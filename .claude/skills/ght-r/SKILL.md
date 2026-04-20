---
name: ght-r
description: Développe le code R/dplyr d'un indicateur GHT à partir de sa fiche Markdown. Phase 3 du pipeline /ght-gen → /ght-dev → /ght-r. Déclencher systématiquement avec /ght-r, ou dès qu'une fiche d'indicateur PMSI est fournie et que l'utilisateur demande une implémentation R, du code dplyr, un script de calcul, ou "comment calculer cet indicateur". Génère un script R exécutable sur le portail ATIH (Teradata via dbplyr), en demandant le mapping schéma → colonnes à l'utilisateur avant finalisation. Fonctionne pour tous champs PMSI (MCO, SSR/SMR, HAD, Psy) et toutes bases (portail ATIH, SNDS, datamarts locaux).
trigger: /ght-r
---

# /ght-r

Phase 3 du pipeline — implémentation R. Prend une fiche d'indicateur
(issue de `/ght-dev` ou existante) et produit le script R complet, dans
le style dplyr/purrr du projet, avec demande de mapping à l'utilisateur.

## Usage

```
/ght-r <nom_indicateur>              # développe depuis le contexte courant (après /ght-dev)
/ght-r <chemin_fiche.md>             # développe depuis un fichier de fiche explicite
/ght-r <nom> --profil <chemin>       # avec un profil de mapping pré-enregistré
/ght-r <nom> --pattern <type>        # force le pattern (taux, mesure_diversite, parcours_sequentiel, etc.)
/ght-r <nom> --cat <N>               # force la catégorie (01 à 10)
/ght-r <nom> --dry-run               # squelette avec placeholders, pas de mapping demandé
/ght-r <nom> --write                 # écrit le fichier dans scripts_r/ sans confirmation
```

## Principe directeur

**La skill ne connaît pas la base de l'utilisateur.** Elle connaît les
concepts PMSI (GHM, DP, CCAM, FINESS, chaînage...) et les méthodes
statistiques classiques. Elle demande à l'utilisateur le mapping
concepts → (table, colonne) avant de finaliser le code.

## Workflow — 4 étapes

### Étape 1 : Analyse de la fiche

Lire la fiche fournie et en extraire :

- **Type d'indicateur** (voir `references/patterns_methodologiques.md`)
- **Champ PMSI** concerné : MCO, SSR, HAD, Psy, multi-champ
- **Concepts PMSI nécessaires** au calcul (GHM, actes CCAM, diagnostics...)
- **Granularité d'analyse** : séjour, patient, établissement, parcours
- **Paramètres ouverts** laissés au calculateur (délais, seuils, options)
- **Formule mathématique** exacte
- **Catégorie** (01 à 10) pour le chemin de sortie, si non forcée par `--cat`

Si un point est ambigu dans la fiche (ex: "dans les 30, 60 ou 90 jours"),
le marquer comme **paramètre ouvert** à poser à l'utilisateur à l'étape 3.

### Étape 2 : Premier brouillon avec placeholders

Produire un script R suivant le squelette de
`references/conventions_dplyr.md` section 7, en utilisant :

- `<table_XXX>` pour les tables (ex: `<table_sejours>`, `<table_diag>`)
- `<col_XXX>` pour les colonnes (ex: `<col_ghm>`, `<col_dp>`)
- Clé de jointure par défaut : `ident` (le confirmer à l'étape 3)

Sélectionner le squelette approprié selon le type d'indicateur dans
`references/patterns_methodologiques.md` et l'adapter à la fiche.

### Étape 3 : Questions groupées à l'utilisateur

**Sauf si `--dry-run` ou `--profil <chemin>` est fourni.**

Poser **toutes les questions nécessaires en un seul message**, sous forme
d'un tableau de mapping à compléter. Ne pas fractionner en plusieurs tours.

Format type :

```
Pour finaliser le script, j'ai besoin du mapping suivant. Complète les
cases `?` (si tu as déjà un profil mapping, colle-le simplement) :

| Concept PMSI             | Table                     | Colonne      |
|--------------------------|---------------------------|--------------|
| Séjour (1 ligne)         | ? (ex: fixe)              | ? (ex: ident)|
| GHM complet              | ?                         | ?            |
| Diagnostic principal     | ?                         | ?            |
| Actes CCAM               | ?                         | ?            |
| ...                      |                           |              |

Et pour les paramètres méthodologiques :
- Délai de ré-hospitalisation : 30, 60 ou 90 jours ? (fiche laisse ouvert)
- Granularité GHM : complet (6 car.) ou racine (5 car.) ?
```

Règles pour les questions :

- Seulement les concepts réellement utilisés par l'indicateur
- Proposer un exemple entre parenthèses pour les cas évidents
- Grouper mapping (tableau) et méthodologie (liste) séparément
- Si la fiche a mentionné le champ PMSI, l'indiquer

### Étape 4 : Substitution et finalisation

Une fois la réponse reçue (ou immédiatement si `--dry-run`) :

1. Substituer les placeholders par les valeurs réelles
2. Ajouter les jointures `inner_join(..., by = "ident")` sauf indication contraire
3. Générer le **bloc `# PROFIL DE BASE`** en tête du script
4. Laisser `<TODO: description>` bien visible pour toute info manquante,
   et les lister en fin de réponse
5. Inclure la visualisation timeseries sauf indicateur a-temporel
6. Terminer par un `write_csv()` commenté
7. Si `--write`, écrire à `scripts_r/<NN>_<categorie>/<nom_snake_case>.R`
   sinon proposer l'emplacement à l'utilisateur

## Règles qualité

**Structure obligatoire du script** :

- Bloc `# PROFIL DE BASE` en tête avec le mapping complet utilisé
- Bloc `# PARAMÈTRES` listant les paramètres ouverts avec valeurs
  suggérées en commentaire
- En-tête indiquant le **pattern méthodologique** utilisé (§1 à §8 de
  `patterns_methodologiques.md`) et la **source de la fiche**
- Visualisation timeseries finale (pattern §8 de `conventions_dplyr.md`)
- `write_csv()` commenté en dernière ligne

**Conformité au style** (`conventions_dplyr.md` à 100 %) :

- `purrr::map_dfr` pour l'itération multi-année (pas `map() |> list_rbind()`)
- `collect()` **dans** la fonction `map_dfr`, pas après
- `transmute()` plutôt que `select() + mutate()` quand possible
- `.groups = "drop"` systématique sur `summarise()`
- `substr()` et non `stringr::str_sub()`
- `n_distinct(ident)` et non `length(unique(ident))`
- `select()` **dans** les jointures pour limiter les colonnes
- **Jamais** `library(tidyverse)` en bloc — charger explicitement
- **Jamais** `arrange()` avant `collect()` (rarement utile)
- `reorder(rs, rs)` pour les facets — **ne pas "simplifier"**, c'est
  volontaire pour le tri alphabétique

**Robustesse méthodologique** :

- Filtre final `N_total >= seuil_min` pour les taux (default 30)
- `distinct(ident)` avant tout dénombrement pour éviter les doublons
- Pour les indicateurs sensibles au volume (entropie, ratios), seuil de
  500 séjours minimum par unité d'agrégation
- CMD 28 (séances) à traiter explicitement pour les indicateurs MCO
- Bien distinguer `ident` (séjour) et identifiant patient chaîné pour
  les indicateurs de parcours

**Transparence sur les manquants** :

- Tout `<TODO: ...>` dans le script doit être listé en fin de réponse
- Aucune hypothèse silencieuse sur les codes CIM/CCAM/GHM — les récupérer
  de la fiche ou demander à l'utilisateur

## Chemin de fichier

```
scripts_r/<NN>_<categorie>/<nom_snake_case>.R
```

Catégories (alignées sur `indicateurs_pmsi/`) :

- 01_activite_production
- 02_casemix_patientele
- 03_vulnerabilite_sociale
- 04_efficience_capacitaire
- 05_qualite_securite
- 06_pertinence_pratiques
- 07_parcours_continuite
- 08_readmissions_evitables
- 09_territoire_attractivite
- 10_financement_valorisation

## Gestion des cas particuliers

### Profil de base déjà fourni

Si l'utilisateur colle un bloc `# PROFIL DE BASE` au début de sa demande
(généré par un appel précédent) ou passe `--profil <chemin>`, **sauter
l'étape 3** et utiliser directement ce mapping. Ne poser que les
questions méthodologiques s'il en reste.

### Indicateur multi-champs

Si l'indicateur traverse plusieurs champs PMSI (ex: continuité GHT
MCO→SSR→HAD), demander le mapping pour chaque champ, clairement séparé.
Voir `references/exemples/parcours_continuite.R`.

### Tables de nomenclature

La clé de jointure universelle est `ident` **pour les tables de données**.
Les tables de nomenclature (référentiels GHM, CIM, CCAM, FINESS) se
joignent sur la **variable métier** correspondante. Si l'indicateur
nécessite un référentiel, le demander explicitement.

### Indicateur a-temporel

Si la fiche n'a aucune dimension temporelle (ex: analyse cross-sectionnelle
d'une seule année), omettre la visualisation timeseries et prévenir
l'utilisateur qu'une viz alternative pourrait être pertinente.

## Fichiers de référence

- `references/conventions_dplyr.md` — **toujours lire** : style de code,
  squelette de script, pattern `map_dfr`, viz timeseries
- `references/patterns_methodologiques.md` — **toujours lire** : 8
  patterns d'indicateurs avec leur squelette R
- `references/exemples/` — à consulter pour voir un script final type :
  - `taux_iso_pth.R` — pattern `taux` (catégorie 05)
  - `diversite_shannon.R` — pattern `mesure_diversite` (catégorie 02)
  - `parcours_continuite.R` — pattern `parcours_sequentiel` (catégorie 07)

## Exemples

```
/ght-r entropie_casemix_cmd
/ght-r indicateurs_pmsi/07_parcours_continuite/continuite_ght.md
/ght-r iso_pth --cat 05 --write
/ght-r concentration_ghm --pattern mesure_diversite --dry-run
/ght-r readmission_j30 --profil profils/portail_atih.md
```

## Ce que la skill NE fait PAS

- Ne connaît pas les noms de colonnes/tables d'une base particulière
- N'exécute pas le code R (génération uniquement)
- Ne valide pas statistiquement les résultats
- Ne rédige pas de rapport final (juste le calcul + viz de base)
- Ne rédige pas la fiche Markdown (c'est le rôle de `/ght-dev`)
