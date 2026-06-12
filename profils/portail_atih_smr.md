# Profil — Portail ATIH / SMR

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | Portail ATIH (Plateforme données hospit.)   |
| SGBD              | Teradata (via dbplyr)                       |
| Connexion         | `pRatihque::connection_database()`          |
| Schéma annuel     | `prd_vue_smr_AAAA`                          |
| Années couvertes  | 2016 → N-1                                  |
| Clé universelle   | `ident_sej` (identifiant séjour annuel)     |

## `fixe` — 1 ligne / séjour

| Concept                    | Colonne         |
|----------------------------|-----------------|
| Id séjour (clé)            | `ident_sej`     |
| FINESS géographique        | `finessgeo`     |
| GME (6 car)                | `gme`           |
| Groupe nosologique (4 car) | `substr(gme, 1, 4)` |
| CM (2 car)                 | `substr(gme, 1, 2)` |

## `fixe_sej` — 1 ligne / séjour

| Concept                    | Colonne         |
|----------------------------|-----------------|
| N° chaînage anonyme (patient, commun MCO↔SMR) | `anonyme` |
| Date entrée                | `date_entree`   |
| Date sortie                | `date_sortie`   |
| FINESS géographique        | `finessgeo` [à confirmer] |

## Pièges

| Piège                                        | Traitement                             |
|----------------------------------------------|----------------------------------------|
| Erreurs de groupage (CM 90)                  | `substr(gme, 1, 2) != "90"`            |
| Répartition `fixe` vs `fixe_sej`             | Vérifier sur quelle vue chaque colonne est portée avant jointure |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Plage d'années            | `annees <- 2016:2025`           |
| Filtre département        | `substr(finessgeo, 1, 2) == "29"` |
| Seuil robustesse (taux)   | 30 séjours                      |
