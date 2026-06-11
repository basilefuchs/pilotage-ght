# Indice de Besoins Non Couverts par Segment de Population

## Définition
L'indice de besoins non couverts (BNC) mesure l'écart entre la demande théorique de soins hospitaliers d'une population — estimée à partir de données épidémiologiques et démographiques — et l'offre réelle observée dans les données PMSI du GHT. Un indice positif signale une demande non satisfaite (besoins supérieurs à l'offre), révélant des inégalités d'accès, un déficit capacitaire ou une fuite vers d'autres territoires. Un indice négatif peut indiquer une sur-offre relative ou une hospitalisation excessive par rapport aux besoins réels de la population. Cet indicateur est un outil de planification stratégique : il permet d'anticiper les évolutions de l'activité du GHT en fonction des projections démographiques et épidémiologiques du territoire.

## Calcul
L'indice de besoins non couverts est calculé en trois étapes :

**Étape 1 — Estimation de la demande théorique :**
```
Demande théorique (séjours) = Population du territoire × Taux de recours de référence (national ou régional)
```

**Étape 2 — Observation de l'offre réelle :**
```
Offre réelle (séjours) = Séjours PMSI réalisés pour les patients résidant sur le territoire (tous établissements confondus)
```

**Étape 3 — Calcul de l'indice :**
```
Indice BNC (%) = ((Demande théorique − Offre réelle) / Demande théorique) × 100

  → BNC > 0 : besoins non couverts (déficit d'offre ou fuite)
  → BNC < 0 : sur-offre relative ou hospitalisation excessive
  → BNC = 0 : adéquation parfaite offre/demande
```

**Précisions méthodologiques** :
- Le taux de recours de référence est le taux national standardisé par âge et sexe pour chaque segment (pathologie, CMD, GHM), publié par l'ATIH ou la DREES.
- La population du territoire est issue des projections INSEE (OMPhale) par tranche d'âge et sexe pour intégrer l'évolution démographique.
- L'offre réelle inclut tous les séjours des patients résidant sur le territoire, quel que soit l'établissement prestataire (intra- ou extra-GHT), pour éviter de confondre les BNC avec les flux de fuite.
- L'analyse est réalisée par segment : pathologie chronique, domaine chirurgical, spécialité médicale, type de prise en charge (MCO, SSR, HAD).
- Une variante utilise les taux de recours du quintile FDep le plus favorisé comme référence (taux « optimal atteignable »), pour mesurer les BNC liés aux inégalités sociales.

## Utilité
- **Planification stratégique du GHT** : identifier les segments où l'offre de soins du territoire est structurellement insuffisante par rapport aux besoins de la population, pour orienter les demandes d'autorisation et les investissements capacitaires.
- **Anticipation des évolutions démographiques** : projeter les BNC à 5 et 10 ans en intégrant les projections de population INSEE (vieillissement, croissance démographique) pour dimensionner les futurs besoins en lits, personnel et équipements.
- **Dialogue avec l'ARS** : objectiver les besoins non couverts pour justifier des créations de lits, des autorisations nouvelles ou des financements spécifiques dans le cadre du SROS/SRSM.
- **Réduction des fuites de parcours** : distinguer la part des BNC liée à une fuite vers d'autres territoires (population se soignant hors GHT) de celle liée à un renoncement réel aux soins.
- **Priorisation par pathologie** : concentrer les efforts de développement sur les pathologies à fort BNC et fort impact sur la qualité de vie (orthopédie, ophtalmologie, cardiologie).

## Sources de Données
- **PMSI MCO** : séjours par pathologie, code postal de résidence, pour calculer l'offre réelle consommée par la population du territoire.
- **ATIH / ScanSanté** : taux de recours nationaux standardisés par pathologie et par CMD, servant de référence pour la demande théorique.
- **INSEE - OMPhale** : projections de population par commune, tranche d'âge et sexe à horizon 5, 10 et 20 ans pour le calcul de la demande théorique future.
- **DREES** : données épidémiologiques nationales (prévalence, incidence) par pathologie, pour affiner la demande théorique au-delà des seuls taux d'hospitalisation observés.
- **Registres de pathologies** (cancers, AVC, maladies rares) : pour les segments où la prévalence locale s'écarte significativement de la moyenne nationale.

## Exemple de Valeurs
- **Chirurgie de la cataracte** : BNC de +15 à +25 % dans les territoires ruraux vieillissants, reflétant un déficit d'ophtalmologistes chirurgicaux.
- **SSR neurologique post-AVC** : BNC souvent > +30 % dans les GHT sans SSR neurologique spécialisé, conduisant à une fuite systématique vers les CHU.
- **Chirurgie carcinologique** : BNC de +20 à +40 % dans les GHT sans autorisation de traitement du cancer pour certaines localisations.
- **Médecine gériatrique** : BNC projeté à +35-50 % à horizon 2035 dans les territoires à fort vieillissement démographique (taux de population > 75 ans supérieur à la moyenne nationale).
- **HAD** : BNC structurel de +40-60 % dans la majorité des territoires, l'HAD étant encore largement sous-développée par rapport aux besoins estimés.

## Limites
- La demande théorique repose sur des taux de recours de référence qui sont eux-mêmes le produit de pratiques hospitalières pouvant inclure des hospitalisations non pertinentes ; le référentiel n'est pas nécessairement optimal.
- Les projections démographiques INSEE comportent une incertitude croissante avec l'horizon temporel (migrations, évolution de la natalité).
- L'indicateur ne distingue pas les BNC par renoncement aux soins (demande supprimée) des BNC par fuite vers d'autres territoires (demande satisfaite ailleurs).
- Certains BNC sont structurels et ne peuvent être comblés localement (ex. : neurochirurgie, greffes) : leur persistance ne signale pas une défaillance du GHT.
- Le calcul nécessite un appareil statistique et des compétences en épidémiologie et en analyse géographique qui dépassent les outils natifs de ScanSanté.

## Références
- [INSEE - Projections de population OMPhale](https://www.insee.fr/fr/information/3683517)
- [ATIH - Taux de recours nationaux standardisés](https://www.atih.sante.fr/)
- [DREES - Besoins de santé et offre de soins](https://www.drees.solidarites-sante.gouv.fr/)
- [ScanSanté - Analyse territoriale de l'activité hospitalière](https://www.scansante.fr/)
