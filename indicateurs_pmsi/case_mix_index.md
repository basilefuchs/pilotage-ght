# Case-Mix Index (CMI)

## Définition
Le Case-Mix Index (CMI), ou indice de complexité du casemix, mesure la lourdeur économique moyenne des séjours pris en charge par un établissement ou un GHT, en pondérant chaque GHM par son poids relatif (coefficient de pondération tarifaire). Un CMI élevé indique que l'établissement traite des cas plus complexes et plus coûteux que la moyenne nationale, tandis qu'un CMI proche de 1 signale une activité dans la norme. Cet indicateur est central pour l'analyse médico-économique : il permet de comprendre pourquoi les recettes T2A diffèrent entre établissements, indépendamment du volume d'activité.

## Calcul
Le Case-Mix Index est calculé comme suit :

```
CMI = Σ (Nombre de séjours dans le GHM i × Poids relatif du GHM i) / Nombre total de séjours
```

**Précisions méthodologiques** :
- Les poids relatifs des GHM sont publiés annuellement par l'ATIH dans le cadre de la classification T2A. Ils expriment le coût relatif d'un GHM par rapport au coût moyen national d'un séjour (CMI national = 1 par construction).
- Le CMI peut être calculé pour l'ensemble des séjours MCO ou par segment (chirurgie, médecine, obstétrique) et par unité fonctionnelle.
- Une variante fréquente utilise les tarifs GHM publiés plutôt que les poids relatifs ATIH, donnant un CMI en valeur monétaire (recette moyenne par séjour).
- Le CMI est également calculable en SSR (via les GME et leurs pondérations) et en psychiatrie (GHJ/GHS).
- L'analyse de décomposition du CMI distingue l'effet « casemix » (nature des pathologies traitées) de l'effet « DMS » (durée de séjour relative au GHM), permettant d'identifier les leviers d'amélioration.

## Utilité
- **Analyse médico-économique** : comprendre l'écart de recettes T2A entre établissements du GHT par l'effet casemix, indépendamment des volumes ou des tarifs négociés.
- **Benchmark entre établissements** : comparer le niveau de complexité des cas traités par chaque site du GHT pour objectiver les différences de ressources nécessaires.
- **Justification des ressources** : un CMI élevé justifie des dotations en personnel médical et paramédical plus importantes et des plateaux techniques plus lourds.
- **Suivi de l'évolution du casemix** : détecter un glissement vers des cas moins complexes (baisse du CMI) pouvant signaler une perte d'activité de recours ou un excès d'hospitalisations non justifiées.
- **Dialogue avec les tutelles** : le CMI est un argument clé dans les négociations CPOM et les demandes d'autorisation d'activités de recours ou de référence.

## Sources de Données
- **PMSI MCO** : données de séjours par GHM pour le numérateur (séjours × poids) et le dénominateur (total des séjours).
- **ATIH - Poids relatifs des GHM** : publiés annuellement dans les arrêtés tarifaires, disponibles sur le site de l'ATIH.
- **ScanSanté** : module de comparaison du CMI entre établissements et par rapport à la moyenne nationale, avec décomposition par segment.
- **Tableaux de bord EPRD / ERRD** : intègrent le CMI comme indicateur de suivi de l'activité médico-économique des établissements publics de santé.

## Exemple de Valeurs
- **CMI moyen national MCO** : par définition proche de 1,0 (base de calcul ATIH).
- **CHU** : CMI généralement compris entre 1,3 et 1,8, reflétant la prise en charge de cas complexes et de référence.
- **GHT établissement support (CHG de grande taille)** : CMI entre 1,0 et 1,3 selon le niveau de recours.
- **GHT établissements périphériques** : CMI entre 0,7 et 1,0, reflétant une activité de proximité moins complexe.
- **Cliniques privées** : CMI variable selon la spécialisation ; souvent élevé en chirurgie orthopédique et cardiologie interventionnelle (1,2-1,5), faible en médecine polyvalente.
- **Variation intra-GHT** : un écart de CMI de 0,3 entre deux établissements du même GHT représente, pour 10 000 séjours, un différentiel de recettes T2A de plusieurs millions d'euros.

## Limites
- Le CMI est dépendant de la qualité du codage PMSI : un codage insuffisant des comorbidités et complications (CC/CMA) sous-évalue le CMI réel de l'établissement.
- Il ne reflète pas la complexité clinique réelle des patients mais uniquement la complexité économique telle que définie par la classification GHM.
- La comparaison du CMI entre secteur public et secteur privé est biaisée par les différences de tarification (GHS vs tarifs OQN) et de périmètre d'activité.
- Le CMI est influencé par les changements annuels de la classification GHM et des poids relatifs, rendant les comparaisons temporelles sensibles aux révisions tarifaires.
- Un CMI élevé peut résulter d'une sélection des cas complexes (écrémage de l'activité simple vers le privé) plutôt que d'une réelle capacité de prise en charge lourde.

## Références
- [ATIH - Classification GHM et poids relatifs](https://www.atih.sante.fr/)
- [ScanSanté - Case-Mix Index par établissement](https://www.scansante.fr/)
- [DGOS - Guide méthodologique de production des recettes MCO (T2A)](https://sante.gouv.fr/)
- [HAS - Indicateurs de performance médico-économique](https://www.has-sante.fr/)
