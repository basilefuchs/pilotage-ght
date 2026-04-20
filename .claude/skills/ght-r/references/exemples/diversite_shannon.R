# ==============================================================================
# Indicateur : Entropie de Shannon du casemix
# Source     : custom (basé sur Shannon 1948)
# Pattern    : §4 — mesure_diversite
# Catégorie  : 02_casemix_patientele
# Fiche      : indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# GHM                   : fixe.ghm2 (6 car), racine = substr(ghm2, 1, 5)
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees         <- 2016:2025
dep            <- "29"              # Finistère (filtre FINESS)
granularite    <- "racine"          # "complet" (6 car), "racine" (5 car), "cmd" (2 car)
seuil_min_sej  <- 500               # seuil de robustesse statistique (fiche : 500)

# ==== EXTRACTION — distribution des GHMs par établissement × année ====
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Longueur de troncature selon granularité choisie
  long <- switch(granularite,
                 "complet" = 6L,
                 "racine"  = 5L,
                 "cmd"     = 2L)

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",         # exclure erreurs de groupage
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      finessgeo = finessgeodp,
      ident,
      code = substr(ghm2, 1, long),
      annee = an
    ) %>%
    group_by(annee, finessgeo, code) %>%
    summarise(
      N_i = n_distinct(ident),
      .groups = "drop"
    ) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
# Entropie de Shannon : H = -sum(p_i * log2(p_i))
# Entropie normalisée : H' = H / log2(n_modalites)  ∈ [0 ; 1]

calcul_shannon <- function(df) {
  df %>%
    group_by(annee, finessgeo) %>%
    mutate(p_i = N_i / sum(N_i)) %>%
    summarise(
      N_total  = sum(N_i),
      n_codes  = n_distinct(code),
      H        = -sum(p_i * log2(p_i), na.rm = TRUE),
      H_max    = log2(n_codes),
      H_norm   = if_else(H_max > 0, H / H_max, 0),
      .groups  = "drop"
    )
}

resultat <- calcul_shannon(distribution) %>%
  filter(N_total >= seuil_min_sej) %>%
  mutate(rs = finessgeo)   # à enrichir avec libellé RS si table dispo

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot2::ggplot(resultat, aes(x = annee, y = H_norm, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = paste0("Entropie de Shannon normalisée du casemix MCO (granularité : ",
                   granularite, ")"),
    x = "Année",
    y = "H' (0 = spécialisé, 1 = polyvalent)",
    caption = paste0("Seuil robustesse : n >= ", seuil_min_sej, " séjours/an")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "entropie_shannon_casemix.csv")
