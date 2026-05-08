# ==============================================================================
# Indicateur : Taux ajusté de mortalité intra-hospitalière post-AVC ischémique (I63)
# Source     : OCDE HCQO Acute Care 2025
# Pattern    : §1 — taux ajusté (standardisation indirecte par modèle logistique)
# Fiche      : indicateurs_pmsi/05_qualite_securite/taux_mortalite_intra_hosp_avc_ischemique_ajustee.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base : portail_atih_mco
# Séjour (1 ligne)        : prd_vue_mco_AAAA.fixe.ident
# DP                      : fixe.dp
# Âge / Sexe              : fixe.age / fixe.sexe
# Mode entrée / sortie    : fixe.modeentree / fixe.modesortie
# GHM                     : fixe.ghm2
# Diag (DP+DR+DA)         : diag.diag
# FINESS géo (DP)         : finessgeo_umdudp.finessgeodp
# RS établissement        : prd_vue_nomgen.finessgeo.rs
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

source("helpers_r/charlson_quan.R")

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees    <- 2016:2025
dep       <- "29"
seuil_min <- 30L

prefix_avc_isch <- "I63"

# ==== EXTRACTION ====
cohorte_all <- purrr::map_dfr(annees, function(an) {

  tbl_fixe       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_diag       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))
  tbl_finessgeo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Cohorte index : DP I63, hors transferts entrants, hors erreurs groupage
  cohorte <- tbl_fixe %>%
    filter(
      substr(dp, 1, 3) == prefix_avc_isch,
      modeentree != "7",
      substr(ghm2, 1, 2) != "90"
    ) %>%
    select(ident, age, sexe, modesortie)

  # Charlson Quan via helper (sur l'ensemble DP+DR+DA agrégé dans tbl_diag)
  charlson <- compute_charlson_quan(tbl_diag)

  cohorte %>%
    left_join(charlson, by = "ident") %>%
    inner_join(tbl_finessgeo %>% select(ident, finessgeodp), by = "ident") %>%
    transmute(
      ident, finessgeodp,
      annee    = an,
      age, sexe,
      charlson = coalesce(charlson, 0L),
      deces    = if_else(modesortie == "9", 1L, 0L)
    ) %>%
    collect()
})

# ==== AJUSTEMENT (standardisation indirecte, modèle France entière) ====
mod <- glm(
  deces ~ age + factor(sexe) + charlson,
  data   = cohorte_all,
  family = binomial(link = "logit")
)

cohorte_all$prob_attendue <- predict(mod, type = "response")

# Ratio standardisé observé / attendu par établissement × année (1 séjour = 1 obs)
resultat <- cohorte_all %>%
  group_by(annee, finessgeodp) %>%
  summarise(
    N_total = n(),
    obs     = sum(deces),
    att     = sum(prob_attendue),
    taux_brut = obs / N_total,
    smr     = obs / att,
    smr_lo  = (obs * (1 - 1/(9*obs)         - 1.96/(3*sqrt(obs)))^3)         / att,
    smr_hi  = ((obs + 1) * (1 - 1/(9*(obs+1)) + 1.96/(3*sqrt(obs+1)))^3) / att,
    .groups = "drop"
  ) %>%
  filter(N_total >= seuil_min)

# Jointure RS, restreint au département
ref_finess <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  select(annee, finessgeo, rs) %>%
  collect()

resultat <- resultat %>%
  inner_join(ref_finess, by = c("annee", "finessgeodp" = "finessgeo"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = smr, color = rs)) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey40") +
  geom_smooth(se = FALSE, method = "loess") +
  geom_pointrange(aes(ymin = smr_lo, ymax = smr_hi)) +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Mortalité intra-hosp post-AVC ischémique (I63) — SMR ajusté âge×sexe×Charlson",
       y = "SMR (obs / attendu)", x = NULL)

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "smr_mortalite_avc_ischemique.csv")
