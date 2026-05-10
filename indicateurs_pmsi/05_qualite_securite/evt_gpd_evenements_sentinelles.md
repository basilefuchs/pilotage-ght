# Théorie des Valeurs Extrêmes (EVT-GPD) appliquée aux Événements Sentinelles

## Définition

La **théorie des valeurs extrêmes (Extreme Value Theory, EVT)** est la branche de la statistique consacrée à la modélisation des queues de distribution — c'est-à-dire des événements rares mais à fort impact. Appliquée aux **événements sentinelles** hospitaliers (décès inattendu, retour bloc < 24h, transfert non programmé en réanimation, never-events), elle permet d'estimer des probabilités de survenue au-delà des données observées et des **périodes de retour** (intervalle moyen entre deux dépassements d'un niveau donné).

Le théorème de Pickands–Balkema–de Haan (1974-1975) établit que pour la plupart des distributions, la loi conditionnelle des excès au-dessus d'un seuil **u** suffisamment élevé converge vers une **distribution de Pareto généralisée (GPD)** :

```
P(X − u ≤ x | X > u) = G(x; ξ, σ) = 1 − (1 + ξ·x/σ)^(−1/ξ)    si ξ ≠ 0
                                  = 1 − exp(−x/σ)               si ξ = 0
```

avec :
- **ξ** (xi) = paramètre de forme (queue lourde si ξ > 0)
- **σ** = paramètre d'échelle

**Positionnement vs indicateurs existants** : la fiche `value_at_risk_evenements_indesirables.md` du dépôt utilise une VaR empirique (percentile observé), valable uniquement à l'intérieur de l'historique. EVT-GPD permet d'**extrapoler** au-delà : « combien de fois par décennie peut-on attendre un mois à 25 décès inattendus alors qu'on n'a jamais dépassé 18 ? ». La fiche `loi_gutenberg_richter_evenements_indesirables.md` traite de la loi en magnitude/fréquence ; EVT est complémentaire et formellement justifié pour la queue.

**Différence-clé** : la VaR-empirique répond à « quel seuil n'a pas été dépassé dans 95 % des mois passés » ; EVT répond à « quel seuil ne sera dépassé qu'une fois tous les 100 mois en projection ».

## Calcul

```
Étape 1 — Choix du périmètre événements sentinelles :
  - Décès inattendus : mode_sort = 9 hors GHM palliatifs/oncologiques
  - Retours au bloc < 24h : CCAM_2 dans les 24h suivant CCAM_1, même séjour
  - Transferts non programmés en réa : changement d'UM vers UM réanimation
    (codes UM 01, 02, 03 selon nomenclature ATIH) en cours de séjour
  - Never-events : liste HAS (chirurgie sur mauvais côté, oubli de corps étranger…)

Étape 2 — Constitution de la série temporelle :
  Granularité recommandée : journalière ou hebdomadaire
  Sur 36 mois minimum d'historique
  X_t = nombre d'événements sentinelles sur l'intervalle t

Étape 3 — Choix du seuil u (point critique) :
  Méthode 1 — Mean Excess Plot :
    e(u) = E[X − u | X > u]  → tracer e(u) vs u
    → choisir u dans la plage où e(u) est approximativement linéaire
  Méthode 2 — Percentile fixe : u = q90 ou q95 de la distribution
  Règle pratique : retenir entre 5 % et 10 % d'excès

Étape 4 — Estimation des paramètres GPD :
  - Méthode du maximum de vraisemblance sur les excès Y_i = X_i − u (pour X_i > u)
  - Estimation de (ξ, σ) avec IC95 par profile likelihood
  - Diagnostic : QQ-plot, return level plot

Étape 5 — Niveaux et périodes de retour :
  Niveau de retour T-périodes :
    x_T = u + (σ/ξ) · [(T·ζ_u)^ξ − 1]      si ξ ≠ 0
        = u + σ · log(T·ζ_u)               si ξ = 0
    avec ζ_u = P(X > u) = n_excès / N_total

  Période de retour d'un niveau x :
    T(x) = 1 / [ζ_u · (1 + ξ·(x − u)/σ)^(−1/ξ)]
```

Implémentation R via `evd::fpot()`, `extRemes::fevd()` ou `ismev::gpd.fit()`.

## Utilité

- **Dimensionnement de la vigilance et des ressources de crise** : connaître le niveau attendu une fois par décennie permet de calibrer les capacités de réponse (cellules de crise, RMM exceptionnelles) sans sur-dimensionner
- **Communication aux instances** : présenter une période de retour (« le seuil que nous fixons est dépassé en moyenne tous les 50 mois ») est plus parlant qu'un percentile abstrait pour CME / direction / ARS
- **Détection précoce d'une dérive de queue** : si ξ estimé est croissant d'une fenêtre à l'autre, la queue s'alourdit (les pics deviennent plus probables) — alerte sur la stabilité du système qualité, indépendamment de la moyenne
- **Comparabilité inter-établissements GHT** : ξ et niveau de retour à 100 mois fournissent un profil de risque queue-de-distribution commun, robuste aux différences de volume
- **Provisionnement des ressources de réanimation** : sur la queue des transferts non programmés, EVT donne le quantile à long terme nécessaire au dimensionnement de lits de réa de réserve
- **Articulation avec PSI-90** : EVT s'applique aux événements sentinelles individuellement, là où PSI-90 et la VaR opèrent en agrégat — couvre la part « never-events » du référentiel HAS

## Sources de Données

- **PMSI MCO RSA / RUM** : mode de sortie (décès), GHM (filtre des cas attendus), CCAM avec dates pour les retours au bloc, codes UM pour les transferts intra-séjour, durées de séjour pour la chronologie
- **Référentiel des UM ATIH** en vigueur : nomenclature des unités médicales (réanimation, surveillance continue, USC, USI)
- **Liste HAS des never-events** pour le périmètre événements sentinelles graves
- **Historique 36 à 60 mois** : indispensable pour avoir suffisamment d'excès au-dessus du seuil u (≥ 30 excès recommandés pour estimation stable de ξ)
- **Données auxiliaires** : nombre de séjours total par période pour normaliser (taux d'événements sentinelles)

## Exemple de Valeurs

- **Décès inattendus mensuels, CHU 80 000 séjours/an** :
  - moyenne historique : 7 décès/mois ; max observé sur 36 mois : 18
  - seuil u = 12 (q90)
  - GPD ajustée : ξ ≈ 0,15 (queue modérément lourde), σ ≈ 3,2
  - niveau de retour 100 mois : x_100 ≈ 24 décès/mois
  - niveau de retour 10 ans (120 mois) : x_120 ≈ 26 décès/mois
- **Retours bloc < 24h, CH 1 000 lits** :
  - moyenne hebdomadaire : 1,5 ; max observé : 6
  - GPD ajustée : ξ ≈ 0,05 (proche exponentielle), σ ≈ 1,8
  - niveau de retour 1 an : x_52 ≈ 7
- **Seuil d'alerte EVT** : si la valeur observée dans le mois courant dépasse x_T pour T = 24 mois, déclencher revue ; dépassement de x_120 → alerte direction immédiate
- *Valeurs illustratives, ordre de grandeur expert — calibration locale obligatoire avant déploiement opérationnel.*

## Limites

- **Choix du seuil u critique** : trop bas → biais (les excès ne sont plus distribués GPD), trop haut → variance excessive (peu d'observations) ; recourir au mean excess plot et tester la sensibilité du résultat à u
- **Stationnarité requise** : EVT classique suppose une distribution stable ; en cas de rupture (COVID, restructuration), recourir à GPD non-stationnaire (paramètres dépendant du temps) — implémentation plus complexe
- **Volume de données** : avec < 30 excès au-dessus du seuil, l'estimation de ξ est très instable — agréger plusieurs établissements du GHT ou élargir la période
- **Hypothèse d'indépendance** : EVT requiert des excès indépendants ; clusters d'événements (épidémie nosocomiale) violent cette hypothèse → utiliser le « declustering » (Ferro-Segers) avant ajustement
- **Sensibilité au codage exhaustif des EIG** : un sous-codage des événements sentinelles tronque la queue et sous-estime ξ ; un audit qualité du codage est préalable indispensable
- **Sur-interprétation des périodes de retour longues** : x_120 mois extrapolé sur un historique de 36 mois reste une projection, à présenter avec son IC95 (souvent large)
- **Indicateur technique** : nécessite un statisticien formé pour l'ajustement et la communication ; déployer avec un dashboard pédagogique (return level plot avec IC)

## Références

- [Pickands J. — Statistical inference using extreme order statistics, Annals of Statistics 1975 : théorème fondateur GPD](https://doi.org/10.1214/aos/1176343003)
- [Balkema A.A., de Haan L. — Residual life time at great age, Annals of Probability 1974](https://doi.org/10.1214/aop/1176996548)
- [Coles S. — An Introduction to Statistical Modeling of Extreme Values, Springer 2001 : référence pédagogique standard](https://doi.org/10.1007/978-1-4471-3675-0)
- [Embrechts P., Klüppelberg C., Mikosch T. — Modelling Extremal Events for Insurance and Finance, Springer 1997](https://doi.org/10.1007/978-3-642-33483-2)
- [Chavez-Demoulin V., Embrechts P., Hofert M. — An extreme value approach for modeling operational risk losses, J. Risk Insur. 2016 — application méthodologique transposable au risque hospitalier](https://doi.org/10.1111/jori.12059)
- [HAS — Liste des never-events et méthode d'analyse des événements indésirables graves](https://www.has-sante.fr/)
- [ATIH — Manuel des GHM et nomenclature des UM en vigueur](https://www.atih.sante.fr/)
