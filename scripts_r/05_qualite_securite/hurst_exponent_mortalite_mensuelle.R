# ==============================================================================
# Indicateur : Exposant de Hurst de la mortalité mensuelle ajustée
# Source     : custom (Hurst 1951, Peng 1994)
# Pattern    : §2 ratio_standardise (SMR mensuel) + calcul local H (DFA)
# Fiche      : indicateurs_pmsi/05_qualite_securite/hurst_exponent_mortalite_mensuelle.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — portail_atih_mco) ====
# Séjour (1 ligne)         : fixe.ident
# FINESS géographique      : finessgeo_umdudp.finessgeodp
# Raison sociale           : prd_vue_nomgen.finessgeo.rs
# GHM (6 car) / CMD        : fixe.ghm2 / substr(ghm2, 1, 2)
# Âge                      : fixe.age
# Mode sortie (décès = 9)  : fixe.modesortie
# Mode entrée              : fixe.modeentree
# Date sortie / mois / an  : fixe.date_sortie / fixe.mois / fixe.annee
# Lit palliatif (top)      : fixe.lit_palliatif
# Diagnostics (Charlson)   : diag.diag
# ==============================================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(pracma)        # hurstexp() (R/S)
library(nonlinearTseries) # dfa()

source("helpers_r/charlson_quan.R")

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees           <- 2019:2025
dep              <- "29"
fenetre_mois     <- 60        # 36 mini, 60 recommandé
methode_H        <- "dfa"     # "dfa" (recommandé) ou "rs"
desaisonnaliser  <- TRUE      # STL avant calcul de H
seuil_min_sejours_mois <- 100  # mois écarté si < seuil (instabilité du SMR)
exclure_cmd      <- c("28", "90")  # CMD séances + erreurs groupage
exclure_lit_palliatif <- TRUE       # top_palliatif retiré du périmètre

# ==== EXTRACTION : séjours mensuels avec décès et covariables ajustement ====
sejours <- purrr::map_dfr(annees, function(an) {

  tbl_fixe   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_diag   <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag")))
  tbl_geo    <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_finess <- tbl(conn, I(paste0("prd_vue_nomgen.finessgeo"))) %>%
    filter(annee == an, substr(finessgeo, 1, 2) == dep)

  charlson <- compute_charlson_quan(tbl_diag)

  tbl_fixe %>%
    filter(
      !substr(ghm2, 1, 2) %in% exclure_cmd,
      if (exclure_lit_palliatif) lit_palliatif == 0 else TRUE
    ) %>%
    inner_join(tbl_geo %>% select(ident, finessgeodp), by = "ident") %>%
    inner_join(tbl_finess %>% select(finessgeo, rs),
               by = c("finessgeodp" = "finessgeo")) %>%
    left_join(charlson, by = "ident") %>%
    transmute(
      ident,
      finessgeodp,
      rs,
      annee   = an,
      mois,
      cmd     = substr(ghm2, 1, 2),
      racine  = substr(ghm2, 1, 5),
      age,
      age_cl  = case_when(
        age < 40 ~ "1",
        age < 65 ~ "2",
        age < 80 ~ "3",
        TRUE     ~ "4"
      ),
      modeentree,
      charlson = coalesce(charlson, 0L),
      charlson_cl = case_when(
        charlson == 0 ~ "0",
        charlson <= 2 ~ "1-2",
        charlson <= 4 ~ "3-4",
        TRUE          ~ "5+"
      ),
      deces = if_else(modesortie == "9", 1L, 0L)
    ) %>%
    collect()
})

# ==== MODÈLE D'ATTENDU (logistique sur l'ensemble du panel — strate) ====
# Probabilité de décès attendue par strate (cmd × age_cl × charlson_cl × modeentree)
# Ajustement local — alternative : charger des coefs ATIH/ScanSanté pré-calibrés
modele_attendu <- sejours %>%
  group_by(cmd, age_cl, charlson_cl, modeentree) %>%
  summarise(
    n_strate    = n(),
    p_attendu   = sum(deces) / n(),
    .groups = "drop"
  )

sejours <- sejours %>%
  left_join(modele_attendu,
            by = c("cmd", "age_cl", "charlson_cl", "modeentree")) %>%
  mutate(p_attendu = coalesce(p_attendu, mean(deces)))

# ==== SMR MENSUEL PAR ÉTABLISSEMENT ====
smr_mensuel <- sejours %>%
  group_by(finessgeodp, rs, annee, mois) %>%
  summarise(
    n_sejours   = n_distinct(ident),
    O           = sum(deces),
    E           = sum(p_attendu),
    SMR         = if_else(E > 0, O / E, NA_real_),
    .groups = "drop"
  ) %>%
  filter(n_sejours >= seuil_min_sejours_mois) %>%
  arrange(finessgeodp, annee, mois) %>%
  group_by(finessgeodp) %>%
  mutate(t = row_number()) %>%
  ungroup()

# ==== CALCUL DE L'EXPOSANT DE HURST ====
calcul_hurst <- function(serie, methode = "dfa") {
  s <- serie[!is.na(serie)]
  if (length(s) < 24) return(tibble(H = NA_real_, n_obs = length(s)))
  if (desaisonnaliser && length(s) >= 24) {
    ts_obj <- ts(s, frequency = 12)
    s <- as.numeric(stats::stl(ts_obj, s.window = "periodic")$time.series[, "remainder"])
    s <- s + mean(serie, na.rm = TRUE)  # recentrer pour DFA
  }
  H <- tryCatch({
    if (methode == "dfa") {
      fit <- nonlinearTseries::dfa(time.series = s,
                                   window.size.range = c(4, floor(length(s) / 4)),
                                   do.plot = FALSE)
      nonlinearTseries::estimate(fit, do.plot = FALSE)
    } else {
      pracma::hurstexp(s, display = FALSE)$Hs   # R/S corrigé
    }
  }, error = function(e) NA_real_)
  tibble(H = H, n_obs = length(s))
}

resultat <- smr_mensuel %>%
  group_by(finessgeodp, rs) %>%
  summarise(
    serie = list(SMR),
    n_mois = n(),
    SMR_moyen = mean(SMR, na.rm = TRUE),
    SMR_sd    = sd(SMR, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n_mois >= fenetre_mois) %>%
  mutate(hurst = purrr::map(serie, ~ calcul_hurst(.x, methode = methode_H))) %>%
  tidyr::unnest(hurst) %>%
  select(-serie) %>%
  mutate(
    classe_H = case_when(
      is.na(H)        ~ NA_character_,
      H < 0.60        ~ "nominal",
      H < 0.70        ~ "vigilance",
      TRUE            ~ "alerte"
    )
  )

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION 1 : H par établissement ====
ggplot2::ggplot(resultat, aes(x = reorder(rs, H), y = H, fill = classe_H)) +
  geom_col() +
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  geom_hline(yintercept = 0.7, linetype = "dotted") +
  coord_flip() +
  scale_fill_manual(values = c(nominal = "grey60",
                               vigilance = "orange",
                               alerte = "firebrick")) +
  labs(x = NULL, y = "Exposant de Hurst H",
       title = "Persistance de la mortalité mensuelle ajustée",
       subtitle = paste0("Méthode : ", methode_H,
                         " — fenêtre : ", fenetre_mois, " mois")) +
  theme_minimal()

# ==== VISUALISATION 2 : séries SMR mensuelles ====
ggplot2::ggplot(smr_mensuel, aes(x = annee + (mois - 1)/12, y = SMR, color = rs)) +
  geom_smooth(se = FALSE, method = "loess", span = 0.3) +
  geom_point(alpha = 0.4, size = 0.8) +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  geom_hline(yintercept = 1, linetype = "dashed") +
  scale_x_continuous(breaks = annees) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_hurst_mortalite_mensuelle.csv")
