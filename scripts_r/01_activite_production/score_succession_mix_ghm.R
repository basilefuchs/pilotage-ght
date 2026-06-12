# ==============================================================================
# Indicateur : Score de Succession du Mix GHM
# Source     : Clements 1916 / Horn 1975 (succession écologique) — adaptation PMSI
# Pattern    : §6 — score_composite (comptages trimestriels + régression locale
#              + classification par stades + agrégation)
# Fiche      : indicateurs_pmsi/01_activite_production/score_succession_mix_ghm.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car) → racine (5 car)  : substr(fixe.ghm2, 1, 5)
# CMD (2 car)                   : substr(fixe.ghm2, 1, 2)
# Date entrée                   : fixe.date_entree
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# Référentiel RS                : prd_vue_nomgen.finessgeo
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(lubridate)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
dep              <- "29"          # filtre département (FINESS commençant par)
fenetre_trim     <- 8             # nb de trimestres dans la fenêtre glissante
fenetre_pente    <- 4             # nb de trimestres pour la régression de pente
seuil_part_pion  <- 2             # part max pour "Pionnier" (%)
seuil_pente_haut <- 0.5           # pp/trim — Croissance / Déclin
seuil_pente_clim <- 0.3           # pp/trim — stabilité Climax / Relique
seuil_part_clim  <- 5             # part min pour "Climax" (%)
seuil_part_relq  <- 1             # part max pour "Relique" (%)
seuil_volume_fam <- 20            # séjours min cumulés sur fenetre_trim

# ==== EXTRACTION : comptages trimestriels (finessgeodp, ghm_racine) ====
# On extrait aussi le total national par trimestre × racine pour la médiane
comptages <- purrr::map_dfr(annees, function(an) {

  tbl_fixe   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_refrs  <- tbl(conn, I(paste0("prd_vue_nomgen.finessgeo")))

  base <- tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28"
    ) %>%
    inner_join(
      tbl_geodp %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      ident, finessgeodp,
      ghm_racine = substr(ghm2, 1, 5),
      mois_e     = month(date_entree),
      trim_num   = case_when(
        mois_e <= 3 ~ 1L, mois_e <= 6 ~ 2L,
        mois_e <= 9 ~ 3L, TRUE        ~ 4L
      ),
      annee = an
    )

  # Local : sous-périmètre du GHT
  local <- base %>%
    filter(substr(finessgeodp, 1, 2) == dep) %>%
    inner_join(
      tbl_refrs %>% filter(annee == an) %>% select(finessgeo, rs),
      by = c("finessgeodp" = "finessgeo")
    ) %>%
    group_by(finessgeodp, rs, ghm_racine, annee, trim_num) %>%
    summarise(N = n_distinct(ident), .groups = "drop") %>%
    collect() %>%
    mutate(scope = "local")

  # National : pour la médiane des parts par famille × trimestre
  nat <- base %>%
    group_by(finessgeodp, ghm_racine, annee, trim_num) %>%
    summarise(N = n_distinct(ident), .groups = "drop") %>%
    collect() %>%
    mutate(scope = "national", rs = NA_character_)

  bind_rows(local, nat)
})

# ==== UTIL : index trimestre absolu (annee*4 + trim − 1) ====
ajoute_trim_idx <- function(df) {
  df %>% mutate(trim_idx = annee * 4L + trim_num - 1L)
}

comptages <- ajoute_trim_idx(comptages)

# ==== PARTS TRIMESTRIELLES par établissement et famille ====
parts_local <- comptages %>%
  filter(scope == "local") %>%
  group_by(finessgeodp, rs, trim_idx, annee, trim_num) %>%
  mutate(N_total_trim = sum(N)) %>%
  ungroup() %>%
  mutate(part = if_else(N_total_trim > 0, 100 * N / N_total_trim, NA_real_))

# Parts nationales pour la médiane
parts_nat <- comptages %>%
  filter(scope == "national") %>%
  group_by(finessgeodp, trim_idx) %>%
  mutate(N_total_trim = sum(N)) %>%
  ungroup() %>%
  mutate(part = if_else(N_total_trim > 0, 100 * N / N_total_trim, NA_real_))

mediane_nat <- parts_nat %>%
  group_by(ghm_racine, trim_idx) %>%
  summarise(part_med_nat = median(part, na.rm = TRUE), .groups = "drop")

# ==== CLASSIFICATION PAR FENÊTRE GLISSANTE ====
# Pour chaque trim_ref, on classe les familles sur la fenêtre [trim_ref - fenetre_trim + 1 ; trim_ref]
trims_ref <- sort(unique(parts_local$trim_idx))
trims_ref <- trims_ref[trims_ref >= min(trims_ref) + fenetre_trim - 1L]

classifier_fenetre <- function(trim_ref) {

  fenetre <- (trim_ref - fenetre_trim + 1L):trim_ref
  pente_window <- (trim_ref - fenetre_pente + 1L):trim_ref

  parts_loc_f <- parts_local %>% filter(trim_idx %in% fenetre)
  med_f       <- mediane_nat %>% filter(trim_idx == trim_ref) %>%
    select(ghm_racine, part_med_nat)

  # Volume cumulé par famille × établissement (filtrage qualité)
  vol_fam <- parts_loc_f %>%
    group_by(finessgeodp, rs, ghm_racine) %>%
    summarise(N_cum = sum(N), .groups = "drop") %>%
    filter(N_cum >= seuil_volume_fam)

  # Pente OLS sur la fenêtre courte (4 trim) — calcul local après collect
  pentes <- parts_loc_f %>%
    filter(trim_idx %in% pente_window) %>%
    group_by(finessgeodp, rs, ghm_racine) %>%
    summarise(
      n_pts = n(),
      pente = if (n_pts >= 2)
                stats::coef(stats::lm(part ~ trim_idx, data = pick(everything())))[2]
              else NA_real_,
      .groups = "drop"
    )

  # Ancienneté = nb de trimestres dans la fenêtre où la famille est présente
  presence <- parts_loc_f %>%
    filter(N > 0) %>%
    group_by(finessgeodp, rs, ghm_racine) %>%
    summarise(anciennete = n(), .groups = "drop")

  # Part au trimestre de référence
  part_ref <- parts_loc_f %>%
    filter(trim_idx == trim_ref) %>%
    select(finessgeodp, rs, ghm_racine, part_ref = part)

  # Assemblage et classification
  vol_fam %>%
    inner_join(part_ref, by = c("finessgeodp", "rs", "ghm_racine")) %>%
    left_join(pentes,    by = c("finessgeodp", "rs", "ghm_racine")) %>%
    left_join(presence,  by = c("finessgeodp", "rs", "ghm_racine")) %>%
    left_join(med_f,     by = "ghm_racine") %>%
    mutate(
      stade = case_when(
        anciennete <  fenetre_pente & part_ref < seuil_part_pion        ~ "Pionnier",
        !is.na(pente) & pente < -seuil_pente_haut                        ~ "Declin",
        !is.na(pente) & pente >  seuil_pente_haut &
          (is.na(part_med_nat) | part_ref < part_med_nat)                ~ "Croissance",
        part_ref >= seuil_part_clim & abs(pente) <= seuil_pente_clim     ~ "Climax",
        anciennete >= fenetre_trim & part_ref < seuil_part_relq &
          abs(pente) <= seuil_pente_clim                                 ~ "Relique",
        TRUE                                                              ~ "Intermediaire"
      ),
      trim_ref = trim_ref
    )
}

classification <- purrr::map_dfr(trims_ref, classifier_fenetre)

# ==== AGRÉGATION : scores par établissement × trimestre de référence ====
scores <- classification %>%
  group_by(finessgeodp, rs, trim_ref) %>%
  summarise(
    N_familles      = n(),
    N_pionniers     = sum(stade == "Pionnier"),
    N_croissance    = sum(stade == "Croissance"),
    N_climax        = sum(stade == "Climax"),
    N_declin        = sum(stade == "Declin"),
    N_reliques      = sum(stade == "Relique"),
    N_intermediaire = sum(stade == "Intermediaire"),
    .groups = "drop"
  ) %>%
  mutate(
    Score_expansion    = (N_pionniers + N_croissance) / N_familles,
    Score_stabilite    =  N_climax / N_familles,
    Score_contraction  = (N_declin  + N_reliques)     / N_familles,
    Score_intermediaire = N_intermediaire             / N_familles,
    Turnover           = (N_pionniers + N_declin)     / N_familles,
    IMP                = (2 * N_climax + N_croissance - N_declin
                          - 2 * N_reliques) / N_familles,
    annee_ref = trim_ref %/% 4L,
    trim_label = paste0(annee_ref, "-T", (trim_ref %% 4L) + 1L)
  )

# ==== RÉSULTAT ====
print(scores)
print(classification)

# ==== VISUALISATION : évolution des trois scores agrégés ====
scores %>%
  mutate(periode = annee_ref + (trim_ref %% 4L) / 4) %>%
  tidyr::pivot_longer(
    c(Score_expansion, Score_stabilite, Score_contraction),
    names_to = "score", values_to = "valeur"
  ) %>%
  ggplot2::ggplot(aes(x = periode, y = valeur, color = score)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  labs(title = "Score de succession du mix GHM (8 trimestres glissants)",
       x = NULL, y = "Part des familles GHM")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(scores,         "score_succession_etab.csv")
# readr::write_csv(classification, "classification_familles_ghm.csv")
