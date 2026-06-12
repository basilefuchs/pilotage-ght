# ==============================================================================
# Indicateur : Densité de Patientèle Partagée d'une Dyade d'Établissements
# Source     : care density / patient-sharing (Pollack 2013, PMID:22696255 ;
#              Scodari 2024, PMID:39659048) — forme Jaccard sur files actives
# Pattern    : §7 comptage (recouvrement d'ensembles patients, agrégé en base)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/densite_patientele_partagee_dyade.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)            : fixe.ident
# Patient chaîné (national)   : fixe.anonyme
# CMD (2 car)                 : substr(fixe.ghm2, 1, 2)
# FINESS géographique du DP   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2016:2025
finess_A <- c("<TODO: FINESS géographiques de l'établissement A>")
finess_B <- c("<TODO: FINESS géographiques de l'établissement B>")

seuil_min_patients <- 200   # min(P_A, P_B) minimum / an pour l'interprétation

# ==== EXTRACTION : recouvrement des files actives, agrégé en base ====
# Séances (CMD 28) exclues : un patient dialysé/chimio génère un partage
# mécanique massif — les suivre à part si besoin.
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28",
      !is.na(anonyme)
    ) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% c(finess_A, finess_B)) %>%
    transmute(
      anonyme,
      in_a = if_else(finessgeodp %in% finess_A, 1L, 0L),
      in_b = if_else(finessgeodp %in% finess_B, 1L, 0L)
    ) %>%
    group_by(anonyme) %>%
    summarise(
      in_a = max(in_a),
      in_b = max(in_b),
      .groups = "drop"
    ) %>%
    summarise(
      P_A     = sum(in_a),
      P_B     = sum(in_b),
      partage = sum(if_else(in_a == 1L & in_b == 1L, 1L, 0L))
    ) %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL : Jaccard, formes directionnelles, recouvrement ====
resultat <- resultat %>%
  mutate(
    D   = partage / (P_A + P_B - partage),   # Jaccard
    d_A = partage / P_A,                     # part des patients de A partagés
    d_B = partage / P_B,
    O   = partage / pmin(P_A, P_B)           # overlap (dyades asymétriques)
  ) %>%
  filter(pmin(P_A, P_B) >= seuil_min_patients)

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
resultat %>%
  tidyr::pivot_longer(c(D, d_A, d_B, O), names_to = "mesure", values_to = "valeur") %>%
  ggplot(aes(x = annee, y = valeur, color = mesure)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ mesure, scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(title = "Densité de patientèle partagée de la dyade",
       subtitle = "D = Jaccard ; d_A, d_B = formes directionnelles ; O = recouvrement (min)",
       y = NULL, x = NULL) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "densite_patientele_partagee_dyade.csv")
