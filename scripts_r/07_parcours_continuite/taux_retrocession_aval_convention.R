# ==============================================================================
# Indicateur : Taux de Rétrocession d'Aval d'une Convention de Recours
# Source     : repatriation / régionalisation (Mesfin 2026, PMID:42036067 ;
#              Samuels-Kalow 2023, PMID:36099536)
# Pattern    : §5 parcours_sequentiel (3 maillons A → B → suite, multi-champ MCO+SMR)
# Fiche      : indicateurs_pmsi/07_parcours_continuite/taux_retrocession_aval_convention.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schémas : prd_vue_mco_AAAA / prd_vue_smr_AAAA
#
# MCO — Séjour (1 ligne)      : fixe.ident
# MCO — Patient chaîné        : fixe.anonyme
# MCO — GHM / CMD             : substr(fixe.ghm2, 1, 5) / substr(fixe.ghm2, 1, 2)
# MCO — Dates entrée / sortie : fixe.date_entree / fixe.date_sortie
# MCO — Mode sortie (9 décès) : fixe.modesortie
# MCO — Actes CCAM            : acte.acte, clé ident
# MCO — FINESS géo. du DP     : finessgeo_umdudp.finessgeodp
# SMR — Patient chaîné        : fixe_sej.anonyme  (clé commune MCO ↔ SMR)
# SMR — Dates entrée / sortie : fixe_sej.date_entree / fixe_sej.date_sortie
# SMR — FINESS géographique   : fixe_sej.finessgeo
#       <TODO: confirmer que finessgeo est porté par fixe_sej (sinon joindre la vue adéquate)>
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
finess_A <- c("<TODO: FINESS géographiques de l'établissement adresseur A (MCO + SMR)>")
finess_B <- c("<TODO: FINESS géographiques de l'établissement de recours B>")

# Périmètre conventionné (partagé avec taux_adressage_preferentiel_convention.R)
perim_ghm  <- c("<TODO: racines de GHM (5 car) du périmètre conventionné>")
perim_ccam <- c("<TODO: actes CCAM (7 car) du périmètre conventionné>")

fenetre_adressage <- 90   # fenêtre contact A → séjour périmètre à B (fiche : 90 j)
fenetre_retour    <- 90   # fenêtre sortie de B → séjour de suite (fiche : 90 j)
seuil_min         <- 30   # adressages avec suite minimum / an

# ==== EXTRACTION ====
## Contacts index à A
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
    transmute(anonyme, date_sortie_a = date_sortie) %>%
    collect()
})

## Séjours du périmètre conventionné à B (hors décès au cours du séjour)
sejours_b <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_acte <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  ident_ccam <- tbl_acte %>%
    # acte = CCAM + phase (8 car, dico ATIH) : matcher sur 7 car
    filter(substr(acte, 1, 7) %in% perim_ccam) %>%
    distinct(ident) %>%
    transmute(ident, a_acte = 1L)

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      modesortie != "9"
    ) %>%
    left_join(ident_ccam, by = "ident") %>%
    filter(substr(ghm2, 1, 5) %in% perim_ghm | a_acte == 1L) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% finess_B) %>%
    transmute(anonyme, ident, date_entree_b = date_entree,
              date_sortie_b = date_sortie, annee = an) %>%
    collect()
})

## Adressages A → B : séjour à B précédé d'un contact à A (≤ fenetre_adressage)
adressages <- sejours_b %>%
  filter(!is.na(anonyme)) %>%
  inner_join(contacts_a, by = "anonyme") %>%
  mutate(delai = as.numeric(date_entree_b - date_sortie_a)) %>%
  filter(delai >= 0, delai <= fenetre_adressage) %>%
  group_by(ident) %>%
  slice_min(delai, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  group_by(anonyme) %>%
  slice_min(date_entree_b, n = 1, with_ties = FALSE) %>%   # 1 adressage / patient
  ungroup()

anonymes_adresses <- unique(adressages$anonyme)
# NB : si la liste dépasse quelques milliers d'identifiants, préférer
# copy_to(conn, ...) + semi_join SQL plutôt que %in% (limite Teradata).

## Séjours de suite candidats : MCO (tous établissements) + SMR
suites_mco <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28",
      anonyme %in% anonymes_adresses
    ) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(anonyme, finessgeo_suite = finessgeodp,
              date_entree_suite = date_entree, champ = "MCO") %>%
    collect()
})

suites_smr <- purrr::map_dfr(annees, function(an) {

  tbl_smr <- tbl(conn, I(paste0("prd_vue_smr_", an, ".fixe_sej")))

  tbl_smr %>%
    filter(anonyme %in% anonymes_adresses) %>%
    transmute(anonyme, finessgeo_suite = finessgeo,
              date_entree_suite = date_entree, champ = "SMR") %>%
    collect()
})

# ==== CALCUL : première suite ≤ fenetre_retour, classée retour A / reste B / tiers ====
suites <- bind_rows(suites_mco, suites_smr) %>%
  inner_join(
    adressages %>%
    select(anonyme, ident_b = ident, date_sortie_b, annee),
    by = "anonyme"
  ) %>%
  mutate(delai_suite = as.numeric(date_entree_suite - date_sortie_b)) %>%
  filter(delai_suite > 0, delai_suite <= fenetre_retour) %>%
  group_by(ident_b) %>%
  slice_min(delai_suite, n = 1, with_ties = FALSE) %>%   # première suite
  ungroup() %>%
  mutate(
    destination = case_when(
      finessgeo_suite %in% finess_A ~ "retour_A",
      finessgeo_suite %in% finess_B ~ "reste_B",
      TRUE                          ~ "tiers"
    )
  )

resultat <- suites %>%
  group_by(annee) %>%
  summarise(
    N_suites  = n(),
    N_retour  = sum(destination == "retour_A"),
    N_reste_b = sum(destination == "reste_B"),
    N_tiers   = sum(destination == "tiers"),
    TR = N_retour / N_suites * 100,
    delai_median_retour = median(delai_suite[destination == "retour_A"]),
    .groups = "drop"
  ) %>%
  filter(N_suites >= seuil_min)

# Part des adressages sans aucune suite hospitalière observée (succès cliniques
# + perdus de vue, indissociables sans SNDS)
sans_suite <- adressages %>%
  group_by(annee) %>%
  summarise(N_adressages = n(), .groups = "drop") %>%
  left_join(
    resultat %>%
    select(annee, N_suites),
    by = "annee"
  ) %>%
  mutate(part_sans_suite = 1 - N_suites / N_adressages)

# ==== RÉSULTAT ====
print(resultat)
print(sans_suite)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = TR)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(title = "Taux de rétrocession d'aval B → A (adressages conventionnés)",
       subtitle = paste0("fenêtre retour ", fenetre_retour,
                         " j — dénominateur : adressages avec suite hospitalière"),
       y = "TR (%)", x = NULL) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_retrocession_aval_convention.csv")
