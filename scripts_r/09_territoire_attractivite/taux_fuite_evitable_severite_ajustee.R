# ==============================================================================
# Indicateur : Taux de Fuite Évitable Ajusté sur la Sévérité
# Source     : custom (décomposition fuite évitable / structurelle)
# Pattern    : §1 — taux (double dénominateur : brut et restreint)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_fuite_evitable_severite_ajustee.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)              : fixe.ident
# GHM (6 car)                   : fixe.ghm2
# Racine GHM (5 car)            : substr(ghm2, 1, 5)
# Niveau de sévérité            : substr(ghm2, 6, 6)
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Mode entrée                   : fixe.modeentree
# Code géographique patient     : fixe.codegeo
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
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

niveaux_evitables <- c("1", "2", "J", "T")  # niveaux GHM "légers"
v_min     <- 30   # séjours/an pour qu'une racine appartienne au casemix GHT
seuil_min <- 50   # robustesse : N_eligible minimal par racine (fiche : ~50)

# Racines à exclure du périmètre évitable malgré leur présence au casemix
# (recours légitime : cancérologie sous seuils, chirurgie pédiatrique...)
racines_exclues <- c()  # à compléter à dires d'experts, ex: c("17K04", ...)

modes_entree_exclus <- c("6", "7")  # mutation, transfert — <TODO: confirmer les codes>

# ==== EXTRACTION ====
resultat_racine <- purrr::map_dfr(annees, function(an) {

  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Séjours des résidents du territoire (hors séances, erreurs, transferts)
  residents <- tbl_fixe %>%
    filter(codegeo %in% codegeo_ght,
           substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28",
           !modeentree %in% modes_entree_exclus) %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    transmute(
      ident, finessgeodp,
      racine   = substr(ghm2, 1, 5),
      niveau   = substr(ghm2, 6, 6),
      hors_ght = if_else(finessgeodp %in% finess_ght, 0L, 1L)
    )

  # Casemix GHT : racines produites par le GHT (production totale, tous sites)
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

  # Agrégat par racine : fuite brute + périmètre évitable
  residents %>%
    left_join(casemix_ght, by = "racine") %>%
    mutate(
      eligible = if_else(!is.na(in_casemix) & niveau %in% niveaux_evitables, 1L, 0L)
    ) %>%
    group_by(racine) %>%
    summarise(
      N_res            = n_distinct(ident),
      N_fuite_brute    = sum(hors_ght, na.rm = TRUE),
      N_eligible       = sum(eligible, na.rm = TRUE),
      N_fuite_evitable = sum(eligible * hors_ght, na.rm = TRUE),
      .groups          = "drop"
    ) %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL MÉTHODOLOGIQUE ====
resultat_racine <- resultat_racine %>%
  filter(!racine %in% racines_exclues)

# Synthèse annuelle GHT : taux brut, taux évitable, part structurelle
resultat_global <- resultat_racine %>%
  group_by(annee) %>%
  summarise(
    N_res            = sum(N_res),
    N_fuite_brute    = sum(N_fuite_brute),
    N_eligible       = sum(N_eligible),
    N_fuite_evitable = sum(N_fuite_evitable),
    taux_brut        = N_fuite_brute / N_res,
    TFE              = N_fuite_evitable / N_eligible,
    part_structurelle = (N_fuite_brute - N_fuite_evitable) / N_fuite_brute,
    .groups          = "drop"
  )

# Top racines contributrices en volume de fuite évitable (robustesse)
top_contributrices <- resultat_racine %>%
  filter(N_eligible >= seuil_min) %>%
  mutate(TFE = N_fuite_evitable / N_eligible) %>%
  arrange(desc(N_fuite_evitable))

# ==== RÉSULTAT ====
print(resultat_global)
print(top_contributrices %>% head(20))

# ==== VISUALISATION ====
ggplot2::ggplot(resultat_global, aes(x = annee)) +
  geom_smooth(aes(y = taux_brut), se = FALSE, method = "loess", color = "grey60") +
  geom_smooth(aes(y = TFE), se = FALSE, method = "loess", color = "firebrick") +
  geom_point(aes(y = taux_brut), color = "grey60") +
  geom_point(aes(y = TFE), color = "firebrick") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(y = "taux de fuite (gris = brut, rouge = évitable)") +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(top_contributrices, "indicateur_taux_fuite_evitable.csv")
