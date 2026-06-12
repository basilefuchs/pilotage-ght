# ==============================================================================
# Indicateur : Indice de Résilience Post-Perturbation (IRPP)
# Source     : custom — Holling (1973), Pimm (1984), Page (1954, CUSUM)
# Pattern    : §7 comptage_simple (extraction série mensuelle)
#              + calcul local R (CUSUM, baseline, durée de retour, IRPP)
# Fiche      : indicateurs_pmsi/01_activite_production/indice_resilience_post_perturbation.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Séjour (1 ligne)    : prd_vue_mco_<an>.fixe.ident
# FINESS géographique : prd_vue_mco_<an>.finessgeo_umdudp.finessgeodp (jointure ident)
# Date d'entrée       : prd_vue_mco_<an>.fixe.date_entree (jour, AAAAMMJJ)
# CMD (exclusion)     : substr(ghm2, 1, 2) sur prd_vue_mco_<an>.fixe (CMD 28 = séances)
# Référentiel rs      : prd_vue_nomgen.finessgeo.rs (jointure annee + finessgeo)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(lubridate)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
dep              <- "75"            # département à filtrer pour le référentiel rs
fenetre_baseline <- 24              # mois de baseline pré-perturbation
seuil_retour_k   <- 0.5             # |X_t - mu_baseline| < seuil_retour_k * sigma_baseline
duree_retour_min <- 3               # mois consécutifs sous le seuil pour valider t_retour
fenetre_max_post <- 24              # mois max d'observation post-t* avant NA
irpp_max         <- 10              # plafond pour D = 0 (retour immédiat)
# CUSUM
cusum_k          <- 0.5             # sensibilité (en unités de sigma_ref)
cusum_h          <- 5               # seuil de signal (en unités de sigma_ref)

# ==== EXTRACTION : série mensuelle d'admissions par FINESS_GEO ====
serie_mensuelle <- purrr::map_dfr(annees, function(an) {

  tbl_fixe   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_finess <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "28") %>%        # exclure CMD 28 (séances)
    inner_join(
      tbl_finess %>% select(ident, finessgeo = finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      ident,
      finessgeo,
      annee = an,
      mois  = substr(date_entree, 5, 6)
    ) %>%
    group_by(annee, mois, finessgeo) %>%
    summarise(n_sejours = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# ==== RÉFÉRENTIEL RS ====
ref_finessgeo <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(
    substr(finessgeo, 1, 2) == dep,
    annee %in% annees
  ) %>%
  select(annee, finessgeo, rs) %>%
  distinct() %>%
  collect() %>%
  group_by(annee, finessgeo) %>%
  summarise(rs = first(rs), .groups = "drop")

# ==== CONSOLIDATION SÉRIE MENSUELLE ====
serie <- serie_mensuelle %>%
  inner_join(ref_finessgeo, by = c("annee", "finessgeo")) %>%
  mutate(
    date_mois = ymd(paste0(annee, "-", mois, "-01"))
  ) %>%
  arrange(finessgeo, date_mois) %>%
  group_by(finessgeo, rs) %>%
  complete(
    date_mois = seq(min(date_mois), max(date_mois), by = "month"),
    fill = list(n_sejours = 0L)
  ) %>%
  mutate(t = row_number()) %>%
  ungroup()

# ==== CALCUL MÉTHODOLOGIQUE ====

# Détection CUSUM du premier point de rupture (one-sided, baisse d'activité)
detecter_rupture_cusum <- function(x, fenetre_ref, k, h) {
  n <- length(x)
  if (n <= fenetre_ref + 1) return(NA_integer_)

  cusum <- numeric(n)
  t_star <- NA_integer_

  for (t in (fenetre_ref + 1):n) {
    mu_ref    <- mean(x[(t - fenetre_ref):(t - 1)], na.rm = TRUE)
    sigma_ref <- sd(x[(t - fenetre_ref):(t - 1)],   na.rm = TRUE)
    if (is.na(sigma_ref) || sigma_ref == 0) next

    increment   <- (mu_ref - x[t] - k * sigma_ref)
    cusum[t]    <- max(0, cusum[t - 1] + increment)

    if (cusum[t] > h * sigma_ref) {
      t_star <- t
      break
    }
  }
  t_star
}

# Calcul de l'IRPP pour une série mensuelle d'un établissement
calculer_irpp <- function(df_etab) {

  x <- df_etab$n_sejours
  n <- length(x)

  t_star <- detecter_rupture_cusum(x, fenetre_baseline, cusum_k, cusum_h)

  if (is.na(t_star)) {
    return(tibble(
      finessgeo = df_etab$finessgeo[1], rs = df_etab$rs[1],
      t_star = NA, t_retour = NA, mu_baseline = NA, sigma_baseline = NA,
      D = NA, A = NA, ecart_max = NA,
      IRPP = NA, Resistance = NA, Recuperation = NA,
      Rebond_excedent = NA, rebond_detecte = FALSE
    ))
  }

  idx_baseline   <- max(1, t_star - fenetre_baseline):(t_star - 1)
  mu_baseline    <- mean(x[idx_baseline], na.rm = TRUE)
  sigma_baseline <- sd(x[idx_baseline],   na.rm = TRUE)

  ecart      <- (x - mu_baseline) / mu_baseline
  abs_dev    <- abs(x - mu_baseline)
  sous_seuil <- abs_dev < (seuil_retour_k * sigma_baseline)

  # Recherche de duree_retour_min mois consécutifs sous le seuil après t_star
  fin_obs  <- min(n, t_star + fenetre_max_post)
  t_retour <- NA_integer_
  if (fin_obs >= t_star + duree_retour_min) {
    for (t in (t_star + 1):(fin_obs - duree_retour_min + 1)) {
      if (all(sous_seuil[t:(t + duree_retour_min - 1)])) {
        t_retour <- t
        break
      }
    }
  }

  if (is.na(t_retour)) {
    return(tibble(
      finessgeo = df_etab$finessgeo[1], rs = df_etab$rs[1],
      t_star = t_star, t_retour = NA,
      mu_baseline = mu_baseline, sigma_baseline = sigma_baseline,
      D = NA, A = NA, ecart_max = max(abs(ecart[t_star:fin_obs]), na.rm = TRUE),
      IRPP = NA_real_, Resistance = NA_real_, Recuperation = NA_real_,
      Rebond_excedent = NA_real_, rebond_detecte = FALSE
    ))
  }

  D         <- t_retour - t_star
  ecart_pert <- ecart[t_star:(t_retour - 1)]
  A         <- sum(abs(ecart_pert), na.rm = TRUE)
  ecart_max <- max(abs(ecart_pert), na.rm = TRUE)

  IRPP <- if (D == 0 || A == 0) irpp_max else min(1 / (D * A), irpp_max)

  Resistance   <- if (ecart_max == 0) NA_real_ else 1 / ecart_max
  Recuperation <- if (D == 0) NA_real_ else 1 / D

  # Rebond tardif : >= 2 mois consécutifs avec X_t > mu_baseline + 1.5 * sigma_baseline
  fin_rebond     <- min(n, t_retour + fenetre_max_post)
  seuil_rebond   <- mu_baseline + 1.5 * sigma_baseline
  rebond_logique <- x[t_retour:fin_rebond] > seuil_rebond
  rebond_detecte <- any(
    rebond_logique[-length(rebond_logique)] & rebond_logique[-1],
    na.rm = TRUE
  )
  Rebond_excedent <- if (rebond_detecte) {
    sum(ecart[t_retour:fin_rebond][rebond_logique], na.rm = TRUE)
  } else NA_real_

  tibble(
    finessgeo = df_etab$finessgeo[1], rs = df_etab$rs[1],
    t_star = t_star, t_retour = t_retour,
    mu_baseline = mu_baseline, sigma_baseline = sigma_baseline,
    D = D, A = A, ecart_max = ecart_max,
    IRPP = IRPP, Resistance = Resistance, Recuperation = Recuperation,
    Rebond_excedent = Rebond_excedent, rebond_detecte = rebond_detecte
  )
}

resultat <- serie %>%
  group_by(finessgeo, rs) %>%
  group_split() %>%
  purrr::map_dfr(calculer_irpp) %>%
  arrange(desc(IRPP))

# Récupération des dates calendaires t_star / t_retour pour interprétation
dates_serie <- serie %>%
  group_by(finessgeo) %>%
  summarise(date_min = min(date_mois), .groups = "drop")

resultat <- resultat %>%
  left_join(dates_serie, by = "finessgeo") %>%
  mutate(
    date_t_star   = date_min %m+% months(t_star - 1),
    date_t_retour = date_min %m+% months(t_retour - 1)
  ) %>%
  select(-date_min)

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION : trace mensuelle annotée ====
serie_viz <- serie %>%
  inner_join(
    resultat %>% select(finessgeo, mu_baseline, sigma_baseline,
                        date_t_star, date_t_retour),
    by = "finessgeo"
  )

ggplot2::ggplot(serie_viz, aes(x = date_mois, y = n_sejours)) +
  geom_line(color = "grey40") +
  geom_point(size = 0.8, color = "grey20") +
  geom_hline(aes(yintercept = mu_baseline),
             linetype = "dashed", color = "steelblue") +
  geom_ribbon(aes(ymin = mu_baseline - 0.5 * sigma_baseline,
                  ymax = mu_baseline + 0.5 * sigma_baseline),
              fill = "steelblue", alpha = 0.15) +
  geom_vline(aes(xintercept = date_t_star),
             color = "firebrick", linetype = "dotted") +
  geom_vline(aes(xintercept = date_t_retour),
             color = "darkgreen", linetype = "dotted") +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_y_continuous(limits = c(0, NA)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = "Indice de Résilience Post-Perturbation",
    subtitle = "Pointillé rouge : t* (rupture CUSUM) — Pointillé vert : t_retour — Bandeau bleu : baseline ± 0.5·σ",
    x = "Mois", y = "Admissions / mois (CMD 28 exclue)"
  )

# Comparaison synthétique inter-établissements
ggplot2::ggplot(
  resultat %>% filter(!is.na(IRPP)),
  aes(x = reorder(rs, IRPP), y = IRPP)
) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = 0.20, linetype = "dashed", color = "darkgreen") +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "firebrick") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "IRPP par établissement",
    subtitle = "Vert : seuil résilience forte (0.20) — Rouge : seuil résilience faible (0.05)",
    x = NULL, y = "IRPP"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_irpp.csv")
