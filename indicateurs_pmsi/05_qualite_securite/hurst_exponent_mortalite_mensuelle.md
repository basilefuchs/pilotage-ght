# Exposant de Hurst de la Mortalité Mensuelle Ajustée

## Définition

L'exposant de Hurst H est une mesure de la **mémoire longue** d'une série temporelle, introduite par Harold Edwin Hurst (1951) pour modéliser les crues du Nil. Il caractérise le degré de persistance ou d'anti-persistance d'un processus stochastique :

- **H = 0,5** → série de type marche aléatoire (mouvement brownien), aucune mémoire
- **H > 0,5** → série persistante : une période de forte mortalité tend à être suivie d'une autre période forte (dérive lente, signal de fond non maîtrisé)
- **H < 0,5** → série anti-persistante (mean-reverting) : un mois élevé est suivi d'un mois bas (forte régulation, retour à la moyenne)

Appliqué à la **série mensuelle du SMR** (Standardized Mortality Ratio) ou du taux de mortalité ajustée d'un établissement, l'exposant de Hurst répond à une question que ni les cartes de contrôle (CUSUM, EWMA déjà présents dans le dépôt) ni les SMR annuels ne capturent : **la mortalité d'un établissement présente-t-elle une dérive structurelle de fond, masquée par le bruit mois-à-mois ?** Une carte CUSUM détecte une rupture ; H quantifie une **tendance fractale persistante** à plus longue échelle.

Formule symbolique (méthode du Rescaled Range, R/S) :

```
R/S(n) ∝ n^H
log(R(n)/S(n)) = H · log(n) + c
```

où R(n) est l'étendue cumulée et S(n) l'écart-type sur des sous-séries de longueur n. H est estimé par régression de log(R/S) sur log(n).

Méthode alternative recommandée : **DFA (Detrended Fluctuation Analysis)** de Peng et al. (1994), plus robuste aux non-stationnarités locales.

## Calcul

```
Étape 1 — Construction de la série mensuelle ajustée :
  Pour chaque mois m de la période d'observation (recommandé : 36 à 60 mois) :
    - Numérateur : nombre de décès intra-hospitaliers (mode_sort = 9) du mois m
    - Dénominateur : somme des probabilités de décès attendues par séjour
      (modèle logistique pré-calibré sur GHM, âge, Charlson, mode d'entrée)
    - SMR_m = Σ décès_observés / Σ décès_attendus
  Optionnel — désaisonnaliser la série (STL ou différenciation saisonnière)
  pour éviter les artefacts saisonniers (mortalité hivernale grippe/COVID)

Étape 2 — Estimation de H par DFA :
  1. Intégrer la série centrée :
     Y(k) = Σ_{i=1..k} (SMR_i − moyenne(SMR))
  2. Découper Y en boîtes de longueur n (n ∈ {4, 8, 16, 32})
  3. Dans chaque boîte, ajuster une tendance linéaire locale Y_tend(k)
  4. Calculer la fluctuation détrendée :
     F(n) = sqrt( (1/N) · Σ (Y(k) − Y_tend(k))² )
  5. Si F(n) ∝ n^H → régression log(F(n)) ~ H · log(n)
  6. H = pente de la régression

Étape 3 — Test de significativité :
  - Bootstrap : générer 1000 séries permutées, calculer H sur chacune
  - Calculer l'intervalle de confiance à 95 % de H sous H0 (= 0,5)
  - Conclure : persistance significative si H > borne_sup_IC95
```

Implémentation R disponible via le package `pracma::hurstexp()` ou `nonlinearTseries::dfa()`.

## Utilité

- **Détecter les dérives qualité lentes invisibles aux SPC classiques** : une carte CUSUM signale une rupture ponctuelle ; H quantifie une dérive de fond persistante (ex. perte progressive d'expertise, vieillissement structurel du recrutement) que la moyenne mobile lisse
- **Distinguer "bruit" et "signal" dans la variabilité mensuelle** : un établissement avec SMR moyen acceptable mais H = 0,75 a une mortalité dont les fluctuations sont **structurées** (auto-corrélées) — chaque mauvais mois prédit le suivant, ce qui justifie une intervention immédiate
- **Pilotage long-terme à l'échelle du GHT** : H comparé entre établissements du GHT identifie ceux dont la performance mortalité est intrinsèquement instable vs aléatoire (cible des plans qualité pluriannuels)
- **Évaluation rétrospective d'une intervention qualité** : avant/après un plan d'action, H devrait baisser (moins de persistance = système mieux régulé) — métrique complémentaire aux comparaisons de moyennes
- **Prévention des "epidemic clusters"** : un H élevé est un signal précoce de regroupement d'événements défavorables (clusters d'infections nosocomiales, d'erreurs médicamenteuses) avant que la moyenne ne soit affectée
- **Communication ARS / certification HAS** : un établissement présentant H ≈ 0,5 démontre un système qualité auto-régulé ; H > 0,7 alerte sur des problèmes structurels

## Sources de Données

- **PMSI MCO RSA** : mode de sortie (`MODE_SORT = 9` pour décès), dates de sortie pour le calage mensuel, GHM, âge, sexe et diagnostics (DP + DAS) pour le calcul du SMR attendu
- **Historique 36 à 60 mois minimum** : la fiabilité de l'estimation de H dégrade en deçà ; idéalement 60 mois pour stabilité statistique de la régression log-log
- **Modèle d'ajustement du SMR** : régression logistique pré-calibrée sur la base nationale (ATIH ou benchmark GHT), variables au minimum : GHM (ou CMD), âge en classes, score de Charlson dérivé des DAS, mode d'entrée, durée de séjour
- **Référentiel CIM-10 ATIH** en vigueur sur la période — toute mise à jour majeure du codage doit faire l'objet d'une harmonisation rétroactive avant calcul de H

## Exemple de Valeurs

- **CHU stable, plan qualité ancien** : H ≈ 0,50–0,55 (système auto-régulé, fluctuations aléatoires)
- **CH général en transition managériale** : H ≈ 0,65–0,75 (persistance modérée, dérive lente identifiable)
- **Établissement en crise structurelle (vacances PH, sous-effectif chronique)** : H > 0,75 (forte mémoire longue, mauvais mois s'enchaînent)
- **Service de chirurgie post-réorganisation réussie** : transition observée H = 0,72 → 0,52 sur 24 mois (effet du plan d'action)
- **Seuils d'alerte indicatifs** :
  - H ∈ [0,45 ; 0,60] → fonctionnement nominal
  - H ∈ [0,60 ; 0,70] → vigilance, RMM ciblée
  - H > 0,70 → audit qualité approfondi, recherche de cause structurelle
- *Ordre de grandeur expert, non sourcé sur cohorte française — à calibrer sur historique GHT.*

## Limites

- **Volume minimal de séjours par mois** : pour un établissement < 500 séjours/mois, le SMR mensuel est dominé par la variance d'échantillonnage et H devient peu interprétable ; agréger trimestriellement si nécessaire
- **Sensibilité aux ruptures de codage** : un changement de version PMSI (mise à jour de la classification GHM, nouvelles règles de groupage) introduit un saut artificiel dans la série qui inflate H — toute série traversant une rupture doit être segmentée
- **Hypothèse de stationnarité** : la version simple R/S est biaisée si la série a une tendance ; DFA corrige partiellement mais ne supprime pas les non-stationnarités fortes (effets COVID, restructurations majeures)
- **Estimation difficile sur séries courtes** : 24 mois → IC95 sur H très large ; 60 mois recommandé pour distinguer significativement H = 0,55 de H = 0,50
- **Indicateur abstrait pour les équipes cliniques** : nécessite une présentation pédagogique (graphique log-log, comparaison avec marche aléatoire) — ne se substitue pas aux indicateurs d'usage opérationnel mais les complète
- **Pas standardisé internationalement en santé** : peu d'utilisation pour la qualité hospitalière à ce jour, ce qui complique les comparaisons inter-pays et freine la diffusion réglementaire

## Références

- [Hurst H.E. — Long-term storage capacity of reservoirs, Trans. Am. Soc. Civ. Eng. 1951 : article fondateur de l'analyse R/S](https://doi.org/10.1061/TACEAT.0006518)
- [Peng C.K. et al. — Mosaic organization of DNA nucleotides, Phys. Rev. E 1994 : introduction du Detrended Fluctuation Analysis (DFA)](https://doi.org/10.1103/PhysRevE.49.1685)
- [Mandelbrot B.B., Wallis J.R. — Robustness of the rescaled range R/S in the measurement of noncyclic long-run statistical dependence, Water Resources Research 1969](https://doi.org/10.1029/WR005i005p00967)
- [Goldberger A.L. et al. — Fractal dynamics in physiology: alterations with disease and aging, PNAS 2002 — application DFA aux séries biomédicales (PMID:11875196)](https://pubmed.ncbi.nlm.nih.gov/11875196/)
- [Spiegelhalter D.J. — Funnel plots for comparing institutional performance, Stat. Med. 2005 : référence des méthodes SPC en qualité hospitalière, complémentaire à H](https://doi.org/10.1002/sim.1970)
- [ATIH — Manuel des GHM et guide méthodologique MCO en vigueur](https://www.atih.sante.fr/)
