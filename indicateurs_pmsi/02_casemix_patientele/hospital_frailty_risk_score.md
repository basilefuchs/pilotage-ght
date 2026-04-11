# Score de Fragilité Hospitalière (Hospital Frailty Risk Score — HFRS)

## Définition

Le HFRS est un score mesurant la fragilité des patients hospitalisés, calculé exclusivement à partir des codes diagnostiques CIM-10 présents dans les données administratives hospitalières (PMSI en France). Développé par Gilbert T. et al. sur une cohorte britannique de 22 139 patients âgés de ≥75 ans (Lancet 2018), il repose sur 34 codes CIM-10 associés aux syndromes de fragilité (délirium, chutes, incontinence urinaire, démence, escarres, troubles de la mobilité, dénutrition, amaigrissement, etc.), chacun pondéré par son association avec des résultats défavorables. Le HFRS comble un manque critique : alors que les indices de Charlson et d'Elixhauser capturent la charge en comorbidités (nombre et sévérité des maladies chroniques), ils ne capturent pas la fragilité — un syndrome distinct reflétant la réduction de la réserve physiologique, la vulnérabilité aux agents stresseurs et l'incapacité à maintenir l'homéostasie. Dans un contexte de GHT, le HFRS permet l'identification systématique des patients âgés fragiles dans le case-mix, l'anticipation des besoins de prise en charge complexe et le benchmarking des résultats de sortie pour cette population.

## Calcul

Le HFRS est la somme des poids associés aux codes CIM-10 présents dans le séjour :

```
HFRS — 34 codes CIM-10 et leurs poids :

Code  Description                                          Poids
F00   Démence dans la maladie d'Alzheimer                  7.45
F01   Démence vasculaire                                   7.45
F02   Démence dans d'autres maladies                       7.45
F03   Démence sans précision                               7.45
F05   Délirium (non lié à alcool/drogues)                  5.23
G81   Hémiplégie                                           3.29
G30   Maladie d'Alzheimer                                  7.45
I69   Séquelles de maladies cérébrovasculaires             3.29
J96   Insuffisance respiratoire                            3.29
K59   Autres troubles fonctionnels de l'intestin           1.67
L89   Escarre                                              4.53
M19   Autres arthroses                                     1.67
M81   Ostéoporose sans fracture pathologique               1.47
N39   Autres affections de l'appareil urinaire             1.67
R26   Anomalies de la démarche et de la mobilité           2.63
R29   Autres symptômes nerveux/musculosquelettiques        2.63
R31   Hématurie non précisée                               1.67
R32   Incontinence urinaire non précisée                   2.21
R41   Autres symptômes cognitifs                           2.63
R54   Sénilité                                             3.29
R55   Syncope                                              1.67
R62   Défaut de développement normal                       2.63
R63   Symptômes liés à l'alimentation                      2.63
R64   Cachexie                                             4.53
T83   Complication d'implant urinaire                      1.67
W06   Chute d'un lit                                       3.29
W18   Autres chutes sur même niveau                        3.29
W19   Chute sans précision                                 3.29
Z50   Soins de rééducation                                 2.63
Z74   Problèmes liés à la dépendance                       3.29
Z75   Problèmes d'accès aux soins                          2.63
Z87   Antécédents personnels de maladies                   1.67
Z93   Présence d'ostomie                                   2.21
Z99   Dépendance à machines/appareils                      2.63
```

```
HFRS = Σ poids des codes CIM-10 présents dans le séjour index
  → Calculé sur le séjour d'index OU sur l'ensemble des séjours des 2 années précédentes
    (version "rolling" plus sensible)

Stratification :
  HFRS < 5    → faible fragilité (low frailty risk)
  HFRS 5-15   → fragilité intermédiaire (intermediate frailty risk)
  HFRS > 15   → fragilité élevée (high frailty risk)

Sous-indicateurs dérivés :
  → Proportion patients HFRS > 15 dans le case-mix MCO (%)
  → HFRS moyen par GHM / CMD / spécialité
  → HFRS moyen par établissement membre du GHT (benchmark interne)
  → Taux de patients HFRS > 15 avec DMS > borne haute (prolongation séjour liée à la fragilité)
  → Taux de retour à domicile vs orientation en EHPAD pour patients HFRS > 15
```

## Utilité

- **Enrichissement du case-mix au-delà des comorbidités** : le HFRS complète Charlson/Elixhauser en capturant la dimension gériatrique — un patient avec HFRS élevé mais Charlson faible est tout aussi à risque de DMS prolongée et de réadmission, ce que les indices de comorbidité seuls ne détectent pas
- **Anticipation des besoins de coordination à la sortie** : les patients HFRS > 15 ont un risque de séjour prolongé × 2, de réadmission à 30j × 1.8, et de décès hospitalier × 3 — leur identification précoce active les filières gériatriques, la coordination avec les EHPAD et les services sociaux
- **Benchmarking gériatrique inter-établissements** : comparaison de la proportion de patients fragiles entre les établissements membres du GHT pour ajuster les ressources gériatriques (ETP gériatres, lits SSR, assistantes sociales)
- **Ajustement au risque pour les indicateurs de qualité** : utiliser le HFRS comme covariable dans les modèles de mortalité ajustée (SHMI) et de réadmission pour ne pas pénaliser les établissements recevant plus de patients fragiles
- **Pilotage des filières gériatriques** : mesurer l'évolution du HFRS moyen dans le case-mix du GHT année par année — une hausse traduit le vieillissement de la population et justifie des investissements en filières gériatriques (court séjour gériatrique, UROG, HAD gériatrique)
- **Outil de dialogue avec l'ARS** : argumenter les besoins en capacité SSR et en coordination ville-hôpital pour les patients fragiles avec données PMSI objectives

## Sources de Données

- **PMSI MCO RSA** : codes CIM-10 diagnostics principaux et associés (champs DGP/DAS/DAD), source principale pour le calcul du HFRS
- **Référentiel CIM-10 FR** : équivalences codes UK→FR validées pour l'adaptation des 34 codes originaux au contexte français
- **INSEE données démographiques communales** : contexte de vieillissement territorial pour l'interprétation des tendances du HFRS dans le case-mix du GHT

## Exemple de Valeurs

- **Cohorte de validation UK (Gilbert 2018)** : 47 % des patients âgés de ≥75 ans avaient un HFRS > 5 (fragilité intermédiaire ou élevée) ; 24 % avaient un HFRS > 15 (fragilité élevée)
- **Risques associés au HFRS > 15** : OR mortalité 3.06 (IC 95 % 2.85-3.30), OR DMS prolongée 2.13, OR réadmission 1.61
- **Estimations MCO français** : environ 20-25 % des patients âgés de ≥75 ans ont un HFRS > 15 en court séjour hospitalier
- **HFRS moyen par spécialité** : gériatrie (~12-15), médecine (~6-8), chirurgie (~3-5) — reflète la distribution attendue de la fragilité
- **Patients fracture de hanche avec HFRS > 15** : taux de 50 % (Mitsutake 2023) — population clé pour les unités d'orthopédie du GHT

## Limites

- Le HFRS a été développé et validé au Royaume-Uni sur des patients ≥75 ans — sa calibration sur la population française et sur des patients plus jeunes (65-74 ans) n'a pas encore été publiée ; une validation locale sur les données PMSI du GHT est recommandée avant utilisation normative
- Le score est calculé depuis les codes CIM-10 documentés dans le séjour, qui reflètent la qualité du codage — un codage incomplet des diagnostics associés (délirium, chutes, incontinence) sous-estime systématiquement le HFRS et biaise la comparaison entre établissements avec des pratiques de codage différentes
- Le HFRS mesure la fragilité telle qu'elle est codée à l'admission, pas la fragilité clinique évaluée par un gériatre (score de Fried, grille AGGIR) — les deux approches sont complémentaires mais non interchangeables
- La version "rolling" (séjours des 2 années précédentes) nécessite le chaînage des séjours par NIR crypté sur plusieurs années — données disponibles dans le PMSI chaîné mais calcul plus complexe que la version "index séjour seul"
- Le HFRS ne capture pas la fragilité des patients hospitalisés pour la première fois sans antécédents PMSI documentés (primo-hospitalisation)

## Références

- [Gilbert T. et al. — Development and validation of a Hospital Frailty Risk Score focusing on older people in acute care settings using electronic hospital records: an observational study, Lancet 2018](https://doi.org/10.1016/S0140-6736(18)30668-8)
- [Mitsutake S. et al. — The role of frailty risk for fracture-related hospital readmission and mortality after a hip fracture, Arch Gerontol Geriatr 2023](https://doi.org/10.1016/j.archger.2023.105264)
- [ATIH — PMSI MCO RSA : codes CIM-10 diagnostics principaux et associés](https://www.atih.sante.fr/)
- [HAS — Référentiel de prise en charge des personnes âgées fragiles en établissement de santé](https://www.has-sante.fr/)
- [SFGG (Société Française de Gériatrie et de Gérontologie) — Recommandations sur le dépistage de la fragilité](https://www.sfgg.fr/)
