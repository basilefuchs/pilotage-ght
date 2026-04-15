library(dplyr)
library(purrr)
library(ggplot2)

# Paramètres
annees <- 2016:2025
dep <- "29"

# Table de référence
ref_finess <- tbl(conn, I("prd_vue_nomgen.finess")) %>%
  filter(
    substr(finess, 1, 2) == dep,
    mco == "1" # Filtre les établissements MCO
  ) %>%
  select(annee, finess, rs) %>%
  distinct() %>%
  collect() %>%
  filter(!grepl("dialyse", rs, ignore.case = TRUE))

# nb_rghm_par_annee <- tbl(conn, "thesaurus_ghm") %>%
#   group_by(annee) %>%
#   summarise(GHM_TOTAL = n_distinct(ghm)) %>%
#   collect()

# Boucle principale MCO
df <- map_df(annees, function(an) {
  
  nom_table <- paste0("prd_vue_mco_", an, ".fixe")
  
  tbl(conn, I(nom_table)) %>%
    filter(substr(ghm2, 1, 2) != "90",
           substr(finess, 1, 2) == dep) %>%
    mutate(
      annee = an,
      rghm = substr(ghm2, 1, 5)
    ) %>%
    group_by(annee, finess, rghm) %>%
    summarise(N_i = n_distinct(ident), .groups = "drop") %>%
    collect()
})

# Calcul de l'entropie
result <- df %>%
  inner_join(ref_finess, by = c("finess", "annee")) %>% # Jointure avec le référentiel des FINESS
  left_join(nb_rghm_par_annee, by = "annee") %>%  # Jointure avec le nombre de GHM par année
  group_by(annee, finess) %>%
  filter(sum(N_i) > 0) %>%
  summarise(
    rs = first(rs), # Sélectionne la première valeur de raison sociale en cas de doublon
    N_total = sum(N_i),
    N_GHM = n_distinct(rghm),
    H = -sum((N_i / sum(N_i)) * log2(N_i / sum(N_i))),
    H_max = log2(GHM_TOTAL),  # Utilise le nombre de GHM total pour l'année
    H_norm = H / H_max,
    .groups = "drop"
  )

# Filtre le top 10 des établissements sur la période
top_finess <- result %>%
  group_by(finess) %>%
  summarise(total = sum(N_total), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 10) %>%
  pull(finess)

df_plot <- result %>%
  filter(finess %in% top_finess)

# Tri décroissant des établissements sur la période
ordre_rs <- df_plot %>%
  group_by(rs) %>%
  summarise(total = sum(N_total), .groups = "drop") %>%
  arrange(desc(total)) %>%
  pull(rs)

df_plot <- df_plot %>%
  mutate(rs = factor(rs, levels = ordre_rs))

# Tracé des tendances avec lissage et facettes
ggplot(df_plot, aes(x = annee, y = H_norm, color = rs)) +
  geom_smooth(se = FALSE) +
  geom_point() +
  facet_wrap(~ rs, scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  theme_minimal() +
  theme(legend.position = "none")