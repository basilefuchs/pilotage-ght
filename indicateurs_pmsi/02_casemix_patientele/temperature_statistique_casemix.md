# Température Statistique du Casemix

## Définition

En physique statistique, la **température** d'un système de particules est inversement proportionnelle au paramètre β de la distribution de Boltzmann-Gibbs : P(E) ∝ e^(−βE), où P(E) est la probabilité qu'une particule ait l'énergie E et β = 1/(k_B × T). Une température élevée signifie que la distribution d'énergie est large et aplatie (beaucoup de particules à haute énergie) ; une température basse signifie une distribution concentrée autour des basses énergies (peu d'excitation, système "froid").

Transposée à la distribution des durées de séjour hospitalières, la **Température Statistique du Casemix** (TSC) modélise la DMS comme une variable distribuée selon une loi exponentielle (ou de Pareto pour les queues lourdes) :

**P(DMS > t) = e^(−t/τ)**

où τ = 1/k = DMS moyenne — c'est la "température" du service. Un service "chaud" (τ élevé) a une distribution de DMS aplatie avec beaucoup de séjours longs ; un service "froid" (τ faible) a une distribution concentrée sur les séjours courts.

Mais l'intérêt principal de la TSC est qu'elle va **au-delà de la DMS moyenne** : elle caractérise la **forme** de la distribution des séjours, et en particulier le poids de la queue (les séjours très longs). Deux services peuvent avoir la même DMS moyenne mais des "températures" très différentes si l'un a une queue lourde (quelques séjours extrêmement longs) et l'autre une distribution homogène. La TSC, couplée à l'indice de queue, capture cette hétérogénéité invisible dans les statistiques de moyenne et d'écart-type habituelles.

## Calcul

Test du modèle exponentiel et estimation de τ :

```
Données : séquence des DMS individuelles {d₁, d₂, …, dₙ} pour un service
  (séjours du même GHM ou de la même CMD sur 12 mois)

Étape 1 — Vérification graphique (Q-Q plot exponentiel) :
  Tracer les quantiles empiriques de DMS vs quantiles d'une loi exponentielle
  → Si les points suivent une droite : loi exponentielle vérifiée (cinétique 1er ordre)
  → Si convexe en haut (queue plus lourde) : loi exponentielle sous-estime la queue
    → Ajuster une loi de Weibull ou de Pareto

Étape 2 — Estimation de τ (température) par maximum de vraisemblance :
  Pour une loi exponentielle : τ_MLE = DMS_moyenne = (1/n) × Σᵢ dᵢ
  IC95%(τ) = [τ × (1 − 1.96/√n) ; τ × (1 + 1.96/√n)]

  Pour une loi de Weibull (modèle plus flexible) :
    P(DMS > t) = e^(−(t/λ)^k)
    → k < 1 : queue plus lourde que l'exponentielle (services complexes, gériatrie)
    → k = 1 : loi exponentielle (τ = λ)
    → k > 1 : queue plus légère (séjours homogènes, chirurgie ambulatoire)
    → Estimation par MLE : Python (scipy.stats.weibull_min.fit), R (fitdistrplus::fitdist)
```

Indicateurs dérivés :

```
Température τ (DMS caractéristique) :
  τ = DMS_MLE = estimation robuste de la DMS typique
  → Interprétation : si le processus est exponentiel, 63% des séjours sont
    inférieurs à τ, 37% supérieurs

Indice de Queue Lourde (IQL) :
  IQL = DMS_P90 / DMS_médiane
  → Si loi exponentielle pure : IQL = −ln(0.10) / ln(2) ≈ 3.32 (valeur théorique)
  → IQL > 4 : queue plus lourde que l'exponentielle → présence de "super-longs séjours"
  → IQL < 3 : queue plus légère (séjours homogènes)

Exposant de Pareto α (si queue très lourde) :
  Pour les services avec IQL > 5, ajuster une loi de Pareto :
    P(DMS > t) = (t/t_min)^(−α)   pour t > t_min
  → Estimation : α = 1 + n / Σᵢ ln(dᵢ / t_min)   (estimateur de Hill)
  → α < 2 : queue extrêmement lourde (variance infinie théoriquement — quelques séjours
    très longs dominent toute la statistique)
  → α > 3 : queue légère, statistiques classiques applicables

Rapport température service / température GHM national :
  Ratio_T = τ_service / τ_national_GHM
  → Ratio_T > 1.2 : service "plus chaud" que la référence nationale
    (DMS plus longue, queue plus épaisse — complexité ou inefficience ?)
  → Ratio_T < 0.8 : service "plus froid" que la référence
    (DMS courte, séjours homogènes — efficiency ou sélection de cas ?)
```

Décomposition de la variance de DMS (signal/chaleur) :

```
Variance totale observée de la DMS :
  σ²_total = Var(DMS_observée)

Variance théorique d'une loi exponentielle de paramètre τ :
  σ²_exponentielle = τ²   (propriété de la loi exponentielle : σ = μ)

Excès de variance (queue anormalement lourde) :
  ΔVar = σ²_total − τ²
  → ΔVar > 0 : la distribution réelle a des queues plus lourdes que l'exponentielle
    → Des séjours anormalement longs ne s'expliquent pas par la seule variabilité
      attendue — ils constituent un sous-groupe à investiguer
  → ΔVar ≈ 0 : distribution cohérente avec le modèle exponentiel
    → Pas de structure cachée, variabilité naturelle du processus

Fraction de variance expliquée par les "super-longs séjours" (P95+) :
  FVS = Σ_{d > P95} (dᵢ − τ)² / Σᵢ (dᵢ − τ)²
  → FVS > 50% : les 5% de séjours les plus longs expliquent plus de la moitié
    de toute la variabilité de DMS — ils méritent une analyse individualisée
```

## Utilité

- **Distinguer deux services avec la même DMS mais des profils radicalement différents** : un service avec τ = 8 jours et IQL = 3,2 (distribution régulière) n'a pas le même profil qu'un service avec τ = 8 jours et IQL = 7,5 (quelques séjours de 40-60 jours qui tirent la moyenne) — les actions correctives sont fondamentalement différentes : optimisation du flux standard dans le premier cas, gestion des cas complexes dans le second
- **Identifier et quantifier les "super-longs séjours"** : les séjours dans la queue lourde (au-delà de P95 ou P99) sont souvent invisibles dans les statistiques de DMS moyenne — la TSC les révèle, les quantifie (FVS) et permet de les cibler pour une revue individuelle (bed-blocking, complexité sociale, attente de décision médicale)
- **Benchmarking ajusté sur la forme de distribution, pas seulement la moyenne** : comparer la température τ ET l'exposant de Weibull k entre services du même GHM national — un service avec k < 1 traite des cas plus hétérogènes que ses pairs (justification d'une complexité spécifique), un service avec k > 1 a des séjours très homogènes (possible sélection de cas ou protocole standardisé efficace)
- **Dimensionnement des lits selon la distribution réelle** : le nombre de lits nécessaires pour garantir un taux d'occupation cible dépend non seulement de la DMS moyenne (τ) mais aussi de la forme de la distribution — une queue lourde (IQL élevé) requiert plus de lits tampons qu'une distribution homogène même avec la même DMS moyenne ; la TSC alimente les modèles de simulation de files d'attente
- **Suivi de l'impact des protocoles d'optimisation de séjour** : un protocole de sortie précoce (RAC — Réhabilitation Améliorée après Chirurgie) devrait diminuer τ ET augmenter k (distribution plus concentrée, moins de queues lourdes) — le suivi de ces deux paramètres avant/après est plus riche que le seul suivi de la DMS moyenne

## Sources de Données

- **PMSI MCO RSA** : DMS individuelle de chaque séjour (DATE_SOR − DATE_ENT) par GHM, CMD ou service — base suffisante pour tous les calculs ; fenêtre de 12-24 mois pour un ajustement robuste des paramètres de distribution
- **Base nationale ATIH** : distribution des DMS par GHM au niveau national — pour calculer τ_national et les paramètres de Weibull de référence ; permettent le calcul du Ratio_T et la détection des services statistiquement hors norme
- **Implémentation** : Python (scipy.stats : expon.fit, weibull_min.fit, pareto.fit ; powerlaw pour l'exposant de Pareto), R (fitdistrplus : fitdist avec "exp", "weibull", "pareto") — calcul rapide même sur plusieurs années de données

## Exemple de Valeurs

- **Service de chirurgie orthopédique (PTH, GHM 08C48)** :
  τ = 5,2 jours, k_Weibull = 2,1 (queue légère, séjours homogènes)
  IQL = 2,8 (inférieur à la valeur exponentielle de 3,32)
  → Service "froid" avec distribution concentrée — protocole RAC bien appliqué
  Ratio_T = 5,2 / 6,8 (national) = 0,76 → DMS 24% en dessous de la référence

- **Service de gériatrie aiguë (CMD 15)** :
  τ = 11,4 jours, k_Weibull = 0,72 (queue très lourde)
  IQL = 5,8 (queue bien plus lourde que l'exponentielle)
  FVS = 61% (les 5% de séjours les plus longs expliquent 61% de la variance de DMS)
  → Service "très chaud", hétérogène — quelques patients en grande complexité sociale
    ou médicale bloquent des lits ; investigation individuelle des P95+ justifiée

- **Exposant de Pareto en réanimation** :
  α = 1,8 (queue extrêmement lourde, variance théoriquement infinie)
  → Les statistiques de DMS moyenne sont trompeuses — quelques séjours de 60-120 jours
    dominent toute la statistique ; gestion des "grands séjours" prioritaire

- **Impact d'un protocole RAC en chirurgie colorectale** :
  Avant RAC : τ = 9,1j, k = 0,91 (queue modérée)
  Après RAC : τ = 6,2j, k = 1,35 (distribution plus homogène, queue réduite)
  → Le protocole RAC a réduit τ de 32% ET régularisé la distribution (k > 1)
    — double bénéfice non visible dans la seule DMS moyenne

## Limites

- La loi exponentielle est un **modèle simplifié** de la distribution des DMS — elle suppose un taux constant de sortie quelle que soit la durée du séjour, ce qui est biologiquement discutable ; le modèle de Weibull est plus général mais requiert plus de données pour des estimations robustes (N > 100 séjours par groupe)
- La **stratification par GHM** est indispensable avant l'analyse — mélanger des GHM différents dans le même ajustement produit une distribution bimodale ou multimodale qui n'est ni exponentielle ni de Weibull ; la TSC doit être calculée au niveau GHM ou au niveau d'un groupe homogène cliniquement
- Le **seuil t_min** pour l'ajustement de la loi de Pareto est un paramètre délicat — il définit à partir de quelle DMS on considère être dans la "queue lourde" ; des méthodes automatiques (estimateur de Hill, test de Kolmogorov-Smirnov) existent mais restent sensibles à ce choix
- La TSC ne dit pas **pourquoi** la queue est lourde — un IQL élevé peut refléter une complexité médicale légitime (patients très sévères nécessitant un long séjour), un bed-blocking organisationnel (patients prêts à sortir mais sans aval), ou un biais de codage (séjours non clos administrativement) ; une investigation des séjours en queue lourde est nécessaire pour distinguer ces causes

## Références

- [Boltzmann L. — Vorlesungen über Gastheorie (Leçons sur la théorie des gaz), 1896 : fondements de la distribution de Boltzmann-Gibbs]
- [Weibull W. — A statistical distribution function of wide applicability, Journal of Applied Mechanics 1951](https://doi.org/10.1115/1.4010337) — distribution de Weibull
- [Clauset A. et al. — Power-law distributions in empirical data, SIAM Review 2009](https://doi.org/10.1137/070710111) — méthodes d'ajustement des lois de puissance et test de Pareto
- [Marazzi A. et al. — Fitting the distributions of length of stay by parametric models, Medical Care 1998](https://doi.org/10.1097/00005650-199806000-00014) — ajustement de lois paramétriques aux DMS hospitalières
- [ATIH — Statistiques de DMS par GHM : distributions et percentiles nationaux (rapports annuels)](https://www.atih.sante.fr/)
- [HAS — Réhabilitation améliorée après chirurgie (RAAC) : guide de mise en œuvre (2020)](https://www.has-sante.fr/)
