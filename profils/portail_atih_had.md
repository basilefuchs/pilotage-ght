# Profil — Portail ATIH / HAD

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | Portail ATIH (Plateforme données hospit.)   |
| SGBD              | Teradata (via dbplyr)                       |
| Connexion         | `pRatihque::connection_database()`          |
| Schéma annuel     | `prd_vue_had_AAAA`                          |
| Années couvertes  | 2016 → N-1                                  |
| Clé universelle   | `ident_sej` (identifiant séjour HAD annuel) |

## `fixe_sej` — 1 ligne / séjour HAD

| Concept                    | Colonne       |
|----------------------------|---------------|
| Id séjour HAD (clé)        | `ident_sej`   |
| N° chaînage anonyme (patient, commun MCO↔HAD) | `anonyme` |
| Qualité du chaînage        | `ano_retour`  |
| FINESS géographique        | `finessgeo`   |
| Durée du séjour (journées) | `duree`       |
| Date entrée                | `date_entree` |
| Année sortie               | `annee`       |

## `fixe` — table patient HAD, jointe à `fixe_sej` sur `ident_sej`

| Concept                    | Colonne       |
|----------------------------|---------------|
| Id séjour HAD (clé)        | `ident_sej`   |
| Code géographique patient  | `codegeo`     |

## Pièges

| Piège                                         | Traitement                            |
|-----------------------------------------------|---------------------------------------|
| 1 séjour HAD = N journées (pas 1 jour = 1 RSA)| Sommer `duree` pour total journées    |
| `date_entree`/`date_sortie` indisponibles avant 2019 | Plage d'années ≥ 2019 pour les dates réelles |
| Séjour rattaché à son **année de sortie**     | Chaînage fin d'année : balayer aussi le schéma N+1 |
| Chaînage non exploitable                      | Filtrer `ano_retour == "000000000"` (9 codes à zéro) |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Plage d'années            | `annees <- 2016:2025`           |
| Filtre département        | `substr(finessgeo, 1, 2) == "29"` |
| Clé d'agrégation          | `finessgeo`                     |
