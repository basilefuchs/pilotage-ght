# Distance de Mahalanobis du Profil Qualité Multivarié

## Définition

La **distance de Mahalanobis** (Mahalanobis 1936) est une distance statistique multivariée qui mesure l'écart d'un point à une distribution de référence en **tenant compte des corrélations** entre les variables. Là où la distance euclidienne traite chaque dimension comme indépendante (un écart de 1 sur la mortalité compte autant qu'un écart de 1 sur le taux d'ISO), la distance de Mahalanobis :
- **Standardise** chaque dimension par son écart-type empirique (un écart de 1% sur un taux à variance 0.5% pèse plus qu'un écart de 1% sur un taux à variance 5%)
- **Décorrèle** les dimensions (si mortalité et complications sont corrélés à 0.7, un établissement déviant simultanément sur les deux ne sera pas "doublement pénalisé")

Appliquée à la qualité hospitalière, elle produit un **score d'atypicité multivarié** par établissement : un D² élevé signifie que l'établissement présente un profil qualité globalement déviant de la norme du GHT (ou nationale), prenant en compte simultanément mortalité, complications, réadmissions, EIG, infections, etc.

**Formule :**

**D²(x) = (x − μ)ᵀ Σ⁻¹ (x − μ)**

où :
- x ∈ ℝᵖ est le vecteur des p indicateurs qualité de l'établissement
- μ ∈ ℝᵖ est le vecteur moyen de la distribution de référence (GHT ou national)
- Σ ∈ ℝᵖˣᵖ est la matrice de covariance de la distribution de référence

Sous l'hypothèse de normalité multivariée, **D² ~ χ²(p)** : on peut donc convertir D² en un **p-value d'atypicité** ou un **percentile** (si D² > χ²₀.₉₅(p), l'établissement est atypique au seuil 5%).

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `psi90_patient_safety_indicators.md` — composite **additif** sur 11 PSI, sans pondération par variance ni gestion des corrélations
- `taux_mortalite_ajustee.md`, `taux_complications_ghm.md`, `taux_failure_to_rescue.md` — indicateurs **univariés**
- `rapport_signal_bruit_indicateurs_qualite.md` — qualité du signal univarié
- `ratio_sharpe_performance_qualite.md` — composite ratio risque/rendement

Ce qui est nouveau :
- **Détection d'atypicité globale** : un établissement peut être moyen sur chaque indicateur isolé mais avoir un *profil* atypique (combinaison rare des écarts) — seul Mahalanobis le capture
- **Prise en compte des corrélations** : évite la double comptabilité quand mortalité, FTR et complications graves sont fortement corrélés
- **Standardisation par variance empirique** : neutralise les écarts d'échelle entre indicateurs (taux à 0.5% vs taux à 15%)
- **Test statistique formel** : χ² avec p-value, contrairement aux composites HAS (additifs sans inférence)

## Calcul

### 1. Constitution du vecteur d'indicateurs

```
Sélection des p indicateurs (p typiquement 4-8) :
  - Mortalité 30j ajustée (SMR)
  - Taux de complications post-op (PSI 03 ATIH)
  - Taux de réintervention J<30 (acte CCAM de reprise)
  - Taux d'IAS post-op (CIM-10 T81.4*)
  - Taux de réadmission J<30 toutes causes
  - Taux de Failure-to-Rescue (FTR)
  - Taux d'escarres acquises stade 3-4
  - Taux d'erreurs médicamenteuses (CIM-10 Y40-Y84)

Critères de sélection :
  - Calculables sur PMSI uniquement
  - Volume suffisant pour stabilité (≥ 30 séjours/an et ≥ 5 événements)
  - Pas de redondance parfaite (corrélation < 0.95)
```

### 2. Ajustement préalable des indicateurs

```
Chaque indicateur xᵢ doit être ajusté sur le casemix avant entrée dans Mahalanobis,
sinon les écarts mesurés refléteront en partie des différences de patientèle :

Méthode : SMR-like
  xᵢ_obs = taux observé
  xᵢ_att = taux attendu (modèle GLM logistique sur âge/sexe/Charlson/GHM/
                        sévérité/mode_entree, entraîné sur tout le GHT)
  xᵢ_aj  = xᵢ_obs / xᵢ_att   (ratio standardisé)

Le vecteur x = (x₁_aj, x₂_aj, ..., xₚ_aj) est ce qui entre dans Mahalanobis.
```

### 3. Estimation de μ et Σ

```r
# Population de référence : tous les établissements du GHT
# (ou nationale via ScanSanté si comparaison externe)

X <- matrix(...)   # n établissements × p indicateurs ajustés
mu_hat   <- colMeans(X)
Sigma_hat <- cov(X)

# Estimation robuste alternative (recommandée pour petits n) :
library(MASS)
robust <- cov.mcd(X, quantile.used = 0.75)
mu_hat   <- robust$center
Sigma_hat <- robust$cov

# Vérification : conditionnement de Sigma
kappa(Sigma_hat)   # < 100 : OK ; > 1000 : régularisation nécessaire
```

### 4. Régularisation si nécessaire

```
Cas problématiques (n < 3p) :
  - Sigma proche de la singularité → inversion instable
  - Solution 1 : sélection des p indicateurs les moins corrélés
  - Solution 2 : régularisation Ledoit-Wolf
      Σ_reg = (1 − λ) × Σ_hat + λ × diag(Σ_hat)
      λ optimal estimé par validation croisée (corpcor::cov.shrink)
  - Solution 3 : ACP préalable et calcul de D² en espace réduit (q < p)
```

### 5. Calcul de la distance et du percentile

```r
inv_Sigma <- solve(Sigma_hat)

D2 <- function(x) {
  diff <- x - mu_hat
  as.numeric(t(diff) %*% inv_Sigma %*% diff)
}

D2_etabs <- apply(X, 1, D2)

# Conversion en p-value et percentile χ²
p <- ncol(X)
pval    <- 1 - pchisq(D2_etabs, df = p)
percent <- pchisq(D2_etabs, df = p) * 100   # 0-100, plus haut = plus atypique
```

### 6. Décomposition du score

```
Pour identifier QUELLES dimensions tirent le D² vers le haut :

Contribution_i = (xᵢ - μᵢ)² / Σᵢᵢ_diag    (approximation, ignore corrélations)
ou exactement :
Contribution_i = ((xᵢ - μᵢ) × Σ⁻¹[i, :] %*% (x - μ))   (vrai gradient de D²)

→ Permet de communiquer aux établissements quels indicateurs spécifiques
  expliquent leur atypicité.
```

## Utilité

- **Détection d'établissements atypiques globalement** : un établissement avec D² > seuil χ²₀.₉₉ est statistiquement atypique sur l'ensemble du profil qualité — déclencheur d'analyse approfondie même si aucun indicateur isolé n'apparaît anormal
- **Pilotage GHT par cartographie** : représenter les établissements dans le plan des 2 premières composantes principales et colorer selon D² produit une cartographie qualité immédiatement lisible pour le directeur GHT
- **Détection de combinaisons inhabituelles** : un établissement peut avoir mortalité moyenne, complications moyennes, mais combinaison atypique des deux (ex: faible mortalité + nombreuses complications, suggérant un pattern de "rescue" intensif) — invisibles aux indicateurs univariés
- **Suivi temporel du profil global** : refit annuel, trajectoire de D² dans le temps — un établissement qui voit son D² augmenter glisse hors du peloton GHT, signal précoce de dégradation systémique
- **Identification d'outliers à re-coder** : un D² très élevé peut révéler une anomalie de codage plutôt qu'un vrai problème qualité (établissement codant systématiquement différemment) — vérification préalable avant interprétation qualité
- **Argumentation pour partage de bonnes pratiques** : un établissement avec D² faible (proche du centre du nuage GHT) est un "ancrage" qualité — ses processus sont à analyser comme référence
- **Décomposition explicative** : la contribution de chaque indicateur au D² total permet de communiquer précisément aux établissements quels axes spécifiques expliquent leur position

## Sources de Données

- **PMSI MCO RSA** : `ident`, `finess`, `finessgeodp`, `ghm2`, `dp`, `dr`, `nbda`, `age`, `sexe`, `modeentree`, `passage_urg`, `modesortie`, `duree`, `date_entree`, `date_sortie` ; pour calculer chaque indicateur composant le vecteur x
- **PMSI MCO diag** : `diag` (codes CIM-10) pour identifier les complications (PSI), comorbidités (Charlson) et causes de réadmission
- **PMSI MCO acte** : `acte` (CCAM) pour identifier les actes index et de reprise
- **PMSI MCO chaîné (id_hospit_ipp)** : `ipp_c` pour les réadmissions et réinterventions inter-séjours
- **Référentiel PSI ATIH 2024** : codes CIM-10 et CCAM pour PSI 03, 04, 09, 11, 12, 13, 14, 15
- **Référentiel Charlson Quan 2005** : mapping CIM-10 → poids comorbidité pour ajustement risque
- **(Optionnel) Données ScanSanté ATIH** : valeurs nationales par GHM pour calculer le SMR-like avec une référence externe au GHT
- **Outils** : R (`stats::mahalanobis`, `MASS::cov.mcd`, `corpcor::cov.shrink`), Python (`scipy.spatial.distance.mahalanobis`, `sklearn.covariance.LedoitWolf`)

## Exemple de Valeurs

- **Configuration GHT type (8 établissements, p = 6 indicateurs)** :
  Seuil critique χ²₀.₉₅(6) = 12.59 ; χ²₀.₉₉(6) = 16.81

- **CHU régional** :
  D² = 4.2 → percentile 60% → profil dans la moyenne malgré casemix complexe
  (l'ajustement préalable a bien neutralisé l'effet casemix)

- **CH périphérique A** :
  D² = 18.5 → percentile 99.5% → atypique
  Décomposition : 65% de D² vient de "réintervention" et "complications"
  → ces deux indicateurs corrélés sont conjointement élevés
  → audit chirurgical orthopédie immédiat

- **Clinique privée GHT** :
  D² = 2.1 → percentile 35% → profil très centré, qualité homogène
  → site de référence potentiel

- **CH B en transition** :
  D²(2022) = 5.0, D²(2023) = 8.5, D²(2024) = 14.2
  → trajectoire d'éloignement : alerte déclenchée à l'année 3
  → enclencher revue qualité bien avant qu'aucun indicateur isolé ne franchisse son seuil

- **Plage typique** :
  - 50% des établissements : D² < χ²₀.₅ = 5.35 (p = 6)
  - 90% : D² < 10.6
  - 5% atypiques : D² > 12.59
  - 1% très atypiques : D² > 16.81

- **Effet de l'ajout d'un nouvel indicateur (p : 6 → 7)** :
  Le seuil χ² monte (de 12.59 à 14.07), pas de "double pénalisation" automatique
  → Mahalanobis bien dimensionné est robuste à l'ajout de variables

## Limites

- **Hypothèse de normalité multivariée** : la conversion D² → p-value via χ²(p) suppose que x suit une loi normale multivariée ; les indicateurs qualité (taux bornés à [0,1]) violent souvent cette hypothèse — utiliser une transformation logit avant (logit(p) = log(p/(1−p))) pour gaussianiser, ou abandonner l'inférence χ² au profit d'un percentile empirique par bootstrap
- **Stabilité de Σ** : avec n < 3p établissements (cas fréquent en GHT à 6-8 établissements), la matrice de covariance estimée est instable et son inverse peut amplifier le bruit ; régularisation Ledoit-Wolf ou estimation robuste (MCD) **obligatoires**
- **Sensibilité aux outliers** : Σ classique est très influencée par les observations extrêmes ; un établissement très atypique peut "tirer" la matrice et masquer son atypicité — utiliser systématiquement `cov.mcd` ou une autre estimation robuste
- **Choix arbitraire des p indicateurs** : ajouter ou retirer un indicateur change toute la structure et les D² ne sont plus comparables entre versions ; documenter rigoureusement la liste, ne pas la modifier en cours d'année
- **Ajustement casemix imparfait** : si l'ajustement SMR-like est incomplet (variables non capturées dans le PMSI : statut nutritionnel, observance), le D² reflète en partie un effet casemix résiduel et non une vraie atypicité qualité
- **Effet de la taille du GHT** : avec un GHT de 4 établissements, on n'a pas la puissance pour détecter une atypicité ; pour des GHT < 6 étab, calculer Mahalanobis sur un référentiel externe (national ATIH) plutôt que sur les pairs locaux
- **Pas un indicateur HAS officiel** : à utiliser pour le pilotage interne, **pas** pour communication publique ou comparaison Scope Santé (qui exigent des indicateurs validés et standardisés nationalement)
- **Interprétation délicate pour les cliniciens** : "votre D² est de 14.2" est moins parlant qu'un taux de mortalité ; toujours accompagner d'une décomposition par contribution et d'un percentile interprétable

## Références

- [Mahalanobis P.C. — On the generalised distance in statistics, Proc Natl Inst Sci India 1936](https://insa.nic.in/writereaddata/UpLoadedFiles/PINSA/Vol02_1936_1_Art05.pdf) — article fondateur
- [De Maesschalck R., Jouan-Rimbaud D., Massart D.L. — The Mahalanobis distance, Chemometrics and Intelligent Laboratory Systems 2000](https://doi.org/10.1016/S0169-7439(99)00047-7) — revue méthodologique
- [Rousseeuw P.J., Van Driessen K. — A fast algorithm for the minimum covariance determinant estimator, Technometrics 1999](https://doi.org/10.1080/00401706.1999.10485670) — estimation robuste de Σ
- [Ledoit O., Wolf M. — A well-conditioned estimator for large-dimensional covariance matrices, J Multivariate Analysis 2004](https://doi.org/10.1016/S0047-259X(03)00096-4) — régularisation pour petits n
- [Iezzoni L.I. — Risk Adjustment for Measuring Health Care Outcomes, 4th ed., Health Administration Press 2013] — ajustement multivarié en qualité hospitalière
- [Spiegelhalter D.J. — Funnel plots for comparing institutional performance, Stat Med 2005](https://doi.org/10.1002/sim.1970)
- [HAS — Méthodologie d'élaboration des indicateurs composites en qualité, 2017](https://www.has-sante.fr/)
- [ATIH — ScanSanté, indicateurs PSI](https://scansante.fr/)
