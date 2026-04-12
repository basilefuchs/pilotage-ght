# Centralité de Betweenness du GHT dans le Réseau de Soins Territorial

## Définition

La centralité de betweenness (ou centralité d'intermédiarité), concept fondateur de la théorie des réseaux (Freeman, 1977), mesure la fréquence à laquelle un nœud se trouve sur le "chemin le plus court" entre deux autres nœuds d'un réseau. Appliquée au réseau de soins territorial, elle quantifie dans quelle mesure le GHT est un **intermédiaire incontournable** — un hub — dans les flux de patients entre les autres producteurs de soins du territoire (médecins généralistes, spécialistes libéraux, cliniques, EHPAD, SSR privés, laboratoires, pharmacies).

Formellement : CB(v) = Σ_{s≠v≠t} [σ(s,t|v) / σ(s,t)], où σ(s,t) est le nombre de chemins les plus courts entre les nœuds s et t, et σ(s,t|v) est le nombre de ces chemins qui passent par le nœud v (le GHT).

Le réseau de soins territorial est modélisé depuis le SNDS comme un graphe orienté pondéré : les nœuds sont les producteurs de soins (établissements FINESS, médecins traitants RPPS, spécialistes libéraux) et les arcs sont les flux de patients (un patient vu par le médecin A puis par le producteur B crée un arc A→B, pondéré par le volume de patients en commun).

Cet indicateur est radicalement différent du taux d'attraction habituel (qui mesure les parts de marché en volume) : un GHT peut avoir un taux d'attraction modeste mais une centralité élevée s'il est systématiquement sur les parcours complexes qui relient de nombreux acteurs entre eux. Inversement, un GHT volumétriquement dominant mais contournable (patients qui vont directement chez les spécialistes libéraux sans passer par le GHT) peut avoir une centralité faible.

## Calcul

Construction du réseau de soins territorial :

```
Nœuds du réseau :
  → Établissements FINESS géographiques (MCO, SSR, HAD, psychiatrie, EHPAD)
    dans le bassin de vie ou le département du GHT
  → Médecins traitants déclarés (RPPS) — identifiables via IR_BEN_R DCIR
  → Spécialistes libéraux actifs (RPPS, actes ER_PRS_F DCIR)
  → Pharmacies (ER_PHA_F DCIR — FINESS pharmacie)
  → Laboratoires de biologie (ER_BIO_F DCIR)

Arcs du réseau (flux de patients) :
  → Pour chaque patient (NIR), extraire la séquence temporelle ordonnée
    de tous les producteurs de soins consultés sur 12 mois
    (depuis DCIR ER_PRS_F + PMSI tous champs)
  → Un arc A→B existe si au moins X patients ont eu un contact avec A
    puis un contact avec B dans les 30 jours (fenêtre temporelle paramétrable)
  → Poids de l'arc A→B = nombre de patients en commun (A puis B dans 30j)

Filtres recommandés :
  → Ne conserver que les producteurs avec ≥ 50 patients/an
    (éliminer les nœuds anecdotiques qui rendent le réseau trop dense)
  → Fenêtre temporelle : 30j pour les transitions aiguës,
    90j pour les transitions chroniques (ALD)
  → Population cible : tous patients du territoire OU sous-population ALD
    (parcours chroniques, plus significatifs pour la centralité)
```

Calcul de la centralité de betweenness :

```
Algorithme : Brandes (2001) — algorithme standard O(VE) pour les graphes pondérés
  → Implémentable en Python (networkx : nx.betweenness_centrality(G, weight='weight'))
  → Ou en R (igraph : betweenness(g, weights=E(g)$weight))

CB_GHT = centralité de betweenness normalisée du nœud "GHT"
  → Normalisée sur [0,1] : CB_norm = CB / [(n-1)(n-2)] pour un graphe orienté
    où n = nombre de nœuds du réseau

Interprétation :
  CB_norm proche de 1 : le GHT est sur presque tous les parcours = hub absolu
  CB_norm > 0.3        : position centrale forte
  CB_norm 0.1-0.3      : position intermédiaire
  CB_norm < 0.1        : position périphérique (patients contournent le GHT)
```

Indicateurs dérivés :

```
Centralité par type de flux :
  → CB sur flux MCO uniquement (hospitalisations)
  → CB sur flux ambulatoires (consultations spécialisées, DCIR)
  → CB sur flux ALD (parcours chroniques sur 12 mois)
  → Comparer les centralités : le GHT peut être central pour les hospitalisations
    mais périphérique pour le suivi ambulatoire post-hospitalier

Détection des "courtiers alternatifs" (competing hubs) :
  → Identifier les nœuds du réseau avec CB_norm > CB_GHT
  → Ce sont les acteurs qui interceptent les flux avant le GHT
  → Information stratégique clé pour les décisions de coopération ou concurrence

Évolution temporelle de la centralité :
  → Calculer CB_GHT pour chaque année sur 3-5 ans
  → Une CB décroissante = désintermédiation progressive du GHT
    (patients contournent de plus en plus le GHT)
  → Une CB croissante = renforcement du rôle de hub = succès des politiques
    de coordination (filières, conventions, réseaux de soins)
```

## Utilité

- **Mesurer le rôle stratégique réel du GHT dans son territoire** : la centralité révèle si le GHT est un acteur structurant qui coordonne les parcours, ou un acteur parmi d'autres qui peut être contourné — information stratégique impossible à obtenir des seuls taux d'attraction volumétriques
- **Identifier les axes de désintermédiation** : si le GHT est central pour les hospitalisations MCO mais périphérique pour les consultations post-sortie (DCIR), cela révèle que les patients quittent la filière GHT dès la sortie d'hospitalisation — orientation pour le développement de consultations externes spécialisées ou de protocoles de coopération ville-hôpital
- **Cartographier les concurrents structurels** : les nœuds avec une centralité supérieure au GHT sur certains types de flux sont les acteurs qui captent les parcours avant le GHT — information clé pour les décisions stratégiques (coopération, développement d'offre, négociation de filières)
- **Évaluer l'impact des politiques de coordination** : mesurer l'évolution de la centralité avant/après l'implémentation d'un réseau de soins, d'une filière AVC, ou d'une consultation multidisciplinaire — démonstration quantitative de l'impact sur le positionnement territorial du GHT
- **Négociation avec l'ARS sur le rôle de recours** : un CB_norm élevé sur les pathologies complexes est un argument pour reconnaître le GHT comme centre de recours territorial, avec les implications tarifaires et réglementaires correspondantes

## Sources de Données

- **SNDS complet** (PMSI tous champs + DCIR) : accès nécessaire pour construire le réseau multi-acteurs complet — requiert le NIR crypté et les identifiants producteurs (FINESS, RPPS)
- **DCIR ER_PRS_F** : actes médicaux libéraux avec code RPPS du prescripteur et de l'exécutant — principal source des flux ambulatoires entre médecins et spécialistes
- **DCIR ER_PHA_F et ER_BIO_F** : dispensations pharmaceutiques et actes de biologie — pour inclure les pharmacies et laboratoires dans le réseau
- **IR_BEN_R** : médecin traitant déclaré (RPPS) — nœud de départ de nombreux parcours de soins
- **Algorithme Brandes** : implémentation Python (networkx ≥ 2.8) ou R (igraph ≥ 1.3) — calcul performant même sur des réseaux de plusieurs milliers de nœuds

## Exemple de Valeurs

- **CB_norm attendue pour un GHT dominant en territoire semi-rural** : 0,35-0,55 (fort hub sur les hospitalisations MCO, moindre sur l'ambulatoire)
- **CB_norm en territoire urbain concurrentiel** : 0,10-0,25 (présence de plusieurs acteurs alternatifs — cliniques privées, CHU de proximité)
- **CB_norm d'un CHU en territoire isolé** : 0,55-0,75 (quasi-monopole sur les parcours complexes)
- **Seuil d'alerte de désintermédiation** : CB_norm décroissant de > 0,05 sur 2 ans consécutifs = investigation stratégique recommandée
- **Centralité des concurrents principaux** (benchmarking) : clinique privée concurrente CB_norm ~0,08-0,15 en territoire mixte = concurrent existant mais non dominant

## Limites

- La construction du réseau requiert un accès SNDS complet avec identifiants producteurs (RPPS, FINESS) — les données de l'établissement seul ne permettent de construire que les arcs impliquant le GHT, pas la structure complète du réseau (centralité des concurrents non calculable)
- La définition de la fenêtre temporelle des arcs (30j, 90j) influence fortement la structure du réseau et les centralités calculées — une fenêtre trop courte fragmente les parcours chroniques, une fenêtre trop longue dilue les relations causales entre consultations
- La centralité de betweenness capture les flux de patients existants, non les flux potentiels (patients qui auraient pu être orientés vers le GHT mais ne l'ont jamais été) — elle mesure le réseau actuel, pas le réseau optimal
- Sur les très grands réseaux (> 10 000 nœuds), le calcul de betweenness peut être coûteux en temps de calcul même avec l'algorithme de Brandes — recommander un filtrage des nœuds à faible volume et éventuellement une approximation stochastique (betweenness sampling)

## Références

- [Freeman L.C. — A set of measures of centrality based on betweenness, Sociometry 1977](https://doi.org/10.2307/3033543)
- [Brandes U. — A faster algorithm for betweenness centrality, Journal of Mathematical Sociology 2001](https://doi.org/10.1080/0022250X.2001.9990249)
- [Barnett M.L. et al. — Mapping physician networks with self-reported and administrative data, Health Services Research 2011](https://doi.org/10.1111/j.1475-6773.2011.01262.x)
- [Landon B.E. et al. — Using administrative data to identify naturally occurring networks of physicians, Med Care 2012](https://doi.org/10.1097/MLR.0b013e3182374834)
- [Health Data Hub — Documentation SNDS : identifiants producteurs de soins (RPPS, FINESS) dans le DCIR](https://www.health-data-hub.fr/)
