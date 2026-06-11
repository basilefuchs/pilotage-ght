# ==============================================================================
# Indicateur : Taux de Bypass du Site Compétent le Plus Proche
# Source     : custom (littérature "hospital bypass" — Mullens 2026, Abid 2025)
# Pattern    : §1 — taux (numérateur conditionné par une distance)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_bypass_site_competent_plus_proche.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA (+ nom_gen pour le distancier)
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car)                   : fixe.ghm2
# Racine GHM (5 car)            : substr(ghm2, 1, 5)
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Mode entrée                   : fixe.modeentree
# Code géographique patient     : fixe.codegeo
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# Distancier FINESS × codegeo   : nom_gen.finess_codegeo_distance_tps
#                                 (finess, codegeo, distance, tps_trajet,
#                                  annee_deb, annee_fin — période de validité)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees      <- 2016:2025
finess_ght  <- c("<TODO: liste des FINESS géographiques du GHT>")
codegeo_ght <- c("<TODO: liste des codes géographiques PMSI du territoire>")

col_dist  <- "distance"   # "distance" (km) ou "tps_trajet" (minutes)
delta     <- 15           # tolérance au-delà du site GHT compétent (fiche : 10-30 km)
v_min     <- 30           # séjours/an pour qu'un site soit "compétent" sur une racine
seuil_min <- 30           # robustesse : N_total minimal par racine pour l'interprétation

modes_entree_exclus <- c("6", "7")  # mutation, transfert — <TODO: confirmer les codes>

# ==== EXTRACTION ====
resultat_racine <- purrr::map_dfr(annees, function(an) {

  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_dist  <- tbl(conn, I("nom_gen.finess_codegeo_distance_tps"))

  # Distancier valide pour l'année, restreint au territoire
  dist_an <- tbl_dist %>%
    filter(an >= annee_deb, an <= annee_fin,
           codegeo %in% codegeo_ght) %>%
    transmute(finess, codegeo, dist = !!rlang::sym(col_dist))

  # Séjours des résidents du territoire (hors séances, erreurs, transferts —
  # la destination d'un transfert n'est pas un choix du patient)
  sejours <- tbl_fixe %>%
    filter(codegeo %in% codegeo_ght,
           substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28",
           !modeentree %in% modes_entree_exclus) %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    transmute(ident, codegeo, finessgeodp, racine = substr(ghm2, 1, 5))

  # Sites GHT compétents par racine : production TOTALE du site (pas
  # seulement les résidents du territoire)
  sites_competents <- tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28") %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    filter(finessgeodp %in% finess_ght) %>%
    transmute(ident, finessgeodp, racine = substr(ghm2, 1, 5)) %>%
    group_by(finessgeodp, racine) %>%
    summarise(N_prod = n_distinct(ident), .groups = "drop") %>%
    filter(N_prod >= v_min)

  # Distance minimale au site GHT compétent, par (codegeo, racine)
  d_ght <- sites_competents %>%
    inner_join(dist_an, by = c("finessgeodp" = "finess")) %>%
    group_by(codegeo, racine) %>%
    summarise(d_ght = min(dist, na.rm = TRUE), .groups = "drop")

  # Classification : l'inner_join sur d_ght exclut le recours structurel
  # (racines sans site GHT compétent → pas de bypass possible)
  sejours %>%
    inner_join(d_ght, by = c("codegeo", "racine")) %>%
    left_join(dist_an, by = c("finessgeodp" = "finess", "codegeo" = "codegeo")) %>%
    filter(!is.na(dist)) %>%  # établissements absents du distancier
    mutate(
      bypass = if_else(!finessgeodp %in% finess_ght & dist > d_ght + delta, 1L, 0L)
    ) %>%
    group_by(racine) %>%
    summarise(
      N_total  = n_distinct(ident),
      N_bypass = sum(bypass, na.rm = TRUE),
      .groups  = "drop"
    ) %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
# Taux global GHT par année
resultat_global <- resultat_racine %>%
  group_by(annee) %>%
  summarise(
    N_total     = sum(N_total),
    N_bypass    = sum(N_bypass),
    taux_bypass = N_bypass / N_total,
    .groups     = "drop"
  )

# Taux par racine (filtre de robustesse)
resultat_racine <- resultat_racine %>%
  filter(N_total >= seuil_min) %>%
  mutate(taux_bypass = N_bypass / N_total)

# ==== RÉSULTAT ====
print(resultat_global)
print(resultat_racine %>% arrange(desc(N_bypass)) %>% head(20))

# ==== VISUALISATION ====
# Série globale GHT
ggplot2::ggplot(resultat_global, aes(x = annee, y = taux_bypass)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal()

# Top 12 racines contributrices (en volume de bypass cumulé)
top_racines <- resultat_racine %>%
  group_by(racine) %>%
  summarise(N_bypass_cum = sum(N_bypass), .groups = "drop") %>%
  arrange(desc(N_bypass_cum)) %>%
  head(12) %>%
  pull(racine)

ggplot2::ggplot(
  resultat_racine %>% filter(racine %in% top_racines),
  aes(x = annee, y = taux_bypass, color = racine)
) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(racine, racine), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_racine, "indicateur_taux_bypass_site_competent.csv")
