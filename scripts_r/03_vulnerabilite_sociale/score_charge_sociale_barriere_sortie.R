# ==============================================================================
# Indicateur : Score de charge sociale comme barrière à la sortie
# Source     : custom — Aaltonen 2020 (JAMDA, DOI 10.1016/j.jamda.2020.11.030) ;
#              Pellico-López 2019 (IJERPH, DOI 10.3390/ijerph16183304)
# Pattern    : §6 score_composite / §8 distribution (score gradué par séjour)
# Catégorie  : 03_vulnerabilite_sociale
# Fiche      : indicateurs_pmsi/03_vulnerabilite_sociale/score_charge_sociale_barriere_sortie.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/portail_atih_mco.md) ====
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# Mode de sortie / dest.: fixe.modesortie (6/7) / fixe.destination (SSR "2")
# Journées > borne haute: fixe.nbexh  (> 0 → séjour prolongé)
# DAS (CIM-10)          : diag.diag  (codes Z sociaux)
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Raison sociale (RS)   : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees     <- 2016:2025
dep        <- "29"
modes_aval <- c("6", "7")
dest_ssr   <- "2"            # destination SSR — code à confirmer (notice ATIH)
code_z751  <- "Z751"
seuil_min  <- 30

# Pondérations des familles de barrières sociales (défaut : poids égaux = comptage).
# Variante experte possible : surpondérer F1 (logement) et F4 (dépendance soignant),
# les plus directement bloquantes pour un retour à domicile.
w1 <- 1   # F1 Logement / précarité économique  (Z59*)
w2 <- 1   # F2 Isolement / vie seule            (Z60.2, Z60.4)
w3 <- 1   # F3 Entourage défaillant             (Z63.4/5/6)
w4 <- 1   # F4 Dépendance vis-à-vis du soignant  (Z74*)
w5 <- 1   # F5 Attente de structure adaptée      (Z75.1)

# Codes CIM-10 (sans point, format PMSI)
codes_f2 <- c("Z602", "Z604")
codes_f3 <- c("Z634", "Z635", "Z636")

# ==== EXTRACTION — séjours prolongés en attente d'aval + familles sociales ====
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  # Familles de barrières sociales agrégées au séjour (max → présence ≥ 1 code)
  soc <- tbl_diag %>%
    transmute(
      ident,
      f1 = if_else(substr(diag, 1, 3) == "Z59", 1L, 0L),
      f2 = if_else(diag %in% codes_f2, 1L, 0L),
      f3 = if_else(diag %in% codes_f3, 1L, 0L),
      f4 = if_else(substr(diag, 1, 3) == "Z74", 1L, 0L),
      f5 = if_else(diag == code_z751, 1L, 0L)
    ) %>%
    group_by(ident) %>%
    summarise(
      f1 = max(f1), f2 = max(f2), f3 = max(f3),
      f4 = max(f4), f5 = max(f5),
      .groups = "drop"
    )

  # Population : séjours prolongés (nbexh > 0) en attente d'aval
  pop <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(soc, by = "ident") %>%
    mutate(
      across(c(f1, f2, f3, f4, f5), ~ coalesce(., 0L)),
      nbexh = coalesce(nbexh, 0L)
    ) %>%
    filter(nbexh > 0L,
           (modesortie %in% modes_aval & destination == dest_ssr) | f5 == 1L) %>%
    transmute(
      annee     = an,
      finessgeo = finessgeodp,
      ident,
      score_social = w1 * f1 + w2 * f2 + w3 * f3 + w4 * f4 + w5 * f5,
      n_familles   = f1 + f2 + f3 + f4 + f5
    )

  pop %>%
    group_by(annee, finessgeo) %>%
    summarise(
      N_total       = n_distinct(ident),
      score_moyen   = mean(score_social),
      N_barriere    = sum(if_else(n_familles >= 1L, 1L, 0L)),
      N_intense     = sum(if_else(n_familles >= 2L, 1L, 0L)),
      N_filiere_pure = sum(if_else(n_familles == 0L, 1L, 0L)),  # médico-filière
      .groups       = "drop"
    ) %>%
    collect()
})

# ==== CALCUL — parts et typologie du bed-blocker ====
resultat <- resultat %>%
  filter(N_total >= seuil_min) %>%
  mutate(
    part_barriere = N_barriere / N_total,        # sous-type médico-social
    part_intense  = N_intense / N_total,
    ratio_social_filiere = if_else(N_filiere_pure > 0,
                                   N_barriere / N_filiere_pure, NA_real_)
  )

# Jointure raison sociale
ref_rs <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  transmute(annee, finessgeo, rs) %>%
  collect()

resultat <- resultat %>%
  left_join(ref_rs, by = c("annee", "finessgeo")) %>%
  mutate(rs = coalesce(rs, finessgeo))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — série temporelle de la part à barrière sociale ====
ggplot2::ggplot(resultat, aes(x = annee, y = part_barriere, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Charge sociale comme barrière à la sortie (séjours prolongés)",
    subtitle = "Part des séjours bloqués avec ≥ 1 barrière sociale codée — sous-type médico-social",
    x = "Année", y = "Part (codage social — plancher)",
    caption  = "Sous-codage massif des Z sociaux : la part est un plancher (cf. fiche)"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "score_charge_sociale_barriere_sortie.csv")
