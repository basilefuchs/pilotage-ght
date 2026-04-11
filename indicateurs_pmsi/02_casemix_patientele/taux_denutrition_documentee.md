# Taux de Dénutrition Documentée

## Définition
Le taux de dénutrition documentée mesure la proportion de séjours MCO dans lesquels une dénutrition a été codée en diagnostic associé (DA) selon la CIM-10, signalant que l'équipe soignante a identifié et documenté cet état nutritionnel dégradé lors de l'hospitalisation. Les codes pertinents incluent E40 à E46 (malnutrition protéino-énergétique de différents degrés) ainsi que E50-E64 (carences en micronutriments). La dénutrition hospitalière est une comorbidité fréquente et sous-diagnostiquée : elle est présente chez 20-40 % des patients hospitalisés en médecine et gériatrie selon les études de prévalence françaises, mais ne figure dans le PMSI que chez 3-8 % des séjours selon les établissements, révélant un sous-codage massif. Elle aggrave le pronostic, allonge la DMS, augmente les complications et majore le coût de séjour — son codage systématique est à la fois un enjeu clinique, qualité et médico-économique (la dénutrition sévère est une CMA dans de nombreux GHM, ce qui impacte le niveau de sévérité et donc le financement T2A).

## Calcul
Le taux de dénutrition documentée est calculé directement depuis les codes diagnostics du PMSI :

```
Séjour avec dénutrition documentée = séjour ayant au moins un code E40-E46 en DA (ou DP)
  → E40 : Kwashiorkor
  → E41 : Marasme nutritionnel
  → E42 : Kwashiorkor-marasme
  → E43 : Malnutrition protéino-énergétique sévère, sans précision
  → E44 : Malnutrition protéino-énergétique modérée et légère
  → E45 : Retard de développement dû à une malnutrition protéino-énergétique
  → E46 : Malnutrition protéino-énergétique, sans précision

Taux de dénutrition documentée (%) = (Séjours avec code E40-E46 en DA / Total séjours MCO) × 100
```

**Sous-indicateurs dérivés :**
```
Taux de dénutrition sévère (%) = (Séjours E43 / Total séjours MCO) × 100
  → E43 = dénutrition sévère, critère de CMA dans de nombreux GHM

Taux de dénutrition par CMD (%) → identifie les spécialités avec la plus forte prévalence documentée
  (gériatrie CMD 23, cancérologie CMD 17, digestif CMD 6, neurologie CMD 1)

Impact sur le niveau de sévérité GHM :
  Proportion de séjours passant en niveau 3 ou 4 grâce au codage de la dénutrition (CC ou CMA)
  → Mesure l'impact médico-économique du codage sur la valorisation T2A

Ratio codage/prévalence estimée :
  = Taux de dénutrition documentée PMSI / Prévalence attendue selon le profil de patientèle
  → Estimé par comparaison avec les études de prévalence de la littérature (PNNS, études NutriAction)
  → Un ratio < 0,3 signale un sous-codage majeur justifiant un audit ciblé

Taux de dénutrition documentée associé à une prise en charge nutritionnelle :
  = (Séjours E40-E46 + acte CCAM de nutrition entérale ou parentérale / Séjours E40-E46) × 100
  → Mesure la cohérence entre le diagnostic codé et la prise en charge effective
```

**Précisions méthodologiques** :
- Le codage de la dénutrition en DA déclenche dans de nombreux GHM le classement en niveau CC ou CMA (complication ou comorbidité majeure) — il est donc à la fois un indicateur clinique et un levier de valorisation financière, ce qui peut biaiser les comparaisons inter-établissements si le codage est motivé par la T2A plutôt que par la clinique.
- La dénutrition peut figurer en DP (diagnostic principal) uniquement quand elle est le motif principal d'hospitalisation — dans la grande majorité des cas, elle est codée en DA.
- Les actes CCAM de nutrition artificielle (nutrition entérale JVJF001, parentérale JVJB001) sont un proxy de la prise en charge nutritionnelle et permettent de croiser le codage diagnostique avec l'acte thérapeutique.

## Utilité
- **Audit de la qualité du codage nutritionnel** : comparer le taux de dénutrition documentée par service avec les prévalences attendues dans la littérature (NutriAction II : 30 % en gériatrie, 20 % en médecine interne) pour identifier les services sous-codeurs et cibler les formations DIM/soignants.
- **Pilotage médico-économique** : la dénutrition sévère (E43) est une CMA dans de nombreux GHM — son codage systématique permet de classer les séjours en niveau 3 ou 4 et d'optimiser légitimement la valorisation T2A des séjours complexes ; la quantification de cet impact justifie les investissements dans les programmes de dépistage nutritionnel (NRS-2002, MNA).
- **Évaluation des programmes de dépistage nutritionnel** : mesurer l'évolution du taux de dénutrition documentée avant/après la mise en place d'un dépistage systématique à l'admission (NRS-2002 obligatoire depuis la certification HAS V2020) pour évaluer l'efficacité du programme et l'amélioration du codage.
- **Signal qualité et sécurité des soins** : la dénutrition non documentée et non traitée est associée à une augmentation de 2 à 4 fois du risque de complications infectieuses, de chutes et de réhospitalisations — son taux de détection est un proxy de la qualité de la surveillance nutritionnelle.
- **Comparaison inter-établissements et benchmarking** : ScanSanté permet d'accéder au taux de codage des codes E40-E46 par établissement et par CMD — un taux structurellement inférieur à la moyenne régionale déclenche un audit de pratiques de codage et de dépistage.
- **Dialogue avec les équipes de soins** : les données PMSI sur la dénutrition documentée fournissent un argument objectif aux diététiciennes et aux équipes de nutrition pour justifier des ressources supplémentaires (équipe de nutrition transversale, référents nutritionnels par service).

## Sources de Données
- **PMSI MCO** : codes E40-E46 en diagnostics associés (DA) dans les RSS — disponibles directement dans ScanSanté par établissement, CMD et GHM, sans traitement supplémentaire.
- **ScanSanté** : filtrage des séjours par code de diagnostic associé E40-E46, croisement avec le GHM et le niveau de sévérité — calcul immédiat du taux de dénutrition documentée et de son impact sur la valorisation T2A.
- **Données locales DIM** : croisement des codes E40-E46 avec les actes CCAM de nutrition artificielle (entérale, parentérale) pour évaluer la cohérence codage/prise en charge ; analyse par service et par praticien codeur.
- **Littérature de prévalence (NutriAction, PNNS)** : études épidémiologiques françaises fournissant les prévalences attendues de dénutrition par type de service, servant de dénominateur pour calculer le ratio codage/prévalence réelle.

## Exemple de Valeurs
- **Taux de dénutrition documentée (codes E40-E46 en DA)** : 3-8 % des séjours MCO dans les établissements qui codent activement, contre une prévalence réelle estimée à 20-40 % en médecine et gériatrie (sous-codage massif).
- **Gériatrie (CMD 23)** : 8-15 % de dénutrition documentée dans les meilleurs codeurs ; prévalence réelle estimée à 30-50 % selon les études NutriAction II (Raynaud-Simon, 2011).
- **Cancérologie (CMD 17)** : 6-12 % de codage de la dénutrition ; prévalence réelle estimée à 30-70 % selon la localisation tumorale (ORL, digestif, poumon).
- **Médecine interne et polyvalente** : 4-8 % de dénutrition documentée ; prévalence réelle estimée à 20-30 %.
- **Chirurgie digestive (CMD 6)** : 5-10 % de codage ; la dénutrition préopératoire est pourtant un facteur pronostique majeur de morbi-mortalité chirurgicale.
- **Impact T2A du codage E43 (CMA)** : dans les GHM où E43 est CMA, le passage en niveau 3 ou 4 représente une majoration tarifaire de 30-80 % par séjour — l'impact annuel pour un établissement de 20 000 séjours avec 5 % de dénutrition sévère non codée peut atteindre 500 000 à 2 000 000 €.
- **Évolution après programme de dépistage NRS-2002** : les établissements ayant déployé un dépistage systématique à l'admission observent une augmentation de 50-200 % du taux de codage de la dénutrition dans les 12-24 mois suivant le déploiement.

## Limites
- Le taux de dénutrition documentée mesure le codage, pas la prévalence réelle — un établissement avec un taux faible peut avoir une excellente prise en charge nutritionnelle mais un sous-codage systématique, tandis qu'un taux élevé peut refléter un sur-codage motivé par la T2A.
- La motivation financière du codage (dénutrition = CMA dans certains GHM) crée un biais de sélection : les établissements sensibilisés aux enjeux de valorisation coderont davantage la dénutrition que les autres, indépendamment de la qualité clinique de leur prise en charge.
- Les codes E40-E46 de la CIM-10 ne distinguent pas les dénutritions de gravités cliniques très différentes (E44 légère vs E43 sévère) avec la précision nécessaire pour des comparaisons épidémiologiques rigoureuses — le recours aux critères HAS (perte de poids, IMC, albuminémie) permettrait une classification plus fine mais n'est pas disponible dans le PMSI.
- La dénutrition documentée en DA peut être préexistante à l'hospitalisation (dénutrition chronique) ou développée pendant le séjour (dénutrition iatrogène) — le PMSI ne permet pas de distinguer ces deux situations aux enjeux cliniques et organisationnels très différents.
- L'indicateur ne mesure pas la qualité de la prise en charge nutritionnelle (prescription d'une nutrition adaptée, suivi du poids, consultation diététique) — il ne renseigne que sur l'acte de dépistage et de codage.

## Références
- [HAS - Dénutrition : dépistage et diagnostic chez l'adulte et l'enfant (2021)](https://www.has-sante.fr/)
- [ATIH - Impact du codage des comorbidités sur la classification GHM](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des diagnostics associés par établissement](https://www.scansante.fr/)
- [Raynaud-Simon A. et al. - NutriAction II : prévalence de la dénutrition en établissements de soins, 2011](https://www.ncbi.nlm.nih.gov/pubmed/)
- [PNNS - Programme National Nutrition Santé : dépistage de la dénutrition hospitalière](https://www.mangerbouger.fr/)
