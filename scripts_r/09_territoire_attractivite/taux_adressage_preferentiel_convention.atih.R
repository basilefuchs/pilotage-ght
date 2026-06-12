# ==============================================================================
# Indicateur : Taux d'Adressage Préférentiel d'une Convention Inter-Établissements
# Source     : custom (parts de marché conditionnelles ; IGAS 2024, DGOS 2025)
# Pattern    : §5 parcours_sequentiel + §1 taux (contact index A → séjour périmètre)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_adressage_preferentiel_convention.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)            : fixe.ident
# Patient chaîné (national)   : fixe.anonyme
# GHM (6 car) → racine / CMD  : substr(fixe.ghm2, 1, 5) / substr(fixe.ghm2, 1, 2)
# Dates entrée / sortie       : fixe.date_entree / fixe.date_sortie
# Actes CCAM (7 car)          : acte.acte, clé ident
# FINESS géographique du DP   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2016:2025
finess_A <- c("<TODO: FINESS géographiques de l'établissement adresseur A>")
finess_B <- c("<TODO: FINESS géographiques de l'établissement de recours B>")

# Périmètre conventionné (annexe de la convention traduite en codes, à figer
# avec les équipes médicales — un séjour est dans le périmètre s'il porte une
# racine de GHM listée OU un acte CCAM listé)
perim_ghm  <- c("<TODO: racines de GHM (5 car) du périmètre conventionné>")
perim_ccam <- c("<TODO: actes CCAM (7 car) du périmètre conventionné>")

fenetre_jours <- 90   # fenêtre contact index A → séjour du périmètre (fiche : 90 j)
seuil_min     <- 30   # candidats minimum / an pour l'interprétation

# ==== EXTRACTION ====
## Contacts index à A (tout séjour hors séances et erreurs de groupage)
contacts_a <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28"
    ) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% finess_A) %>%
    transmute(anonyme, date_sortie_a = date_sortie, annee = an) %>%
    collect()
})

## Séjours du périmètre conventionné hors A (tous établissements, base nationale)
sejours_perim <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_acte <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  ident_ccam <- tbl_acte %>%
    # acte = code CCAM + phase (8 car, cf. dictionnaire) : matcher sur 7 car
    filter(substr(acte, 1, 7) %in% perim_ccam) %>%
    distinct(ident) %>%
    transmute(ident, a_acte = 1L)

  tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "90") %>%
    left_join(ident_ccam, by = "ident") %>%
    filter(substr(ghm2, 1, 5) %in% perim_ghm | a_acte == 1L) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(!finessgeodp %in% finess_A) %>%
    transmute(anonyme, ident, finessgeodp, date_entree, annee = an) %>%
    collect()
})

# ==== CALCUL : chaînage local contact A → premier séjour du périmètre ====
# Candidat = séjour du périmètre précédé d'un contact à A (≤ fenetre_jours) ;
# un seul candidat par patient (premier séjour du périmètre).
candidats <- sejours_perim %>%
  filter(!is.na(anonyme)) %>%
  inner_join(
    contacts_a %>%
    select(anonyme, date_sortie_a),
    by = "anonyme"
  ) %>%
  mutate(delai = as.numeric(date_entree - date_sortie_a)) %>%
  filter(delai >= 0, delai <= fenetre_jours) %>%
  group_by(ident) %>%
  slice_min(delai, n = 1, with_ties = FALSE) %>%   # contact A le plus proche
  ungroup() %>%
  group_by(anonyme) %>%
  slice_min(date_entree, n = 1, with_ties = FALSE) %>%   # 1er séjour périmètre
  ungroup()

resultat <- candidats %>%
  mutate(vers_b = finessgeodp %in% finess_B) %>%
  group_by(annee) %>%
  summarise(
    N_candidats = n(),
    N_vers_B = sum(vers_b),
    TAP = N_vers_B / N_candidats * 100,
    .groups = "drop"
  ) %>%
  filter(N_candidats >= seuil_min)

# Destinations des adressages non conformes (qui capte ce que B devait recevoir)
destinations_hors_b <- candidats %>%
  filter(!finessgeodp %in% finess_B) %>%
  count(annee, finessgeodp, sort = TRUE)

# ==== RÉSULTAT ====
print(resultat)
print(destinations_hors_b)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = TAP)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(title = "Taux d'adressage préférentiel A → B (périmètre conventionné)",
       y = "TAP (%)", x = NULL) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_adressage_preferentiel_convention.csv")
