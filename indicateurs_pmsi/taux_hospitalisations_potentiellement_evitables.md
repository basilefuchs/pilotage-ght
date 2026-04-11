# Taux d'Hospitalisations Potentiellement Évitables (HPE)

## Définition
Le taux d'hospitalisations potentiellement évitables (HPE) mesure la proportion de séjours MCO liés à des pathologies chroniques ou aiguës dont l'hospitalisation aurait pu être évitée par une prise en charge ambulatoire adaptée (médecin traitant, spécialiste de ville, soins infirmiers, HAD). Ces séjours sont considérés comme le signal d'une rupture dans la coordination ville-hôpital ou d'un recours inapproprié aux soins hospitaliers. Les pathologies traceurs les plus utilisées sont l'insuffisance cardiaque, le diabète, l'asthme, la BPCO, l'hypertension artérielle, les infections urinaires et les pneumonies bactériennes.

## Calcul
Le taux d'HPE est calculé comme suit :

```
Taux d'HPE (%) = (Nombre de séjours MCO pour pathologies HPE / Nombre total de séjours MCO) × 100

Taux d'HPE pour 100 000 hab. = (Nombre de séjours MCO pour pathologies HPE / Population du territoire) × 100 000
```

**Précisions méthodologiques** :
- Les séjours HPE sont identifiés par le diagnostic principal (DP) du RSS, en s'appuyant sur les listes de codes CIM-10 validées (DREES, OCDE, ou liste française COMPAQH/HAS).
- Les principales pathologies traceurs et leurs codes CIM-10 associés :
  - Insuffisance cardiaque : I50
  - BPCO exacerbée : J44
  - Asthme : J45, J46
  - Diabète décompensé : E10-E14 avec complications
  - Hypertension artérielle : I10-I15
  - Infections urinaires : N10, N30, N39.0
  - Pneumonies bactériennes : J13-J18
- Les séjours de moins de 24 heures (ambulatoires) sont exclus du dénominateur selon certaines définitions.
- Le taux standardisé par âge et sexe est préférable pour les comparaisons inter-territoriales.

## Utilité
- **Évaluation de la coordination ville-hôpital** : un taux élevé d'HPE signale des lacunes dans le suivi ambulatoire des patients chroniques sur le territoire.
- **Identification des populations à risque** : cibler les patients polypathologiques ou précaires pour lesquels des programmes de gestion de cas ou d'éducation thérapeutique réduiraient les hospitalisations évitables.
- **Pilotage des coopérations avec la ville** : objectiver le besoin de renforcer les équipes de soins primaires, les réseaux de soins ou les dispositifs d'appui à la coordination (DAC).
- **Benchmarking territorial** : comparer le taux d'HPE du territoire du GHT avec la moyenne régionale et nationale pour identifier les pathologies les plus problématiques localement.
- **Dialogue avec l'ARS** : les HPE sont un indicateur clé des Contrats Locaux de Santé (CLS) et des CPOM pour orienter les financements de prévention et de coordination.

## Sources de Données
- **PMSI MCO** : diagnostic principal (DP) codé en CIM-10, pour l'identification des séjours HPE par pathologie traceur.
- **ScanSanté / ATIH** : module d'analyse des séjours par diagnostic principal, filtrable par territoire et par établissement.
- **DREES** : listes de référence des hospitalisations évitables utilisées dans les études françaises et internationales.
- **INSEE** : données de population pour le calcul des taux pour 100 000 habitants et la standardisation démographique.
- **Assurance Maladie (SNDS)** : pour les analyses longitudinales croisant hospitalisations et suivi ambulatoire.

## Exemple de Valeurs
- **Taux d'HPE moyen en France** : 5-10 % des séjours MCO selon la définition retenue et la liste de pathologies incluses.
- **Insuffisance cardiaque** : 1re cause d'HPE en France, représentant environ 150 000 à 200 000 séjours évitables par an.
- **Variation territoriale** : les taux d'HPE sont 30-50 % plus élevés dans les territoires déficitaires en médecins généralistes.
- **Impact de l'âge** : les patients de plus de 75 ans représentent 50-60 % des séjours HPE, avec une forte proportion de réadmissions répétées.
- **Taux d'HPE pour 100 000 hab.** : entre 800 et 1 500 selon les territoires pour l'ensemble des pathologies traceurs.

## Limites
- La liste des pathologies HPE n'est pas standardisée en France : les comparaisons entre études doivent vérifier la cohérence des définitions utilisées.
- Toutes les hospitalisations pour une pathologie traceur ne sont pas évitables : le codage CIM-10 seul ne permet pas de distinguer les cas réellement évitables des cas sévères justifiant l'hospitalisation.
- L'indicateur peut pénaliser les territoires accueillant des populations précaires ou vieillissantes, indépendamment de la qualité de la coordination.
- Ne capture pas les passages aux urgences non suivis d'hospitalisation, qui constituent également une forme de recours évitable.
- L'amélioration du taux d'HPE nécessite des actions hors du champ hospitalier (médecine de ville, officines, médico-social), limitant le levier d'action direct du GHT.

## Références
- [DREES - Hospitalisations potentiellement évitables](https://www.drees.solidarites-sante.gouv.fr/)
- [HAS - Indicateurs de qualité et sécurité des soins (IQSS)](https://www.has-sante.fr/)
- [OCDE - Preventable Hospitalisations Indicator](https://www.oecd.org/health/)
- [ATIH - Base nationale PMSI MCO](https://www.atih.sante.fr/)
