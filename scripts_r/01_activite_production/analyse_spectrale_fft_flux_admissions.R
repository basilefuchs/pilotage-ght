# ==============================================================================
# Indicateur : Analyse spectrale (FFT) des flux d'admission
# Source     : custom (Cooley & Tukey 1965 ; Jones 2008 ; ANAP 2015)
# Pattern    : §6 transformée + §7 calcul local — extraction série temporelle
#              journalière puis FFT par établissement (calcul en mémoire)
# Catégorie  : 01_activite_production
# Fiche      : indicateurs_pmsi/01_activite_production/analyse_spectrale_fft_flux_admissions.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_mco — réutilisable en tête des prochains prompts
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# Date entrée           : fixe.date_entree     (résolution journalière requise)
# CMD (2 car)           : substr(ghm2, 1, 2)
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2023:2025          # fenêtre 2-3 ans (fiche §Calcul)
dep              <- "29"                # Finistère
seuil_min_jours  <- 700L                # ≈ 2 ans de données minimum par établissement
seuil_min_quotidien_p5 <- 0.3           # remplace x(t) si < P5 * 0.3 (fermeture)
periodes_cibles  <- c(R7 = 7, R14 = 14, R30 = 30, R91 = 91, R365 = 365)
# Bande passante pour intégration autour d'une fréquence cible (en bins FFT)
bande_bins       <- 1L
# Fenêtrage : Hann (alternative : Hamming)
fenetre_type     <- "hann"

# ==== EXTRACTION — comptage journalier par finessgeo ====
journalier <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",             # erreurs de groupage
      substr(ghm2, 1, 2) != "28",             # CMD 28 séances — bruite la cyclicité
      substr(finess, 1, 2) == dep,
      !is.na(date_entree)
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(finessgeo = finessgeodp, ident, date_entree, annee = an) %>%
    group_by(annee, finessgeo, date_entree) %>%
    summarise(N = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# ==== PRÉTRAITEMENT — grille journalière complète + interpolation fermetures ====
date_min <- as.Date(paste0(min(annees), "-01-01"))
date_max <- as.Date(paste0(max(annees), "-12-31"))
grille   <- tibble(date_entree = seq(date_min, date_max, by = "day"))

prepare_serie <- function(df_etab) {
  s <- grille %>%
    left_join(df_etab %>% select(date_entree, N), by = "date_entree") %>%
    mutate(
      N        = if_else(is.na(N), 0L, N),
      dow      = as.integer(format(date_entree, "%u"))   # 1=lundi
    )

  # Détection fermetures : x(t) < P5 * seuil_min_quotidien_p5 → médiane par jour de semaine
  p5 <- quantile(s$N[s$N > 0], probs = 0.05, na.rm = TRUE)
  med_dow <- s %>%
    filter(N > 0) %>%
    group_by(dow) %>%
    summarise(med = median(N), .groups = "drop")

  s <- s %>%
    left_join(med_dow, by = "dow") %>%
    mutate(
      x_brut = N,
      x      = if_else(N < p5 * seuil_min_quotidien_p5, med, as.numeric(N))
    )

  s$x
}

fenetre_hann <- function(N) {
  0.5 * (1 - cos(2 * pi * (0:(N - 1)) / (N - 1)))
}

calcul_spectre <- function(x) {
  N <- length(x)

  # Détrending linéaire (fiche §Calcul prétraitement 2)
  t <- seq_len(N)
  fit <- lm(x ~ t)
  x_dt <- as.numeric(residuals(fit))

  # Fenêtrage Hann
  w <- if (fenetre_type == "hann") fenetre_hann(N) else rep(1, N)
  x_w <- x_dt * w

  # FFT et PSD normalisée (one-sided)
  X   <- stats::fft(x_w)
  k   <- 0:(floor(N / 2))
  PSD <- (Mod(X[k + 1])^2) / (N * sum(w^2) / N)
  freq <- k / N    # cycles par jour

  list(N = N, freq = freq, PSD = PSD, X = X, k = k)
}

puissance_bande <- function(spec, periode, bande = bande_bins) {
  # Index FFT le plus proche de la fréquence cible 1/période
  N      <- spec$N
  k_cibl <- round(N / periode)
  k_min  <- max(1L, k_cibl - bande)              # exclure DC
  k_max  <- min(length(spec$PSD) - 1L, k_cibl + bande)
  sum(spec$PSD[(k_min + 1L):(k_max + 1L)])
}

resume_spectral <- function(x, fg) {
  spec <- calcul_spectre(x)
  P_tot <- sum(spec$PSD[-1])                       # exclure DC

  # Ratios par cycle cible
  ratios <- purrr::map_dbl(periodes_cibles, function(p) {
    puissance_bande(spec, p) / P_tot
  })
  names(ratios) <- names(periodes_cibles)

  # Indice de Périodicité Dominante : pic / moyenne (hors DC)
  PSD_no_dc <- spec$PSD[-1]
  IPD       <- max(PSD_no_dc) / mean(PSD_no_dc)

  # Fréquence dominante f* et période T*
  k_star    <- which.max(PSD_no_dc)                # index dans PSD_no_dc
  f_star    <- spec$freq[k_star + 1L]              # +1 car DC exclu
  T_star    <- if (f_star > 0) 1 / f_star else NA_real_

  # Phase du cycle dominant (en jours de la semaine si T*≈7)
  phi_star  <- Arg(spec$X[k_star + 1L])
  jour_pic  <- ((phi_star / (2 * pi)) %% 1) * T_star

  # Bandes BF/HF (fiche §Calcul indicateurs synthétiques)
  BF <- sum(spec$PSD[which(spec$freq < 1 / 30 & spec$freq > 0)])
  HF <- sum(spec$PSD[which(spec$freq > 1 / 7)])

  tibble(
    finessgeo  = fg,
    N_jours    = spec$N,
    !!!as.list(ratios),
    IPD        = IPD,
    f_star     = f_star,
    T_star     = T_star,
    jour_pic   = jour_pic,
    BF         = BF,
    HF         = HF,
    BF_sur_HF  = if_else(HF > 0, BF / HF, NA_real_)
  )
}

# ==== CALCUL — un spectre par établissement ====
resultat <- journalier %>%
  group_by(finessgeo) %>%
  group_split() %>%
  purrr::map_dfr(function(df_etab) {
    fg <- unique(df_etab$finessgeo)
    if (nrow(df_etab) < seuil_min_jours) return(tibble())
    x  <- prepare_serie(df_etab)
    resume_spectral(x, fg)
  }) %>%
  mutate(rs = finessgeo)   # <TODO>: enrichir avec libellé RS si table dispo

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — densité spectrale de puissance par établissement ====
# Indicateur a-temporel (un spectre par établissement sur la fenêtre fixe).
# La viz timeseries du squelette est remplacée par le PSD vs fréquence.
psd_long <- journalier %>%
  group_by(finessgeo) %>%
  group_split() %>%
  purrr::map_dfr(function(df_etab) {
    fg <- unique(df_etab$finessgeo)
    if (nrow(df_etab) < seuil_min_jours) return(tibble())
    x    <- prepare_serie(df_etab)
    spec <- calcul_spectre(x)
    tibble(
      finessgeo = fg,
      rs        = fg,
      freq      = spec$freq[-1],
      periode   = 1 / spec$freq[-1],
      PSD       = spec$PSD[-1]
    )
  })

ggplot2::ggplot(psd_long %>% filter(periode <= 400, periode >= 2),
                aes(x = periode, y = PSD, color = rs)) +
  geom_line() +
  geom_vline(xintercept = c(7, 14, 30, 91, 365),
             linetype = "dashed", alpha = 0.4) +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_log10(breaks = c(2, 7, 14, 30, 91, 365)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Densité spectrale des admissions journalières — par établissement",
    subtitle = paste0("Fenêtre ", min(annees), "-", max(annees),
                      " ; détrending linéaire + fenêtre Hann"),
    x = "Période (jours, échelle log)",
    y = "PSD",
    caption = "Lignes verticales : 7j, 14j, 30j, 91j, 365j"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "analyse_spectrale_fft_flux_admissions.csv")
