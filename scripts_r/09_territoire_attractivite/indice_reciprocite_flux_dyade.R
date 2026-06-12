# ==============================================================================
# Indicateur : Indice de Réciprocité des Flux d'une Dyade d'Établissements
# Source     : réseaux patient-sharing (Ishikawa 2024, PMID:38269990 ;
#              Barnett 2012, PMID:22249922)
# Pattern    : §5 parcours_sequentiel (couples orientés) + calcul local R / S
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/indice_reciprocite_flux_dyade.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)            : fixe.ident
# Patient chaîné (national)   : fixe.anonyme
# CMD (2 car)                 : substr(fixe.ghm2, 1, 2)
# Dates entrée / sortie       : fixe.date_entree / fixe.date_sortie
# FINESS géographique du DP   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
finess_A <- c("<TODO: FINESS géographiques de l'établissement A>")
finess_B <- c("<TODO: FINESS géographiques de l'établissement B>")

fenetre_jours <- 30   # délai max entre les deux séjours du couple (fiche : 30 j ;
                      # tester la robustesse sur 15 / 30 / 90 j)
seuil_min     <- 60   # F_AB + F_BA minimum / an pour l'interprétation

# ==== EXTRACTION : séjours de la dyade (hors séances et erreurs de groupage) ====
sejours_dyade <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28"
    ) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% c(finess_A, finess_B)) %>%
    transmute(anonyme, ident, finessgeodp, date_entree, date_sortie) %>%
    collect()
})

# ==== CALCUL : couples orientés A→B / B→A puis réciprocité ====
# NB : seuls les séjours de la dyade sont extraits — un séjour intermédiaire
# dans un établissement tiers entre les deux maillons n'est pas détecté.
couples <- sejours_dyade %>%
  filter(!is.na(anonyme)) %>%
  mutate(site = if_else(finessgeodp %in% finess_A, "A", "B")) %>%
  arrange(anonyme, date_entree) %>%
  group_by(anonyme) %>%
  mutate(
    site_suivant  = lead(site),
    delai_suivant = as.numeric(lead(date_entree) - date_sortie)
  ) %>%
  ungroup() %>%
  filter(
    !is.na(delai_suivant),
    delai_suivant >= 0,
    delai_suivant <= fenetre_jours,
    site != site_suivant
  ) %>%
  mutate(
    annee = as.integer(format(date_sortie, "%Y")),
    sens  = paste0(site, "_", site_suivant)
  )

resultat <- couples %>%
  group_by(annee) %>%
  summarise(
    F_AB = sum(sens == "A_B"),
    F_BA = sum(sens == "B_A"),
    P_AB = n_distinct(anonyme[sens == "A_B"]),
    P_BA = n_distinct(anonyme[sens == "B_A"]),
    R = 2 * pmin(F_AB, F_BA) / (F_AB + F_BA),
    S = (F_AB - F_BA) / (F_AB + F_BA),
    .groups = "drop"
  ) %>%
  filter(F_AB + F_BA >= seuil_min)

# <TODO: réciprocité valorisée R€ — joindre les tarifs GHS de campagne
# (fichier local CSV ghs, annee, tarif — indisponibles en base nationale,
# cf. profils/portail_atih_mco.md) et remplacer les effectifs par les
# valorisations des séjours receveurs>

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
resultat %>%
  tidyr::pivot_longer(c(R, S), names_to = "mesure", values_to = "valeur") %>%
  ggplot(aes(x = annee, y = valeur, color = mesure)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ mesure, scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  labs(title = "Réciprocité (R) et solde directionnel (S) des flux de la dyade",
       subtitle = paste0("fenêtre ", fenetre_jours, " j — R ∈ [0;1], S ∈ [-1;+1] (S > 0 : A envoie plus qu'il ne reçoit)"),
       y = NULL, x = NULL) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indice_reciprocite_flux_dyade.csv")
