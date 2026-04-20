# ==============================================================================
# Indicateur : Taux d'Actes Diagnostiques Redondants
# Source     : custom — pertinence des pratiques (GHT)
# Pattern    : §1 — taux (intra-séjour)
#              + §5 — parcours_sequentiel (inter-séjours, section commentée)
# Fiche      : indicateurs_pmsi/06_pertinence_pratiques/taux_actes_diagnostiques_redondants.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Séjour (1 ligne)      : <table_sejours>.<col_ident>
# FINESS géographique   : <table_sejours>.<col_finessgeo>
# CMD                   : <table_sejours>.<col_cmd>
# Date entrée séjour    : <table_sejours>.<col_date_entree>    [inter-séjours]
# Date sortie séjour    : <table_sejours>.<col_date_sortie>    [inter-séjours]
# Ident patient chaîné  : <table_sejours>.<col_ident_patient>  [inter-séjours]
# Code acte CCAM        : <table_actes>.<col_ccam>
# Raison sociale        : <table_finess>.<col_rs> (jointure sur finessgeo)
# Préfixe schéma annuel : <prefix>  (ex: prd_vue_mco)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)
library(readr)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees    <- 2019:2025
seuil_min <- 30   # séjours min par famille × établissement × an

# Référentiel des familles d'actes diagnostiques traceurs
# Codes CCAM issus de la fiche — à compléter depuis le référentiel ATIH complet
# <TODO: compléter la liste avec tous les codes CCAM équivalents par famille>
familles_ccam <- tibble::tribble(
  ~ccam_code,   ~famille,              ~delai_j,
  "ZBQK002",    "scanner_thorax",      7,
  "ZZQN002",    "scanner_thorax",      7,
  "ZZQK002",    "scanner_abdo",        7,
  "BZQK002",    "irm_cerebrale",       14,
  "HGED004",    "fibroscopie",         30,
  "HGEH001",    "fibroscopie",         30,
  "HHQE003",    "coloscopie",          30,
  "HHQE001",    "coloscopie",          30,
  "DKJB001",    "coronaro",            30,
  "DKJB002",    "coronaro",            30,
  "GEJE001",    "bronchoscopie",       14,
  "GEJB001",    "bronchoscopie",       14,
  "HHHB001",    "biopsie_hepatique",   90
)

all_traceur_codes <- familles_ccam$ccam_code

# ==============================================================================
# PARTIE 1 — Redondance INTRA-SÉJOUR
# Définition : ≥ 2 actes CCAM de la même famille dans le même séjour
# Ne nécessite pas de chaînage patient
# ==============================================================================

resultat_intra <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))
  tbl_actes   <- tbl(conn, I(paste0("<prefix>_", an, ".<table_actes>")))

  # Séjours éligibles : hors séances CMD 28
  denom_tbl <- tbl_sejours %>%
    filter(<col_cmd> != "28") %>%
    transmute(
      ident     = <col_ident>,
      finessgeo = <col_finessgeo>
    )

  # Actes traceurs des séjours éligibles — rapatriés en local pour join famille
  actes_raw <- tbl_actes %>%
    filter(<col_ccam> %in% !!all_traceur_codes) %>%
    transmute(ident = <col_ident>, ccam_code = <col_ccam>) %>%
    inner_join(denom_tbl, by = "ident") %>%
    collect() %>%
    inner_join(familles_ccam, by = "ccam_code")   # mapping local ccam_code → famille + délai

  # Dénominateur : séjours distincts ayant ≥1 acte traceur de la famille
  denom <- actes_raw %>%
    distinct(ident, finessgeo, famille)

  # Numérateur : séjours avec ≥2 actes de la même famille (redondance intra)
  num <- actes_raw %>%
    group_by(ident, finessgeo, famille) %>%
    summarise(n_actes = n(), .groups = "drop") %>%
    filter(n_actes >= 2) %>%
    distinct(ident, finessgeo, famille)

  # Taux par famille × établissement
  denom %>%
    group_by(finessgeo, famille) %>%
    summarise(N_total = n_distinct(ident), .groups = "drop") %>%
    left_join(
      num %>%
        group_by(finessgeo, famille) %>%
        summarise(N_i = n_distinct(ident), .groups = "drop"),
      by = c("finessgeo", "famille")
    ) %>%
    mutate(
      N_i   = coalesce(N_i, 0L),
      taux  = N_i / N_total,
      annee = an
    )
})

# Filtre robustesse + jointure raison sociale
# <TODO: remplacer par la vue/table FINESS de votre base>
ref_finess <- tbl(conn, I("<table_finess>")) %>%
  transmute(finessgeo = <col_finessgeo_ref>, rs = <col_rs>) %>%
  collect()

resultat_intra <- resultat_intra %>%
  filter(N_total >= seuil_min) %>%
  left_join(ref_finess, by = "finessgeo")

# ==============================================================================
# PARTIE 2 — Redondance INTER-SÉJOURS (optionnel — nécessite chaînage NIR)
# Définition : acte famille F en séjour S-1, même famille en séjour S,
#              délai(sortie S-1 → entrée S) ≤ délai_j de la famille
# <TODO: activer si identifiant patient chaîné disponible>
# ==============================================================================

# sejours_chaines <- purrr::map_dfr(annees, function(an) {
#
#   tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))
#   tbl_actes   <- tbl(conn, I(paste0("<prefix>_", an, ".<table_actes>")))
#
#   tbl_actes %>%
#     filter(<col_ccam> %in% !!all_traceur_codes) %>%
#     transmute(ident = <col_ident>, ccam_code = <col_ccam>) %>%
#     inner_join(
#       tbl_sejours %>%
#         filter(<col_cmd> != "28") %>%
#         transmute(
#           ident         = <col_ident>,
#           ident_patient = <col_ident_patient>,
#           finessgeo     = <col_finessgeo>,
#           date_entree   = <col_date_entree>,
#           date_sortie   = <col_date_sortie>
#         ),
#       by = "ident"
#     ) %>%
#     collect() %>%
#     inner_join(familles_ccam, by = "ccam_code") %>%
#     mutate(annee = an)
# })
#
# redondants_inter <- sejours_chaines %>%
#   arrange(ident_patient, famille, date_entree) %>%
#   group_by(ident_patient, famille) %>%
#   mutate(
#     delai_inter    = as.numeric(lead(date_entree) - date_sortie),
#     finessgeo_suiv = lead(finessgeo)
#   ) %>%
#   ungroup() %>%
#   filter(
#     !is.na(delai_inter),
#     delai_inter >= 0,
#     delai_inter <= delai_j
#   )
#
# resultat_inter <- redondants_inter %>%
#   group_by(annee, finessgeo, famille) %>%
#   summarise(N_i = n_distinct(ident_patient), .groups = "drop") %>%
#   filter(N_i >= seuil_min) %>%
#   left_join(ref_finess, by = "finessgeo")

# ==============================================================================
# RÉSULTAT
# ==============================================================================

print(resultat_intra)

# ==== VISUALISATION ====
# Taux de redondance intra-séjour par famille d'actes × établissement
# (facets par famille — viz alternative au pattern timeseries/établissement
#  car la dimension famille est la plus interprétable ici)
ggplot2::ggplot(
  resultat_intra,
  aes(x = annee, y = taux * 100, color = rs)
) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(famille, famille), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(
    title    = "Taux d'actes diagnostiques redondants (intra-séjour)",
    subtitle = "Séjours avec >= 2 actes de la même famille CCAM / séjours avec >= 1 acte traceur",
    y        = "Taux (%)", x = NULL, color = "Établissement"
  ) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_intra,
#   "indicateur_taux_actes_diagnostiques_redondants_intra.csv")
