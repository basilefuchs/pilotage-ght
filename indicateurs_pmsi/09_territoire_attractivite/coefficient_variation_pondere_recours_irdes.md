# Coefficient de variation pondéré du recours (méthode IRDES / Dartmouth)

## Définition

Le **coefficient de variation pondéré** mesure la dispersion inter-territoires du taux de recours standardisé pour une intervention donnée, en pondérant chaque territoire par sa population. Il est issu de la méthodologie **Dartmouth Atlas of Health Care** (Wennberg) et utilisé par l'**IRDES** dans son *Atlas des variations de pratiques médicales – Recours à 11 interventions chirurgicales* (2024).

Conceptuellement, c'est l'écart-type des taux standardisés rapporté à la moyenne, mais pondéré pour neutraliser le poids démesuré de très petits territoires. Formellement, pour une intervention *k* :

```
CV_w(k) = √( Σ_z w_z × (TR_z(k) − TR_moy(k))² ) / TR_moy(k)
```

avec :
- `z` indexe les territoires (département, zone d'attractivité, GHT),
- `TR_z(k)` = taux de recours standardisé âge × sexe de l'intervention *k* dans le territoire *z*,
- `w_z = pop(z) / pop_tot` = poids démographique,
- `TR_moy(k) = Σ_z w_z × TR_z(k)` = moyenne nationale pondérée.

Un CV_w élevé signale une variation injustifiée entre territoires — au-delà de ce que la morbidité standardisée explique — assimilable à de la « pratique médicale variable » au sens de Wennberg.

Positionnement vs indicateurs existants :
- `taux_recours_standardise_age_sexe.md` (cat 09) calcule le **niveau** par territoire.
- `taux_recours_ajuste_fdep.md` neutralise la précarité.
- Le présent indicateur **résume la distribution inter-territoires en un seul nombre** par intervention — il est l'agrégat statistique national.

## Calcul

**Source PMSI** : RSA MCO (+ table actes CCAM pour identifier les 11 interventions).

**Liste des 11 interventions IRDES 2024** :
1. Prothèse de hanche après fracture
2. Prothèse du genou
3. Chirurgie du syndrome du canal carpien
4. Chirurgie de la cataracte
5. Amygdalectomie
6. Pose de stent coronaire (hors IDM)
7. Chirurgie bariatrique
8. Cholécystectomie
9. Césarienne
10. Hystérectomie
11. Résection trans-urétrale de la prostate (RTUP, tumeur bénigne)

Chaque intervention est définie par une combinaison spécifique de codes CCAM (et parfois CIM-10 pour exclure les indications hors champ). **Reprendre les listes opérationnelles de l'Atlas IRDES** plutôt que de les redéfinir.

**Variables PMSI mobilisées** :
- `CODE_GEO_RESIDENCE` → mapping territoire (département ou zone d'attractivité ATIH)
- `AGE_ANNEE`, `SEXE`
- `CODE_ACTE_CCAM` (table actes) → identification de l'intervention *k*
- `DP`, `DAS` → exclusion d'indications hors champ pour certaines interventions
- `NUM_FINESS_GEO` → uniquement pour vérifier publique/privée si on veut décliner

**Pseudocode** :

```r
# 1. Pour chaque intervention k, calculer le taux standardisé par territoire z
tr_std <- pmsi %>%
  filter(annee == A, intervention_irdes(actes_ccam, dp, das, k = K)) %>%
  count(zone, classe_age, sexe, name = "n_int") %>%
  left_join(pop_insee, by = c("zone","classe_age","sexe")) %>%
  mutate(taux_brut = n_int / pop * 100000) %>%
  left_join(pop_ref_nat, by = c("classe_age","sexe")) %>%
  group_by(zone) %>%
  summarise(
    tr_z = sum(taux_brut * pop_ref) / sum(pop_ref),
    pop_z = sum(pop),
    .groups = "drop"
  )

# 2. Calculer la moyenne pondérée et le CV pondéré
result <- tr_std %>%
  mutate(w = pop_z / sum(pop_z)) %>%
  summarise(
    tr_moy = sum(w * tr_z),
    var_w  = sum(w * (tr_z - sum(w * tr_z))^2),
    cv_w   = sqrt(var_w) / tr_moy
  )
```

**Conventions cas limites** :
- Territoires avec population < 50 000 hab : exclure ou regrouper (zones d'attractivité IRDES = ~150 zones environ pour la France).
- Codes géographiques `99xxx` : exclure du numérateur ET du dénominateur.
- Effectif < 30 séjours/an/zone pour l'intervention *k* : taux instable ; appliquer un shrinkage bayésien (James-Stein ou modèle hiérarchique) avant le calcul du CV pour ne pas surestimer la variation.
- Recommandation : produire un CV brut **et** un CV après shrinkage — l'écart entre les deux quantifie le bruit statistique.

## Utilité

1. **Diagnostic territorial structurel** : identifier les interventions les plus « variables » (CV_w > 0,30) — généralement les actes à décision médicale forte (cataracte, hystérectomie, RTUP).
2. **Pilotage HAS / DGOS** : alimenter la liste des actes à pertinence à surveiller, alignée sur les travaux IRDES.
3. **Comparaison internationale** : reproduit la métrique du *Dartmouth Atlas* (US) et de l'OECD Atlas of Variations — permet le benchmark France/OECD.
4. **Ciblage MSAP / CPOM** : un CV_w élevé combiné à un sur-recours dans certains territoires oriente l'action vers MSAP ou contractualisation.
5. **Surveillance temporelle** : suivi annuel — une baisse du CV_w témoigne d'une convergence des pratiques, signal d'efficacité des politiques de pertinence.
6. **Filtre méthodologique** : avant publication d'un classement de territoires, vérifier que le CV_w post-shrinkage reste significatif — sinon la variation est du bruit.
7. **Alimentation du dialogue clinique** : un CV_w élevé est l'argument quantitatif pour ouvrir une discussion avec les sociétés savantes sur la standardisation des indications.

## Sources de Données

- **PMSI MCO** : RSA + table actes CCAM. Variables `CODE_GEO_RESIDENCE`, `AGE_ANNEE`, `SEXE`, `CODE_ACTE_CCAM`, `DP`, `DAS`. Guide méthodologique MCO ATIH en vigueur.
- **INSEE** : populations municipales par âge × sexe (millésime cohérent).
- **Listes opérationnelles IRDES** : codes CCAM et CIM-10 définissant chacune des 11 interventions. À récupérer dans la publication IRDES ou ses annexes méthodologiques.
- **Zonage géographique** : zones d'attractivité hospitalière ATIH (option) ou départements (publication IRDES principale).

Restitution publique de référence : IRDES, *Atlas des variations de pratiques médicales – Recours à 11 interventions chirurgicales*, 2024.

## Exemple de Valeurs

Ordre de grandeur indicatif issu de la littérature Wennberg et Atlas IRDES (à confirmer sur l'édition courante de l'Atlas IRDES) :

| Intervention | CV_w pondéré observé (départements FR) |
|---|---|
| Prothèse hanche après fracture | 0,10 – 0,15 (faible variation, contrainte par la fracture) |
| Cataracte | 0,25 – 0,35 |
| Amygdalectomie | 0,30 – 0,45 |
| Hystérectomie | 0,25 – 0,40 |
| Chirurgie bariatrique | 0,40 – 0,60 (forte variation, décision élective) |
| Césarienne | 0,10 – 0,18 (cf. également `taux_cesariennes_standardise_drees`) |

Lectures :
- CV_w < 0,15 : intervention « contrainte » (urgence, indication étroite).
- CV_w ∈ [0,15 ; 0,30] : variation modérée, à surveiller.
- CV_w > 0,30 : variation injustifiée probable → action pertinence prioritaire.

Source des plages : extrapolation de la littérature Wennberg / OECD et résumé IRDES — non sourcé au chiffre près sur l'édition 2024.

## Limites

- **Confusion variation réelle / bruit statistique** : sans shrinkage, les petits territoires gonflent artificiellement le CV_w. Toujours produire la version corrigée.
- **Standardisation limitée à âge × sexe** : ne neutralise pas la morbidité (ex : prévalence du surpoids pour bariatrique, du tabagisme pour stent). Une variation peut être médicalement justifiée.
- **Lieu de résidence vs lieu d'offre** : un territoire sous-recours peut être un territoire sans offre — l'indicateur ne distingue pas demande de offre.
- **Liste fermée de 11 interventions** : non extrapolable à d'autres actes sans validation IRDES.
- **Effet maille géographique** : passer du département à la zone d'attractivité (~150 zones) ou au territoire de santé change fortement la valeur (MAUP — Modifiable Areal Unit Problem).
- **Évolution CCAM/CIM-10** : changements de codification entre années → casse les comparaisons pluri-annuelles sans correction.
- **Pondération démographique** : un CV_w peut masquer des écarts forts entre petits territoires (« France périphérique »). Compléter avec ratio extrême P90/P10 (cf. `ratio_extreme_p90_p10_recours_chirurgie.md`).
- **Pas d'intervalle de confiance natif** : à compléter par bootstrap territoire pour intervalle de confiance autour du CV_w.

## Références

- IRDES, *Atlas des variations de pratiques médicales – Recours à 11 interventions chirurgicales*, Ouvrage n°9, 2024. URL : https://www.irdes.fr/recherche/2024/ouvrage-009-atlas-des-variations-de-pratiques-medicales-recours-a-onze-interventions-chirurgicales.html
- Wennberg, J.E. *Tracking Medicine: A Researcher's Quest to Understand Health Care*. Oxford University Press, 2010 — fondement méthodologique du Dartmouth Atlas.
- OECD, *Geographic Variations in Health Care: What Do We Know and What Can Be Done to Improve Health System Performance?* OECD Health Policy Studies, 2014. DOI : 10.1787/9789264216594-en
- DREES, ER 1262 (avril 2023) — hospitalisations potentiellement évitables et gradient social. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2023-04/ER1262EMB.pdf
- Voir aussi `taux_recours_standardise_age_sexe.md`, `ratio_extreme_p90_p10_recours_chirurgie.md`, `taux_recours_ajuste_fdep.md`.
