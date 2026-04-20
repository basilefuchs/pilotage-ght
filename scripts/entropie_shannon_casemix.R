library(dplyr)


# Paramètres
annees <- 2016:2025
dep <- "29"

# Connexion
conn <- pRatihque::connection_database()


# Référentiels
ref_finessgeo <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(
    substr(finessgeo, 1, 2) == dep,
    annee %in% annees
  ) %>%
  select(annee, finessgeo, rs) %>%
  distinct() %>%
  collect() %>%
  group_by(annee, finessgeo) %>%
  summarise(
    rs = first(rs),
    .groups = "drop"
  )

nb_code_par_annee <- tbl(conn, I("prd_vue_nompmsi.all_classif_pmsi")) %>%
  mutate(annee = year(date_deb)) %>%
  filter(annee %in% annees) %>%
  distinct(annee, champ, type_code, code) %>%
  collect() %>%
  group_by(annee, champ, type_code) %>%
  summarise(N_TOTAL_CODE = n_distinct(code)) %>%
  distinct()


# Activité
## MCO
mco <- purrr::map_dfr(annees, function(an) {
  
  fixe_tbl <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  geo_tbl  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  
  fixe_tbl %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(finess, 1, 2) == dep
    ) %>%
    inner_join(
      geo_tbl %>% 
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    transmute(
      finessgeo = finessgeodp,
      ident,
      code = substr(ghm2, 1, 5),
      annee = an
    ) %>%
    group_by(annee, finessgeo, code) %>%
    summarise(
      N_i = n_distinct(ident),
      .groups = "drop"
    ) %>%
    collect()
})

## SMR
smr <- purrr::map_dfr(annees, function(an) {
  
  fixe_tbl <- tbl(conn, I(paste0("prd_vue_smr_", an, ".fixe")))
  
  fixe_tbl %>%
    filter(
      substr(gme, 1, 2) != "90",
      substr(finessgeo, 1, 2) == dep
    ) %>%
    transmute(
      finessgeo,
      ident_sej,
      code = substr(gme, 1, 4),
      annee = an
    ) %>%
    group_by(annee, finessgeo, code) %>%
    summarise(
      N_i = n_distinct(ident_sej),
      .groups = "drop"
    ) %>%
    collect()
})


# Entropie
calcul_entropie <- function(df, x) {
    
  df <- df %>%
  inner_join(ref_finessgeo, by = c("finessgeo", "annee")) %>%
  inner_join(
    nb_code_par_annee %>% 
    filter(type_code == x),
    by = "annee"
  ) %>%
  group_by(annee, finessgeo, rs) %>%
  summarise(
    N_total = sum(N_i),
    N_code = n_distinct(code),
    H = -sum((N_i / sum(N_i)) * log2(N_i / sum(N_i))),
    H_max = log2(N_TOTAL_CODE),
    H_norm = H / H_max,
    .groups = "drop"
  ) %>%
  distinct() %>%
  mutate(rs = factor(rs, levels = sort(unique(rs))))
  
  return(df)

}


# Visualisation
library(ggplot2)

df <- calcul_entropie(mco, "racine")
# df <- calcul_entropie(smr, "gn")

ggplot(df, aes(x = annee, y = H_norm, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(legend.position = "none")