# ==============================================================================
# Indicateur : ISO-PTH — Taux d'infection du site opératoire après PTH
# Source     : HAS
# Pattern    : §1 — taux
# Catégorie  : 05_qualite_securite
# Fiche      : indicateurs_pmsi/05_qualite_securite/iso_pth.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# GHM                   : fixe.ghm2 (6 car), racine = substr(ghm2, 1, 5)
# DP                    : fixe.dp
# DR                    : fixe.dr
# Diagnostics associés  : diag.diag (jointure sur ident)
# Actes CCAM            : acte.acte (jointure sur ident)
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Âge                   : fixe.age
# Durée séjour          : fixe.duree
# Mode sortie           : fixe.modesortie (9 = décès)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees          <- 2016:2025
dep             <- "29"              # Finistère (filtre FINESS géo)
codes_ccam_pth  <- c("NEKA020")      # Pose PTH primaire
codes_ghm_excl  <- c("08C48")        # Reprises exclues (racine)
codes_cim_iso   <- c("T845", "T846", "T847")  # ISO post-implant
age_min         <- 18
seuil_min_sej   <- 30                # cible robustesse statistique

# ==== EXTRACTION ====
resultat_brut <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_acte <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Dénominateur : séjours avec PTH primaire, adultes, hors reprises
  denom <- tbl_fixe %>%
    filter(
      age >= age_min,
      modesortie != "9",
      substr(ghm2, 1, 5) != codes_ghm_excl,
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      tbl_acte %>%
        filter(acte %in% codes_ccam_pth) %>%
        select(ident),
      by = "ident"
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    distinct(ident, .keep_all = TRUE)

  # Numérateur : PTH avec ISO en DP ou DAS
  num <- denom %>%
    inner_join(
      tbl_diag %>%
        filter(substr(diag, 1, 4) %in% codes_cim_iso) %>%
        select(ident) %>%
        distinct(),
      by = "ident"
    )

  # Agrégation
  denom %>%
    group_by(finessgeodp) %>%
    summarise(N_total = n_distinct(ident), .groups = "drop") %>%
    left_join(
      num %>%
        group_by(finessgeodp) %>%
        summarise(N_i = n_distinct(ident), .groups = "drop"),
      by = "finessgeodp"
    ) %>%
    mutate(
      N_i = coalesce(N_i, 0L),
      taux = N_i / N_total,
      annee = an
    ) %>%
    collect()
})

# ==== FILTRAGE ROBUSTESSE ====
resultat <- resultat_brut %>%
  filter(N_total >= seuil_min_sej) %>%
  rename(finessgeo = finessgeodp) %>%
  mutate(rs = finessgeo)   # à enrichir avec libellé RS si table dispo

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot2::ggplot(resultat, aes(x = annee, y = taux, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = "Taux ISO post-PTH par établissement",
    x = "Année",
    y = "Taux ISO",
    caption = paste0("Seuil robustesse : n >= ", seuil_min_sej,
                     " séjours PTH/an")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "iso_pth_par_etablissement.csv")
