# ==============================================================================
# Indicateur : Hazard Ratio de Cox — Réinterventions chirurgicales ajustées
# Source     : custom (Cox 1972 ; Steiner 2000 ; Iezzoni 2013)
# Pattern    : §5 modèle de risque ajusté (analyse de survie Cox)
# Catégorie  : 05_qualite_securite
# Fiche      : indicateurs_pmsi/05_qualite_securite/hazard_ratio_cox_reinterventions.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_mco
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# GHM (6 car)           : fixe.ghm2
# Type GHM              : substr(ghm2, 3, 1)   # C/M/Z/K
# Sévérité              : substr(ghm2, 6, 1)   # 1-4 ou T/E/J/Z
# CMD                   : substr(ghm2, 1, 2)
# Mode entrée / urgence : fixe.modeentree, fixe.passage_urg
# Mode sortie           : fixe.modesortie
# Âge / sexe            : fixe.age, fixe.sexe
# Dates                 : fixe.date_entree, fixe.date_sortie
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Diagnostics           : diag.diag (CIM-10) — pour Charlson
# Actes CCAM            : acte.acte (8 car : CCAM + phase) — racine = substr(acte, 1, 4)
# Chaînage patient      : id_hospit_ipp.ipp_c
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(survival)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2022:2024     # cohorte 3 ans
dep              <- "29"           # Finistère
fenetre_jours    <- 90L            # fenêtre J1-J90 pour la réintervention
seuil_min_etab   <- 200L           # ≥200 séjours/an (fiche §Limites)
# Codes CCAM : la fiche §Sources mentionne une "liste ATIH actes chirurgicaux"
# et "liste ATIH actes de reprise". Faute de référentiel embarqué, l'approximation
# retenue ici est :
#   - acte chirurgical = présence d'un acte CCAM ET ghm2 commence par "C" ou "Z"
#   - réintervention   = séjour suivant du même patient dans [1, 90] j avec
#                        ghm2 type C, et au moins un acte dont la racine (4 car)
#                        match une racine d'acte du séjour index
# <TODO>: brancher la liste ATIH officielle dès que disponible

# ==== EXTRACTION — séjours index chirurgicaux + actes + diags pour Charlson ====
extraire_an <- function(an) {
  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_ipp   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".id_hospit_ipp")))
  tbl_diag  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))
  tbl_acte  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  # Séjours candidats (chirurgie ou acte technique, hors décès, hors CMD 14/28/90)
  fixe_filt <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28",
      substr(ghm2, 1, 2) != "14",
      modesortie != "9",
      substr(finess, 1, 2) == dep,
      substr(ghm2, 3, 1) %in% c("C", "Z")
    )

  # Charlson via DAS — version simplifiée Quan 2005 (sous-ensemble, à enrichir)
  # <TODO>: passer à une implémentation complète Quan 2005
  charlson_codes <- c(
    "I21", "I22", "I25",       # IDM / cardiopathie ischémique
    "I50",                       # insuffisance cardiaque
    "I70", "I71", "I73",       # vasculaire périphérique
    "G45", "I63", "I64",       # AVC
    "F00", "F01", "F02", "F03",# démence
    "J40", "J41", "J42", "J43", "J44",  # BPCO
    "M05", "M06", "M32",       # connectivites
    "K25", "K26", "K27",       # ulcère
    "K70", "K71", "K73", "K74",# hépatopathie
    "E10", "E11", "E12", "E13", "E14",  # diabète
    "N03", "N04", "N18", "N19",# néphropathie
    "C00", "C01", "C02", "C03", "C04", "C05", "C06", "C07",  # cancers solides (extrait)
    "B20", "B21", "B22", "B23", "B24"   # VIH
  )

  charlson <- tbl_diag %>%
    inner_join(fixe_filt %>% select(ident), by = "ident") %>%
    filter(substr(diag, 1, 3) %in% charlson_codes) %>%
    group_by(ident) %>%
    summarise(charlson_n = n_distinct(substr(diag, 1, 3)), .groups = "drop")

  # Actes CCAM index (racines 4 car)
  actes_index <- tbl_acte %>%
    inner_join(fixe_filt %>% select(ident), by = "ident") %>%
    transmute(ident, racine_acte = substr(acte, 1, 4)) %>%
    distinct() %>%
    group_by(ident) %>%
    summarise(racines = sql("LISTAGG(racine_acte, ';')"), .groups = "drop")
  # <TODO>: LISTAGG est Teradata-spécifique. Sur PostgreSQL utiliser
  # string_agg ; sur SQLite group_concat. Adapter si besoin.

  sejours <- fixe_filt %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    inner_join(tbl_ipp  %>% select(ident, ipp_c),       by = "ident") %>%
    left_join(charlson,                                  by = "ident") %>%
    left_join(actes_index,                               by = "ident")

  # passage_urg absent des vues < 2023 (dico ATIH) : la covariable mode_urg
  # repose sur modeentree seul avant 2023 (légère sous-détection des urgences)
  if (an >= 2023) {
    sejours <- sejours %>%
      mutate(p_urg = coalesce(as.integer(passage_urg), 0L))
  } else {
    sejours <- sejours %>%
      mutate(p_urg = 0L)
  }

  sejours %>%
    transmute(
      ident,
      ipp_c,
      finessgeo   = finessgeodp,
      annee_index = an,
      date_entree,
      date_sortie,
      age,
      sexe,
      ghm_racine  = substr(ghm2, 1, 5),
      severite    = substr(ghm2, 6, 1),
      mode_urg    = case_when(
        modeentree %in% c("7", "8") ~ 1L,
        p_urg == 1L                  ~ 1L,
        TRUE                         ~ 0L
      ),
      charlson_n  = coalesce(charlson_n, 0L),
      racines
    ) %>%
    collect()
}

cohorte_index <- purrr::map_dfr(annees, extraire_an)

# ==== EXTRACTION — séjours candidats à la réintervention (toutes années +1) ====
# On charge aussi l'année suivante pour capter les réinterventions à cheval
extraire_succ <- function(an) {
  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_ipp   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".id_hospit_ipp")))
  tbl_acte  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  fixe_filt <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 3, 1) == "C",
      modesortie != "9"
    )

  actes_succ <- tbl_acte %>%
    inner_join(fixe_filt %>% select(ident), by = "ident") %>%
    transmute(ident, racine_acte_succ = substr(acte, 1, 4)) %>%
    distinct()

  fixe_filt %>%
    inner_join(tbl_ipp %>% select(ident, ipp_c), by = "ident") %>%
    inner_join(actes_succ,                       by = "ident") %>%
    transmute(ident_succ = ident, ipp_c, date_succ = date_entree, racine_acte_succ) %>%
    collect()
}

succ <- purrr::map_dfr(c(annees, max(annees) + 1L), extraire_succ)

# ==== CONSTRUCTION (T, delta) PAR SÉJOUR INDEX ====
# Une réintervention est : ipp_c partagé, date_succ ∈ ]date_sortie ; date_sortie + 90j],
# ET racine d'acte du séjour suivant figure dans les racines du séjour index
cohorte_idx_long <- cohorte_index %>%
  tidyr::separate_rows(racines, sep = ";") %>%
  rename(racine_acte_idx = racines)

joints <- cohorte_idx_long %>%
  inner_join(succ, by = "ipp_c", relationship = "many-to-many") %>%
  filter(
    racine_acte_idx == racine_acte_succ,
    ident_succ != ident,
    as.numeric(difftime(date_succ, date_sortie, units = "days")) > 0,
    as.numeric(difftime(date_succ, date_sortie, units = "days")) <= fenetre_jours
  ) %>%
  group_by(ident) %>%
  summarise(
    delai_event = min(as.numeric(difftime(date_succ, date_sortie, units = "days"))),
    .groups = "drop"
  )

cohorte <- cohorte_index %>%
  left_join(joints, by = "ident") %>%
  mutate(
    delta = if_else(is.na(delai_event), 0L, 1L),
    T     = if_else(is.na(delai_event), as.numeric(fenetre_jours), delai_event),
    rs    = finessgeo                  # <TODO>: enrichir avec libellé RS
  ) %>%
  filter(!is.na(age), !is.na(sexe))

# Filtre volume minimal par établissement (sur la période)
etabs_ok <- cohorte %>%
  count(finessgeo) %>%
  filter(n >= seuil_min_etab) %>%
  pull(finessgeo)

cohorte <- cohorte %>% filter(finessgeo %in% etabs_ok)

# ==== CALCUL MÉTHODOLOGIQUE — Cox ajusté avec effet établissement ====
cox_fit <- survival::coxph(
  Surv(T, delta) ~ age + factor(sexe) + charlson_n +
                   factor(ghm_racine) + factor(severite) +
                   mode_urg + factor(annee_index) +
                   factor(finessgeo),
  data = cohorte,
  ties = "efron"
)

# Hazard ratios par établissement
coefs <- summary(cox_fit)$coefficients
conf  <- summary(cox_fit)$conf.int

idx_etab <- grepl("^factor\\(finessgeo\\)", rownames(coefs))

resultat_etab <- tibble(
  finessgeo = sub("^factor\\(finessgeo\\)", "", rownames(coefs)[idx_etab]),
  HR        = conf[idx_etab, "exp(coef)"],
  IC_low    = conf[idx_etab, "lower .95"],
  IC_high   = conf[idx_etab, "upper .95"],
  p_value   = coefs[idx_etab, "Pr(>|z|)"]
) %>%
  left_join(cohorte %>% count(finessgeo, name = "n_sejours"), by = "finessgeo") %>%
  mutate(rs = finessgeo)

# Vérification PH (Schoenfeld)
ph_test <- survival::cox.zph(cox_fit)

# C-index
c_index <- summary(cox_fit)$concordance[1]

# ==== RÉSULTAT ====
cat("C-index :", round(c_index, 3), "\n")
cat("Test PH global p =", round(ph_test$table["GLOBAL", "p"], 4), "\n")
print(resultat_etab)

# ==== TRAJECTOIRE TEMPORELLE — refit par année index ====
trajectoire <- purrr::map_dfr(annees, function(an) {
  sub_co <- cohorte %>% filter(annee_index == an)
  if (n_distinct(sub_co$finessgeo) < 2 || sum(sub_co$delta) < 30) return(tibble())

  fit <- try(survival::coxph(
    Surv(T, delta) ~ age + factor(sexe) + charlson_n +
                     factor(ghm_racine) + factor(severite) +
                     mode_urg + factor(finessgeo),
    data = sub_co, ties = "efron"
  ), silent = TRUE)
  if (inherits(fit, "try-error")) return(tibble())

  cf <- summary(fit)$conf.int
  idx <- grepl("^factor\\(finessgeo\\)", rownames(cf))
  tibble(
    annee     = an,
    finessgeo = sub("^factor\\(finessgeo\\)", "", rownames(cf)[idx]),
    HR        = cf[idx, "exp(coef)"],
    IC_low    = cf[idx, "lower .95"],
    IC_high   = cf[idx, "upper .95"]
  )
}) %>%
  mutate(rs = finessgeo)

# ==== VISUALISATION — trajectoire HR par établissement ====
ggplot2::ggplot(trajectoire, aes(x = annee, y = HR, color = rs)) +
  geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  geom_errorbar(aes(ymin = IC_low, ymax = IC_high), width = 0.2, alpha = 0.4) +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_log10() +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Hazard Ratio de Cox — réinterventions chirurgicales J<90",
    subtitle = paste0("Référence = établissement de base du modèle ; ajusté sur ",
                      "âge, sexe, Charlson, GHM-racine, sévérité, urgence"),
    x = "Année d'entrée du séjour index",
    y = "HR (échelle log)",
    caption = paste0("Volume minimal : ", seuil_min_etab, " séjours/établissement ; ",
                     "C-index = ", round(c_index, 2))
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_etab, "hazard_ratio_cox_reinterventions.csv")
# readr::write_csv(trajectoire,   "hazard_ratio_cox_reinterventions_trajectoire.csv")
