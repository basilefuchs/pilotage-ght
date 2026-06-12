# Indice de Ramification de la Trajectoire de Soins

## Définition

En botanique, la ramification désigne le nombre et la structure des bifurcations d'une tige à partir d'un axe principal : un arbre à forte ramification développe de nombreuses branches parallèles à partir du tronc central. Appliqué aux parcours de soins, **l'indice de ramification de la trajectoire** (IRT) mesure le nombre moyen de transitions inter-secteurs qu'un patient emprunte à la suite d'un séjour hospitalier index, caractérisant la complexité topologique de sa trajectoire au-delà du seul séjour MCO initial.

IRT = Σ transitions_inter_champs / n_séjours_index

Une transition inter-champs est définie comme tout mouvement documenté vers un secteur distinct dans les 90 jours suivant la sortie du séjour index : MCO → SSR, MCO → HAD, MCO → PSY, MCO → urgences (réadmission non programmée), séjour PMSI → consultations spécialisées intensives (≥ 3 spécialités distinctes dans les 30 jours). Chaque champ constitue un nœud du réseau de soin ; chaque séquence documentée entre deux champs distincts constitue une arête.

Cet indicateur est distinct des indicateurs existants : l'indice de complexité du parcours multi-RUM mesure la complexité intra-SSR (nombre de Résumés d'Unité Médicale enchaînés au sein d'un même séjour SSR) ; l'indice de fragmentation du parcours patient mesure des ruptures binaires (présence/absence de suivi) ; le taux de transferts intra-GHT comptabilise uniquement les transferts formels entre établissements. L'IRT capture la **topologie de branchement** de l'ensemble de la trajectoire multi-sectorielle, y compris les transitions vers la ville.

## Calcul

**Sources :** PMSI MCO RSA + PMSI SSR RHS + PMSI PSY RPS + PMSI HAD + SNDS `ER_PRS_F` chaînés par NIR pseudonymisé sur la période index + 90 jours.

```
Population : tous les séjours MCO d'une période (séjour index)
             avec durée ≥ 1 jour (exclure les séjours en séances)

Étape 1 — Identification du séjour index :
  Séjour MCO de référence : RSA avec date de sortie SOR_DAT dans la période
  `finessgeo`, NIR, SOR_DAT constituent la clé d'appariement
  Exclure : séjours obstétricaux (CMD 14), séances (NAT_ASS = 1), nouveau-nés (CMD 15)

Étape 2 — Fenêtre de suivi post-sortie :
  J0   = SOR_DAT du séjour index
  J90  = J0 + 90 jours calendaires
  Collecter tous les contacts de soins documentés sur [J1, J90] :
    - PMSI SSR : séjour SSR avec ENT_DAT ∈ [J1, J90] pour le même NIR
    - PMSI PSY : séjour PSY avec DAT_DEB ∈ [J1, J90] pour le même NIR
    - PMSI HAD : séjour HAD avec ENT_DAT ∈ [J1, J90] pour le même NIR
    - PMSI MCO : réadmission MCO non programmée (`modeentree` = 8 ou 6) ∈ [J1, J30]
    - SNDS ER_PRS_F : consultations de spécialistes distincts ∈ [J1, J30]
      → compter les spécialités distinctes (`PSE_SPE_COD` exécutant, `PSP_SPE_COD` prescripteur)
      → si ≥ 3 spécialités distinctes en 30j : compter comme 1 branche "ambulatoire intensif"

Étape 3 — Comptage des transitions inter-champs :
  Champs distincts : [MCO, SSR, PSY, HAD, Urgences_réadmission, Ambulatoire_intensif]
  Transition = passage d'un champ à un autre champ distinct
    (chaque champ ne compte qu'une fois même si visitée plusieurs fois)
  n_transitions_patient = nb champs distincts touchés post-index − 1
    (ex : MCO→SSR→Ambulatoire = 2 transitions, IRT_patient = 2)

Étape 4 — IRT global :
  IRT_établissement = Σ(n_transitions_i) / n_séjours_index
  IRT par GHM : calculer séparément par racine GHM (5 car.) ou CMD
  IRT par FINESS : comparer les établissements du GHT entre eux

Étape 5 — Indicateurs dérivés :
  Taux de trajectoires simples (IRT = 0) : patients rentrés directement à domicile sans
    aucune transition documentée dans les 90j → proxy d'autonomie post-hospitalière
  Taux de trajectoires complexes (IRT ≥ 3) : patients avec ≥ 4 champs traversés
    → population-cible des dispositifs de coordination renforcée (DAC, SPRAD)
  IRT_moyen_GHM : valeur de référence pour identifier les GHMs à forte ramification
    systématique (justifiant des filières dédiées) vs les GHMs à ramification variable
    (signalant une hétérogénéité de prise en charge potentiellement évitable)
```

**Cas limites :**
- Séjour index suivi d'un décès intra-hospitalier dans les 90j : le séjour MCO de décès est compté comme transition si survenu dans un autre établissement que l'index
- Patients hors SNDS (régimes spéciaux non couverts) : exclus du calcul ambulatoire, IRT partiel possible
- Réadmissions programmées (chimiothérapie en séances) : exclure les réadmissions en `modeentree` = 7 (transfert programmé) pour les séjours en séances

## Utilité

- **Identifier les GHMs à filière systématiquement complexe** : un GHM d'AVC sévère avec IRT moyen de 3.2 ± 0.8 confirme la nécessité d'une filière MCO→SSR→HAD formalisée ; un GHM d'appendicectomie avec IRT de 0.3 ± 0.5 indique une trajectoire principalement directe-domicile, ce qui ne justifie pas un coordinateur dédié
- **Détecter les ramifications non organisées** : un IRT élevé pour un GHM qui ne devrait pas l'être (ex. fracture distale du radius, IRT > 2.0) signale une trajectoire désorganisée — réadmissions aux urgences, consultations multispécialistes non coordonnées — qui mérite une analyse de cause
- **Calibrer les ressources de coordination du GHT** : l'IRT moyen pondéré par volume permet d'estimer la charge de travail de coordination post-hospitalière par UF ou par service (chaque branche supplémentaire ≈ charge de liaison supplémentaire pour le coordinateur)
- **Comparer les établissements du GHT sur leurs capacités de projection ambulatoire** : un établissement avec IRT faible pour ses AVC peut indiquer une absence de filière SSR structurée (les patients rentrent directement à domicile sans réhabilitation documentée), ou au contraire une bonne gestion des sorties directes
- **Évaluer l'effet d'une restructuration de filière** : comparer IRT avant/après création d'une filière gériatrique ou d'un protocole PRADO par GHM — une hausse de l'IRT combinée à une baisse du taux de réadmissions indique un meilleur aiguillage vers les secteurs aval
- **Alimenter les négociations de CPOM** : l'IRT élevé des GHMs de neurologie, oncologie et gériatrie justifie des dotations de coordination renforcées et des objectifs de structuration des filières dans les contrats pluriannuels avec l'ARS

## Sources de Données

- **PMSI MCO — RSA** : `SOR_DAT` (date de sortie), `MODE_SORTIE` (destination), `finessgeo`, racine GHM, NIR pseudonymisé — extraction ATIH annuelle
- **PMSI SSR — RHS** : `ENT_DAT`, `NIR_ANO_17`, `finessgeo` — pour détecter les séjours SSR post-index
- **PMSI PSY — RPS** : `DAT_DEB`, `NIR_ANO_17`, `finessgeo` — pour les séjours psychiatriques post-index
- **PMSI HAD** : `ENT_DAT`, `NIR_ANO_17`, `finessgeo` — pour les séjours d'hospitalisation à domicile
- **SNDS — `ER_PRS_F`** : `EXE_SOI_DTD`, `PSE_SPE_COD` (spécialité du PS exécutant), `BEN_NIR_PSA` — pour détecter la ramification ambulatoire intensive
- **Référentiel ATIH GHMs** : pour la stratification par CMD et racine GHM

## Exemple de Valeurs

| GHM / Situation clinique | IRT moyen attendu | Profil |
|---|---|---|
| Fracture simple (08C37x) | 0.8 – 1.5 | MCO → ville ou MCO → SSR court |
| AVC constitué (01C08Z) | 2.5 – 3.5 | MCO → SSR → HAD ou ambulatoire intensif |
| Chirurgie ambulatoire programmée | 0.2 – 0.5 | Retour domicile direct dominant |
| Cancer digestif opéré (stade II-III) | 2.8 – 4.5 | MCO → chimiothérapie → consultations multiples |
| Fracture du col du fémur (PA ≥ 80 ans) | 2.0 – 3.5 | MCO → SSR → HAD ou EHPAD |
| Infarctus du myocarde (05K03J) | 1.8 – 2.5 | MCO → cardiologie ambulatoire → réadaptation |
| Diabète décompensé simple | 0.5 – 1.0 | MCO → médecin traitant + endocrinologue |

**Seuils de référence GHT :**
- IRT < 0.5 pour un GHM attendu complexe → sous-organisation des soins aval (alerte)
- IRT > 4.0 pour tout GHM → trajectoire hyperfragmentée, revue de coordination requise

## Limites

- **Dépendance au SNDS chaîné** : le calcul de la branche ambulatoire nécessite l'accès au SNDS (DCIR) en plus du PMSI ; les établissements sans accès aux données SNDS ne peuvent calculer qu'un IRT partiel (PMSI seul), sous-estimant la ramification réelle de 20-40 %
- **Fenêtre de 90 jours arbitraire** : des pathologies à évolution lente (BPCO, insuffisance cardiaque) ont des trajectoires qui se déploient sur 6-12 mois ; la fenêtre de 90 jours sous-estime l'IRT réel pour ces groupes
- **Homogénéité de champ non garantie** : une réadmission MCO dans le même établissement pour une autre pathologie compte comme transition, potentiellement non liée au séjour index — un algorithme de filtrage par diagnostic principal est recommandé pour les études de causalité
- **Absence de pondération par intensité** : une transition vers une consultation de 15 minutes et une transition vers un séjour SSR de 30 jours comptent identiquement ; l'IRT pondéré par durée ou coût est plus discriminant mais complexe à calculer
- **Biais de disponibilité territoriale** : les patients en zone sous-dotée ont structurellement un IRT ambulatoire plus faible, non par bonne organisation mais par absence d'offre — les comparaisons inter-zones nécessitent un ajustement sur la densité médicale locale

## Références

- [Blondel V.D. et al. — Fast unfolding of communities in large networks, Journal of Statistical Mechanics 2008 : algorithme de détection de communautés dans les réseaux — applicable à la cartographie des transitions inter-secteurs](https://doi.org/10.1088/1742-5468/2008/10/P10008)
- [Newcomer S.R. et al. — Complexity of care for patients with multiple chronic conditions, Health Affairs 2011 : lien entre complexité de la trajectoire et coordination des soins](https://doi.org/10.1377/hlthaff.2011.0027)
- [Orueta J.F. et al. — Patterns of multimorbidity in primary care patients and associated outcomes, PLoS ONE 2014 : profils de trajectoires multi-sectorielles dans les populations chroniques](https://doi.org/10.1371/journal.pone.0099464)
- [ATIH — Guide méthodologique de production des résumés MCO, SSR, PSY, HAD (version en vigueur)](https://www.atih.sante.fr/)
- [Nuño-Solinís R. et al. — Development of an assessment tool to measure and track integration of care, International Journal of Integrated Care 2013 : cadre d'évaluation de l'intégration des soins](https://doi.org/10.5334/ijic.1065)
