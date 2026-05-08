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
| FINESS géographique        | `finessgeo`   |
| Durée du séjour (journées) | `duree`       |

## `fixe` — table patient HAD, jointe à `fixe_sej` sur `ident_sej`

| Concept                    | Colonne       |
|----------------------------|---------------|
| Id séjour HAD (clé)        | `ident_sej`   |
| Code géographique patient  | `codegeo`     |

## Pièges

| Piège                                         | Traitement                            |
|-----------------------------------------------|---------------------------------------|
| 1 séjour HAD = N journées (pas 1 jour = 1 RSA)| Sommer `duree` pour total journées    |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Plage d'années            | `annees <- 2016:2025`           |
| Filtre département        | `substr(finessgeo, 1, 2) == "29"` |
| Clé d'agrégation          | `finessgeo`                     |
