# Taux de Non-Recours aux Soins Ambulatoires Pré-Hospitalisation

## Définition
Le taux de non-recours aux soins ambulatoires pré-hospitalisation mesure la proportion d'admissions hospitalières urgentes (`modeentree` = 8 et `provenance` = 5 — entrée du domicile par les urgences) pour des pathologies ambulatory care-sensitive (ACS), également appelées hospitalisations potentiellement évitables (HPE), chez des patients n'ayant eu aucun contact avec le système de soins ambulatoires au cours des 6 mois précédant l'admission. Le calcul repose sur un chaînage entre le PMSI MCO (mode d'entrée, GHM et diagnostic principal de la pathologie ACS) et le DCIR (consultations médecin généraliste et spécialistes, actes CCAM tracés dans ER_PRS_F) via le NIR crypté. Cet indicateur capture la barrière « invisible » à l'accès aux soins : des patients qui n'atteignent l'hôpital que lorsque leur état s'est décompensé, sans aucune prise en charge ambulatoire préalable. Il se distingue du taux d'HPE lui-même (qui comptabilise l'ensemble des admissions évitables) en isolant le sous-groupe pour lequel le problème est l'absence d'accès aux soins primaires, et non une mauvaise gestion d'un suivi existant.

## Calcul
Le taux de non-recours est calculé comme suit :

```
Taux non-recours (%) = (Admissions urgentes ACS sans contact ambulatoire préalable / Total admissions urgentes ACS) × 100
```

**Numérateur** : admissions urgentes (`modeentree` = 8 et `provenance` = 5) pour pathologies ACS (sélection par GHM de la liste HPE ATIH/HAS) pour lesquelles le DCIR ne retrace aucune consultation médecin généraliste ni spécialiste sur la fenêtre J-180 à J-1 avant la date d'entrée.

**Dénominateur** : ensemble des admissions urgentes (`modeentree` = 8 et `provenance` = 5 — entrée du domicile par les urgences) pour les mêmes pathologies ACS (même liste de GHM).

**Chaînage PMSI-DCIR** :

```sql
-- Etape 1 : extraction des séjours PMSI urgents ACS
SELECT rsa.nir_crypt, rsa.date_entree, rsa.ghm, rsa.dp
FROM pmsi_mco_rsa rsa
WHERE rsa.mode_entree = '8'
  AND rsa.provenance = '8'   -- domicile
  AND rsa.ghm IN (<liste_ghm_hpe>)

-- Etape 2 : recherche de contacts ambulatoires dans DCIR (J-180 à J-1)
SELECT DISTINCT prs.nir_crypt
FROM er_prs_f prs
WHERE prs.prs_nat_ref IN (<codes_actes_consultation_mg_sp>)
  AND prs.exe_soi_dtd BETWEEN rsa.date_entree - 180 AND rsa.date_entree - 1

-- Etape 3 : calcul du taux
-- Numérateur : séjours PMSI sans correspondance dans l'étape 2
-- Dénominateur : ensemble des séjours PMSI de l'étape 1
```

**Liste des pathologies ACS** (basée sur la liste française ATIH/HAS des 17 conditions traceurs HPE) :
- Asthme aigu grave
- Exacerbation de BPCO
- Complications du diabète (hypoglycémie, acidocétose, décompensation)
- Insuffisance cardiaque congestive (CHF)
- Complications de l'hypertension artérielle
- Angor instable
- Épilepsie non contrôlée
- Infection urinaire haute (pyélonéphrite)
- Déshydratation (notamment sujet âgé)
- Cellulite infectieuse

**Stratification recommandée** : par type de pathologie ACS, par tranche d'âge, par indice de défaveur sociale (IDH-2, FDEP calculé à partir de la commune de résidence INSEE).

## Utilité
- **Cartographie des zones de non-accès** : identifier les communes ou IRIS où les patients n'accèdent pas aux soins ambulatoires avant une hospitalisation urgente évitable, pour orienter l'offre de soins primaires.
- **Corrélation avec le taux sans médecin traitant** : mettre en regard le taux de non-recours avec la proportion de patients sans médecin traitant déclaré (données CPAM) pour quantifier le lien causal et objectiver les déserts médicaux.
- **Justification d'investissements en accès aux soins primaires** : chiffrer le besoin non couvert pour légitimer la création de maisons de santé pluriprofessionnelles (MSP), de CPTS, ou de consultations avancées de spécialistes en proximité.
- **Ciblage de programmes de médiation et de case management** : orienter les actions de médiation en santé et d'accompagnement proactif vers les profils à haut risque de non-recours identifiés par l'indicateur.
- **Évaluation de l'impact des programmes de prévention ACS** : une réduction du taux de non-recours dans un territoire après une intervention (CPTS, dispositif d'accès aux soins) signe une amélioration de l'accès ambulatoire, indépendamment du taux global d'HPE.
- **Dialogue ARS / CPAM** : cet indicateur croise données PMSI (hospitalisation) et DCIR (accès ambulatoire) pour offrir une vision 360° du parcours patient, mobilisable dans les CPOM et les Contrats Locaux de Santé.

## Sources de Données
- **PMSI MCO RSA** : `modeentree` + `provenance` (urgences = 8 + provenance 5), diagnostic principal (DP) en CIM-10, GHM pour identification des pathologies ACS/HPE.
- **DCIR ER_PRS_F** : consultations médecin généraliste et spécialistes (actes remboursés), actes CCAM tracés, permettant de reconstituer les contacts ambulatoires sur la fenêtre de 6 mois pré-admission.
- **NIR crypté** : identifiant patient pseudonymisé commun au PMSI et au DCIR, permettant le chaînage longitudinal des séjours et des actes ambulatoires.
- **ATIH — liste GHM des HPE** : liste officielle des GHM correspondant aux 17 conditions traceurs d'hospitalisations potentiellement évitables, référence pour la sélection des séjours ACS.
- **INSEE — données communales** : codes communes de résidence des patients pour le calcul des indices de défaveur sociale (IDH-2, FDEP) et la cartographie territoriale du non-recours.

## Exemple de Valeurs
- **Taux global de non-recours en France** : 15 à 25 % des admissions urgentes pour pathologies ACS surviennent chez des patients sans aucun contact ambulatoire dans les 6 mois précédents.
- **Pathologies à taux de non-recours élevé** : déshydratation du sujet âgé (> 35 %), cellulite infectieuse (> 30 %), exacerbation de BPCO en zone rurale (> 25 %).
- **Corrélation avec le taux sans médecin traitant** : dans les zones où plus de 20 % des patients n'ont pas de médecin traitant déclaré, le taux de non-recours est 2 à 3 fois plus élevé que dans les zones bien dotées.
- **Gradient social** : le taux de non-recours est environ 2 fois plus élevé dans le quintile de défaveur sociale le plus élevé par rapport au quintile le moins défavorisé (cadre Billings et al.).
- **Impact des actions CPTS** : une réduction de 15 à 20 % du taux de non-recours a été observée dans des territoires ayant bénéficié d'actions structurées de CPTS évaluées.

## Limites
- La fenêtre de 6 mois peut manquer des patients récemment installés sur le territoire, ayant changé de régime d'assurance, ou dont la couverture était temporairement suspendue.
- Tous les contacts ambulatoires ne sont pas traçables dans le DCIR : les consultations réglées intégralement par le patient sans remboursement (dépassements d'honoraires en secteur 3 ou praticiens non conventionnés) n'y apparaissent pas, même si ce cas reste rare.
- La liste GHM des ACS ne correspond pas parfaitement aux définitions cliniques des pathologies ACS : certains séjours codés comme HPE peuvent avoir eu une présentation clinique non évitable, générant un biais de classification.
- Le DCIR ne capture que les actes remboursés : les consultations gratuites réalisées dans des centres de santé municipaux, des associations humanitaires ou des permanences d'accès aux soins de santé (PASS) peuvent ne pas y figurer, sous-estimant le recours réel chez les populations très précaires.

## Références
- [Billings J. et al. — Impact of socioeconomic status on hospital use in New York City, Health Affairs 1993](https://www.healthaffairs.org/)
- [HAS — Indicateurs d'hospitalisations potentiellement évitables](https://www.has-sante.fr/)
- [ATIH — Liste des GHM correspondant aux HPE](https://www.atih.sante.fr/)
- [SNDS — Chaînage PMSI-DCIR par NIR crypté](https://www.snds.gouv.fr/)
- [DREES — Recours aux soins et déserts médicaux](https://www.drees.solidarites-sante.gouv.fr/)
