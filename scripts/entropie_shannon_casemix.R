library(dplyr)
library(purrr)
library(ggplot2)

# Paramètres
annees <- 2016:2025
dep <- "29"

# Connexion
conn <- pRatihque::connection_database()

# MCO

## Référentiels
ref_finessgeo_mco <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(
    substr(finessgeo, 1, 2) == dep,
    mco == "O"
  ) %>%
  select(annee, finessgeo, rs) %>%
  distinct() %>%
  collect() %>%
  filter(!grepl("dialyse|udm|rein", rs, ignore.case = TRUE)) %>%
  group_by(annee, finessgeo) %>%
  summarise(
    rs = first(rs),
    .groups = "drop"
  )

nb_rghm_par_annee <- tbl(conn, I("prd_vue_nompmsi.all_classif_pmsi")) %>%
  filter(
    champ == "mco",
    type_code == "racine"
  ) %>%
  mutate(annee = year(date_deb)) %>%
  distinct(annee, code) %>%
  collect() %>%
  group_by(annee) %>%
  summarise(GHM_TOTAL = n_distinct(code)) %>%
  distinct()

## Activité
df <- map_dfr(annees, function(an) {
  
  fixe_tbl <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  geo_tbl  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  
  fixe_tbl %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      geo_tbl %>% select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      finessgeo = finessgeodp,
      ident,
      rghm = substr(ghm2, 1, 5),
      annee = !!an
    ) %>%
    group_by(annee, finessgeo, rghm) %>%
    summarise(
      N_i = n_distinct(ident),
      .groups = "drop"
    ) %>%
    collect()
})

## Entropie
entropie_mco <- df %>%
  inner_join(ref_finessgeo_mco, by = c("finessgeo", "annee")) %>%
  left_join(nb_rghm_par_annee, by = "annee") %>%  
  group_by(annee, finessgeo) %>%
  summarise(
    rs = rs,
    N_total = sum(N_i),
    N_GHM = n_distinct(rghm),
    H = -sum((N_i / sum(N_i)) * log2(N_i / sum(N_i))),
    H_max = log2(GHM_TOTAL),
    H_norm = H / H_max,
    .groups = "drop"
  ) %>%
  distinct()

# SMR

## Référentiels
ref_finessgeo_smr <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(
    substr(finessgeo, 1, 2) == dep,
    ssr == "O"
  ) %>%
  distinct(annee, finessgeo, rs) %>%
  collect() %>%
  filter(!grepl("dialyse|udm|rein", rs, ignore.case = TRUE)) %>%
  group_by(annee, finessgeo) %>%
  summarise(
    rs = first(rs),
    .groups = "drop"
  )

nb_gn_par_annee <- tbl(conn, I("prd_vue_nompmsi.all_classif_pmsi")) %>%
  filter(
    champ == "ssr",
    type_code == "gn"
  ) %>%
  mutate(annee = year(date_deb)) %>%
  distinct(annee, code) %>%
  collect() %>%
  group_by(annee) %>%
  summarise(GN_TOTAL = n_distinct(code)) %>%
  distinct()

## Activité
df <- map_dfr(annees, function(an) {
  
  fixe_tbl <- tbl(conn, I(paste0("prd_vue_smr_", an, ".fixe")))
  
  fixe_tbl %>%
    filter(
      substr(gme, 1, 2) != "90",
      substr(finessgeo, 1, 2) == dep
    ) %>%
    transmute(
      finessgeo,
      ident_sej,
      gn = substr(gme, 1, 4),
      annee = !!an
    ) %>%
    group_by(annee, finessgeo, gn) %>%
    summarise(
      N_i = n_distinct(ident_sej),
      .groups = "drop"
    ) %>%
    collect()
})

## Entropie
entropie_smr <- df %>%
  inner_join(ref_finessgeo_smr, by = c("finessgeo", "annee")) %>%
  left_join(nb_gn_par_annee, by = "annee") %>%
  group_by(annee, finessgeo) %>%
  summarise(
    rs = rs,
    N_total = sum(N_i),
    N_GHM = n_distinct(gn),
    H = -sum((N_i / sum(N_i)) * log2(N_i / sum(N_i))),
    H_max = log2(GN_TOTAL),
    H_norm = H / H_max,
    .groups = "drop"
  ) %>%
  distinct()

# Visualisation
df_plot <- entropie_mco %>%
  mutate(rs = factor(rs, levels = sort(unique(rs))))

ggplot(df_plot, aes(x = annee, y = H_norm, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none")