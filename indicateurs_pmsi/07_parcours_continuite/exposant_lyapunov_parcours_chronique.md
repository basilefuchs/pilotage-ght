# Exposant de Lyapunov du Parcours Chronique

## Définition

L'exposant de Lyapunov (Aleksandr Lyapunov, 1892) est le concept central de la théorie du chaos déterministe. Il mesure le **taux moyen de divergence exponentielle** entre deux trajectoires d'un système dynamique qui partent de conditions initiales infiniment proches. Un exposant positif signifie que des conditions initiales quasiment identiques génèrent des trajectoires qui s'éloignent exponentiellement avec le temps — le système est chaotique et imprévisible à long terme. Un exposant négatif ou nul signifie que les trajectoires convergent — le système est attracteur et prévisible.

**λ_L = lim_{t→∞} (1/t) × ln(|δ(t)| / |δ(0)|)**

où δ(0) est la divergence initiale entre deux trajectoires et δ(t) la divergence au temps t.

Appliqué aux parcours de soins chroniques, l'**Exposant de Lyapunov du Parcours Chronique** (ELPC) mesure dans quelle mesure deux patients ALD aux profils initiaux très similaires (même pathologie, même âge, même sévérité initiale) voient leurs trajectoires de soins **diverger progressivement** ou au contraire **converger vers un même régime de suivi**. Un ELPC élevé signale un parcours chaotique, sensible aux conditions initiales et aux petites perturbations — le système de soins n'est pas attracteur, les patients similaires ne convergent pas vers le même suivi. Un ELPC négatif ou proche de 0 signale un parcours régulier et prévisible — les patients similaires reçoivent des soins similaires, le système converge vers un état de référence.

L'analogie avec le chaos est directe : de même qu'un météorologue ne peut prévoir le temps au-delà de 15 jours quelle que soit la précision de ses mesures initiales (sensibilité aux conditions initiales = chaos), un système de soins avec ELPC élevé est fondamentalement imprévisible — le parcours d'un patient donné ne peut être anticipé même en connaissant parfaitement son profil initial.

## Calcul

Représentation du parcours comme trajectoire dans un espace d'état :

```
Pour chaque patient i atteint d'une ALD (ex. diabète type 2) :
  Définir l'espace d'état à k dimensions, décrit à chaque instant t (mensuel) :

  État_i(t) = [
    x₁(t) : nombre de consultations cumulées (type, fréquence)
    x₂(t) : observance médicamenteuse (PDC, Proportion of Days Covered)
    x₃(t) : dernier résultat biologique clé (HbA1c, INR, créatinine...)
    x₄(t) : nombre d'hospitalisations cumulées
    x₅(t) : score de synchronisation SSP (si calculé)
  ]

  Trajectoire : séquence temporelle {État_i(1), État_i(2), …, État_i(T)}
  Longueur : T = 24-36 mois (suffisant pour mesurer la divergence)

  Sources des composantes :
    x₁, x₃ : DCIR ER_PRS_F (consultations), ER_BIO_F (biologie)
    x₂      : DCIR ER_PHA_F (dispensations, calcul du PDC)
    x₄      : PMSI MCO RSA (séjours MCO avec le diagnostic ALD)
```

Algorithme de calcul de l'ELPC (méthode des voisins proches) :

```
Étape 1 — Identifier les paires de patients "voisins initiaux" :
  Pour chaque patient i, trouver son voisin le plus proche j au temps t=0 :
    δ₀(i,j) = D_M(État_i(0), État_j(0))   ← distance de Mahalanobis initiale
  Ne conserver que les paires avec δ₀ < ε  (ε = seuil de proximité initiale,
  ex. percentile 5 des distances dans la cohorte)

Étape 2 — Mesurer la divergence des trajectoires au cours du temps :
  Pour chaque paire (i,j) et chaque instant t ∈ {1, 2, …, T} :
    δₜ(i,j) = D_M(État_i(t), État_j(t))   ← distance entre les deux trajectoires à t

Étape 3 — Estimer l'exposant de Lyapunov :
  Pour chaque paire (i,j) :
    λ_L(i,j) = (1/T) × ln(δ_T(i,j) / δ_0(i,j))

  ELPC = médiane(λ_L(i,j)) sur toutes les paires initiales proches
    → λ_L > 0 : trajectoires divergentes (chaos, imprévisibilité)
    → λ_L ≈ 0 : trajectoires parallèles (ni convergence ni divergence)
    → λ_L < 0 : trajectoires convergentes (attracteur, régularité)

  Temps de Lyapunov (horizon de prévisibilité) :
    T_Lyapunov = 1 / |λ_L|  (en mois)
    → Si λ_L = 0.1 /mois : le parcours est prévisible sur ~10 mois
    → Si λ_L = 0.4 /mois : le parcours est prévisible sur ~2.5 mois seulement
```

Analyse spatiale de l'espace d'état :

```
Attracteur du parcours (si λ_L < 0) :
  → L'attracteur est l'état vers lequel les trajectoires convergent
  → Calculer le centroïde des états à t = T : μ_T = moyenne(État_i(T))
  → μ_T représente le "bon régime de suivi" vers lequel le système attire les patients
  → Comparer μ_T aux recommandations HAS : si μ_T correspond au suivi optimal,
    le système est à la fois stable ET conforme aux recommandations

ELPC par sous-groupe :
  → Calculer l'ELPC séparément pour les patients avec/sans médecin traitant déclaré,
    avec/sans programme SOPHIA, en zone urbaine/rurale
  → Identifier les facteurs organisationnels qui réduisent l'ELPC
    (= augmentent la régularité et la prévisibilité du parcours)
```

## Utilité

- **Mesurer la régularité systémique du parcours indépendamment de sa conformité** : deux systèmes de soins peuvent produire des parcours conformes aux recommandations mais avec des ELPC très différents — l'un converge régulièrement vers le bon suivi (ELPC < 0), l'autre y parvient de façon chaotique et non reproductible (ELPC > 0) ; le second est fragile car une petite perturbation (déménagement du médecin traitant, changement de pharmacie) peut faire basculer le parcours vers un mauvais régime
- **Évaluer la robustesse d'un programme de suivi structuré** : un programme de coordination (SOPHIA pour les diabétiques, télésuivi pour l'insuffisance cardiaque) devrait réduire l'ELPC de la cohorte — il "attire" les patients vers un régime de suivi régulier et réduit la sensibilité aux perturbations initiales ; l'évolution de l'ELPC avant/après l'inclusion est un indicateur de robustesse du programme
- **Identifier les territoires à parcours chaotiques** : l'ELPC peut être calculé par territoire (bassin de vie, département) pour comparer la régularité des parcours chroniques sur le territoire du GHT — un territoire avec ELPC élevé n'a pas d'attracteur de soins fort (absence de médecin traitant déclaré, faible densité de spécialistes, pas de CPTS) ce qui rend les parcours imprévisibles et non reproductibles
- **Prédire les patients à risque de rupture de parcours** : les patients dont la trajectoire individuelle diverge rapidement de celle de leurs voisins initiaux (λ_L individuel élevé) sont les patients les plus sensibles aux perturbations — candidats prioritaires à une intervention préventive de coordination avant la rupture effective
- **Outil de recherche sur les déterminants de la stabilité du parcours** : l'ELPC permet d'étudier quels facteurs organisationnels (densité médicale, outils de coordination, caractéristiques socio-économiques du territoire) sont associés à des parcours attracteurs — contribue à la recherche en organisation des soins sur les conditions d'un suivi chronique stable

## Sources de Données

- **DCIR ER_PRS_F** : consultations médicales avec date, RPPS, spécialité — pour reconstituer x₁(t) (fréquence des consultations dans le temps) et calculer les intervalles entre consultations
- **DCIR ER_PHA_F** : dispensations médicamenteuses avec date et code ATC — pour calculer x₂(t) (PDC mensuel, observance médicamenteuse dans le temps)
- **DCIR ER_BIO_F** : actes biologiques clés avec résultats (HbA1c, INR, créatinine, BNP) et date — pour x₃(t) (évolution du marqueur de suivi biologique)
- **PMSI MCO RSA** : séjours hospitaliers avec date d'entrée et diagnostic principal/associés — pour x₄(t) (accumulation d'hospitalisations, événements aigus intercurrents)
- **IR_IMB_R** : ALD actives par NIR et date d'ouverture — pour identifier la cohorte de patients ALD à inclure et la date de début de trajectoire (t=0)
- **Chaînage SNDS par NIR crypté** : nécessaire pour reconstituer la trajectoire longitudinale multi-sources sur 24-36 mois

## Exemple de Valeurs

- **Cohorte diabète type 2 avec médecin traitant déclaré et programme SOPHIA** :
  ELPC médian ≈ −0,05 à −0,15 /mois (attracteur stable)
  T_Lyapunov ≈ 7-20 mois (horizon de prévisibilité confortable)
  → Les patients convergent vers un régime de suivi trimestriel régulier

- **Cohorte diabète type 2 sans médecin traitant en zone sous-dotée** :
  ELPC médian ≈ +0,10 à +0,25 /mois (trajectoires divergentes)
  T_Lyapunov ≈ 4-10 mois (parcours imprévisible à court terme)
  → Deux patients similaires au départ ont des suivis totalement différents à 12 mois

- **Insuffisance cardiaque avec télésuivi** vs **sans télésuivi** :
  Avec télésuivi : ELPC ≈ −0,10 /mois ; Sans télésuivi : ELPC ≈ +0,08 /mois
  Différence = −0,18 /mois → le télésuivi transforme un système chaotique
  en système attracteur (réduction de l'imprévisibilité du parcours)

- **ELPC par territoire** :
  Zones rurales avec déserts médicaux : ELPC ≈ +0,15 à +0,30 /mois
  Zones urbaines avec CPTS active : ELPC ≈ −0,05 à +0,05 /mois

## Limites

- Le calcul de l'ELPC requiert des **trajectoires longitudinales longues** (24-36 mois minimum) et un **nombre suffisant de paires de voisins proches** — pour les pathologies rares ou les cohortes petites, le nombre de paires avec δ₀ < ε peut être trop faible pour une estimation robuste ; recommander une cohorte minimale de 200 patients par sous-groupe analysé
- La **définition de l'espace d'état** (choix des variables et de leur pondération) influence fortement la valeur de l'ELPC — deux chercheurs utilisant des variables légèrement différentes obtiendront des ELPC différents ; la standardisation de l'espace d'état par pathologie (diabète, IC, BPCO) est un prérequis à la comparabilité inter-études
- L'ELPC ne distingue pas le **chaos déterministe** (système gouverné par des règles complexes mais déterministes) de la **variabilité stochastique** (aléatoire pure) — or les parcours de soins sont soumis aux deux ; une ELPC élevée peut refléter un système chaotique réel ou simplement beaucoup de bruit de mesure dans les données DCIR (dispensations non représentatives de la consommation réelle)
- L'interprétation clinique de l'ELPC nécessite une **expertise en systèmes dynamiques** peu répandue dans les équipes hospitalières — l'indicateur est davantage adapté à la recherche en organisation des soins qu'au tableau de bord opérationnel ; le **Temps de Lyapunov** (T_L = 1/|λ_L|, exprimé en mois d'horizon de prévisibilité) est une traduction plus accessible pour les non-spécialistes

## Références

- [Lyapunov A.M. — The General Problem of the Stability of Motion, 1892, traduit en anglais 1992 : fondements mathématiques des exposants de Lyapunov]
- [Lorenz E.N. — Deterministic nonperiodic flow, Journal of the Atmospheric Sciences 1963](https://doi.org/10.1175/1520-0469(1963)020%3C0130:DNF%3E2.0.CO;2) — découverte de la sensibilité aux conditions initiales (effet papillon)
- [Kantz H., Schreiber T. — Nonlinear Time Series Analysis, Cambridge University Press 2004 : méthodes pratiques d'estimation des exposants de Lyapunov sur données réelles]
- [Goldberger A.L. et al. — Fractal dynamics in physiology: alterations with disease and aging, PNAS 2002](https://doi.org/10.1073/pnas.012579499) — application des concepts de chaos et complexité à la physiologie et à la maladie chronique
- [Lipsitz L.A. — Dynamics of stability: the physiologic basis of functional health and frailty, J Gerontol Biol Sci 2002](https://doi.org/10.1093/gerona/57.3.B115) — concept de perte de complexité et de variabilité dans le vieillissement et la maladie chronique
- [CNAM — Programme Sophia : évaluation de l'impact sur le suivi des patients diabétiques](https://www.ameli.fr/)
