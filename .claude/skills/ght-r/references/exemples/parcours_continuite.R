# ==============================================================================
# Indicateur : Indice de continuité du parcours patient au sein du GHT
# Source     : custom
# Pattern    : §5 — parcours_sequentiel
# Catégorie  : 07_parcours_continuite
# Fiche      : indicateurs_pmsi/07_parcours_continuite/continuite_parcours_ght.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Base                  : portail ATIH Teradata, multi-champ
# Séjour MCO            : prd_vue_mco_AAAA.fixe (ident)
# Séjour SSR            : prd_vue_ssr_AAAA.fixe (ident)
# Séjour HAD            : prd_vue_had_AAAA.fixe (ident)
# FINESS géographique   : <champ>.finessgeo_umdudp.finessgeodp
# Chaînage patient      : id_hospit_ipp.ipp_c (inter-séjours)
# Date entrée/sortie    : fixe.date_entree / fixe.date_sortie
# ==========================================
#
# NOTE : Le chaînage via ipp_c suppose un appariement validé côté portail.
# Pour un chaînage via NIR crypté du SNDS, adapter la clé de chaînage.

library(dplyr)
library(dbplyr)
library(purrr)
library(lubridate)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees             <- 2020:2025
delai_max_jours    <- 90             # fiche propose 30/60/90 — défaut 90
finess_ght         <- c(             # FINESS du GHT (à personnaliser)
  "290000017",
  "290000025",
  "290000033"
)
types_parcours     <- c("MCO_SSR", "MCO_HAD", "MCO_SSR_HAD")

# ==== EXTRACTION DES SÉJOURS BRUTS (3 champs, chaînage via ipp_c) ====

extraire_champ <- function(champ) {
  purrr::map_dfr(annees, function(an) {

    prefix <- paste0("prd_vue_", champ, "_", an)
    tbl_fixe <- tbl(conn, I(paste0(prefix, ".fixe")))
    tbl_ipp  <- tbl(conn, I(paste0(prefix, ".id_hospit_ipp")))
    tbl_geo  <- tbl(conn, I(paste0(prefix, ".finessgeo_umdudp")))

    tbl_fixe %>%
      inner_join(tbl_ipp %>% select(ident, ipp_c), by = "ident") %>%
      inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
      transmute(
        ipp_c,
        finess = finessgeodp,
        champ = champ,
        date_debut = date_entree,
        date_fin   = date_sortie,
        annee = an
      ) %>%
      collect()
  })
}

sejours_mco <- extraire_champ("mco")
sejours_ssr <- extraire_champ("ssr")
sejours_had <- extraire_champ("had")

sejours <- bind_rows(sejours_mco, sejours_ssr, sejours_had) %>%
  mutate(
    date_debut = as.Date(date_debut),
    date_fin   = as.Date(date_fin)
  )

# ==== RECONSTITUTION DES PARCOURS ====
# Pour chaque patient : tri chrono + lookahead sur le séjour suivant

parcours <- sejours %>%
  arrange(ipp_c, date_debut) %>%
  group_by(ipp_c) %>%
  mutate(
    champ_suivant        = lead(champ),
    finess_suivant       = lead(finess),
    delai_suivant_jours  = as.numeric(lead(date_debut) - date_fin),
    annee_suivant        = lead(annee)
  ) %>%
  ungroup() %>%
  filter(
    !is.na(champ_suivant),
    delai_suivant_jours >= 0,
    delai_suivant_jours <= delai_max_jours
  ) %>%
  mutate(
    type_parcours = paste0(toupper(champ), "_", toupper(champ_suivant)),
    intra_ght = finess %in% finess_ght & finess_suivant %in% finess_ght,
    origine_ght = finess %in% finess_ght
  )

# ==== CALCUL DE L'INDICATEUR ====
# Dénominateur : parcours initiés intra-GHT
# Numérateur   : parcours entièrement intra-GHT

resultat <- parcours %>%
  filter(origine_ght,
         type_parcours %in% c("MCO_SSR", "MCO_HAD", "SSR_HAD")) %>%
  group_by(annee, type_parcours) %>%
  summarise(
    n_parcours       = n(),
    n_intra_ght      = sum(intra_ght),
    taux_continuite  = n_intra_ght / n_parcours,
    .groups = "drop"
  )

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot2::ggplot(resultat, aes(x = annee, y = taux_continuite,
                              color = type_parcours)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(type_parcours, type_parcours), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = "Indice de continuité du parcours intra-GHT",
    subtitle = paste0("Délai max entre séjours : ", delai_max_jours, " jours"),
    x = "Année",
    y = "Taux de continuité intra-GHT",
    caption = "Parcours avec 1er séjour dans un FINESS du GHT"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "continuite_parcours_ght.csv")
