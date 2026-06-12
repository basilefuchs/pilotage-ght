# Analyse Spectrale (FFT) des Flux d'Admission

## Définition

La transformée de Fourier rapide (Fast Fourier Transform, FFT — Cooley & Tukey, 1965) décompose n'importe quel signal temporel en une somme de composantes sinusoïdales à différentes fréquences, chacune caractérisée par une **amplitude** (puissance de la composante) et une **phase** (décalage temporel). Appliquée à la série temporelle des admissions hospitalières journalières, elle révèle les **cycles périodiques cachés** dans le flux de patients : cycle hebdomadaire (7 jours), bimensuel, mensuel, saisonnier (trimestriel, annuel) et leurs amplitudes relatives.

L'analyse spectrale répond à une question que les indicateurs de moyenne et d'écart-type ne posent pas : **la variabilité des flux est-elle structurée (périodique, prévisible) ou aléatoire (bruit blanc, imprévisible) ?** Un flux dominé par un cycle à 7 jours est prévisible et actionnable — on sait que les lundis seront creux et les jeudis chargés, et on peut agir. Un flux avec un spectre "plat" (bruit blanc) est fondamentalement imprévisible et ne bénéficiera pas du heijunka.

**X(f) = Σₜ x(t) × e^(−2πift)**

où x(t) est le nombre d'admissions au jour t, X(f) le spectre de fréquence f, et |X(f)|² la puissance spectrale (contribution de la fréquence f à la variabilité totale du flux).

## Calcul

Préparation de la série temporelle :

```
Série d'entrée : x(t) = nombre d'admissions MCO le jour t
  → Source : PMSI RSA, variable `date_entree`, agrégée par jour calendaire
  → Fenêtre recommandée : 2-3 ans (730-1095 jours) pour résoudre les cycles annuels
  → Par unité médicale (UM), service ou établissement selon l'objectif

Prétraitements nécessaires :
  1. Gestion des jours fériés et fermetures (valeurs aberrantes) :
     → Identifier les jours avec x(t) = 0 ou x(t) < P5 historique (fermetures)
     → Interpolation linéaire ou remplacement par la médiane du même jour de la semaine
  2. Détrending (retrait de la tendance) :
     → Ajuster et soustraire la tendance linéaire (évolution de l'activité sur la période)
     → Évite que la dérive lente domine le spectre aux basses fréquences
  3. Fenêtrage (windowing) :
     → Appliquer une fenêtre de Hann ou de Hamming pour réduire les artefacts
       de bord (spectral leakage) dus à la longueur finie de la série
```

Calcul du spectre de puissance :

```
FFT standard :
  X(f) = FFT(x(t))   via numpy.fft.fft (Python) ou fft() (R, MATLAB)
  Densité spectrale de puissance (DSP) :
    PSD(f) = |X(f)|² / N   (normalisée par la longueur de la série N)

Fréquences d'intérêt (en cycles/jour) :
  f₇    = 1/7  ≈ 0.143 c/j   → cycle hebdomadaire (lundi-dimanche)
  f₁₄   = 1/14 ≈ 0.071 c/j   → cycle bimensuel (gardes, plannings)
  f₃₀   = 1/30 ≈ 0.033 c/j   → cycle mensuel
  f₉₁   = 1/91 ≈ 0.011 c/j   → cycle trimestriel (saisonnalité légère)
  f₃₆₅  = 1/365 ≈ 0.003 c/j  → cycle annuel (saisonnalité majeure)

Rapport signal/cycle (contribution de chaque cycle à la variance totale) :
  R₇ = PSD(f₇) / Σ_f PSD(f) × 100   (% de la variance totale expliqué par le cycle à 7j)
  → R₇ > 30% : flux fortement hebdomadaire (cible prioritaire du heijunka)
  → R₇ < 10% : flux peu structuré hebdomadairement (heijunka de faible impact)
```

Indicateurs synthétiques dérivés :

```
Indice de Périodicité Dominante (IPD) :
  IPD = max_f(PSD(f)) / (Σ_f PSD(f) / N_fréquences)
  → Ratio entre la puissance du pic dominant et la puissance spectrale moyenne
  → IPD > 5 : un cycle domine clairement (flux structuré, prévisible)
  → IPD < 2 : spectre plat (flux proche du bruit blanc, peu prévisible)

Fréquence dominante f* :
  f* = argmax_f PSD(f)   → période dominante T* = 1/f* (en jours)

Profil de phase du cycle dominant :
  φ* = arg(X(f*))   → phase du cycle dominant
  → Permet de calculer le jour de la semaine correspondant au pic
  → Ex. : φ* = 3/7 × 2π → pic le mercredi (jour 3 de la semaine)

Ratio basse fréquence / haute fréquence (BF/HF) :
  BF = Σ_{f < 1/30} PSD(f)   (variabilité lente : saisonnalité)
  HF = Σ_{f > 1/7} PSD(f)    (variabilité rapide : bruit, événements aléatoires)
  BF/HF > 1 : la saisonnalité domine la variabilité (gérable par anticipation)
  BF/HF < 1 : le bruit domine (variabilité difficile à anticiper)
```

## Utilité

- **Diagnostic de la structure de variabilité avant toute action de lissage** : avant de lancer un chantier heijunka, l'analyse spectrale détermine si la variabilité est réductible (composante périodique dominante) ou intrinsèque (bruit blanc) — un service avec IPD faible ne bénéficiera pas du lissage des admissions programmées car sa variabilité n'est pas structurée ; l'effort est mieux investi ailleurs
- **Identifier le bon levier d'action selon la fréquence dominante** : un cycle à 7j pointe vers une organisation hebdomadaire des blocs à revoir ; un cycle à 30j pointe vers des effets de fin de mois (objectifs d'activité, renouvellements d'autorisation) ; un cycle à 365j pointe vers la gestion saisonnière des capacités — chaque fréquence a son remède organisationnel
- **Prévision des tensions à court et moyen terme** : la composante périodique identifiée par la FFT est directement utilisable comme signal prédictif — si le cycle à 7j a une amplitude de ±15 admissions et que l'on est en début de semaine "creux", on prévoit une charge élevée dans 3-4 jours ; intégrable dans un outil de prévision de charge hebdomadaire pour la direction des soins
- **Détection des perturbations exogènes par résidu spectral** : soustraire le signal périodique prédit (somme des cycles identifiés) de la série observée laisse un résidu — les pics dans ce résidu correspondent aux événements non périodiques (épidémies, grèves, catastrophes) ; outil complémentaire de l'IRO pour dater et mesurer les chocs
- **Comparaison inter-services et inter-établissements** : le profil spectral (R₇, R₃₆₅, IPD) est un "empreinte spectrale" du service — deux services avec des empreintes similaires ont des structures de variabilité analogues et peuvent partager les mêmes solutions organisationnelles ; deux services avec des empreintes très différentes nécessitent des approches distinctes

## Sources de Données

- **PMSI MCO RSA** : variable `date_entree` (date d'entrée effective) agrégée par jour calendaire sur 2-3 ans — source unique suffisante pour le calcul ; la résolution journalière est indispensable (une agrégation hebdomadaire efface le cycle à 7j)
- **Calendrier des jours fériés et fermetures** (données publiques INSEE) : pour le prétraitement des valeurs aberrantes et l'interprétation des pics spectraux coïncidant avec les jours fériés
- **Données de gestion des blocs opératoires** (logiciel planning) : pour interpréter les cycles identifiés — un pic à f = 1/7 peut correspondre à une fermeture systématique des blocs le lundi ; la comparaison spectre/planning confirme l'origine organisationnelle des cycles
- **Implémentation** : Python (numpy.fft, scipy.signal.periodogram, matplotlib.pyplot.psd), R (stats::spectrum, astsa::mvspec) — calcul rapide même sur des séries de plusieurs années

## Exemple de Valeurs

- **Service de chirurgie orthopédique programmée** :
  R₇ = 48% (le cycle hebdomadaire explique 48% de la variance totale des admissions)
  f* = 1/7 c/j, T* = 7 jours, phase φ* → pic le mercredi
  IPD = 8,2 (cycle hebdomadaire très dominant)
  → Interprétation : le service opère essentiellement en milieu de semaine ;
    les lundis et vendredis sont quasi-vides ; le heijunka a un fort potentiel

- **Service des urgences médicales** :
  R₇ = 12%, R₃₆₅ = 28% (la saisonnalité annuelle domine)
  f* = 1/365 c/j, T* = 365 jours
  IPD = 2,1 (spectre relativement plat, variabilité peu structurée)
  BF/HF = 1,8 (saisonnalité > bruit)
  → Interprétation : la variabilité est surtout saisonnière (hiver/été) ;
    peu de structure hebdomadaire ; le levier d'action est la gestion saisonnière
    des capacités, pas le lissage hebdomadaire

- **Service de médecine interne (CHU)** :
  R₇ = 22%, R₁₄ = 15%, R₃₆₅ = 18%
  IPD = 3,4 (plusieurs cycles coexistent, aucun ne domine nettement)
  → Interprétation : variabilité multi-fréquence ; actions simultanées sur le
    planning hebdomadaire et la gestion saisonnière ; potentiel de lissage modéré

- **Impact de la COVID-19 visible dans le spectre** :
  En 2020-2021, le cycle annuel habituel est remplacé par un pic à f ≈ 1/90 c/j
  (cycle trimestriel lié aux vagues COVID) non présent dans le spectre pré-pandémique
  → La FFT détecte la rupture de structure spectrale comme marqueur d'une perturbation majeure

## Limites

- La FFT suppose la **stationnarité** du signal — que la structure périodique soit stable sur toute la fenêtre d'analyse ; or les flux hospitaliers évoluent (nouveaux services, réorganisations) et les cycles peuvent changer de fréquence ou d'amplitude dans le temps ; utiliser une STFT (Short-Time Fourier Transform) ou une analyse par ondelettes (wavelet transform) pour les séries non-stationnaires
- La **résolution fréquentielle** est inversement proportionnelle à la longueur de la série : avec 1 an de données (365 jours), la résolution est 1/365 c/j — insuffisant pour distinguer un cycle à 28j d'un cycle à 30j ; une fenêtre de 2-3 ans est nécessaire pour une résolution acceptable aux basses fréquences
- Le **spectral leakage** (fuite spectrale) est un artefact inévitable quand les cycles ne sont pas des diviseurs entiers de la longueur de la série — l'énergie d'un pic se "répand" sur les fréquences voisines, pouvant créer de faux pics ; l'application d'une fenêtre (Hann, Hamming) réduit cet artefact mais ne l'élimine pas complètement
- L'analyse spectrale identifie les cycles mais **n'explique pas leurs causes** — un pic à 7j est cohérent avec un cycle hebdomadaire organisationnel mais peut aussi refléter des artefacts de saisie (habitudes de codage concentrées sur certains jours) ; la validation par le planning des blocs et les données RH est nécessaire pour interpréter les pics identifiés

## Références

- [Cooley J.W., Tukey J.W. — An algorithm for the machine calculation of complex Fourier series, Mathematics of Computation 1965](https://doi.org/10.1090/S0025-5718-1965-0178586-1) — article fondateur de l'algorithme FFT
- [Oppenheim A.V., Schafer R.W. — Discrete-Time Signal Processing, Prentice Hall 1999 : référence standard du traitement du signal numérique]
- [Jones S.S. et al. — Forecasting daily patient volumes in the emergency department, Acad Emerg Med 2008](https://doi.org/10.1111/j.1553-2712.2008.00160.x) — application des méthodes spectrales à la prévision des flux aux urgences
- [Boyle J. et al. — Predicting emergency department admissions, Emerg Med J 2012](https://doi.org/10.1136/emj.2010.103531)
- [ANAP — Gestion des flux et prévision de l'activité hospitalière : méthodes quantitatives (2015)](https://www.anap.fr/)
