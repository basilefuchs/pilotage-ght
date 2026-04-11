# Taux de Transferts Inter-Établissements au sein du GHT

## Définition
Le taux de transferts inter-établissements au sein du GHT mesure la proportion de patients dont le parcours de soins comprend au moins un transfert entre deux établissements membres du même GHT, rapportée au total des séjours du GHT. Cet indicateur évalue la fluidité et la cohérence du parcours patient à l'intérieur du groupement : un taux élevé et maîtrisé témoigne d'une bonne organisation de la filière intra-GHT, tandis qu'un taux faible peut signaler un manque de coordination ou une orientation par défaut vers des structures extérieures au groupement.

## Calcul
Le taux de transferts intra-GHT est calculé comme suit :

```
Taux de transferts intra-GHT (%) = (Nombre de séjours avec au moins un transfert vers un établissement membre du GHT / Nombre total de séjours du GHT) × 100
```

**Précisions méthodologiques** :
- Les transferts intra-GHT sont identifiés par le couplage des modes de sortie (code 6 = transfert) et d'entrée (code 6 = transfert) entre deux FINESS membres du GHT, sur des séjours de dates compatibles.
- L'analyse distingue les flux selon leur sens : MCO → SSR, MCO → HAD, SSR → MCO (réhospitalisation), MCO → MCO (transfert entre sites).
- Le taux peut être calculé globalement ou par filière (traumatologie, AVC, chirurgie orthopédique, cancérologie, gériatrie, etc.).
- La durée entre la sortie de l'établissement émetteur et l'entrée dans l'établissement receveur (délai de transfert) est un indicateur complémentaire de fluidité.

## Utilité
- **Évaluation de la coordination intra-GHT** : mesurer dans quelle mesure les établissements du GHT travaillent réellement en filière plutôt qu'en silos.
- **Optimisation des parcours post-aigus** : identifier les filières MCO → SSR ou MCO → HAD qui fonctionnent bien et celles qui nécessitent une meilleure organisation.
- **Réduction des fuites de parcours** : repérer les patients transférés hors GHT alors qu'une structure du groupement aurait pu les accueillir.
- **Pilotage des conventions intra-GHT** : objectiver les flux entre établissements pour dimensionner les capacités d'aval (lits SSR, places HAD) en adéquation avec l'activité MCO.
- **Suivi du projet médical partagé** : évaluer l'avancement de la structuration des filières prévues dans le projet médical partagé du GHT.

## Sources de Données
- **PMSI MCO, SSR et HAD** : modes d'entrée et de sortie (codes transfert), FINESS des établissements, dates d'entrée et de sortie — pour reconstituer les chaînes de séjours intra-GHT.
- **ScanSanté** : module d'analyse des flux de patients entre établissements, filtrable par FINESS de GHT.
- **ATIH - Chaînage PMSI** : le chaînage anonymisé des séjours par numéro de patient (NIR crypté) permet de reconstituer les parcours multi-séjours au sein du GHT.
- **Données locales des établissements** : logiciels de gestion des lits et des transferts (TerritOR, Trajectoire) pour affiner l'analyse.

## Exemple de Valeurs
- **Taux global de transferts intra-GHT** : 5-15 % des séjours MCO selon la taille et l'organisation du GHT.
- **Filière MCO → SSR intra-GHT** : objectif cible >60 % des transferts en SSR réalisés vers un établissement du GHT (vs transferts vers le secteur privé ou hors territoire).
- **Filière MCO → HAD intra-GHT** : très variable, souvent <30 % faute de couverture HAD suffisante du GHT.
- **Délai de transfert MCO → SSR** : idéalement <5 jours ; un délai >10 jours est associé à une prolongation de séjour MCO et à une dégradation du pronostic fonctionnel.
- **Taux de retour MCO depuis SSR intra-GHT** : 8-15 % (réhospitalisations depuis SSR vers MCO du même GHT).

## Limites
- Le chaînage des séjours PMSI entre établissements distincts n'est possible qu'avec le NIR crypté, dont l'accès est soumis à des contraintes réglementaires (CNIL, SNDS).
- Les transferts informels (sorties sur demande, retours à domicile intermédiaires) ne sont pas captés par le PMSI.
- Un taux de transferts intra-GHT élevé ne garantit pas la qualité du parcours si les délais sont longs ou si l'orientation est inadaptée.
- La comparaison entre GHT est difficile en raison des différences de périmètre géographique, de taille et de spécialisation des établissements membres.
- L'indicateur ne distingue pas les transferts programmés (filière organisée) des transferts non anticipés (orientation par défaut).

## Références
- [ATIH - Méthodologie de chaînage PMSI](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des flux inter-établissements](https://www.scansante.fr/)
- [Plateforme Trajectoire - Gestion des admissions SSR/HAD](https://trajectoire.sante-ra.fr/)
- [Ministère de la Santé - Instruction GHT et projet médical partagé](https://www.legifrance.gouv.fr/)
