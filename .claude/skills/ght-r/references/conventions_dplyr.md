# Conventions R/dplyr — Génération de code PMSI

## 1. Environnement d'exécution

- Exécution sur SGBD distant via **dbplyr** (typiquement Teradata sur le
  portail ATIH, mais le code généré doit rester agnostique du SGBD)
- Connexion encapsulée dans une fonction utilisateur — **ne pas réécrire** :
  ```r
  conn <- pRatihque::connection_database()
  ```
- Si l'utilisateur utilise un autre wrapper de connexion, adapter cette
  ligne uniquement
- Libs disponibles : tidyverse complet (dplyr, dbplyr, purrr, tidyr,
  readr, stringr, lubridate, ggplot2)
- **Toujours** charger les libs explicitement, **jamais**
  `library(tidyverse)` en bloc

## 2. Référencement des vues

Schémas annuels, une vue par type. Pattern de référencement :

```r
tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))
```

`I()` est **impératif** pour que dbplyr traite la chaîne comme un nom
qualifié (schéma.vue) et non comme un identifier à quoter.

**Convention de nommage** : suffixe `_tbl` pour les références lazy
(avant `collect()`), nom nu après `collect()`.

## 3. Itération multi-année — pattern canonique

```r
annees <- 2016:2025

resultat <- purrr::map_dfr(annees, function(an) {

  tbl_fixe <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))

  tbl_fixe %>%
    filter(...) %>%
    ...
    transmute(..., annee = an) %>%
    group_by(annee, ...) %>%
    summarise(..., .groups = "drop") %>%
    collect()
})
```

Règles strictes :

- **`map_dfr`**, pas `map() |> list_rbind()` (convention locale)
- Fonction **anonyme** inline, pas de fonction externe nommée (sauf
  calcul méthodologique complexe réutilisable)
- `annee = an` **matérialisée** dans le résultat via `transmute`/`mutate`
  — sinon perdue au `collect()`
- `collect()` **dans** la fonction, pas après le `map_dfr`

## 4. Ordre des verbes dbplyr

Ordre qui optimise le SQL généré :

1. `filter()` — réduire le volume tôt
2. `inner_join()` / `left_join()` — avec `select()` *dans* le join pour
   limiter les colonnes
3. `transmute()` ou `mutate()` — créer / renommer
4. `group_by()` + `summarise(.groups = "drop")`
5. `collect()` — toujours en dernier

## 5. Préférences de style

| Règle | Préférer | Éviter |
|---|---|---|
| Découpe de chaînes | `substr(x, 1, 5)` | `stringr::str_sub(x, 1, 5)` |
| Sélection + renommage | `transmute()` | `select()` + `mutate()` |
| Agrégation | `.groups = "drop"` | laisser le warning dplyr |
| Dénombrement patients | `n_distinct(ident)` | `length(unique(ident))` |
| Jointure sélective | `select()` **dans** le join | projeter après |
| Concaténation noms | `paste0()` | `sprintf()`, `glue()` |

## 6. Nommage

- Variables de périmètre courtes : `an`, `dep`, `finessgeo`
- Numérateur/dénominateur : `N_i`, `N_total`
- Indicateurs mathématiques selon notation d'origine : `H`, `H_norm`, `SMR`
- Paramètres utilisateur en tête, dans un bloc `# ==== PARAMÈTRES ====`

## 7. Squelette de script standard

```r
# ==============================================================================
# Indicateur : <LIBELLE>
# Source     : <HAS / ATIH / ANAP / custom>
# Pattern    : <§N — taux / mesure_diversite / parcours_sequentiel / ...>
# Fiche      : <chemin indicateurs_pmsi/NN_categorie/nom.md>
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé) ====
# À réutiliser en tête des prochains prompts pour sauter l'étape de mapping
#
# Séjour (1 ligne)      : <table_sejours>.<col_ident>
# GHM                   : <table_sejours>.<col_ghm>
# DP                    : <table_sejours>.<col_dp>
# Actes CCAM            : <table_actes>.<col_acte>
# ...
# ==========================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)

conn <- pRatihque::connection_database()

# ==== PARAMÈTRES ====
annees <- 2016:2025
# <Autres paramètres ouverts avec valeurs suggérées en commentaire>
#   delai_jours <- 90       # fiche propose 30/60/90

# ==== EXTRACTION ====
<map_dfr sur les années>

# ==== CALCUL MÉTHODOLOGIQUE ====
<fonction spécifique à l'indicateur si besoin>

# ==== RÉSULTAT ====
print(resultat)

# ==== VISUALISATION ====
<ggplot timeseries>

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat, "indicateur_<nom>.csv")
```

## 8. Visualisation — série temporelle par établissement

Pattern canonique :

```r
ggplot2::ggplot(df, aes(x = annee, y = <indicateur>, color = rs)) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point() +
  facet_wrap(~ reorder(rs, rs), scales = "free_y") +
  scale_x_continuous(breaks = annees) +
  scale_y_continuous(limits = c(<min>, <max>)) +
  theme_minimal() +
  theme(legend.position = "none")
```

Règles :

- `geom_smooth` **avant** `geom_point` (points au-dessus)
- `scales = "free_y"` dans facet pour absorber les différences d'échelle
- `reorder(rs, rs)` → tri alphabétique stable des facets
  (**volontaire** — ne pas "simplifier" en enlevant le reorder)
- `legend.position = "none"` quand la couleur redouble le facet
- Limites Y selon nature :
  - Taux : `c(0, 1)` ou `c(0, 100)`
  - Ratio standardisé : `NULL` (auto)
  - Entropie normalisée : `c(0, 1)`
  - Comptages : `c(0, NA)`

## 9. À éviter

- `rowwise()` sur dbplyr lazy : non supporté → `collect()` avant
- `arrange()` avant `collect()` : rarement utile, mieux après
- `pull()` anticipé : casse le pattern lazy, rester sur tibble jusqu'à
  la viz
- Boucle `for` sur les années : toujours `map_dfr`
- `library(tidyverse)` en bloc : charger explicitement
- Traduire les fonctions R en SQL manuellement : dbplyr le fait
  (`substr`, `case_when`, `n_distinct`... sont traduits automatiquement)
