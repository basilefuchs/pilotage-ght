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
/ght-r <nom> --profil <p1>,<p2>,... # plusieurs profils fusionnés (virgule, sans espace)
/ght-r <nom> --pattern <type>        # force le pattern (taux, mesure_diversite, parcours_sequentiel, etc.)
/ght-r <nom> --cat <N>               # force la catégorie (01 à 10)
/ght-r <nom> --dry-run               # squelette avec placeholders, pas de mapping demandé
/ght-r <nom> --write                 # écrit le fichier dans scripts_r/ sans confirmation
/ght-r <nom> --no-save-profil        # n'enrichit pas le profil partagé après la skill
```

## Principe directeur

**Aucun mapping n'est inventé.** La skill connaît les concepts PMSI
(GHM, DP, CCAM, FINESS, chaînage...) et les méthodes statistiques
classiques. Pour le schéma réel, elle résout chaque concept dans cet
ordre : **profil curaté** (`profils/*.md`, utilisé d'office) →
**dictionnaire complet** (`profils/dictionnaires/*.csv`, candidats
présentés à l'utilisateur pour confirmation) → **question libre**.
Tout mapping confirmé est persisté dans le profil.

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
- **Helpers candidats** : lire `helpers_r/README.md` (s'il existe) et
  matcher les mots-clés de la fiche (« Charlson », « Elixhauser »,
  « comorbidités OECD », « chirurgie programmée »…) contre la colonne
  *Rôle* du tableau d'index. Retenir les helpers applicables pour
  l'étape 2 (insertion) et l'étape 3 (lever ambiguïté si plusieurs
  helpers couvrent le même concept, ex: Charlson Quan vs Deyo).

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

**Helpers partagés** : pour chaque helper retenu en étape 1, insérer en
tête de script (après les `library()`) :

```r
source("helpers_r/<fichier>.R")
```

et **ne pas inliner** le calcul correspondant dans le script. Appeler la
fonction du helper là où le placeholder `<TODO ...>` aurait été inséré.
Si un helper applicable n'existe pas encore (concept présent dans la
fiche mais absent de `helpers_r/README.md`), conserver le `<TODO>` et le
signaler en fin de réponse comme **helper à créer** (ne pas inliner non
plus — le `<TODO>` rend la dette visible).

### Étape 3 : Questions groupées à l'utilisateur

Décision de l'étape, dans l'ordre :

- `--dry-run` → sauter intégralement l'étape (placeholders conservés).
- `--profil <chemin>` (ou bloc `# PROFIL DE BASE` collé) → utiliser ce
  mapping tel quel, sauter §3.0, ne poser que les questions
  méthodologiques restantes en §3.1.
- Sinon → §3.0 (détection automatique) puis §3.1 (questions restantes).

#### 3.0 — Détection de profils existants

Avant de poser les questions, lister `profils/*.md` à la racine du repo
et identifier les profils couvrant le **champ PMSI** de la fiche
(MCO/SSR/HAD/Psy, déduit du nom de fichier `<base>_<champ>.md`) :

- **0 profil candidat** → chercher tous les concepts dans les
  dictionnaires (§3.0.1) avant de poser les questions de mapping.
- **1 profil candidat couvrant tous les concepts requis** → le charger
  d'office, sauter le mapping, ne poser que les questions
  méthodologiques. Annoncer dans le message : "Profil détecté et
  utilisé : `profils/portail_atih_mco.md`".
- **1 profil candidat couvrant partiellement** → l'utiliser pour les
  concepts couverts ; pour les concepts manquants, chercher des
  candidats dans les dictionnaires (§3.0.1) et les soumettre avec les
  questions méthodologiques.
- **Plusieurs candidats** → les lister dans le message et demander
  lequel utiliser, en même temps que les questions méthodologiques.

#### 3.0.1 — Recherche dans les dictionnaires complets

`profils/dictionnaires/` contient le schéma **complet** des bases,
généré depuis les sources officielles (voir `profils/source/README.md`) :

- `portail_atih.csv` — base nationale ATIH, format
  `champ;schema_teradata;table;colonne;libelle;type;longueur;annees;jointure;commentaire;schema_sas`.
  `champ` ∈ {mco, smr, had, psy, rpu, ref}. Les schémas sont **déjà
  traduits** du nommage SAS vers Teradata (`prd_vue_mco_AAAA`, …) ;
  `prd_vue_rpu_AAAA` reste à confirmer à l'usage.
- `snds.csv` — SNDS complet, format
  `domaine;table;libelle_table;variable;libelle;type;longueur;remarques`.
  `domaine` ∈ {DCIR, PMSI, CARTOGRAPHIE, CAUSE_DECES, AUTRE, VALEUR}.

Recherche par grep (insensible à la casse, sur libellé ou nom de
colonne), en filtrant par champ/domaine :

```sh
grep -i "^mco;" profils/dictionnaires/portail_atih.csv | grep -i "urgence"
grep -i ";ER_PRS_F;" profils/dictionnaires/snds.csv
```

Règles :

- **Jamais d'insertion silencieuse** : tout candidat issu du
  dictionnaire est présenté à l'utilisateur (table, colonne, libellé,
  années de disponibilité) et confirmé en chat avant usage.
- **Un seul candidat évident** → le proposer pré-rempli dans le tableau
  de l'étape 3.1 (l'utilisateur valide d'un mot). **Plusieurs
  candidats** → les lister et demander le bon. **Aucun** → question
  libre comme avant.
- La colonne `annees` (ATIH) borne la disponibilité : alerter si la
  plage d'années du script déborde (ex. `passage_urg` : 2023-2026).
- Les mappings confirmés suivent le circuit normal de **persistance
  dans `profils/`** (section "Persistance des profils").

#### 3.1 — Format des questions

Poser **toutes les questions nécessaires en un seul message**, sous forme
d'un tableau de mapping à compléter. Ne pas fractionner en plusieurs tours.

Format type :

```
Pour finaliser le script, j'ai besoin du mapping suivant. Complète les
cases `?` (si tu as déjà un profil mapping, colle-le simplement) :

| Concept PMSI             | Table                     | Colonne      | Clef(s) de jointure    |
|--------------------------|---------------------------|--------------|------------------------|
| Séjour (1 ligne)         | ? (ex: fixe)              | ? (ex: ident)| ? (ex: ident, anonyme) |
| GHM complet              | ?                         | ?            | ?                      |
| Diagnostic principal     | ?                         | ?            | ?                      |
| Actes CCAM               | ?                         | ?            | ?                      |
| ...                      |                           |              |                        |

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
8. **Persister le profil** (sauf si `--no-save-profil` ou `--dry-run`) :
   voir section "Persistance des profils" ci-dessous.

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
scripts_r/<NN>_<categorie>/<nom_snake_case>.R          # base unique
scripts_r/<NN>_<categorie>/<nom_snake_case>.<base>.R   # variantes multi-bases
```

**Variantes multi-bases** : un même indicateur peut avoir un script par
base de données (`.atih.R`, `.snds.R`, `.datamart_chu_<nom>.R`...). Le
suffixe reprend le préfixe du profil utilisé. Règles :

- Premier script d'un indicateur → nom nu `<nom>.R`, **sauf** si la base
  n'est pas le portail ATIH (alors suffixer d'emblée, ex. `.snds.R`).
- Ajout d'une variante alors qu'un script nu existe → renommer le script
  nu avec son suffixe de base (`git mv`) puis créer la variante. La
  GitHub Page affiche un onglet par variante (`build_docs.py` matche
  `<nom>.R` et `<nom>.<suffixe>.R`).

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

### Profils multiples

Le flag `--profil` accepte plusieurs chemins séparés par des virgules
(sans espace) :

```
/ght-r continuite_ght --profil profils/portail_atih_mco.md,profils/portail_atih_ssr.md
```

Règles de fusion :

- Chaque vue est prise dans le profil qui la définit
- Les sections "Pièges" et "Défauts recommandés" sont **concaténées**
  (en dédupliquant les lignes identiques)
- En cas de conflit (même nom de vue avec colonnes différentes dans
  deux profils), signaler l'ambiguïté à l'utilisateur et demander
  lequel garder

Le glob (`profils/*`) n'est **pas** supporté : lister explicitement les
profils à charger.

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

## Persistance des profils

À la fin de l'étape 4, la skill persiste le mapping dans
`profils/<base>_<champ>.md`.

**Cas où la persistance est SKIPPÉE** :

- `--no-save-profil` fourni
- `--dry-run` (pas de mapping réel)
- Mapping chargé via `--profil` **et** aucun concept ajouté ni modifié
  pendant la session (le profil n'a rien à apprendre)
- `--profil` charge plusieurs profils fusionnés (la rétro-écriture vers
  les sources serait ambigüe)

### Procédure

1. **Identifier la base** : déduite de la connexion utilisée
   (`pRatihque::connection_database()` → `portail_atih`). Si la base
   n'est pas reconnue, demander à l'utilisateur le préfixe
   (`datamart_chu_lille`, `snds`, etc.) — une seule fois.
2. **Identifier le champ** : MCO, SSR, HAD, Psy. Déduit de la fiche
   (catégorie + tables citées). Si ambigu, demander.
3. **Charger le profil existant** `profils/<base>_<champ>.md` s'il
   existe, sinon créer le squelette (voir
   `references/profils_format.md`).
4. **Fusionner** concept par concept :
   - Concept absent → ajouter la ligne dans la bonne section de vue
     (créer la section si nécessaire).
   - Concept présent avec **même colonne** → ne rien faire.
   - Concept présent avec **colonne différente** → **CONFLIT** :
     afficher le diff `ancien → nouveau` à l'utilisateur, demander
     "écraser ? [O/n]". En cas de refus, ne pas écrire.
5. **Concaténer** les sections "Pièges" et "Défauts recommandés"
   (dédupliquer les lignes identiques par hash de contenu).
6. **Écrire** le fichier mis à jour.
7. **Annoncer** dans la réponse finale, exemple :
   `Profil mis à jour : profils/portail_atih_mco.md (+2 concepts dans
   "fixe", +1 vue "finessgeo_umdudp")`.

### Format du profil

Voir `references/profils_format.md` pour le schéma exact (sections,
libellés concepts normalisés, conventions). Exemple canonique :
`profils/portail_atih_mco.md` du repo `pilotage-ght`.

### Cas multi-champs

Si l'indicateur traverse plusieurs champs (ex. continuité MCO→SSR), la
skill enrichit chaque profil indépendamment :
`profils/portail_atih_mco.md` ET `profils/portail_atih_ssr.md`.

### Désactivation

`--no-save-profil` désactive l'étape de persistance. Utile pour les
mappings ad-hoc ou expérimentaux qu'on ne veut pas pousser dans le
profil partagé.

## Fichiers de référence

- `references/conventions_dplyr.md` — **toujours lire** : style de code,
  squelette de script, pattern `map_dfr`, viz timeseries
- `references/patterns_methodologiques.md` — **toujours lire** : 8
  patterns d'indicateurs avec leur squelette R
- `references/profils_format.md` — schéma des fichiers profil
  `profils/<base>_<champ>.md`, conventions de libellés concept
- `helpers_r/README.md` — **lire à l'étape 1** : index des helpers
  partagés (Charlson, Elixhauser, etc.) à `source()` plutôt qu'inliner
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
/ght-r readmission_j30 --profil profils/portail_atih_mco.md
/ght-r continuite_ght --profil profils/portail_atih_mco.md,profils/portail_atih_ssr.md
```

## Ce que la skill NE fait PAS

- Ne valide jamais seule un mapping hors profil : les candidats trouvés
  dans `profils/dictionnaires/` sont systématiquement confirmés par
  l'utilisateur avant d'entrer dans le script ou le profil
- N'exécute pas le code R (génération uniquement)
- Ne valide pas statistiquement les résultats
- Ne rédige pas de rapport final (juste le calcul + viz de base)
- Ne rédige pas la fiche Markdown (c'est le rôle de `/ght-dev`)