# ==============================================================================
# Indicateur : Taux de Recours Hospitalier Standardisé sur l'âge et le sexe (TRHS)
# Source     : DREES/SAE, ATIH, IRDES (méthodologie standardisation indirecte)
# Pattern    : §2 — ratio_standardise (Obs / Att, IC95 Ulm 1990)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_recours_hospitalier_standardise_age_sexe.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA (+ nom_gen pour pop INSEE et correspondance géo)
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car)                   : fixe.ghm2
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Âge (années)                  : fixe.age
# Sexe                          : fixe.sexe                    (1 = M, 2 = F)
# Code géographique patient     : fixe.codegeo                 (codegeo PMSI)
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# Référentiel RS                : prd_vue_nomgen.finessgeo
# Pop INSEE par commune × âge × sexe : nom_gen.pop_com_sex_ag
#                                      (code_com, annee_pop, age, sexe, pop)
# Correspondance code_com ↔ codegeo PMSI : nom_gen.corresp_code_com_geo_ts_pop
#                                          (code_com, code_geo)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees        <- 2018:2025
seuil_obs     <- 500          # séjours minimum / zone pour TRHS global
seuil_obs_cmd <- 100          # séjours minimum / CMD pour TRHS_cmd

# ==== UTIL : tranche d'âge quinquennale (traduisible SQL via case_when) ====
# Utilisée à la fois côté dbplyr (avant collect) et en R local.
expr_tranche_age <- function() {
  # rlang::quo pour réinjecter dans mutate côté dbplyr
  rlang::quo(case_when(
    age <  5 ~ "00-04", age < 10 ~ "05-09", age < 15 ~ "10-14",
    age < 20 ~ "15-19", age < 25 ~ "20-24", age < 30 ~ "25-29",
    age < 35 ~ "30-34", age < 40 ~ "35-39", age < 45 ~ "40-44",
    age < 50 ~ "45-49", age < 55 ~ "50-54", age < 60 ~ "55-59",
    age < 65 ~ "60-64", age < 70 ~ "65-69", age < 75 ~ "70-74",
    age < 80 ~ "75-79", age < 85 ~ "80-84", age < 90 ~ "85-89",
    TRUE     ~ "90+"
  ))
}

# ==== EXTRACTION + CALCUL ANNUEL ====
resultats_an <- purrr::map_dfr(annees, function(an) {

  tbl_fixe    <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_refrs   <- tbl(conn, I(paste0("prd_vue_nomgen.finessgeo")))
  tbl_pop     <- tbl(conn, I("nom_gen.pop_com_sex_ag"))
  tbl_corresp <- tbl(conn, I("nom_gen.corresp_code_com_geo_ts_pop"))

  # ---- Séjours retenus (avec finessgeodp) ----
  sej <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",   # erreurs de groupage
      substr(ghm2, 1, 2) != "14",   # grossesse
      substr(ghm2, 1, 2) != "15",   # nouveau-nés
      !is.na(age),
      !is.na(sexe),
      !is.na(codegeo)
    ) %>%
    inner_join(
      tbl_geodp %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      ident, finessgeodp, codegeo,
      cmd  = substr(ghm2, 1, 2),
      age,
      sexe = as.character(sexe),
      tranche_age = !!expr_tranche_age()
    )

  # ---- ZONE D'ATTRACTION par pluralité (codegeo → finessgeodp dominant) ----
  zone <- sej %>%
    group_by(codegeo, finessgeodp) %>%
    summarise(n_drain = n_distinct(ident), .groups = "drop") %>%
    group_by(codegeo) %>%
    mutate(rg = row_number(desc(n_drain))) %>%
    filter(rg == 1) %>%
    ungroup() %>%
    transmute(codegeo, finessgeodp_zone = finessgeodp)

  # ---- POPULATION DE LA ZONE par (finessgeodp, tranche_age, sexe) ----
  pop_zone <- tbl_pop %>%
    filter(annee_pop == an) %>%
    inner_join(
      tbl_corresp %>% select(code_com, code_geo),
      by = "code_com"
    ) %>%
    inner_join(zone, by = c("code_geo" = "codegeo")) %>%
    transmute(
      finessgeodp_zone,
      sexe = as.character(sexe),
      tranche_age = !!expr_tranche_age(),
      pop
    ) %>%
    group_by(finessgeodp_zone, tranche_age, sexe) %>%
    summarise(pop = sum(pop, na.rm = TRUE), .groups = "drop") %>%
    collect() %>%
    rename(finessgeodp = finessgeodp_zone)

  # ---- POPULATION NATIONALE par (tranche_age, sexe) ----
  pop_nat <- tbl_pop %>%
    filter(annee_pop == an) %>%
    transmute(
      sexe = as.character(sexe),
      tranche_age = !!expr_tranche_age(),
      pop
    ) %>%
    group_by(tranche_age, sexe) %>%
    summarise(pop_nat = sum(pop, na.rm = TRUE), .groups = "drop") %>%
    collect()

  # ---- OBSERVÉS dans la zone : séjours dont codegeo affecté à finessgeodp ----
  obs <- sej %>%
    inner_join(zone, by = "codegeo") %>%
    filter(finessgeodp == finessgeodp_zone) %>%
    group_by(finessgeodp, cmd, tranche_age, sexe) %>%
    summarise(O = n_distinct(ident), .groups = "drop") %>%
    collect()

  # ---- SÉJOURS NATIONAUX par (cmd, tranche_age, sexe) — pour les taux ----
  obs_nat <- sej %>%
    group_by(cmd, tranche_age, sexe) %>%
    summarise(O_nat = n_distinct(ident), .groups = "drop") %>%
    collect()

  # ---- LIBELLÉ ÉTABLISSEMENT ----
  rs <- tbl_refrs %>%
    filter(annee == an) %>%
    select(finessgeo, rs) %>%
    collect() %>%
    rename(finessgeodp = finessgeo)

  # ---- TAUX NATIONAUX ----
  taux_nat_cmd <- obs_nat %>%
    inner_join(pop_nat, by = c("tranche_age", "sexe")) %>%
    mutate(taux = O_nat / pop_nat) %>%
    select(cmd, tranche_age, sexe, taux)

  taux_nat <- obs_nat %>%
    group_by(tranche_age, sexe) %>%
    summarise(O_nat = sum(O_nat), .groups = "drop") %>%
    inner_join(pop_nat, by = c("tranche_age", "sexe")) %>%
    mutate(taux = O_nat / pop_nat) %>%
    select(tranche_age, sexe, taux)

  # ---- TRHS GLOBAL ----
  obs_total <- obs %>%
    group_by(finessgeodp) %>%
    summarise(O_total = sum(O), .groups = "drop")

  att_total <- pop_zone %>%
    inner_join(taux_nat, by = c("tranche_age", "sexe")) %>%
    mutate(E = pop * taux) %>%
    group_by(finessgeodp) %>%
    summarise(E_total = sum(E, na.rm = TRUE), .groups = "drop")

  trhs_global <- obs_total %>%
    inner_join(att_total, by = "finessgeodp") %>%
    inner_join(rs, by = "finessgeodp") %>%
    mutate(
      annee   = an,
      TRHS    = if_else(E_total > 0, 100 * O_total / E_total, NA_real_),
      IC_low  = TRHS - 1.96 * (TRHS / sqrt(O_total)),
      IC_high = TRHS + 1.96 * (TRHS / sqrt(O_total)),
      Delta   = O_total - E_total,
      type    = "global",
      cmd     = NA_character_
    )

  # ---- TRHS PAR CMD ----
  obs_cmd <- obs %>%
    group_by(finessgeodp, cmd) %>%
    summarise(O_total = sum(O), .groups = "drop")

  att_cmd <- pop_zone %>%
    inner_join(taux_nat_cmd, by = c("tranche_age", "sexe")) %>%
    mutate(E = pop * taux) %>%
    group_by(finessgeodp, cmd) %>%
    summarise(E_total = sum(E, na.rm = TRUE), .groups = "drop")

  trhs_cmd <- obs_cmd %>%
    inner_join(att_cmd, by = c("finessgeodp", "cmd")) %>%
    inner_join(rs, by = "finessgeodp") %>%
    mutate(
      annee   = an,
      TRHS    = if_else(E_total > 0, 100 * O_total / E_total, NA_real_),
      IC_low  = TRHS - 1.96 * (TRHS / sqrt(O_total)),
      IC_high = TRHS + 1.96 * (TRHS / sqrt(O_total)),
      Delta   = O_total - E_total,
      type    = "cmd"
    )

  bind_rows(trhs_global, trhs_cmd)
})

# ==== RÉSULTAT ====
trhs_global <- resultats_an %>%
  filter(type == "global", O_total >= seuil_obs)

trhs_cmd <- resultats_an %>%
  filter(type == "cmd", O_total >= seuil_obs_cmd)

print(trhs_global)
print(trhs_cmd)

# ==== VISUALISATION : TRHS global par établissement ====
ggplot2::ggplot(trhs_global, aes(x = annee, y = TRHS, color = rs)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = IC_low, ymax = IC_high, fill = rs),
              alpha = 0.15, color = NA) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "TRHS standardisé âge × sexe", y = "TRHS (base 100)", x = NULL)

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(trhs_global, "trhs_global.csv")
# readr::write_csv(trhs_cmd,    "trhs_par_cmd.csv")
