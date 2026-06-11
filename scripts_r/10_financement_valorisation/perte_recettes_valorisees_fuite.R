# ==============================================================================
# Indicateur : Perte de Recettes Valorisées de la Fuite
# Source     : custom (T2A — valorisation théorique socle ex-DG)
# Pattern    : §7 — comptage_simple (somme valorisée par GHS)
# Fiche      : indicateurs_pmsi/10_financement_valorisation/perte_recettes_valorisees_fuite.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car)                   : fixe.ghm2
# GHS                           : fixe.ghs
# Racine GHM (5 car)            : substr(ghm2, 1, 5)
# Niveau de sévérité            : substr(ghm2, 6, 6)
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Code géographique patient     : fixe.codegeo
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# Tarifs GHS ex-DG              : NON DISPONIBLE EN BASE — fichier local ATIH
#                                 (CSV campagne tarifaire : ghs, annee, tarif)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees      <- 2016:2025
finess_ght  <- c("<TODO: liste des FINESS géographiques du GHT>")
codegeo_ght <- c("<TODO: liste des codes géographiques PMSI du territoire>")

# Fichier tarifs construit depuis les arrêtés/fichiers de campagne ATIH
# (tarifs GHS secteur ex-DG, un par GHS × année) — colonnes : ghs, annee, tarif
chemin_tarifs <- "<TODO: chemin vers tarifs_ghs_exdg.csv>"

# Tarifs constants : année de référence pour neutraliser l'effet campagne
# (NULL = tarifs courants de chaque année uniquement)
annee_tarif_ref <- NULL   # ex: 2024

niveaux_evitables <- c("1", "2", "J", "T")
v_min <- 30               # séjours/an pour qu'une racine appartienne au casemix GHT

# NB : séances (CMD 28) exclues — leur valorisation est par forfait/séance,
# à traiter dans une extension dédiée si besoin.

# ==== EXTRACTION ====
fuite_ghs <- purrr::map_dfr(annees, function(an) {

  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Casemix GHT (production totale, tous sites) pour le flag "évitable"
  casemix_ght <- tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28") %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    filter(finessgeodp %in% finess_ght) %>%
    transmute(ident, racine = substr(ghm2, 1, 5)) %>%
    group_by(racine) %>%
    summarise(N_prod = n_distinct(ident), .groups = "drop") %>%
    filter(N_prod >= v_min) %>%
    transmute(racine, in_casemix = 1L)

  # Séjours en fuite des résidents, agrégés par GHS × racine × évitable
  tbl_fixe %>%
    filter(codegeo %in% codegeo_ght,
           substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28") %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    filter(!finessgeodp %in% finess_ght) %>%
    transmute(ident, ghs,
              racine = substr(ghm2, 1, 5),
              niveau = substr(ghm2, 6, 6)) %>%
    left_join(casemix_ght, by = "racine") %>%
    mutate(
      evitable = if_else(!is.na(in_casemix) & niveau %in% niveaux_evitables, 1L, 0L)
    ) %>%
    group_by(ghs, racine, evitable) %>%
    summarise(n = n_distinct(ident), .groups = "drop") %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE (valorisation en local) ====
tarifs <- readr::read_csv(chemin_tarifs, show_col_types = FALSE)
# attendu : ghs (même format que fixe.ghs), annee, tarif (euros, socle ex-DG
# hors suppléments et coefficients géographiques)

if (!is.null(annee_tarif_ref)) {
  tarifs <- tarifs %>%
    filter(annee == annee_tarif_ref) %>%
    select(ghs, tarif)
  fuite_val <- fuite_ghs %>% left_join(tarifs, by = "ghs")
} else {
  fuite_val <- fuite_ghs %>% left_join(tarifs, by = c("ghs", "annee"))
}

# GHS sans correspondance tarifaire : à examiner (nouveautés de campagne)
ghs_sans_tarif <- fuite_val %>%
  filter(is.na(tarif)) %>%
  group_by(annee, ghs) %>%
  summarise(n = sum(n), .groups = "drop")
print(ghs_sans_tarif)

resultat_global <- fuite_val %>%
  filter(!is.na(tarif)) %>%
  group_by(annee) %>%
  summarise(
    n_sejours    = sum(n),
    PRF          = sum(n * tarif),
    PRF_evitable = sum(n * tarif * evitable),
    panier_moyen = PRF / n_sejours,
    .groups      = "drop"
  )

resultat_racine <- fuite_val %>%
  filter(!is.na(tarif)) %>%
  group_by(annee, racine) %>%
  summarise(
    n_sejours    = sum(n),
    PRF          = sum(n * tarif),
    PRF_evitable = sum(n * tarif * evitable),
    .groups      = "drop"
  )

# ==== RÉSULTAT ====
print(resultat_global)
print(resultat_racine %>% arrange(desc(PRF_evitable)) %>% head(20))

# ==== VISUALISATION ====
ggplot2::ggplot(resultat_global, aes(x = annee)) +
  geom_smooth(aes(y = PRF / 1e6), se = FALSE, method = "loess", color = "grey60") +
  geom_smooth(aes(y = PRF_evitable / 1e6), se = FALSE, method = "loess",
              color = "firebrick") +
  geom_point(aes(y = PRF / 1e6), color = "grey60") +
  geom_point(aes(y = PRF_evitable / 1e6), color = "firebrick") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(y = "M€ (gris = PRF brut, rouge = PRF évitable)") +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_racine, "indicateur_perte_recettes_fuite.csv")
