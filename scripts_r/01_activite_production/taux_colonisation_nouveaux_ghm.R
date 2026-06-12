# ==============================================================================
# Indicateur : Taux de colonisation / extinction / turnover des racines GHM
# Source     : custom (MacArthur & Wilson 1967 — biogéographie insulaire)
# Pattern    : §4/§7 hybride — extraction de distribution + calcul local
#              ensembliste sur fenêtres trimestrielles glissantes
# Catégorie  : 01_activite_production
# Fiche      : indicateurs_pmsi/01_activite_production/taux_colonisation_nouveaux_ghm.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Connexion             : pRatihque::connection_database()
# Séjour (1 ligne)      : fixe.ident
# GHM (6 car)           : fixe.ghm2
# Racine GHM (5 car)    : substr(ghm2, 1, 5)
# CMD (2 car)           : substr(ghm2, 1, 2)
# FINESS juridique      : fixe.finess
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Année / mois sortie   : fixe.annee, fixe.mois
# Date entrée           : fixe.date_entree  (non utilisé — voir <TODO> ci-dessous)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees          <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
dep             <- "29"         # Finistère (filtre FINESS juridique)
granularite     <- 5L           # racine GHM (5 car) — fiche ; 6 = complet, 2 = CMD
seuil_pareto    <- 0.80         # Top-N défini comme Top-80% de l'activité
seuil_min_famille <- 20L        # N_f ≥ 20 sur 4 trimestres pour entrer au Top (fiche)
seuil_min_sejours <- 500L       # robustesse : ne pas interpréter si <500 sur la fenêtre
largeur_fenetre <- 4L           # nb trimestres par fenêtre (fiche : 4)
# Pas saisonnier pour la comparaison Ref↔Cur :
#   pas = 4 → compare T-7..T-4 à T-3..T  (annuel glissant classique fiche)
#   pas = 4 et comparaison fenêtre N vs fenêtre N-4 → anti-saisonnier (fiche §Limites)
pas_comparaison <- 4L

# <TODO>: la fiche agrège sur DATE_ENTREE ; ce script utilise (annee, mois)
#   = mois de sortie comme proxy du trimestre. Écart attendu faible (<1%) hors
#   long séjours. Pour coller strictement à la fiche, extraire MONTH(date_entree).

# ==== EXTRACTION — activité par finess × racine × trimestre ====
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",       # erreurs de groupage
      substr(ghm2, 1, 2) != "28",       # CMD 28 séances — hors cœur activité
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      tbl_geo %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      finessgeo = finessgeodp,
      ident,
      code = substr(ghm2, 1, granularite),
      annee = an,
      mois
    ) %>%
    mutate(trimestre = (mois - 1L) %/% 3L + 1L) %>%
    group_by(annee, trimestre, finessgeo, code) %>%
    summarise(N_i = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# Clé trimestre absolue (entier croissant) pour fenêtres glissantes
distribution <- distribution %>%
  mutate(t_abs = (annee - min(annees)) * 4L + trimestre)

# ==== CALCUL MÉTHODOLOGIQUE ====
# Pour chaque (finessgeo, fenêtre Ref, fenêtre Cur) :
#   1. Agréger les comptages par racine sur chacune des 2 fenêtres
#   2. Filtrer N_f >= seuil_min_famille
#   3. Déterminer Top-80% (tri décroissant, cumul ≤ seuil_pareto)
#   4. Calculer C, E, T, S, Jaccard

top_pareto <- function(df_fenetre, seuil) {
  # df_fenetre : code, N_i (déjà agrégé sur la fenêtre)
  df_fenetre %>%
    arrange(desc(N_i)) %>%
    mutate(
      N_total = sum(N_i),
      cum = cumsum(N_i),
      part_cum = cum / N_total
    ) %>%
    # Inclure toutes les familles jusqu'à dépasser le seuil (inclusif)
    mutate(inclus = lag(part_cum, default = 0) < seuil) %>%
    filter(inclus) %>%
    pull(code)
}

calcul_turnover_fenetre <- function(df_etab, t_cur) {

  t_ref_debut <- t_cur - 2L * largeur_fenetre + 1L
  t_ref_fin   <- t_cur - largeur_fenetre
  t_cur_debut <- t_cur - largeur_fenetre + 1L
  t_cur_fin   <- t_cur

  agg_fenetre <- function(tmin, tmax) {
    df_etab %>%
      filter(t_abs >= tmin, t_abs <= tmax) %>%
      group_by(code) %>%
      summarise(N_i = sum(N_i), .groups = "drop") %>%
      filter(N_i >= seuil_min_famille)
  }

  agg_ref <- agg_fenetre(t_ref_debut, t_ref_fin)
  agg_cur <- agg_fenetre(t_cur_debut, t_cur_fin)

  n_ref_total <- sum(agg_ref$N_i)
  n_cur_total <- sum(agg_cur$N_i)

  top_ref <- top_pareto(agg_ref, seuil_pareto)
  top_cur <- top_pareto(agg_cur, seuil_pareto)

  col_ghm <- setdiff(top_cur, top_ref)
  ext_ghm <- setdiff(top_ref, top_cur)
  inter   <- intersect(top_ref, top_cur)
  union_  <- union(top_ref, top_cur)

  n_base <- (length(top_ref) + length(top_cur)) / 2

  tibble(
    t_cur        = t_cur,
    annee_cur    = min(annees) + (t_cur - 1L) %/% 4L,
    trim_cur     = (t_cur - 1L) %% 4L + 1L,
    N_ref        = n_ref_total,
    N_cur        = n_cur_total,
    card_top_ref = length(top_ref),
    card_top_cur = length(top_cur),
    n_colonisateurs = length(col_ghm),
    n_extinctions   = length(ext_ghm),
    C = if_else(length(top_ref) == 0, 1, length(col_ghm) / n_base),
    E = if_else(length(top_ref) == 0, NA_real_, length(ext_ghm) / n_base),
    T = NA_real_,   # rempli ci-après
    S = NA_real_,
    Jaccard      = if_else(length(union_) == 0, NA_real_,
                           length(inter) / length(union_)),
    colonisateurs = paste(col_ghm, collapse = ";"),
    extinctions   = paste(ext_ghm, collapse = ";")
  ) %>%
    mutate(
      T = C + coalesce(E, 0),
      S = C - coalesce(E, 0)
    )
}

# Fenêtres Cur candidates : il faut t_ref_debut >= min(t_abs)
t_min <- min(distribution$t_abs)
t_max <- max(distribution$t_abs)
t_cur_candidats <- seq(t_min + 2L * largeur_fenetre - 1L, t_max, by = 1L)

resultat <- distribution %>%
  group_by(finessgeo) %>%
  group_split() %>%
  purrr::map_dfr(function(df_etab) {
    fg <- unique(df_etab$finessgeo)
    purrr::map_dfr(t_cur_candidats, function(t) {
      calcul_turnover_fenetre(df_etab, t) %>%
        mutate(finessgeo = fg, .before = 1)
    })
  }) %>%
  filter(N_cur >= seuil_min_sejours, N_ref >= seuil_min_sejours) %>%
  mutate(rs = finessgeo)   # <TODO>: enrichir avec libellé RS si table dispo

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — turnover T par établissement ====
# Sur l'axe : date de fin de la fenêtre courante (année fractionnaire)
resultat_viz <- resultat %>%
  mutate(date_cur = annee_cur + (trim_cur - 1L) / 4)

ggplot2::ggplot(resultat_viz, aes(x = date_cur, y = T, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = "Turnover T = C + E du cœur d'activité (Top-80% racines GHM)",
    subtitle = paste0("Fenêtres glissantes de ", largeur_fenetre,
                      " trimestres — seuil famille N_f >= ", seuil_min_famille),
    x = "Fin de fenêtre courante",
    y = "Turnover T",
    caption = paste0("N_ref et N_cur >= ", seuil_min_sejours, " séjours")
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_colonisation_nouveaux_ghm.csv")
