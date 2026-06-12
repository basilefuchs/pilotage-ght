# EWMA de la Mortalité Chirurgicale Mensuelle

## Définition

La carte de contrôle **EWMA** (Exponentially Weighted Moving Average, Roberts 1959) est un outil de maîtrise statistique des procédés qui pondère exponentiellement les observations passées : chaque mesure influence indéfiniment la statistique courante, mais avec un poids décroissant géométriquement. Là où le CUSUM accumule les écarts au-dessus d'une référence et excelle à détecter les dérives **soutenues**, l'EWMA fournit une estimation **lissée du niveau courant** du processus, optimale pour détecter les **dérives de faible amplitude** (0,5σ–1σ) et naturellement adaptée aux indicateurs binaires comme la mortalité hospitalière (Grigg & Spiegelhalter 2007).

Transposée à la qualité chirurgicale, l'EWMA mensuelle de la mortalité ajustée GHM permet une surveillance prospective où la statistique zₜ peut être tracée directement sur un graphique de contrôle avec ses bornes ±L·σ_zₜ, lisible par les cliniciens (interprétation directe : « niveau courant estimé du taux »), là où le CUSUM impose la lecture d'une accumulation moins intuitive.

**Statistique EWMA risk-adjusted (Grigg-Spiegelhalter 2007) :**

**z₀ = 0**
**zₜ = λ · (Oₜ − Eₜ) / √Vₜ + (1 − λ) · zₜ₋₁**

où :
- Oₜ = nombre observé de décès dans le mois t
- Eₜ = Σᵢ pᵢ = nombre attendu, somme des probabilités individuelles issues d'un modèle logistique de risque
- Vₜ = Σᵢ pᵢ(1 − pᵢ) = variance binomiale-Poisson attendue
- λ ∈ ]0, 1] : facteur de lissage — λ petit (0,1–0,2) → mémoire longue, sensible aux petites dérives ; λ grand (0,4–0,6) → réactif aux changements brusques

**Bornes de contrôle asymptotiques :** ±L · √(λ / (2 − λ))
typiquement L = 2,7 pour ARL₀ ≈ 250 (≈20 ans entre faux positifs en mensuel).

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `cusum_surveillance_complications.md` — CUSUM, optimal pour dérives **persistantes ≥1σ**
- `taux_mortalite_ajustee.md` — taux annuel agrégé (retard ≥12 mois)
- `shmi_summary_hospital_mortality_indicator.md` — indicateur trimestriel/annuel
- `rapport_signal_bruit_indicateurs_qualite.md` — diagnostic statique
- `value_at_risk_evenements_indesirables.md` — quantile extrême

L'EWMA comble un trou méthodologique : **détection mensuelle des dérives de faible amplitude** (0,5σ), avec une statistique directement interprétable comme estimation lissée du taux courant. Le couple CUSUM + EWMA est la pratique recommandée en SPC santé (Woodall 2006) — chacun détectant des profils de dérive différents.

## Calcul

### 1. Définition de l'événement et du périmètre

```
Événement : décès intra-séjour (modesortie = 9 dans le RSA)
Périmètre : séjours chirurgicaux programmés
            (hors entrée par les urgences — modeentree 8 + provenance 5, présence d'un acte CCAM
             chirurgical du chapitre ATIH activité 1)
Stratification : par GHM-racine ou par grand groupe (CMD 05 cardio,
                 CMD 08 ostéo-articulaire, etc.)
Granularité : mensuelle
Apprentissage : ≥24 mois pour calibrer le modèle de risque et estimer ARL₀
```

### 2. Modèle de risque (calcul de Eₜ et Vₜ)

```
GLM logistique sur historique 36 mois, hors mois en cours :
  logit(p_i) = β₀ + β₁·age + β₂·sexe + β₃·Charlson(DAS)
             + β_GHM (effet GHM-racine) + β₄·entrée_urgence
             + β₅·niveau_sévérité_GHM (1..4)

Validation :
  - C-statistic (AUC) ≥ 0,75 sur fold de validation
  - Calibration Hosmer-Lemeshow p ≥ 0,05
  - Recalibration annuelle obligatoire
```

### 3. Mise à jour séquentielle

```
Pour chaque mois t :
  Récupérer la cohorte chirurgicale du mois (n_t séjours)
  Pour chaque séjour i : calculer p_i via le modèle pré-entraîné
  E_t = Σ_i p_i
  V_t = Σ_i p_i (1 - p_i)
  O_t = nombre de séjours avec modesortie = 9
  u_t = (O_t - E_t) / sqrt(V_t)             # écart standardisé
  z_t = lambda * u_t + (1 - lambda) * z_{t-1}

Bornes :
  sigma_z = sqrt(lambda / (2 - lambda)) * sqrt(1 - (1-lambda)^(2t))
  UCL_t = +L * sigma_z
  LCL_t = -L * sigma_z

Alerte : z_t > UCL_t (dégradation) ou z_t < LCL_t (amélioration suspecte
         à investiguer : sous-codage ? changement casemix ?)
```

### 4. Choix des paramètres

```
λ = 0.2  par défaut (équilibre)
       0.1 si surveillance « long terme » (CHU à fort volume)
       0.4 si on veut détecter des sauts brusques (CH petit volume)

L = 2.7  pour ARL₀ ≈ 250 mois (calibration tabulée Crowder 1989)
    Ajuster par simulation Monte-Carlo sur l'historique si stratification fine.
```

### 5. Visualisation

```
Graphique :
  - axe X : mois
  - axe Y : z_t
  - courbes : UCL_t, LCL_t (s'écartent puis se stabilisent)
  - annotations : changements organisationnels, transitions de version PMSI
```

## Utilité

- **Détection des dérives lentes (~+10–20% de taux)** invisibles au CUSUM avec k cible 1,5×μ₀ : un bloc opératoire qui glisse progressivement (turnover infirmier, équipement vieillissant) est typiquement repéré par EWMA(λ=0,15) 2–3 mois avant le CUSUM.
- **Pilotage en direction médicale** : la statistique zₜ est lisible comme un « score-Z courant de la mortalité » — beaucoup plus parlant en CME qu'une accumulation CUSUM, ce qui facilite l'appropriation par les cliniciens.
- **Surveillance combinée CUSUM + EWMA** : les deux cartes partagent le même modèle de risque mais détectent des profils complémentaires ; alerte conjointe = forte probabilité de dérive réelle, alerte isolée = à investiguer avec prudence.
- **Comparaison inter-établissements du GHT** : EWMA stratifiée par FINESS sur GHM commun (PTH, CABG, colectomie) → identification des sites du GHT divergents sans biais de casemix entrant.
- **Évaluation d'intervention organisationnelle** : déploiement d'un programme RAAC, checklist HAS, RMM → suivi de la trajectoire EWMA après déploiement, comparée à un seuil d'amélioration cible (LCL à −2,7).
- **Reporting régulier ARS / contrat GHT** : courbe EWMA mensuelle directement intégrable dans les tableaux de bord de pilotage de la CME, contrat d'objectifs ARS, certification HAS.

## Sources de Données

Variables PMSI MCO confirmées dans le *Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation en MCO*, ATIH 2025 :

- **RSA** :
  - `modesortie` (mode de sortie) — code 9 = décès
  - `modeentree` + `provenance` (urgences = 8 + provenance 5) — pour exclure les entrées urgentes si périmètre = chirurgie programmée
  - `GHM` / `GHM_RACINE` / niveau de sévérité (4ᵉ caractère du GHM)
  - `age`, `SEXE`
  - `DAS` (diagnostics associés) — calcul du score Charlson
  - `duree`
- **Actes CCAM** : présence d'au moins un acte chirurgical (chapitre ATIH activité 1) pour qualifier la cohorte.
- **FINESS géographique** (`FINESSGEO`) pour stratification par site dans un GHT multi-FINESS.
- **Référentiel GHM en vigueur** (V2025 / V2026 selon période) — table de correspondance ATIH publiée dans le scope du fichier `rsa203` ou équivalent en cours.
- **Modèle de risque** : entraîné localement (R `glm`, Python `statsmodels`) sur historique chaîné.
- **Outils statistiques** : R (`qcc::ewma`, `vlad` pour racusum/raewma), Python (`statsmodels.stats.diagnostic`, `pyqcc`).

Les noms de variables ci-dessus correspondent au format RSA en vigueur au moment de l'écriture ; à confirmer pour le format **V016** (entrée en vigueur progressive 2026, voir notice ATIH-294-9-2025) qui modifie la structure des Disciplines Médico-Tarifaires (DMT).

## Exemple de Valeurs

Ordres de grandeur experts, à recalibrer localement avec les données du GHT.

- **CHU — chirurgie cardiaque (CABG isolé)** : volume 800 cas/an, μ₀ ≈ 2,1 % (mortalité 30j) ; λ = 0,2, L = 2,7 → UCL asymptotique +1,01 ; détection typique d'une dérive +30 % en 5–6 mois.
- **CH — orthopédie majeure (PTH/PTG)** : volume 1 200 cas/an, μ₀ ≈ 0,5 % ; λ = 0,15, L = 3 → ARL₀ ≈ 400 mois ; sensibilité réduite par faible événement-rate, à coupler obligatoirement avec CUSUM.
- **CHU — chirurgie digestive lourde (colectomie, œso-gastrectomie)** : μ₀ ≈ 3–4 %, EWMA très réactive ; λ = 0,3 recommandé pour saisir les dérives liées à la composition d'équipe.
- **GHT consolidé — toute chirurgie programmée** : volume 25 000+ cas/an réparti sur 4 FINESS ; EWMA stratifiée par site permet d'identifier le ou les sites moteurs d'une éventuelle dérive globale.
- **Cas d'amélioration** : déploiement RAAC ortho → zₜ glissant vers −1,5 sur 6 mois consécutifs → confirmation statistique de l'effet (sans atteindre forcément LCL).

## Limites

- **Calibration de λ et L** : sensibilité directe au compromis faux positifs / délai de détection ; un λ trop petit lisse à l'excès (perte de réactivité), un λ trop grand revient à un Shewhart bruité ; calibrer par **simulation Monte-Carlo** sur l'historique avant déploiement, comme pour le CUSUM.
- **Faible volume mensuel** : pour des GHM rares (< 20 séjours/mois), la variance Vₜ est instable et zₜ devient erratique ; agrégation trimestrielle ou périmètre élargi (GHM-racine multi-niveaux) requis.
- **Qualité du modèle de risque** : EWMA risk-adjusted ne fait que reporter la mortalité résiduelle non expliquée par le modèle ; un modèle sous-spécifié (omission d'un facteur de risque corrélé au site) génère des faux signaux systématiques. AUC ≥ 0,75 et recalibration annuelle minimums.
- **Effet de version PMSI** : transition V2025 → V2026 / passage au format V016 (DMT à 3 caractères) → discontinuité sur la valeur de Eₜ ; planifier un reset explicite (z₀ = 0) à la date de bascule.
- **Casemix drift** : ouverture/fermeture de service, recrutement de patients différents → modèle de risque dérive ; surveiller un indicateur Brier-score mensuel et ré-entraîner sur fenêtre glissante 36 mois.
- **Pas un outil de jugement causal** : zₜ > UCL signale une dérive statistique au regard du modèle, pas une mauvaise pratique ; déclencheur d'audit qualitatif, jamais une sanction.
- **Auto-corrélation des décès** : un cluster (épidémie nosocomiale, défaillance équipement) induit une auto-corrélation positive non gérée par l'EWMA standard ; en cas d'auto-corrélation détectée (Ljung-Box), passer à une EWMA pour processus auto-corrélés (Lu & Reynolds 1999) ou réduire L.

## Références

- [Roberts S.W. — Control chart tests based on geometric moving averages, Technometrics 1959](https://doi.org/10.1080/00401706.1959.10489860) — article fondateur de l'EWMA.
- [Grigg O.A., Spiegelhalter D.J. — A simple risk-adjusted exponentially weighted moving average, J Am Stat Assoc 2007](https://doi.org/10.1198/016214506000001167) — formalisation EWMA risk-adjusted en santé.
- [Cook D.A., Steiner S.H., Cook R.J., Farewell V.T., Morton A.P. — Monitoring the evolutionary process of quality: risk-adjusted charting to track outcomes in intensive care, Crit Care Med 2003](https://pubmed.ncbi.nlm.nih.gov/14693983/) — application réanimation et discussion CUSUM/EWMA. PMID 14693983
- [Cook D.A., Coory M., Webster R.A. — Exponentially weighted moving average charts to compare observed and expected values for monitoring risk-adjusted hospital indicators, BMJ Qual Saf 2011](https://doi.org/10.1136/bmjqs.2008.031831) — implémentation hospitalière. PMID 19908262
- [Woodall W.H. — The use of control charts in health-care and public-health surveillance, J Quality Technology 2006](https://doi.org/10.1080/00224065.2006.11918593) — revue de référence.
- [Crowder S.V. — Design of exponentially weighted moving average schemes, J Quality Technology 1989](https://doi.org/10.1080/00224065.1989.11979139) — tables de calibration ARL.
- [ATIH — Guide méthodologique de production des informations PMSI MCO, version 2025](https://www.atih.sante.fr/sites/default/files/public/content/4935/guide_methodo_mco_2025_version_provisoire_040225_0.pdf) — variables RSA, codage modesortie, format en vigueur.
- [ATIH — Notice technique ATIH-294-9-2025 du 21 novembre 2025 — Nouveautés PMSI 2026](https://www.atih.sante.fr/sites/default/files/public/content/5108/notice_technique_pmsi_2026.pdf) — passage au format V016, refonte sévérité prévue 2028.
