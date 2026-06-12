# Entropie de Transfert Inter-Services

## Définition

L'entropie de transfert (Transfer Entropy, TE) est une mesure d'information introduite par Thomas Schreiber (2000) pour quantifier le **flux d'information directionnel** entre deux processus stochastiques. Contrairement à la corrélation (symétrique et linéaire) ou à l'information mutuelle (symétrique), l'entropie de transfert est **asymétrique et non-paramétrique** : TE(A→B) ≠ TE(B→A), et elle capture les dépendances non-linéaires.

Formellement :

**TE(A→B) = H(Bₜ₊₁ | Bₜ) − H(Bₜ₊₁ | Bₜ, Aₜ)**

où H est l'entropie de Shannon. TE(A→B) mesure la **réduction d'incertitude sur l'état futur de B apportée par la connaissance de l'état actuel de A, au-delà de ce qu'apporte B lui-même**. En d'autres termes : est-ce que savoir ce qui se passe dans le service A aujourd'hui aide à prédire ce qui se passera dans le service B demain, au-delà de ce que B prédit déjà de lui-même ?

Appliquée aux flux d'activité hospitaliers (admissions, occupations, durées de séjour par service), l'**Entropie de Transfert Inter-Services** (ETIS) identifie les **dépendances causales directionnelles** entre services : le flux de MCO médecine "cause" (au sens de Granger) le flux d'admissions SSR avec un décalage de 3 jours ; la saturation des urgences "cause" le débordement en médecine interne avec un délai de 12 heures. Ces dépendances sont invisibles dans la corrélation classique (qui ne distingue pas A→B de B→A) et constituent la cartographie des **chaînes de propagation des tensions hospitalières**.

## Calcul

Préparation des séries temporelles :

```
Pour chaque service i du GHT, construire une série temporelle à résolution journalière :

  Xᵢ(t) = indicateur du service i au jour t, au choix :
    → Nombre d'admissions du jour
    → Taux d'occupation en fin de journée (depuis loi de Little)
    → DMS moyenne des séjours actifs
    → Nombre de patients en attente de transfert aval

  Source : PMSI RSA agrégé par UM/service et par jour (`date_entree`, `date_sortie`)
  Fenêtre : 2-3 ans (730-1095 jours) pour une estimation robuste
  Granularité : journalière (hebdomadaire si volume insuffisant)

Prétraitement :
  → Normalisation ou discrétisation des séries (obligatoire pour l'approche
    par fréquences conditionnelles)
  → Discrétisation en k = 3-5 bins par quantile :
    [P0-P33 = "faible", P33-P66 = "normal", P66-P100 = "élevé"]
  → Retrait de la saisonnalité (décomposition STL) pour éviter
    que la corrélation saisonnière biais la TE
```

Calcul de l'entropie de transfert :

```
Approche par fréquences conditionnelles (k-nearest neighbors ou histogrammes) :

TE(A→B, lag τ) mesure l'influence de A à l'instant t
sur B à l'instant t+τ (délai τ en jours) :

  TE(A→B, τ) = Σ p(bₜ₊τ, bₜ, aₜ) × log₂[p(bₜ₊τ | bₜ, aₜ) / p(bₜ₊τ | bₜ)]

  → Estimation par comptage de fréquences sur les triplets (bₜ₊τ, bₜ, aₜ)
  → Implémentation : Python (pyinform, IDTxl), R (RTransferEntropy), MATLAB (TRENTOOL)

  Pour chaque paire de services (A, B) et chaque délai τ ∈ {0, 1, 2, …, 14 jours} :
    Calculer TE(A→B, τ) et TE(B→A, τ)

  Délai optimal τ*(A→B) = argmax_τ TE(A→B, τ)
    → Le délai auquel l'influence de A sur B est maximale

Test de significativité :
  TE_surr = distribution nulle obtenue par permutation des séries temporelles
  (rupture de la structure temporelle tout en conservant la distribution marginale)
  p-valeur = P(TE_observée > TE_surr)
  Conserver uniquement les paires avec p < 0.05
```

Matrice d'influence et graphe de propagation :

```
Matrice ETIS [N_services × N_services] :
  ETIS[i][j] = TE(Xᵢ → Xⱼ, τ*(i→j))   pour toutes les paires (i,j)
  → Asymétrique : ETIS[i][j] ≠ ETIS[j][i]
  → Diagonale nulle (un service n'influence pas son futur via lui-même)

Indicateurs synthétiques par service :

  Influence émise (out-TE) :
    TE_out(i) = Σⱼ ETIS[i][j]   → service qui "propage" sa tension aux autres
    → Service avec TE_out élevé = source de tension systémique

  Influence reçue (in-TE) :
    TE_in(i) = Σⱼ ETIS[j][i]   → service qui "absorbe" les tensions des autres
    → Service avec TE_in élevé = récepteur de tension (vulnérable aux perturbations amont)

  Influence nette :
    TE_net(i) = TE_out(i) − TE_in(i)
    → TE_net > 0 : service émetteur net (source dans le réseau de propagation)
    → TE_net < 0 : service récepteur net (puits dans le réseau de propagation)

Graphe orienté de propagation :
  → Nœuds = services du GHT
  → Arcs = paires (i,j) avec ETIS[i][j] significatif
  → Poids de l'arc = valeur de TE(i→j)
  → Délai affiché = τ*(i→j) en jours
  → Visualisation : Gephi, networkx, cytoscape
```

## Utilité

- **Cartographier les chaînes de propagation des tensions** : identifier comment une saturation aux urgences se propage vers la médecine interne (délai τ* = 1 jour), puis vers la gériatrie (τ* = 3 jours), puis vers le SSR (τ* = 7 jours) — la séquence causale invisible dans les corrélations classiques devient explicite dans la matrice ETIS et guide les actions préventives à chaque maillon de la chaîne
- **Distinguer les causes des conséquences** : si TE(MCO→SSR) > TE(SSR→MCO), c'est le flux MCO qui conditionne le SSR (saturation du MCO crée de la demande SSR), non l'inverse — l'asymétrie de l'ETIS identifie la causalité et évite les actions correctives appliquées au mauvais maillon (agir sur le SSR quand c'est le MCO qui cause le problème)
- **Identifier les services amplificateurs vs amortisseurs** : un service avec TE_net élevé (émetteur net) est un amplificateur de tensions dans le système — une perturbation dans ce service se propage à de nombreux autres ; les services avec TE_net très négatif (récepteurs nets) sont des amortisseurs qui absorbent les tensions sans les propager ; prioriser la résilience des services amplificateurs
- **Prévision des tensions à J+τ** : la connaissance de l'état actuel du service A (saturé ou non) prédit l'état du service B dans τ* jours — construire un système d'alerte précoce qui, en détectant une saturation au service A, alerte le service B τ* jours à l'avance pour anticiper la surcharge
- **Évaluation de l'impact des réorganisations sur la propagation** : après la création d'une filière dédiée (unité post-urgences, lit dédié de post-réanimation), mesurer si la TE entre les services concernés a diminué — démonstration que la filière a réellement découplé les flux et réduit la propagation des tensions
- **Outil de gestion de crise en temps réel** : pendant un pic d'activité, la matrice ETIS permet d'anticiper quels services seront touchés en second et troisième rang, et de planifier les renforts de capacité avant que la tension ne se manifeste

## Sources de Données

- **PMSI MCO RSA** : `date_entree` et `date_sortie` par unité médicale (UM) et par jour calendaire — pour construire les séries temporelles X_service(t) d'admissions et d'occupation ; la variable UM du RSA permet de descendre au niveau du service dans les établissements qui codent à ce niveau de granularité
- **PMSI SSR RHS et PMSI HAD** : mêmes séries temporelles pour les services de SSR et HAD — permettant de modéliser les dépendances MCO→SSR et MCO→HAD
- **Données de gestion des urgences** (RPU — Résumé de Passage aux Urgences, OSCOUR) : flux horaire aux urgences — résolution supérieure au PMSI pour le service des urgences, permettant des délais τ < 1 jour dans la matrice ETIS
- **Implémentation** : Python (pyinform pour TE, statsmodels pour le détrending STL, networkx pour la visualisation du graphe) ; R (RTransferEntropy, vars pour les tests de causalité de Granger comme validation) — calcul typiquement en quelques minutes sur 2-3 ans de données journalières pour un GHT de 5-10 services

## Exemple de Valeurs

- **GHT avec 6 services (urgences, MCO méd., MCO chir., réanimation, SSR, gériatrie)** :
  Matrice ETIS (valeurs significatives p<0.05) :

  Urgences → MCO médecine : TE = 0.18, τ* = 1 jour
  MCO médecine → Gériatrie : TE = 0.12, τ* = 3 jours
  MCO médecine → SSR       : TE = 0.09, τ* = 7 jours
  Réanimation → MCO méd.   : TE = 0.07, τ* = 2 jours
  MCO chir. → SSR          : TE = 0.11, τ* = 5 jours
  (toutes les autres paires : TE non significatif)

  TE_net : Urgences = +0.18 (source primaire), MCO méd. = +0.10 (amplificateur)
           SSR = −0.20 (récepteur final), Gériatrie = −0.12 (récepteur secondaire)
  → La chaîne de propagation principale est : Urgences → MCO méd. (J+1)
    → Gériatrie (J+3) et SSR (J+7)

- **Délai de prévision opérationnel** :
  Saturation aux urgences détectée un lundi → alerte MCO médecine pour mardi,
  alerte gériatrie pour jeudi, alerte SSR pour lundi suivant
  → Fenêtre de 7 jours pour préparer des capacités supplémentaires en SSR

- **Impact d'une convention urgences-MCO** :
  Avant convention : TE(urgences→MCO) = 0.18
  Après convention (filière courte dédiée) : TE(urgences→MCO) = 0.07
  → La convention a réduit la propagation de 61% — découplage partiel des flux

## Limites

- L'estimation de l'entropie de transfert par fréquences conditionnelles requiert un **nombre élevé d'observations** pour être statistiquement fiable — avec des séries journalières de 2 ans (730 observations) et 3 niveaux de discrétisation, les fréquences conditionnelles peuvent être estimées sur des cellules très peu peuplées, biaisant la TE ; recommander un minimum de 500-1000 observations par paire et k = 3 bins maximum
- La **discrétisation** des séries continues (passage de valeurs réelles à des bins catégoriels) introduit un biais dépendant du choix des seuils — des seuils par quantiles (P33, P66) sont plus robustes que des seuils absolus, mais le nombre optimal de bins k est difficile à choisir sans validation croisée
- L'entropie de transfert capture les **dépendances à un lag fixé τ** — si la relation causale est décalée de façon variable (parfois 1 jour, parfois 3 jours selon la saison), la TE à un lag unique sous-estimera la dépendance ; le balayage sur τ ∈ {0..14j} résout partiellement ce problème mais augmente le nombre de tests (correction de Bonferroni recommandée)
- L'ETIS mesure les **dépendances observées** dans les données historiques — si une filière dédiée est créée précisément pour éviter une propagation connue, la TE post-filière sera faible non pas parce que la dépendance n'existe plus mécaniquement, mais parce que la filière la prévient ; la distinction entre "dépendance supprimée" et "dépendance masquée" nécessite une analyse de scénario de rupture de la filière

## Références

- [Schreiber T. — Measuring information transfer, Physical Review Letters 2000](https://doi.org/10.1103/PhysRevLett.85.461) — article fondateur de l'entropie de transfert
- [Barnett L. et al. — Granger causality and transfer entropy are equivalent for Gaussian variables, Physical Review Letters 2009](https://doi.org/10.1103/PhysRevLett.103.238701) — lien entre TE et causalité de Granger
- [Granger C.W.J. — Investigating causal relations by econometric models and cross-spectral methods, Econometrica 1969](https://doi.org/10.2307/1912791) — causalité de Granger, précurseur conceptuel de la TE
- [Barabási A.L. — Network Science, Cambridge University Press 2016 : propagation dans les réseaux complexes]
- [DGOS — Gestion des tensions hospitalières : outils de prévision et d'anticipation des pics d'activité (guide ORSAN 2021)](https://solidarites-sante.gouv.fr/)
- [SPF — OSCOUR : réseau de surveillance des urgences, données de flux quotidiens](https://www.santepubliquefrance.fr/)
