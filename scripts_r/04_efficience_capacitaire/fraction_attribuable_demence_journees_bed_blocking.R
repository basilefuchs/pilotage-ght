# ==============================================================================
# Indicateur : Fraction attribuable de la démence dans les journées de bed-blocking
# Source     : custom — Aaltonen 2020 (JAMDA, DOI 10.1016/j.jamda.2020.11.030) ;
#              FAP Levin/Miettinen (Khosravi 2021, DOI 10.1016/j.gloepi.2021.100062)
# Pattern    : §1 taux / ratio attribuable (calcul local Levin)
# Catégorie  : 04_efficience_capacitaire
# Fiche      : indicateurs_pmsi/04_efficience_capacitaire/fraction_attribuable_demence_journees_bed_blocking.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/portail_atih_mco.md) ====
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# Âge (années)          : fixe.age
# Sexe                  : fixe.sexe
# GHM (6 car), CMD      : fixe.ghm2 / substr(ghm2,1,2)
# Mode de sortie        : fixe.modesortie  (6 mutation, 7 transfert)
# Destination           : fixe.destination (précise le mode de sortie ; SSR = "2")
# Journées > borne haute: fixe.nbexh  (nb journées au-delà de la borne extrême haute)
# DAS (CIM-10)          : diag.diag
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Raison sociale (RS)   : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# Comorbidités          : helpers_r/charlson_quan.R
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

source("helpers_r/charlson_quan.R")

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees       <- 2016:2025
dep          <- "29"                 # Finistère (filtre FINESS géographique)
age_min      <- 70                   # cohérence littérature gériatrique (Aaltonen : >=70)
modes_aval   <- c("6", "7")          # mutation / transfert (attente d'aval)
dest_ssr     <- "2"                  # destination SSR — code à confirmer (notice ATIH)
seuil_min    <- 30                   # séjours minimum par maille (robustesse taux)

# Codes CIM-10 (sans point, format PMSI)
codes_demence <- c("F00", "F01", "F02", "F03", "G30")   # match sur 3 car.
code_z751     <- "Z751"               # attente d'admission en structure adaptée

# ==== EXTRACTION — séjours à risque d'aval, niveau séjour ====
sejours <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  # Flag démence (≥ 1 DAS parmi F00-F03 / G30)
  flag_dem <- tbl_diag %>%
    filter(substr(diag, 1, 3) %in% codes_demence) %>%
    distinct(ident) %>%
    mutate(dem = 1L)

  # Flag attente de structure (Z75.1)
  flag_z751 <- tbl_diag %>%
    filter(diag == code_z751) %>%
    distinct(ident) %>%
    mutate(z751 = 1L)

  # Score de Charlson (helper partagé) — pour l'ajustement optionnel
  charlson <- compute_charlson_quan(tbl_diag)

  tbl_fixe %>%
    filter(
      age >= age_min,
      substr(ghm2, 1, 2) != "90",                 # exclure erreurs de groupage
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(flag_dem,  by = "ident") %>%
    left_join(flag_z751, by = "ident") %>%
    left_join(charlson,  by = "ident") %>%
    mutate(
      dem      = coalesce(dem, 0L),
      z751     = coalesce(z751, 0L),
      charlson = coalesce(charlson, 0L),
      nbexh    = coalesce(nbexh, 0L)
    ) %>%
    # Population à risque d'aval : transfert SSR OU attente de structure codée
    filter((modesortie %in% modes_aval & destination == dest_ssr) | z751 == 1L) %>%
    transmute(
      annee    = an,
      finessgeo = finessgeodp,
      ident,
      age, sexe, charlson,
      dem,
      bb_jours = nbexh,                            # journées de bed-blocking (proxy)
      bb       = if_else(nbexh > 0 | z751 == 1L, 1L, 0L)
    ) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE — FAP de Levin (brute) ====
# FAP = p·(RR − 1) / (1 + p·(RR − 1))
#   p  = part de séjours déments parmi les éligibles
#   RR = ratio des journées de bed-blocking déments / non déments
# Journées attribuables = FAP × total des journées bloquées
calcul_fap <- function(df) {
  df %>%
    group_by(annee, finessgeo) %>%
    summarise(
      N_total   = n_distinct(ident),
      N_dem     = sum(dem),
      N_non     = N_total - N_dem,
      J_total   = sum(bb_jours),
      J_dem     = sum(bb_jours[dem == 1L]),
      J_non     = J_total - J_dem,
      .groups   = "drop"
    ) %>%
    mutate(
      taux_j_dem = if_else(N_dem > 0, J_dem / N_dem, NA_real_),
      taux_j_non = if_else(N_non > 0, J_non / N_non, NA_real_),
      RR_journees = taux_j_dem / taux_j_non,
      p           = N_dem / N_total,
      FAP         = (p * (RR_journees - 1)) / (1 + p * (RR_journees - 1)),
      J_attribuables = FAP * J_total
    )
}

resultat <- calcul_fap(sejours) %>%
  filter(N_total >= seuil_min)

# Jointure raison sociale (libellé établissement)
ref_rs <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  transmute(annee, finessgeo, rs) %>%
  collect()

resultat <- resultat %>%
  left_join(ref_rs, by = c("annee", "finessgeo")) %>%
  mutate(rs = coalesce(rs, finessgeo))

# ==== (OPTIONNEL) FAP ajustée — estimateur de Miettinen ====
# RR ajusté sur âge, sexe, Charlson (modèle de Poisson robuste sur l'issue bb),
# puis FAP = p_cas·(RR_aj − 1)/RR_aj où p_cas = part de déments parmi les cas bloqués.
# Décommenter pour l'exécuter (calcul local, plus lourd) :
#
# fap_ajustee <- function(df) {
#   fit <- glm(bb ~ dem + age + factor(sexe) + charlson,
#              family = poisson(link = "log"), data = df)
#   rr_aj  <- exp(coef(fit)[["dem"]])
#   p_cas  <- with(df, sum(dem == 1L & bb == 1L) / sum(bb == 1L))
#   p_cas * (rr_aj - 1) / rr_aj
# }
# fap_ajustee(sejours)

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — série temporelle de la FAP par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = FAP, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Fraction attribuable de la démence dans les journées de bed-blocking",
    subtitle = "FAP de Levin (brute) — part des journées bloquées imputable au profil démence",
    x = "Année", y = "FAP (0 = aucun rôle, 1 = totalité)",
    caption  = paste0("Séjours ≥ ", age_min, " ans en attente d'aval ; seuil ", seuil_min, " séjours/maille")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "fraction_attribuable_demence_journees_bed_blocking.csv")
