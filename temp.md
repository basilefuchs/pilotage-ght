# Plan — Helpers R partagés (scores Charlson, Elixhauser, etc.) intégrés à `/ght-r`

## Contexte

Plusieurs fiches du projet `pilotage-ght` font appel à des **briques de calcul réutilisables** : score de Charlson (Quan 2005), score d'Elixhauser, comorbidités OECD, mapping CMD-PSI, etc. Aujourd'hui, la skill `/ght-r` les insère sous forme de **placeholders `<TODO>`** (cas vu sur `ewma_mortalite_chirurgicale_mensuelle.R`), ce qui force l'utilisateur à recoder le même mapping CIM-10 → poids dans chaque script.

L'utilisateur souhaite pouvoir **écrire une fois** ces briques (au format R/dplyr conforme au style projet) et que la skill `/ght-r` les **détecte et les intègre automatiquement** au moment où une fiche les invoque, sans les inliner.

Objectif : enrichir le repo d'un dossier `helpers_r/` (= librairie locale d'utilitaires) et apprendre à `/ght-r` à le consulter.

## Recommandation

### 1. Nouveau dossier racine `helpers_r/`

Parallèle à `profils/`, `indicateurs_pmsi/`, `scripts_r/`. Contenu :

```
helpers_r/
  README.md                 # index : helper → rôle, signature, dépendances
  charlson_quan.R           # 1 fichier = 1 helper, self-contained
  elixhauser_vanwalraven.R
  cmd_chirurgicale.R
  ...
```

**Règle d'or** : chaque fichier expose **une fonction nommée**, prend en entrée des **tables `tbl()` lazy dbplyr** (ou un `ident_set`), retourne un **tibble agrégé par `ident`** prêt à `left_join`. Pas de `collect()` interne — la fonction reste lazy si possible.

Exemple de signature canonique pour Charlson :

```r
# helpers_r/charlson_quan.R
# Score de Charlson pondéré (Quan 2005, version updated weights)
# Entrée : tbl_diag = lazy tbl avec colonnes (ident, diag) — codes CIM-10
# Sortie : tbl lazy (ident, charlson) — somme des poids, max 0
compute_charlson_quan <- function(tbl_diag, col_ident = "ident", col_diag = "diag") {
  # liste des regex CIM-10 → poids Quan 2005
  # ... (mapping intégré, ~17 catégories)
  tbl_diag %>%
    mutate(
      weight = case_when(
        substr(diag, 1, 3) %in% c("I21","I22","I25") ~ 1L, # MI
        # ...
        TRUE ~ 0L
      )
    ) %>%
    group_by(.data[[col_ident]]) %>%
    summarise(charlson = sum(weight, na.rm = TRUE), .groups = "drop")
}
```

### 2. Index `helpers_r/README.md`

Format machine-lisible (lu par la skill au démarrage) :

```markdown
# Helpers R partagés

| Helper                    | Fichier                          | Rôle                                  | Entrée                | Sortie                |
|---------------------------|----------------------------------|---------------------------------------|-----------------------|-----------------------|
| compute_charlson_quan     | charlson_quan.R                  | Score de Charlson (Quan 2005)         | tbl(ident, diag)      | tbl(ident, charlson)  |
| compute_elixhauser_vw     | elixhauser_vanwalraven.R         | Elixhauser-VanWalraven                | tbl(ident, diag)      | tbl(ident, elix)      |
| filtre_cmd_chirurgicale   | cmd_chirurgicale.R               | Cohorte chir programmée (GHM type C)  | tbl_fixe              | tbl_fixe filtrée      |
```

La skill **lit ce tableau à l'étape 1** pour savoir quels helpers existent et à quelle fonction faire appel.

### 3. Modifications de la skill `/ght-r`

Trois ajouts ciblés à `.claude/skills/ght-r/SKILL.md` :

a. **Étape 1 — Détection de helpers** : après lecture de la fiche, lire `helpers_r/README.md` et matcher les concepts de la fiche (« Charlson », « Elixhauser », « chirurgie programmée ») contre la colonne *Rôle*.

b. **Étape 2 — Insertion** : pour chaque helper retenu, insérer en tête de script :
   ```r
   source("helpers_r/charlson_quan.R")
   ```
   et remplacer le placeholder `<TODO Charlson>` par l'appel `compute_charlson_quan(tbl_diag)`.

c. **Étape 3 — Question méthodologique groupée** : si plusieurs helpers candidats existent pour le même concept (Charlson Quan vs Charlson Deyo), les proposer en option à choisir.

### 4. Convention de style helpers (à documenter dans `helpers_r/README.md`)

- Compatible **dbplyr lazy** quand le calcul peut tourner SQL-side ; sinon documenter le `collect()` requis.
- Pas de chargement de libs internes (la skill garantit `dplyr` chargé en amont).
- Pas de side-effect : pure fonction.
- Tester sur portail ATIH (Teradata) car certaines fonctions (`case_when` avec regex) varient.
- En-tête de fichier : `# nom — description — référence (article/PMID) — colonnes attendues`.

### 5. Référence d'exemple

Ajouter `helpers_r/charlson_quan.R` comme premier exemple opérationnel — l'utilisateur s'en sert pour reprendre le script EWMA déjà généré et valider le mécanisme bout-en-bout.

## Fichiers à créer / modifier

- `helpers_r/README.md` *(création)* — index des helpers
- `helpers_r/charlson_quan.R` *(création, par l'utilisateur ou stub par la skill)* — premier helper
- `.claude/skills/ght-r/SKILL.md` *(modif)* — ajout étape « détection helpers » dans le workflow
- `.claude/skills/ght-r/references/conventions_dplyr.md` *(modif optionnelle)* — section 10 « Helpers partagés »

## Hors-périmètre

- Réécrire les scripts `scripts_r/` existants : à faire au fil de l'eau, par script, quand ils sont rouverts.
- Helpers Python (cohérence multi-langage) : non discuté, restera mono-R.

## Vérification

1. Créer `helpers_r/charlson_quan.R` (par l'utilisateur).
2. Mettre à jour `helpers_r/README.md` avec la ligne correspondante.
3. Relancer `/ght-r ewma_mortalite_chirurgicale_mensuelle` → vérifier que le script généré contient `source("helpers_r/charlson_quan.R")` et `compute_charlson_quan(...)` à la place du proxy.
4. Exécuter le script sur le portail ATIH, vérifier que `auc_global` ≥ 0,75 (seuil annoncé dans la fiche).
5. Lancer `/ght-r` sur une nouvelle fiche utilisant Elixhauser → vérifier que la skill détecte aussi ce 2ᵉ helper.
