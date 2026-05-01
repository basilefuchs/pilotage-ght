# ==============================================================================
# Indicateur : Score de vulnérabilité sociale des patients (codes Z CIM-10)
# Source     : custom (OMS CIM-10 ; HAS précarité ; DREES)
# Pattern    : §1 taux + §3 score composite pondéré sur diagnostics
# Catégorie  : 03_vulnerabilite_sociale
# Fiche      : indicateurs_pmsi/03_vulnerabilite_sociale/score_vulnerabilite_sociale.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_mco
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# DP (motif principal)  : fixe.dp        — exclu de la détection (fiche §Précisions)
# DAS (diagnostics)     : diag.diag      — source de détection des codes Z
# CMD                   : substr(ghm2, 1, 2)
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Année / mois sortie   : fixe.annee, fixe.mois
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2018:2025
dep              <- "29"        # Finistère
seuil_min_etab   <- 500L         # ≥500 séjours/an pour interpréter (fiche §Limites)

# Pondérations du score composite (fiche §Calcul niveau 2)
poids_logement   <- 3L     # Z59.0, Z59.1, Z59.2
poids_isolement  <- 2L     # Z60.2, Z60.3, Z60.4
poids_ecogenes   <- 3L     # Z59.5, Z59.6, Z59.7
poids_familial   <- 1L     # Z63.0, Z63.4, Z63.6
poids_protection <- 1L     # Z59.4, Z76.0

# Codes CIM-10 par domaine (préfixes complets — code à 4-5 caractères)
codes_logement   <- c("Z590", "Z591", "Z592")
codes_isolement  <- c("Z602", "Z603", "Z604")
codes_ecogenes   <- c("Z595", "Z596", "Z597")
codes_familial   <- c("Z630", "Z634", "Z636")
codes_protection <- c("Z594", "Z760")

codes_tous <- c(codes_logement, codes_isolement, codes_ecogenes,
                codes_familial, codes_protection)

# ==== EXTRACTION — flag domaine par séjour ====
sejour_score <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  fixe_filt <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28",
      substr(finess, 1, 2) == dep
    )

  # <TODO>: la table diag contient-elle uniquement les DAS, ou DP/DR/DAS confondus ?
  #   La fiche restreint aux DAS. Si la vue diag contient le DP, ajouter
  #   `filter(diag != fixe.dp)` après jointure pour exclure le DP.
  flags_z <- tbl_diag %>%
    inner_join(fixe_filt %>% select(ident), by = "ident") %>%
    filter(substr(diag, 1, 4) %in% codes_tous) %>%
    transmute(
      ident,
      dom_logement   = as.integer(substr(diag, 1, 4) %in% codes_logement),
      dom_isolement  = as.integer(substr(diag, 1, 4) %in% codes_isolement),
      dom_ecogenes   = as.integer(substr(diag, 1, 4) %in% codes_ecogenes),
      dom_familial   = as.integer(substr(diag, 1, 4) %in% codes_familial),
      dom_protection = as.integer(substr(diag, 1, 4) %in% codes_protection)
    ) %>%
    group_by(ident) %>%
    summarise(
      f_logement   = max(dom_logement,   na.rm = TRUE),
      f_isolement  = max(dom_isolement,  na.rm = TRUE),
      f_ecogenes   = max(dom_ecogenes,   na.rm = TRUE),
      f_familial   = max(dom_familial,   na.rm = TRUE),
      f_protection = max(dom_protection, na.rm = TRUE),
      .groups = "drop"
    )

  fixe_filt %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(flags_z,                                  by = "ident") %>%
    transmute(
      ident,
      finessgeo    = finessgeodp,
      annee        = an,
      mois,
      cmd          = substr(ghm2, 1, 2),
      f_logement   = coalesce(f_logement,   0L),
      f_isolement  = coalesce(f_isolement,  0L),
      f_ecogenes   = coalesce(f_ecogenes,   0L),
      f_familial   = coalesce(f_familial,   0L),
      f_protection = coalesce(f_protection, 0L)
    ) %>%
    mutate(
      score = f_logement   * poids_logement   +
              f_isolement  * poids_isolement  +
              f_ecogenes   * poids_ecogenes   +
              f_familial   * poids_familial   +
              f_protection * poids_protection,
      vuln_binaire = as.integer(score > 0L),
      classe = case_when(
        score == 0L            ~ "0_aucune",
        score >= 1L & score <= 3L ~ "1_legere",
        score >= 4L & score <= 6L ~ "2_moderee",
        score >= 7L              ~ "3_severe"
      )
    ) %>%
    collect()
})

# ==== CALCUL — agrégation par finessgeo × année ====
resultat <- sejour_score %>%
  group_by(finessgeo, annee) %>%
  summarise(
    N_total          = n_distinct(ident),
    N_vulnerable     = sum(vuln_binaire),
    score_moyen      = mean(score),
    score_p90        = quantile(score, 0.9),
    n_legere         = sum(classe == "1_legere"),
    n_moderee        = sum(classe == "2_moderee"),
    n_severe         = sum(classe == "3_severe"),
    n_log            = sum(f_logement),
    n_iso            = sum(f_isolement),
    n_eco            = sum(f_ecogenes),
    n_fam            = sum(f_familial),
    n_prot           = sum(f_protection),
    .groups = "drop"
  ) %>%
  filter(N_total >= seuil_min_etab) %>%
  mutate(
    taux_vulnerabilite = N_vulnerable / N_total,
    taux_severe        = n_severe     / N_total,
    rs                 = finessgeo                  # <TODO>: enrichir avec libellé RS
  )

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — taux de vulnérabilité par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = taux_vulnerabilite, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Taux de séjours avec ≥1 code Z de vulnérabilité sociale",
    subtitle = paste0("Codes Z : logement (Z59.0-2), isolement (Z60.2-4), ",
                      "économie (Z59.5-7), familial (Z63), protection (Z59.4/Z76.0)"),
    x = "Année",
    y = "Taux de vulnérabilité (≥1 code Z)",
    caption = paste0("Volume minimal : ", seuil_min_etab, " séjours/an. ",
                     "Sous-codage massif probable (cf. fiche §Limites)")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "score_vulnerabilite_sociale.csv")
