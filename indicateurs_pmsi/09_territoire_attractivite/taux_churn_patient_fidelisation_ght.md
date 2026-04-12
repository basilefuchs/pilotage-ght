# Taux de Churn Patient — Fidélisation Longitudinale du GHT

## Définition

Adapté du concept marketing de "churn rate" (taux d'attrition client), le taux de churn patient mesure la proportion de patients qui avaient eu recours aux soins au sein du GHT au cours de l'année N et qui n'ont plus aucun contact avec le GHT en année N+1, alors qu'ils sont toujours vivants et ont consommé des soins hospitaliers ou ambulatoires. Il s'agit d'une mesure longitudinale de la fidélisation du GHT sur sa patientèle, calculable exclusivement depuis le SNDS (chaînage NIR crypté multi-annuel sur PMSI + DCIR).

L'indicateur capture un phénomène distinct du taux de fuite instantané (qui mesure la proportion de soins réalisés hors GHT pour une pathologie et une période données) : le churn mesure la **rupture totale du lien** avec le GHT sur une année entière. Un patient qui fuit à 30% (3 hospitalisations sur 10 ailleurs) n'est pas un patient churné ; un patient qui n'a plus aucun contact avec le GHT après y avoir été soigné l'année précédente est churné. La distinction est opérationnellement importante : réduire le churn nécessite une stratégie de fidélisation (coordination, continuité, qualité relationnelle), tandis que réduire la fuite nécessite une stratégie de compétitivité (offre de soins, délais, réputation).

Stratifié par profil patient (ALD, âge, pathologie) et par type de prise en charge (MCO, consultation externe, ambulatoire DCIR) pour identifier les segments les plus à risque d'attrition.

## Calcul

Chaînage longitudinal SNDS sur 2 années consécutives :

```
Population de référence (cohorte année N) :
  → Patients ayant eu ≥ 1 contact avec le GHT en année N :
      Séjour MCO/SSR/HAD/psychiatrie au GHT (PMSI, FINESS établissement)
      OU consultation externe au GHT (PMSI ACE)
      OU acte médical en établissement GHT tracé en DCIR (ER_PRS_F)
  → Identifiés par NIR crypté
  → Exclusions :
      Décès avant le 31/12/N (mode_sort=9 ou date décès IR_BEN_R)
      Déménagement hors territoire (changement de commune de résidence ≥ 50km
       entre N et N+1, détectable via IR_BEN_R)
      Patients ayant eu exclusivement des soins ponctuels uniques sans pathologie
       chronique (ex. fracture unique réparée = rupture de contact normale)
```

Définition du churn :

```
Patient churné en N+1 :
  → Présent dans la cohorte N
  → Vivant au 31/12/N+1 (IR_BEN_R date décès absente)
  → Résidant toujours dans le territoire (commune de résidence stable)
  → Ayant consommé des soins quelconques en N+1 (PMSI ou DCIR)
    → condition essentielle : le patient N'A PAS disparu du système de soins
  → N'ayant eu AUCUN contact avec le GHT en N+1 (ni PMSI, ni consultation,
    ni acte DCIR en établissement GHT)
```

Formule :

```
Taux de churn (%) =
  (Patients cohorte N, vivants, résidants, avec soins N+1, sans contact GHT N+1)
  / (Patients cohorte N, vivants, résidants, avec soins N+1) × 100

Taux de rétention (%) = 100 − Taux de churn
```

Sous-indicateurs et segmentation :

```
Churn par segment clinique :
  → Patients ALD (IR_IMB_R) : churn sur le suivi des pathologies chroniques
    → Sous-segmentation par ALD : ALD 5 (diabète), ALD 12 (HTA sévère),
      ALD 13 (insuffisance cardiaque), ALD 30 (cancer actif)
  → Patients non-ALD : soins ponctuels, prise en charge épisodique
  → Churn post-première hospitalisation : patients hospitalisés pour la 1ère fois
    au GHT en N → taux de retour en N+1

Churn par type de contact perdu :
  → Churn MCO pur (plus aucune hospitalisation au GHT)
  → Churn total (plus aucun contact y compris consultation externe)
  → Destination du patient churné (si identifiable) :
    → Patients allant en MCO hors GHT (établissement concurrent identifié
      par chaînage PMSI national via ARS)
    → Patients restant exclusivement en ambulatoire ville (DCIR uniquement)

Délai de rechurn (durée avant retour éventuel) :
  → Proportion de patients revenus au GHT en N+2 après churn en N+1
  → "Taux de reconquête" = clients perdus puis récupérés
```

## Utilité

- **Mesure de la fidélisation réelle du GHT sur sa patientèle chronique** : pour les patients ALD (diabète, insuffisance cardiaque, cancer), le churn mesure si le GHT maintient un rôle central dans leur parcours de soins sur le long terme — indicateur de loyalty impossible à calculer sans chaînage SNDS multi-annuel
- **Identification des segments à risque d'attrition** : un taux de churn élevé sur les patients ALD diabète (ALD 5) peut signaler une défaillance du suivi spécialisé diabétologique (absence de consultation endocrinologie dans les 12 mois N, migration vers un cabinet libéral ou une clinique privée)
- **Mesure de l'impact des actions de coordination** : évaluer si les programmes de case management (infirmière de coordination, télésuivi, protocoles de coopération médecin traitant–GHT) réduisent le churn sur les patients chroniques — comparaison bénéficiaires vs non-bénéficiaires du programme via le NIR
- **Outil de dialogue CPOM/ARS sur le maintien de l'offre** : un churn élevé sur une pathologie (ex. oncologie) dans une zone géographique peut révéler que les patients quittent le GHT pour un centre expert régional — argument pour l'ARS d'une révision de l'offre ou d'une filière de soins partagée
- **Calcul de la "valeur vie patient" (Patient Lifetime Value)** : le churn est le paramètre clé du CLV (Customer Lifetime Value) en marketing — en santé, la durée espérée de suivi d'un patient ALD au GHT = 1 / taux_churn → outil de planification des ressources long terme (combien de patients actifs attendus dans 5 ans si le taux de churn ne change pas ?)
- **Benchmarking entre établissements du GHT** : si le GHT est multi-sites, comparer les taux de churn par site sur des pathologies comparables pour identifier les établissements qui fidélisent mieux leur patientèle

## Sources de Données

- **PMSI tous champs** (MCO, SSR, HAD, psychiatrie, ACE) : identification des contacts N et N+1 au sein des établissements FINESS du GHT, par NIR crypté
- **DCIR ER_PRS_F** : actes médicaux en établissement tracés en DCIR (complète le PMSI pour les consultations externes et les actes techniques ambulatoires réalisés dans les structures du GHT)
- **IR_BEN_R** : date de décès, commune de résidence (pour l'exclusion des décès et des déménagements hors territoire), statut ALD
- **IR_IMB_R** : codes ALD actifs par patient — permet la segmentation par pathologie chronique
- **Chaînage multi-annuel SNDS** : indispensable — requiert un accès SNDS complet avec NIR crypté persistant entre les années N et N+1 (disponible dans l'EGB ou dans les accès SNDS permanents des établissements via le Health Data Hub)

## Exemple de Valeurs

- **Taux de churn global tous patients MCO** : difficilement benchmarkable car très dépendant de la proportion de séjours ponctuels dans la patientèle — valeurs attendues 30-50%
- **Taux de churn patients ALD chroniques** : 10-20% (ces patients ont des besoins récurrents et quittent rarement leur établissement de suivi sans raison) ; un taux > 25% est un signal d'alerte
- **Taux de churn post-première hospitalisation** : 40-60% (patients admis pour la première fois qui ne reviennent pas l'année suivante — normal pour les pathologies aiguës, anormal pour les pathologies chroniques nécessitant un suivi)
- **Taux de reconquête N+2** (patients revenus après un an d'absence) : environ 15-25% selon les établissements — indique que le churn est partiellement réversible
- **Benchmark marketing SaaS** : taux de churn considéré "acceptable" dans les industries de services = 5-7%/an pour les clients premium ; en santé, les patients ALD ont une "nécessité de soins" qui devrait naturellement limiter le churn si l'offre est disponible et de qualité

## Limites

- Le taux de churn ne distingue pas le churn "subi" (patient insatisfait, mauvaise expérience, délai d'attente excessif → départ volontaire vers concurrent) du churn "naturel" (patient guéri, pathologie résolue, plus besoin de soins spécialisés) — la stratification par ALD et par pathologie chronique est le principal levier pour isoler le churn évitable
- L'identification des contacts avec le GHT requiert d'apparier les FINESS géographiques de tous les établissements membres du GHT dans la requête SNDS — une omission de FINESS conduit à sous-estimer les contacts et sur-estimer le churn
- Le DCIR a un lag de 6-12 mois : les contacts ambulatoires très récents (dernier trimestre de l'année N+1) peuvent ne pas encore être dans le DCIR lors du calcul — légère sur-estimation du churn pour les analyses réalisées tôt dans l'année N+2
- Enjeux éthiques de la terminologie : le vocabulaire "marketing" (churn, fidélisation, customer lifetime value) peut être perçu comme réducteur ou inapproprié dans le contexte des soins — recommander d'utiliser des formulations adaptées ("continuité du suivi", "maintien dans la filière de soins") dans les communications internes

## Références

- [Reichheld F.F., Sasser W.E. — Zero defections: quality comes to services, HBR 1990 : définition du churn et de la customer lifetime value dans les services]
- [Tuppin P. et al. — Value of a national administrative database to guide public decisions: SNIIRAM to SNDS, Rev Epidemiol Sante Publique 2017](https://doi.org/10.1016/j.respe.2017.05.004)
- [Health Data Hub — Documentation technique SNDS et accès multi-annuel pour le chaînage longitudinal](https://www.health-data-hub.fr/)
- [Van Walraven C. et al. — Continuity of care and patient outcomes after hospital discharge, J Gen Intern Med 2004 : impact de la continuité de suivi sur les réhospitalisations](https://doi.org/10.1111/j.1525-1497.2004.30082.x)
- [Beal A.C. et al. — Closing the divide: how medical homes promote equity in health care, Commonwealth Fund 2007 : fidélisation des patients chroniques dans les systèmes de soins primaires]
