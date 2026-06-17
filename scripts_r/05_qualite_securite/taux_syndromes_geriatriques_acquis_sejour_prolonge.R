# ==============================================================================
# Indicateur : Taux de syndromes gériatriques acquis en séjour prolongé
# Source     : custom — Covinsky 2011 (JAMA, DOI 10.1001/jama.2011.1556) ;
#              Takahashi 2024 (Circ J, DOI 10.1253/circj.CJ-23-0722)
# Pattern    : §1 — taux
# Catégorie  : 05_qualite_securite
# Fiche      : indicateurs_pmsi/05_qualite_securite/taux_syndromes_geriatriques_acquis_sejour_prolonge.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/portail_atih_mco.md) ====
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# Âge (années)          : fixe.age
# CMD (erreurs groupage): substr(fixe.ghm2, 1, 2) != "90"
# Mode de sortie        : fixe.modesortie  (6/7 = attente d'aval)
# Destination           : fixe.destination (SSR = "2")
# Journées > borne haute: fixe.nbexh  (> 0 → séjour prolongé)
# DAS (CIM-10)          : diag.diag
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Raison sociale (RS)   : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees     <- 2016:2025
dep        <- "29"
age_min    <- 75
modes_aval <- c("6", "7")
dest_ssr   <- "2"            # destination SSR — code à confirmer (notice ATIH)
code_z751  <- "Z751"
seuil_min  <- 30

# Codes CIM-10 (sans point, format PMSI) par famille de syndrome gériatrique
codes_denutrition <- c("E40", "E41", "E42", "E43", "E44", "E45", "E46")  # match 3 car.
codes_chute_w     <- sprintf("W%02d", 0:19)                              # W00–W19, match 3 car.
# délire = F05* (3 car.) ; escarre = L89* (3 car.) ; déshydratation = E86 (3 car.) ;
# chutes à répétition = R29.6 → "R296" (4 car.)

# ==== EXTRACTION — séjours prolongés en attente d'aval + flag syndrome ====
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  # Flag attente de structure (Z75.1) pour compléter le ciblage aval
  flag_z751 <- tbl_diag %>%
    filter(diag == code_z751) %>%
    distinct(ident) %>%
    mutate(z751 = 1L)

  # Détection des syndromes gériatriques par famille (niveau diag → distinct ident)
  synd <- tbl_diag %>%
    mutate(
      famille = case_when(
        substr(diag, 1, 3) == "F05"               ~ "delire",
        substr(diag, 1, 3) == "L89"               ~ "escarre",
        substr(diag, 1, 3) %in% codes_denutrition ~ "denutrition",
        substr(diag, 1, 3) == "E86"               ~ "deshydratation",
        substr(diag, 1, 4) == "R296"              ~ "chute",
        substr(diag, 1, 3) %in% codes_chute_w     ~ "chute",
        TRUE                                       ~ NA_character_
      )
    ) %>%
    filter(!is.na(famille)) %>%
    group_by(ident) %>%
    summarise(
      synd_any    = 1L,
      n_familles  = n_distinct(famille),
      f_delire    = max(if_else(famille == "delire", 1L, 0L)),
      f_escarre   = max(if_else(famille == "escarre", 1L, 0L)),
      f_denutr    = max(if_else(famille == "denutrition", 1L, 0L)),
      .groups     = "drop"
    )

  # Population : séjours prolongés (nbexh > 0), âgés, en attente d'aval
  pop <- tbl_fixe %>%
    filter(
      age >= age_min,
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(flag_z751, by = "ident") %>%
    mutate(z751 = coalesce(z751, 0L), nbexh = coalesce(nbexh, 0L)) %>%
    filter(nbexh > 0L,
           (modesortie %in% modes_aval & destination == dest_ssr) | z751 == 1L) %>%
    transmute(annee = an, finessgeo = finessgeodp, ident)

  pop %>%
    left_join(synd, by = "ident") %>%
    mutate(
      synd_any   = coalesce(synd_any, 0L),
      n_familles = coalesce(n_familles, 0L),
      f_delire   = coalesce(f_delire, 0L),
      f_escarre  = coalesce(f_escarre, 0L),
      f_denutr   = coalesce(f_denutr, 0L)
    ) %>%
    group_by(annee, finessgeo) %>%
    summarise(
      N_total       = n_distinct(ident),
      N_synd        = sum(synd_any),
      N_polyatteinte = sum(if_else(n_familles >= 2L, 1L, 0L)),
      N_delire      = sum(f_delire),
      N_escarre     = sum(f_escarre),
      N_denutr      = sum(f_denutr),
      .groups       = "drop"
    ) %>%
    collect()
})

# ==== CALCUL — taux global et par famille ====
resultat <- resultat %>%
  filter(N_total >= seuil_min) %>%
  mutate(
    taux_global        = N_synd / N_total,
    part_polyatteinte  = N_polyatteinte / N_total,
    taux_delire        = N_delire / N_total,
    taux_escarre       = N_escarre / N_total,
    taux_denutrition   = N_denutr / N_total
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

# ==== VISUALISATION — série temporelle du taux global par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = taux_global, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Syndromes gériatriques acquis en séjour MCO prolongé",
    subtitle = "Part des séjours prolongés (≥ borne haute) en attente d'aval avec ≥ 1 syndrome codé",
    x = "Année", y = "Taux (présence codée — plancher)",
    caption  = "Sans marqueur present-on-admission : présence ≠ acquisition certaine (cf. fiche)"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_syndromes_geriatriques_acquis_sejour_prolonge.csv")
