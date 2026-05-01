# Hazard Ratio de Cox — Réinterventions Chirurgicales Ajustées

## Définition

Le modèle de **régression de Cox à risques proportionnels** (Cox 1972) est la référence en analyse de survie pour estimer l'effet de covariables sur le **délai d'occurrence** d'un événement, sans imposer de forme paramétrique au risque de base. Appliqué à la qualité chirurgicale, il permet de comparer les établissements sur leur **taux de réintervention dans le temps** tout en neutralisant les différences de **casemix, d'âge, de comorbidités et de gravité initiale**.

L'indicateur produit un **hazard ratio (HR) par établissement** : un HR de 1.30 signifie que, à patientèle équivalente, l'établissement a 30% de risque additionnel de réintervention par rapport à la moyenne du GHT. C'est l'indicateur **équitable** par excellence pour le benchmarking qualité, là où un taux brut surestime systématiquement la mauvaise performance des CHU (qui reçoivent les cas complexes) et flatte les cliniques (qui sélectionnent les cas simples).

**Modèle de Cox :**

**h(t | X) = h₀(t) × exp(β₁X₁ + β₂X₂ + ... + βₚXₚ)**

où h(t | X) est le hazard (risque instantané de réintervention au temps t sachant qu'elle n'a pas encore eu lieu), h₀(t) le hazard de base, et X le vecteur de covariables (incluant un effet établissement à K-1 dummies).

**Hazard Ratio de l'établissement k :**

**HR_k = exp(β_k)**

Interprétation :
- HR_k = 1.0 : performance moyenne du GHT
- HR_k > 1.2 : sur-performance défavorable (signal qualité)
- HR_k < 0.8 : sous-risque significatif (best practice candidate)

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `taux_reinterventions_chirurgicales.md` — **taux brut**, non ajusté
- `taux_mortalite_ajustee.md` — ajustement SMR (ratio standardisé) sur la mortalité
- `psi90_patient_safety_indicators.md` — composite, sans dimension temporelle

Ce qui est nouveau ici :
- **Dimension temporelle explicite** : le Cox modélise *quand* survient la réintervention (J7, J30, J90), pas seulement *si*
- **Prise en compte de la censure** : les patients perdus de vue ou décédés sans réintervention sont correctement traités (SMR ne le permet pas)
- **Effet établissement comme covariable** : permet test d'hypothèse rigoureux (Wald, log-rank) sur la différence inter-établissements
- **Granularité par GHM-racine** : un HR par établissement × spécialité chirurgicale, plutôt qu'un score global

## Calcul

### 1. Constitution de la cohorte

```
Population : séjours MCO chirurgicaux index sur 36 mois glissants
  - Inclusion : ghm2 commençant par C ou Z (chirurgie ou acte technique)
                ET au moins un acte CCAM chirurgical (liste ATIH)
  - Exclusion : décès intra-séjour (modesortie = 9), CMD 14/15 (obstétrique néonatal)
                CMD 28 (séances), GHM erreur (CMD 90)

Identification de l'événement :
  - Événement : séjour ultérieur du même patient (chaînage ipp_c)
                avec acte CCAM chirurgical de reprise
                dans la fenêtre [J1 ; J90] après sortie du séjour index
  - Codes de reprise : selon liste ATIH "actes de reprise chirurgicale"
                       OU même racine CCAM (4 premiers caractères)
  - Censure droite à J90 si pas d'événement
  - Censure pour décès post-sortie (chaînage SNDS si dispo)
```

### 2. Variables et covariables

```
Variable de réponse :
  T = délai séjour index → réintervention (en jours)
  δ = 1 si réintervention observée, 0 si censuré

Covariables :
  - age           : âge du patient (continu)
  - sexe          : binaire (référence = femme)
  - charlson      : score de Charlson calculé depuis DA/DAS (Quan 2005)
  - ghm_racine    : 5 premiers caractères de ghm2 (effet fixe)
  - severite      : niveau 1-4 (4ᵉ caractère du GHM ≥ 2)
  - mode_entree   : binaire (urgence : modeentree ∈ {7,8} ou passage_urg=1)
  - finess_etab   : effet fixe établissement (K-1 dummies)
  - annee         : effet d'année (continu ou facteur)
```

### 3. Estimation du modèle

```r
library(survival)

cox_fit <- coxph(
  Surv(T, delta) ~ age + sexe + charlson + factor(ghm_racine) +
                   severite + mode_entree + factor(finess_etab) +
                   annee,
  data = cohorte,
  ties = "efron"
)

# Hazard ratios par établissement
HR_etab <- exp(coef(cox_fit))[grepl("finess_etab", names(coef(cox_fit)))]
IC95    <- exp(confint(cox_fit))

# Test global d'effet établissement
anova_etab <- anova(cox_fit, type = "II")
```

### 4. Vérification des hypothèses

```
Hypothèse de proportionnalité des risques (PH) :
  - Test de Schoenfeld résiduel (cox.zph) — p > 0.05 attendu
  - Si violée pour la covariable établissement → modèle stratifié :
      coxph(Surv(T, delta) ~ X + strata(finess_etab))
    → on perd l'estimation directe du HR mais on garde l'ajustement

Linéarité des covariables continues (age, charlson) :
  - Splines cubiques restreintes (rms::cph + rcs(age, 4))
  - Tester non-linéarité par anova(modele_lineaire, modele_spline)

Adéquation globale :
  - C-index de concordance (>= 0.65 pour un modèle informatif)
  - Test du log-rank pour comparaison des courbes Kaplan-Meier
```

### 5. Indicateurs dérivés

```
HR ajusté par établissement (intervalle de confiance 95%)
Funnel plot : HR vs nombre de séjours, avec bornes de contrôle (Spiegelhalter 2005)
Évolution temporelle : refit sur fenêtres glissantes 36 mois → trajectoire HR
Décomposition par GHM-racine : effet établissement × spécialité
```

## Utilité

- **Benchmarking équitable au sein du GHT** : comparer un CH périphérique (orthopédie élective, casemix simple) à un CHU (chirurgie complexe) sur le taux brut est trompeur ; le HR de Cox neutralise ces différences et révèle les vraies écarts de qualité
- **Identification des best practices** : un établissement avec HR < 0.7 et IC95 ne contenant pas 1.0 est un site de référence GHT — visites croisées, échange de protocoles, identification des facteurs organisationnels reproductibles
- **Détection des établissements en difficulté** : un HR > 1.3 persistant sur 3 fenêtres glissantes est un signal d'audit qualité ciblé — supérieur au taux brut qui peut être confondu par le casemix
- **Suivi d'impact d'un programme qualité** : déploiement d'une RMM dédiée → re-fit du Cox sur la période post-déploiement, comparaison du HR avant/après — preuve statistique de l'effet, intégrant l'évolution naturelle du casemix
- **Pilotage par spécialité** : décomposer le HR par GHM-racine (PTH, PTG, cholécystectomie, etc.) localise précisément la dérive (un seul GHM peut tirer le HR global vers le haut)
- **Argumentaire pour la concentration GHT** : si un établissement présente un HR significativement élevé sur un GHM rare, cela soutient la décision de transférer cette activité vers un site plus spécialisé — argumentaire opposable (issu d'un modèle reconnu) à la CME et à l'ARS
- **Communication aux instances** : le HR avec IC95 est un format compris des cliniciens (langage habituel des essais cliniques) et statistiquement défendable face à la CME, la HAS ou l'ARS

## Sources de Données

- **PMSI MCO RSA** : `ident`, `ipp_c` (chaînage patient), `ghm2`, `dp`, `dr`, `nbda` ; covariables `age`, `sexe`, `modeentree`, `passage_urg` ; dates `date_entree`, `date_sortie` pour calcul du délai
- **PMSI MCO acte** : variable `acte` (codes CCAM 7 caractères) — identification des actes chirurgicaux index et des actes de reprise via liste ATIH
- **PMSI MCO diag** : codes CIM-10 (variable `diag`) pour calcul du score de Charlson selon Quan 2005 (mapping CIM-10 → poids comorbidité)
- **Référentiel actes de reprise ATIH** : disponible dans la documentation ScanSanté — liste exhaustive des couples (acte index, acte de reprise) reconnus comme réinterventions
- **PMSI MCO chaîné (id_hospit_ipp)** : `ipp_c` pour identifier les séjours ultérieurs du même patient
- **(Optionnel) SNDS** : pour la censure correcte sur décès post-sortie hors hospitalisation MCO
- **Outils** : R (`survival::coxph`, `rms::cph`, `survminer`), Python (`lifelines.CoxPHFitter`)

## Exemple de Valeurs

- **CHU régional — orthopédie (PTH GHM 08C481)** :
  N = 1 200 séjours/an, HR = 1.05 [IC95 0.92 — 1.20]
  Conclusion : performance dans la moyenne GHT, malgré un casemix plus complexe

- **CH périphérique — chirurgie viscérale (cholécystectomie GHM 07C141)** :
  N = 280 séjours/an, HR = 1.42 [IC95 1.15 — 1.75]
  Conclusion : sur-risque significatif, audit qualité justifié — possiblement
  lié à la courbe d'apprentissage récente d'un opérateur

- **Clinique privée GHT — PTG GHM 08C501** :
  N = 600 séjours/an, HR = 0.71 [IC95 0.55 — 0.92]
  Conclusion : sous-risque significatif (sélection casemix résiduelle ?
  vérifier sur covariables non observables ; ou vraie performance)

- **CHU — chirurgie complexe pancréatique (GHM 07C111)** :
  N = 45 séjours/an, HR = 1.20 [IC95 0.65 — 2.20]
  Conclusion : non significatif (volume insuffisant) — fusionner sur 5 ans
  pour atteindre puissance suffisante

- **Distribution attendue dans un GHT type (8 établissements)** :
  HR médian ≈ 1.0 (par construction), étendue 0.7 — 1.4
  2 établissements typiquement en dehors de l'IC95 du benchmark
  C-index global du modèle : 0.65 — 0.72

- **Effet d'un programme qualité (RAAC orthopédique)** :
  Avant : HR = 1.25 [1.05 — 1.48]
  Après 18 mois : HR = 0.92 [0.78 — 1.08]
  → Effet statistiquement significatif (interaction période × établissement p < 0.01)

## Limites

- **Hypothèse de proportionnalité des risques** : le Cox suppose que l'effet de chaque covariable est constant dans le temps ; or l'effet établissement peut varier (urgence post-op à J7 vs reprise tardive à J60 ne dépendent pas des mêmes facteurs) ; vérifier systématiquement avec `cox.zph` et stratifier si nécessaire
- **Confondants non observés** : le PMSI ne capture pas certaines variables critiques (statut nutritionnel, observance, complexité technique réelle de l'intervention) ; le HR ajusté reste donc imparfait — un établissement qui sélectionne ses cas par des critères non-PMSI conservera un avantage indu
- **Volume minimal requis** : pour un IC95 informatif sur le HR d'un établissement, il faut typiquement ≥ 200 séjours/an et ≥ 30 événements ; en deçà, l'IC95 est trop large pour conclure (cas typique des spécialités rares en CH périphérique)
- **Codage hétérogène des comorbidités** : le score de Charlson dépend de la qualité du codage des DAS, qui varie entre établissements (CHU surcodent typiquement) ; un établissement qui sous-code ses comorbidités apparaîtra artificiellement performant — vérifier la stabilité du nombre moyen de DAS par séjour entre établissements
- **Définition de la réintervention** : la frontière entre "reprise programmée planifiée" et "reprise non programmée pour complication" n'est pas toujours nette dans le PMSI (mode_entree ne suffit pas) ; risque de mélanger les deux populations et de diluer le signal qualité
- **Effet d'apprentissage et de dérive** : un modèle estimé sur 2018-2020 peut être inadapté à 2024 (évolution des techniques, nouvelles classes de GHM) ; ré-estimer annuellement sur fenêtre glissante 36 mois
- **Comparabilité limitée hors GHT** : le modèle est calibré sur la patientèle du GHT ; comparer un établissement à un benchmark national nécessite un recalage avec un modèle entraîné sur la BDD ATIH complète

## Références

- [Cox D.R. — Regression models and life-tables, J R Stat Soc B 1972](https://doi.org/10.1111/j.2517-6161.1972.tb00899.x) — article fondateur
- [Quan H. et al. — Coding algorithms for defining comorbidities in ICD-9-CM and ICD-10 administrative data, Med Care 2005](https://doi.org/10.1097/01.mlr.0000182534.19832.83) — calcul Charlson sur données administratives
- [Iezzoni L.I. — Risk Adjustment for Measuring Health Care Outcomes, 4th ed., Health Administration Press 2013] — référence pour l'ajustement risque en qualité hospitalière
- [Spiegelhalter D.J. — Funnel plots for comparing institutional performance, Stat Med 2005](https://doi.org/10.1002/sim.1970)
- [Therneau T.M., Grambsch P.M. — Modeling Survival Data: Extending the Cox Model, Springer 2000] — référence méthodologique du package `survival`
- [HAS — Méthodologie d'ajustement des indicateurs de qualité, 2017](https://www.has-sante.fr/)
- [Krumholz H.M. et al. — Evaluation of risk-adjustment models for surgical mortality, JAMA 2006](https://doi.org/10.1001/jama.296.16.1942)
