# ==============================================================================
# Indicateur : Indice de concentration des journées de bed-blocking par profil patient
# Source     : custom — Lorenz 1905 / Gini 1912 ; cadrage Pellico-López 2019
#              (IJERPH, DOI 10.3390/ijerph16183304)
# Pattern    : §4 — mesure_diversite (Gini / Lorenz sur distribution profil × journées)
# Catégorie  : 04_efficience_capacitaire
# Fiche      : indicateurs_pmsi/04_efficience_capacitaire/indice_concentration_journees_bb_profil_patient.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/portail_atih_mco.md) ====
# Base                  : portail ATIH Teradata, schéma prd_vue_mco_AAAA
# Séjour (1 ligne)      : fixe.ident
# Âge (années)          : fixe.age
# CMD                   : substr(fixe.ghm2, 1, 2)
# Mode de sortie / dest.: fixe.modesortie (6/7) / fixe.destination (SSR "2")
# Journées > borne haute: fixe.nbexh  (journées de bed-blocking)
# DAS (CIM-10)          : diag.diag  (démence F00-F03/G30 ; dépendance Z74)
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Raison sociale (RS)   : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees     <- 2016:2025
dep        <- "29"
modes_aval <- c("6", "7")
dest_ssr   <- "2"            # destination SSR — code à confirmer (notice ATIH)
seuil_sej_profil <- 20      # séjours bloqués minimum pour qu'un profil compte
seuil_profils    <- 5       # nb minimum de profils pour calculer un Gini stable

codes_demence <- c("F00", "F01", "F02", "F03", "G30")  # match 3 car.
code_z74      <- "Z74"                                  # dépendance (match 3 car.)

# ==== EXTRACTION — journées de bed-blocking par profil patient ====
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  flag_dem <- tbl_diag %>%
    filter(substr(diag, 1, 3) %in% codes_demence) %>%
    distinct(ident) %>% mutate(dem = 1L)

  flag_dep <- tbl_diag %>%
    filter(substr(diag, 1, 3) == code_z74) %>%
    distinct(ident) %>% mutate(dep_z74 = 1L)

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    left_join(flag_dem, by = "ident") %>%
    left_join(flag_dep, by = "ident") %>%
    mutate(
      dem     = coalesce(dem, 0L),
      dep_z74 = coalesce(dep_z74, 0L),
      nbexh   = coalesce(nbexh, 0L)
    ) %>%
    # Séjours bloqués : journées au-delà de la borne haute ET attente d'aval SSR
    filter(nbexh > 0L, modesortie %in% modes_aval, destination == dest_ssr) %>%
    transmute(
      annee    = an,
      finessgeo = finessgeodp,
      ident,
      bb_jours = nbexh,
      # Profil = CMD × tranche d'âge × cognition/dépendance
      cmd      = substr(ghm2, 1, 2),
      age_band = case_when(age < 75 ~ "lt75", age < 85 ~ "75_84", TRUE ~ "ge85"),
      cognition = case_when(dem == 1L ~ "demence",
                            dep_z74 == 1L ~ "dependance",
                            TRUE ~ "aucune"),
      profil   = paste(cmd, age_band, cognition, sep = "|")
    ) %>%
    group_by(annee, finessgeo, profil) %>%
    summarise(
      BB_i   = sum(bb_jours),
      n_sej  = n_distinct(ident),
      .groups = "drop"
    ) %>%
    collect()
})

# Filtre des profils à effectif suffisant (stabilité)
distribution <- distribution %>%
  filter(n_sej >= seuil_sej_profil)

# ==== CALCUL MÉTHODOLOGIQUE — Gini sur la distribution des BB_i par profil ====
# G = (2 × Σᵢ i×BBᵢ) / (N × Σᵢ BBᵢ) − (N+1)/N   (BBᵢ triés croissants)
calcul_gini <- function(x) {
  x <- sort(x)
  n <- length(x)
  if (n < 2 || sum(x) == 0) return(NA_real_)
  (2 * sum(seq_len(n) * x)) / (n * sum(x)) - (n + 1) / n
}

# Part des journées portée par les k profils les plus chargés
part_top_k <- function(x, k) {
  x <- sort(x, decreasing = TRUE)
  if (sum(x) == 0) return(NA_real_)
  sum(x[seq_len(min(k, length(x)))]) / sum(x)
}

resultat <- distribution %>%
  group_by(annee, finessgeo) %>%
  summarise(
    K_profils  = n_distinct(profil),
    J_total    = sum(BB_i),
    G          = calcul_gini(BB_i),
    top3_part  = part_top_k(BB_i, 3),
    .groups    = "drop"
  ) %>%
  filter(K_profils >= seuil_profils)

# Jointure raison sociale
ref_rs <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  transmute(annee, finessgeo, rs) %>%
  collect()

resultat <- resultat %>%
  left_join(ref_rs, by = c("annee", "finessgeo")) %>%
  mutate(rs = coalesce(rs, finessgeo))

# ==== Courbe de Lorenz (dernière année) — lecture opérationnelle ====
lorenz <- distribution %>%
  group_by(annee, finessgeo) %>%
  arrange(BB_i, .by_group = TRUE) %>%
  mutate(
    rang_pct = row_number() / n(),
    cum_pct  = cumsum(BB_i) / sum(BB_i)
  ) %>%
  ungroup() %>%
  left_join(ref_rs, by = c("annee", "finessgeo")) %>%
  mutate(rs = coalesce(rs, finessgeo))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION 1 — série temporelle du Gini par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = G, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Concentration (Gini) des journées de bed-blocking par profil patient",
    subtitle = "0 = blocage diffus (action systémique) ; → 1 = blocage ciblable (dispositif dédié)",
    x = "Année", y = "Indice de Gini"
  )

# ==== VISUALISATION 2 — courbes de Lorenz (dernière année) ====
ggplot2::ggplot(
  dplyr::filter(lorenz, annee == max(annees)),
  aes(x = rang_pct, y = cum_pct, color = rs)
) +
  geom_line() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ reorder(rs, rs)) +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title = paste("Courbes de Lorenz des journées de bed-blocking —", max(annees)),
    x = "Part cumulée des profils (triés par charge croissante)",
    y = "Part cumulée des journées bloquées"
  )

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indice_concentration_journees_bb_profil_patient.csv")
# readr::write_csv(lorenz,   "indice_concentration_bb_lorenz_curves.csv")
