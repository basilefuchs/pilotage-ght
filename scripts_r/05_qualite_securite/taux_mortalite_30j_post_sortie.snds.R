# ==============================================================================
# Indicateur : Taux de Mortalité à 30 Jours Post-Sortie
# Source     : custom (chaînage PMSI-SNDS, décès toutes causes IR_BEN_R)
# Pattern    : §1 taux — numérateur/dénominateur sur sorties vivantes
# Catégorie  : 05_qualite_securite
# Fiche      : indicateurs_pmsi/05_qualite_securite/taux_mortalite_30j_post_sortie.md
# Base       : SNDS (portail CNAM) — PAS le portail ATIH
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# Profil snds_mco — réutilisable en tête des prochains prompts
#
# Base                    : SNDS Oracle, tables annuelles T_MCOaaX (aa = millésime 2 chiffres)
# Connexion               : ROracle::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")
# Séjour RSA (1 ligne)    : T_MCOaaB, clé (ETA_NUM, RSA_NUM)
# Mode de sortie          : T_MCOaaB.SOR_MOD        ('9' = décès intra-hospitalier)
# GHM (GENRSA)            : T_MCOaaB.GRG_GHM        (CMD = substr(GRG_GHM, 1, 2))
# FINESS                  : T_MCOaaB.ETA_NUM
# Date de sortie          : T_MCOaaC.EXE_SOI_DTF
# Patient pseudonymisé    : T_MCOaaC.NIR_ANO_17     (= IR_BEN_R.BEN_NIR_PSA)
# Qualité chaînage        : T_MCOaaC.{NIR,NAI,SEX,SEJ,FHO,PMS,DAT}_RET tous = '0'
# Date de décès           : IR_BEN_R.BEN_DCD_DTE    (toutes causes ; défaut 01/01/0001 si invalide)
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- ROracle::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")

# ==== PARAMÈTRES ====
annees       <- 2016:2024  # N-1 souvent incomplet : un suivi 30j des sorties de
                           # décembre N requiert la consolidation de janvier N+1
dep          <- "29"       # Finistère (filtre FINESS ETA_NUM)
delai_jours  <- 30L        # fenêtre de mortalité post-sortie (fiche : 30 j)
seuil_min    <- 30L        # robustesse : ≥30 sorties/an par établissement
# FINESS juridiques doublonnés AP-HP / AP-HM / HCL (doublons des FINESS géo)
finess_doublons <- c("750712184", "130780521", "690783154")

# ==== RÉFÉRENTIEL DÉCÈS — une date par bénéficiaire (toutes causes) ====
# IR_BEN_R peut porter plusieurs lignes par bénéficiaire : on déduplique en
# prenant la date de décès minimale valide (les dates invalides sont au 01/01/0001)
tbl_deces <- tbl(conn, "IR_BEN_R") %>%
  filter(!is.na(BEN_DCD_DTE), BEN_DCD_DTE > to_date("1900-01-01", "YYYY-MM-DD")) %>%
  group_by(BEN_NIR_PSA) %>%
  summarise(date_deces = min(BEN_DCD_DTE, na.rm = TRUE), .groups = "drop")

# ==== EXTRACTION — sorties vivantes chaînées × décès ≤ 30 j ====
resultat <- purrr::map_dfr(annees, function(an) {

  aa    <- substr(as.character(an), 3, 4)
  tbl_b <- tbl(conn, paste0("T_MCO", aa, "B"))
  tbl_c <- tbl(conn, paste0("T_MCO", aa, "C"))

  tbl_b %>%
    filter(
      substr(GRG_GHM, 1, 2) != "90",       # erreurs de groupage
      substr(GRG_GHM, 1, 2) != "28",       # CMD 28 séances — hors champ
      SOR_MOD != "9",                      # sorties vivantes uniquement
      substr(ETA_NUM, 1, 2) == dep,
      !ETA_NUM %in% finess_doublons
    ) %>%
    inner_join(
      tbl_c %>%
        filter(                            # chaînage complet uniquement
          NIR_RET == "0", NAI_RET == "0", SEX_RET == "0", SEJ_RET == "0",
          FHO_RET == "0", PMS_RET == "0", DAT_RET == "0"
        ) %>%
        select(ETA_NUM, RSA_NUM, NIR_ANO_17, EXE_SOI_DTF),
      by = c("ETA_NUM", "RSA_NUM")
    ) %>%
    left_join(tbl_deces, by = c("NIR_ANO_17" = "BEN_NIR_PSA")) %>%
    mutate(
      delai   = as.numeric(date_deces - EXE_SOI_DTF),
      dcd_30j = if_else(!is.na(delai) & delai >= 0 & delai <= delai_jours, 1L, 0L)
    ) %>%
    group_by(ETA_NUM) %>%
    summarise(                             # jointures 1:1 → n() = nb de sorties
      N_total = n(),
      N_dcd   = sum(dcd_30j, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(annee = an) %>%
    collect()
})

# ==== CALCUL — taux par établissement × année ====
resultat <- resultat %>%
  filter(N_total >= seuil_min) %>%
  mutate(taux_mortalite_30j = N_dcd / N_total)

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION — trajectoire du taux par établissement ====
# Pas de référentiel raison sociale sur le portail SNDS : facets par ETA_NUM
# (joindre un référentiel FINESS local après collect() si disponible)
ggplot2::ggplot(resultat, aes(x = annee, y = taux_mortalite_30j, color = ETA_NUM)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(ETA_NUM, ETA_NUM), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent) +
  labs(
    title    = "Taux de mortalité à 30 jours post-sortie (toutes causes, SNDS)",
    subtitle = paste0("Sorties vivantes MCO chaînées, décès IR_BEN_R ≤ ", delai_jours,
                      " j — dép. ", dep),
    x = NULL, y = "Taux de mortalité 30 j"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_taux_mortalite_30j_post_sortie.csv")
