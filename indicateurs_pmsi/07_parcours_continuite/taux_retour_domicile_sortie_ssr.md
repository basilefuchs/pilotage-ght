# Taux de Retour à Domicile à la Sortie du SSR

## Définition

Proportion de patients sortis d'un séjour SSR (Soins de Suite et Réadaptation) dont la destination de sortie est le domicile — personnel ou familial, avec ou sans aide à domicile (SSIAD, HAD, auxiliaire de vie) — par opposition à l'institutionnalisation en EHPAD/USLD ou au retour en hospitalisation MCO/psychiatrie. Codé via la variable mode de sortie du PMSI SSR : mode_sort = 8 (retour domicile ou famille) vs mode_sort = 6 (mutation vers établissement médico-social ou EHPAD) vs mode_sort = 7 (transfert vers MCO ou autre SSR) vs mode_sort = 9 (décès).

C'est l'indicateur de résultat final le plus important du SSR : il mesure si la rééducation a permis une récupération fonctionnelle suffisante pour permettre une vie en autonomie ou semi-autonomie à domicile. Il est intimement lié au gain MIF (delta score fonctionnel entrée-sortie) et à la durée de séjour SSR. Stratifié par finalité principale de prise en charge (FP) et par GME : neurologie cérébro-lésée (AVC, TC), appareil locomoteur (PTH/PTG, fractures du col du fémur), cardiovasculaire, gériatrie polyvalente.

Un taux de retour à domicile faible peut refléter soit une rééducation insuffisante (patient non récupéré), soit une inadéquation de l'environnement à domicile (absence d'aidant, logement inadapté), soit un défaut d'organisation de la sortie (absence de SSIAD disponible, HAD non mise en place à temps).

## Calcul

Population éligible :

```
Population cible :
  → Tous les séjours SSR terminés (mode_sort renseigné et ≠ transfert intra-SSR
    entre unités d'un même séjour continu)
  → Exclusions :
      - Décès (mode_sort = 9) — analysés séparément (taux de mortalité SSR)
      - Transferts vers autre SSR sans sortie définitive (mode_sort = 7 avec
        séjour SSR suivant dans les 24h = mutation de continuité, non une sortie)
      - Patients < 18 ans (indicateur adulte)
```

Formule principale :

```
Taux de retour à domicile SSR (%) =
  (Séjours SSR avec mode_sort = 8 / Total séjours SSR terminés éligibles) × 100
```

Sous-indicateurs par destination de sortie :

```
Décomposition des sorties SSR :
  mode_sort = 8 : retour domicile/famille            → cible principale
  mode_sort = 6 : institutionnalisation (EHPAD/USLD) → indicateur d'alerte
  mode_sort = 7 : retour MCO ou autre SSR            → analysé via SSR-4
  mode_sort = 9 : décès en SSR                       → indicateur séparé

Sous-indicateurs qualitatifs du retour domicile :
  → Taux de retour domicile avec HAD :
    (patients avec mode_sort=8 ET séjour HAD dans les 7j post-sortie SSR
     identifié par chaînage NIR) / total retours domicile
  → Taux de retour domicile avec SSIAD :
    (patients avec mode_sort=8 ET actes SSIAD dans les 30j post-sortie SSR
     identifiés via DCIR ER_PRS_F codes NGAP infirmiers) / total retours domicile
  → Taux d'institutionnalisation chez les < 75 ans :
    (patients âge < 75 avec mode_sort = 6) / (séjours SSR terminés âge < 75)
    → proxy de "institutionnalisation non souhaitée"
```

Stratification :

```
Stratification par GME (spécialité SSR) :
  Locomoteur (PTH/PTG)       : taux attendu ~75-85%
  AVC/neurologie             : taux attendu ~50-60%
  Fracture col fémur         : taux attendu ~55-65%
  Gériatrie polyvalente      : taux attendu ~40-55%
  Cardiovasculaire           : taux attendu ~65-75%

Stratification par niveau MIF à l'entrée :
  MIF < 36  (dépendance totale)   : taux retour domicile ~15-25%
  MIF 36-72 (dépendance modérée)  : taux retour domicile ~45-60%
  MIF > 72  (dépendance légère)   : taux retour domicile ~75-90%

Stratification par tranche d'âge :
  18-64 ans, 65-74 ans, 75-84 ans, ≥ 85 ans
```

Indicateur de robustesse du retour à domicile :

```
Taux de réhospitalisation MCO à 30j post-retour domicile (%) =
  (Patients avec mode_sort=8 SSR ET séjour MCO dans les 30j suivants via chaînage NIR)
  / Total patients retournés à domicile depuis SSR × 100
→ Indicateur de solidité du retour : un taux > 15% signale des sorties prématurées
```

## Utilité

- **Mesurer l'efficacité réelle du SSR en termes d'autonomie retrouvée** : c'est l'outcome clinique final qui donne du sens à l'ensemble des indicateurs de processus SSR (gain MIF, DMS, prophylaxie)
- **Identifier les spécialités SSR ou établissements avec des taux d'institutionnalisation excessifs** par rapport aux références nationales après ajustement sur le profil patient (GME + MIF d'entrée + âge) — signal de rééducation insuffisante ou de défaut d'organisation de la sortie
- **Optimiser les filières de sortie SSR** : les établissements avec un faible taux de retour domicile malgré un gain MIF satisfaisant ont probablement un défaut d'organisation à la sortie (SSIAD non commandé, HAD non mise en place, famille non formée) plutôt qu'un défaut de rééducation
- **Appuyer les demandes de financement de structures intermédiaires** : un taux élevé d'institutionnalisation chez les < 75 ans avec MIF > 50 est un argument pour développer des appartements thérapeutiques, des MAIA, ou du HAD de rééducation
- **Dialogue CPOM ARS** : le retour à domicile est un objectif explicite des projets régionaux de santé et des volets SSR des SROS ; l'indicateur permet un suivi contractuel
- **Évaluation des programmes de préparation de sortie** : mesurer l'impact de dispositifs dédiés (infirmière coordinatrice de sortie, bilan logement ergothérapeute, plateforme d'orientation médico-sociale) sur l'évolution du taux

## Sources de Données

- **PMSI SMR RHS** : `modesortie`, GME, FP (finalité principale), cotations de dépendance AVQ (`dep_phys`, `dep_cogn` — pas de MIF dans la base nationale), dates d'entrée/sortie, chaînage `anonyme`
- **PMSI HAD** : chaînage NIR post-sortie SSR pour identifier les retours domicile avec HAD dans les 7 jours
- **PMSI MCO RSA** : chaînage NIR post-sortie SSR pour détecter les réhospitalisations MCO à 30 jours (solidité du retour domicile)
- **DCIR ER_PRS_F** : actes SSIAD (codes NGAP infirmiers) dans les 30 jours post-sortie SSR — permet d'identifier les retours domicile avec aide infirmière à domicile
- **IR_BEN_R DCIR** : commune de résidence du patient — permet l'analyse territoriale des taux de retour domicile (déserts médico-sociaux)

## Exemple de Valeurs

- **Taux national de retour à domicile SSR tous GME confondus (ATIH 2022)** : ~58-63%
- **PTH/PTG (locomoteur, patients jeunes)** : 78-85% — population la plus favorable (indication programmée, récupération fonctionnelle prévisible)
- **AVC (neurologie cérébro-lésée)** : 50-60% — très dépendant de la sévérité neurologique initiale et de la présence d'un aidant
- **Fracture du col du fémur (personne âgée)** : 55-65% — forte variabilité liée à la situation sociale pré-fracture
- **Gériatrie polyvalente** : 40-52% — population âgée polypathologique, institutionnalisation fréquente
- **Impact de l'organisation de sortie** : les SSR disposant d'une infirmière coordinatrice de sortie dédiée présentent des taux de retour domicile supérieurs de 8-12 points (littérature sur discharge planning)

## Limites

- Le mode_sort = 8 (domicile) inclut les retours à domicile suivis très rapidement d'une réhospitalisation MCO ou d'un placement en urgence en EHPAD — sans le chaînage NIR à 30j, le taux brut surestime la réussite du retour
- Les patients qui retournent chez un proche (enfant, conjoint) sans aide professionnelle sont indistinguables de ceux qui retournent seuls à domicile, alors que leurs trajectoires de risque sont très différentes
- Biais de sélection structurel : les SSR accueillant des patients avec des AVC sévères ou des fractures compliquées présenteront un taux plus faible qu'un SSR orienté chirurgie orthopédique programmée — la stratification par GME et MIF d'entrée est indispensable pour tout benchmark inter-établissements
- Les transferts en EHPAD temporaire (hébergement temporaire le temps de l'adaptation du domicile) sont codés en mode_sort = 6 et comptabilisés dans l'institutionnalisation, alors qu'ils correspondent parfois à un retour domicile différé — sur-estimation possible du taux d'institutionnalisation

## Références

- [Prvu Bettger J. et al. — Transitional care after hospitalization for acute stroke or myocardial infarction: a systematic review, Ann Intern Med 2012](https://doi.org/10.7326/0003-4819-157-6-201209180-00004)
- [HAS — Recommandations de bonne pratique post-AVC : rééducation et retour à domicile (2012)](https://www.has-sante.fr/)
- [SFGG — Recommandations sur la prise en charge SSR gériatrique et les critères de retour à domicile (2019)](https://www.sfgg.fr/)
- [ATIH — Statistiques nationales PMSI SSR : taux de retour à domicile par GME (données annuelles)](https://www.atih.sante.fr/)
- [DREES — Enquête auprès des établissements de santé sur les filières de sortie SSR (2020)](https://www.drees.solidarites-sante.gouv.fr/)
