# ==============================================================================
# Indicateur : Taux de Recours à l'HAD (relais MCO → HAD)
# Source     : ANAP / ATIH — chaînage inter-champs MCO↔HAD
# Pattern    : §1 taux + §5 parcours_sequentiel (chaînage patient `anonyme`)
# Catégorie  : 09_territoire_attractivite
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_recours_had.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profils portail_atih_mco + portail_atih_had — réutilisables en tête de prompt
#
# Base                    : portail ATIH Teradata, schémas prd_vue_mco_AAAA / prd_vue_had_AAAA
# Connexion               : pRatihque::connection_database()
# -- MCO --
# Séjour (1 ligne)        : fixe.ident
# Chaînage patient        : fixe.anonyme        (pseudonyme commun MCO↔HAD)
# Qualité chaînage        : fixe.ano_retour     ("000000000" = chaînage OK)
# Date de sortie          : fixe.date_sortie    (disponible 2019+)
# Mode sortie             : fixe.modesortie     ('9' = décès)
# GHM (6 car)             : fixe.ghm2           (CMD = substr(ghm2, 1, 2))
# FINESS géographique     : finessgeo_umdudp.finessgeodp
# -- HAD --
# Séjour HAD (1 ligne)    : fixe_sej.ident_sej
# Chaînage patient        : fixe_sej.anonyme
# Qualité chaînage        : fixe_sej.ano_retour
# Date d'entrée HAD       : fixe_sej.date_entree (disponible 2019+)
# FINESS géographique     : fixe_sej.finessgeo
# Raison sociale          : prd_vue_nomgen.finessgeo.rs (clé annee + finessgeo)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees       <- 2019:2024  # dates réelles dispo 2019+ (MCO et HAD) ; sorties MCO
                           # bornées à N-2 : les relais de décembre vivent dans le
                           # schéma HAD N+1 (séjour HAD rattaché à son année de sortie)
annees_had   <- 2019:2025  # schémas HAD balayés (année N et N+1)
dep          <- "29"       # Finistère — appliqué aux deux champs (un relais vers
                           # une HAD hors département n'est pas compté)
delai_jours  <- 7L         # relais précoce ANAP : entrée HAD ≤ J+7 post-sortie MCO
                           #   (2 = relais direct, plus strict)
chainage_ok  <- "000000000"  # ano_retour : 9 codes retour à zéro
seuil_min    <- 30L        # robustesse : ≥30 sorties/an par établissement

# ==== EXTRACTION HAD — entrées chaînées (tous schémas, dédupliquées) ====
had_entrees <- purrr::map_dfr(annees_had, function(an) {

  tbl_had <- tbl(conn, I(paste0("prd_vue_had_", an, ".fixe_sej")))

  tbl_had %>%
    filter(
      ano_retour == chainage_ok,
      substr(finessgeo, 1, 2) == dep
    ) %>%
    transmute(anonyme, date_entree_had = date_entree) %>%
    collect()
}) %>%
  distinct(anonyme, date_entree_had)

# ==== EXTRACTION MCO — sorties vivantes chaînées ====
sorties <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",        # erreurs de groupage
      substr(ghm2, 1, 2) != "28",        # CMD 28 séances — hors champ
      modesortie != "9",                 # sorties vivantes uniquement
      ano_retour == chainage_ok,         # chaînage exploitable
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(ident, anonyme, date_sortie, finessgeodp, annee = an) %>%
    collect()
})

# ==== CALCUL — relais HAD ≤ J+delai_jours par séjour, puis taux ====
relais <- sorties %>%
  left_join(had_entrees, by = "anonyme", relationship = "many-to-many") %>%
  mutate(delai = as.numeric(date_entree_had - date_sortie)) %>%
  group_by(annee, finessgeodp, ident) %>%
  summarise(
    relais_had = any(!is.na(delai) & delai >= 0 & delai <= delai_jours),
    .groups = "drop"
  )

resultat <- relais %>%
  group_by(annee, finessgeodp) %>%
  summarise(
    N_total  = n_distinct(ident),
    N_relais = sum(relais_had),
    .groups  = "drop"
  ) %>%
  filter(N_total >= seuil_min) %>%
  mutate(taux_relais_had = N_relais / N_total)

# Raison sociale (référentiel annuel, jointure annee + finessgeo)
ref_finess <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  transmute(annee, finessgeo, rs) %>%
  collect() %>%
  mutate(annee = as.integer(annee))

resultat <- resultat %>%
  left_join(ref_finess, by = c("annee", "finessgeodp" = "finessgeo"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — trajectoire du taux de relais par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = taux_relais_had, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent) +
  labs(
    title    = "Taux de recours à l'HAD en relais d'un séjour MCO",
    subtitle = paste0("Entrée HAD ≤ J+", delai_jours, " post-sortie, chaînage anonyme — dép. ", dep),
    x = NULL, y = "Part des sorties MCO relayées en HAD"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_taux_recours_had.csv")
