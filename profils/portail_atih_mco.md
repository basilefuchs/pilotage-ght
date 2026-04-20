# Profil — Portail ATIH / MCO

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | Portail ATIH (Plateforme données hospit.)   |
| SGBD              | Teradata (via dbplyr)                       |
| Connexion         | `pRatihque::connection_database()`          |
| Schéma annuel     | `prd_vue_mco_AAAA`                          |
| Années couvertes  | 2016 → N-1                                  |
| Clé universelle   | `ident` (identifiant séjour annuel)         |

## `fixe` — 1 ligne / séjour

| Concept                    | Colonne         |
|----------------------------|-----------------|
| Id séjour (clé)            | `ident`         |
| FINESS juridique           | `finess`        |
| GHM (6 car)                | `ghm2`          |
| Racine GHM (5 car)         | `substr(ghm2, 1, 5)` |
| CMD (2 car)                | `substr(ghm2, 1, 2)` |
| GHS                        | `ghs`           |
| DP                         | `dp`            |
| DR                         | `dr`            |
| Nb DAS                     | `nbda`          |
| Sexe                       | `sexe`          |
| Âge (années)               | `age`           |
| Âge (jours, < 1 an)        | `agejour`       |
| Âge gestationnel           | `age_gest`      |
| Poids (nouveau-né)         | `poids`         |
| Mode entrée                | `modeentree`    |
| Provenance                 | `provenance`    |
| Mode sortie                | `modesortie`    |
| Destination                | `destination`   |
| Passage urgences           | `passage_urg`   |
| Type séjour                | `typ_sej`       |
| Durée (nuitées)            | `duree`         |
| Nb RUM                     | `nbrum`         |
| Nb actes                   | `nbacte`        |
| Nb séances                 | `nbseance`      |
| Date entrée                | `date_entree`   |
| Date sortie                | `date_sortie`   |
| Mois sortie                | `mois`          |
| Année sortie               | `annee`         |
| Code géographique patient  | `codegeo`       |
| Code postal patient        | `codepost`      |
| RUM portant le DP          | `rumdudp`       |
| Top UHCD                   | `top_uhcd`      |
| Top RAAC                   | `raac`          |
| Top lit palliatif          | `lit_palliatif` |

## `diag` — N / séjour (~3.2x)

| Concept              | Colonne  |
|----------------------|----------|
| Id séjour (clé)      | `ident`  |
| Code CIM-10          | `diag`   |

## `acte` — N / séjour (~2.6x)

| Concept              | Colonne  |
|----------------------|----------|
| Id séjour (clé)      | `ident`  |
| Code CCAM (7 car)    | `acte`   |

## `um` — N / séjour (~1.1x)

| Concept              | Colonne   |
|----------------------|-----------|
| Id séjour (clé)      | `ident`   |
| Numéro UM            | `num_um`  |
| Type UM              | `type`    |

## `finessgeo_umdudp` — 1 / séjour

| Concept                                   | Colonne        |
|-------------------------------------------|----------------|
| Id séjour (clé)                           | `ident`        |
| FINESS géographique (portant le DP)       | `finessgeodp`  |

## `id_hospit_ipp` — 1 / séjour (chaînage)

| Concept                           | Colonne  |
|-----------------------------------|----------|
| Id séjour (clé)                   | `ident`  |
| IPP chaîné inter-séjours          | `ipp_c`  |

## Pièges

| Piège                                        | Traitement                             |
|----------------------------------------------|----------------------------------------|
| CMD 28 (1 séance = 1 RSA)                    | Exclure ou dénombrer à part            |
| Erreurs de groupage (CMD 90)                 | `substr(ghm2, 1, 2) != "90"`           |
| Doublons sur jointure `diag` / `acte`        | `distinct(ident, ...)` avant comptage  |
| Décès intra-séjour fausse ré-hospi           | `modesortie != "9"`                    |
| FINESS juridique vs géographique             | Benchmarking = `finessgeodp`           |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Plage d'années            | `annees <- 2016:2025`           |
| Filtre département        | `substr(finess, 1, 2) == "29"`  |
| Seuil robustesse (taux)   | 30 séjours                      |
| Seuil robustesse (ratios) | 500 séjours                     |
| Clé d'agrégation          | `finessgeodp`                   |