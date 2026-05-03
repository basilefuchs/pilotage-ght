# ==============================================================================
# Indicateur : EWMA de la mortalité chirurgicale mensuelle (risk-adjusted)
# Source     : Roberts 1959 ; Grigg & Spiegelhalter 2007 ; Cook 2011
# Pattern    : §2 ratio_standardisé séquentiel + post-traitement carte EWMA
# Fiche      : indicateurs_pmsi/05_qualite_securite/ewma_mortalite_chirurgicale_mensuelle.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil      : profils/portail_atih_mco.md
# Base        : Portail ATIH (Teradata via dbplyr)
# Schéma      : prd_vue_mco_AAAA
#
# Séjour (1 ligne)        : fixe.ident
# FINESS géographique     : finessgeo_umdudp.finessgeodp
# GHM (6 car)             : fixe.ghm2 → racine = substr(ghm2,1,5), CMD = substr(ghm2,1,2)
# Type GHM (C/M/K/Z)      : substr(fixe.ghm2, 3, 1)   # 3e caractère = "C" → chir
# Sévérité GHM            : substr(fixe.ghm2, 5, 1)
# Sexe / Âge              : fixe.sexe / fixe.age
# Mode entrée / sortie    : fixe.modeentree / fixe.modesortie    (modesortie="9" → décès)
# Mois / Année sortie     : fixe.mois / fixe.annee
# Diagnostics (DP+DAS)    : diag.diag                           (Charlson via Quan 2005)
# Référentiel FINESS      : prd_vue_nomgen.finessgeo            (clé = annee, finessgeo)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2016:2025
dep      <- "29"

# --- EWMA ---
lambda   <- 0.2     # facteur de lissage : 0.1 mémoire longue, 0.4 réactif
L        <- 2.7     # multiplicateur bornes : 2.7 → ARL0 ≈ 250 ; 3.0 plus conservateur
agg_temp <- "mois"  # "mois" ou "trimestre"

# --- Périmètre ---
exclure_entree_urgence <- TRUE     # modeentree == "8" → entrée par urgences
seuil_volume_mois      <- 5        # mois avec n_t < seuil → carte non publiée

# --- Stratification ---
# Niveau d'agrégation : finessgeodp × GHM-racine
# (modifier var_strat si besoin, ex. c("finessgeodp") seul, ou +CMD)
var_strat <- c("finessgeodp", "ghm_racine")

# ==== EXTRACTION ====
# Pour chaque année : cohorte chirurgicale + décès + covariables d'ajustement.

extraire_cohorte <- function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  # 1. Cohorte chirurgicale = GHM type "C" (3e caractère)
  cohorte <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",         # exclure erreurs de groupage
      substr(ghm2, 1, 2) != "28",         # exclure CMD 28 (séances)
      substr(ghm2, 3, 1) == "C",          # GHM chirurgical
      substr(finess, 1, 2) == dep,
      duree >= 1L
    )

  if (exclure_entree_urgence) {
    cohorte <- cohorte %>% filter(modeentree != "8")
  }

  # 2. Charlson via DAS+DP — approximation Quan 2005 (placeholder)
  #    <TODO Charlson : intégrer le mapping CIM-10 → poids Quan 2005.
  #     Ici on calcule un proxy = nb de DAS distincts plafonné à 5.>
  charlson <- tbl_diag %>%
    group_by(ident) %>%
    summarise(
      charlson = pmin(n_distinct(diag), 5L),   # proxy à remplacer
      .groups = "drop"
    )

  # 3. Cohorte enrichie
  cohorte %>%
    transmute(
      ident,
      annee_sortie = annee,
      mois_sortie  = mois,
      age, sexe,
      modeentree,
      ghm2,
      ghm_racine = substr(ghm2, 1, 5),
      cmd        = substr(ghm2, 1, 2),
      severite   = substr(ghm2, 5, 1),
      deces      = if_else(modesortie == "9", 1L, 0L)
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    left_join(charlson, by = "ident") %>%
    mutate(charlson = coalesce(charlson, 0L)) %>%
    collect()
}

cohorte <- purrr::map_dfr(annees, extraire_cohorte)

# ==== MODÈLE DE RISQUE (logistique) ====
# Eₜ = Σ pᵢ , Vₜ = Σ pᵢ(1-pᵢ) issus du modèle logistique global pré-entraîné.
# Recalibration annuelle recommandée — ici un seul modèle sur tout l'historique.

cohorte <- cohorte %>%
  mutate(
    sexe       = factor(sexe),
    modeentree = factor(modeentree),
    severite   = factor(severite),
    cmd        = factor(cmd)
  )

modele_risque <- glm(
  deces ~ age + sexe + charlson + modeentree + cmd + severite,
  data   = cohorte,
  family = binomial("logit")
)

cohorte <- cohorte %>%
  mutate(p_hat = predict(modele_risque, newdata = ., type = "response"))

# Diagnostic AUC (Hosmer-Lemeshow + C-statistic — à compléter selon besoin)
auc_global <- with(cohorte, {
  rk <- rank(p_hat)
  n1 <- sum(deces == 1); n0 <- sum(deces == 0)
  (sum(rk[deces == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
})
message(sprintf("C-statistic global : %.3f (cible >= 0.75)", auc_global))

# ==== AGRÉGATION MENSUELLE O / E / V ====
oev_mensuel <- cohorte %>%
  group_by(across(all_of(var_strat)), annee_sortie, mois_sortie) %>%
  summarise(
    n_t = n(),
    O_t = sum(deces),
    E_t = sum(p_hat),
    V_t = sum(p_hat * (1 - p_hat)),
    .groups = "drop"
  ) %>%
  arrange(across(all_of(var_strat)), annee_sortie, mois_sortie) %>%
  mutate(
    date_t = as.Date(sprintf("%04d-%02d-01", annee_sortie, mois_sortie)),
    u_t    = if_else(V_t > 0, (O_t - E_t) / sqrt(V_t), NA_real_)
  )

# ==== CALCUL EWMA ====
# z_t = lambda * u_t + (1 - lambda) * z_{t-1}
# Bornes asymptotiques : sigma_z(t) = sqrt(lambda/(2-lambda)) * sqrt(1-(1-lambda)^(2t))

ewma_groupe <- function(df, lambda, L, seuil_volume) {
  df <- df %>% filter(n_t >= seuil_volume)
  if (nrow(df) == 0) return(df %>% mutate(z_t = NA_real_, ucl = NA_real_, lcl = NA_real_, alerte = NA_character_))

  z <- numeric(nrow(df)); z[1] <- lambda * df$u_t[1]
  if (nrow(df) > 1) {
    for (i in 2:nrow(df)) {
      z[i] <- lambda * df$u_t[i] + (1 - lambda) * z[i - 1]
    }
  }
  t_idx   <- seq_len(nrow(df))
  sigma_z <- sqrt(lambda / (2 - lambda)) * sqrt(1 - (1 - lambda)^(2 * t_idx))

  df %>%
    mutate(
      z_t    = z,
      ucl    = +L * sigma_z,
      lcl    = -L * sigma_z,
      alerte = case_when(
        z_t > ucl ~ "haut",
        z_t < lcl ~ "bas",
        TRUE      ~ "ok"
      )
    )
}

resultat <- oev_mensuel %>%
  group_by(across(all_of(var_strat))) %>%
  group_modify(~ ewma_groupe(.x, lambda, L, seuil_volume_mois)) %>%
  ungroup()

# ==== JOINTURE LIBELLÉS FINESS ====
ref_finess <- purrr::map_dfr(annees, function(an) {
  tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
    filter(annee == an) %>%
    transmute(annee, finessgeodp = finessgeo, rs) %>%
    collect()
})

resultat <- resultat %>%
  left_join(ref_finess, by = c("annee_sortie" = "annee", "finessgeodp"))

# ==== RÉSULTAT ====
print(resultat)

# Synthèse alertes courantes
resultat %>%
  group_by(across(all_of(var_strat))) %>%
  slice_tail(n = 1) %>%
  filter(alerte != "ok") %>%
  print()

# ==== VISUALISATION ====
# Carte EWMA par établissement, facetté GHM racine (top volume)
top_racines <- resultat %>%
  count(ghm_racine, wt = n_t, sort = TRUE) %>%
  slice_head(n = 6) %>%
  pull(ghm_racine)

resultat %>%
  filter(ghm_racine %in% top_racines) %>%
  ggplot(aes(x = date_t, y = z_t, color = rs)) +
  geom_ribbon(aes(ymin = lcl, ymax = ucl), fill = "grey85", color = NA, alpha = 0.4) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_smooth(se = FALSE, method = "loess", span = 0.4) +
  geom_point(size = 0.8) +
  facet_wrap(~ reorder(rs, rs) + ghm_racine, scales = "free_y") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "EWMA mortalité chirurgicale mensuelle",
    subtitle = sprintf("lambda = %.2f, L = %.1f", lambda, L),
    x = NULL, y = "z_t (EWMA standardisé)"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "ewma_mortalite_chirurgicale_mensuelle.csv")
