# Helpers R partagés

Bibliothèque locale de **briques de calcul réutilisables** consommées par
les scripts de `scripts_r/`. Chaque fichier expose **une fonction** prenant
des `tbl()` lazy dbplyr en entrée et retournant un `tbl()` lazy agrégé par
`ident` (ou clef équivalente), prêt à `left_join`.

Un script généré pour un indicateur (parcours `pdh-query` du dépôt
`basilefuchs/skills`) peut consulter cet index pour réutiliser un helper via
`source()` au lieu de recoder le calcul.

## Index

| Helper                   | Fichier                  | Rôle                                          | Entrée                | Sortie                |
|--------------------------|--------------------------|-----------------------------------------------|-----------------------|-----------------------|
| `compute_charlson_quan`  | `charlson_quan.R`        | Score de Charlson pondéré (Quan 2005)         | `tbl(ident, diag)`    | `tbl(ident, charlson)`|

> Pour ajouter un helper : créer un fichier R self-contained, l'ajouter à
> ce tableau (la skill lit la colonne *Rôle* en mots-clés pour matcher).

## Conventions

- **Une fonction par fichier**, nommée explicitement (`compute_*`,
  `filtre_*`, `mapping_*`).
- **Lazy dbplyr** quand possible : pas de `collect()` interne, la fonction
  retourne un `tbl()` que l'appelant compose dans son pipeline.
- **Pas de `library()`** — la skill garantit que `dplyr`/`dbplyr` sont chargés.
- **Pas de side-effect** : pure fonction, pas d'I/O, pas d'`options()`.
- **Compatibilité Teradata (portail ATIH)** : préférer `substr()` +
  `%in%` aux regex SQL-side qui varient selon le moteur.
- **En-tête de fichier** : `# nom — description — référence (article/PMID)
  — colonnes attendues`.
- **Hiérarchies / corrections méthodologiques** appliquées dans le helper
  lui-même (ex : Quan écrase `mild_liver` si `sev_liver`, `cancer` si
  `mets`). L'utilisateur ne doit pas avoir à y penser.

## Utilisation côté script

```r
source("helpers_r/charlson_quan.R")

charlson <- compute_charlson_quan(tbl_diag)

cohorte <- cohorte %>%
  left_join(charlson, by = "ident") %>%
  mutate(charlson = coalesce(charlson, 0L))
```

## Vérification

Pour valider un helper :

1. Le brancher dans un script existant (ex : `scripts_r/05_qualite_securite/ewma_mortalite_chirurgicale_mensuelle.R`).
2. Comparer le score obtenu à un échantillon avec une référence
   (calcul manuel sur 5 séjours, ou `comorbidity::comorbidity()` en local).
3. Vérifier la performance prédictive aval (ex : AUC du modèle de risque
   ≥ seuil annoncé dans la fiche de l'indicateur).
