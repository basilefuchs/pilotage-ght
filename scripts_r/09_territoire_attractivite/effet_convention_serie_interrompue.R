# ==============================================================================
# Indicateur : Effet d'une Convention Inter-Établissements (série interrompue)
# Source     : régression segmentée ITS (Bernal 2017, PMID:27283160)
# Pattern    : §5 parcours_sequentiel (flux mensuel dyade) + régression segmentée locale
# Fiche      : indicateurs_pmsi/09_territoire_attractivite/effet_convention_serie_interrompue.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base    : Portail ATIH (Teradata via dbplyr)
# Schéma  : prd_vue_mco_AAAA
#
# Séjour (1 ligne)            : fixe.ident
# Patient chaîné (national)   : fixe.anonyme
# GHM / CMD                   : substr(fixe.ghm2, 1, 5) / substr(fixe.ghm2, 1, 2)
# Dates entrée / sortie       : fixe.date_entree / fixe.date_sortie
# Actes CCAM                  : acte.acte, clé ident
# FINESS géographique du DP   : finessgeo_umdudp.finessgeodp
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(tidyr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees   <- 2019:2025  # dates réelles indisponibles avant 2019 (dico ATIH)
finess_A <- c("<TODO: FINESS géographiques de l'établissement adresseur A>")
finess_B <- c("<TODO: FINESS géographiques de l'établissement de recours B>")

# Périmètre conventionné (partagé avec taux_adressage_preferentiel_convention.R)
perim_ghm  <- c("<TODO: racines de GHM (5 car) du périmètre conventionné>")
perim_ccam <- c("<TODO: actes CCAM (7 car) du périmètre conventionné>")

t0 <- as.Date("<TODO: date de mise en œuvre effective de la convention (pas la signature)>")

fenetre_jours <- 90      # fenêtre contact A → séjour périmètre à B
exclure_mois_t0 <- TRUE  # exclure le mois de transition de l'estimation

# Recommandations fiche : ≥ 24 mois pré-t0 et ≥ 12 mois post-t0 ;
# < 10 parcours/mois → agréger en trimestres ou allonger la série.

# ==== EXTRACTION : adressages mensuels A → B du périmètre conventionné ====
contacts_a <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  tbl_fixe %>%
    filter(
      substr(ghm2, 1, 2) != "90",
      substr(ghm2, 1, 2) != "28"
    ) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% finess_A) %>%
    transmute(anonyme, date_sortie_a = date_sortie) %>%
    collect()
})

sejours_b <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_geo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
  tbl_acte <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))

  ident_ccam <- tbl_acte %>%
    # acte = CCAM + phase (8 car, dico ATIH) : matcher sur 7 car
    filter(substr(acte, 1, 7) %in% perim_ccam) %>%
    distinct(ident) %>%
    transmute(ident, a_acte = 1L)

  tbl_fixe %>%
    filter(substr(ghm2, 1, 2) != "90") %>%
    left_join(ident_ccam, by = "ident") %>%
    filter(substr(ghm2, 1, 5) %in% perim_ghm | a_acte == 1L) %>%
    inner_join(
      tbl_geo %>%
      select(ident, finessgeodp),
      by = "ident"
    ) %>%
    filter(finessgeodp %in% finess_B) %>%
    transmute(anonyme, ident, date_entree_b = date_entree) %>%
    collect()
})

adressages <- sejours_b %>%
  filter(!is.na(anonyme)) %>%
  inner_join(contacts_a, by = "anonyme") %>%
  mutate(delai = as.numeric(date_entree_b - date_sortie_a)) %>%
  filter(delai >= 0, delai <= fenetre_jours) %>%
  distinct(ident, .keep_all = TRUE)

# ==== CALCUL : série mensuelle puis régression segmentée quasi-Poisson ====
serie <- adressages %>%
  mutate(mois = as.Date(format(date_entree_b, "%Y-%m-01"))) %>%
  count(mois, name = "Y") %>%
  tidyr::complete(
    mois = seq.Date(min(mois), max(mois), by = "month"),
    fill = list(Y = 0L)
  ) %>%
  arrange(mois) %>%
  mutate(
    t      = row_number(),
    post   = as.integer(mois >= t0),
    t_post = if_else(post == 1L, t - min(t[post == 1L]), 0),
    sin12  = sin(2 * pi * t / 12),
    cos12  = cos(2 * pi * t / 12)
  )

serie_estim <- if (exclure_mois_t0) {
  serie %>% filter(format(mois, "%Y-%m") != format(t0, "%Y-%m"))
} else {
  serie
}

# Y_t = β0 + β1·t + β2·post + β3·(t − t0)·post + saisonnalité
# β2 : changement de niveau (marche) ; β3 : changement de pente (montée en charge)
modele <- glm(Y ~ t + post + t_post + sin12 + cos12,
              family = quasipoisson, data = serie_estim)

summary(modele)
exp(cbind(RR = coef(modele), confint(modele)))[c("post", "t_post"), ]

# Vérification de l'autocorrélation résiduelle (si marquée : erreurs
# Newey-West via sandwich::NeweyWest, ou modèle ARMA sur résidus)
acf(residuals(modele, type = "deviance"))

# Contrefactuel : trajectoire prédite sans convention (post = 0)
serie <- serie %>%
  mutate(
    pred  = predict(modele, newdata = serie, type = "response"),
    contrefactuel = predict(modele,
                            newdata = serie %>% mutate(post = 0L, t_post = 0),
                            type = "response")
  )

effet_cumule <- serie %>%
  filter(post == 1L) %>%
  summarise(parcours_attribuables = sum(pred - contrefactuel))

# <TODO: dyade témoin (ITS contrôlée) — répliquer l'extraction en remplaçant
# finess_B par un établissement comparable non concerné par la convention,
# puis modèle joint avec interaction série × groupe (cf. fiche)>

# ==== RÉSULTAT ====
print(serie)
print(effet_cumule)

# ==== VISUALISATION ====
ggplot(serie, aes(x = mois)) +
  geom_point(aes(y = Y), color = "grey40") +
  geom_line(aes(y = pred), color = "#2166ac", linewidth = 0.8) +
  geom_line(aes(y = contrefactuel), color = "#b2182b", linetype = "dashed") +
  geom_vline(xintercept = t0, linetype = "dotted") +
  scale_y_continuous(limits = c(0, NA)) +
  labs(title = "Adressages mensuels A → B : observé, ajusté, contrefactuel",
       subtitle = "pointillé rouge = trajectoire estimée sans convention ; vertical = t0",
       y = "Adressages / mois", x = NULL) +
  theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(serie, "effet_convention_serie_interrompue.csv")
