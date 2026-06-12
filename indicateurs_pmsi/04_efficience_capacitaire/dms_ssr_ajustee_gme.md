# DMS SSR Ajustée au GME (Indice de Performance SSR)

## Définition

Ratio entre la durée de séjour (DMS) observée dans un établissement SSR et la DMS nationale de référence ATIH pour le même GME (Groupe Médico-Économique). Le GME est le groupage tarifaire du PMSI SSR, équivalent fonctionnel du GHM en MCO : il classe les séjours SSR selon la finalité principale de prise en charge (FP), le groupe nosologique (GN), et le niveau de dépendance (cotations AVQ — la MIF n'est pas recueillie dans la base nationale). Un ratio > 1 indique une DMS supérieure à la moyenne nationale pour le même profil de patient (possible inefficience ou complexité non capturée par le GME) ; un ratio < 1 indique une DMS inférieure à la référence (efficience ou risque de sortie prématurée).

Cet indicateur permet un benchmarking équitable entre établissements SSR en neutralisant l'effet du casemix — un SSR spécialisé en neurologie lourde (AVC sévères, DMS nationale ~55 jours pour ce GME) ne peut pas être comparé brut à un SSR locomoteur (PTH, DMS nationale ~18 jours). L'indicateur est l'équivalent SSR de l'IPDMS (Indice de Performance de la Durée Moyenne de Séjour) déjà utilisé en MCO, et s'inscrit dans la même logique de mesure de l'efficience de production hospitalière par rapport à une norme nationale.

## Calcul

Sources de données :

```
1. PMSI SSR RHS (données établissement) :
   → Durée de séjour observée = date_sortie_séjour − date_entrée_séjour (en jours)
     calculée depuis la séquence complète des RHS d'un séjour (1er au dernier RHS)
   → GME du séjour : issu du groupage ATIH sur les variables RHS
     (FP = finalité principale, GN = groupe nosologique,
      niveau de dépendance AVQ à l'entrée — la MIF n'est pas dans la base nationale)

2. Fichiers de référence ATIH (données nationales) :
   → DMS_nationale_GME : durée de séjour nationale pour chaque GME,
     publiée annuellement dans les statistiques SSR de l'ATIH
   → Disponibles en téléchargement sur le portail ATIH (format CSV/Excel)
```

Formules de l'indicateur :

```
Ratio DMS observée/attendue (par séjour) :
  → DMS_attendue_séjour = DMS_nationale_GME du séjour concerné
  → Ratio_séjour = DMS_observée / DMS_attendue_séjour

Indice de Performance SSR (IPS) au niveau de l'établissement :
  IPS = (Σ DMS_observées / Σ DMS_attendues) × 100

  IPS = 100  → performance exactement égale à la médiane nationale
  IPS < 100  → DMS observée < référence nationale (meilleur que la médiane)
  IPS > 100  → DMS observée > référence nationale (moins bon que la médiane)

Bornes d'interprétation opérationnelles :
  IPS < 85   : DMS structurellement courte → risque de sortie prématurée
               surveiller le taux de réhospitalisation MCO à 30j post-SSR
  85-95      : Zone d'efficience
  95-115     : Conformité à la norme nationale (fourchette acceptable ±15%)
  IPS > 115  : DMS excédentaire → investigation : complexité documentée
               ou inefficience organisationnelle ?
  IPS > 130  : Signal fort d'inefficience → audit clinique recommandé
```

Sous-indicateurs complémentaires :

```
Analyse de la distribution des séjours par rapport à la norme :
  → Proportion de séjours avec DMS_obs/DMS_att < 0.75 (séjours très courts)
  → Proportion de séjours avec DMS_obs/DMS_att > 1.5 (séjours très longs)
  → Corrélation DMS × gain AVQ : les séjours longs avec faible delta de dépendance
    (ΔMif < 5 après 30j) sont les candidates prioritaires à l'optimisation

Stratification :
  → IPS par GME principal de l'établissement SSR
  → IPS par tranche d'âge (< 65, 65-74, 75-84, ≥ 85 ans)
  → IPS par niveau de dépendance AVQ à l'entrée (totale vs modérée vs légère)
  → Évolution trimestrielle de l'IPS (trend sur 2 ans)
```

## Utilité

- **Benchmarking équitable inter-établissements SSR du GHT** : l'IPS permet de comparer des établissements SSR aux casemix très différents en neutralisant les effets de structure — un SSR gériatrique avec IPS = 105 est plus efficace qu'un SSR locomoteur avec IPS = 118
- **Identifier les GME spécifiques sur- ou sous-performants** : un IPS global de 100 peut masquer un GME neurologique à IPS 130 (DMS excessive) et un GME locomoteur à IPS 85 (DMS courte) — l'analyse par GME oriente les actions ciblées
- **Optimiser la planification des sorties** : la DMS attendue par GME fournit une cible prévisionnelle dès l'admission SSR — outil de programmation des sorties à J+DMS_attendue pour anticiper l'organisation médico-sociale
- **Appuyer les demandes de révision tarifaire SSR** auprès de l'ATIH si la DMS observée est structurellement supérieure à la référence pour des raisons documentées (territoire rural, patients isolés sans aidant, offre EHPAD insuffisante) — argument objectif pour un financement adapté à la complexité
- **Dialogue ARS/CPOM sur l'efficience des structures SSR** : indicateur contractualisable, comparable aux indicateurs IPDMS MCO déjà présents dans certains CPOM
- **Corrélation avec le taux de bed-blocking MCO** : un IPS élevé (séjours SSR longs) est corrélé à un taux de bed-blocking MCO élevé — la réduction de la DMS SSR excédentaire libère des capacités pour l'aval MCO

## Sources de Données

- **PMSI SSR RHS** : GME (issu du groupage ATIH), dates d'entrée/sortie du séjour SSR, cotations de dépendance AVQ (`dep_phys`, `dep_cogn` — pas de MIF dans la base nationale), FP et GN (pour reconstitution du GME si nécessaire), chaînage `anonyme`
- **Fichiers de référence ATIH** : statistiques nationales SSR par GME publiées annuellement — contiennent la DMS nationale, l'écart-type, les percentiles P25/P75 et P10/P90 par GME ; disponibles sur le portail ATIH (données publiques)
- **PMSI MCO RSA** : chaînage NIR pour corréler l'IPS avec le taux de réhospitalisation MCO post-SSR et le taux de bed-blocking

## Exemple de Valeurs

- **DMS nationale moyenne SSR tous GME** : ~25-30 jours
- **Par GME** :
  - Neurologie cérébro-lésée lourde (AVC sévère, MIF entrée < 36) : ~50-60 jours
  - AVC modéré (MIF entrée 36-72) : ~30-40 jours
  - PTH/PTG : ~15-20 jours
  - Fracture du col du fémur : ~25-35 jours
  - Gériatrie polyvalente : ~25-35 jours
  - Cardiovasculaire : ~20-25 jours
- **IPS cible** : 90-115 (fourchette de performance acceptable selon référentiel ATIH)
- **IPS < 85** : observé dans les SSR à forte rotation (chirurgie orthopédique élective) — à surveiller avec le taux de réhospitalisation MCO à 30j
- **IPS > 120** : fréquent dans les SSR gériatriques en zone rurale sans offre médico-sociale en aval — à documenter avec le taux de patients en attente de place EHPAD (codage Z75.1)

## Limites

- Le GME capture imparfaitement la complexité réelle du patient : deux séjours dans le même GME peuvent avoir des DMS très différentes selon les comorbidités non intégrées dans le groupage SSR (isolement social, trouble cognitif sévère, problème de logement) — une DMS excédentaire n'est pas toujours synonyme d'inefficience
- La DMS nationale de référence ATIH est calculée sur l'ensemble des établissements SSR français, qui ont des profils très hétérogènes (SSR hautement spécialisés vs polyvalents, urbains vs ruraux) — la comparaison d'un petit SSR rural à cette référence nationale peut être peu pertinente ; une comparaison régionale (données ARS) est préférable
- Les séjours très longs (> 90 jours), souvent liés à des situations sociales complexes (impossibilité de retour domicile, attente de place EHPAD), gonflent l'IPS indépendamment de la qualité rééducative — recommander leur analyse séparée
- Les DMS nationales de référence ATIH changent chaque année (revalorisation du référentiel) — les comparaisons temporelles de l'IPS sur plusieurs années nécessitent d'utiliser le référentiel de chaque année concernée

## Références

- [ATIH — Statistiques nationales PMSI SSR et fichiers de référence DMS par GME (portail ATIH)](https://www.atih.sante.fr/)
- [Briggs R. et al. — Predicting length of stay in older patients admitted for rehabilitation, Age Ageing 2017](https://doi.org/10.1093/ageing/afx051)
- [HAS — Critères de certification 2020 sur l'efficience et la pertinence des soins en SSR](https://www.has-sante.fr/)
- [DREES — Les soins de suite et de réadaptation : organisation, activité et financement (2021)](https://www.drees.solidarites-sante.gouv.fr/)
- [Tuppin P. et al. — Value of a national administrative database to guide public decisions: from the système national d'information interrégimes de l'Assurance Maladie (SNIIRAM) to the système national des données de santé (SNDS) in France, Rev Epidemiol Sante Publique 2017](https://doi.org/10.1016/j.respe.2017.05.004)
