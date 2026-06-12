# ==============================================================================
# Indicateur : Taux de croissance de l'activité trimestrielle par CMD (TCAT/TCAM)
# Source     : INSEE (méthodologie taux de croissance) / ATIH (CMD)
# Pattern    : §7 — comptage_simple + dérivation locale (TCAT, TCAM, accélération)
# Fiche      : indicateurs_pmsi/01_activite_production/taux_croissance_activite_trimestrielle.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car)                   : fixe.ghm2
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Date entrée                   : fixe.date_entree
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# Référentiel RS                : prd_vue_nomgen.finessgeo (annuel, jointure (annee, finessgeo))
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(lubridate)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees       <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
dep          <- "29"        # filtre département (FINESS commençant par)
seuil_volume <- 30          # séjours minimum / trimestre pour TCAT interprétable
K_tcam       <- 3           # horizon en années du TCAM
annee_base   <- 2019        # référence pour l'indice base 100 (pré-COVID)

# ==== EXTRACTION : comptage par (finessgeodp, cmd, trimestre, annee) ====
comptages <- purrr::map_dfr(annees, function(an) {

  tbl_fixe   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_refrs  <- tbl(conn, I(paste0("prd_vue_nomgen.finessgeo")))

  tbl_fixe %>%
    filter(
      substr(finess, 1, 2) == dep,
      substr(ghm2, 1, 2) != "90",   # exclusion erreurs de groupage
      substr(ghm2, 1, 2) != "28"    # exclusion séances (CMD 28)
    ) %>%
    inner_join(
      tbl_geodp %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    inner_join(
      tbl_refrs %>% filter(annee == an) %>% select(finessgeo, rs),
      by = c("finessgeodp" = "finessgeo")
    ) %>%
    transmute(
      ident,
      finessgeodp,
      rs,
      cmd       = substr(ghm2, 1, 2),
      mois_e    = month(date_entree),
      trimestre = case_when(
        mois_e <= 3  ~ "T1",
        mois_e <= 6  ~ "T2",
        mois_e <= 9  ~ "T3",
        TRUE         ~ "T4"
      ),
      annee = an
    ) %>%
    group_by(finessgeodp, rs, cmd, trimestre, annee) %>%
    summarise(N = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE : TCAT + accélération + indice base 100 ====
# Compléter les cellules absentes par 0 pour ne pas perdre les chutes à zéro
grille <- comptages %>%
  distinct(finessgeodp, rs, cmd, trimestre) %>%
  tidyr::crossing(annee = annees) %>%
  left_join(comptages, by = c("finessgeodp", "rs", "cmd", "trimestre", "annee")) %>%
  mutate(N = coalesce(N, 0L))

resultat <- grille %>%
  arrange(finessgeodp, cmd, trimestre, annee) %>%
  group_by(finessgeodp, rs, cmd, trimestre) %>%
  mutate(
    N_lag1   = lag(N, 1L),
    N_lagK   = lag(N, K_tcam),
    N_base   = N[annee == annee_base][1],
    TCAT     = if_else(!is.na(N_lag1) & N_lag1 >= seuil_volume,
                       (N - N_lag1) / N_lag1, NA_real_),
    flag     = case_when(
      is.na(N_lag1)              ~ "premiere_annee",
      N_lag1 == 0                ~ "ex_nihilo",
      N_lag1 < seuil_volume      ~ "volume_insuffisant",
      TRUE                       ~ "ok"
    ),
    Accel    = TCAT - lag(TCAT, 1L),
    TCAM     = if_else(!is.na(N_lagK) & N_lagK >= seuil_volume,
                       (N / N_lagK)^(1 / K_tcam) - 1, NA_real_),
    IC_b100  = if_else(!is.na(N_base) & N_base > 0, N / N_base * 100, NA_real_)
  ) %>%
  ungroup()

# Contribution de chaque CMD à la croissance globale de l'établissement
contrib <- grille %>%
  group_by(finessgeodp, rs, trimestre, annee) %>%
  mutate(N_total_etab = sum(N)) %>%
  ungroup() %>%
  arrange(finessgeodp, cmd, trimestre, annee) %>%
  group_by(finessgeodp, rs, cmd, trimestre) %>%
  mutate(
    N_lag1_total = lag(N_total_etab, 1L),
    Contrib      = if_else(!is.na(N_lag1_total) & N_lag1_total > 0,
                           (N - lag(N, 1L)) / N_lag1_total, NA_real_)
  ) %>%
  ungroup() %>%
  select(finessgeodp, cmd, trimestre, annee, Contrib)

resultat <- resultat %>%
  left_join(contrib, by = c("finessgeodp", "cmd", "trimestre", "annee"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION : TCAT trimestriel par CMD pour les 6 plus gros volumes ====
top_cmd <- resultat %>%
  group_by(cmd) %>%
  summarise(N_tot = sum(N, na.rm = TRUE), .groups = "drop") %>%
  slice_max(N_tot, n = 6) %>%
  pull(cmd)

resultat %>%
  filter(cmd %in% top_cmd, !is.na(TCAT)) %>%
  mutate(periode = annee + (as.integer(substr(trimestre, 2, 2)) - 1) / 4) %>%
  ggplot(aes(x = periode, y = TCAT, color = rs)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(cmd, cmd), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  labs(title = "TCAT trimestriel par CMD", x = NULL, y = "TCAT (n vs n-1)")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "tcat_trimestriel_cmd.csv")

# ==== TODO ====
# - Benchmark vs TCAT national : nécessite import ScanSanté (CSV externe), à
#   joindre par (cmd, trimestre, annee) puis Ecart_benchmark = TCAT - TCAT_nat
# - Si la fenêtre couvre 2020-2021, envisager exclusion explicite de ces années
#   du TCAM pour neutraliser le creux COVID
