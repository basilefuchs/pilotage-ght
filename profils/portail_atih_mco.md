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

| Concept              | Colonne             |
|----------------------|---------------------|
| Id séjour (clé)      | `ident`             |
| Code CCAM (7 car)    | `acte`              |
| Délai depuis date_entree (jours, int) | `acte_delai` |

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

## `nom_gen.pop_com_sex_ag` — population INSEE par commune × âge × sexe (annuel)

| Concept                            | Colonne     |
|------------------------------------|-------------|
| Code commune INSEE                 | `code_com`  |
| Année du recensement               | `annee_pop` |
| Âge (années entières)              | `age`       |
| Sexe (1 = M, 2 = F)                | `sexe`      |
| Effectif de population             | `pop`       |

## `nom_gen.corresp_code_com_geo_ts_pop` — correspondance code commune INSEE ↔ code géographique PMSI

| Concept                            | Colonne     |
|------------------------------------|-------------|
| Code commune INSEE                 | `code_com`  |
| Code géographique PMSI             | `code_geo`  |

Jointure : `code_com` côté INSEE, `code_geo` à apparier sur `fixe.codegeo`.
Permet d'agréger la population INSEE au niveau `codegeo` PMSI (utile pour
TRHS, taux de recours, zones d'attraction).

## `nom_gen.finess_codegeo_distance_tps` — distancier FINESS × code géo PMSI

| Concept                            | Colonne      |
|------------------------------------|--------------|
| FINESS établissement               | `finess`     |
| Code géographique PMSI             | `codegeo`    |
| Distance routière (km) [à confirmer] | `distance` |
| Temps de trajet (min) [à confirmer]  | `tps_trajet` |
| Début de validité (année)          | `annee_deb`  |
| Fin de validité (année)            | `annee_fin`  |

Jointure : `(finess, codegeo)` après filtre de validité
`filter(an >= annee_deb, an <= annee_fin)`. Distance directe
domicile (codegeo) → établissement : pas besoin de passer par les communes.

## `nom_gen.geolocalisation_finess` — implantation des établissements

| Concept                            | Colonne        |
|------------------------------------|----------------|
| FINESS établissement (clé)         | `finess`       |
| Commune INSEE d'implantation       | `code_commune` |
| Début de validité (année)          | `annee_deb`    |
| Fin de validité (année)            | `annee_fin`    |

Jointure : `finess` + filtre de validité `annee_deb`/`annee_fin`.

## `prd_vue_nomgen.finessgeo` — référentiel (annuel, hors schéma MCO)

| Concept                                   | Colonne        |
|-------------------------------------------|----------------|
| FINESS géographique (clé)                 | `finessgeo`    |
| Raison sociale établissement              | `rs`           |
| Année                                     | `annee`        |

Jointure : `(annee, finessgeo)`. Filtre département recommandé :
`substr(finessgeo, 1, 2) == dep`.

## Pièges

| Piège                                        | Traitement                             |
|----------------------------------------------|----------------------------------------|
| CMD 28 (1 séance = 1 RSA)                    | Exclure ou dénombrer à part            |
| Erreurs de groupage (CMD 90)                 | `substr(ghm2, 1, 2) != "90"`           |
| Doublons sur jointure `diag` / `acte`        | `distinct(ident, ...)` avant comptage  |
| Décès intra-séjour fausse ré-hospi           | `modesortie != "9"`                    |
| FINESS juridique vs géographique             | Benchmarking = `finessgeodp`           |
| Tables `nom_gen` à période de validité       | `filter(an >= annee_deb, an <= annee_fin)` avant jointure |
| Tarifs GHS ex-DG                             | Indisponibles en base nationale → fichier campagne ATIH local (CSV `ghs, annee, tarif`), joint après `collect()` |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Plage d'années            | `annees <- 2016:2025`           |
| Filtre département        | `substr(finess, 1, 2) == "29"`  |
| Seuil robustesse (taux)   | 30 séjours                      |
| Seuil robustesse (ratios) | 500 séjours                     |
| Clé d'agrégation          | `finessgeodp`                   |