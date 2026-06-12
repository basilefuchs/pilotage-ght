# Profil — Portail ATIH / Psy

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | Portail ATIH (Plateforme données hospit.)   |
| SGBD              | Teradata (via dbplyr)                       |
| Connexion         | `pRatihque::connection_database()`          |
| Schéma annuel     | `prd_vue_psy_AAAA`                          |
| Années couvertes  | 2016 → N-1                                  |
| Clé universelle   | `ident` (identifiant séquence RPSA annuel)  |

## `fixe` — 1 ligne / séquence RPSA

| Concept                                   | Colonne       |
|-------------------------------------------|---------------|
| Id séquence (clé)                         | `ident`       |
| Id séjour (clé)                           | `ident_sej`   |
| Forme d'activité (ex-NPEC)                | `fa`          |
| Détail forme d'activité (≥ 2022)          | `fa_detail`   |
| Journées de présence                      | `nbjseq`      |
| Demi-journées de présence (temps partiel) | `nbdemijseq`  |
| Durée de la séquence (jours couverts)     | `dureeseq`    |
| FINESS juridique                          | `finess`      |
| FINESS géographique                       | `finessgeo`   |
| Année (fin de séquence)                   | `annee`       |
| Mois (fin de séquence)                    | `mois`        |
| DP                                        | `dp`          |
| Sexe                                      | `sexe`        |
| Âge (années)                              | `age`         |
| Mode entrée                               | `modeentree`  |
| Mode sortie                               | `modesortie`  |
| Mode légal de soins                       | `modelegal`   |
| N° secteur psychiatrique                  | `secteurpsy`  |
| Code géographique patient                 | `codegeo`     |

## Pièges

| Piège                                              | Traitement                                   |
|----------------------------------------------------|----------------------------------------------|
| Granularité = séquence RPSA, pas séjour            | Agréger via `ident_sej` pour du par-séjour   |
| Formes d'activité ambulatoires (16-17)             | Hors périmètre journées : exclure            |
| Temps plein : fiche DREES dit FA 01-04, ATIH 01-07 | Définition ATIH retenue : FA 01-07           |
| Demi-journées temps partiel                        | Compter × 0,5 (convention ATIH `nbjpres`)    |
| `fixe_sej.nbjpres_hc` / `nbjpres_hp`               | Dispo 2016 uniquement ; utiliser `fixe.nbjseq` + `nbdemijseq` |
| `annee` = année de **fin** de séquence             | Séquences à cheval rattachées à l'année de fin |

## Défauts recommandés

| Paramètre                  | Valeur                          |
|----------------------------|---------------------------------|
| Plage d'années             | `annees <- 2016:2025`           |
| Filtre département         | `substr(finess, 1, 2) == "29"`  |
| Seuil robustesse (journées)| 500                             |
| Clé d'agrégation           | `finessgeo`                     |
