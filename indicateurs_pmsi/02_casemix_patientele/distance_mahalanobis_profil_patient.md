# Distance de Mahalanobis du Profil Patient

## Définition

La distance de Mahalanobis (P.C. Mahalanobis, 1936) est une mesure de distance statistique multivariée qui quantifie l'éloignement d'un point par rapport au centre d'une distribution, en tenant compte des **corrélations entre variables** et en **normalisant par les variances**. Contrairement à la distance euclidienne classique, elle n'est pas affectée par les différences d'échelle entre variables (une variable en jours et une en euros ne sont pas comparables directement) ni par leurs corrélations (âge et comorbidités sont fortement corrélés — ne pas en tenir compte surestime la distance).

**D²_M(x) = (x − μ)ᵀ × Σ⁻¹ × (x − μ)**

où x est le vecteur de caractéristiques du patient, μ le vecteur des moyennes de la population de référence et Σ la matrice de covariance de cette population. D_M(x) = √(D²_M) est la distance de Mahalanobis du patient.

Appliquée au profil patient PMSI, la **Distance de Mahalanobis du Profil Patient** (DMPP) mesure dans quelle mesure un patient — ou un séjour — est **atypique par rapport à sa cohorte de référence**, en tenant compte simultanément de toutes ses caractéristiques cliniques et de leur structure de corrélation. Un patient avec D_M élevé n'est pas nécessairement "anormal" au sens clinique : il est statistiquement distant du profil habituel de sa cohorte, ce qui justifie une attention particulière — révision du codage PMSI, vérification de la prise en charge, analyse d'un possible outlier tarifaire ou d'un profil complexe sous-capté par les GHM.

La DMPP généralise et améliore tous les indicateurs d'outlier univariés (DMS hors norme, coût atypique, âge atypique) : elle détecte des patients qui ne sont outliers sur aucune dimension isolément mais dont la **combinaison** de caractéristiques est globalement rare dans la cohorte.

## Calcul

Définition du vecteur de caractéristiques patient :

```
x = [x₁, x₂, …, xₖ] — vecteur à k dimensions pour un séjour ou un patient

Variables pertinentes selon l'objectif :

  Profil clinique :
    x₁ = âge (en années)
    x₂ = indice de Charlson (comorbidités, calculé sur les DA/DP)
    x₃ = nombre de diagnostics associés (DA) du séjour
    x₄ = nombre d'actes CCAM du séjour
    x₅ = DMS observée (en jours)

  Profil économique :
    x₆ = valorisation GHS du séjour (en euros)
    x₇ = ratio valorisation réelle / valorisation attendue du GHM
    x₈ = nombre de suppléments facturés (REA, SI, SC)

  Profil de parcours (fenêtre 12 mois) :
    x₉  = nombre de séjours MCO dans l'année
    x₁₀ = nombre de structures distinctes fréquentées (IF)
    x₁₁ = SSP (score de synchronisation du parcours, si calculé)

  → Choisir le sous-ensemble de variables selon l'objectif :
    Détection d'outliers de codage PMSI : variables cliniques + économiques
    Détection de patients complexes non capturés : variables de parcours
    Benchmarking inter-GHM : variables cliniques seules
```

Calcul de la DMPP :

```
Population de référence R :
  → Tous les séjours du même GHM sur la même période (intra-établissement
    ou national via les données ATIH/benchmarking)
  → Ou tous les patients du même profil ALD (pour une analyse de parcours)

Étape 1 — Calcul du vecteur de moyennes μ et de la matrice Σ :
  μ = (1/N) × Σᵢ xᵢ     (moyennes des k variables sur N séjours de référence)
  Σ = (1/N) × Σᵢ (xᵢ−μ)(xᵢ−μ)ᵀ   (matrice de covariance k×k)

Étape 2 — Calcul de la distance pour un séjour cible x :
  D²_M(x) = (x − μ)ᵀ × Σ⁻¹ × (x − μ)
  D_M(x)  = √(D²_M(x))

  → Implémentation : Python (scipy.spatial.distance.mahalanobis),
    R (mahalanobis(x, center=μ, cov=Σ)), SAS (PROC IML)

Étape 3 — Test statistique (seuil d'alerte) :
  Sous hypothèse de normalité multivariée, D²_M suit une loi χ²(k)
  Seuil d'alerte : D²_M > χ²(k, 0.975)   (p < 2.5%, bilatéral)
  Seuil sévère  : D²_M > χ²(k, 0.995)   (p < 0.5%)

  Exemple pour k = 5 variables :
    Seuil alerte : D²_M > 12.8 (χ²₅ au quantile 97.5%)
    Seuil sévère : D²_M > 16.7 (χ²₅ au quantile 99.5%)
```

Score d'atypicité normalisé :

```
Pour faciliter l'interprétation, convertir D_M en percentile dans la cohorte :
  Rang_M(x) = percentile de D_M(x) dans la distribution des D_M de la cohorte
  → Rang_M > 95 : patient dans les 5% les plus atypiques de sa cohorte
  → Rang_M > 99 : patient dans le 1% le plus atypique — investigation systématique

Décomposition de la distance (contributions par variable) :
  Contribution_i = [(x − μ)ᵀ × Σ⁻¹]_i × (xᵢ − μᵢ)
  → Identifier quelle(s) variable(s) contribue(nt) le plus à la distance élevée
  → Guide l'investigation : "ce patient est atypique principalement parce que
    sa DMS est 3× la moyenne ET qu'il a un Charlson inhabituel pour son GHM"
```

## Utilité

- **Détection d'outliers PMSI multi-dimensionnels pour le contrôle qualité du codage** : un séjour avec D_M élevé sur les dimensions cliniques + économiques est un candidat prioritaire pour la revue de codage par le DIM — il peut indiquer un GHM mal attribué (patient plus complexe que le GHM moyen), un acte majeur non codé, ou une erreur de diagnostic principal
- **Identification des patients complexes non capturés par les outils habituels** : des patients qui ne sont pas outliers sur une seule dimension (DMS dans la norme, Charlson dans la norme) mais atypiques sur leur combinaison de caractéristiques — profil rare de multimorbidités avec un parcours inhabituel — sont détectés par la DMPP et peuvent nécessiter une coordination renforcée invisible aux indicateurs univariés
- **Contrôle des facturations atypiques** : appliquée sur les dimensions économiques (valorisation GHS, suppléments, nombre d'actes), la DMPP identifie les séjours dont le profil de facturation est statistiquement incompatible avec leur profil clinique — outil de contrôle interne et de préparation aux visites de contrôle de l'Assurance Maladie
- **Benchmarking de la casemix par GHM** : comparer la distribution des DMPP entre établissements pour un même GHM — un établissement avec une proportion élevée de séjours à D_M > P95 traite des cas structurellement plus complexes que ses pairs (argument pour une reconnaissance tarifaire) ou code de façon systématiquement différente (argument pour une harmonisation)
- **Détection précoce des séjours à risque de complication** : en entrée de séjour (dès les premières 48h), calculer la DMPP sur les variables disponibles (âge, Charlson, diagnostic principal) par rapport aux séjours du même GHM — les patients très atypiques dès l'admission ont un risque de complication ou de prolongation de séjour plus élevé, justifiant une surveillance renforcée
- **Analyse rétrospective des réadmissions** : calculer la DMPP des patients réadmis à 30 jours vs non réadmis — si les réadmis avaient des D_M élevés dès le séjour index, cela confirme que l'atypicité du profil d'entrée est un facteur prédictif de réadmission non capturé par les modèles univariés

## Sources de Données

- **PMSI MCO RSA** : DMS, âge, nombre de DA, actes CCAM, GHM, valorisation GHS, suppléments — toutes les variables du vecteur x disponibles dans le RSA ; calcul de la matrice Σ possible sur la base nationale ATIH (données agrégées par GHM) ou sur la base locale (séjours historiques de l'établissement)
- **Indice de Charlson PMSI** : calculé depuis les DP/DA/DR des RSA sur les 24 mois précédents le séjour index, via le chaînage NIR — variable de comorbidité multidimensionnelle synthétisée en scalaire pour l'intégration dans x
- **PMSI SSR, HAD, DCIR** : pour les variables de parcours (IF, SSP, nombre de structures) sur la fenêtre 12 mois — nécessite le chaînage SNDS par NIR crypté
- **Données ATIH** (statistiques nationales par GHM) : pour construire μ et Σ de référence nationale — permettent un benchmarking national en comparant le profil de l'établissement à la distribution nationale du même GHM

## Exemple de Valeurs

- **Séjour chirurgie digestive (GHM 06C05Z — résection intestin grêle)** :
  μ = [âge=65, Charlson=2.1, nDA=3.2, DMS=8.5, valorisation=4200€]
  Patient atypique : x = [72, 5, 7, 21, 4200€]
  D_M = 4.8 → D²_M = 23 > χ²₅(97.5%) = 12.8 → **outlier significatif**
  Contribution principale : DMS (21j vs moyenne 8.5j) + Charlson (5 vs 2.1)
  → Investigation : prolongation liée aux comorbidités ou complication non codée ?

- **Distribution des D_M dans une cohorte MCO** :
  P50 ≈ 1.5-2.0 ; P90 ≈ 3.5-4.5 ; P95 ≈ 5.0-6.5 ; P99 ≈ 8.0-12.0
  Proportion de séjours au-dessus du seuil χ²(97.5%) : 5-8% selon le GHM
  (légèrement supérieur à 2.5% théorique — distributions hospitalières non gaussiennes)

- **Gain de détection vs indicateurs univariés** :
  Sur une cohorte de 10 000 séjours, la DMPP identifie 15-20% de cas atypiques
  supplémentaires non détectés par les seuils univariés (DMS > 2×moyenne OU
  coût > 3×moyenne) — ces cas additionnels ont des profils complexes mais
  "équilibrés" sur chaque dimension individuelle

## Limites

- La DMPP suppose une **distribution approximativement gaussienne multivariée** des caractéristiques patients — hypothèse souvent violée en PMSI (distributions très asymétriques de la DMS, du coût, des comorbidités) ; une transformation préalable des variables (log-transformation pour DMS et coût) améliore la robustesse
- La **matrice de covariance Σ doit être inversible** — problème si deux variables sont parfaitement corrélées (colinéarité) ou si le nombre de variables k approche le nombre d'observations N ; utiliser une régularisation (Σ_reg = Σ + λI) ou une réduction de dimension préalable (PCA) pour les vecteurs de grande dimension
- La DMPP est calculée par rapport à une **population de référence choisie** — un patient sera outlier par rapport à la cohorte nationale du GHM mais pas par rapport à la cohorte locale (si l'établissement traite systématiquement des cas plus complexes) ; la définition de la référence est un choix analytique structurant qui doit être documenté
- L'interprétation de la distance requiert une **décomposition par variable** pour être cliniquement actionnable — une DMPP élevée sans décomposition ne permet pas de savoir pourquoi le patient est atypique ; l'étape de décomposition des contributions est indispensable pour guider l'investigation

## Références

- [Mahalanobis P.C. — On the generalised distance in statistics, Proceedings of the National Institute of Sciences of India 1936 : article fondateur]
- [McLachlan G.J. — Mahalanobis distance, Resonance 1999 : revue pédagogique de la distance et de ses applications]
- [Barnett V., Lewis T. — Outliers in Statistical Data, Wiley 1994 : détection d'outliers multivariés par distance de Mahalanobis]
- [Goldstein M., Uchida S. — A comparative evaluation of unsupervised anomaly detection algorithms for multivariate data, PLoS One 2016](https://doi.org/10.1371/journal.pone.0152173)
- [ATIH — Analyse des séjours outliers en MCO : méthodologie de détection des séjours atypiques (rapport annuel)](https://www.atih.sante.fr/)
- [Quan H. et al. — Coding algorithms for defining comorbidities in ICD-9-CM and ICD-10 administrative data, Med Care 2005](https://doi.org/10.1097/01.mlr.0000182534.19832.83) — indice de Charlson adapté aux données administratives
