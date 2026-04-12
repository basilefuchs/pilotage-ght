# First-Pass Yield — Taux de Parcours Sans Défaut

## Définition

Adapté du concept industriel de qualité Six Sigma, le First-Pass Yield (FPY) mesure la proportion de séjours hospitaliers complétés sans aucun événement de "retraitement" : ni complication documentée, ni réintervention chirurgicale non programmée, ni réhospitalisation à 30 jours. En industrie, le FPY exprime la proportion de pièces sorties conformes du processus de production sans intervention corrective. En MCO, chaque séjour est assimilé à une unité de production et le "défaut" est tout événement contraire à l'objectif thérapeutique initial.

Le FPY est un indicateur composite multiplicatif : il combine trois dimensions de qualité indépendantes en un score unique qui reflète la probabilité qu'un séjour se déroule intégralement sans incident. Il se distingue des indicateurs habituels de qualité — qui mesurent chaque dimension séparément — en capturant la qualité du parcours dans sa globalité. Un service avec 5% de complications, 3% de réinterventions et 10% de réhospitalisations n'est pas performant à 97%, 97% et 90% : son FPY est de 0,95 × 0,97 × 0,90 = **82,9%**, révélant que seulement 83 séjours sur 100 se terminent sans aucun défaut.

Applicable à l'ensemble du PMSI MCO et calculable par GHM, spécialité, chirurgien, ou établissement.

## Calcul

Le FPY est le produit de trois taux de conformité calculés depuis le PMSI MCO :

```
FPY (%) = Taux_sans_complication × Taux_sans_réintervention × Taux_sans_réadmission × 100

Composante 1 — Taux sans complication (qualité intra-séjour) :
  = 1 − Taux de complications documentées (PSI-90 AHRQ ou liste ATIH)
  → Complications codées en CIM-10 comme DA du RSA :
      Infections nosocomiales (A40-A41, T80-T88)
      Thrombose veineuse profonde / EP (I26, I80-I82)
      Pneumopathie de déglutition (J69.0)
      Chute avec fracture (W00-W19 + S00-S99)
      Hématome post-opératoire, déhiscence (T81.x)
      Sepsis post-procédural (T81.4, R65.2)

Composante 2 — Taux sans réintervention chirurgicale non programmée :
  = 1 − (Séjours avec ≥ 2 actes opératoires CCAM dont le 2e est non programmé
          / Total séjours chirurgicaux)
  → Proxy : séjours avec acte CCAM de reprise (révision, évacuation hématome,
    réfection de cicatrice, réopération sur même site dans le même séjour)
  → Codes CCAM de reprise : LMMA009 (révision PTH), LMPA010 (révision PTG),
    ZZQP001 (reprise de plaie opératoire), etc.

Composante 3 — Taux sans réhospitalisation à 30 jours :
  = 1 − Taux de réhospitalisation MCO toutes causes à 30j (chaînage NIR)
  → Fenêtre : J1 à J30 post-DATESOR du séjour index
  → Exclusions : réhospitalisations programmées documentées (chimiothérapie,
    radiothérapie séquentielle, dialyse — GHM identifiables)
```

Calcul illustratif :

```
Exemple service de chirurgie digestive (période N) :
  Taux complication   = 4,2%  → Composante 1 = 0,958
  Taux réintervention = 2,1%  → Composante 2 = 0,979
  Taux réadmission 30j = 8,5% → Composante 3 = 0,915

  FPY = 0,958 × 0,979 × 0,915 = 0,858 → 85,8%

Interprétation : 14,2% des séjours présentent au moins un défaut de parcours.
Identification du levier prioritaire : réadmission à 30j contribue à 8,5%
des défauts → action prioritaire sur préparation de sortie et suivi post-opératoire.
```

Stratification recommandée :

```
FPY par GHM (chirurgie vs médecine, électif vs urgent)
FPY par service médical ou spécialité chirurgicale
FPY par chirurgien (sous réserve de règles de diffusion)
FPY par établissement du GHT (benchmarking inter-sites)
Décomposition du FPY : contribution de chaque composante à la perte de qualité
  → Perte totale = 1 − FPY = Σ(pertes par composante) + termes d'interaction
```

## Utilité

- **Vision intégrée de la qualité de parcours** : le FPY est la première réponse à la question "combien de séjours se passent vraiment bien ?" — question à laquelle aucun indicateur isolé (taux de complication seul, taux de réadmission seul) ne répond. Il donne une lecture immédiatement compréhensible par les équipes médicales et les directions
- **Identification du levier d'amélioration prioritaire** : la décomposition des trois composantes permet d'orienter l'action vers le défaut le plus impactant (ex : si la composante réadmission est le principal contributeur, l'effort doit porter sur le suivi post-hospitalier et la coordination ville-hôpital)
- **Benchmarking entre services et établissements du GHT** : le FPY est comparable entre spécialités car il est normalisé entre 0 et 1 quel que soit le casemix — deux services très différents peuvent avoir leur FPY comparé sur une base commune
- **Suivi de l'impact des démarches qualité** : indicateur synthétique idéal pour mesurer l'effet d'une action d'amélioration (nouveau protocole, programme de formation, outil d'aide à la décision) — une augmentation du FPY de 5 points représente 5 séjours sans défaut supplémentaires pour 100 pris en charge
- **Communication institutionnelle** : le format ratio (83% de séjours sans défaut) est plus parlant pour le grand public et les instances que les taux de complication isolés — utile pour les rapports d'activité qualité et les certifications HAS

## Sources de Données

- **PMSI MCO RSA** : diagnostics associés (DA CIM-10) pour les complications intra-séjour, actes CCAM pour les réinterventions, GHM, DATESOR, NIR crypté
- **Chaînage SNDS par NIR crypté** : identification des réhospitalisations MCO à 30 jours post-sortie, y compris dans des établissements différents du territoire
- **Référentiel PSI-90 AHRQ / ATIH** : liste des codes CIM-10 retenus pour définir les complications intra-séjour (permet une définition standardisée et reproductible de la composante 1)

## Exemple de Valeurs

- **FPY estimé en chirurgie orthopédique élective (PTH/PTG)** : ~88-92% (faible taux de complication, réintervention rare, réadmission ~8-10%)
- **FPY en chirurgie digestive lourde (résection colorectale)** : ~75-82% (complications fréquentes ~10-12%, réadmission ~15-18%)
- **FPY en médecine (décompensations cardiaques)** : ~70-78% (réadmission à 30j élevée ~20-25% même sans complication intra-séjour)
- **Objectif Six Sigma industriel** : FPY > 99,99966% (3,4 défauts par million) — en santé, viser > 90% en chirurgie élective est déjà un objectif ambitieux compte tenu de la complexité des patients
- **Impact de l'amélioration** : une augmentation du FPY de 80% à 85% sur un service réalisant 2000 séjours/an représente 100 séjours supplémentaires sans défaut annuellement

## Limites

- Le FPY est sensible à la qualité du codage PMSI : sous-codage des complications (DA manquants) gonfle artificiellement le FPY et masque les problèmes — l'indicateur est plus fiable dans les établissements avec un DIM actif et un taux de complétude diagnostique élevé
- La définition des "réinterventions non programmées" par les seuls codes CCAM est imparfaite — certaines reprises chirurgicales légitimes (nécrose de lambeau nécessitant révision) peuvent être confondues avec des défauts ; une liste de codes CCAM de reprise validée par les chirurgiens de l'établissement est indispensable
- Le FPY multiplicatif suppose l'indépendance des trois composantes, ce qui est une approximation : une complication intra-séjour augmente la probabilité de réadmission — le FPY sous-estime légèrement la fréquence des séjours réellement sans défaut quand les composantes sont corrélées
- Pas de référentiel national publié pour ce calcul — l'établissement doit définir et documenter sa méthodologie pour permettre des comparaisons inter-établissements reproductibles

## Références

- [Montgomery D.C. — Introduction to Statistical Quality Control (6e éd.), Wiley 2009 : définition du First-Pass Yield et Six Sigma en production industrielle]
- [AHRQ — Patient Safety Indicators Technical Specifications (PSI-90), version 2024 : définition des complications intra-séjour codées en CIM-10](https://qualityindicators.ahrq.gov/)
- [Birkmeyer J.D. et al. — Surgical skill and complication rates after bariatric surgery, NEJM 2013 : variabilité inter-chirurgiens des taux de complication et réopération](https://doi.org/10.1056/NEJMsa1300625)
- [ATIH — Définition des complications et morbidités associées (CMA) dans le PMSI MCO](https://www.atih.sante.fr/)
