# Indice de Succession Morbide

## Définition

En écologie végétale, la **succession** décrit la progression directionnelle et ordonnée d'un écosystème à travers des stades successifs (communauté pionnière → stades intermédiaires → climax). La vitesse de succession et la réversibilité de chaque stade caractérisent la dynamique du système. Transposé à la trajectoire clinique d'un patient, **l'indice de succession morbide** (ISM) mesure la vitesse de progression à travers des stades morbides successifs définis de manière opérationnelle à partir des données PMSI/SNDS : stable → décompensation aiguë → chronicisation → soins palliatifs.

Quatre stades sont définis pour les patients porteurs d'une ALD ou d'une pathologie chronique indexée :

| Stade | Code | Critère opérationnel PMSI/SNDS |
|---|---|---|
| Stable | 0 | ALD active, ≤ 1 hospitalisation MCO/an pour la pathologie, pas de SSR ni HAD |
| Décompensation aiguë | 1 | Hospitalisation MCO non programmée (mode_entree ∈ {8,9}) pour la pathologie index |
| Chronicisation | 2 | ≥ 2 hospitalisations MCO/an pour la pathologie OU séjour SSR OU séjour HAD |
| Soins palliatifs | 3 | CIM-10 Z51.5 en DP/DR OU GHM soins palliatifs (CMD 23) OU HAD palliative (MPP = 01) |

La formule de l'ISM individuel est :

ISM = Σₖ (Δstade_k × durée_stade_k_jours) / (durée_suivi × 365)

où Δstade_k est la variation de stade à chaque transition (positif si aggravation, négatif si amélioration), durée_stade_k est le nombre de jours passés dans le stade avant la transition, et durée_suivi est la durée totale de suivi en années. L'ISM est exprimé en unités-stade/an.

- ISM ≈ 0 : patient stable, sans progression ni régression nette
- ISM > 0 : progression morbide (aggravation au cours du temps)
- ISM < 0 : régression (rémission, amélioration durable — cas rares, peut indiquer un biais de codage)
- ISM ≥ 1.5 : progression rapide vers les stades sévères, surveillance rapprochée

Cet indicateur est distinct des indicateurs de sévérité instantanée (score de Charlson, indice de lourdeur des cas, taux de polypathologie sévère) qui mesurent l'état ponctuel du patient, et du taux de recours aux soins palliatifs qui mesure uniquement l'atteinte du stade terminal. L'ISM mesure la **dynamique longitudinale** de la trajectoire clinique — information inaccessible par tout indicateur transversal.

## Calcul

**Sources :** SNDS chaîné (DCIR + PMSI MCO + PMSI SSR + PMSI HAD), horizon de suivi minimum 24 mois par patient.

```
Population : patients porteurs d'une ALD active (IR_ALD_R) dans la période,
             âge ≥ 18 ans, suivi documenté ≥ 24 mois dans le SNDS

Étape 1 — Définition de la pathologie index par patient :
  Chaque patient est indexé sur son ALD principale (ALD_TYP, ex. ALD 13 = insuffisance cardiaque)
  Table de mapping ALD ↔ CIM-10 ↔ GHM : construire une table par groupe pathologique
    (ex. ALD 13 : codes CIM-10 I50.x, I11.0, I13.x ; GHM CMD 05 cardio-vasculaire)

Étape 2 — Attribution du stade à chaque période de 90 jours :
  Pour chaque fenêtre glissante de 90 jours :
    → Stade 3 si Z51.5 DP/DR ou CMD 23 ou HAD MPP=01 détecté dans la fenêtre
    → Stade 2 si ≥ 2 hospit MCO pour pathologie index OU séjour SSR OU HAD (non palliatif)
    → Stade 1 si 1 hospit MCO non programmée pour pathologie index
    → Stade 0 sinon (ALD active, aucun autre critère)
    Règle de priorité : stade le plus élevé observé prime sur la fenêtre

Étape 3 — Construction de la séquence de stades :
  Séquence : [s₁, s₂, ..., sₙ] avec n = durée_suivi_jours / 90
  Identifier les transitions : (sₖ, sₖ₊₁) avec sₖ ≠ sₖ₊₁
  Δstade_k = sₖ₊₁ − sₖ  (positif = aggravation, négatif = amélioration)
  Durée_stade_k = durée du séjour dans le stade sₖ avant transition (en jours)

Étape 4 — ISM individuel :
  ISM = Σₖ (Δstade_k × durée_stade_k) / (durée_suivi × 365)
  Convention : durée_suivi = date_dernière_observation − date_première_ALD (en années)
  Valeur manquante si durée_suivi < 365 jours ou si < 2 fenêtres observées

Étape 5 — Agrégation par groupe :
  ISM_moy(groupe) = moyenne des ISM individuels, stratifiée par :
    - Groupe pathologique (ALD1 à ALD30)
    - FINESS établissement index (dernier séjour MCO dans la période)
    - Tranche d'âge (< 60, 60-74, 75-84, ≥ 85 ans)
  Distribution : D10, D25, D50, D75, D90 pour caractériser l'hétérogénéité intra-groupe

Étape 6 — Indicateurs dérivés :
  Taux de progression stade 0→3 en < 2 ans :
    n(patients passés de stade 0 à stade 3 en moins de 730j) / n_total × 100
  ISM_ajusté_âge : ISM standardisé sur la structure d'âge de référence du groupe
  Délai médian stade 0→2 : en mois, par pathologie et par établissement GHT
```

**Cas limites :**
- Codage insuffisant du stade 3 (Z51.5 souvent sous-codé) : utiliser HAD avec MPP=01 comme critère de détection complémentaire ; documenter le taux de détection dans les notes méthodologiques
- Régression de stade 2→0 (ex. greffe, chirurgie curative) : ISM peut être négatif — valider cliniquement avant interprétation
- Pathologies à cours épisodique (ex. épilepsie, SEP rémittente-récurrente) : la succession n'est pas linéaire ; adapter la fenêtre de 90j à la durée d'un épisode typique

## Utilité

- **Anticiper la transition vers les soins palliatifs** : les patients avec ISM > 1.5 sur insuffisance cardiaque ou BPCO ont une probabilité élevée d'atteindre le stade 3 dans les 18 mois suivants — permet de déclencher précocement une discussion ACP (Advance Care Planning) et d'activer les équipes mobiles de soins palliatifs
- **Planifier les capacités SSR long-cours du GHT** : l'ISM moyen d'une cohorte de patients ALD identifie la vélocité de glissement vers les stades 2-3, qui déterminent la demande future en lits SSR, HAD et USLD — indicateur prospectif pour les projets médicaux de territoire
- **Comparer la dynamique morbide entre établissements du GHT** : un ISM moyen plus élevé dans un établissement pour un même groupe pathologique peut signaler un recrutement de patients plus sévères (effet casemix) ou une moindre efficacité des interventions préventives de décompensation — à analyser conjointement avec le taux d'hospitalisations potentiellement évitables
- **Évaluer l'impact des programmes de gestion des maladies chroniques** : comparer ISM avant/après déploiement d'un protocole de suivi coordonné (infirmière d'éducation thérapeutique, télésurveillance insuffisance cardiaque, PRADO BPCO) — un ISM stable ou décroissant valide l'efficacité du programme
- **Stratifier les cohortes pour les études médicales économiques** : l'ISM permet de contrôler la progression morbide dans les analyses de coût par pathologie, en distinguant les coûts liés à la sévérité initiale de ceux liés à la vitesse de progression
- **Alimenter les indicateurs de performance des filières** : pour une filière gériatrique, l'objectif de stabilisation du stade (ISM cible < 0.3 pour les patients en hôpital de jour de gériatrie) constitue un indicateur de résultat mesurable et opposable dans les CPOM

## Sources de Données

- **SNDS — `IR_ALD_R`** : date de début et de fin d'ALD par type (`ALD_TYP`), identifiant bénéficiaire — définition du groupe pathologique et de la période de suivi
- **PMSI MCO — RSA** : `MODE_ENTREE` (programmé vs non programmé), `DP` et `DR` CIM-10, CMD, GHM, `ENT_DAT`, `SOR_DAT` — détection des stades 1, 2 et 3
- **PMSI SSR — RHS** : présence de séjour SSR dans la période de suivi — détection du stade 2
- **PMSI HAD** : `MPP` (motif principal de prise en charge, code 01 = soins palliatifs), `ENT_DAT` — détection des stades 2 et 3
- **Table de mapping pathologique** : correspondance ALD ↔ CIM-10 ↔ GHM construite en interne avec validation médicale pour chaque groupe nosologique (à produire et maintenir par l'équipe d'analyse)
- **CCAM ATIH** : pour les pathologies dont l'épisode index est un acte (ex. cancer avec chirurgie curative) — détection de la rémission potentielle

## Exemple de Valeurs

| Pathologie (ALD) | ISM médian attendu | Plage D25-D75 | ISM > 1.5 (%) |
|---|---|---|---|
| Diabète type 2 sans complication (ALD 8) | 0.10 – 0.25 | 0.05 – 0.45 | ~5 % |
| Insuffisance cardiaque (ALD 5) | 0.50 – 1.00 | 0.20 – 1.60 | ~20 % |
| BPCO sévère (ALD 14) | 0.60 – 1.10 | 0.25 – 1.80 | ~25 % |
| Cancer colorectal stade III (ALD 30) | 1.00 – 2.00 | 0.60 – 3.00 | ~40 % |
| Cancer du poumon stade IV (ALD 30) | 2.00 – 3.50 | 1.50 – 4.50 | ~70 % |
| IRC pré-dialyse (ALD 19) | 0.40 – 0.80 | 0.15 – 1.30 | ~15 % |
| Maladie de Parkinson (ALD 16) | 0.30 – 0.70 | 0.10 – 1.20 | ~12 % |

**Seuil d'alerte populationnelle :** ISM médian annuel de la cohorte ALD 5 (cardio) > 0.80 sur deux années consécutives → révision de la filière insuffisance cardiaque du GHT

## Limites

- **Stades non standardisés dans le PMSI** : la définition opérationnelle des 4 stades repose sur une table de mapping ALD/CIM-10/GHM construite en interne, non validée par l'ATIH — des variations de définition entre GHT rendraient les comparaisons inter-établissements difficiles sans harmonisation préalable
- **Sous-codage du stade 3** : le code Z51.5 (soins palliatifs) est notablement sous-renseigné dans le PMSI français (estimé à 30-50 % des situations palliatives réelles selon les audits SFAP) ; l'ISM sous-estime donc la proportion de patients en stade 3 et leur vitesse d'atteinte
- **Fenêtre de 90 jours inadaptée aux pathologies épisodiques** : pour les pathologies à cours rémittent (SEP, Crohn, épilepsie), la fenêtre de 90 jours peut sur-classifier en stade 1 des patients stable ayant eu un épisode isolé ; une fenêtre glissante de 180 jours est recommandée pour ces groupes
- **Régression artefactuelle** : un ISM négatif peut refléter une guérison réelle (chirurgie curative), un biais de codage (sous-codage progressif des comorbidités en DA), ou un déménagement hors territoire (perte de suivi dans le SNDS local) — distinguer ces cas nécessite une analyse au cas par cas
- **Durée de suivi minimale** : l'ISM est instable pour des suivis < 24 mois (une seule transition observée peut dominer le numérateur) ; pour les études comparatives, recommander un seuil minimal de 36 mois de suivi documenté

## Références

- [Clements F.E. — Plant Succession: An Analysis of the Development of Vegetation, Carnegie Institution 1916 : fondements de la théorie de succession écologique]
- [Schuling J. et al. — Should we classify multimorbidity by severity? A study of the clinical validity of a new multimorbidity severity classification, BMC Family Practice 2012 : opérationnalisation des stades de morbidité en soins primaires](https://doi.org/10.1186/1471-2296-13-38)
- [Murray S.A. et al. — Illness trajectories and palliative care, BMJ 2005 : modèle des trajectoires de fin de vie (déclin progressif, déclin rapide, lent) — base conceptuelle des stades 2-3](https://doi.org/10.1136/bmj.330.7498.1007)
- [Barnett K. et al. — Epidemiology of multimorbidity and implications for health care, research, and medical education, Lancet 2012 : profils de progression de la multimorbidité](https://doi.org/10.1016/S0140-6736(12)60240-2)
- [Tuppin P. et al. — Prévalence et charge du diabète traité en France en 2012, Bulletin Épidémiologique Hebdomadaire 2014 : utilisation du SNDS pour le suivi longitudinal des ALD]
- [SFAP — Soins palliatifs : état des lieux du codage PMSI, rapport 2020 : documentation du sous-codage Z51.5](https://www.sfap.org/)
- [ATIH — Guide de lecture du PMSI SSR et HAD (MPP codes) version en vigueur](https://www.atih.sante.fr/)
