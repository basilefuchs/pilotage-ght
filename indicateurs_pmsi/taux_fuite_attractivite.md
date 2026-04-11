# Taux de Fuite et d'Attractivité

## Définition
Le taux de fuite mesure la proportion de patients résidant sur le territoire du GHT qui sont hospitalisés dans des établissements extérieurs au GHT. À l'inverse, le taux d'attractivité mesure la proportion de séjours réalisés au sein du GHT pour des patients résidant hors de son territoire. Ces deux indicateurs sont complémentaires : un fort taux de fuite signale une perte de parts de marché et un déficit d'offre ou de confiance, tandis qu'un fort taux d'attractivité témoigne du rayonnement du GHT au-delà de son territoire de référence.

## Calcul
Les taux de fuite et d'attractivité sont calculés comme suit :

```
Taux de fuite (%) = (Nombre de séjours de patients résidents du territoire réalisés hors GHT / Nombre total de séjours de patients résidents du territoire) × 100

Taux d'attractivité (%) = (Nombre de séjours de patients non-résidents réalisés au sein du GHT / Nombre total de séjours réalisés au sein du GHT) × 100
```

**Précisions méthodologiques** :
- Le territoire de référence est défini par les codes postaux ou les communes rattachées au GHT.
- L'analyse est réalisée par domaine d'activité (MCO, SSR, HAD, PSY) et par segment (chirurgie, médecine, obstétrique, cancérologie, etc.).
- La variable de résidence du patient est issue du code postal du RSS/RUM dans le PMSI.
- Les séjours en établissements privés du territoire sont inclus dans le dénominateur du taux de fuite pour mesurer la fuite réelle hors territoire.

## Utilité
- **Stratégie territoriale** : identifier les segments d'activité où le GHT perd des patients au profit d'autres établissements (privés ou CHU) et prioriser les actions de développement.
- **Analyse concurrentielle** : mesurer la position du GHT face au secteur privé sur son territoire et face aux CHU pour les activités de recours.
- **Planification de l'offre** : détecter les besoins non couverts sur le territoire (spécialités déficitaires générant une fuite importante).
- **Rayonnement du GHT** : évaluer la capacité du GHT à attirer des patients au-delà de son territoire, notamment pour ses activités de référence.
- **Pilotage par établissement** : décomposer les flux par site du GHT pour optimiser les coopérations intra-GHT.

## Sources de Données
- **PMSI MCO, SSR, HAD, PSY** : code postal de résidence du patient dans les RSS/RUM, croisé avec le FINESS de l'établissement prestataire.
- **ScanSanté** : outil ATIH permettant d'analyser les flux de patients entre territoires et établissements (module « Flux de patients »).
- **INSEE** : zonages infra-territoriaux (bassins de vie, zones d'emploi) pour affiner la définition du territoire de référence.

## Exemple de Valeurs
- **Taux de fuite moyen** : 15-30 % pour un GHT de taille moyenne, pouvant dépasser 40 % pour certaines spécialités chirurgicales complexes.
- **Taux d'attractivité moyen** : 10-20 % pour un GHT non-CHU, supérieur à 30 % pour les GHT disposant d'une activité de recours régionale.
- **Fuite chirurgicale** : souvent plus élevée (20-40 %) que la fuite médicale (10-20 %) en raison de la concurrence du secteur privé.
- **Fuite vers le CHU** : structurellement élevée pour les GHM de niveau 3-4, indépendamment de la qualité du GHT.

## Limites
- La définition du territoire de référence est structurante : un périmètre trop large sous-estime la fuite, un périmètre trop étroit la surestime.
- Le PMSI ne couvre pas les soins de ville ni les consultations externes non suivies d'hospitalisation, sous-estimant la fuite réelle.
- Une fuite élevée vers le CHU pour des GHM complexes est structurelle et ne signale pas nécessairement une défaillance du GHT.
- La fuite vers le secteur privé du territoire n'est pas toujours évitable si l'offre privée répond à une demande légitime de proximité ou de rapidité.
- Les variations saisonnières (flux touristiques) peuvent biaiser le taux d'attractivité dans certains territoires.

## Références
- [ScanSanté - Analyse des flux de patients](https://www.scansante.fr/)
- [ATIH - Guide méthodologique PMSI MCO](https://www.atih.sante.fr/)
- [DREES - Études sur les bassins de vie hospitaliers](https://www.drees.solidarites-sante.gouv.fr/)
