# Profil — SNDS / MCO

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | SNDS (portail CNAM)                         |
| SGBD              | Oracle (via ROracle + dbplyr)               |
| Connexion         | `ROracle::dbConnect(ROracle::Oracle(), dbname = "IPIAMPR2.WORLD")` |
| Schéma            | tables annuelles `T_MCOaaX` (`aa` = millésime 2 chiffres, ex. `T_MCO22B`) |
| Années couvertes  | 2016 → N-1 (N-1 partiellement consolidé)    |
| Clé universelle   | `(ETA_NUM, RSA_NUM)` (séjour RSA annuel)    |

## `T_MCOaaB` — 1 ligne / séjour RSA

| Concept                        | Colonne    |
|--------------------------------|------------|
| FINESS établissement (clé)     | `ETA_NUM`  |
| N° d'index du RSA (clé)        | `RSA_NUM`  |
| GHM (GENRSA)                   | `GRG_GHM`  |
| CMD (2 car)                    | `substr(GRG_GHM, 1, 2)` |
| GHS                            | `GHS_NUM`  |
| Mode de sortie                 | `SOR_MOD`  |
| Année de sortie                | `SOR_ANN`  |
| Mois de sortie                 | `SOR_MOI`  |

## `T_MCOaaC` — 1 ligne / séjour (chaînage)

| Concept                                  | Colonne       |
|------------------------------------------|---------------|
| FINESS établissement (clé)               | `ETA_NUM`     |
| N° d'index du RSA (clé)                  | `RSA_NUM`     |
| Identifiant patient pseudonymisé         | `NIR_ANO_17`  |
| Date d'entrée                            | `EXE_SOI_DTD` |
| Date de sortie                           | `EXE_SOI_DTF` |
| Code retour chaînage NIR                 | `NIR_RET`     |
| Codes retour chaînage complémentaires    | `NAI_RET`, `SEX_RET`, `SEJ_RET`, `FHO_RET`, `PMS_RET`, `DAT_RET` |

## `T_MCOaaA` — N lignes / séjour (actes CCAM)

| Concept                                  | Colonne       |
|------------------------------------------|---------------|
| FINESS établissement (clé)               | `ETA_NUM`     |
| N° d'index du RSA (clé)                  | `RSA_NUM`     |
| Code CCAM (7 car)                        | `CDC_ACT`     |
| Phase de l'acte                          | `PHA_ACT`     |
| Nb réalisations de l'acte                | `NBR_EXE_ACT` |

## `IR_BEN_R` — référentiel bénéficiaires (non annuel)

| Concept                                  | Colonne       |
|------------------------------------------|---------------|
| Identifiant patient pseudonymisé (clé)   | `BEN_NIR_PSA` |
| Rang du bénéficiaire                     | `BEN_RNG_GEM` |
| Date de décès (toutes causes)            | `BEN_DCD_DTE` |
| Année-mois de décès                      | `BEN_DCD_AME` |

Jointure : `T_MCOaaC.NIR_ANO_17 = IR_BEN_R.BEN_NIR_PSA`.

## Pièges

| Piège                                          | Traitement                                  |
|------------------------------------------------|---------------------------------------------|
| Chaînage incomplet                              | Filtrer `NIR_RET, NAI_RET, SEX_RET, SEJ_RET, FHO_RET, PMS_RET, DAT_RET` tous = `'0'` |
| `IR_BEN_R` : plusieurs lignes / bénéficiaire    | Dédupliquer (`group_by(BEN_NIR_PSA)` + `min(BEN_DCD_DTE)`) |
| Date de décès invalide = 01/01/0001             | Filtrer `BEN_DCD_DTE > to_date("1900-01-01")` |
| FINESS juridiques doublonnés AP-HP/AP-HM/HCL    | Exclure `ETA_NUM ∈ {750712184, 130780521, 690783154}` |
| Décès intra-hospitalier dans le numérateur      | Exclure `SOR_MOD == '9'` du dénominateur     |
| CMD 28 (séances) et CMD 90 (erreurs)            | `substr(GRG_GHM, 1, 2) ∉ {"28", "90"}`       |
| Millésime N-1 partiellement consolidé           | Suivi à 30 j : s'arrêter à N-2 en fin d'année |
| Pas de référentiel raison sociale sur le portail | Facets par `ETA_NUM`, ou référentiel FINESS local après `collect()` |
| CCAM : `CDC_ACT` = 7 car, phase séparée (`PHA_ACT`) | Différent du portail ATIH (`acte.acte` = CCAM+phase, 8 car) |
| Séjour du périmètre postérieur au décès `IR_BEN_R` | Clé de chaînage défaillante → exclure le candidat |

## Défauts recommandés

| Paramètre                 | Valeur                              |
|---------------------------|-------------------------------------|
| Plage d'années            | `annees <- 2016:2024`               |
| Filtre département        | `substr(ETA_NUM, 1, 2) == "29"`     |
| Seuil robustesse (taux)   | 30 sorties                          |
| Clé d'agrégation          | `ETA_NUM`                           |
| Fenêtre post-sortie       | 30 jours                            |
