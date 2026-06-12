# ==============================================================================
# Indicateur : CUSUM de surveillance séquentielle des complications
# Source     : custom (Page 1954 ; Steiner 2000 ; Woodall 2006)
# Pattern    : §5 modèle de surveillance — CUSUM mensuel agrégé +
#              Bernoulli risk-adjusted par séjour
# Catégorie  : 05_qualite_securite
# Fiche      : indicateurs_pmsi/05_qualite_securite/cusum_surveillance_complications.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_mco
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# GHM (6 car)           : fixe.ghm2  → type = substr(ghm2, 3, 1) ; CMD = substr(ghm2,1,2)
# Sortie / décès        : fixe.modesortie ("9" = décès)
# Mode entrée / urgence : fixe.modeentree, fixe.passage_urg
# Âge / sexe            : fixe.age, fixe.sexe
# Année / mois sortie   : fixe.annee, fixe.mois
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Diagnostics           : diag.diag (CIM-10) — DP/DR/DAS confondus
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees             <- 2018:2025
dep                <- "29"        # Finistère
periode_apprentissage_mois <- 24L # μ₀ estimé sur les 24 premiers mois
seuil_h            <- 5.0          # decision interval (ARL₀ ≈ 100-150)
arl_cible          <- 100L         # cible faux positif (information seulement)
delta_cible        <- 1.5          # μ₁ = delta_cible × μ₀ → dégradation +50%
seuil_min_mensuel  <- 30L          # robustesse : min séjours/mois
# Codes CIM-10 identifiant une complication post-opératoire (PSI ATIH simplifié) :
# T80-T88 (complications de soins), Y60-Y84 (incidents médicaux), J95 (post-op resp),
# I97 (post-cardiotomie), N99 (post-uro), K91 (post-digestif), G97 (post-neuro)
# <TODO>: remplacer par la liste PSI ATIH 2024 officielle (scansante.fr)
codes_compl_prefixes <- c("T80", "T81", "T82", "T83", "T84", "T85", "T86", "T87", "T88",
                          "J95", "I97", "N99", "K91", "G97",
                          "Y60", "Y61", "Y62", "Y63", "Y64", "Y65", "Y66",
                          "Y69", "Y70", "Y71", "Y72", "Y73", "Y74", "Y75",
                          "Y76", "Y77", "Y78", "Y79", "Y80", "Y81", "Y82", "Y83", "Y84")

# ==== EXTRACTION — séjours chirurgicaux + flag complication par mois ====
mensuel <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  # Séjours chirurgicaux index (hors séances, erreurs, obstétrique normale)
  fixe_chir <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28",
      substr(ghm2, 1, 2) != "14",
      substr(finess, 1, 2) == dep,
      substr(ghm2, 3, 1) %in% c("C", "Z")
    )

  # Flag complication = ≥1 diag dans liste sur le séjour
  flag_compl <- tbl_diag %>%
    inner_join(fixe_chir %>% select(ident), by = "ident") %>%
    filter(substr(diag, 1, 3) %in% codes_compl_prefixes) %>%
    distinct(ident) %>%
    mutate(complication = 1L)

  sejours <- fixe_chir %>%
    inner_join(tbl_geo  %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(flag_compl,                                 by = "ident")

  # passage_urg absent des vues < 2023 (dico ATIH) : modeentree seul avant
  if (an >= 2023) {
    sejours <- sejours %>%
      mutate(p_urg = coalesce(as.integer(passage_urg), 0L))
  } else {
    sejours <- sejours %>%
      mutate(p_urg = 0L)
  }

  sejours %>%
    transmute(
      ident,
      finessgeo  = finessgeodp,
      annee      = an,
      mois,
      age,
      sexe,
      # urgences = modeentree 8 (domicile) + provenance 5, ou passage_urg ≥ 2023
      mode_urg   = case_when(
        modeentree == "8" & provenance == "5" ~ 1L,
        p_urg == 1L                            ~ 1L,
        TRUE                                   ~ 0L
      ),
      ghm_racine = substr(ghm2, 1, 5),
      compl      = coalesce(complication, 0L)
    ) %>%
    collect()
})

# ==== CALCUL — taux mensuel par établissement ====
taux_mensuel <- mensuel %>%
  group_by(finessgeo, annee, mois) %>%
  summarise(
    n_sejours      = n_distinct(ident),
    n_complic      = sum(compl),
    .groups = "drop"
  ) %>%
  mutate(
    taux  = n_complic / n_sejours,
    t_abs = (annee - min(annees)) * 12L + mois
  ) %>%
  filter(n_sejours >= seuil_min_mensuel) %>%
  arrange(finessgeo, t_abs)

# ==== CALIBRATION μ₀, μ₁, k ====
calibrer <- function(df_etab) {
  appr <- df_etab %>%
    filter(t_abs <= min(t_abs) + periode_apprentissage_mois - 1L)
  mu0 <- weighted.mean(appr$taux, w = appr$n_sejours)
  mu1 <- delta_cible * mu0
  list(mu0 = mu0, mu1 = mu1, k = (mu0 + mu1) / 2)
}

# ==== CUSUM unilatéral S+ et S- ====
cusum_serie <- function(df_etab) {
  cal <- calibrer(df_etab)
  df_etab %>%
    arrange(t_abs) %>%
    mutate(
      mu0   = cal$mu0,
      k     = cal$k,
      x_dev = taux - cal$k
    ) %>%
    mutate(
      S_plus  = purrr::accumulate(x_dev, ~ max(0, .x + .y), .init = 0)[-1],
      S_minus = purrr::accumulate(x_dev, ~ min(0, .x + .y), .init = 0)[-1],
      alerte_plus  = S_plus  >  seuil_h,
      alerte_minus = S_minus < -seuil_h
    )
}

resultat <- taux_mensuel %>%
  group_by(finessgeo) %>%
  group_split() %>%
  purrr::map_dfr(cusum_serie) %>%
  mutate(
    rs   = finessgeo,                  # <TODO>: enrichir avec libellé RS
    date = as.Date(paste0(annee, "-", sprintf("%02d", mois), "-15"))
  )

# ==== RÉSULTAT ====
print(resultat %>% group_by(finessgeo) %>%
        summarise(
          mois_observes = n(),
          mu0           = first(mu0),
          n_alerte_plus = sum(alerte_plus),
          dernier_S_plus = last(S_plus),
          .groups = "drop"
        ))

# ==== VARIANTE RISK-ADJUSTED CUSUM (Steiner 2000, par séjour) ====
# Modèle logistique entraîné sur la période d'apprentissage, prédit p_t
# pour chaque séjour, puis CUSUM Bernoulli pondéré
seuils_an_appr <- min(annees) + (periode_apprentissage_mois - 1L) %/% 12L
appr_data <- mensuel %>%
  mutate(t_abs = (annee - min(annees)) * 12L + mois) %>%
  filter(t_abs <= periode_apprentissage_mois)

modele_risque <- glm(
  compl ~ age + factor(sexe) + mode_urg + factor(ghm_racine),
  data   = appr_data,
  family = binomial()
)

cusum_ra_serie <- function(df_etab) {
  df_etab <- df_etab %>%
    mutate(
      p_hat   = predict(modele_risque, newdata = ., type = "response"),
      p1_hat  = pmin(0.999, delta_cible * p_hat)
    ) %>%
    arrange(annee, mois, ident)
  W <- with(df_etab, log(
    (p1_hat / p_hat)^compl *
    ((1 - p1_hat) / (1 - p_hat))^(1 - compl)
  ))
  df_etab %>%
    mutate(
      W      = W,
      S_plus = purrr::accumulate(W, ~ max(0, .x + .y), .init = 0)[-1],
      alerte = S_plus > seuil_h
    )
}

cusum_ra <- mensuel %>%
  group_by(finessgeo) %>%
  group_split() %>%
  purrr::map_dfr(cusum_ra_serie) %>%
  mutate(
    rs   = finessgeo,
    rang = row_number()
  )

# ==== VISUALISATION — CUSUM agrégé mensuel par établissement ====
ggplot2::ggplot(resultat, aes(x = date, y = S_plus, color = rs)) +
  geom_hline(yintercept = seuil_h,  linetype = "dashed", color = "red") +
  geom_hline(yintercept = -seuil_h, linetype = "dashed", color = "blue") +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  geom_line(aes(y = S_minus), alpha = 0.4) +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "CUSUM mensuel — taux de complications post-opératoires",
    subtitle = paste0("μ₀ par étab estimé sur ", periode_apprentissage_mois,
                      " premiers mois ; μ₁ = ", delta_cible, "×μ₀ ; h = ", seuil_h),
    x = "Date",
    y = "Statistique CUSUM (S⁺ : haut ; S⁻ : bas)",
    caption = paste0("Seuil min : ", seuil_min_mensuel, " séjours/mois ; ",
                     "ARL₀ cible ≈ ", arl_cible, " mois")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "cusum_surveillance_complications.csv")
# readr::write_csv(cusum_ra, "cusum_surveillance_complications_risk_adjusted.csv")
