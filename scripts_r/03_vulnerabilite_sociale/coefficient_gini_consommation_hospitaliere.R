# ==============================================================================
# Indicateur : Coefficient de Gini de la Consommation Hospitalière
# Source     : custom — vulnérabilité sociale (GHT)
# Pattern    : §4 — mesure_diversite (Gini sur distribution patient × consommation)
# Fiche      : indicateurs_pmsi/03_vulnerabilite_sociale/coefficient_gini_consommation_hospitaliere.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Séjour (1 ligne)      : <table_sejours>.<col_ident>
# Ident patient chaîné  : <table_sejours>.<col_ident_patient>   (NIR crypté)
# FINESS géographique   : <table_sejours>.<col_finessgeo>
# CMD                   : <table_sejours>.<col_cmd>
# Durée séjour (jours)  : <table_sejours>.<col_duree>
# Valorisation GHS €    : <table_valo>.<col_valo_ghs>           (table valorisation)
# Raison sociale (RS)   : <table_finess>.<col_rs>               (jointure sur finessgeo)
# Préfixe schéma annuel : <prefix>  (ex: prd_vue_mco)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(readr)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees    <- 2019:2025
seuil_min <- 500   # patients minimum par établissement × an (sensibilité au volume)

# Variable de consommation : "n_sejours" | "valorisation_ghs" | "n_journees" | "n_actes"
# La fiche propose 4 options — choisir selon l'objectif d'analyse
variable_conso <- "n_sejours"

# Inclusion des séances CMD 28 ?
# → Recommandé : exclure (gonfle artificiellement la consommation des patients
#   en chimio/dialyse/radiothérapie)
inclure_cmd28 <- FALSE

# ==============================================================================
# PHASE 1 — Extraction de la distribution patient × consommation
# ==============================================================================

distribution <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))
  # <TODO: si valorisation_ghs choisi, ajouter tbl_valo (table de valorisation)>
  # tbl_valo <- tbl(conn, I(paste0("<prefix>_", an, ".<table_valo>")))

  tbl_sejours %>%
    filter(if (!inclure_cmd28) <col_cmd> != "28" else TRUE) %>%
    transmute(
      ident         = <col_ident>,
      ident_patient = <col_ident_patient>,
      finessgeo     = <col_finessgeo>,
      duree         = <col_duree>
      # <TODO: si variable_conso = "valorisation_ghs", ajouter via inner_join sur valo>
      # <TODO: si variable_conso = "n_actes", ajouter via inner_join sur table actes>
    ) %>%
    group_by(finessgeo, ident_patient) %>%
    summarise(
      n_sejours  = n_distinct(ident),
      n_journees = sum(duree, na.rm = TRUE),
      .groups    = "drop"
    ) %>%
    mutate(annee = an) %>%
    collect()
})

# ==============================================================================
# PHASE 2 — Calcul local du Gini et indicateurs complémentaires
# ==============================================================================

# Formule directe (Cᵢ triés croissants, i ∈ {1..N}) :
#   G = (2 × Σᵢ i×Cᵢ) / (N × Σᵢ Cᵢ) − (N+1)/N
calcul_gini <- function(c_i) {
  c_i <- sort(c_i)
  n   <- length(c_i)
  if (n < 2 || sum(c_i) == 0) return(NA_real_)
  (2 * sum(seq_len(n) * c_i)) / (n * sum(c_i)) - (n + 1) / n
}

# Ratios de Pareto (part détenue par les top X%)
calcul_part_top <- function(c_i, top_pct) {
  c_i  <- sort(c_i, decreasing = TRUE)
  n    <- length(c_i)
  k    <- ceiling(n * top_pct)
  sum(c_i[seq_len(k)]) / sum(c_i)
}

resultat <- distribution %>%
  rename(C_i = !!variable_conso) %>%
  group_by(annee, finessgeo) %>%
  summarise(
    N_patients = n(),
    C_total    = sum(C_i),
    G          = calcul_gini(C_i),
    P20_80     = calcul_part_top(C_i, 0.20),
    P10_90     = calcul_part_top(C_i, 0.10),
    .groups    = "drop"
  ) %>%
  filter(N_patients >= seuil_min)

# Jointure raison sociale
# <TODO: remplacer par la vue/table FINESS de votre base>
ref_finess <- tbl(conn, I("<table_finess>")) %>%
  transmute(finessgeo = <col_finessgeo_ref>, rs = <col_rs>) %>%
  collect()

resultat <- resultat %>%
  left_join(ref_finess, by = "finessgeo")

# ==============================================================================
# PHASE 3 — Courbe de Lorenz (à publier en complément du Gini scalaire)
# ==============================================================================

lorenz <- distribution %>%
  rename(C_i = !!variable_conso) %>%
  group_by(annee, finessgeo) %>%
  arrange(C_i, .by_group = TRUE) %>%
  mutate(
    rang_pct = row_number() / n(),
    cum_pct  = cumsum(C_i) / sum(C_i)
  ) %>%
  ungroup() %>%
  left_join(ref_finess, by = "finessgeo")

# ==============================================================================
# RÉSULTAT
# ==============================================================================

print(resultat)

# ==== VISUALISATION 1 — série temporelle du Gini ====
ggplot2::ggplot(resultat, aes(x = annee, y = G, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    title    = "Coefficient de Gini de la consommation hospitalière",
    subtitle = paste("Variable :", variable_conso, "— par patient chaîné NIR"),
    y        = "Gini (0 = égalité, 1 = concentration totale)", x = NULL
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== VISUALISATION 2 — courbes de Lorenz (dernière année) ====
ggplot2::ggplot(
  dplyr::filter(lorenz, annee == max(annees)),
  aes(x = rang_pct, y = cum_pct, color = rs)
) +
  geom_line() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ reorder(rs, rs)) +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title    = paste("Courbes de Lorenz —", max(annees)),
    subtitle = "Diagonale = égalité parfaite ; éloignement = concentration",
    x        = "Part cumulée des patients (triés par consommation croissante)",
    y        = paste("Part cumulée de la consommation (", variable_conso, ")")
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_gini_consommation_hospitaliere.csv")
# readr::write_csv(lorenz,   "indicateur_gini_lorenz_curves.csv")
