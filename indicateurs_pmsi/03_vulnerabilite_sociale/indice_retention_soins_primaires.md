# Indice de Rétention des Soins Primaires

## Définition

En hydrologie, le **coefficient de rétention** (ou coefficient d'infiltration) mesure la fraction des précipitations qui s'infiltre dans les sols et les nappes phréatiques avant d'atteindre les cours d'eau : un sol imperméable a un coefficient de rétention faible (presque toute la pluie ruisselle directement vers la rivière) ; un sol riche en humus et couvert de végétation a un coefficient élevé (la pluie est absorbée progressivement, régulant les crues et maintenant un débit de base stable).

Transposé à l'organisation des soins, l'**Indice de Rétention des Soins Primaires** (IRSP) mesure la fraction de la demande de soins aiguë ou potentiellement aiguë qui est **absorbée, filtrée ou orientée par les soins primaires** (médecin généraliste, CPTS, maison de santé pluriprofessionnelle) avant d'atteindre l'hôpital. Un territoire avec des soins primaires robustes est comme un sol perméable : la demande de soins est régulée, partiellement traitée en ambulatoire, et seulement la fraction nécessitant une hospitalisation atteint le MCO. Un territoire avec des soins primaires fragiles (désert médical, absence de médecin traitant déclaré) est imperméable : toute la demande ruisselle directement vers les urgences hospitalières, générant des "crues" de débit de crue.

**IRSP = 1 − (Hospitalisations_potentiellement_évitables / Total_hospitalisations_aiguës)**

où les hospitalisations potentiellement évitables (HPE) sont les hospitalisations pour des pathologies dont la prise en charge ambulatoire de qualité aurait dû prévenir l'hospitalisation (ACSC — Ambulatory Care Sensitive Conditions).

## Calcul

Identification des hospitalisations potentiellement évitables (HPE) :

```
Les ACSC (Ambulatory Care Sensitive Conditions) sont des pathologies pour lesquelles
une bonne prise en charge ambulatoire réduit le risque d'hospitalisation :

Liste des codes CIM-10 retenus (DP du séjour MCO index) :
  Diabète décompensé : E10-E14 avec complications aiguës
  Insuffisance cardiaque : I50
  BPCO exacerbation : J44.1
  Asthme aigu : J45, J46
  HTA décompensée : I10-I13 avec complication
  Angine, ORL : J02, J03, J06
  Infections urinaires : N10-N12, N30
  Pneumonie bactérienne : J13-J18 (hors immunodéprimés)
  Epilepsie non contrôlée : G40-G41
  Anémie ferriprive : D50 (chez patient ALD non suivi)

Source de référence : liste AHRQ PQI (Prevention Quality Indicators),
adaptée au contexte français par la DREES/HAS

HPE = séjours MCO avec DP ∈ {liste ACSC}
  ET MODE_ENTREE = 8 (urgences) — hospitalisations non programmées
  ET âge ≥ 18 ans (les ACSC pédiatriques ont une définition spécifique)
```

Calcul de l'IRSP par territoire :

```
Dénominateur de référence :
  N_aiguës = total des hospitalisations MCO avec MODE_ENTREE = 8 sur le territoire
  (hospitalisations non programmées, entrée par urgences)

IRSP = 1 − (N_HPE / N_aiguës)
  → IRSP ∈ [0 ; 1]
  → IRSP élevé (> 0,85) : peu d'hospitalisations évitables / les soins primaires filtrent bien
  → IRSP faible (< 0,70) : forte proportion d'hospitalisations potentiellement évitables
    → Indicateur d'un accès insuffisant ou d'une qualité insuffisante des soins primaires

Standardisation par l'âge et le sexe (IRSP standardisé) :
  → Utiliser la standardisation indirecte pour comparer des territoires avec des
    structures démographiques différentes
  → IRSP_std = 1 − (N_HPE_observées / N_HPE_attendues_si_taux_national)
  → N_HPE_attendues = Σ_strate (N_patients_strate × taux_HPE_national_strate)
```

Facteurs explicatifs exploitables depuis le SNDS :

```
Depuis DCIR IR_BEN_R (médecin traitant déclaré) :
  Taux de MT déclaré = fraction des patients hospitalisés ayant un MT déclaré
  Corrélation attendue : Taux_MT_élevé → IRSP élevé

Depuis DCIR ER_PRS_F (consultations ambulatoires) :
  Pour les patients hospitalisés pour une ACSC :
    Nombre de consultations de MG dans les 3 mois précédant l'hospitalisation
    → 0 consultation : patient sans suivi ambulatoire → "ruissellement direct"
    → ≥ 2 consultations + hospitalisation quand même → échec de la prise en charge
      ambulatoire (insuffisance des soins primaires ou sévérité réelle)

Délai consultation MG → hospitalisation (proxy de la filière) :
  Δ = DATE_ENT_MCO − DATE_dernière_consultation_MG (depuis DCIR)
  → Δ < 2j : hospitalisation dans la foulée d'une consultation MG (filière fonctionnelle)
  → Δ > 30j : aucun contact MG récent (ruissellement direct)
  → Distribution de Δ sur la cohorte HPE = profil de la filière primaire-secondaire
```

## Utilité

- **Quantifier l'impact des déserts médicaux sur l'hôpital** : calculé par commune ou IRIS, l'IRSP révèle les zones où l'absence de soins primaires génère directement des hospitalisations évitables — argument factuel pour les politiques de redéploiement médical, les maisons de santé et les CPTS ; "les zones sans médecin généraliste ont un IRSP de 0,64 vs 0,83 dans les zones avec MSP — soit 19 points d'hospitalisations évitables supplémentaires"
- **Évaluer l'impact des CPTS et MSP** : mesurer l'évolution de l'IRSP sur un territoire avant/après la création d'une CPTS ou d'une MSP — si l'IRSP augmente, les nouvelles structures ont amélioré la rétention de la demande aiguë et réduit les hospitalisations évitables ; indicateur de résultat territorial des investissements en soins primaires
- **Dialoguer avec l'ARS et la CNAM sur les inégalités territoriales** : l'IRSP par territoire est l'indicateur qui fait le lien entre la densité médicale et le recours hospitalier — il justifie les financements FIQCS (Fonds d'Intervention pour la Qualité et la Coordination des Soins) et les projets territoraux de santé par des données objectives sur les pertes de rétention
- **Identifier les ACSC les plus "évitables"** : décomposer l'IRSP par type d'ACSC pour identifier les pathologies où le déficit de soins primaires est le plus marqué — dans un territoire donné, ce sont peut-être les décompensations d'insuffisance cardiaque (ACSC riche en soins de suivi) plutôt que les pneumonies qui dominent les HPE ; l'action doit être ciblée sur ces pathologies prioritaires
- **Benchmarking inter-GHT** : comparer les IRSP entre GHTs de caractéristiques similaires pour identifier les territoires avec les meilleurs modèles de soins primaires — les GHTs avec IRSP élevé malgré une densité médicale similaire ont développé des modèles de coordination ville-hôpital qui méritent d'être diffusés

## Sources de Données

- **PMSI MCO RSA** : DP du séjour (pour identifier les ACSC), MODE_ENTREE = 8 (urgences), âge, sexe, commune de résidence — pour calculer N_HPE et N_aiguës par territoire (commune, IRIS, canton) via le code postal du patient dans le RSA
- **DCIR IR_BEN_R** : médecin traitant déclaré (RPPS) et commune de résidence — pour le taux de MT déclaré et la stratification des patients HPE selon leur suivi ambulatoire
- **DCIR ER_PRS_F** : consultations de MG dans les 3 mois pré-hospitalisation (pour les patients HPE) — pour calculer le délai consultation-hospitalisation et distinguer "ruissellement direct" de "filière fonctionnelle mais insuffisante"
- **INSEE (données publiques)** : population par commune, âge, sexe — pour le dénominateur de standardisation et le calcul des taux de recours par IRIS

## Exemple de Valeurs

- **Comparaison territoriale (département avec zones urbaines et rurales)** :
  Zone urbaine dense avec nombreux MG : IRSP_std = 0,84
  Zone péri-urbaine avec MSP récente : IRSP_std = 0,80 → 0,83 après 2 ans
  Zone rurale sans MG disponible (<5j délai RDV) : IRSP_std = 0,67
  → Écart de 17 points entre zones extrêmes = 17 hospitalisations évitables
    supplémentaires pour 100 hospitalisations aiguës dans les zones sous-dotées

- **Décomposition par ACSC (zone à IRSP faible)** :
  ACSC dominants : insuffisance cardiaque (32%), BPCO (18%), diabète décompensé (15%)
  → Action prioritaire : programme de télésuivi IC et protocole de décompensation BPCO
    en ambulatoire avec les généralistes disponibles

- **Impact de la création d'une CPTS** :
  Territoire pilote : IRSP = 0,71 (2020) → 0,76 (2022) après création CPTS
    avec protocoles communs urgences/MG et régulation des hospitalisations non programmées
  → +5 points en 2 ans = réduction de ~80 hospitalisations évitables/an sur le territoire

- **Délai consultation-hospitalisation pour les HPE** :
  48% des patients HPE n'ont aucune consultation MG dans les 30j précédant l'hospitalisation
  ("ruissellement direct" : accès aux soins primaires absent ou non sollicité)
  28% ont eu ≥ 1 consultation dans les 7j précédant ("filière fonctionnelle mais insuffisante")
  24% ont eu une consultation le jour même ou la veille ("admission directe organisée")

## Limites

- La définition des **ACSC est contestée** : toutes les hospitalisations pour insuffisance cardiaque ne sont pas évitables même avec des soins primaires parfaits (décompensations liées à une progression naturelle de la maladie) ; des études montrent que 30-50% des HPE classifiées par les PQI-AHRQ correspondent en réalité à des hospitalisations médicalement nécessaires ; l'IRSP mesure le potentiel de prévention, non la certitude d'évitabilité
- La **standardisation sur l'âge et le sexe** est indispensable mais insuffisante — les territoires avec une proportion élevée de patients en ALD (diabète, IC) ont structurellement plus d'ACSC potentielles, indépendamment de la qualité des soins primaires ; une standardisation supplémentaire sur le profil de comorbidités (Charlson) est recommandée pour les comparaisons inter-territoires avec des profils épidémiologiques très différents
- Le calcul requiert le **chaînage PMSI-DCIR par NIR** pour les analyses incluant les consultations ambulatoires pré-hospitalisation — la version "PMSI seul" (sans DCIR) ne peut calculer que la part HPE/total sans analyser le parcours pré-hospitalier ; c'est une version moins riche mais déjà très informative pour le benchmarking territorial

## Références

- [Billings J. et al. — Impact of socioeconomic status on hospital use in New York City, Health Affairs 1993](https://doi.org/10.1377/hlthaff.12.1.162) — article fondateur des ACSC et de la mesure des hospitalisations évitables
- [AHRQ — Prevention Quality Indicators (PQI) technical specifications (2022)](https://qualityindicators.ahrq.gov/) — référence internationale des indicateurs PQI
- [Or Z. — Indicateurs de qualité et de performance des systèmes de santé en Europe, IRDES 2009](https://www.irdes.fr/)
- [DREES — Les hospitalisations potentiellement évitables en France : état des lieux et déterminants (2018)](https://www.drees.solidarites-sante.gouv.fr/)
- [Haute Autorité de Santé — Pertinence des hospitalisations et soins ambulatoires sensibles aux soins primaires (2019)](https://www.has-sante.fr/)
