# CUSUM de Surveillance Séquentielle des Complications

## Définition

La carte de contrôle **CUSUM** (Cumulative Sum, Page 1954) est un outil de maîtrise statistique des procédés conçu pour détecter les **petites dérives persistantes** d'un processus bien avant qu'elles ne deviennent visibles dans la moyenne. Là où une moyenne mobile lisse les fluctuations et masque les dégradations lentes, le CUSUM **accumule l'écart cumulé** au seuil cible : tant que le processus est sous contrôle, la somme reste proche de zéro ; dès qu'une dérive s'installe, l'accumulation diverge linéairement et déclenche un signal d'alerte.

Transposée à la qualité hospitalière (Steiner 2000, Grigg 2003), cette logique permet la **surveillance prospective** des taux de complications post-opératoires, infections nosocomiales ou réinterventions : chaque séjour ou chaque mois met à jour la statistique CUSUM, qui sonne l'alerte au moment où la dérive s'installe — typiquement **3 à 6 mois avant** que le taux annuel n'apparaisse anormal.

**Statistique CUSUM unilatérale (détection de hausse) :**

**S₀ = 0**
**Sₜ = max(0, Sₜ₋₁ + (xₜ − k))**

Alerte lorsque **Sₜ > h** (seuil de décision).

où :
- xₜ est l'observation au temps t (taux de complications du mois t, ou indicateur 0/1 par séjour)
- k = (μ₀ + μ₁) / 2 est la *reference value* (drift), point milieu entre le taux cible μ₀ et le taux dégradé μ₁ que l'on souhaite détecter
- h est la *decision interval*, calibré sur le couple (ARL₀, ARL₁) — temps moyen entre faux positifs / temps moyen de détection d'une vraie dérive

Pour les indicateurs binaires (séjour avec/sans complication), on utilise la variante **Bernoulli CUSUM** ou le **risk-adjusted CUSUM** (Steiner 2000) qui pondère chaque séjour par sa probabilité a priori de complication, calculée à partir d'un modèle logistique sur le casemix.

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `taux_complications_ghm.md` — **taux annuel** : retard de détection ≥ 12 mois
- `psi90_patient_safety_indicators.md` — composite annuel
- `rapport_signal_bruit_indicateurs_qualite.md` — diagnostic statique du bruit
- `loi_gutenberg_richter_evenements_indesirables.md` — analyse de la **distribution** des EI
- `value_at_risk_evenements_indesirables.md` — quantile extrême

Aucun n'offre la **détection séquentielle prospective** : le CUSUM est le seul outil à temps de détection court (mois à mois) garantissant un ARL₀ contrôlé.

## Calcul

### 1. Définition de l'événement et de la fenêtre

```
Événement à surveiller : complication post-opératoire codée selon PSI-90
                         OU réintervention non programmée à J<30
                         OU décès intra-séjour pour GHM à mortalité attendue < 1%

Périmètre : un GHM-racine ou un service (UM)
Granularité temporelle : mensuelle (par défaut) ou par séjour (CUSUM séquentiel)
Fenêtre d'apprentissage : 24-36 mois pour estimer μ₀ (taux cible "sous contrôle")
```

### 2. Calibration des paramètres (μ₀, μ₁, k, h)

```
μ₀ : taux moyen observé sur la période d'apprentissage
     OU benchmark national (taux PSI ATIH, ScanSanté)
μ₁ : taux que l'on veut détecter — typiquement 1.5 × μ₀ (dégradation de 50%)
k  : k = (μ₀ + μ₁) / 2

h  : choisi pour respecter ARL₀ ≥ 100 mois (≈8 ans entre faux positifs)
     Tabulé : pour CUSUM normal, h ≈ 4-5 σ
     Pour Bernoulli CUSUM, h ≈ 4-5 selon Reynolds & Stoumbos 1999
     Pour risk-adjusted CUSUM, simulation Monte-Carlo sur l'historique
```

### 3. Mise à jour séquentielle

```
Pour chaque mois t (ou chaque séjour t) :

  CUSUM agrégé mensuel :
    xₜ = (n_complications_t / n_séjours_t) − μ₀
    Sₜ⁺ = max(0, Sₜ₋₁⁺ + (xₜ − k))      # détection hausse
    Sₜ⁻ = min(0, Sₜ₋₁⁻ + (xₜ + k))      # détection baisse (amélioration)

  Bernoulli CUSUM (par séjour, sans casemix) :
    Wₜ = log((p₁/p₀)^yₜ × ((1−p₁)/(1−p₀))^(1−yₜ))
    Sₜ = max(0, Sₜ₋₁ + Wₜ)
    où yₜ ∈ {0, 1} = présence de complication

  Risk-adjusted CUSUM (Steiner 2000) :
    pₜ = Pr(complication | casemix_t) issu d'un modèle logistique GLM
         pré-entraîné (âge, sexe, Charlson, GHM, mode entrée)
    Wₜ = log((p₁_adj/pₜ)^yₜ × ((1−p₁_adj)/(1−pₜ))^(1−yₜ))
    où p₁_adj = pₜ × OR cible (typiquement OR = 2)
    Sₜ = max(0, Sₜ₋₁ + Wₜ)

Alerte : Sₜ > h → déclencher audit qualité, mettre en pause si critique.
Reset : après alerte ET résolution, repartir de Sₜ = 0.
```

### 4. Visualisation et reporting

```
Graphique de contrôle :
  - Axe X : temps (mois ou séjour)
  - Axe Y : Sₜ
  - Ligne horizontale : h (seuil de décision)
  - Annotations : événements (changement de praticien, nouvelle technique)

Tableau de bord GHT :
  - Statut courant par GHM-racine surveillé : OK / WARNING (Sₜ > h/2) / ALERTE
  - Pente de Sₜ sur les 3 derniers mois (vitesse de dérive)
  - Temps depuis le dernier reset
```

## Utilité

- **Détection précoce des dérives qualité** : un CUSUM bien calibré détecte une dégradation de 50% du taux de complications avec ~3-4 mois d'avance par rapport au taux annuel — temps précieux pour intervenir avant qu'un audit national (HAS, ARS) ne pointe l'établissement
- **Surveillance par praticien après nouvelle technique** : déploiement d'une intervention chirurgicale innovante (robot, mini-invasif) → CUSUM dédié sur les 100 premiers cas pour vérifier que la courbe d'apprentissage reste dans des bornes acceptables (Steiner 2000 utilise précisément ce cas)
- **Pilotage des plans d'actions correctifs** : après audit ayant révélé un défaut (par ex. checklist non appliquée), CUSUM⁻ (détection de baisse) sert à confirmer **objectivement** l'amélioration — preuve du retour sous contrôle pour la CME
- **Comparaison équitable inter-établissements** : le risk-adjusted CUSUM neutralise les différences de casemix, permettant une comparaison directe des trajectoires qualité entre CH périphérique et CHU au sein du GHT
- **Optimisation du périmètre des audits qualité** : seuls les CUSUM en alerte déclenchent un audit complet — économie majeure de ressources qualité, ciblage des problèmes réels plutôt qu'audit calendaire systématique
- **Gouvernance de la transition de version PMSI** : les changements de classification (V2025 → V2026) provoquent souvent des artefacts ; un CUSUM avec reset planifié à la transition permet de distinguer artefact technique vs vraie dérive

## Sources de Données

- **PMSI MCO RSA** : DAS (diagnostics associés, table `diag`) pour identifier les complications selon les codes CIM-10 PSI ATIH ; dates `date_entree`/`date_sortie` pour la chronologie ; `ghm2` pour le GHM-racine et niveau de sévérité ; `finess`, `finessgeodp` pour la granularité établissement ; `age`, `sexe` pour l'ajustement risque
- **Référentiel PSI ATIH** : liste des codes CIM-10 et CCAM identifiant les complications post-opératoires (PSI 03, 09, 11, 12, 13, 14, 15) — disponible sur scansante.fr et atih.sante.fr
- **PMSI MCO chaîné (id_hospit_ipp)** : variable `ipp_c` pour le suivi des réinterventions à J<30 sur séjours ultérieurs
- **Modèle de risque** : à entraîner localement sur 3 ans d'historique avec GLM logistique (covariables : age, sexe, Charlson via DAS, GHM, modeentree) — package `glm` R ou `statsmodels` Python
- **Outils** : R (`qcc::cusum`, `vlad::racusum`), Python (`statsmodels.stats.diagnostic.recursive_olsresiduals`)

## Exemple de Valeurs

- **CHU — chirurgie cardiaque (CABG isolé)** :
  μ₀ = 2.1% (taux de mortalité 30j), μ₁ = 4.0%, k = 0.0305
  h = 4.5 (calibré pour ARL₀ ≈ 120 mois)
  Volume = 800 cas/an → ~67 séjours/mois
  Détection typique : dérive de +50% sur 6 mois → alerte au 4ᵉ mois

- **CH périphérique — orthopédie (PTH/PTG)** :
  μ₀ = 3.5% (taux de complications post-op), μ₁ = 5.5%
  Volume = 300 cas/an → 25 séjours/mois → forte variance, h = 5
  Détection plus tardive (5-7 mois) à cause du faible volume mensuel

- **Service de gériatrie aiguë — escarres** :
  μ₀ = 4.0%, surveillance trimestrielle (volume mensuel insuffisant)
  Alerte historique : dérive identifiée trimestre 3 d'un changement de prestataire literie

- **Réinterventions chirurgicales J<30 (toutes spé. confondues, GHT)** :
  μ₀ = 5.8% (benchmark ATIH 2024)
  Volume = ~12 000 cas chir/an → CUSUM mensuel robuste
  Seuil ARL₀ = 60 mois → h ≈ 4.0

- **Cas d'amélioration documentée** :
  Après déploiement d'un programme RAAC orthopédique :
  CUSUM⁻ négatif soutenu sur 8 mois → confirmation statistique de l'effet
  Réduction estimée : −30% du taux de complications (Sₜ⁻ atteint −15)

## Limites

- **Calibration sensible** : le couple (k, h) détermine entièrement le compromis faux positifs / temps de détection — un h trop bas génère une vague d'alertes injustifiées (perte de confiance des cliniciens), un h trop haut retarde la détection au point de la rendre inutile ; nécessité d'un calibrage par simulation Monte-Carlo sur l'historique avant déploiement
- **Faible volume mensuel** : pour un GHM avec moins de 30 séjours/mois, la variance du taux mensuel est trop élevée pour un CUSUM agrégé fiable ; utiliser le Bernoulli CUSUM séquentiel par séjour, ou agréger en trimestres au prix d'un délai de détection allongé
- **Effet de la version PMSI** : un changement de groupage (V2025 → V2026) peut réaffecter des séjours entre GHM et créer un saut artificiel dans le taux ; planifier un **reset** explicite du CUSUM aux dates de bascule version, sinon faux positif systématique
- **Casemix drift** : le risk-adjusted CUSUM suppose que le modèle de risque reste stable ; si la patientèle change (ouverture d'un nouveau service, fermeture d'un concurrent local), le modèle dérive et provoque des faux signaux ; ré-entraîner le modèle annuellement sur fenêtre glissante de 36 mois
- **Effet "post-alerte"** : après une alerte vraie suivie d'un plan d'action, le CUSUM doit être reset manuellement ; oubli fréquent en pratique → CUSUM bloqué au-dessus de h pendant des mois après que le problème est résolu, masquant les dérives suivantes
- **Pas un outil de jugement causal** : le CUSUM signale une dérive statistique, pas une cause ; une alerte n'est pas une preuve de mauvaise pratique — c'est un déclencheur d'audit qualitatif

## Références

- [Page E.S. — Continuous inspection schemes, Biometrika 1954](https://doi.org/10.1093/biomet/41.1-2.100) — article fondateur du CUSUM
- [Steiner S.H., Cook R.J., Farewell V.T., Treasure T. — Monitoring surgical performance using risk-adjusted cumulative sum charts, Biostatistics 2000](https://doi.org/10.1093/biostatistics/1.4.441) — risk-adjusted CUSUM appliqué à la chirurgie
- [Grigg O., Spiegelhalter D. — A simple risk-adjusted exponentially weighted moving average, J Am Stat Assoc 2007](https://doi.org/10.1198/016214506000001167)
- [Reynolds M.R., Stoumbos Z.G. — A CUSUM chart for monitoring a proportion when inspecting continuously, J Quality Technology 1999](https://doi.org/10.1080/00224065.1999.11979913) — calibration Bernoulli CUSUM
- [Woodall W.H. — The use of control charts in health-care and public-health surveillance, J Quality Technology 2006](https://doi.org/10.1080/00224065.2006.11918593) — revue d'application au domaine santé
- [HAS — Surveillance des indicateurs qualité en établissement de santé : méthodes statistiques, 2019](https://www.has-sante.fr/) — recommandations méthodologiques nationales
- [ATIH — Indicateurs PSI, ScanSanté](https://scansante.fr/) — référentiel des codes complications
