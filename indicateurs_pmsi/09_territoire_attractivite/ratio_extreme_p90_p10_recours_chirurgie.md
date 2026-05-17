# Ratio extrême P90/P10 du recours chirurgical (Atlas IRDES)

## Définition

Le **ratio extrême P90/P10** mesure l'amplitude des disparités territoriales du taux de recours en comparant le 9ème décile au 1er décile de la distribution des taux standardisés sur l'ensemble des territoires. Il est l'indicateur de **variation extrême** retenu par l'IRDES dans son *Atlas des variations de pratiques médicales – Recours à 11 interventions chirurgicales* (2024) et le Dartmouth Atlas.

Formellement, pour une intervention *k* :

```
RE(k) = P90( TR_z(k) ) / P10( TR_z(k) )
```

où la distribution est calculée sur l'ensemble des territoires *z* (départements, zones d'attractivité ou GHT). Un ratio = 1 signifie pratique homogène ; un ratio = 3 signifie que les territoires du décile haut opèrent 3 fois plus que ceux du décile bas, à structure démographique standardisée.

Pour un classement multi-interventions, on agrège par moyenne géométrique :

```
RE_global = ( Π_k RE(k) )^(1/K)
```

Positionnement vs `coefficient_variation_pondere_recours_irdes.md` :
- Le CV_w résume la dispersion **globale** (sensible à toute la distribution).
- Le P90/P10 capture l'**amplitude extrême** (insensible au centre, robuste aux valeurs aberrantes uniques).
- Les deux sont complémentaires : un CV_w faible et un P90/P10 élevé indiquent quelques territoires extrêmes dans une masse homogène ; l'inverse indique une variation diffuse.

## Calcul

**Source PMSI** : RSA MCO + table actes CCAM.

**Variables PMSI mobilisées** : identiques à `coefficient_variation_pondere_recours_irdes.md` — `CODE_GEO_RESIDENCE`, `AGE_ANNEE`, `SEXE`, `CODE_ACTE_CCAM`, `DP`, `DAS`.

**Liste des 11 interventions IRDES** : voir `coefficient_variation_pondere_recours_irdes.md` § Calcul.

**Pseudocode** :

```r
# 1. Calculer le taux standardisé TR_z(k) par territoire et par intervention
tr_std_k <- map_dfr(1:11, function(k) {
  pmsi %>%
    filter(annee == A, intervention_irdes(actes_ccam, dp, das, k = k)) %>%
    count(zone, classe_age, sexe) %>%
    left_join(pop_insee, by = c("zone","classe_age","sexe")) %>%
    mutate(taux_brut = n / pop * 100000) %>%
    left_join(pop_ref_nat, by = c("classe_age","sexe")) %>%
    group_by(zone) %>%
    summarise(
      tr_z = sum(taux_brut * pop_ref) / sum(pop_ref),
      pop_z = sum(pop),
      .groups = "drop"
    ) %>%
    mutate(intervention = k)
})

# 2. Calculer P90/P10 par intervention
re_par_intervention <- tr_std_k %>%
  filter(pop_z >= 50000) %>%                              # seuil démographique
  group_by(intervention) %>%
  summarise(
    p10 = quantile(tr_z, 0.10, na.rm = TRUE),
    p90 = quantile(tr_z, 0.90, na.rm = TRUE),
    ratio_extreme = p90 / p10,
    .groups = "drop"
  )

# 3. Agrégat moyenne géométrique
re_global <- re_par_intervention %>%
  summarise(re_global = exp(mean(log(ratio_extreme))))
```

**Conventions cas limites** :
- Quantiles **pondérés par la population** (variante recommandée) : utiliser `Hmisc::wtd.quantile(tr_z, weights = pop_z)` pour cohérence avec le CV_w.
- Territoire avec `tr_z = 0` : exclu du calcul P10 (`tr_z + ε` ou exclusion documentée).
- Volume minimal recommandé par territoire-intervention : 20 séjours/an, sinon shrinkage bayésien préalable.
- Toujours rapporter le **nombre de territoires** retenu dans le calcul.

## Utilité

1. **Communication grand public** : « entre les 10 % de territoires opérant le plus et les 10 % opérant le moins, le ratio est de 3,5 » — phrase actionnable pour ARS / médias.
2. **Identification des extrêmes** : repérer nommément les territoires en P10 (suspicion sous-recours / accès) et P90 (suspicion sur-recours / pratiques).
3. **Pilotage IRDES / DGOS** : indicateur officiel synthétique de la pertinence territoriale, déclinable par discipline.
4. **Robustesse vs outliers** : un seul département outlier ne fait pas exploser le P90/P10 comme il pourrait exploser un CV. Plus stable pour suivi pluriannuel.
5. **Convergence des pratiques** : la baisse pluriannuelle du P90/P10 est l'objectif chiffré d'une politique de pertinence — cible CPOM ARS possible.
6. **Comparaison internationale** : métrique standard du Dartmouth Atlas et OECD Atlas of Variations — comparaison directe France vs autres pays.
7. **Hiérarchisation des interventions** : trier les 11 interventions IRDES par P90/P10 décroissant pour prioriser les chantiers pertinence.

## Sources de Données

- **PMSI MCO** : RSA + table actes CCAM. ATIH, guide méthodologique en vigueur.
- **INSEE** : populations municipales par âge × sexe.
- **Listes IRDES** : codes CCAM/CIM-10 des 11 interventions — Atlas IRDES 2024 et annexes méthodologiques.
- **Zonage** : départements (analyse principale IRDES) ou zones d'attractivité ATIH (analyse fine).

## Exemple de Valeurs

Ordre de grandeur indicatif issu de la littérature Atlas of Variations (Wennberg, OECD) et synthèse de l'Atlas IRDES, à confirmer sur l'édition en cours :

| Intervention | P90/P10 attendu (départements FR) |
|---|---|
| Césarienne | 1,4 – 1,8 |
| Prothèse hanche post-fracture | 1,3 – 1,7 |
| Cataracte | 1,8 – 2,5 |
| Cholécystectomie | 1,8 – 2,4 |
| Hystérectomie | 2,0 – 3,0 |
| Amygdalectomie | 2,5 – 3,5 |
| RTUP prostate | 2,5 – 4,0 |
| Chirurgie bariatrique | 3,5 – 6,0 |

Lectures :
- P90/P10 < 1,5 : pratique relativement homogène.
- P90/P10 ∈ [1,5 ; 2,5] : variation modérée acceptable selon contexte.
- P90/P10 > 2,5 : variation extrême → enquête pertinence prioritaire.

Source des plages : ordre de grandeur expert et littérature Dartmouth/OECD, non sourcé au chiffre près sur édition IRDES 2024.

## Limites

- **Insensible aux extrêmes au-delà du P90/P10** : un P95/P5 peut être 2× plus élevé. Compléter avec autres percentiles si besoin de tail risk.
- **Petit nombre de territoires** : sur 100 départements, P10/P90 = 10ème et 90ème valeurs — bruit statistique non négligeable pour interventions rares.
- **Shrinkage à appliquer** : sans correction, les départements à faible volume affichent des taux instables qui peuvent gonfler artificiellement le ratio.
- **Non interprétable comme « écart à la cible »** : l'indicateur dit qu'il y a variation, pas où est le bon niveau. Ne désigne pas le décile haut comme excès ni le décile bas comme insuffisance.
- **Effet pondération** : ratio sur quantiles non pondérés peut donner du poids aux petits départements. Préférer quantiles pondérés population pour cohérence.
- **Échelle géographique** : MAUP — passage département ↔ zone d'attractivité peut multiplier ou diviser le ratio par 2.
- **Standardisation âge/sexe seule** : ne neutralise pas la morbidité (cf. limites équivalentes pour CV_w).
- **Liste fermée IRDES** : 11 interventions. Élargir nécessite validation méthodologique.

## Références

- IRDES, *Atlas des variations de pratiques médicales – Recours à 11 interventions chirurgicales*, Ouvrage n°9, 2024. URL : https://www.irdes.fr/recherche/2024/ouvrage-009-atlas-des-variations-de-pratiques-medicales-recours-a-onze-interventions-chirurgicales.html
- Wennberg, J.E., et al. *The Dartmouth Atlas of Health Care*. URL : https://www.dartmouthatlas.org
- OECD, *Geographic Variations in Health Care*, OECD Health Policy Studies, 2014. DOI : 10.1787/9789264216594-en
- DREES, ER 1262 (avril 2023) — hospitalisations potentiellement évitables. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2023-04/ER1262EMB.pdf
- Voir aussi `coefficient_variation_pondere_recours_irdes.md`, `taux_recours_standardise_age_sexe.md`.
