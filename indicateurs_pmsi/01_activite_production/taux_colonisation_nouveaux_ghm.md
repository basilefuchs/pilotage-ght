# Taux de Colonisation de Nouveaux GHMs

## Définition

La théorie de la biogéographie insulaire (MacArthur & Wilson, 1967) modélise l'équilibre dynamique du nombre d'espèces sur une île comme la résultante de deux flux opposés : un **taux de colonisation** (nouvelles espèces atteignant l'île depuis le continent) et un **taux d'extinction** (espèces localement disparues). À l'équilibre, ces deux taux s'égalisent et définissent un turnover permanent de la composition spécifique, même lorsque la richesse totale est stable.

Transposée au portefeuille d'activités d'un établissement, cette théorie produit deux indicateurs symétriques :

```
Taux de colonisation GHM :
  C = nb de familles GHM nouvellement entrées dans le Top-N de l'établissement
      ──────────────────────────────────────────────────────────────────────
      nb total de familles GHM dans le Top-N

Taux d'extinction GHM :
  E = nb de familles GHM sorties du Top-N de l'établissement sur la même période
      ──────────────────────────────────────────────────────────────────────────
      nb total de familles GHM dans le Top-N sur la période précédente

Turnover du portefeuille :
  T = C + E
```

Le Top-N désigne les N familles GHM représentant au moins 80% de l'activité de l'établissement (Top-80% analogue au seuil de Pareto), calculé sur la fenêtre glissante de référence (N-4 trimestres). N est propre à chaque établissement et reflète sa concentration d'activité.

L'intérêt est fondamentalement distinct du score de succession (qui classe chaque GHM en stade) et de l'entropie de Shannon (qui mesure la diversité globale) : le taux de colonisation/extinction mesure le **renouvellement de la composition** du cœur d'activité, indépendamment de la diversité totale. Un établissement peut avoir une entropie stable et un fort turnover (remplacement d'activités par d'autres de même poids).

À l'équilibre insulaire (C = E), le portefeuille est dynamiquement stable — les entrées compensent les sorties. Un déséquilibre (C > E : expansion nette ; C < E : contraction nette) signale une transformation directionnelle du portefeuille.

## Calcul

Source : PMSI MCO RSA — variables `ghm2` (6 caractères, racine = 5 premiers), `finessgeo`, `date_entree` agrégée par trimestre.

```
Population : tous séjours MCO d'un établissement
             sur deux fenêtres de 4 trimestres glissants consécutives

Fenêtre de référence (Ref) : trimestres T-7 à T-4
Fenêtre courante (Cur)     : trimestres T-3 à T

Étape 1 — Activité par famille GHM dans chaque fenêtre :
  N_f_Ref = count(RSA | GHM_racine = f, fenêtre = Ref)
  N_f_Cur = count(RSA | GHM_racine = f, fenêtre = Cur)

Étape 2 — Définition du Top-N par fenêtre (Top-80%) :
  Trier les familles par N_f décroissant
  Top_Ref = {f₁, f₂, ..., fₙ} tel que Σ N_fᵢ_Ref / N_total_Ref ≥ 0,80
  Top_Cur = {g₁, g₂, ..., gₘ} tel que Σ N_gⱼ_Cur / N_total_Cur ≥ 0,80

Étape 3 — Identification des entrées et sorties :
  Colonisateurs (Nouveaux entrants) : {f ∈ Top_Cur \ Top_Ref}
    = familles présentes dans le Top courant mais absentes du Top de référence
  Extinctions (Sorties) : {f ∈ Top_Ref \ Top_Cur}
    = familles présentes dans le Top de référence mais absentes du Top courant

Étape 4 — Calcul des taux :
  Base de référence commune pour les deux taux :
  N_base = (card(Top_Ref) + card(Top_Cur)) / 2  [taille moyenne des deux tops]

  C = card(Colonisateurs) / N_base   [taux de colonisation]
  E = card(Extinctions)   / N_base   [taux d'extinction]
  T = C + E                          [turnover total]

  Solde net : S = C − E
  S > 0 : expansion du portefeuille (plus d'entrées que de sorties)
  S < 0 : contraction (plus de sorties que d'entrées)
  S ≈ 0 : équilibre dynamique (analogue à l'équilibre insulaire MacArthur-Wilson)

Cas limites :
  - Si card(Top_Ref) = 0 (établissement sans historique) : C = 1, E = NA
  - Si N_base < 5 : indicateur peu informatif — établissement très concentré
    (quasi-mono-activité) → signaler dans le rapport
  - Seuil minimal d'inclusion d'une famille dans le Top :
    N_f ≥ 20 séjours sur la fenêtre de 4 trimestres
```

Indicateurs dérivés :

```
Courbe d'espèce-aire (species-area curve) :
  Tracer card(Top-k%) en fonction de k (Pareto du portefeuille)
  Comparer la courbure entre deux périodes → mesure la concentration/dilution du portefeuille

Distance de Jaccard entre deux portefeuilles :
  J(Ref, Cur) = |Top_Ref ∩ Top_Cur| / |Top_Ref ∪ Top_Cur|
  J proche de 1 : portefeuilles très similaires (faible turnover)
  J proche de 0 : portefeuilles entièrement différents (rupture totale)

Indice de fidélité de la famille GHM :
  nb de fenêtres consécutives où f ∈ Top-80%
  Familles à fidélité > 90% sur 12 trimestres = cœur d'activité structurel
```

## Utilité

- **Détection précoce d'une expansion non pilotée** : un taux de colonisation C > 0,25 sur deux fenêtres consécutives sans décision explicite du projet médical signale l'apparition d'activités qui n'ont pas été délibérément développées — recrutement de praticiens avec une spécialité complémentaire, dérive de codage, ou afflux d'un recrutement territorial non anticipé
- **Surveillance de l'érosion silencieuse du cœur d'activité** : un taux d'extinction E > 0,20 combiné à un solde négatif (S < −0,10) signale qu'une partie du cœur d'activité est en train de migrer vers d'autres établissements (concurrence, départs de praticiens) sans que les volumes bruts globaux n'aient encore diminué de manière visible
- **Benchmarking de la dynamique inter-établissements GHT** : comparer les turnover T entre établissements du même GHT révèle lesquels ont un portefeuille stable (T < 0,10 : cœur figé) et lesquels sont en forte mutation (T > 0,30) — information utile pour anticiper les convergences ou concurrences internes au GHT
- **Identification du cœur d'activité structurel** : les familles à fidélité > 90% sur 12 trimestres constituent l'invariant du portefeuille — intouchable dans les plans de restructuration sans risque majeur pour l'établissement
- **Suivi de l'impact d'une politique d'ouverture d'activité** : mesurer C avant et après l'ouverture d'un nouveau plateau technique ou le recrutement d'un praticien permet d'objectiver si la politique a effectivement «colonisé» de nouvelles familles dans le cœur d'activité
- **Comparaison avec la dynamique de concurrents** : si l'établissement voisin (hors GHT) a un C élevé sur les mêmes familles que les extinctions de l'établissement, la perte d'activité est probablement liée à une captation concurrentielle

## Sources de Données

- **PMSI MCO RSA** : variable `GHM` (8 caractères — racine 5 premiers), `finessgeo`, `date_entree` agrégée par trimestre — 8 trimestres consécutifs minimum (deux fenêtres de 4)
- **Référentiel ATIH des GHMs** : correspondance GHM racine → CMD → libellé, pour l'interprétation clinique des colonisateurs et extinctions (quelle spécialité entre/sort ?)
- **Base nationale ATIH** : pour calculer les taux de colonisation et d'extinction de référence nationale par type d'établissement (CHU, CH, clinique), permettant de contextualiser un turnover élevé ou faible

## Exemple de Valeurs

- **CH 400 lits — turnover annuel typique** : T ≈ 0,10–0,18 ; C ≈ 0,06–0,10 ; E ≈ 0,05–0,08 ; S ≈ +0,01–+0,03 (légère expansion nette)
- **CHU — turnover** : T ≈ 0,18–0,28 (fort renouvellement lié à l'activité d'innovation et de recours évolutifs)
- **Clinique mono-activité** : T ≈ 0,02–0,05 (cœur d'activité très stable, Top-80% concentré sur 3–5 familles)
- **Signal d'alerte expansion** : C > 0,25 sur deux fenêtres consécutives → identifier les familles colonisatrices et évaluer si leur développement est souhaitable
- **Signal d'alerte érosion** : E > 0,20 ET S < −0,10 sur deux fenêtres consécutives → carte des familles sorties, croisement avec les données de concurrence territoriale
- **Distance de Jaccard d'alerte** : J < 0,65 entre deux fenêtres consécutives → portefeuille transformé à plus d'un tiers en 4 trimestres, probablement non anticipé

## Limites

- **Dépendance au seuil Pareto (80%)** : le choix du seuil définissant le Top influence fortement C et E ; un établissement très concentré (5 familles = 80%) aura un turnover mécaniquement faible comparé à un établissement diversifié (25 familles = 80%) — toujours reporter card(Top) avec l'indicateur
- **Instabilité sur petits volumes** : les familles proches du seuil du Top-80% peuvent entrer et sortir du top par simple variabilité statistique sans changement réel de stratégie — les familles GHM avec < 20 séjours sur 4 trimestres ne devraient pas être comptabilisées comme colonisateurs ou extinctions significatifs
- **Artefacts de changement de classification ATIH** : les changements de version GHM créent des pseudo-colonisations (nouvelle famille = ancienne renommée) et pseudo-extinctions — appliquer une table de correspondance inter-versions avant tout calcul longitudinal inter-version
- **Non-interprétabilité isolée** : C et E doivent toujours être croisés avec les volumes absolus des familles concernées ; une famille colonisant le Top-80% avec 30 séjours n'a pas la même signification stratégique qu'une famille à 500 séjours
- **Biais de la fenêtre temporelle** : des fenêtres de 4 trimestres capturent la saisonnalité — certaines familles GHM peuvent entrer et sortir du Top-80% selon la saison (CMD 04 en hiver) sans constituer un changement structurel ; neutraliser en comparant fenêtre N à fenêtre N-4 (même saison, un an plus tôt)

## Références

- [MacArthur R.H., Wilson E.O. — The Theory of Island Biogeography, Princeton University Press 1967 : théorie originale du taux de colonisation et d'extinction sur les îles](https://doi.org/10.1515/9781400881376)
- [Simberloff D.S., Wilson E.O. — Experimental zoogeography of islands: the colonization of empty islands, Ecology 1969 : validation empirique du modèle colonisation/extinction](https://doi.org/10.2307/1934856)
- [Jaccard P. — Étude comparative de la distribution florale dans une portion des Alpes et du Jura, Bulletin de la Société Vaudoise des Sciences Naturelles 1901 : indice de similarité entre communautés]
- [Henderson B.D. — The product portfolio, BCG Perspectives 1970 : application des dynamiques de colonisation/extinction à la gestion stratégique de portefeuilles]
- [ATIH — Base nationale PMSI MCO, statistiques annuelles d'activité par GHM et par établissement](https://www.atih.sante.fr/)
