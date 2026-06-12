# ==============================================================================
# Indicateur : Part des Journées de Psychiatrie en Temps Partiel
# Source     : DREES (ER n°1344, juillet 2025) / ATIH PMSI Psy (RPSA)
# Pattern    : §1 taux — sur sommes de journées (numérateur/dénominateur)
# Catégorie  : 01_activite_production
# Fiche      : indicateurs_pmsi/01_activite_production/part_journees_psy_temps_partiel.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil portail_atih_psy — réutilisable en tête des prochains prompts
#
# Base                       : portail ATIH Teradata, schéma prd_vue_psy_AAAA
# Connexion                  : pRatihque::connection_database()
# Séquence RPSA (1 ligne)    : fixe.ident
# Forme d'activité (ex-NPEC) : fixe.fa            (2 car. : 01-07 = temps plein,
#                                                  20-26 = temps partiel, 16-17 = ambu)
# Journées de présence       : fixe.nbjseq
# Demi-journées de présence  : fixe.nbdemijseq    (temps partiel, comptées × 0,5)
# FINESS géographique        : fixe.finessgeo
# FINESS juridique           : fixe.finess
# Année (fin de séquence)    : fixe.annee
# Raison sociale             : prd_vue_nomgen.finessgeo.rs (clé annee + finessgeo)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees          <- 2016:2025
dep             <- "29"      # Finistère (filtre FINESS juridique)
seuil_journees  <- 500L      # robustesse : ≥500 journées totales/an par établissement
# Périmètre des formes d'activité — définition ATIH (remarque nbjpres) :
#   temps plein    : FA 01-07 (hospitalisation complète ; la fiche DREES dit 01-04)
#   temps partiel  : FA 20-26 (HDJ, HDN, CATTP...), demi-journées comptées × 0,5
#   ambulatoire    : FA 16-17 — hors périmètre (ni numérateur ni dénominateur)
fa_temps_plein   <- sprintf("%02d", 1:7)
fa_temps_partiel <- sprintf("%02d", 20:26)

# ==== EXTRACTION — journées par finessgeo × mode de prise en charge ====
journees <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_psy_", an, ".fixe")))

  tbl_fixe %>%
    filter(
      substr(finess, 1, 2) == dep,
      fa %in% c(fa_temps_plein, fa_temps_partiel)
    ) %>%
    transmute(
      finessgeo,
      temps_partiel = fa %in% fa_temps_partiel,
      journees = if_else(fa %in% fa_temps_partiel,
                         nbjseq + 0.5 * nbdemijseq,   # convention ATIH nbjpres
                         as.numeric(nbjseq))
    ) %>%
    group_by(finessgeo, temps_partiel) %>%
    summarise(J = sum(journees, na.rm = TRUE), .groups = "drop") %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL — part temps partiel par établissement × année ====
resultat <- journees %>%
  group_by(annee, finessgeo) %>%
  summarise(
    J_total = sum(J),
    J_tp    = sum(if_else(temps_partiel, J, 0)),
    .groups = "drop"
  ) %>%
  filter(J_total >= seuil_journees) %>%
  mutate(part_tp = J_tp / J_total)

# Raison sociale (référentiel annuel, jointure annee + finessgeo)
ref_finess <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  transmute(annee, finessgeo, rs) %>%
  collect() %>%
  mutate(annee = as.integer(annee))

resultat <- resultat %>%
  left_join(ref_finess, by = c("annee", "finessgeo"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — trajectoire de la part temps partiel ====
ggplot2::ggplot(resultat, aes(x = annee, y = part_tp, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent) +
  labs(
    title    = "Part des journées de psychiatrie en temps partiel",
    subtitle = paste0("FA temps plein 01-07, temps partiel 20-26 (demi-journées × 0,5) — dép. ", dep),
    x = NULL, y = "Part temps partiel"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_part_journees_psy_temps_partiel.csv")
