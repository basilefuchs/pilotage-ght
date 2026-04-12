# Rapport Signal/Bruit des Indicateurs de Qualité

## Définition

Le rapport signal/bruit (Signal-to-Noise Ratio, SNR) est un concept fondamental du traitement du signal et des télécommunications : il mesure le rapport entre la puissance du signal utile (information réelle) et la puissance du bruit de fond (variation aléatoire). Un SNR élevé signifie que le signal est clairement distinguable du bruit ; un SNR faible signifie que le signal est noyé dans le bruit et qu'il est impossible de distinguer une variation réelle d'une fluctuation aléatoire.

Appliqué aux indicateurs de qualité hospitaliers (taux de réadmission, taux de mortalité ajusté, taux de complications, DMS), le **Rapport Signal/Bruit des Indicateurs de Qualité** (RSNIQ) répond à la question que tout gestionnaire et médecin pose en regardant ses résultats mensuels : **"Cette variation de mon indicateur est-elle réelle ou due au hasard ?"**

Sans calcul du SNR, deux erreurs symétriques sont inévitables :
- **Fausse alarme** : réagir à une "dégradation" qui n'est qu'une fluctuation aléatoire (gaspillage d'énergie, démotivation des équipes)
- **Fausse réassurance** : ignorer une vraie dégradation masquée dans le bruit statistique (risque qualité non détecté)

**SNR = σ²_signal / σ²_bruit**

où σ²_signal est la variance des variations réelles de l'indicateur (liées à des causes assignables) et σ²_bruit la variance du bruit statistique attendu (liée à la taille de la cohorte et aux fluctuations aléatoires intrinsèques).

## Calcul

Modèle de décomposition signal/bruit pour un indicateur de proportion :

```
Exemple : taux de réadmission à 30j sur une série mensuelle

Indicateur observé chaque mois m :
  p̂_m = r_m / n_m   (réadmissions r_m sur n_m séjours éligibles)

Variance du bruit statistique (modèle binomial) :
  σ²_bruit(m) = p̂ × (1 − p̂) / n_m
  où p̂ = taux moyen sur la période de référence (12-24 mois)
  → Plus n_m est petit, plus le bruit est grand — les petites cohortes sont très bruyantes

Variance observée totale (signal + bruit) :
  σ²_total = (1/M) × Σ_m (p̂_m − p̂)²
  où M = nombre de mois dans la fenêtre d'analyse

Variance du signal (excès de variance au-delà du bruit attendu) :
  σ²_signal = max(0 ; σ²_total − σ²_bruit_moyen)
  où σ²_bruit_moyen = (1/M) × Σ_m σ²_bruit(m)

SNR = σ²_signal / σ²_bruit_moyen
  → SNR > 1 : il existe un signal réel au-delà du bruit statistique
  → SNR < 1 : la variabilité observée est entièrement expliquée par le bruit
  → SNR > 3 : signal fort, variations interprétables avec confiance
```

Test de surdispersion (test préalable à tout commentaire d'indicateur) :

```
Statistique de surdispersion χ² :
  χ² = Σ_m [(p̂_m − p̂)² × n_m] / [p̂ × (1 − p̂)]
  Suit une loi χ²(M−1) sous H₀ (pas de signal, variabilité purement aléatoire)

p-valeur de surdispersion :
  p_surdisp = P(χ²(M−1) > χ²_observé)
  → p_surdisp > 0.05 : pas de preuve de signal réel — toute la variabilité
    observée est compatible avec le bruit statistique seul
  → p_surdisp < 0.05 : surdispersion significative — il existe un signal réel
    qu'il est pertinent d'investiguer

Règle pratique :
  Avant tout commentaire sur l'évolution d'un indicateur mensuel,
  calculer p_surdisp :
  → Si p > 0.05 : "La variation observée n'est pas statistiquement significative
    compte tenu de la taille de cohorte. Elle ne justifie pas d'action corrective."
  → Si p < 0.05 : "La variation dépasse le bruit statistique attendu.
    Une investigation est justifiée."
```

Intervalle de confiance funnel plot :

```
Représentation graphique standard (funnel plot de Spiegelhalter) :
  Axe X : taille du dénominateur n_m (volume d'activité)
  Axe Y : valeur de l'indicateur p̂_m
  Limites de contrôle (funnels) :
    Limite à 2σ : p̂ ± 2 × √(p̂ × (1−p̂) / n)   → alerte (2.5% faux positifs)
    Limite à 3σ : p̂ ± 3 × √(p̂ × (1−p̂) / n)   → alarme (0.1% faux positifs)

  → Points dans le funnel : performance compatible avec le hasard
  → Points hors du funnel à 2σ : signal potentiel (1 sur 20 est un faux positif)
  → Points hors du funnel à 3σ : signal quasi-certain

Score z standardisé (comparable entre indicateurs différents) :
  z_m = (p̂_m − p̂) / √(p̂ × (1−p̂) / n_m)
  → |z_m| > 2 : hors contrôle statistique à 95%
  → |z_m| > 3 : hors contrôle statistique à 99.9%
  → Permet de classer les services par niveau de signal,
    indépendamment de l'indicateur et de la taille du service
```

SNR pour indicateurs continus (DMS, coût) :

```
Pour un indicateur continu x̄_m (DMS mensuelle) :
  σ²_bruit(m) = s² / n_m   (variance intra-groupe / taille de l'échantillon)
    où s² = variance intra-groupe de la DMS (estimée sur la période de référence)
  σ²_total = variance inter-mois de x̄_m
  SNR = max(0 ; σ²_total − σ²_bruit_moyen) / σ²_bruit_moyen
```

## Utilité

- **Éviter les réunions de crise inutiles sur des variations aléatoires** : dans la grande majorité des établissements, les indicateurs qualité mensuels sont commentés sans test de significativité — des variations de ±20% sur de petites cohortes sont présentées comme des "dégradations alarmantes" ou des "améliorations notables" alors qu'elles sont entièrement dues au bruit statistique ; le RSNIQ impose une discipline analytique avant tout commentaire
- **Détecter les vraies dégradations masquées par le bruit** : symmétriquement, une vraie dégradation sur un indicateur à faible cohorte peut être statistiquement invisible sur un mois mais significative sur un trimestre — le RSNIQ identifie l'agrégation temporelle minimale nécessaire pour détecter un signal de taille donnée (calcul de la taille d'échantillon nécessaire)
- **Prioriser les indicateurs les plus informatifs** : dans un tableau de bord avec 20 indicateurs qualité, ceux avec un SNR > 1 sont les seuls qui contiennent de l'information interprétable sur la performance réelle — les autres ne font que refléter le bruit statistique et peuvent être simplifiés ou agrégés sans perte d'information
- **Calibrer la fréquence de surveillance des indicateurs** : un indicateur avec un SNR très faible mensuel mais significatif trimestriellement devrait être suivi au trimestre, pas au mois — le RSNIQ guide la conception des tableaux de bord en adaptant la fréquence de reporting à la puissance statistique réelle disponible
- **Outil pédagogique pour les CME et instances qualité** : le funnel plot est une représentation graphique accessible qui montre intuitivement pourquoi un petit service ne peut pas être évalué avec les mêmes standards qu'un grand service — argument pour une interprétation contextualisée des indicateurs et contre le classement brut des services
- **Base des cartes de contrôle CUSUM et EWMA** : le RSNIQ est l'étape préalable à l'implémentation de cartes de contrôle statistique de processus (SPC) — identifier la variance du bruit σ²_bruit est le prérequis pour calculer les limites de contrôle des cartes CUSUM (détection précoce des dérives) et EWMA (lissage exponentiel)

## Sources de Données

- **PMSI MCO RSA** : numérateurs (réadmissions, décès, complications identifiées par les codes CIM-10 en DA) et dénominateurs (séjours éligibles par GHM ou CMD) pour les indicateurs de proportion — calcul de n_m et r_m par mois sur 24-36 mois glissants
- **PMSI MCO RSA (DMS, coût)** : variables DATE_ENT, DATE_SOR, GHS pour les indicateurs continus — calcul de x̄_m et s² par mois et par groupe
- **PMSI SSR RHS** : pour les indicateurs SSR (gain MIF, DMS SSR, taux de retour à domicile) — mêmes méthodes que MCO
- **Base nationale ATIH** : taux de référence nationaux p̂_ref par GHM — pour centrer les funnel plots sur la référence nationale plutôt que sur la moyenne locale (comparaison externe)

## Exemple de Valeurs

- **Taux de réadmission à 30j en chirurgie cardiaque (service de 15-20 séjours/mois)** :
  p̂ = 8%, n_m moyen = 17 séjours/mois
  σ²_bruit = 0.08 × 0.92 / 17 = 0.00432 → σ_bruit = 6,6 points de %
  → Toute variation mensuelle de ±13 points est dans les 2σ du bruit statistique
  → Un "pic" à 20% un mois est compatible avec le hasard (z = 1.82 < 2)
  → SNR < 1 : suivi mensuel non informatif — agrégation trimestrielle nécessaire

- **Taux de réadmission à 30j en médecine interne (service de 120 séjours/mois)** :
  p̂ = 12%, n_m moyen = 120
  σ²_bruit = 0.12 × 0.88 / 120 = 0.00088 → σ_bruit = 3,0 points de %
  σ²_total observée sur 24 mois = 0.00210
  SNR = (0.00210 − 0.00088) / 0.00088 = 1.39 → signal réel détectable
  → Un taux mensuel > 18% (p̂ + 2σ) ou < 6% déclenche une alerte justifiée

- **Test de surdispersion sur un indicateur de mortalité** :
  12 mois de taux de mortalité intra-hospitalière, n_m = 200 séjours/mois
  χ² = 22.3 pour 11 degrés de liberté → p_surdisp = 0.022
  → Surdispersion significative : la variabilité mensuelle dépasse le bruit attendu
  → Signal réel à investiguer (changement de casemix ? événement qualité ?)

- **Taille d'échantillon nécessaire pour détecter une variation de +2 points** :
  p̂ = 10%, variation cible Δ = +2 points, puissance 80%, α = 5%
  n_nécessaire = 2 × p̂(1−p̂) × (z_{0.975} + z_{0.8})² / Δ²
               = 2 × 0.09 × (1.96+0.84)² / 0.0004 ≈ **3 528 séjours**
  → Pour un service de 100 séjours/mois : détection possible après 35 mois seulement
  → Argument pour l'agrégation au niveau GHT plutôt que service isolé

## Limites

- Le modèle binomial de bruit statistique suppose l'**indépendance des événements** — hypothèse violée si des patients sont réadmis plusieurs fois (biais de clustering) ou si des épidémies nosocomiales créent des regroupements temporels d'événements ; utiliser un modèle négatif-binomial ou quasi-binomial pour tenir compte de la surdispersion résiduelle
- Le **funnel plot standard** ne tient pas compte des différences de casemix entre mois ou entre services — un service qui traite des cas plus lourds en hiver aura un indicateur "hors funnel" en hiver non pas parce que sa qualité a baissé mais parce que son casemix a changé ; l'ajustement sur le risque (SMSR standardisé) est nécessaire avant d'appliquer le funnel plot
- Le RSNIQ mesure la **significativité statistique, non la pertinence clinique** — une variation statistiquement significative peut être cliniquement insignifiante (passage de 10,0% à 10,5%) et une variation cliniquement importante peut être statistiquement non significative sur une petite cohorte ; les deux dimensions (SNR statistique et importance clinique) doivent être présentées conjointement
- La définition de la **période de référence** pour calculer p̂ et σ²_bruit influence les limites de contrôle — si la période de référence inclut des épisodes de mauvaise qualité, le bruit de référence est surestimé et des vraies dégradations ultérieures seront classifiées comme "dans les limites normales" ; la période de référence doit être une période de performance stable et représentative

## Références

- [Spiegelhalter D.J. — Funnel plots for comparing institutional performance, Statistics in Medicine 2005](https://doi.org/10.1002/sim.1970) — référence fondamentale du funnel plot en qualité hospitalière
- [Mohammed M.A. et al. — Evidence of methodological bias in hospital standardised mortality ratios, BMJ 2009](https://doi.org/10.1136/bmj.b780)
- [Shewhart W.A. — Economic Control of Quality of Manufactured Product, Van Nostrand 1931 : fondements des cartes de contrôle statistique]
- [Montgomery D.C. — Introduction to Statistical Quality Control, Wiley 2009 : référence standard du SPC, cartes CUSUM et EWMA]
- [HAS — Indicateurs de qualité et de sécurité des soins (IQSS) : méthodes statistiques de calcul et d'interprétation (2022)](https://www.has-sante.fr/)
- [ATIH — Méthode de calcul des indicateurs PMSI et intervalles de confiance associés](https://www.atih.sante.fr/)
