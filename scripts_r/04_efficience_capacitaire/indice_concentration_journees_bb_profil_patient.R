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
# Sévérité                   : substr(fixe.ghm2, 5, 5)
# Journées > borne haute: fixe.nbexh  (journées de bed-blocking)
# DAS (CIM-10)          : diag.diag  (démence F00-F03/G30 ; dépendance Z74)
# Facteurs socio-économiques   : prd_vue_nompmsi.all_cim10_caract_patient (code, caract)
# FINESS géographique   : finessgeo_umdudp.finessgeodp
# Raison sociale (RS)   : prd_vue_nomgen.finessgeo (annee, finessgeo, rs)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees     <- 2019:2025
dep        <- "29"
modes_aval <- c("6", "7")
seuil_sej_profil <- 20      # séjours bloqués minimum pour qu'un profil compte
seuil_profils    <- 5       # nb minimum de profils pour calculer un Gini stable

tbl_socio_eco <- tbl(conn, I(paste0("prd_vue_nompmsi.all_cim10_caract_patient"))) |>
  filter(type_liste == "Socio_eco") |>
  select(code, caract)

# ==== EXTRACTION — journées de bed-blocking par profil patient ====
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_diag <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))

  tbl_fixe <- tbl_fixe |>
    filter(
      ano_retour == "000000000",
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) %in% dep,
      modesortie %in% modes_aval,
      nbexh > 0
    )

  flag_dem <- tbl_fixe |>
    inner_join(tbl_diag, by = "ident") |>
    filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30|A810|B220).*', 'c') = 1")) |>
    distinct(ident) |> mutate(demence = 1)

  flag_socio_eco <- tbl_fixe |>
    inner_join(tbl_diag, by = "ident") |>
    inner_join(tbl_socio_eco, by = c("diag" = "code")) |>
    distinct(ident) |> mutate(fse = 1)

  tbl_fixe <- tbl_fixe |>
    inner_join(tbl_geo |> select(ident, finessgeodp), by = "ident") |>
    left_join(flag_dem, by = "ident") |>
    left_join(flag_socio_eco, by = "ident") |>
    transmute(
      annee    = an,
      finessgeo = finessgeodp,
      ident,
      bb_jours = nbexh,
      sev      = case_when(
        substr(ghm2, 5, 5) %in% c("3","4") ~ "severite",
        TRUE ~ "absence severite"
      ),
      age_band = case_when(
        age < 75  ~ "< 75 ans",
        age < 85 ~ "75-84 ans",
        TRUE ~ "> 85 ans"
      ),
      demence = case_when(
        demence == 1 ~ "demence",
        TRUE ~ "absence demence"
      ),
      fse = case_when(
        fse == 1 ~ "fse",
        TRUE ~ "absence fse"
      ),
      # Profil = Sévérité × tranche d'âge × démence x fse
      profil   = paste(
        sev,
        age_band,
        demence,
        fse,
        sep = " | "
      )
    ) |>
    group_by(annee, finessgeo, profil) |>
    summarise(
      BB_i   = sum(bb_jours),
      n_sej  = n_distinct(ident),
      .groups = "drop"
    ) |>
    collect()
})

# Filtre des profils à effectif suffisant (stabilité)
distribution <- distribution |>
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

resultat <- distribution |>
  group_by(annee, finessgeo) |>
  summarise(
    K_profils  = n_distinct(profil),
    J_total    = sum(BB_i),
    G          = calcul_gini(BB_i),
    top3_part  = part_top_k(BB_i, 3),
    .groups    = "drop"
  ) |>
  filter(K_profils >= seuil_profils)

# Jointure raison sociale
ref_rs <- tbl(conn, I("prd_vue_nomgen.finessgeo")) |>
  filter(substr(finessgeo, 1, 2) %in% dep) |>
  select(annee, finessgeo, rs) |>
  collect()

resultat <- resultat |>
  left_join(ref_rs, by = c("annee", "finessgeo")) |>
  mutate(rs = coalesce(rs, finessgeo))

# ==== Courbe de Lorenz (dernière année) — lecture opérationnelle ====
lorenz <- distribution |>
  group_by(annee, finessgeo) |>
  arrange(BB_i, .by_group = TRUE) |>
  mutate(
    rang_pct = row_number() / n(),
    cum_pct  = cumsum(BB_i) / sum(BB_i)
  ) |>
  ungroup() |>
  left_join(ref_rs, by = c("annee", "finessgeo")) |>
  mutate(rs = coalesce(rs, finessgeo))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION 1 — série temporelle du Gini par établissement ====
ggplot2::ggplot(resultat, aes(x = annee, y = G, color = rs)) +
  geom_smooth(method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(
    title    = "Concentration (Gini) des journées de bed-blocking par profil patient",
    subtitle = "0 = blocage diffus (action systémique) ; → 1 = blocage ciblé (dispositif dédié)",
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
