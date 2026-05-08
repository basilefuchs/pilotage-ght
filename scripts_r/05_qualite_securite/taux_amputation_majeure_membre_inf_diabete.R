# ==============================================================================
# Indicateur : Taux d'amputation majeure MI chez patient diabétique (pour 100 000 hab.)
# Source     : OCDE HCQO long-term diabetes complications
# Pattern    : §1 — taux populationnel (numérateur PMSI / dénominateur INSEE)
# Fiche      : indicateurs_pmsi/05_qualite_securite/taux_amputation_majeure_membre_inf_diabete.md
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Base : portail_atih_mco
# Séjour (1 ligne)        : prd_vue_mco_AAAA.fixe.ident
# Âge / Sexe              : fixe.age / fixe.sexe
# GHM                     : fixe.ghm2
# Code géo PMSI patient   : fixe.codegeo
# Diag associés (DA)      : diag.diag
# Actes CCAM              : acte.acte
# IPP chaîné inter-séjours: id_hospit_ipp.ipp_c
# FINESS géo (DP)         : finessgeo_umdudp.finessgeodp
# Pop INSEE (commune)     : nom_gen.pop_com_sex_ag (code_com, annee_pop, age, sexe, pop)
# Correspondance commune  : nom_gen.corresp_code_com_geo_ts_pop (code_com ↔ code_geo)
# RS établissement        : prd_vue_nomgen.finessgeo.rs
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees      <- 2016:2025
dep         <- "29"
age_min     <- 15L
seuil_min   <- 30L            # robustesse minimale par établissement
fenetre_diab <- 2L            # antériorité diabète : 24 mois glissants

# Codes CCAM amputation MAJEURE (au-dessus de la cheville, déf. OCDE)
ccam_amputation_majeure <- c(
  "NZFA004",  # amputation transtibiale (jambe)
  "NZFA006",  # désarticulation du genou
  "NZFA008",  # amputation transfémorale (cuisse)
  "NZFA00A"   # désarticulation de hanche
)
# <TODO: confirmer la liste CCAM (DIM/SOFCOT), notamment NZFA00A>

# Codes CIM-10 diabète (E10–E14)
diab_prefix <- c("E10", "E11", "E12", "E13", "E14")

# Population européenne standard ESP2013 (≥15 ans, classes OCDE)
esp2013 <- tibble::tribble(
  ~classe,  ~poids,
  "15-44",  35000,
  "45-64",  25500,
  "65-74",  13000,
  "75-84",   9500,
  "85+",     5000
)
# <TODO: vérifier les poids ESP2013 contre la table Eurostat 2013 officielle>

classe_age <- function(a) {
  cut(a, breaks = c(15, 45, 65, 75, 85, Inf),
      right = FALSE, labels = c("15-44", "45-64", "65-74", "75-84", "85+"))
}

# ==== EXTRACTION : numérateur ====
# Pour chaque année an : amputations majeures chez patients ayant eu un dia-
# gnostic E10-E14 dans an-2..an (fenêtre glissante 24 mois via chaînage ipp_c)
numerateur <- purrr::map_dfr(annees, function(an) {

  tbl_fixe       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
  tbl_acte       <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte")))
  tbl_ipp        <- tbl(conn, I(paste0("prd_vue_mco_", an, ".id_hospit_ipp")))
  tbl_finessgeo  <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))

  # Pool diabète : ipp_c ayant eu E10-E14 dans an-2..an (lazy union_all)
  annees_diab <- seq(an - fenetre_diab, an)
  annees_diab <- annees_diab[annees_diab >= min(annees)]

  diab_pool <- purrr::reduce(annees_diab, function(acc, a) {
    diab_a <- tbl(conn, I(paste0("prd_vue_mco_", a, ".diag"))) %>%
      filter(substr(diag, 1, 3) %in% diab_prefix) %>%
      inner_join(
        tbl(conn, I(paste0("prd_vue_mco_", a, ".id_hospit_ipp"))) %>%
          select(ident, ipp_c),
        by = "ident"
      ) %>%
      distinct(ipp_c)
    if (is.null(acc)) diab_a else union_all(acc, diab_a)
  }, .init = NULL) %>% distinct(ipp_c)

  # Séjours adultes avec amputation majeure
  sej_amput <- tbl_fixe %>%
    filter(age >= age_min, substr(ghm2, 1, 2) != "90") %>%
    select(ident, age, sexe, codegeo) %>%
    inner_join(
      tbl_acte %>% filter(acte %in% ccam_amputation_majeure) %>% distinct(ident),
      by = "ident"
    )

  # Filtre antécédent diabète + finess géo + IPP, dédoublonnage 1 patient/an
  sej_amput %>%
    inner_join(tbl_ipp %>% select(ident, ipp_c), by = "ident") %>%
    semi_join(diab_pool, by = "ipp_c") %>%
    inner_join(tbl_finessgeo %>% select(ident, finessgeodp), by = "ident") %>%
    transmute(ipp_c, finessgeodp, age, sexe, codegeo, annee = an) %>%
    distinct(annee, ipp_c, .keep_all = TRUE) %>%
    collect()
})

# ==== EXTRACTION : dénominateur (population INSEE par âge × sexe, agrégée dep) ====
pop <- purrr::map_dfr(annees, function(an) {

  tbl_pop     <- tbl(conn, I("nom_gen.pop_com_sex_ag"))
  tbl_corresp <- tbl(conn, I("nom_gen.corresp_code_com_geo_ts_pop"))

  tbl_pop %>%
    filter(annee_pop == an, age >= age_min) %>%
    inner_join(tbl_corresp %>% select(code_com, code_geo), by = "code_com") %>%
    filter(substr(code_geo, 1, 2) == dep) %>%
    group_by(age, sexe) %>%
    summarise(pop = sum(pop, na.rm = TRUE), .groups = "drop") %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL ====
# Numérateur par finessgeo × classe d'âge
num <- numerateur %>%
  mutate(classe = classe_age(age)) %>%
  filter(!is.na(classe)) %>%
  count(annee, finessgeodp, classe, sexe, name = "N")

# Dénominateur département × classe d'âge (partagé entre établissements)
den <- pop %>%
  mutate(classe = classe_age(age)) %>%
  filter(!is.na(classe)) %>%
  group_by(annee, classe, sexe) %>%
  summarise(pop = sum(pop, na.rm = TRUE), .groups = "drop")

# Standardisation directe ESP2013 par finessgeo
taux <- num %>%
  inner_join(den, by = c("annee", "classe", "sexe")) %>%
  inner_join(esp2013, by = "classe") %>%
  group_by(annee, finessgeodp) %>%
  summarise(
    N_total      = sum(N),
    taux_brut    = sum(N) / sum(pop) * 1e5,
    taux_std_esp = sum((N / pop) * poids, na.rm = TRUE) / sum(poids) * 1e5,
    .groups      = "drop"
  ) %>%
  filter(N_total >= seuil_min)

# Jointure raison sociale
ref_finess <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
  filter(substr(finessgeo, 1, 2) == dep) %>%
  select(annee, finessgeo, rs) %>%
  collect()

resultat <- taux %>%
  inner_join(ref_finess, by = c("annee", "finessgeodp" = "finessgeo"))

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
ggplot(resultat, aes(x = annee, y = taux_std_esp, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA)) +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Amputation majeure MI / diabétiques — taux ESP2013 / 100 000 hab. dep",
       y = "Taux standardisé / 100 000", x = NULL)

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "taux_amputation_majeure_diabete.csv")
