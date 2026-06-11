# ==============================================================================
# Indicateur : Kilométrage Excédentaire des Séjours en Fuite
# Source     : custom (géographie de la santé, modèles gravitaires — Kapitza 2026)
# Pattern    : §3 — mediane_percentile (distribution des excédents de distance)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/kilometrage_excedentaire_fuite.md
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

col_dist   <- "distance"  # "distance" (km) ou "tps_trajet" (minutes)
v_min      <- 30          # séjours/an pour qu'un site GHT soit "compétent" sur une racine
seuil_min  <- 100         # robustesse : séjours en fuite minimum par maille (fiche : ≥ 100)
cap_pctile <- 0.99        # plafonnement des excédents pour KE_total (mobilités, vacances)

modes_entree_exclus <- c("6", "7")  # mutation, transfert — <TODO: confirmer les codes>

# ==== EXTRACTION (séjour par séjour : la distribution est calculée en local) ====
exc_sejours <- purrr::map_dfr(annees, function(an) {

  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_dist  <- tbl(conn, I("nom_gen.finess_codegeo_distance_tps"))

  dist_an <- tbl_dist %>%
    filter(an >= annee_deb, an <= annee_fin,
           codegeo %in% codegeo_ght) %>%
    transmute(finess, codegeo, dist = !!rlang::sym(col_dist))

  # Séjours en fuite des résidents (hors séances, erreurs, transferts)
  fuite <- tbl_fixe %>%
    filter(codegeo %in% codegeo_ght,
           substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28",
           !modeentree %in% modes_entree_exclus) %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    filter(!finessgeodp %in% finess_ght) %>%
    transmute(ident, codegeo, finessgeodp, racine = substr(ghm2, 1, 5))

  # Sites GHT compétents par racine (production totale du site)
  sites_competents <- tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28") %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    filter(finessgeodp %in% finess_ght) %>%
    transmute(ident, finessgeodp, racine = substr(ghm2, 1, 5)) %>%
    group_by(finessgeodp, racine) %>%
    summarise(N_prod = n_distinct(ident), .groups = "drop") %>%
    filter(N_prod >= v_min)

  # Distance minimale au site GHT compétent par (codegeo, racine)
  d_ght <- sites_competents %>%
    inner_join(dist_an, by = c("finessgeodp" = "finess")) %>%
    group_by(codegeo, racine) %>%
    summarise(d_ght = min(dist, na.rm = TRUE), .groups = "drop")

  # Excédent par séjour en fuite éligible (inner_join = recours structurel exclu)
  fuite %>%
    inner_join(d_ght, by = c("codegeo", "racine")) %>%
    left_join(dist_an, by = c("finessgeodp" = "finess", "codegeo" = "codegeo")) %>%
    filter(!is.na(dist)) %>%
    transmute(annee = an, ident, racine, exc = dist - d_ght) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
synthese_exc <- function(df) {
  df %>%
    summarise(
      n_fuite     = n_distinct(ident),
      KE_median   = median(exc, na.rm = TRUE),
      KE_p25      = quantile(exc, 0.25, na.rm = TRUE),
      KE_p75      = quantile(exc, 0.75, na.rm = TRUE),
      P_proximite = mean(exc <= 0, na.rm = TRUE),
      # plafonnement au percentile haut avant cumul (mobilités non résidentielles)
      KE_total    = sum(pmax(0, pmin(exc, quantile(exc, cap_pctile, na.rm = TRUE))),
                        na.rm = TRUE),
      .groups     = "drop"
    )
}

resultat_global <- exc_sejours %>%
  group_by(annee) %>%
  synthese_exc()

resultat_racine <- exc_sejours %>%
  group_by(annee, racine) %>%
  synthese_exc() %>%
  filter(n_fuite >= seuil_min)

# ==== RÉSULTAT ====
print(resultat_global)
print(resultat_racine %>% arrange(desc(KE_median)) %>% head(20))

# ==== VISUALISATION ====
ggplot2::ggplot(resultat_global, aes(x = annee, y = KE_median)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  geom_errorbar(aes(ymin = KE_p25, ymax = KE_p75), width = 0.2, alpha = 0.4) +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(NA, NA)) +
  labs(y = paste0("excédent médian (", col_dist, ")")) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_racine, "indicateur_kilometrage_excedentaire_fuite.csv")
