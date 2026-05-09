# ==============================================================================
# Indicateur : Indice de Pareto α — épaisseur de la queue de distribution
#              du nombre de séjours par patient
# Source     : Pareto 1896 ; Hill 1975 ; Clauset, Shalizi & Newman 2009 (custom)
# Pattern    : §4 mesure_diversite (extraction SQL → fit Pareto local)
# Fiche      : indicateurs_pmsi/02_casemix_patientele/indice_pareto_alpha_sejours_patient.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base       : Portail ATIH (prd_vue_mco_AAAA), Teradata via dbplyr
# Connexion  : pRatihque::connection_database()
#
# Séjour (1 ligne)        : fixe.ident
# Patient chaîné          : fixe.anonyme
# GHM (6 car) → CMD       : substr(fixe.ghm2, 1, 2)
# FINESS géo. (DP)        : finessgeo_umdudp.finessgeodp
# Année                   : fixe.annee
# Référentiel établisst.  : prd_vue_nomgen.finessgeo (rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees     <- 2016:2025
dep        <- "29"            # filtre département du GHT (substr finess 1-2)
exclure_cmd28 <- TRUE          # séances → saturent la queue, exclues par défaut
exclure_cmd90 <- TRUE          # erreurs de groupage
x_min_grid <- c(2, 3, 4, 5)    # candidats x_min, sélection par KS (Clauset 2009)
n_tail_min <- 200              # effectif minimum dans la queue pour fit stable
decomp_cmd <- TRUE             # décomposition α par CMD (en plus de α global)

# ==== EXTRACTION : N_i = nb séjours par (patient, finessgeodp[, cmd]) ====
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_fixe   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_ipp    <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_finess <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  base <- tbl_fixe %>%
    transmute(
      ident,
      finess,
      cmd = substr(ghm2, 1, 2)
    ) %>%
    filter(substr(finess, 1, 2) == dep) %>%
    { if (exclure_cmd28) filter(., cmd != "28") else . } %>%
    { if (exclure_cmd90) filter(., cmd != "90") else . } %>%
    inner_join(
      tbl_ipp %>% select(ident, anonyme),
      by = "ident"
    ) %>%
    inner_join(
      tbl_finess %>% select(ident, finessgeodp),
      by = "ident"
    )

  # Comptage global (patient × établissement) — pour α global
  global <- base %>%
    group_by(finessgeodp, anonyme) %>%
    summarise(N_i = n_distinct(ident), .groups = "drop") %>%
    mutate(annee = an, cmd = NA_character_) %>%
    collect()

  if (decomp_cmd) {
    # Comptage (patient × établissement × CMD) — pour α par CMD
    par_cmd <- base %>%
      group_by(finessgeodp, anonyme, cmd) %>%
      summarise(N_i = n_distinct(ident), .groups = "drop") %>%
      mutate(annee = an) %>%
      collect()

    bind_rows(global, par_cmd)
  } else {
    global
  }
})

# ==== CALCUL MÉTHODOLOGIQUE : Hill + sélection x_min Clauset-KS ====

# Hill MLE (1975) : α̂ = 1 + n / Σ log(N_i / x_min) sur la queue
# Erreur standard : (α̂ − 1) / sqrt(n_tail)
hill_alpha <- function(N, x_min) {
  tail <- N[N >= x_min]
  n    <- length(tail)
  if (n < 2) return(c(alpha = NA_real_, se = NA_real_, n_tail = n))
  alpha <- 1 + n / sum(log(tail / x_min))
  se    <- (alpha - 1) / sqrt(n)
  c(alpha = alpha, se = se, n_tail = n)
}

# Distance KS entre CDF empirique et Pareto(α̂, x_min) sur la queue
ks_distance <- function(N, x_min, alpha) {
  tail <- sort(N[N >= x_min])
  if (length(tail) < 2) return(NA_real_)
  emp_cdf  <- seq_along(tail) / length(tail)
  theo_cdf <- 1 - (tail / x_min) ^ (-(alpha - 1))
  max(abs(emp_cdf - theo_cdf))
}

# Sélection x_min par KS minimal (Clauset, Shalizi & Newman 2009)
fit_pareto <- function(N) {
  if (length(N) < n_tail_min) {
    return(tibble(x_min = NA_real_, alpha = NA_real_,
                  se = NA_real_, n_tail = length(N), ks = NA_real_))
  }
  res <- purrr::map_dfr(x_min_grid, function(xm) {
    h  <- hill_alpha(N, xm)
    ks <- ks_distance(N, xm, h["alpha"])
    tibble(x_min = xm, alpha = h["alpha"], se = h["se"],
           n_tail = h["n_tail"], ks = ks)
  })
  res %>% filter(!is.na(ks)) %>% slice_min(ks, n = 1, with_ties = FALSE)
}

# Application : fit α par (annee, finessgeodp[, cmd])
resultat <- distribution %>%
  group_by(annee, finessgeodp, cmd) %>%
  summarise(fit = list(fit_pareto(N_i)),
            n_patients = n(),
            n_sejours_tot = sum(N_i),
            .groups = "drop") %>%
  tidyr::unnest(fit) %>%
  filter(n_tail >= n_tail_min)

# Jointure libellés établissements (référentiel hors schéma annuel)
ref_finess <- purrr::map_dfr(annees, function(an) {
  tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
    filter(annee == an, substr(finessgeo, 1, 2) == dep) %>%
    transmute(annee, finessgeodp = finessgeo, rs) %>%
    collect()
})

resultat <- resultat %>%
  left_join(ref_finess, by = c("annee", "finessgeodp"))

# ==== RÉSULTAT ====
resultat_global <- resultat %>% filter(is.na(cmd))
resultat_cmd    <- resultat %>% filter(!is.na(cmd))

print(resultat_global)

# ==== VISUALISATION : α global par établissement, série temporelle ====
ggplot2::ggplot(resultat_global,
                aes(x = annee, y = alpha, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  geom_hline(yintercept = 2, linetype = "dashed", color = "red") +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(1, 4)) +
  labs(title = "Indice de Pareto α — séjours par patient",
       subtitle = paste0("Seuil α = 2 (variance théorique infinie en dessous)",
                         if (exclure_cmd28) " | hors CMD 28" else ""),
       y = "α (Hill MLE, x_min sélectionné par KS)",
       x = NULL) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_global, "indice_pareto_alpha_global.csv")
# readr::write_csv(resultat_cmd,    "indice_pareto_alpha_par_cmd.csv")
