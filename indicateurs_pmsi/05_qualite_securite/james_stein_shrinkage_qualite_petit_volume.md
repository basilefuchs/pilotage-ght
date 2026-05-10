# Estimateur à Rétrécissement de James-Stein pour la Qualité des Établissements à Faible Volume

## Définition

L'**estimateur de James-Stein** (Stein 1956 ; James & Stein 1961) est un résultat fondamental de la statistique : pour estimer simultanément k ≥ 3 moyennes de populations différentes, l'estimateur empirique (la moyenne par groupe) est **inadmissible** — il est dominé en risque quadratique par un estimateur qui « rétrécit » (shrinks) chaque moyenne vers la moyenne globale. Ce paradoxe contre-intuitif est appelé **paradoxe de Stein**.

Appliqué au profilage hospitalier : un établissement à faible volume affiche un taux de complication empirique très bruité, ce qui produit des classements instables et des « faux mauvais ». L'estimateur James-Stein corrige ce biais en tirant les estimations individuelles vers la moyenne nationale (ou GHT), proportionnellement à la précision de chaque mesure.

Formule pour k établissements observés indépendamment, chacun avec un taux empirique y_i et une variance σ² supposée commune :

```
θ̂_JS,i = ȳ + (1 − (k − 3)·σ² / Σ_j (y_j − ȳ)²) · (y_i − ȳ)
```

avec ȳ = moyenne globale et le coefficient de rétrécissement borné dans [0, 1].

**Variante empirical Bayes** (recommandée en pratique) — modèle hiérarchique :

```
y_i | θ_i ~ N(θ_i, σ_i²)         (vraisemblance, σ_i² propre à chaque ES)
θ_i ~ N(μ, τ²)                   (prior commun)

θ̂_EB,i = w_i · y_i + (1 − w_i) · μ̂
w_i = τ̂² / (τ̂² + σ_i²)
```

Le poids w_i est élevé (peu de rétrécissement) pour les gros volumes (σ_i² faible) et faible (fort rétrécissement vers μ̂) pour les petits volumes.

**Positionnement vs indicateurs existants** : le funnel plot (Spiegelhalter 2005) signale les outliers en tenant compte du volume mais ne **corrige pas** les estimations elles-mêmes. James-Stein / empirical Bayes produisent des **classements stabilisés**, directement utilisables pour IFAQ, comparaison GHT et pilotage interne.

## Calcul

```
Étape 1 — Calcul des taux empiriques par établissement :
  Pour chaque ES i (i = 1..k) :
    n_i = nombre de séjours sur la période (12 ou 24 mois)
    e_i = nombre de complications (PSI-90 ou liste ATIH)
    y_i = e_i / n_i  (taux brut)
    Ajustement case-mix optionnel :
      y_i ← y_i × (taux_attendu_national / taux_attendu_ES)  (ratio standardisé)

Étape 2 — Variance d'échantillonnage par ES :
  σ_i² = y_i · (1 − y_i) / n_i   (binomiale)
  ou via Poisson : σ_i² = e_i / n_i²

Étape 3 — Estimation empirical Bayes (modèle hiérarchique) :
  μ̂ = Σ_i (y_i / σ_i²) / Σ_i (1 / σ_i²)   (moyenne pondérée par précision)
  τ̂² par méthode des moments (DerSimonian-Laird) :
    Q = Σ_i (y_i − μ̂)² / σ_i²
    τ̂² = max(0, (Q − (k − 1)) / (Σ_i 1/σ_i² − Σ_i 1/σ_i⁴ / Σ_i 1/σ_i²))
  Ou par maximum de vraisemblance restreint (REML).

Étape 4 — Calcul des estimateurs rétrécis :
  Pour chaque ES :
    w_i = τ̂² / (τ̂² + σ_i²)
    θ̂_EB,i = w_i · y_i + (1 − w_i) · μ̂
    IC95 a posteriori : θ̂_EB,i ± 1,96 · sqrt(w_i · σ_i²)

Étape 5 — Classement et catégorisation :
  → Classer les ES sur θ̂_EB,i au lieu de y_i
  → Catégorisation 5-classes (très bon / bon / moyen / faible / très faible)
    sur les déciles de θ̂_EB
  → Comparer aux classements bruts pour identifier les "faux mauvais" /
    "faux bons" volumes faibles
```

Implémentation R disponible via `metafor::rma()` ou modèles bayésiens hiérarchiques (`rstanarm::stan_glmer`, `brms`).

## Utilité

- **Réduction du bruit dans les classements IFAQ et comparaisons GHT** : évite que des ES de < 200 séjours/an ressortent en queue de classement par hasard d'échantillonnage, ce qui décrédibilise l'indicateur
- **Pilotage équitable des petits établissements** : le rétrécissement reflète l'incertitude réelle ; un ex-CHIH ou une polyclinique de territoire n'est pas pénalisé par sa taille
- **Détection robuste des vrais outliers** : un ES qui reste éloigné de la moyenne **après** rétrécissement (w_i élevé ou écart massif) est statistiquement signifiant — réduit les faux positifs ET les faux négatifs
- **Stabilité temporelle des classements** : les estimateurs EB varient moins d'une année sur l'autre que les taux bruts, ce qui rend les trajectoires interprétables
- **Cohérence avec la méthodologie IFAQ-HAS** : l'usage de modèles hiérarchiques empirical Bayes est explicitement recommandé pour les comparaisons hospitalières (Spiegelhalter, Goldstein, AHRQ)
- **Incertitude transparente** : l'IC95 a posteriori reflète à la fois la variance d'échantillonnage et la variance entre ES, ce qui n'est pas le cas du taux brut

## Sources de Données

- **PMSI MCO RSA** : DP, DAS pour les complications (PSI-90, liste ATIH), volumes par GHM/CMD pour l'ajustement case-mix, FINESS géographique pour l'identification ES
- **Référentiel taux nationaux par GHM** : PMSI national agrégé via ScanSanté ATIH ou base nationale ATIH (pour le calcul du taux attendu et l'ajustement case-mix)
- **Granularité recommandée** : 12 mois minimum, 24 mois recommandé pour stabilité de τ̂²
- **Volume du panel k** : minimum k = 5 ES (théorème de Stein s'applique pour k ≥ 3) ; recommandé k ≥ 20 pour estimation fiable de τ̂²
- **Liste de complications** : PSI-90 AHRQ adaptée codage français (cf. `psi90_patient_safety_indicators.md`)

## Exemple de Valeurs

- **GHT 12 ES, taux PSI-90 composite, 24 mois** :
  - taux bruts y_i variant de 1,8 % à 9,2 %
  - μ̂ = 4,1 % ; τ̂² ≈ 0,8 % (variabilité réelle entre ES)
  - **Petit ES (n = 1 800 séjours)** : y = 9,2 % ; σ_i = 0,67 % ; w = 0,64 ; θ̂_EB = 7,4 % (rétrécissement modéré)
  - **CHU (n = 35 000)** : y = 4,3 % ; σ_i = 0,11 % ; w = 0,98 ; θ̂_EB = 4,3 % (quasi-pas de rétrécissement)
  - **Très petit ES (n = 600)** : y = 1,8 % ; σ_i = 0,55 % ; w = 0,53 ; θ̂_EB = 3,0 % (rétrécissement fort, le 1,8 % brut est probablement un effet de chance)
- **Inversion de classement** : un ES affichant le « plus mauvais » taux brut peut tomber au 3ᵉ rang après EB ; un « bon » petit ES peut remonter au médian
- *Valeurs illustratives, ordre de grandeur expert — exécuter le calcul réel avant interprétation.*

## Limites

- **Hypothèse de prior commun** : tous les ES sont supposés tirés de la même population θ_i ~ N(μ, τ²) ; en cas de stratification forte (CHU vs CH local vs clinique privée), modèles hiérarchiques multi-niveaux à privilégier
- **Sensibilité à l'estimation de τ̂²** : avec k petit (< 10 ES), l'estimation de τ̂² est instable et l'estimateur EB peut sur-rétrécir → recourir à un prior weakly informative ou à un calcul bayésien complet
- **Critique « politique »** : un petit ES affichant un mauvais taux brut peut contester un rétrécissement vers la moyenne s'il est mal expliqué — accompagner d'une note méthodologique pédagogique
- **Ajustement case-mix préalable** : le rétrécissement opère sur les écarts à la moyenne ; si la moyenne reflète un mix de patients différent (ex. CHU avec patients lourds), l'ajustement case-mix par GHM est impératif avant EB
- **Pas de causalité** : EB stabilise les classements mais n'identifie pas les causes des écarts résiduels — outil de mesure, pas de diagnostic
- **Limites du périmètre** : ne s'applique qu'aux indicateurs binaires/comptés (taux, ratios) ; pour les délais et durées, méthodes différentes (modèles hiérarchiques continus)
- **Présentation visuelle** : nécessite des graphiques caterpillar plots (point + IC95 par ES, ordonnés) pour communication efficace

## Références

- [Stein C. — Inadmissibility of the usual estimator for the mean of a multivariate normal distribution, Berkeley Symp. 1956 : paradoxe de Stein](https://projecteuclid.org/euclid.bsmsp/1200501656)
- [James W., Stein C. — Estimation with quadratic loss, Berkeley Symp. 1961 : estimateur de James-Stein](https://projecteuclid.org/euclid.bsmsp/1200512173)
- [Efron B., Morris C. — Stein's estimation rule and its competitors — an empirical Bayes approach, JASA 1973](https://doi.org/10.1080/01621459.1973.10481358)
- [Spiegelhalter D.J. — Funnel plots for comparing institutional performance, Stat. Med. 2005 : référence en profilage hospitalier](https://doi.org/10.1002/sim.1970)
- [Goldstein H., Spiegelhalter D.J. — League tables and their limitations: statistical issues in comparisons of institutional performance, J. R. Stat. Soc. A 1996](https://doi.org/10.2307/2983325)
- [Normand S.L. et al. — Statistical methods for profiling providers of medical care: issues and applications, JASA 1997 : modèle hiérarchique pour comparaisons hospitalières](https://doi.org/10.1080/01621459.1997.10474035)
- [DerSimonian R., Laird N. — Meta-analysis in clinical trials, Control. Clin. Trials 1986 : estimateur des moments pour τ²](https://doi.org/10.1016/0197-2456(86)90046-2)
- [HAS — Méthodologie IFAQ et indicateurs IQSS](https://www.has-sante.fr/jcms/c_970481/fr/indicateurs-de-qualite-et-de-securite-des-soins-en-etablissements-de-sante)
