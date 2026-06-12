# Indice de Résilience Post-Perturbation

## Définition

La résilience écologique, telle que formalisée par Holling (1973), mesure la capacité d'un système à absorber une perturbation et à se réorganiser pour maintenir son fonctionnement. Pimm (1984) en a proposé une définition opérationnelle : la résilience est l'inverse du temps de retour à l'état d'équilibre après une perturbation. Cette définition est directement transposable aux séries temporelles d'activité hospitalière.

L'indice de résilience post-perturbation (IRPP) quantifie la capacité d'un établissement à retrouver son niveau d'activité après une rupture — pandémie, grève longue, fermeture d'urgence, restructuration. Il se distingue des indicateurs de volatilité (variance, coefficient de variation) qui mesurent l'instabilité permanente du signal sans distinguer les perturbations ponctuelles du bruit de fond.

Formellement, pour une série mensuelle d'admissions X_t :

```
1. Détection du point de rupture t* : algorithme CUSUM ou test de Pettitt
2. Définition de la baseline : μ_baseline = moyenne(X_t, t ∈ [t*−24m ; t*−1m])
3. Retour à la baseline : t_retour = min{t > t* : |X_t − μ_baseline| < σ_baseline}
4. Durée de perturbation : D = t_retour − t*  (en mois)
5. Amplitude intégrée : A = Σ_{t=t*}^{t_retour} |X_t − μ_baseline| / μ_baseline
6. IRPP = 1 / (D × A)  (résistance × vitesse de récupération combinées)
```

Un IRPP élevé signifie une perturbation courte et de faible amplitude : l'établissement a absorbé le choc rapidement. Un IRPP faible signifie une disruption longue et profonde. L'indice est non dimensionnel et comparable entre établissements de tailles différentes grâce à la normalisation par μ_baseline.

Le CUSUM (Cumulative Sum Control Chart) d'activité existant dans certains établissements mesure si l'activité sort d'un corridor de contrôle, mais ne quantifie pas le retour à l'équilibre ni ne produit d'indicateur synthétique de résilience.

## Calcul

Source : PMSI MCO RSA — variable `date_entree` (mois/année), `finessgeo` — série mensuelle d'admissions sur 5 ans minimum.

```
Population : tous séjours MCO d'un établissement, agrégés par mois

Étape 1 — Série temporelle mensuelle :
  X_t = count(RSA | finessgeo = e, mois = t)
  t ∈ {T0, T0+1, ..., T0+N}  (N ≥ 60 mois recommandé)

Étape 2 — Détection du point de rupture par CUSUM :
  μ_ref = moyenne(X_t) sur les 24 mois précédant la fenêtre d'analyse
  σ_ref = écart-type sur les mêmes 24 mois

  CUSUM_t = max(0, CUSUM_{t-1} + (μ_ref − X_t − k·σ_ref))
    où k = 0,5 (seuil de sensibilité standard)
  Signal de rupture : CUSUM_t > h·σ_ref  avec h = 5 (seuil CUSUM standard)

  Alternative (perturbations connues) : t* peut être défini manuellement
    (ex. t* = mars 2020 pour COVID-19, t* = date officielle d'une grève)

  Baseline pré-perturbation :
  μ_baseline = moyenne(X_t, t ∈ [t*−24 ; t*−1])
  σ_baseline = écart-type sur la même période

Étape 3 — Délimitation de la fenêtre de perturbation :
  Début : t* (point de rupture détecté)
  Fin (t_retour) : premier mois consécutif où |X_t − μ_baseline| < 0,5·σ_baseline
    pendant ≥ 3 mois consécutifs (évite les faux retours temporaires)

  Si t_retour non observé dans les 24 mois suivant t* :
    → IRPP = NA (perturbation persistante, non résolue sur la fenêtre)

Étape 4 — Calcul des composantes :
  D = t_retour − t*                         (durée, en mois)
  Ecart_t = (X_t − μ_baseline) / μ_baseline (déviation relative mensuelle)
  A = Σ_{t=t*}^{t_retour−1} |Ecart_t|      (amplitude intégrée, sans unité)

Étape 5 — Indice de résilience :
  IRPP = 1 / (D × A)
  Valeur typique : 0,01–0,50
  > 0,20 : résilience forte (retour rapide, déviation faible)
  0,05–0,20 : résilience modérée
  < 0,05 : résilience faible (disruption longue ou profonde)

  IRPP normalisé (comparaison inter-perturbations) :
  IRPP_norm = IRPP / IRPP_ref_national
    où IRPP_ref_national = médiane des IRPP observés sur le même type de perturbation
    sur le panel national d'établissements de même type (MCO, CHU, CH)

Cas limites :
  - Si D = 0 (retour immédiat) : IRPP = +∞ → plafonner à IRPP_max = 10
  - Si A = 0 (pas de déviation malgré rupture détectée) : vérifier le signal CUSUM
  - Si plusieurs perturbations sur la période : calculer un IRPP par perturbation
    et reporter la médiane et le min
```

Indicateurs dérivés :

```
Composante résistance : Résistance = 1 / max(|Ecart_t|)
  → capacité à limiter l'amplitude maximale de déviation
  (distinct de la résilience : un établissement peut être résistant mais lent à récupérer)

Composante récupération : Récupération = 1 / D
  → vitesse de retour à la normale, indépendamment de l'amplitude

Indice de rebond tardif :
  Si X_t > μ_baseline + 1,5·σ_baseline sur ≥ 2 mois après t_retour
  → signale un effet de rattrapage post-perturbation (report de soins)
  Quantifié par : Excédent_rattrapage = Σ(X_t − μ_baseline) / μ_baseline sur la période d'excédent
```

## Utilité

- **Évaluation de la capacité organisationnelle de rebond** : comparer l'IRPP entre établissements du GHT sur une même perturbation (COVID-19 : t* = mars 2020) révèle quelles structures ont les meilleurs mécanismes d'adaptation organisationnelle — gouvernance, flexibilité des plannings, réactivité des admissions programmées
- **Benchmark sur perturbations historiques typées** : distinguer l'IRPP sur perturbations endogènes (grève, travaux, restructuration) de l'IRPP sur perturbations exogènes (épidémie, catastrophe) permet de séparer la résilience organisationnelle de la résilience face à des chocs non maîtrisables
- **Anticipation de la durée de récupération** : calibrer des plans de retour à l'activité nominale en s'appuyant sur les IRPP historiques de l'établissement — «d'après nos deux dernières perturbations majeures, le retour à 95% de l'activité prend en moyenne 8 mois»
- **Planification du rattrapage chirurgical** : l'indice de rebond tardif quantifie l'ampleur du report de soins accumulé — information critique pour dimensionner les plans de déprogrammation et de remise en liste d'attente
- **Argument dans les négociations de financement post-crise** : l'IRPP objectivé sur données PMSI donne un fondement quantitatif aux demandes d'aide à la reprise d'activité auprès de l'ARS ou dans le cadre des CPOM
- **Indicateur de qualité managériale** : intégrer l'IRPP dans le tableau de bord de la direction médicale comme proxy de la robustesse organisationnelle — complémentaire des indicateurs de sécurité et de qualité

## Sources de Données

- **PMSI MCO RSA** : variable `date_entree` (AAAAMMJJ ou AAAAMM), `finessgeo` — série mensuelle construite en interne depuis le SIH ou extraite des tableaux de bord ATIH
- **Registre interne des perturbations** : liste datée des événements perturbateurs (grèves avec dates, fermetures d'urgence, travaux, réorganisations, crises sanitaires) — sans ce registre, seul le mode automatique CUSUM est utilisable
- **Base nationale ATIH** : pour calculer l'IRPP_ref_national de référence sur le même type de perturbation et le même type d'établissement

## Exemple de Valeurs

- **COVID-19 (t* = mars 2020) — CHU** : D = 7 mois, A = 3,2 (déviation cumulée), IRPP = 0,044 — résilience faible ; rebond tardif de +18% au T4 2020
- **COVID-19 — CH 300 lits (MCO pur)** : D = 5 mois, A = 2,1, IRPP = 0,095 — résilience modérée ; rebond tardif de +12%
- **Grève longue (4 semaines, 2019) — CH 500 lits** : D = 3 mois, A = 0,8, IRPP = 0,42 — résilience forte ; perturbation courte bien absorbée
- **Travaux bloc (6 mois, 2018) — CH chirurgical** : D = 9 mois, A = 4,1, IRPP = 0,027 — résilience très faible ; impact prolongé au-delà de la période de travaux
- **Seuil d'IRPP normalisé d'alerte** : IRPP_norm < 0,5 (IRPP inférieur à la moitié du médiane national sur perturbation comparable) → investiguer les facteurs organisationnels

## Limites

- **Identification des perturbations** : en mode automatique CUSUM, les perturbations de faible amplitude (−15% d'activité sur 2 mois) peuvent ne pas être détectées, et des variations saisonnières extrêmes peuvent être détectées à tort comme perturbations — le seuil h doit être calibré selon le niveau de bruit habituel de l'établissement
- **Non-séparabilité de causes simultanées** : si une grève survient pendant une épidémie, les deux perturbations se superposent et l'IRPP calculé ne peut être attribué à aucune cause précisément — nécessite une interprétation contextuelle
- **Sensibilité à la définition du retour** : le seuil de retour (0,5·σ) et la durée de confirmation (3 mois consécutifs) sont des choix méthodologiques qui influencent D et donc IRPP — reporter systématiquement ces paramètres avec la valeur calculée
- **Non-comparabilité des IRPP entre types de perturbations** : un IRPP de 0,10 sur une perturbation de −50% n'est pas comparable à un IRPP de 0,10 sur une perturbation de −10% — toujours normaliser par l'IRPP_ref_national sur le même type de choc
- **Historique minimum requis** : 24 mois de baseline pré-perturbation sont nécessaires ; les établissements récents ou en forte restructuration permanente (baseline instable) ne peuvent pas être analysés de manière fiable

## Références

- [Holling C.S. — Resilience and stability of ecological systems, Annual Review of Ecology and Systematics 1973 : définition originale de la résilience écologique](https://doi.org/10.1146/annurev.es.04.110173.000245)
- [Pimm S.L. — The complexity and stability of ecosystems, Nature 1984 : opérationnalisation de la résilience comme temps de retour](https://doi.org/10.1038/307321a0)
- [Page E.S. — Continuous inspection schemes, Biometrika 1954 : fondements du test CUSUM](https://doi.org/10.2307/2333009)
- [Pettitt A.N. — A non-parametric approach to the change-point problem, Applied Statistics 1979 : test non-paramétrique de détection de rupture dans une série temporelle](https://doi.org/10.2307/2346729)
- [Holling C.S. — Engineering resilience versus ecological resilience, in Schulze P. (ed.) Engineering within Ecological Constraints, National Academy Press 1996 : distinction résilience ingénierie vs écologique applicable aux systèmes organisationnels]
