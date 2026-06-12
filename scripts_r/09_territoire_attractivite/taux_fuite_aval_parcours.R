# ==============================================================================
# Indicateur : Taux de Fuite d'Aval de Parcours
# Source     : custom (littérature "fragmented care" — Freischlag 2020, Nica 2024)
# Pattern    : §5 — parcours_sequentiel (couples index → traitement chaînés)
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/taux_fuite_aval_parcours.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)              : fixe.ident
# DP                            : fixe.dp
# CMD (2 car)                   : substr(ghm2, 1, 2)
# Dates entrée / sortie         : fixe.date_entree / fixe.date_sortie
# Mode sortie                   : fixe.modesortie     (9 = décès)
# Code géographique patient     : fixe.codegeo
# FINESS géographique du DP     : finessgeo_umdudp.finessgeodp
# IPP chaîné inter-séjours      : id_hospit_ipp.ipp_c
# Actes CCAM                    : acte.acte (8 car : CCAM + phase), clé ident
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees      <- 2019:2025  # table id_hospit_ipp (chaînage IPP) inexistante avant 2019 (dico ATIH)
finess_ght  <- c("<TODO: liste des FINESS géographiques du GHT>")
codegeo_ght <- c("<TODO: liste des codes géographiques PMSI du territoire>")

fenetre_jours <- 180   # fenêtre index → traitement (fiche : 180 j, à adapter par filière)

# Couples index → traitement par filière :
#   dp_index        : préfixes CIM-10 (3 car) du séjour index
#   ccam_traitement : actes CCAM (7 car) du séjour de traitement
# Validation clinique indispensable avant production.
filieres <- list(
  colorectal = list(
    dp_index        = c("C18", "C19", "C20"),
    ccam_traitement = c("<TODO: actes CCAM de colectomie / proctectomie>")
  ),
  sein = list(
    dp_index        = c("C50"),
    ccam_traitement = c("<TODO: actes CCAM de mastectomie / tumorectomie>")
  ),
  pth = list(
    dp_index        = c("M16"),
    ccam_traitement = c("<TODO: actes CCAM de prothèse totale de hanche>")
  )
)

seuil_min <- 30   # parcours minimum / filière / an pour l'interprétation

# ==== EXTRACTION ====
# Pour chaque filière : séjours index candidats (DP filière, dans le GHT) et
# séjours porteurs d'un acte cible (tous établissements), résidents uniquement.
sejours <- purrr::map_dfr(annees, function(an) {

  tbl_fixe  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geodp <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_ipp   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".id_hospit_ipp")))
  tbl_acte  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  base <- tbl_fixe %>%
    filter(codegeo %in% codegeo_ght,
           substr(ghm2, 1, 2) != "90",
           substr(ghm2, 1, 2) != "28") %>%
    inner_join(tbl_ipp %>% select(ident, ipp_c), by = "ident") %>%
    inner_join(tbl_geodp %>% select(ident, finessgeodp), by = "ident") %>%
    select(ident, ipp_c, finessgeodp, dp, date_entree, date_sortie, modesortie)

  purrr::map_dfr(names(filieres), function(f) {

    actes_cibles <- tbl_acte %>%
      # acte = CCAM + phase (8 car, dico ATIH) : matcher sur 7 car
    filter(substr(acte, 1, 7) %in% filieres[[f]]$ccam_traitement) %>%
      distinct(ident) %>%
      mutate(acte_cible = 1L)

    # Index candidats : DP de la filière, pris en charge dans le GHT
    idx <- base %>%
      filter(substr(dp, 1, 3) %in% filieres[[f]]$dp_index,
             finessgeodp %in% finess_ght) %>%
      left_join(actes_cibles, by = "ident") %>%
      transmute(ident, ipp_c, finessgeodp, date_entree, date_sortie, modesortie,
                acte_cible = coalesce(acte_cible, 0L), role = "index")

    # Traitements candidats : acte cible, où qu'il ait lieu
    trt <- base %>%
      inner_join(actes_cibles, by = "ident") %>%
      transmute(ident, ipp_c, finessgeodp, date_entree, date_sortie, modesortie,
                acte_cible = 1L, role = "traitement")

    union_all(idx, trt) %>%
      mutate(filiere = f, annee = an) %>%
      collect()
  })
})

# ==== CALCUL MÉTHODOLOGIQUE (reconstitution des parcours en local) ====
sejours <- sejours %>%
  filter(!is.na(ipp_c)) %>%
  distinct(filiere, role, ident, .keep_all = TRUE)

# Censure : les index trop proches de la fin de période d'observation n'ont
# pas une fenêtre complète → exclus du dénominateur.
date_censure <- as.Date(paste0(max(annees), "-12-31")) - fenetre_jours

# Séjour index retenu = premier séjour index candidat du patient (par filière)
index <- sejours %>%
  filter(role == "index") %>%
  arrange(ipp_c, filiere, date_entree) %>%
  group_by(ipp_c, filiere) %>%
  slice(1) %>%
  ungroup() %>%
  filter(date_sortie <= date_censure,
         modesortie != "9") %>%   # décès au cours de l'index : pas de parcours
  select(ipp_c, filiere,
         ident_index   = ident,
         finess_index  = finessgeodp,
         date_index    = date_sortie,
         acte_pdt_index = acte_cible,
         annee_index   = annee)

# Premier traitement dans la fenêtre, postérieur à l'index
traitements <- sejours %>%
  filter(role == "traitement") %>%
  select(ipp_c, filiere,
         ident_trt  = ident,
         finess_trt = finessgeodp,
         date_trt   = date_entree)

parcours <- index %>%
  left_join(traitements,
            by = c("ipp_c", "filiere"),
            relationship = "one-to-many") %>%
  mutate(delai = as.numeric(date_trt - date_index)) %>%
  filter(is.na(delai) | (delai >= 1 & delai <= fenetre_jours)) %>%
  arrange(ipp_c, filiere, delai) %>%
  group_by(ipp_c, filiere) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(
    # acte réalisé pendant l'index = parcours retenu, non fui (convention fiche)
    traite    = acte_pdt_index == 1L | !is.na(ident_trt),
    fuite_aval = if_else(acte_pdt_index == 1L, FALSE,
                         !finess_trt %in% finess_ght)
  ) %>%
  filter(traite)   # index sans traitement identifié : exclus du dénominateur

resultat <- parcours %>%
  group_by(annee_index, filiere) %>%
  summarise(
    N_parcours    = n_distinct(ipp_c),
    N_fuite_aval  = sum(fuite_aval, na.rm = TRUE),
    TFA           = N_fuite_aval / N_parcours,
    delai_med_ght   = median(delai[!fuite_aval], na.rm = TRUE),
    delai_med_fuite = median(delai[fuite_aval], na.rm = TRUE),
    .groups       = "drop"
  ) %>%
  filter(N_parcours >= seuil_min)

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot2::ggplot(resultat, aes(x = annee_index, y = TFA, color = filiere)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(filiere, filiere), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_taux_fuite_aval_parcours.csv")
