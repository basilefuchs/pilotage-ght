# ==============================================================================
# Indicateur : Taux d'Adressage Préférentiel d'une Convention Inter-Établissements
# Source     : custom (parts de marché conditionnelles ; IGAS 2024, DGOS 2025)
# Pattern    : §5 parcours_sequentiel + §1 taux (contact index A → séjour périmètre)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_adressage_preferentiel_convention.md
# Base       : SNDS (portail CNAM) — variante de taux_adressage_preferentiel_convention.atih.R
#              Avantages SNDS : dates réelles dès 2016 (pas de limite 2019) et
#              garde-fou décès via IR_BEN_R, impossibles sur le portail ATIH.
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil snds_mco — réutilisable en tête des prochains prompts
#
# Base                    : SNDS Oracle, tables annuelles T_MCOaaX (aa = millésime 2 chiffres)
# Connexion               : ROracle::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
# Séjour RSA (1 ligne)    : T_MCOaaB, clé (ETA_NUM, RSA_NUM)
# GHM (GENRSA)            : T_MCOaaB.GRG_GHM (racine = substr(GRG_GHM, 1, 5))
# FINESS                  : T_MCOaaB.ETA_NUM
# Patient pseudonymisé    : T_MCOaaC.NIR_ANO_17
# Dates entrée / sortie   : T_MCOaaC.EXE_SOI_DTD / EXE_SOI_DTF
# Qualité chaînage        : T_MCOaaC.{NIR,NAI,SEX,SEJ,FHO,PMS,DAT}_RET tous = '0'
# Actes CCAM (7 car)      : T_MCOaaA.CDC_ACT, clé (ETA_NUM, RSA_NUM), phase = PHA_ACT
# Date de décès           : IR_BEN_R.BEN_DCD_DTE (jointure NIR_ANO_17 = BEN_NIR_PSA)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- ROracle::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")

# ==== PARAMÈTRES ====
annees   <- 2016:2024  # dates réelles disponibles sur toute la profondeur SNDS
finess_A <- c("<TODO: FINESS de l'établissement adresseur A (ETA_NUM)>")
finess_B <- c("<TODO: FINESS de l'établissement de recours B (ETA_NUM)>")
# NB : ETA_NUM = FINESS d'inscription e-PMSI (juridique pour AP-HP/AP-HM/HCL) —
# si A ou B en fait partie, utiliser le FINESS juridique correspondant

# Périmètre conventionné (annexe de la convention traduite en codes, à figer
# avec les équipes médicales — un séjour est dans le périmètre s'il porte une
# racine de GHM listée OU un acte CCAM listé)
perim_ghm  <- c("<TODO: racines de GHM (5 car) du périmètre conventionné>")
perim_ccam <- c("<TODO: actes CCAM (7 car) du périmètre conventionné>")

fenetre_jours <- 90   # fenêtre contact index A → séjour du périmètre (fiche : 90 j)
seuil_min     <- 30   # candidats minimum / an pour l'interprétation
chainage_ok   <- "0"  # valeur OK de chaque code retour de chaînage
# FINESS juridiques doublonnés AP-HP / AP-HM / HCL (doublons des FINESS géo)
finess_doublons <- c("750712184", "130780521", "690783154")

# Chaînage exploitable (filtre commun aux extractions)
filtre_chainage <- function(tbl_c) {
  tbl_c %>%
    filter(
      NIR_RET == chainage_ok, NAI_RET == chainage_ok, SEX_RET == chainage_ok,
      SEJ_RET == chainage_ok, FHO_RET == chainage_ok, PMS_RET == chainage_ok,
      DAT_RET == chainage_ok
    )
}

# ==== RÉFÉRENTIEL DÉCÈS — garde-fou qualité de chaînage ====
# Un séjour du périmètre postérieur à la date de décès du bénéficiaire signe
# une clé de chaînage défaillante : le candidat est exclu.
tbl_deces <- tbl(conn, "IR_BEN_R") %>%
  filter(!is.na(BEN_DCD_DTE), BEN_DCD_DTE > to_date("1900-01-01", "YYYY-MM-DD")) %>%
  group_by(BEN_NIR_PSA) %>%
  summarise(date_deces = min(BEN_DCD_DTE, na.rm = TRUE), .groups = "drop")

# ==== EXTRACTION ====
## Contacts index à A (tout séjour hors séances et erreurs de groupage)
contacts_a <- purrr::map_dfr(annees, function(an) {

  aa    <- substr(as.character(an), 3, 4)
  tbl_b <- tbl(conn, paste0("T_MCO", aa, "B"))
  tbl_c <- tbl(conn, paste0("T_MCO", aa, "C"))

  tbl_b %>%
    filter(
      substr(GRG_GHM, 1, 2) != "90",
      substr(GRG_GHM, 1, 2) != "28",
      ETA_NUM %in% finess_A
    ) %>%
    inner_join(
      filtre_chainage(tbl_c) %>%
        select(ETA_NUM, RSA_NUM, NIR_ANO_17, EXE_SOI_DTF),
      by = c("ETA_NUM", "RSA_NUM")
    ) %>%
    transmute(nir = NIR_ANO_17, date_sortie_a = EXE_SOI_DTF, annee = an) %>%
    collect()
})

## Séjours du périmètre conventionné hors A (tous établissements, base nationale)
sejours_perim <- purrr::map_dfr(annees, function(an) {

  aa    <- substr(as.character(an), 3, 4)
  tbl_b <- tbl(conn, paste0("T_MCO", aa, "B"))
  tbl_c <- tbl(conn, paste0("T_MCO", aa, "C"))
  tbl_a <- tbl(conn, paste0("T_MCO", aa, "A"))

  sejours_ccam <- tbl_a %>%
    filter(CDC_ACT %in% perim_ccam) %>%
    distinct(ETA_NUM, RSA_NUM) %>%
    mutate(a_acte = 1L)

  tbl_b %>%
    filter(
      substr(GRG_GHM, 1, 2) != "90",
      !ETA_NUM %in% finess_A,
      !ETA_NUM %in% finess_doublons
    ) %>%
    left_join(sejours_ccam, by = c("ETA_NUM", "RSA_NUM")) %>%
    filter(substr(GRG_GHM, 1, 5) %in% perim_ghm | a_acte == 1L) %>%
    inner_join(
      filtre_chainage(tbl_c) %>%
        select(ETA_NUM, RSA_NUM, NIR_ANO_17, EXE_SOI_DTD),
      by = c("ETA_NUM", "RSA_NUM")
    ) %>%
    transmute(nir = NIR_ANO_17, ETA_NUM, RSA_NUM,
              date_entree = EXE_SOI_DTD, annee = an) %>%
    collect()
})

deces <- tbl_deces %>% collect()

# ==== CALCUL : chaînage local contact A → premier séjour du périmètre ====
# Candidat = séjour du périmètre précédé d'un contact à A (≤ fenetre_jours) ;
# un seul candidat par patient (premier séjour du périmètre).
candidats <- sejours_perim %>%
  inner_join(
    contacts_a %>% select(nir, date_sortie_a),
    by = "nir", relationship = "many-to-many"
  ) %>%
  mutate(delai = as.numeric(date_entree - date_sortie_a)) %>%
  filter(delai >= 0, delai <= fenetre_jours) %>%
  left_join(deces, by = c("nir" = "BEN_NIR_PSA")) %>%
  filter(is.na(date_deces) | date_deces >= date_entree) %>%  # garde-fou décès
  group_by(ETA_NUM, RSA_NUM) %>%
  slice_min(delai, n = 1, with_ties = FALSE) %>%   # contact A le plus proche
  ungroup() %>%
  group_by(nir) %>%
  slice_min(date_entree, n = 1, with_ties = FALSE) %>%   # 1er séjour périmètre
  ungroup()

resultat <- candidats %>%
  mutate(vers_b = ETA_NUM %in% finess_B) %>%
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
  filter(!ETA_NUM %in% finess_B) %>%
  count(annee, ETA_NUM, sort = TRUE)

# ==== RÉSULTAT ====
print(resultat)
print(destinations_hors_b)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = TAP)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(title = "Taux d'adressage préférentiel A → B (périmètre conventionné, SNDS)",
       y = "TAP (%)", x = NULL) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_adressage_preferentiel_convention_snds.csv")
