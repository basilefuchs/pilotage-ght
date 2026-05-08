# ==============================================================================
# Indicateur : Ratio journées alternatives à l'hospitalisation complète vs HC
# Source     : DREES ER 13/11/2025 ; Panoramas DREES 2024-2025
# Pattern    : §1 — taux composite multi-champs (MCO + HAD), agrégation GHT
# Fiche      : indicateurs_pmsi/04_efficience_capacitaire/ratio_alternatives_vs_hospi_complete.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base : portail_atih  (MCO + HAD)
# --- MCO ---
# Séjour                  : prd_vue_mco_AAAA.fixe.ident
# GHM (6 car.)            : fixe.ghm2
# Durée séjour (nuitées)  : fixe.duree
# FINESS géo (DP)         : finessgeo_umdudp.finessgeodp
# --- HAD ---
# Séjour HAD (1 / sej)    : prd_vue_had_AAAA.fixe_sej.ident_sej
# FINESS HAD              : fixe_sej.finessgeo
# Journées HAD            : fixe_sej.duree
# Code géo patient (HAD)  : prd_vue_had_AAAA.fixe.codegeo
# Jointure HAD            : fixe.ident_sej == fixe_sej.ident_sej
# --- Référentiel ---
# RS établissement        : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees <- 2016:2025

# Composition manuelle des GHT du Finistère
# (ARS Bretagne — arrêtés du 1er juillet 2016)
ght_finess <- tibble::tribble(
  ~ght,                ~finessgeo,    ~rs,
  # GHT Bretagne Occidentale
  "GHT_BO",            "<TODO>",      "CHRU Brest",
  "GHT_BO",            "<TODO>",      "CHRU Brest - Site Carhaix",
  "GHT_BO",            "<TODO>",      "HIA Clermont Tonnerre Brest",
  "GHT_BO",            "<TODO>",      "CH Pays de Morlaix",
  "GHT_BO",            "<TODO>",      "CH Landerneau",
  "GHT_BO",            "<TODO>",      "CH Lesneven",
  "GHT_BO",            "<TODO>",      "CH St-Renan",
  "GHT_BO",            "<TODO>",      "CH Crozon",
  "GHT_BO",            "<TODO>",      "CH Lanmeur",
  # GHT Union Hospitalière de Cornouaille
  "GHT_Cornouaille",   "<TODO>",      "CHIC Quimper",
  "GHT_Cornouaille",   "<TODO>",      "CHIC Quimper - Site Concarneau",
  "GHT_Cornouaille",   "<TODO>",      "CH Douarnenez",
  "GHT_Cornouaille",   "<TODO>",      "CH Quimperlé",
  "GHT_Cornouaille",   "<TODO>",      "EPSM Quimper (Gourmelen)"
)
# <TODO: renseigner les finessgeo réels (vérifier sur portail ATIH ou via
# prd_vue_nomgen.finessgeo). Compléter avec Pont-l'Abbé et CRRF Cornouaille
# si pertinent.>

finess_vec <- ght_finess$finessgeo

# ==== EXTRACTION MCO (numérateur HJ + dénominateur HC, par finess puis GHT) ====
mco_par_ght <- purrr::map_dfr(annees, function(an) {

  tbl_fixe       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_finessgeo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28"
    ) %>%
    inner_join(tbl_finessgeo %>% select(ident, finessgeodp), by = "ident") %>%
    filter(finessgeodp %in% finess_vec) %>%
    transmute(
      ident, finessgeodp,
      annee    = an,
      is_hj    = if_else(duree == 0, 1L, 0L),
      jours_hc = if_else(duree == 0, 0L, as.integer(duree))
    ) %>%
    group_by(annee, finessgeodp) %>%
    summarise(
      jours_hj = sum(is_hj, na.rm = TRUE),
      jours_hc = sum(jours_hc, na.rm = TRUE),
      .groups  = "drop"
    ) %>%
    collect()
}) %>%
  inner_join(ght_finess %>% select(finessgeo, ght),
             by = c("finessgeodp" = "finessgeo")) %>%
  group_by(annee, ght) %>%
  summarise(
    jours_hj = sum(jours_hj, na.rm = TRUE),
    jours_hc = sum(jours_hc, na.rm = TRUE),
    .groups  = "drop"
  )

# ==== EXTRACTION HAD (attribution par codegeo patient = domicile) ====
# Étape 1 — table de correspondance codegeo → GHT (zone d'attractivité MCO,
# proxy géographique stable sur la période)
codegeo_par_ght <- purrr::map_dfr(annees, function(an) {

  tbl_fixe       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_finessgeo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    inner_join(tbl_finessgeo %>% select(ident, finessgeodp), by = "ident") %>%
    filter(finessgeodp %in% finess_vec) %>%
    select(codegeo, finessgeodp) %>%
    collect()
}) %>%
  inner_join(ght_finess %>% select(finessgeo, ght),
             by = c("finessgeodp" = "finessgeo")) %>%
  count(codegeo, ght, name = "n_sej") %>%
  group_by(codegeo) %>%
  slice_max(n_sej, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(codegeo, ght)

# Étape 2 — journées HAD par codegeo patient, agrégées sur le GHT
had_par_ght <- purrr::map_dfr(annees, function(an) {

  tbl_had_sej <- tbl(conn, I(paste0("prd_vue_had_", an, ".fixe_sej")))
  tbl_had_pat <- tbl(conn, I(paste0("prd_vue_had_", an, ".fixe")))

  tbl_had_sej %>%
    inner_join(tbl_had_pat %>% select(ident_sej, codegeo), by = "ident_sej") %>%
    transmute(
      annee     = an,
      codegeo,
      jours_had = as.integer(duree)
    ) %>%
    group_by(annee, codegeo) %>%
    summarise(jours_had = sum(jours_had, na.rm = TRUE), .groups = "drop") %>%
    collect()
}) %>%
  inner_join(codegeo_par_ght, by = "codegeo") %>%
  group_by(annee, ght) %>%
  summarise(jours_had = sum(jours_had, na.rm = TRUE), .groups = "drop")

# ==== AGRÉGATION ET RATIO ====
resultat <- mco_par_ght %>%
  left_join(had_par_ght, by = c("annee", "ght")) %>%
  mutate(
    jours_had         = coalesce(jours_had, 0L),
    ratio_alt_hc      = (jours_hj + jours_had) / jours_hc,
    part_alternatives = (jours_hj + jours_had) / (jours_hj + jours_had + jours_hc)
  )

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = ratio_alt_hc, color = ght)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(ght, ght), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Ratio (HJ MCO + journées HAD) / journées HC MCO — par GHT",
       subtitle = "Finistère — GHT Bretagne Occidentale vs GHT Cornouaille",
       y = "Ratio alternatives / hospitalisation complète", x = NULL)

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "ratio_alternatives_vs_hospi_complete_ght.csv")
