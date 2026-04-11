# Taux de Journées au-delà de la Borne Haute

## Définition
Le taux de journées au-delà de la borne haute mesure la proportion de journées d'hospitalisation réalisées après que le séjour a dépassé la durée de la borne haute de son GHM, c'est-à-dire le seuil au-delà duquel l'ATIH verse des suppléments journaliers (EXH — suppléments pour extrême haute). Ces journées excédentaires sont un proxy des journées d'attente médicalement non justifiées (JAMJ) : patient cliniquement stable en attente d'une place en SSR, d'une décision chirurgicale, d'un retour à domicile ou d'une assistante sociale. Elles représentent un gisement d'efficience majeur pour les GHT, à la fois sur le plan organisationnel (libération de lits) et financier (coût d'une journée MCO non valorisée à la hauteur de son coût réel).

## Calcul
Le taux de journées au-delà de la borne haute est calculé comme suit :

```
Journées EXH par séjour = max(0, DMS séjour − Borne haute du GHM)

Taux de séjours EXH (%) = (Nombre de séjours avec DMS > borne haute / Nombre total de séjours) × 100

Taux de journées EXH (%) = (Σ journées EXH / Σ journées totales) × 100

Journées EXH pour 100 séjours = Σ journées EXH / Nombre total de séjours × 100
```

**Précisions méthodologiques** :
- La borne haute de chaque GHM est publiée annuellement par l'ATIH dans les fichiers tarifaires (disponibles sur le site ATIH).
- L'analyse est réalisée par GHM, par CMD, par service et par établissement du GHT pour identifier les foyers de journées excédentaires.
- Les séjours EXH génèrent un supplément tarifaire journalier (EXH) mais celui-ci couvre rarement le coût réel de la journée : l'objectif est de réduire ces séjours, pas de les multiplier.
- Un sous-indicateur pertinent est la **durée médiane des journées EXH par GHM**, qui identifie les GHM pour lesquels les dépassements sont chroniques et importants (plusieurs semaines).
- La comparaison avec le taux de séjours en borne basse (EXB) est utile : un établissement avec peu d'EXB et beaucoup d'EXH a un profil de prise en charge lourde structurelle, tandis qu'un établissement avec beaucoup d'EXH en médecine polyvalente signale un problème d'aval.

## Utilité
- **Identification des journées d'attente** : les journées EXH en médecine gériatrique, neurologie et orthopédie sont quasi-systématiquement des journées d'attente d'une place SSR ou médico-sociale, directement actionnable par une meilleure organisation de l'aval.
- **Libération de lits et réduction des tensions capacitaires** : chaque journée EXH évitée libère un lit MCO, réduisant les délais d'attente aux urgences et améliorant le taux d'occupation réel.
- **Pilotage financier** : le taux de journées EXH est un indicateur de la sous-valorisation de l'activité ; une réduction des séjours EXH améliore la recette moyenne par séjour et l'efficience économique du GHT.
- **Dialogue avec les partenaires SSR et médico-sociaux** : objectiver le volume de journées d'attente liées au manque de places SSR ou EHPAD pour négocier des capacités supplémentaires ou des protocoles d'admission prioritaire.
- **Benchmarking par GHM** : comparer le taux de séjours EXH par GHM entre les établissements du GHT et avec la moyenne nationale pour identifier les GHM où les pratiques locales génèrent des dépassements structurels.

## Sources de Données
- **PMSI MCO - Fichier RSA** : DMS de chaque séjour (dates d'entrée et de sortie) et GHM attribué, pour le calcul des journées EXH par croisement avec les bornes hautes ATIH.
- **ATIH - Fichiers tarifaires annuels** : bornes hautes par GHM, publiées dans les arrêtés tarifaires MCO (disponibles sur le site ATIH sous forme de fichiers Excel/CSV).
- **ScanSanté** : module de valorisation permettant d'identifier les séjours EXH et leur poids dans l'activité totale.
- **ATIH - VisualValoSej** : outil de simulation tarifaire permettant de calculer les suppléments EXH séjour par séjour.

## Exemple de Valeurs
- **Taux de séjours EXH moyen** : 5-10 % des séjours MCO en hospitalisation complète, selon le profil de l'établissement.
- **Taux de journées EXH** : 10-20 % des journées totales en MCO dans les établissements à forte activité gériatrique ou neurologique.
- **GHM les plus générateurs de journées EXH** : AVC avec complications (CMD 1), fractures du fémur (CMD 8), insuffisance cardiaque (CMD 5), démences (CMD 19).
- **Durée médiane des dépassements** : 5-15 jours pour les séjours gériatriques en attente de place SSR ou EHPAD.
- **Coût d'une journée EXH** : le supplément EXH versé par l'assurance maladie (60-200 €/jour selon le GHM) est systématiquement inférieur au coût réel de la journée MCO (400-800 €/jour), créant une perte économique structurelle.
- **Potentiel de réduction** : une réduction de 30 % des journées EXH dans un GHT de 20 000 séjours représente 5 000-15 000 journées libérées, soit l'équivalent de 15-40 lits MCO en moins à taux d'occupation constant.

## Limites
- Les journées EXH ne sont pas toutes des journées d'attente : certains séjours légitimement longs (complications graves, pathologies rares) dépassent la borne haute pour des raisons cliniques justifiées.
- La borne haute est définie sur la base des distributions nationales de DMS par GHM : dans un établissement traitant des cas plus complexes que la moyenne (CMI élevé), les dépassements peuvent être structurellement plus fréquents sans refléter une inefficience organisationnelle.
- La réduction des journées EXH nécessite une action sur l'aval (SSR, HAD, médico-social) qui dépasse souvent le seul périmètre d'action du GHT.
- L'indicateur ne distingue pas les causes de dépassement (attente SSR, attente décision chirurgicale, attente retour domicile, complexité clinique) sans analyse complémentaire des données DIM.
- Les bornes hautes varient chaque année avec la révision de la classification GHM : les comparaisons temporelles doivent s'assurer de la cohérence des référentiels tarifaires utilisés.

## Références
- [ATIH - Fichiers tarifaires MCO et bornes EXH/EXB](https://www.atih.sante.fr/)
- [ATIH - VisualValoSej : simulation de la valorisation des séjours](https://www.atih.sante.fr/)
- [ScanSanté - Valorisation et suppléments EXH](https://www.scansante.fr/)
- [DGOS - Circulaires tarifaires annuelles MCO](https://sante.gouv.fr/)
