# Value at Risk des Événements Indésirables Graves (VaR-EIG)

## Définition

Adapté de la gestion des risques financiers, le Value at Risk (VaR) des événements indésirables graves (EIG) est le taux mensuel d'événements indésirables au-delà duquel un établissement ne devrait se trouver que dans 5% des mois (VaR à 95%), ou 1% des mois (VaR à 99%). En finance, la VaR répond à : "Quelle est la perte maximale que l'on peut subir avec une probabilité de 95% sur une période donnée ?" Appliqué à la sécurité des patients : "Quel est le taux mensuel d'EIG que l'établissement ne devrait dépasser qu'une fois tous les 20 mois (VaR 95%) ou une fois tous les 100 mois (VaR 99%) ?"

La rupture conceptuelle par rapport aux indicateurs habituels (taux annuels ou trimestriels comparés à une moyenne) est fondamentale : la VaR-EIG passe d'une gestion **réactive** (on constate après coup que le mois a été mauvais) à une gestion **probabiliste du risque** (on définit à l'avance les seuils statistiques qui déclenchent une investigation, indépendamment du fait que le résultat soit "mieux que l'an dernier"). Elle permet également de quantifier le **risque résiduel** : un établissement avec un taux moyen d'EIG conforme aux benchmarks peut néanmoins avoir une variance élevée (grande variabilité mensuelle) qui génère des pics dangereux. La VaR capture ce risque que les indicateurs moyens ignorent.

Calculable depuis le PMSI MCO sur un historique de 24-36 mois, sur la base des EIG tracés en CIM-10 (PSI-90 AHRQ, complications codées, décès inattendus).

## Calcul

Construction de la distribution historique des EIG :

```
Étape 1 — Série temporelle mensuelle des EIG :
  Pour chaque mois m de la période d'observation (recommandé : 36 mois minimum) :
    EIG_m = nombre d'événements indésirables graves du mois m

  Définition des EIG (à adapter selon l'objectif) :
    Option A — EIG "PSI-90 composite" :
      Séjours avec ≥ 1 code PSI-90 (complications codées en DA du RSA)
      : embolie pulmonaire post-op (I26+Z87.39), sepsis post-proc (T81.4),
        pneumothorax iatrogène (J95.0), chute en service (W00-W19+Y93.89), etc.
    Option B — EIG "graves" (réservé aux événements les plus sévères) :
      Décès inattendus (mode_sort=9 hors GHM palliatifs, oncologiques, SMR)
      + Réinterventions urgentes (CCAM reprise dans les 48h)
      + Transferts non programmés en réanimation (PMSI SSR/MCO mode_entrée=6 urgent)

  Taux mensuel d'EIG :
    Taux_EIG_m = EIG_m / Nombre_séjours_m × 1 000  (pour 1 000 séjours)
```

Calcul de la VaR-EIG :

```
Étape 2 — Modélisation statistique de la distribution :
  Méthode 1 — Non paramétrique (recommandée si N_mois ≥ 36) :
    → Trier les 36 valeurs Taux_EIG_m par ordre croissant
    → VaR_95% = percentile 95 de la distribution observée
                = 34e valeur sur 36 (pour VaR mensuelle à 95%)
    → VaR_99% = percentile 99

  Méthode 2 — Paramétrique (si N_mois < 36) :
    → Modéliser la distribution des EIG mensuels comme Poisson(λ) ou
      Binomiale Négative(r, p) (la Binomiale Négative est préférable si
      surdispersion observée : Var(EIG_m) > E(EIG_m))
    → λ = taux moyen d'EIG par mois sur la période
    → VaR_95% = quantile 95 de la distribution ajustée

Seuil de déclenchement :
  → Si Taux_EIG_mois_courant > VaR_95% : déclenchement d'une revue de morbi-mortalité
    ciblée sur les EIG du mois
  → Si Taux_EIG_mois_courant > VaR_99% : alerte direction / CME immédiate
```

Indicateurs dérivés :

```
Expected Shortfall (ES) ou Conditional VaR :
  ES_95% = E[Taux_EIG | Taux_EIG > VaR_95%]
  = taux moyen d'EIG dans les 5% de mois les plus mauvais
  → Mesure la sévérité attendue quand on franchit le seuil VaR
  → Préférable à la VaR seule pour les décisions de provisionnement (ressources
    supplémentaires à prévoir pour les "mauvais mois")

Volatilité σ des EIG mensuels :
  σ = écart-type de la série Taux_EIG_m
  → Fort σ = grande variabilité = risque de pics même si la moyenne est bonne
  → Faible σ = performance stable et prévisible

VaR par service ou spécialité :
  → Calculer une VaR_95% séparément pour chaque service
  → Permet d'identifier les services à faible taux moyen mais haute volatilité
```

## Utilité

- **Passage d'une culture réactive à une culture proactive du risque patient** : définir à l'avance les seuils statistiques de déclenchement des revues de morbi-mortalité plutôt que de réagir intuitivement à des variations perçues — outil structurant pour les CME et les comités de gestion des risques
- **Détection des services à haute variance cachée** : un service avec un taux moyen d'EIG conforme au benchmark mais une VaR_95% très élevée (forte variabilité mensuelle) est un service instable — sa conformité annuelle masque des pics mensuels dangereux que la VaR révèle
- **Calibration des ressources de sécurité** : l'Expected Shortfall (taux moyen dans les pires mois) permet de dimensionner les ressources supplémentaires (personnel de renfort, capacités de réanimation) pour les mois statistiquement défavorables, plutôt que de raisonner sur la moyenne
- **Objectif de réduction du risque quantifié** : remplacer "réduire les événements indésirables" (objectif flou) par "ramener la VaR_95% de 8,2 ‰ à 5,0 ‰ d'ici 2 ans" (objectif SMART avec cible chiffrée et horizon temporel)
- **Communication avec les tutelles** : la VaR est un indicateur de maturité de la gestion des risques — des établissements capables de présenter leur profil VaR-EIG à l'ARS ou à la HAS démontrent une approche statistiquement rigoureuse de la sécurité
- **Benchmarking inter-établissements du GHT sur le profil de risque** : comparer non seulement les taux moyens d'EIG mais aussi les volatilités et les VaR permet d'identifier les établissements "stables mais moyens" vs "excellents mais imprévisibles"

## Sources de Données

- **PMSI MCO RSA** : diagnostics associés (DA) CIM-10 pour les complications et EIG intra-séjour (liste PSI-90 AHRQ ou liste ATIH), actes CCAM pour les réinterventions urgentes, mode de sortie = 9 pour les décès, dates d'hospitalisation pour la série temporelle mensuelle, NIR crypté pour les chaînages
- **PMSI tous champs** (MCO + SSR + HAD) : chaînage NIR pour inclure dans les EIG les complications survenant après la sortie MCO (ex. décès à J3 post-sortie après réhospitalisation en urgence)
- **Historique de 36 mois minimum** : indispensable pour la stabilité statistique de la VaR non paramétrique — une période plus courte requiert l'approche paramétrique (modèle de Poisson ou Binomiale Négative)

## Exemple de Valeurs

- **Service de chirurgie digestive (example fictif, 200 séjours/mois)** :
  - Taux moyen EIG : 6,5 ‰ (13 EIG/mois en moyenne)
  - Écart-type mensuel σ : 2,1 ‰
  - VaR_95% : 10,2 ‰ (dépassement attendu une fois tous les 20 mois)
  - VaR_99% : 12,8 ‰ (dépassement attendu une fois tous les 100 mois)
  - Expected Shortfall (ES_95%) : 11,4 ‰ (taux moyen dans les pires mois)
- **Seuil de déclenchement RMM** : si taux_EIG > VaR_95% = 10,2 ‰ ce mois-ci → RMM obligatoire dans les 15 jours
- **Benchmark industriel équivalent** : en aviation, la VaR_99.9% des incidents est définie réglementairement et déclenche des audits de sécurité systémiques

## Limites

- La robustesse statistique de la VaR dépend directement de la longueur de la série temporelle : avec < 24 mois d'historique, les percentiles sont instables et la VaR non paramétrique est peu fiable — l'approche paramétrique (Poisson/NB) est plus robuste mais nécessite une validation de la distribution choisie
- La VaR suppose que la distribution des EIG reste stationnaire dans le temps — un changement structurel (nouveau chirurgien, rénovation du bloc, épidémie de COVID) modifie la distribution et invalide les seuils calculés sur l'historique antérieur ; la VaR doit être recalculée après chaque rupture structurelle identifiée
- Le choix de la définition des EIG (PSI-90, décès inattendus, réinterventions) influence fortement les valeurs de VaR calculées — une définition très large (nombreux EIG inclus) donnera une VaR plus haute et des déclenchements plus fréquents ; la définition doit être documentée et stable dans le temps pour la comparabilité
- Indicateur qui peut sembler complexe pour les équipes médicales sans formation en statistiques — nécessite un travail de pédagogie et de présentation visuelle (courbe de distribution, représentation des percentiles) pour être opérationnel dans un comité de gestion des risques

## Références

- [Jorion P. — Value at Risk: The New Benchmark for Managing Financial Risk (3e éd.), McGraw-Hill 2006 : définition et méthodologies VaR en finance]
- [Artzner P. et al. — Coherent measures of risk, Mathematical Finance 1999 : fondements théoriques de la VaR et de l'Expected Shortfall](https://doi.org/10.1111/1467-9965.00068)
- [Runciman W. et al. — Towards an international classification for patient safety, Int J Qual Health Care 2009 : taxonomie des événements indésirables en santé](https://doi.org/10.1093/intqhc/mzp026)
- [AHRQ — Patient Safety Indicators v2024 : liste des complications et EIG codables en PMSI](https://qualityindicators.ahrq.gov/)
- [HAS — Méthode d'analyse des événements indésirables graves (EIG) en établissements de santé (2021)](https://www.has-sante.fr/)
