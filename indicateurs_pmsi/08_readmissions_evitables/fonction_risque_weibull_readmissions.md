# Fonction de Risque de Weibull des Réadmissions

## Définition

En ingénierie de la fiabilité, la **fonction de risque** (hazard function, ou taux de défaillance instantané) h(t) décrit comment la probabilité de défaillance d'un composant évolue avec le temps depuis sa mise en service. La distribution de Weibull (Waloddi Weibull, 1951) est le modèle le plus utilisé en fiabilité car sa forme est entièrement déterminée par deux paramètres — l'échelle λ et la forme k — qui donnent accès à trois régimes fondamentalement différents :

- **k < 1** : taux de défaillance décroissant — les défaillances précoces dominent (mortalité infantile), le composant est plus fragile à t=0 qu'à t>0
- **k = 1** : taux de défaillance constant — loi exponentielle, défaillances aléatoires indépendantes du temps écoulé
- **k > 1** : taux de défaillance croissant — usure progressive, le composant est de plus en plus susceptible de tomber en panne avec le temps

Transposée aux réadmissions post-sortie hospitalière, la **Fonction de Risque de Weibull des Réadmissions** (FRWR) modélise comment le taux instantané de réadmission h(t) évolue avec le temps depuis la sortie du patient. La réponse empirique — k < 1 — révèle que le risque de réadmission est **maximal dans les premiers jours post-sortie** et décroît ensuite : le patient est à son plus fort risque de décompensation à J0-J7 (période critique précoce), et ce risque diminue progressivement s'il passe ce cap sans incident.

**h(t) = (k/λ) × (t/λ)^(k−1)**

où t est le délai en jours depuis la sortie MCO et λ est la durée caractéristique (mediane de la distribution des réadmissions).

## Calcul

Construction de la cohorte de réadmission :

```
Cohorte : séjours MCO index sur une période d'analyse (12-24 mois)
  → Chaînage PMSI par NIR crypté : séjour index S_i + éventuel séjour de réadmission R_i
  → Délai de réadmission : Δᵢ = DATE_ENT(R_i) − DATE_SOR(S_i)   (en jours)

Critères de définition de la réadmission (à préciser selon l'objectif) :
  → Réadmission toutes causes : tout séjour MCO dans les 30j post-sortie
  → Réadmission potentiellement évitable : séjour avec MODE_ENTREE = 8 (urgences)
    ET diagnostic de réadmission lié au diagnostic du séjour index
    (même CMD ou codes CIM-10 apparentés)
  → Réadmission précoce (J0-J7) vs tardive (J8-J30) : selon le délai Δᵢ

Données censurées :
  → Patients non réadmis dans les 30j : censurés à droite à 30 jours
  → Patients décédés avant réadmission : censurés à la date de décès
  → Inclusion dans l'analyse de survie avec marqueur de censure
```

Ajustement du modèle de Weibull et estimation de h(t) :

```
Étape 1 — Estimation des paramètres par maximum de vraisemblance :
  Avec censure à droite :
  (k̂, λ̂) = argmax Σᵢ [δᵢ × ln(f(Δᵢ)) + (1−δᵢ) × ln(S(Δᵢ))]
  où δᵢ = 1 si réadmission, 0 si censuré
  f(t) = densité Weibull, S(t) = fonction de survie Weibull

  Implémentation : Python (scipy.stats.weibull_min.fit, lifelines.WeibullFitter)
                  R (survreg avec dist="weibull", flexsurv)

Étape 2 — Interprétation de k̂ :
  k̂ < 1 : risque maximal à la sortie, décroissant — période critique précoce
           → Action prioritaire : appel téléphonique à J2-J3, consultation J7
  k̂ = 1 : risque constant — réadmissions aléatoires indépendantes du délai
           → Pas de fenêtre critique identifiable
  k̂ > 1 : risque croissant — décompensation progressive à distance
           → Action : suivi renforcé à J14-J21 plutôt qu'à J3-J7

Étape 3 — Calcul de h(t) et identification du pic de risque :
  h(t) = (k̂/λ̂) × (t/λ̂)^(k̂−1)

  Si k̂ < 1 : pic à t = 0 (sortie), h(0) = ∞ théoriquement → calculer h(1j) et h(7j)
  Si k̂ > 1 : pic à t = λ̂ × ((k̂−1)/k̂)^(1/k̂)   (mode de la distribution)

  Fenêtre critique (période où h(t) > h̄_moyen) :
    t_critique = λ̂ × (1 − 1/k̂)^(1/k̂)   pour k̂ < 1
    → Identifier [0 ; t_critique] comme la fenêtre d'action prioritaire
```

Stratification et comparaison :

```
FRWR par profil clinique :
  → Par GHM ou CMD du séjour index : AVC, IC, pneumonie, chirurgie ortho...
  → Par niveau de comorbidités (Charlson ≤ 2 vs ≥ 3)
  → Par âge (< 75 ans vs ≥ 75 ans)
  → Par mode de sortie (domicile vs HAD vs SSR) : comparer h(t) selon l'aval

  Comparer les k̂ entre strates :
    → Même k̂, λ̂ différents : même profil de risque, intensité différente
    → k̂ différents : profils de risque structurellement différents
      → Fenêtres de surveillance optimales différentes selon le profil

Score de criticité post-sortie (SCP) :
  SCP(j) = h(j) / h̄_30j   → risque relatif à j jours vs risque moyen sur 30j
  → Identifier les jours où SCP > 2 (risque double de la moyenne)
    → Définir la "période critique" comme l'ensemble {j : SCP(j) > 2}
```

## Utilité

- **Définir les fenêtres temporelles optimales de suivi post-sortie** : si k̂ < 1 avec un pic à J0-J3, l'appel de sortie à J15 est trop tardif — il faut concentrer les ressources de suivi sur J2-J5 ; si k̂ > 1 avec un pic à J14-J21, à l'inverse un appel à J3 est inutile et un appel à J14 est critique ; la FRWR calibre le protocole de suivi post-hospitalisation sur la réalité empirique du service
- **Comparer l'efficacité de différents modes d'aval** : calculer et comparer h(t) pour les patients sortis à domicile, en HAD et en SSR pour un même profil de pathologie — si h(t) est significativement plus faible pour les patients en HAD, c'est une démonstration de la valeur de ce mode d'aval pour réduire la réadmission précoce
- **Prioriser les ressources de suivi post-sortie par profil** : pour un patient IC avec k̂ = 0,55 (risque très précoce), le suivi à J3 est critique ; pour un patient diabétique décompensé avec k̂ = 1,35 (risque progressif), le suivi à J14 est plus important — les appels infirmiers post-sortie peuvent être programmés automatiquement selon le profil de chaque patient
- **Évaluer l'impact d'un programme de sortie structuré** : avant/après la mise en place d'un protocole de sortie (appel J3, consultation J7, HAD de transition), mesurer si λ̂ augmente (délai avant réadmission repoussé) et si k̂ change (modification de la fenêtre critique) — indicateurs de résultat précis du programme
- **Benchmarking ajusté sur la structure du risque** : deux services avec le même taux de réadmission à 30j mais des k̂ différents ont des problèmes différents — l'un doit améliorer la sortie immédiate, l'autre le suivi à distance ; comparer les k̂ entre établissements du GHT révèle des différences d'organisation post-sortie que le taux brut masque

## Sources de Données

- **PMSI MCO RSA** (chaîné par NIR crypté sur 12-24 mois) : DATE_SOR du séjour index, DATE_ENT du séjour de réadmission, MODE_ENTREE (urgences = 8 pour les réadmissions non programmées), DP du séjour index et de réadmission pour la classification étiologique — base suffisante pour le calcul intra-GHT
- **SNDS (PMSI multi-établissements)** : pour capturer les réadmissions dans des établissements hors GHT — sans accès SNDS, les réadmissions dans des établissements concurrents sont manquantes, sous-estimant le taux réel et biaisant potentiellement k̂

## Exemple de Valeurs

- **Insuffisance cardiaque (N=420 séjours index, 30j de suivi)** :
  k̂ = 0,62, λ̂ = 45 jours → distribution fortement décroissante
  h(J1) = 0,082/j, h(J7) = 0,031/j, h(J30) = 0,015/j
  Fenêtre critique [0 ; t_critique] = [0 ; 4,5 jours] (SCP > 2 pendant les 5 premiers jours)
  → Appel infirmier systématique à J2 et J4 recommandé, consultation J7

- **AVC (N=180 séjours, sortie vers domicile ou SSR)** :
  Sortis à domicile : k̂ = 0,71, λ̂ = 38j, Fenêtre critique = 0-6j
  Sortis en SSR neuro : k̂ = 1,12, λ̂ = 52j, Fenêtre critique = 10-20j
  → Le SSR retarde et modifie la structure du risque : risque précoce réduit,
    risque à distance légèrement augmenté (transition SSR→domicile comme nouveau seuil critique)

- **Pneumonie (N=650 séjours)** :
  k̂ = 0,88 (proche de 1) → risque quasi-constant, pas de fenêtre critique nette
  → Pas de stratégie de suivi focalisé sur un moment précis — surveillance continue sur 30j

- **Chirurgie orthopédique (PTH/PTG, N=280 séjours)** :
  k̂ = 1,42 → risque croissant, pic à J18
  → L'appel de sortie habituel à J3 est inadapté — programmer une consultation à J14-J21

## Limites

- La **loi de Weibull** suppose que tous les patients d'un même groupe ont le même profil de risque — hypothèse irréaliste si la cohorte est hétérogène ; une stratification par score de comorbidités ou un modèle de Cox avec covariables est plus adapté pour des analyses fins ; la Weibull simple est un outil de pilotage opérationnel, pas un modèle de prédiction individuelle
- Le **chaînage NIR inter-établissements** requiert un accès SNDS — sans lui, les réadmissions dans des établissements hors GHT ne sont pas capturées, ce qui sous-estime le taux de réadmission réel et peut biaiser k̂ si les réadmissions précoces (J0-J5) vont préférentiellement dans d'autres établissements (urgences de proximité)
- La **période de suivi à 30 jours** est une convention — pour certaines pathologies (cancer, insuffisance rénale chronique), une fenêtre de 90j ou 1 an est plus pertinente cliniquement ; le choix de la fenêtre modifie λ̂ et peut modifier k̂ si le profil de risque change après 30j

## Références

- [Weibull W. — A statistical distribution function of wide applicability, Journal of Applied Mechanics 1951](https://doi.org/10.1115/1.4010337) — article fondateur de la distribution de Weibull
- [Cox D.R. — Regression models and life-tables, JRSS B 1972](https://doi.org/10.1111/j.2517-6161.1972.tb00899.x)
- [Kansagara D. et al. — Risk prediction models for hospital readmission: a systematic review, JAMA 2011](https://doi.org/10.1001/jama.2011.1556) — revue des modèles prédictifs de réadmission
- [van Walraven C. et al. — A meta-analysis of hospital 30-day avoidable readmission rates, J Eval Clin Pract 2011](https://doi.org/10.1111/j.1365-2753.2011.01773.x)
- [HAS — Réadmissions évitables : définition, indicateurs et programmes de prévention (2019)](https://www.has-sante.fr/)
