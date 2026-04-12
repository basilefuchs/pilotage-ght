# Module d'Young Organisationnel

## Définition

Le **module d'Young** (Thomas Young, 1807) est la constante de rigidité d'un matériau dans son domaine élastique : E = σ/ε, où σ est la contrainte appliquée (force par unité de surface) et ε est la déformation résultante (allongement relatif). Un matériau avec un E élevé (acier : 210 GPa) est rigide — il se déforme peu sous contrainte. Un matériau avec un E faible (caoutchouc : 0,01 GPa) se déforme beaucoup pour la même contrainte mais revient à sa forme initiale (domaine élastique).

La **Capacité de Charge Organisationnelle** (CCO) identifie le seuil K au-delà duquel un service se dégrade — c'est le point de rupture. Le **Module d'Young Organisationnel** (MYO) est complémentaire et distinct : il mesure la **pente de dégradation de la qualité par unité de charge supplémentaire dans le domaine pré-K**, c'est-à-dire avant d'atteindre le seuil. Un service avec un MYO élevé est "rigide" — sa qualité se maintient presque parfaitement jusqu'au seuil K, puis se dégrade brutalement (rupture fragile). Un service avec un MYO faible est "souple" — sa qualité se dégrade progressivement dès les premières tensions, même loin du seuil K (déformation continue).

**MYO = ΔQualité / ΔCharge   dans la zone X < K**

Un service rigide (MYO élevé) est prévisible et robuste en régime normal mais vulnérable aux chocs soudains. Un service souple (MYO faible) se dégrade continûment mais envoie des signaux précoces de tension — il est plus facile à piloter car chaque dégradation est un signal d'action.

## Calcul

```
Données : série temporelle hebdomadaire sur 2-3 ans
  X(t) = taux d'occupation de la semaine t (loi de Little ou journées PMSI / capacité × 7)
  Y(t) = indicateur de qualité de la semaine t :
    Y₁ = DMS observée (normalisation possible sur la DMS du GHM de référence ATIH)
    Y₂ = Taux de complications (DA complication / N séjours)
    Y₃ = Taux de réadmissions à 30j (fenêtre glissante)

Étape 1 — Estimer K depuis le modèle de régression segmentée (cf. CCO) :
  K = breakpoint estimé sur la relation Y ~ X

Étape 2 — Isoler le domaine élastique (X < K) :
  Sous-ensemble de données : toutes les semaines avec X(t) < K_estimé

Étape 3 — Calculer le MYO = pente de la régression linéaire dans ce domaine :
  Y = α + MYO × X   pour X < K
  MYO = β₁ estimé par MCO sur le sous-ensemble {X < K}
  Unité : [unité de Y] par point de taux d'occupation

  Normalisation (pour comparaison inter-indicateurs et inter-services) :
    MYO_norm = MYO × (X_max − X_min) / (Y_max − Y_min)
    → MYO_norm ∈ [0 ; 1]
    → MYO_norm proche de 0 : qualité quasi-insensible à la charge sous K (très rigide)
    → MYO_norm proche de 1 : qualité très sensible à la charge sous K (très souple)
```

Profil élasticité–plasticité complet :

```
Trois zones du comportement mécanique transposées :

Zone 1 — Élastique (X < K, qualité maintenue) :
  MYO = pente faible → service rigide
  → Caractérisée par MYO_norm < 0.15 : qualité quasi-stable

Zone 2 — Élasto-plastique (X ≈ K, qualité se dégrade de façon croissante) :
  → Région autour du breakpoint K (K − 1σ à K + 1σ)
  → Transition entre rigidité et plasticité

Zone 3 — Rupture (X > K) :
  → Pente β₂ ≫ β₁ (cf. CCO) : dégradation rapide et non-linéaire

Indice de fragilité (IF) = β₂ / β₁   (rapport des pentes pré/post K)
  → IF élevé (> 5) : rupture brutale type "fragile" (verre, fonte)
    → Service qui tient bien jusqu'à K puis s'effondre soudainement
  → IF faible (1.5-3) : dégradation progressive type "ductile" (acier doux)
    → Service qui se dégrade graduellement, plus facile à anticiper
  → IF = 1 : pas de changement de pente → pas de breakpoint réel
```

Carte de comportement mécanique des services :

```
Représentation graphique 2D :
  Axe X : MYO_norm (souplesse pré-K : 0 = rigide, 1 = souple)
  Axe Y : K (seuil de rupture : faible = fragile, élevé = robuste)

  Quatre quadrants :
    K élevé + MYO faible : "Acier" — robuste ET rigide (idéal)
    K élevé + MYO élevé  : "Caoutchouc" — robuste mais se dégrade sous charge
    K faible + MYO faible : "Verre" — fragile ET rigide (le plus dangereux :
                             aucun signal avant l'effondrement soudain)
    K faible + MYO élevé  : "Argile" — se dégrade tôt mais de façon progressive
```

## Utilité

- **Distinguer les services fragiles (verre) des services résilients (acier)** : deux services peuvent avoir la même CCO (même K) mais des MYO très différents — le service "acier" maintient sa qualité jusqu'à K et s'effondre brutalement, le service "caoutchouc" envoie des signaux dès les premières tensions ; la carte mécanique des services est un outil de pilotage du risque qualité plus riche que le seul seuil K
- **Définir le niveau d'alerte adapté à chaque profil** : pour un service "verre" (MYO faible, K faible), déclencher l'alerte à 90% de K car aucun signal précurseur ne sera observable ; pour un service "caoutchouc" (MYO élevé), le signal précoce est la dégradation progressive visible dès 70% de K — l'alerte peut être basée sur la dégradation de Y plutôt que sur le niveau de X
- **Guider les investissements organisationnels selon le profil** : un service "verre" bénéficiera d'actions augmentant K (capacité, ressources, processus) car il n'a pas de zone de dégradation progressive à corriger ; un service "argile" bénéficiera d'actions réduisant le MYO (amélioration de la résilience de la qualité en régime tendu : protocoles d'urgence, personnel mobile, lits tampons)
- **Mesurer l'impact des réorganisations sur le profil mécanique** : après une réorganisation, recalculer K et MYO — une bonne réorganisation devrait déplacer le service vers le quadrant "acier" (K élevé + MYO faible) ; une réorganisation qui augmente K mais augmente aussi MYO (service qui se dégrade plus vite avant le seuil) est un compromis à évaluer

## Sources de Données

- **PMSI MCO RSA** : DMS individuelle, complications (DA), réadmissions (chaînage NIR) — pour les variables de qualité Y ; journées d'hospitalisation pour l'approximation du taux d'occupation X (via L = λ×W, loi de Little) sur des séries hebdomadaires de 2-3 ans
- **Capacité installée** : si disponible en gestion interne (nombre de lits ouverts par semaine) pour le dénominateur du taux d'occupation ; sinon, approximer par la capacité nominale constante ou par le nombre de lits "actifs" inféré du PMSI (semaine de référence à activité nominale)

## Exemple de Valeurs

- **Service de chirurgie cardiaque** :
  K = 88%, MYO_norm = 0,08 (rigide), IF = 6,2 (rupture brutale)
  → Profil "verre" : tient jusqu'à 88% sans signal, puis effondrement soudain de la DMS
  → Système d'alerte à déclencher dès 82% (6 points avant K)

- **Service de médecine gériatrique** :
  K = 84%, MYO_norm = 0,42 (souple), IF = 1,8 (dégradation progressive)
  → Profil "caoutchouc" : DMS augmente de +0,8j par 10 points d'occupation dès 70%
  → Signal précoce exploitable : surveiller l'évolution hebdomadaire de la DMS

- **Comparaison inter-services (même GHT)** :
  Chirurgie orthopédique : K=91%, MYO_norm=0,06 → "Acier" (best profile)
  Médecine interne : K=79%, MYO_norm=0,55 → "Argile" (préoccupant)
  Réanimation : K=85%, MYO_norm=0,09, IF=8,3 → "Verre" (risque élevé)

## Limites

- Le MYO ne peut être estimé que si le service a fonctionné dans une plage suffisamment large de taux d'occupation sous K — si le service est quasi-toujours entre 80% et 88%, la pente pré-K est estimée sur une plage de seulement 8 points, avec grande incertitude ; recommander une fenêtre d'observation de 2-3 ans pour maximiser la variabilité naturelle de X
- La séparation entre domaine élastique (X < K) et domaine plastique (X > K) hérite de l'incertitude sur K (cf. limites de la CCO) — une erreur sur K de ±5 points modifie le sous-ensemble de données utilisé pour estimer MYO et peut inverser le profil mécanique d'un service

## Références

- [Young T. — A Course of Lectures on Natural Philosophy and the Mechanical Arts, 1807 : définition originale du module d'élasticité]
- [Muggeo V.M.R. — Estimating regression models with unknown break-points, Statistics in Medicine 2003](https://doi.org/10.1002/sim.1545)
- [Hollnagel E. — Resilience Engineering: Concepts and Precepts, Ashgate 2006 : fragilité vs résilience des systèmes organisationnels complexes]
- [ATIH — Statistiques MCO : séries temporelles d'activité et de DMS par GHM](https://www.atih.sante.fr/)
