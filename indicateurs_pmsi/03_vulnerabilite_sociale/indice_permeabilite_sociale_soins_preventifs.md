# Indice de Perméabilité Sociale aux Soins Préventifs

## Définition
L'**indice de perméabilité sociale aux soins préventifs** mesure la facilité avec laquelle les soins préventifs et ambulatoires "percolent" à travers le tissu social d'un territoire pour atteindre les populations qui en ont besoin. L'analogie est empruntée à l'hydrogéologie : en milieu poreux, la **perméabilité de Darcy** (loi de Darcy, 1856) quantifie la résistance qu'oppose un milieu au passage d'un fluide sous l'effet d'un gradient de pression. Transposée à la santé publique, la "pression motrice" est le besoin de soins non satisfait (charge de morbidité chronique d'un territoire), le "fluide" est l'accès effectif aux soins préventifs, et la "perméabilité" est la capacité sociale, géographique et organisationnelle du territoire à convertir ce besoin en recours aux soins.

Un territoire **imperméable** — comme une roche argileuse — présente de forts besoins de santé mais un recours très faible aux soins préventifs : les barrières sociales (précarité, isolement, illectronisme, absence de médecin traitant), géographiques (déserts médicaux) et culturelles (défiance vis-à-vis du système de santé) bloquent le fluide de soins comme une couche imperméable bloque l'eau. La conséquence mesurable dans le PMSI est l'accumulation d'[[taux_hospitalisations_potentiellement_evitables|hospitalisations potentiellement évitables]] — les pathologies chroniques mal contrôlées qui "débordent" en urgences faute d'avoir été gérées en amont, comme une nappe d'eau qui s'accumule derrière une couche imperméable jusqu'à saturer et s'écouler en crue.

À l'inverse, un territoire **très perméable** convertit efficacement les besoins de santé en recours préventifs et ambulatoires : les pathologies chroniques sont stabilisées, les hospitalisations évitables sont rares, et les urgences ne sont pas le point d'entrée par défaut dans le système de soins.

## Calcul

### 1. Coefficient de perméabilité territoriale (K_p)

Inspiré de la loi de Darcy : Q = −K × A × (ΔP / L)

```
K_p(territoire T) = Recours_effectif(T) / [Charge_morbidité(T) × Recours_attendu_national]

  → Recours_effectif(T)         = 1 − Taux_HPE_observé(T)
                                  (HPE = hospitalisations potentiellement évitables,
                                   PQI — Prevention Quality Indicators)
  → Charge_morbidité(T)         = Prévalence standardisée des pathologies chroniques
                                   traceurs sur le territoire T (diabète, BPCO, ICC,
                                   HTA, asthme — depuis PMSI + SNDS)
  → Recours_attendu_national    = 1 − Taux_HPE_national_référence (base 1,0)

  → K_p = 1,0 : perméabilité dans la norme nationale
  → K_p > 1,0 : territoire sur-perméable (recours préventif supérieur aux besoins)
  → K_p 0,5–1,0 : perméabilité réduite, barrières partielles
  → K_p < 0,5 : territoire imperméable, besoins non convertis en soins préventifs
```

### 2. Gradient de perméabilité sociale (ΔK_p / ΔFDep)

```
Gradient = ΔK_p / ΔFDep9

  → FDep9 = indice de défavorisation sociale par commune (Pasipanodya/Rey,
             quintiles de 1 = favorisé à 5 = très défavorisé)
  → Gradient négatif (normal) : K_p diminue quand FDep augmente
    → Les territoires les plus défavorisés sont les moins perméables
  → Gradient plat ou positif (anomalie) : la perméabilité ne varie pas avec
    la défavorisation — signal d'un système de santé non différencié
    ou de politiques de santé communautaire efficaces

Gradient standardisé :
  ΔK_p/ΔFDep_s = (K_p(Q5) − K_p(Q1)) / K_p(Q1) × 100
  → Exprimé en % de perte de perméabilité entre le quintile le plus
    favorisé et le plus défavorisé du territoire du GHT
```

### 3. Cartographie des "couches imperméables" (zones d'accumulation)

```
Zones imperméables = communes ou bassins de vie avec :
  K_p < 0,5
  ET FDep9 quintile 4 ou 5
  ET Taux_HPE > 1,5 × médiane régionale

  → Analogie géologique : ces zones sont les "aquitards" du territoire —
    couches qui bloquent la circulation du fluide de soins et accumulent
    une pression de besoins non satisfaits
```

Indicateurs satellites pour confirmer l'imperméabilité :
- [[taux_patients_sans_medecin_traitant|Taux de patients sans médecin traitant]] déclaré > 15 %
- Part des entrées MCO par les urgences > 50 %
- [[delai_diagnostic_traitement_cancer|Délai moyen diagnostic-traitement cancer]] > référence nationale
- [[taux_sortie_contre_avis_medical|Taux de sortie contre avis médical]] > 5 %

### 4. Indice de perméabilité composite (IPC)

```
IPC = K_p × (1 / Gradient_social) × Densité_soins_primaires_pondérée

  → Densité_soins_primaires = médecins généralistes + infirmiers libéraux
    pour 10 000 habitants (depuis RPPS/ADELI géolocalisé)
  → Pondération par accessibilité (APL — Accessibilité Potentielle Localisée, DREES)
  → IPC permet de distinguer l'imperméabilité sociale (FDep élevé, K_p bas)
    de l'imperméabilité structurelle (désert médical, K_p bas indépendamment du FDep)
```

**Précisions méthodologiques** :
- Les HPE traceurs retenus sont celles de la liste [[pqi_prevention_quality_indicators|PQI]] de l'AHRQ adaptée au contexte français par la HAS et la DREES : diabète (complications aiguës et chroniques), BPCO, insuffisance cardiaque, hypertension, asthme de l'adulte, angine de poitrine — identifiables dans le PMSI par les codes CIM-10 du diagnostic principal.
- La prévalence des pathologies chroniques traceurs est issue du SNDS (cartographie des pathologies et des dépenses, CNAM) ou, à défaut, estimée depuis la fréquence des séjours MCO avec ces DP sur le territoire.
- L'analyse est réalisée à l'échelon communal ou du bassin de vie, puis agrégée au territoire du GHT.

## Utilité

- **Priorisation des actions de prévention territoriale** : les zones à faible K_p et fort FDep sont les "zones cibles" prioritaires pour les programmes de prévention, les maisons de santé pluriprofessionnelles, les médiateurs de santé et les actions de dépistage communautaire — le GHT dispose d'un argument objectif pour allouer ses ressources de prévention là où la perméabilité est la plus basse.
- **Dialogue avec l'ARS et les collectivités** : l'IPC est un outil de plaidoyer pour l'installation de professionnels de santé dans les zones imperméables, le financement de CPTS dans les bassins de vie à fort gradient social, et la révision des plans locaux de santé publique.
- **Évaluation de l'impact des politiques de prévention** : mesurer l'évolution de K_p avant et après le déploiement d'une maison de santé, d'un programme d'éducation thérapeutique ou d'une action de médiation sanitaire — un programme efficace se traduit par une augmentation de K_p dans la zone ciblée.
- **Anticipation des hospitalisations évitables** : les communes à K_p très faible sont des "réservoirs" d'hospitalisations potentiellement évitables à moyen terme — leur identification précoce permet au GHT d'anticiper la demande de soins aigus et de cibler les ressources en amont.
- **Dimension sociale de la responsabilité populationnelle** : dans le cadre des projets médicaux de territoire (PMT), l'IPC objectivise la responsabilité du GHT vis-à-vis des populations les plus imperméables — populations qui consomment peu de soins préventifs mais arrivent en hospitalisation dans des états de gravité supérieure à la moyenne.
- **Corrélation avec la mortalité prématurée évitable** : les zones à faible K_p sont corrélées avec les [[taux_deces_prematures|taux de mortalité prématurée évitable]] (DREES) — l'indicateur relie directement la performance organisationnelle du territoire à ses résultats de santé populationnelle.

## Sources de Données

- **PMSI MCO** : diagnostic principal (DP) et codes CIM-10 des hospitalisations potentiellement évitables (diabète, BPCO, ICC, HTA, asthme) par commune de résidence du patient — pour le calcul de Recours_effectif et la cartographie des zones imperméables.
- **SNDS — Cartographie des pathologies (CNAM)** : prévalence standardisée des pathologies chroniques traceurs par commune ou bassin de vie — pour le calcul de Charge_morbidité(T).
- **[[taux_recours_ajuste_fdep|FDep9]] (Rey et al., INSERM / ORS)** : indice de défavorisation sociale à l'échelon de la commune ou de l'IRIS, disponible via les ORS régionaux et la DREES — pour le calcul du gradient social.
- **APL — Accessibilité Potentielle Localisée (DREES/IRDES)** : indicateur d'accès aux médecins généralistes par commune, intégrant distance et disponibilité — pour la composante structurelle de l'IPC.
- **RPPS / ADELI (DREES)** : effectifs géolocalisés des professionnels de santé libéraux (médecins, infirmiers, kinésithérapeutes) par commune — pour la densité de soins primaires.
- **PMSI MCO — mode d'entrée** : part des séjours entrant par les urgences (mode d'entrée = 8) par commune de résidence — indicateur satellite de l'imperméabilité (entrée par défaut par les urgences = barrière aux soins ambulatoires).

## Exemple de Valeurs

- **K_p > 1,2** : communes périurbaines favorisées avec forte densité de médecins généralistes et d'infirmiers, taux d'HPE inférieur de 30-40 % à la médiane nationale — "milieux très perméables".
- **K_p 0,6–0,9** : communes rurales de taille moyenne, FDep quintile 3, légère pénurie de médecins — perméabilité réduite mais pas critique.
- **K_p < 0,4** : zones péri-industrielles défavorisées, FDep quintile 5, taux d'HPE 2 à 3 fois supérieur à la médiane nationale, part des entrées MCO par urgences > 60 % — "couches imperméables" à cibler en priorité.
- **Gradient ΔK_p/ΔFDep_s typique** : −30 % à −50 % entre le quintile favorisé (Q1) et le quintile très défavorisé (Q5) dans la plupart des GHT — la perméabilité chute de moitié entre les zones les plus et les moins favorisées.
- **Impact d'une MSP sur K_p** : augmentation de 0,15 à 0,30 point de K_p observée sur les bassins de vie couverts par une maison de santé pluriprofessionnelle dans les 3 ans suivant son ouverture, selon les données DREES/IRDES.
- **Proportion de "zones imperméables" dans un GHT moyen** : 15-25 % des communes du territoire du GHT concentrent 40-50 % des HPE totales — identification conforme à la règle de Pareto des systèmes complexes.

## Limites

- **Le calcul de K_p nécessite une estimation de la charge de morbidité territoriale** : en l'absence d'accès au SNDS, cette charge est approximée depuis la fréquence des séjours MCO pour pathologies chroniques — ce qui sous-estime la morbidité des zones imperméables où les patients arrivent moins fréquemment en hospitalisation (biais d'imperméabilité auto-renforçant).
- **La loi de Darcy suppose un milieu homogène** — hypothèse non vérifiée en santé publique : les "milieux sociaux" sont hétérogènes, anisotropes et dynamiques. L'IPC est une approximation scalaire d'une réalité multidimensionnelle ; la cartographie des zones imperméables compense partiellement cette limite.
- **L'APL (accessibilité potentielle localisée) sous-estime les barrières non géographiques** : la distance au médecin est mesurée, mais pas les barrières culturelles, linguistiques, de confiance, ou d'horaires — l'IPC structural peut surestimer la perméabilité des zones géographiquement proches d'un cabinet mais socialement éloignées du système de santé.
- **Les HPE varient selon les définitions** : la liste des [[taux_hospitalisations_potentiellement_evitables|hospitalisations potentiellement évitables]] retenue pour le calcul des [[pqi_prevention_quality_indicators|PQI]] en France n'est pas entièrement stabilisée — des variations méthodologiques peuvent affecter la comparabilité inter-GHT.
- **Inertie temporelle** : l'amélioration de la perméabilité d'un territoire est lente (3-5 ans après déploiement d'une MSP ou d'une CPTS) — le pilotage à court terme de l'IPC est peu informatif ; l'indicateur est adapté à un suivi pluriannuel dans le cadre du projet médical de territoire.

## Références

- [Darcy H., *Les Fontaines Publiques de la Ville de Dijon*, 1856](https://fr.wikipedia.org/wiki/Loi_de_Darcy) — loi fondatrice de la perméabilité en milieu poreux
- [AHRQ — Prevention Quality Indicators (PQI), Technical Specifications](https://www.qualityindicators.ahrq.gov/Modules/PQI_TechSpec_ICD10_v2024.aspx)
- [DREES / IRDES — Accessibilité Potentielle Localisée (APL)](https://www.irdes.fr/recherche/2012/r553-construction-d-un-indicateur-de-l-accessibilite-potentielle-localisee.html)
- [Rey G. et al., *FDep : an area-based measure of deprivation*, European Journal of Epidemiology, 2009](https://doi.org/10.1007/s10654-009-9343-y)
- [CNAM — Cartographie des pathologies et des dépenses](https://assurance-maladie.ameli.fr/etudes-et-donnees/cartographie-des-pathologies-et-des-depenses)
- [HAS — Hospitalisations potentiellement évitables : indicateurs et méthode](https://www.has-sante.fr/)
- [DREES — Mortalité prématurée évitable par territoire](https://www.drees.solidarites-sante.gouv.fr/)
