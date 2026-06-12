# ==============================================================================
# Indicateur : Débit de Base / Débit de Crue / Indice de Base Hospitalier (IBH)
# Source     : custom (Hewlett & Bosch 1982, Litvak 2000)
# Pattern    : §1 taux + §2 mesure de variabilité (CV) — décomposition de flux
# Catégorie  : 01_activite_production
# Fiche      : indicateurs_pmsi/01_activite_production/debit_base_crue_admissions.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_mco — réutilisable en tête des prochains prompts
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# GHM (6 car)           : fixe.ghm2  → type GHM = substr(ghm2, 3, 1)
# CMD (2 car)           : substr(ghm2, 1, 2)
# Mode entrée           : fixe.modeentree
# Mode sortie           : fixe.modesortie
# Provenance            : fixe.provenance
# Passage urgences      : fixe.passage_urg
# Mois / année sortie   : fixe.mois, fixe.annee
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2016:2025
dep              <- "29"     # Finistère (filtre FINESS juridique)
seuil_min_mois   <- 30L      # robustesse : pas de calcul sur mois < 30 séjours
seuil_min_etab   <- 500L     # robustesse : ≥500 séjours/an pour interpréter IBH
# Modes d'entrée — fiche §Calcul (règle simplifiée PMSI seul) :
#   BASE  : modeentree ∈ {1,2,3,5,6}  ET type GHM ∈ {C,Z,K}  ET pas de passage urg
#   CRUE  : modeentree ∈ {7,8}        OU  passage_urg = 1
# (ambigus : exclus du calcul ; cf <TODO> Charlson plus bas)
# NB : passage_urg n'existe qu'à partir de 2023 (dico ATIH) — avant, la classe
# CRUE repose sur modeentree seul (rupture de série à signaler en lecture)
modes_base       <- c("1", "2", "3", "5", "6")
modes_crue       <- c("7", "8")
types_ghm_base   <- c("C", "Z", "K")

# ==== EXTRACTION — comptages mensuels par finessgeo × classe (BASE/CRUE) ====
mensuel <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  sejours <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",          # erreurs de groupage
      substr(ghm2, 1, 2) != "28",          # CMD 28 séances — hors flux d'admission
      modesortie != "9",                   # exclure décès (fiche §Calcul)
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    )

  # passage_urg absent des vues < 2023 : ne le référencer que si disponible
  if (an >= 2023) {
    sejours <- sejours %>%
      mutate(p_urg = coalesce(as.integer(passage_urg), 0L))
  } else {
    sejours <- sejours %>%
      mutate(p_urg = 0L)
  }

  sejours %>%
    transmute(
      finessgeo = finessgeodp,
      ident,
      annee     = an,
      mois,
      type_ghm  = substr(ghm2, 3, 1),
      modeentree = as.character(modeentree),
      p_urg
    ) %>%
    mutate(
      classe = case_when(
        modeentree %in% modes_crue                                ~ "CRUE",
        p_urg == 1L                                               ~ "CRUE",
        modeentree %in% modes_base & type_ghm %in% types_ghm_base ~ "BASE",
        TRUE                                                      ~ "AMBIGU"
      )
    ) %>%
    filter(classe != "AMBIGU") %>%
    group_by(annee, mois, finessgeo, classe) %>%
    summarise(N = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
# Mois complet : pivot BASE/CRUE et IBH mensuel
mensuel_wide <- mensuel %>%
  tidyr::pivot_wider(
    names_from  = classe,
    values_from = N,
    values_fill = 0L
  ) %>%
  mutate(
    N_total = BASE + CRUE,
    IBH     = if_else(N_total == 0L, NA_real_, BASE / N_total)
  ) %>%
  filter(N_total >= seuil_min_mois)

# Indicateurs annuels par établissement : IBH global, CV_BASE, CV_CRUE, RP
annuel <- mensuel_wide %>%
  group_by(finessgeo, annee) %>%
  summarise(
    N_BASE_an  = sum(BASE),
    N_CRUE_an  = sum(CRUE),
    N_total_an = sum(N_total),
    mu_BASE    = mean(BASE),
    sd_BASE    = sd(BASE),
    mu_CRUE    = mean(CRUE),
    sd_CRUE    = sd(CRUE),
    .groups = "drop"
  ) %>%
  filter(N_total_an >= seuil_min_etab) %>%
  mutate(
    IBH      = N_BASE_an / N_total_an,
    CV_BASE  = if_else(mu_BASE > 0, sd_BASE / mu_BASE, NA_real_),
    CV_CRUE  = if_else(mu_CRUE > 0, sd_CRUE / mu_CRUE, NA_real_),
    RP       = if_else(CV_BASE > 0, CV_CRUE / CV_BASE, NA_real_),
    rs       = finessgeo  # <TODO>: enrichir avec libellé RS si table dispo
  )

# Saisonnalité : amplitude IBH max-min sur les 12 mois calendaires (toutes années confondues)
saisonnalite <- mensuel_wide %>%
  group_by(finessgeo, mois) %>%
  summarise(
    BASE = sum(BASE),
    CRUE = sum(CRUE),
    .groups = "drop"
  ) %>%
  mutate(IBH_mois = BASE / (BASE + CRUE)) %>%
  group_by(finessgeo) %>%
  summarise(
    IBH_min     = min(IBH_mois, na.rm = TRUE),
    IBH_max     = max(IBH_mois, na.rm = TRUE),
    amplitude   = IBH_max - IBH_min,
    mois_min    = mois[which.min(IBH_mois)],
    mois_max    = mois[which.max(IBH_mois)],
    .groups = "drop"
  )

resultat <- annuel %>%
  left_join(saisonnalite, by = "finessgeo")

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — IBH annuel par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = IBH, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = "Indice de Base Hospitalier (IBH) — part des admissions programmées",
    subtitle = paste0("BASE = modeentree {1,2,3,5,6} & GHM {C,Z,K} hors urgences ; ",
                      "CRUE = modeentree {7,8} ou passage urgences"),
    x = "Année",
    y = "IBH = N_BASE / (N_BASE + N_CRUE)",
    caption = paste0("N_total annuel >= ", seuil_min_etab, " séjours")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "debit_base_crue_admissions.csv")
