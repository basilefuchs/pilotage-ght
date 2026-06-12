# Score de Succession du Mix GHM

## Définition

La succession écologique est le processus par lequel la composition d'un écosystème se transforme au fil du temps, des espèces pionnières vers un état climacique stable. Frederic Clements (1916) a formalisé ce concept en quatre stades — colonisation, croissance, climax, sénescence — et Horn (1975) a modélisé les transitions entre stades comme une chaîne de Markov. Ces dynamiques sont désormais appliquées à l'analyse de portefeuilles en biologie évolutive et en stratégie d'entreprise (Henderson 1970, matrice BCG).

Transposé au portefeuille d'activités hospitalières, le score de succession du mix GHM classifie chaque **famille GHM** active dans un établissement en un stade successoral selon la dynamique de sa part d'activité sur 8 trimestres glissants :

| Stade | Critère opérationnel | Analogie écologique |
|---|---|---|
| **Pionnier** | GHM apparu dans les 4 derniers trimestres, part < 2% | Espèce colonisatrice |
| **Croissance** | Δpart > +0,5 pp/trimestre (tendance linéaire sur 4 trimestres), part < médiane nationale | Espèce en expansion |
| **Climax** | part stable (|pente| < 0,3 pp/trimestre), part ≥ 5% | Espèce dominante stable |
| **Déclin** | Δpart < −0,5 pp/trimestre (tendance linéaire sur 4 trimestres) | Espèce en régression |
| **Relique** | GHM présent depuis > 8 trimestres, part < 1%, tendance nulle | Espèce résiduelle |

L'intérêt analytique est fondamentalement différent des indicateurs de diversité (entropie de Shannon) ou de concentration (indice de spécialisation) : ces derniers décrivent l'état statique du casemix ; le score de succession décrit sa **dynamique directionnelle** — quelles activités sont en conquête, lesquelles sont stables, lesquelles sont en train de disparaître.

## Calcul

Source : PMSI MCO RSA — variables `ghm2` (6 caractères, racine = 5 premiers), `finessgeo`, date d'entrée agrégée par trimestre.

```
Population : tous séjours MCO d'un établissement sur les 8 derniers trimestres

Étape 1 — Agrégation trimestrielle par famille GHM (racine 5 caractères) :
  N_f_q  = count(RSA | GHM_racine = f, trimestre = q)
  N_tot_q = count(RSA | trimestre = q)
  part_f_q = N_f_q / N_tot_q × 100  [en %]

Étape 2 — Calcul de la tendance sur 4 trimestres (fenêtre glissante q-3 à q) :
  pente_f = coefficient β de régression linéaire de part_f sur les 4 derniers trimestres
  [régression OLS : part_f_q = α_f + β_f × t + ε, t ∈ {1,2,3,4}]
  Unité : pp/trimestre (points de pourcentage par trimestre)

Étape 3 — Classification par stade (priorité décroissante) :
  Si ancienneté_f < 4 trimestres ET part_f_q < 2%       → Pionnier
  Si pente_f > +0,5 ET part_f_q < médiane(part_f_panel) → Croissance
  Si part_f_q ≥ 5% ET |pente_f| ≤ 0,3                  → Climax
  Si pente_f < −0,5                                      → Déclin
  Si ancienneté_f ≥ 8 trimestres ET part_f_q < 1%
    ET |pente_f| ≤ 0,3                                   → Relique
  Sinon                                                   → Intermédiaire (non classé)

  Cas limite — double critère satisfait :
    Priorité : Pionnier > Déclin > Croissance > Climax > Relique

Étape 4 — Score de succession de l'établissement :
  N_pionniers  = count(f | stade = Pionnier)
  N_croissance = count(f | stade = Croissance)
  N_climax     = count(f | stade = Climax)
  N_declin     = count(f | stade = Déclin)
  N_reliques   = count(f | stade = Relique)

  Score_expansion  = (N_pionniers + N_croissance) / N_total_familles_actives
  Score_stabilite  = N_climax / N_total_familles_actives
  Score_contraction = (N_declin + N_reliques) / N_total_familles_actives

  Condition : Score_expansion + Score_stabilite + Score_contraction + Score_intermediaire = 1

Seuil minimal : 8 trimestres consécutifs sans rupture majeure (COVID exclus recommandé)
                 Exclure les familles GHM avec < 20 séjours cumulés sur 8 trimestres
```

Indicateurs dérivés :

```
Taux de renouvellement du portefeuille (Turnover GHM) :
  T = (N_pionniers + N_déclin) / N_total_familles
  Analogue au turnover d'espèces en biogéographie insulaire
  T élevé → portefeuille en forte mutation ; T faible → portefeuille stable

Matrice de transition trimestrielle :
  M[stade_t, stade_{t+1}] = probabilité de transition d'un stade à l'autre
  → permet de projeter le portefeuille futur sur 4-8 trimestres (chaîne de Markov)

Indice de maturité du portefeuille :
  IMP = (2·N_climax + N_croissance − N_declin − 2·N_reliques) / N_total
  Plage : [−2 ; +2]
  > 0,5 : portefeuille mature et stable
  < −0,5 : portefeuille en contraction nette
```

## Utilité

- **Gestion stratégique du portefeuille d'activités GHT** : identifier en temps réel les GHMs en stade Pionnier permet de décider en amont s'il faut investir (ressources humaines, équipements) pour les passer en Croissance, ou au contraire les abandonner avant qu'ils ne consomment des ressources sans masse critique suffisante — équivalent d'un arbitrage de portefeuille produits
- **Anticipation des restructurations** : un Score_contraction > 0,35 (plus d'un tiers des familles en déclin ou relique) est un signal avancé de déséquilibre du casemix, détectable 2 à 3 ans avant que les indicateurs de volume brut n'alertent — temps nécessaire pour planifier des reconversions ou des mutualisations au sein du GHT
- **Détection des dérives non pilotées** : une famille GHM passant de Climax à Déclin sans décision explicite de la gouvernance signale une érosion de l'activité potentiellement liée à un concurrent ou à un départ de praticien — l'indicateur sert de tableau de bord précoce d'érosion
- **Optimisation de la coopération intra-GHT** : si une famille GHM est en stade Pionnier dans l'établissement A et en stade Climax dans l'établissement B du même GHT, le transfert de compétences ou la mutualisation progressive peut éviter une duplication d'investissement
- **Calibration du projet médical** : le projet médical quinquennal peut utiliser les stades de succession comme langage commun pour cartographier les ambitions (passer telle famille de Pionnier à Climax) et les arbitrages (accompagner la sortie d'une famille Relique)
- **Benchmarking intra-GHT** : comparer les stades de succession d'une même famille GHM entre établissements du GHT révèle quelle structure est naturellement positionnée comme référente et laquelle devrait rediriger son activité

## Sources de Données

- **PMSI MCO RSA** : variable `GHM` (8 caractères — racine 5 premiers), `finessgeo`, `DATE_ENTREE` agrégée par trimestre (ATIH transmet trimestriellement) — 8 trimestres consécutifs minimum
- **Référentiel ATIH des GHMs** : correspondance GHM racine → CMD → libellé, nécessaire pour l'interprétation clinique des stades et la communication aux équipes médicales
- **Médiane nationale par famille GHM** : extraite de la base nationale ATIH (part médiane de la famille f dans les établissements du même type) — utilisée comme seuil dans la classification Croissance

## Exemple de Valeurs

- **CH 400 lits — Score_expansion typique** : 0,15–0,25 (15–25% des familles actives en stade Pionnier ou Croissance) ; Score_stabilite : 0,45–0,60 ; Score_contraction : 0,15–0,25
- **CHU — Taux de renouvellement** : T ≈ 0,20–0,30 (fort renouvellement lié à l'activité de recours et d'innovation) ; CH rural : T ≈ 0,08–0,15 (portefeuille stable)
- **Signal d'alerte Score_contraction** : > 0,40 sur deux trimestres consécutifs → analyser les 10 premières familles en Déclin et leur poids financier cumulé
- **Indice de maturité** : valeur typique CH général = +0,3 à +0,6 ; valeur de crise = < 0,0 (contraction nette du portefeuille)
- **Durée de transition Pionnier → Climax** : 6 à 10 trimestres en moyenne sur les établissements MCO français selon les données historiques ATIH disponibles

## Limites

- **Horizon minimal de 8 trimestres** : la classification des stades repose sur des tendances mesurées sur 4 trimestres dans un historique de 8 — sur des établissements ayant subi des restructurations majeures (fusion, ouverture d'unité), l'historique peut être brisé et la classification faussée
- **Sensibilité aux petits volumes** : les familles GHM avec < 20 séjours cumulés sur 8 trimestres ont des parts et des tendances statistiquement instables — leur classification est peu fiable et doit être exclue ou présentée avec une mention d'incertitude
- **Artefacts de changement de classification ATIH** : le passage d'une version de GHM à la suivante peut faire apparaître une famille comme «Pionnière» alors qu'elle correspond à une famille existante renommée — nécessite une table de correspondance inter-versions avant toute interprétation longitudinale
- **Indépendance du stade et de la valeur stratégique** : un GHM en stade Relique peut être stratégiquement important (activité de recours rare) ; un GHM en stade Climax peut être peu rentable — le score de succession ne substitue pas à une analyse médico-économique complète
- **Non-applicabilité directe en SSR et psychiatrie** : les modes de groupage SSR (MMP, GME) et psychiatrie (journées par modalité) n'ont pas de dynamique de portefeuille comparable au MCO ; une adaptation des seuils et de la définition de «part» est nécessaire

## Références

- [Clements F.E. — Plant Succession: An Analysis of the Development of Vegetation, Carnegie Institution 1916 : théorie originale de la succession écologique par stades]
- Horn H.S. — Markovian properties of forest succession, in Cody M.L., Diamond J.M. (eds), *Ecology and Evolution of Communities*, Harvard University Press 1975 (chapitre) : modélisation des transitions entre stades comme chaîne de Markov
- [Henderson B.D. — The product portfolio, BCG Perspectives 1970 : application des stades de cycle de vie à la gestion de portefeuille stratégique]
- [Tilman D. — Secondary succession and the pattern of plant dominance, American Naturalist 1985 : mécanismes compétitifs dans les dynamiques de succession](https://doi.org/10.1086/284400)
- [ATIH — Base nationale PMSI MCO, publications annuelles des données d'activité par GHM et par établissement](https://www.atih.sante.fr/)
