# profils/source/

Sources brutes des dictionnaires de schéma, converties en fichiers
greppables dans `profils/dictionnaires/` par `build_dictionnaires.R`.

## Fichiers

| Fichier                 | Contenu                                   | Source |
|-------------------------|-------------------------------------------|--------|
| `atih-AAAA-MM-JJ.xlsx`  | Dictionnaire des variables de la base nationale ATIH (nommage SAS) | Documentation ATIH (déposé manuellement) |
| `Kwikly.zip`            | Documentation SNDS Kwikly (HTML, version du 25/03/2026) | [GitLab HDH — documentation-snds](https://gitlab.com/healthdatahub/applications-du-hdh/documentation-snds/-/raw/master/snds/files/CNAM_NEW/formations/kwikly/Kwikly.zip) |
| `build_dictionnaires.R` | Script de conversion sources → dictionnaires | — |

## Régénération

```sh
Rscript profils/source/build_dictionnaires.R
```

À relancer après remplacement d'un fichier source (nouvelle version
annuelle ATIH, nouvelle version Kwikly). S'il existe plusieurs
`atih-*.xlsx`, le plus récent (tri lexical sur la date du nom) est utilisé.

## Règle de nommage SAS → Teradata (base ATIH)

Le fichier ATIH décrit les bibliothèques SAS ; le portail Teradata
utilise d'autres noms de schéma. La traduction appliquée par le script :

| Librairie SAS | Schéma Teradata        | Statut                          |
|---------------|------------------------|---------------------------------|
| `mcoxxbd`     | `prd_vue_mco_AAAA`     | vérifié (scripts existants)     |
| `ssrxxbd`     | `prd_vue_smr_AAAA`     | vérifié (renommage ssr → smr)   |
| `hadxxbd`     | `prd_vue_had_AAAA`     | par analogie                    |
| `psyxxbd`     | `prd_vue_psy_AAAA`     | par analogie                    |
| `rpuxx`       | `prd_vue_rpu_AAAA`     | **à confirmer à l'usage**       |
| `nom_gen`, `nom_pmsi`, `nom_urg`, `agg_pmsi` | inchangés | `nom_gen` vérifié (scripts existants) ; nota : `prd_vue_nomgen` existe aussi côté Teradata |

`AAAA` = année PMSI (schémas partitionnés par année, ex.
`prd_vue_mco_2024.fixe`).

## Particularités des données

- Excel ATIH : 8 variables dérivées sans table (`modentprov`,
  `modsordest`) conservées avec table vide ; cellules `"NA"` littérales
  converties en vide.
- Kwikly : les 478 tables de valeurs sont dupliquées entre les menus
  AUTRE et VALEUR — dédupliquées au profit du domaine le plus
  spécifique. ~2 700 variables sans libellé (le nom de variable et les
  remarques restent recherchables).
