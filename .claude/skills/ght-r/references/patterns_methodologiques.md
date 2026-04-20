# Patterns méthodologiques d'indicateurs PMSI

8 types canoniques d'indicateurs, chacun avec son squelette R à
placeholders. Identifier le type pendant l'étape 1 (analyse de la fiche)
via les mots-clés ci-dessous, puis adapter le squelette.

## Identification du type

| Mots-clés dans la fiche | Type | Section |
|---|---|---|
| "numérateur / dénominateur", "taux de", "proportion de" | `taux` | §1 |
| "attendu vs observé", "standardisé", "SMR", "O/E" | `ratio_standardise` | §2 |
| "médiane", "percentile", "quartile", "DMS", "délai" | `mediane_percentile` | §3 |
| "diversité", "entropie", "concentration", "Gini" | `mesure_diversite` | §4 |
| "parcours", "chaînage", "ré-hospitalisation", "séquence" | `parcours_sequentiel` | §5 |
| "score composite", "tableau de bord", "agrégat pondéré" | `score_composite` | §6 |
| "volume", "file active", "nombre de séjours" | `comptage_simple` | §7 |
| "distribution", "pyramide", "CMI moyen", "profil" | `distribution` | §8 |

Si ambigu, demander à l'utilisateur à l'étape 3.

---

## §1. `taux`

Formule : `numerateur / denominateur`

### Squelette

```r
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))
  # Tables additionnelles si besoin (diag, acte...)

  # Dénominateur : population éligible
  denom <- tbl_sejours %>%
    filter(<conditions_denom>) %>%
    distinct(<col_ident>, .keep_all = TRUE)

  # Numérateur : sous-ensemble qui vérifie la condition
  num <- denom %>%
    filter(<conditions_num>)

  # Agrégation
  denom %>%
    group_by(<col_groupe>) %>%
    summarise(N_total = n_distinct(<col_ident>), .groups = "drop") %>%
    left_join(
      num %>%
        group_by(<col_groupe>) %>%
        summarise(N_i = n_distinct(<col_ident>), .groups = "drop"),
      by = "<col_groupe>"
    ) %>%
    mutate(
      N_i = coalesce(N_i, 0L),
      taux = N_i / N_total,
      annee = an
    ) %>%
    collect()
})
```

### Pièges types

- **Toujours `distinct(<col_ident>)`** avant de compter : si la jointure
  remonte des tables N/séjour (diag, acte), un séjour peut apparaître
  plusieurs fois
- **Dénominateur nul** → `taux = NaN` : prévoir un filtre final sur
  `N_total > seuil_min` (souvent 30 pour la robustesse)

---

## §2. `ratio_standardise`

Formule : `observed / expected` (SMR, HSMR)

### Squelette

Nécessite deux passages :

1. Calcul du modèle d'attendu sur la population de référence (régression
   logistique typiquement) → `p_attendu` par strate
2. Application au numérateur observé

```r
# Phase 1 : modèle de référence (à calculer ou à charger)
# Si le modèle est pré-calculé (fourni par HAS/ATIH), charger les coefs
# Sinon, ajuster sur la population : glm(outcome ~ age + sexe + cormorb,
#   family = binomial)

# Phase 2 : application
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  tbl_sejours %>%
    filter(<conditions_inclusion>) %>%
    mutate(
      age_cl = case_when(<col_age> < 40 ~ "1",
                         <col_age> < 65 ~ "2",
                         TRUE ~ "3")
      # autres variables d'ajustement
    ) %>%
    collect() %>%
    left_join(coefs_attendus, by = c("age_cl", "sexe")) %>%
    group_by(<col_groupe>) %>%
    summarise(
      O = sum(<col_outcome>),
      E = sum(p_attendu),
      SMR = O / E,
      annee = an,
      .groups = "drop"
    )
})
```

### Pièges types

- Le calcul d'attendu se fait souvent **en local** après collect(), pas
  en SQL (stats R non traduisibles en SQL)
- Intervalles de confiance de Poisson : `qchisq(0.025, 2*O)/2` et
  `qchisq(0.975, 2*(O+1))/2`

---

## §3. `mediane_percentile`

Formule : percentile d'une distribution (DMS, délai avant chirurgie...)

### Squelette

```r
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  # dbplyr supporte median() et quantile() via SQL depuis la v2.x
  # Si le SGBD ne supporte pas, collect() puis quantile en R
  tbl_sejours %>%
    filter(<conditions>) %>%
    group_by(<col_groupe>) %>%
    summarise(
      n = n(),
      mediane = median(<col_valeur>, na.rm = TRUE),
      p25 = quantile(<col_valeur>, 0.25, na.rm = TRUE),
      p75 = quantile(<col_valeur>, 0.75, na.rm = TRUE),
      annee = an,
      .groups = "drop"
    ) %>%
    collect()
})
```

### Pièges types

- Les **séances** (CMD 28 en MCO) ont des durées aberrantes (0 ou 1 jour
  répété), souvent à exclure du calcul de DMS
- **`na.rm = TRUE`** impératif
- Sur Teradata, certains percentiles nécessitent `PERCENTILE_CONT` :
  dbplyr le gère mais vérifier la traduction avec `show_query()`

---

## §4. `mesure_diversite`

Formule : entropie de Shannon, Gini, Simpson... sur une distribution de
modalités (GHM, CMD, diagnostic...)

### Squelette

Deux phases : (1) extraction de la distribution, (2) calcul de l'index
en local.

```r
# Phase 1 : extraire la distribution par groupe × modalité
distribution <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  tbl_sejours %>%
    filter(<conditions>) %>%
    transmute(
      annee = an,
      <col_groupe>,
      modalite = <col_modalite>  # ex: substr(ghm2, 1, 5) pour racine GHM
    ) %>%
    group_by(annee, <col_groupe>, modalite) %>%
    summarise(N_i = n_distinct(<col_ident>), .groups = "drop") %>%
    collect()
})

# Phase 2 : calcul local de l'indice
calcul_shannon <- function(df) {
  df %>%
    group_by(annee, <col_groupe>) %>%
    mutate(p_i = N_i / sum(N_i)) %>%
    summarise(
      H = -sum(p_i * log2(p_i), na.rm = TRUE),
      H_max = log2(n()),
      H_norm = if_else(H_max > 0, H / H_max, 0),
      N_total = sum(N_i),
      .groups = "drop"
    )
}

resultat <- calcul_shannon(distribution)
```

### Pièges types

- Convention `0 × log2(0) = 0` : `na.rm = TRUE` suffit en pratique
- **Sensibilité au volume** : filtrer `N_total >= 500` avant
  interprétation
- Choix de granularité (GHM complet, racine, CMD) à paramétrer

---

## §5. `parcours_sequentiel`

Formule : condition sur une séquence de N séjours chaînés

### Squelette

```r
# Extraction des séjours bruts, un par ligne, triés
sejours <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  tbl_sejours %>%
    filter(<conditions_inclusion>) %>%
    transmute(
      <col_ident_patient>,  # ← pas ident séjour, mais ident patient chaîné !
      <col_finess>,
      date_debut = <col_date_entree>,
      date_fin = <col_date_sortie>,
      annee = an
    ) %>%
    collect()
})

# Reconstitution des parcours
parcours <- sejours %>%
  arrange(<col_ident_patient>, date_debut) %>%
  group_by(<col_ident_patient>) %>%
  mutate(
    sejour_suivant_finess = lead(<col_finess>),
    delai_suivant_jours = as.numeric(lead(date_debut) - date_fin)
  ) %>%
  ungroup() %>%
  filter(!is.na(delai_suivant_jours),
         delai_suivant_jours <= <delai_max>)

# Calcul de l'indicateur de parcours
resultat <- parcours %>%
  mutate(
    intra_perimetre = <col_finess> %in% <liste_finess_ght> &
                      sejour_suivant_finess %in% <liste_finess_ght>
  ) %>%
  group_by(annee) %>%
  summarise(
    n_parcours = n(),
    n_intra = sum(intra_perimetre),
    taux_continuite = n_intra / n_parcours,
    .groups = "drop"
  )
```

### Pièges types

- Bien distinguer **identifiant séjour** (`ident`, unique par séjour) et
  **identifiant patient** (chaînage, permet de relier plusieurs séjours)
- `lead()` et `lag()` nécessitent un `arrange()` stable avant `group_by`
- Délai de chaînage **à paramétrer** (30/60/90 jours selon la fiche)
- Les hospitalisations le même jour (transferts) : délai = 0, à inclure
  explicitement ou exclure selon la méthodologie

---

## §6. `score_composite`

Formule : combinaison pondérée de plusieurs sous-indicateurs

### Squelette

```r
# Calculer chaque sous-indicateur séparément (réutiliser les patterns
# §1-§5 selon la nature de chaque sous-indicateur)

ind_a <- <calcul pattern taux>       # ex: taux de mortalité
ind_b <- <calcul pattern mediane>    # ex: DMS
ind_c <- <calcul pattern comptage>   # ex: volume

# Combinaison
resultat <- ind_a %>%
  select(<col_groupe>, annee, val_a = <valeur>) %>%
  inner_join(
    ind_b %>% select(<col_groupe>, annee, val_b = <valeur>),
    by = c("<col_groupe>", "annee")
  ) %>%
  inner_join(
    ind_c %>% select(<col_groupe>, annee, val_c = <valeur>),
    by = c("<col_groupe>", "annee")
  ) %>%
  mutate(
    # Normalisation et pondération
    score = <poids_a> * scales::rescale(val_a, to = c(0, 1)) +
            <poids_b> * scales::rescale(val_b, to = c(0, 1)) +
            <poids_c> * scales::rescale(val_c, to = c(0, 1))
  )
```

### Pièges types

- **Sens des variables** : certaines baissent quand la qualité monte
  (mortalité), d'autres montent (survie). Inverser avant normalisation
- Normalisation : min-max (`scales::rescale`) ou rang (`percent_rank`)
- Gestion des manquants sur un sous-indicateur : exclure l'établissement
  ou imputer ?

---

## §7. `comptage_simple`

Formule : dénombrement (séjours, patients, journées)

### Squelette

```r
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  tbl_sejours %>%
    filter(<conditions>) %>%
    group_by(<col_groupe>) %>%
    summarise(
      n_sejours = n_distinct(<col_ident>),
      n_patients = n_distinct(<col_ident_patient>),  # si chaînage dispo
      n_journees = sum(<col_duree>, na.rm = TRUE),
      annee = an,
      .groups = "drop"
    ) %>%
    collect()
})
```

### Pièges types

- CMD 28 (séances) : **1 séance = 1 séjour** → gonfle `n_sejours`.
  Dénombrer soit à part, soit en excluant
- `n()` (lignes brutes) ≠ `n_distinct(ident)` (séjours uniques) —
  utiliser le second

---

## §8. `distribution`

Formule : profil d'une variable sur une population (pyramide des âges,
CMI moyen, répartition par CMD...)

### Squelette

```r
resultat <- purrr::map_dfr(annees, function(an) {

  tbl_sejours <- tbl(conn, I(paste0("<prefix>_", an, ".<table_sejours>")))

  tbl_sejours %>%
    filter(<conditions>) %>%
    mutate(classe = case_when(
      <col_valeur> < <s1> ~ "< <s1>",
      <col_valeur> < <s2> ~ "<s1>-<s2>",
      TRUE ~ ">= <s2>"
    )) %>%
    group_by(<col_groupe>, classe) %>%
    summarise(
      n = n_distinct(<col_ident>),
      annee = an,
      .groups = "drop"
    ) %>%
    group_by(<col_groupe>, annee) %>%
    mutate(prop = n / sum(n)) %>%
    collect()
})
```

### Pièges types

- Choix des classes : quantiles (équilibrés) vs seuils fixes (comparables
  dans le temps)
- Normalisation `n / sum(n)` pour comparer des établissements de tailles
  différentes
