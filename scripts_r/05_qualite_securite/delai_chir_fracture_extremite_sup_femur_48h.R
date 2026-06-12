# ==============================================================================
# Indicateur : Délai de chirurgie ≤ 48h après fracture extrémité supérieure du fémur (≥65 ans)
# Source     : OCDE HCQO Acute Care
# Pattern    : §1 — taux (rate A/B)
# Fiche      : indicateurs_pmsi/05_qualite_securite/delai_chir_fracture_extremite_sup_femur_48h.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base : portail_atih_mco
# Séjour (1 ligne)        : prd_vue_mco_AAAA.fixe.ident
# DP                      : fixe.dp
# Âge                     : fixe.age
# Mode entrée             : fixe.modeentree
# Date entrée séjour      : fixe.date_entree
# GHM                     : fixe.ghm2
# Actes CCAM              : acte.acte
# Délai acte / date_entree (jours, int) : acte.acte_delai
# FINESS géo (DP)         : finessgeo_umdudp.finessgeodp
# RS établissement        : prd_vue_nomgen.finessgeo.rs
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
dep    <- "29"

age_min         <- 65L
delai_max_jours <- 2L      # 48h calendaires : J0, J1, J2
seuil_min       <- 30L

dp_fracture <- c("S720", "S721", "S722")  # col fémur, pertroch, sous-troch

ccam_chir_fracture <- c(
  "NZCA001", "NZCA002", "NZCA003", "NZCA004",  # ostéosynthèse extr sup fémur
  "NEKA010", "NEKA011", "NEKA012", "NEKA013",  # arthroplastie totale hanche pour fracture
  "NEKA014", "NEKA015", "NEKA016", "NEKA017",
  "NEMA001", "NEMA002",                          # prothèse fémorale
  "NZMA002"                                       # vissage col
)
# <TODO: confirmer/affiner la liste CCAM avec un médecin DIM ou la SOFCOT>

# ==== EXTRACTION ====
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_fixe      <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_acte      <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))
  tbl_finessgeo <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Cohorte index : ≥65 ans, DP fracture haut fémur, admission via urgences
  cohorte <- tbl_fixe %>%
    filter(
      age >= age_min,
      substr(dp, 1, 4) %in% dp_fracture,
      modeentree == "8",
      substr(ghm2, 1, 2) != "90"
    ) %>%
    select(ident)

  # Délai minimum (premier acte chir qualifiant) par séjour
  delai_chir <- tbl_acte %>%
    # acte = CCAM + phase (8 car, dico ATIH) : matcher sur 7 car
    filter(substr(acte, 1, 7) %in% ccam_chir_fracture) %>%
    semi_join(cohorte, by = "ident") %>%
    group_by(ident) %>%
    summarise(delai_min = min(acte_delai, na.rm = TRUE), .groups = "drop")

  # Numérateur / dénominateur par établissement
  cohorte %>%
    inner_join(delai_chir, by = "ident") %>%
    inner_join(tbl_finessgeo %>% select(ident, finessgeodp), by = "ident") %>%
    transmute(
      ident,
      finessgeodp,
      annee   = an,
      ope_48h = if_else(delai_min <= delai_max_jours, 1L, 0L)
    ) %>%
    group_by(annee, finessgeodp) %>%
    summarise(
      N_total = n_distinct(ident),
      N_48h   = sum(ope_48h, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
resultat <- resultat %>%
  filter(N_total >= seuil_min) %>%
  mutate(taux_48h = N_48h / N_total)

# Jointure raison sociale pour la viz, restreint au département
ref_finess <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  select(annee, finessgeo, rs) %>%
  collect()

resultat <- resultat %>%
  inner_join(ref_finess, by = c("annee", "finessgeodp" = "finessgeo"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = taux_48h, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Chirurgie ≤ 48h fracture haut fémur (≥65 ans)",
       y = "Taux opérés ≤ 48h", x = NULL)

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "delai_chir_fracture_haut_femur_48h.csv")
