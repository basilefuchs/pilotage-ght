library(dplyr)
library(purrr)
library(ggplot2)

# paramètres
annees <- 2016:2025
dep <- "29"

# table de référence
ref_finess <- tbl(conn, I("prd_vue_nomgen.finess")) %>%
  filter(
    substr(finess, 1, 2) == dep,
    mco == "1" # filtre ets MCO
  ) %>%
  select(annee, finess, rs) %>%
  distinct() %>%
  collect() %>%
  filter(!grepl("dialyse", rs, ignore.case = TRUE))

# boucle principale MCO
df <- map_df(annees, function(an) {
  
  nom_table <- paste0("prd_vue_mco_", an, ".fixe")
  
  tbl(conn, I(nom_table)) %>%
    filter(substr(ghm2, 1, 2) != "90",
           substr(finess, 1, 2) == dep) %>%
    mutate(
      annee = an,
      ghm_racine = substr(ghm2, 1, 5)
    ) %>%
    group_by(annee, finess, ghm_racine) %>%
    summarise(N_i = n_distinct(ident), .groups = "drop") %>%
    # filter(N_i > 10) %>%
    collect()
})

# calcul final
result <- df %>%
  inner_join(ref_finess, by = c("finess","annee")) %>%
  group_by(annee, finess) %>%
  summarise(
    rs = first(rs),
    N_total = sum(N_i),
    N_GHM = n_distinct(ghm_racine),
    H = -sum(ifelse((N_i / sum(N_i)) > 0,
                    (N_i / sum(N_i)) * log2(N_i / sum(N_i)), 0)),
    H_max = log2(n_distinct(ghm_racine)),
    H_norm = ifelse(H_max > 0, H / H_max, NA_real_),
    .groups = "drop"
  )

# filtre ets top 10 volumétrie sur la période
top_finess <- result %>%
  group_by(finess) %>%
  summarise(total = sum(N_total), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 10) %>%
  pull(finess)

df_plot <- result %>%
  filter(finess %in% top_finess)

# tri décroissant des ets par volumétrie sur la période
ordre_rs <- df_plot %>%
  group_by(rs) %>%
  summarise(total = sum(N_total), .groups = "drop") %>%
  arrange(desc(total)) %>%
  pull(rs)

df_plot <- df_plot %>%
  mutate(rs = factor(rs, levels = ordre_rs))

# plot
ggplot(df_plot, aes(x = annee, y = H_norm, color = rs)) +
  geom_smooth(se = FALSE) +
  geom_point() +
  facet_wrap(~ rs, scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  theme_minimal() +
  theme(legend.position = "none")