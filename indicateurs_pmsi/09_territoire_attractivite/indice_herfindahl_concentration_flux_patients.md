# Indice de Herfindahl-Hirschman des Flux Patients par Pathologie

## Définition

L'Indice de Herfindahl-Hirschman (IHH), utilisé en économie industrielle pour mesurer la concentration d'un marché, est ici adapté pour mesurer la concentration des flux d'hospitalisation par pathologie sur un territoire. Pour chaque GHM ou groupe de pathologies, l'IHH est la somme des carrés des parts de marché de chaque établissement recevant des patients du bassin de vie du GHT. Un IHH proche de 10 000 indique un monopole local (un seul établissement capte tous les patients), un IHH proche de 0 indique une atomisation des flux (multiples établissements de tailles équivalentes).

L'IHH se distingue fondamentalement du simple taux de fuite/attraction (déjà utilisé dans les PMSI territoriaux) : le taux de fuite est unidimensionnel (% de patients allant ailleurs) tandis que l'IHH capture la structure complète de la concurrence — un GHT peut avoir un taux de fuite de 30% vers un concurrent unique (IHH élevé, concurrence concentrée, risque stratégique fort) ou 30% répartis entre 8 établissements (IHH faible, concurrence fragmentée, risque stratégique moindre). Cette nuance est fondamentale pour les décisions d'investissement médical et les négociations avec l'ARS.

Calculable par pathologie (GHM) et par territoire (bassin de vie défini par commune de résidence des patients) depuis le PMSI national.

## Calcul

Données nécessaires :

```
Source : PMSI MCO national (accès ATIH via score EGB ou données régionales ARS)
         OU PMSI MCO de l'établissement + données territoriales ATIH publiées

Pour chaque GHM g et territoire T (bassin de vie ou département) :
  → N_i(g,T) = nombre de séjours du GHM g réalisés par l'établissement i
               pour des patients résidant dans le territoire T
  → N_total(g,T) = Σ N_i(g,T) = total des séjours du GHM g pour les résidents de T
  → Part de marché de i : s_i(g,T) = N_i(g,T) / N_total(g,T) × 100  (en %)
```

Formule de l'IHH :

```
IHH(g,T) = Σ [s_i(g,T)]²

  où la somme porte sur tous les établissements i recevant des patients
  résidant dans le territoire T pour le GHM g

Valeurs caractéristiques :
  IHH = 10 000  : monopole absolu (un seul établissement)
  IHH > 2 500   : marché très concentré (analogie DOJ américain)
  1 500-2 500   : marché modérément concentré
  IHH < 1 500   : marché concurrentiel (nombreux acteurs)

Part du GHT dans la formule :
  IHH_GHT(g,T) = s_GHT(g,T)²  → contribution du GHT à l'IHH total
  Plus la part du GHT est élevée, plus sa contribution à l'IHH est grande
  (relation quadratique = le leader "pèse" disproportionnellement)
```

Indicateurs dérivés :

```
Indice d'attraction pondéré par concentration :
  → Pour les GHMs où IHH_marché > 2500 ET part_GHT < 30% :
    signal de position dominante d'un concurrent = risque stratégique élevé

Delta IHH annuel :
  → ΔIHH = IHH(N) − IHH(N-1)
  → ΔIHH > 0 : concentration croissante (un acteur prend des parts)
  → ΔIHH < 0 : fragmentation (nouveaux entrants ou redistribution)
  → Si ΔIHH > 0 ET part_GHT diminue = perte de position au profit d'un concurrent
    identifiable

Top 5 GHMs par risque concurrentiel :
  → Classés par (part_concurrent_leader × volume_GHM_territoire)
  → Priorise les pathologies à fort enjeu volumétrique ET forte concurrence
```

Stratification recommandée :

```
IHH par GHM : identifier les spécialités en situation de monopole,
  duopole, ou forte concurrence sur le territoire du GHT
IHH par établissement du GHT (si GHT multi-sites) :
  chaque site a-t-il une position dominante locale sur ses pathologies cœur ?
Évolution sur 3-5 ans :
  tendance de concentration/fragmentation du marché local
Carte de chaleur territoire × GHM :
  visualisation des zones géographiques où le GHT perd des parts
  sur des pathologies stratégiques
```

## Utilité

- **Intelligence compétitive et positionnement stratégique** : identifier précisément sur quelles pathologies et dans quelles zones géographiques le GHT fait face à une concurrence concentrée (un concurrent dominant) vs fragmentée (plusieurs petits acteurs) — les stratégies de réponse sont fondamentalement différentes
- **Priorisation des investissements médicaux** : un IHH élevé sur un GHM à fort volume où le GHT est minoritaire (ex : chirurgie bariatrique capturée à 70% par une clinique privée voisine) justifie un investissement ciblé (recrutement d'un chirurgien spécialisé, équipement, communication)
- **Négociation avec l'ARS sur les autorisations d'activité** : un IHH très élevé sur un GHM de soins critiques (neurochirurgie, cardiologie interventionnelle) où le GHT est seul acteur est un argument pour défendre une autorisation d'activité exclusive face à un nouvel entrant
- **Détection précoce des érosions de parts de marché** : le delta IHH annuel permet de détecter dès l'année N+1 un mouvement de concentration au profit d'un concurrent, avant que la perte ne devienne structurelle
- **Analyse des fusions et coopérations inter-établissements** : évaluer l'impact d'une fusion entre deux établissements du GHT sur l'IHH local — outil utilisé par les autorités de concurrence (Autorité de la Concurrence) mais rarement par les GHTs eux-mêmes

## Sources de Données

- **PMSI MCO ATIH** : données nationales des RSA avec commune de résidence du patient (CPLR), GHM, FINESS géographique de l'établissement — accessibles via le portail ATIH pour les établissements (données propres) ou les ARS (données régionales) ; les données tous établissements d'un territoire nécessitent un accès via l'ARS ou le SNDS
- **ATIH — Statistiques et publications** : tableaux publics d'activité par GHM et par établissement, exploitables pour une approximation de l'IHH sans accès SNDS complet
- **IR_BEN_R DCIR** : commune de résidence pour le périmètre ambulatoire (si extension de l'IHH aux consultations spécialisées DCIR)
- **Référentiel INSEE communes / bassins de vie** : définition du territoire pertinent (bassin de vie INSEE, aire urbaine, zone de chalandise médicale construite ad hoc)

## Exemple de Valeurs

- **Chirurgie orthopédique (PTH/PTG) en territoire semi-rural** : IHH typiquement 3 500-5 000 (2-3 acteurs dominants, souvent GHT public + clinique privée + établissement ESPIC)
- **Neurochirurgie en territoire urbain** : IHH > 5 000 (offre concentrée sur 1-2 centres experts, le GHT étant souvent le seul acteur public)
- **Médecine générale hospitalière (GHM médecine non spécialisée)** : IHH < 1 500 (marché fragmenté, multiples acteurs)
- **Chirurgie bariatrique** : forte variabilité territoriale — IHH peut atteindre 7 000-8 000 quand une clinique privée a développé un centre expert régional
- **Seuil d'alerte stratégique** : IHH > 2 500 sur un GHM représentant > 5% du chiffre d'affaires du GHT ET part GHT < 30% = situation nécessitant une analyse stratégique formelle

## Limites

- Le calcul de l'IHH sur un territoire requiert les données de TOUS les établissements hospitaliers recevant des patients du bassin — ces données ne sont disponibles qu'avec un accès aux données ATIH régionales ou via l'ARS ; les données de l'établissement seul ne permettent qu'un calcul partiel (sous-estimation de l'IHH si des concurrents sont non vus)
- La définition du territoire pertinent (bassin de vie, département, zone d'influence construite sur les flux PMSI) influence fortement les valeurs d'IHH — une définition trop large dilue les effets de concentration locaux, une définition trop étroite sur-estime la position monopolistique du GHT
- L'IHH mesure la concentration volumétrique (nombre de séjours) et non la concentration économique (recettes T2A) — un concurrent réalisant des actes très valorisés avec peu de volume peut avoir un impact financier supérieur à ce que l'IHH volumétrique suggère
- Indicateur de pilotage stratégique (horizon annuel) et non opérationnel — le délai de disponibilité des données PMSI nationales (T+12 à 18 mois) limite son utilisation pour des réponses rapides à des mouvements concurrentiels

## Références

- [Herfindahl O.C. — Concentration in the Steel Industry, Columbia University PhD thesis 1950 : définition originale de l'indice HHI]
- [U.S. Department of Justice — Horizontal Merger Guidelines 2010 : seuils IHH pour l'évaluation de la concurrence (IHH < 1500 / 1500-2500 / > 2500)](https://www.justice.gov/atr/horizontal-merger-guidelines-08192010)
- [Capps C. et al. — The silent majority fallacy of the Elzinga-Hogarty criteria: a critique and new approach to analyzing hospital mergers, Int J Industrial Org 2002](https://doi.org/10.3386/w8216)
- [ATIH — Statistiques d'activité hospitalière par établissement et territoire (portail ATIH)](https://www.atih.sante.fr/)
- [Dranove D., White W.D. — Recent theory and evidence on competition in hospital markets, J Econ Management Strategy 1994 : application de l'IHH aux marchés hospitaliers]
