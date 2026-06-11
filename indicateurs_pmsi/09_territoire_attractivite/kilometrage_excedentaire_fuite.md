# Kilométrage Excédentaire des Séjours en Fuite

## Définition

Le kilométrage excédentaire mesure la distance supplémentaire que les patients en fuite acceptent de parcourir **au-delà** du site du GHT le plus proche capable de les prendre en charge. Il quantifie l'intensité du phénomène de fuite là où le taux de fuite n'en mesure que la fréquence : fuir vers une clinique à 5 km du site GHT et fuir vers un établissement à 80 km sont deux signaux très différents.

Le fondement conceptuel vient de la géographie de la santé : les modèles gravitaires de choix hospitalier (type Huff) posent que la probabilité de choisir un établissement décroît avec la distance selon une fonction de « distance decay », et que seul un différentiel perçu d'attractivité (capacité, qualité, réputation) compense un surcoût de distance (Kapitza et al. 2026). Le kilométrage excédentaire est la mesure empirique directe de ce surcoût consenti : un excédent élevé révèle un déficit d'attractivité perçue important, puisque les patients « paient » cher en distance pour éviter le GHT ; un excédent faible signale une fuite d'opportunité, plus facilement récupérable.

Formule symbolique :

```
KE_médian = médiane( d(domicile_i → étab_fuite_i) − d(domicile_i → site_GHT_compétent_le_plus_proche_i) )
            pour i ∈ séjours en fuite éligibles

KE_total  = Σ max(0, excédent_i)        (charge kilométrique excédentaire annuelle, en km)
```

Aucun indicateur PMSI standard ni restitution ScanSanté ne mesure cette grandeur : les restitutions flux de patients comptent des séjours ou des journées, pas des distances.

## Calcul

1. **Champ** : RSA MCO année N, base nationale, résidents du territoire GHT, hors séances (CMD 28), hors transferts, hors GHM d'erreur.
2. **Séjours en fuite éligibles** : séjours réalisés hors GHT dont la racine de GHM est produite par au moins un site du GHT (volume ≥ `V_min` = 30/an) — la notion d'excédent n'a pas de sens si le GHT n'offre pas l'activité.
3. **Distancier** : distances routières (km, ou minutes si disponible) entre le code géographique de résidence PMSI et les communes d'implantation des établissements (distancier inter-communes type METRIC INSEE/DREES ou OSRM).
4. **Pseudocode** :

```
pour chaque séjour en fuite éligible i :
    d_ght(i)  = min( dist(code_geo_i, site) pour site GHT produisant racine_i )
    d_reel(i) = dist(code_geo_i, finess_i)
    exc(i)    = d_reel(i) − d_ght(i)          # peut être négatif : fuite de proximité

KE_médian = médiane(exc)                       # robuste aux valeurs extrêmes
P_proximité = part(exc <= 0)                   # fuite vers plus proche que le GHT
KE_total  = Σ max(0, exc(i))                   # en km/an
```

5. **Conventions** : codes géographiques hors région élargie ou imprécis exclus ; plafonner les excédents au percentile 99 pour `KE_total` (séjours pendant une mobilité — vacances, étudiants — non distinguables dans le PMSI).
6. **Déclinaisons** : par racine de GHM (les racines à fort `KE_médian` sont les déficits d'image les plus profonds), par secteur de destination, par zone de résidence ; distribution complète (P25/P50/P75) plutôt que moyenne.

## Utilité

- **Hiérarchiser les fuites par gravité stratégique** : à taux de fuite égal, une racine avec `KE_médian` de 40 km traduit un évitement actif du GHT (problème d'offre perçue), une racine à 3 km une simple concurrence de proximité — les réponses managériales diffèrent.
- **Détecter la fuite de proximité** (`P_proximité` élevée) : quand une part importante des fuyards va *plus près* que le site GHT, le problème est l'implantation ou le maillage (consultations avancées à créer), pas l'image.
- **Argumenter en termes d'accès et d'écologie** : `KE_total` (km évitables/an) se traduit en charge de transport pour la population et en coûts de transports sanitaires — argument tangible pour l'ARS et les élus, à rapprocher de `depenses_transport_sanitaire_territoire.md`.
- **Calibrer les modèles gravitaires locaux** : la distribution des excédents fournit la fonction de distance decay empirique du territoire, réutilisable pour simuler l'effet d'une relocalisation d'activité (approche Huff, Kapitza et al. 2026).
- **Suivre l'évolution de l'image** : un `KE_médian` qui s'allonge dans le temps sur une filière signale un décrochage de réputation avant même que le taux de fuite n'augmente.
- **Évaluer l'équité territoriale** : croisé avec la défavorisation sociale (FDep), il montre si la capacité à fuir loin est socialement différenciée — la littérature montre que distance et statut socio-économique conditionnent fortement le choix du lieu de soins.

## Sources de Données

- **PMSI MCO national** (RSA) : code géographique de résidence, FINESS, GHM, CMD, mode d'entrée `[noms de champs exacts selon le format RSA de la campagne en vigueur, à confirmer]`.
- **Distancier inter-communes** : METRIC (INSEE, utilisé par la DREES dans les travaux d'accès aux soins — Études et Résultats n° 764) ou distancier routier OSRM ; à défaut, distance euclidienne entre centroïdes (dégradé, à documenter).
- **Référentiel ATIH** : table codes postaux → codes géographiques de l'année.
- **FINESS** : communes d'implantation des établissements, périmètre GHT.

## Exemple de Valeurs

Ordres de grandeur expert, non sourcés (aucune restitution publique de cette grandeur) — points de repère contextuels sourcés :

- Aux États-Unis, les patients ruraux qui contournent leur hôpital chirurgical parcourent une médiane de 32,5 miles (~52 km) contre 6,5 miles (~10 km) pour les autres, soit un excédent médian d'environ 40 km (Abid et al. 2025, contexte nord-américain peu dense).
- **GHT français, attendu (expert)** : `KE_médian` de 5–20 km en zone urbaine dense (fuite de concurrence), 20–60 km en zone rurale avec CHU régional attractif.
- **`P_proximité`** (fuite vers plus proche que le GHT) : 20–40 % attendu pour un GHT multisite avec un territoire étendu ; > 50 % signale un problème de maillage.
- **Seuil d'alerte** : `KE_médian > 30 km` sur une racine de chirurgie programmée courante — les patients fuient activement malgré le coût de distance.

## Limites

- **Précision du code géographique** : la résidence PMSI est une zone (regroupement de codes postaux), pas une adresse ; l'erreur sur chaque distance peut atteindre 10–15 km en zone rurale. L'indicateur est robuste en médiane sur des volumes suffisants (≥ 100 séjours en fuite par maille analysée), pas séjour par séjour.
- **Distance ≠ temps ni coût généralisé** : le choix des patients répond au temps de trajet et à la desserte (autoroute, transports en commun) plus qu'aux kilomètres ; utiliser un distancier en minutes quand il est disponible.
- **Mobilités non résidentielles** : séjours survenus pendant des déplacements (travail, vacances, étudiants) créent des excédents artificiels — d'où la médiane et le plafonnement au P99.
- **L'excédent négatif n'est pas une anomalie** : la fuite de proximité est structurelle dans les territoires où l'offre concurrente est intercalée entre le domicile et les sites GHT.
- **Pas d'inférence qualité** : un excédent consenti peut être rationnel (plateau technique, suivi historique d'un praticien parti dans le privé) ; l'indicateur mesure un comportement, pas une erreur des patients.
- **Dépendance au distancier** : changer de distancier (METRIC → OSRM) décale les niveaux ; figer l'outil pour les comparaisons temporelles.

## Références

- Kapitza J, Wieland T, Metzler M. *Modeling hospital catchment areas in pediatric oncology using an empirically parameterized extended Huff-model.* Int J Health Geogr. 2026. [DOI](https://doi.org/10.1186/s12942-026-00478-2) — PMID:42251381
- Abid M, Malone T, Holmes M, Charles A. *Clinical Consequences Associated With Bypassing Local Surgical Care for Urgent and Emergent Surgery.* J Surg Res. 2025;315:504-514. [DOI](https://doi.org/10.1016/j.jss.2025.09.034) — PMID:41092603
- DREES. *Distances et temps d'accès aux soins en France métropolitaine.* Études et Résultats n° 764, juin 2011 (méthodologie distancier) : [PDF](https://drees.solidarites-sante.gouv.fr/sites/default/files/2020-10/er764.pdf)
- IRDES. *Distances et temps d'accès aux soins en France métropolitaine.* Questions d'économie de la santé n° 164, 2011 : [PDF](https://www.irdes.fr/Publications/2011/Qes164.pdf)
- Fiches liées : `taux_bypass_site_competent_plus_proche.md` (fréquence du contournement), `depenses_transport_sanitaire_territoire.md` (traduction monétaire des distances), `taux_fuite_attractivite.md`.
