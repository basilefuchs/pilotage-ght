# Taux de Biologie Ambulatoire Redondante en Période Préopératoire

## Définition

Cet indicateur mesure la proportion de patients pris en charge pour une chirurgie élective (programmée) qui ont bénéficié d'examens biologiques redondants au cours des 30 jours précédant la date d'intervention. La redondance est définie comme la réalisation du même acte biologique — identifié par son code NABM (Nomenclature des Actes de Biologie Médicale) — prescrit par au moins deux médecins distincts et exécuté dans au moins deux laboratoires distincts dans la fenêtre J-30 à J-1 avant la date d'entrée chirurgicale. Le calcul repose sur le croisement du PMSI MCO (identification des séjours de chirurgie programmée par le mode d'entrée P et les actes CCAM chirurgicaux) avec le DCIR (tables ER_BIO_F ou ER_PRS_F, cotations BHN/B, identification du prescripteur et de l'exécutant). Cet indicateur capture une forme spécifique de défaillance de pertinence : le bilan biologique préopératoire est dupliqué parce que l'anesthésiste, le chirurgien et/ou le médecin traitant prescrivent indépendamment les mêmes examens, sans consultation des résultats récents existants. Les recommandations HAS de 2012 déconseillent déjà la biologie préopératoire systématique et préconisent une biologie ciblée selon le risque clinique — la redondance aggrave ainsi l'inappropriateness déjà documentée des bilans systématiques.

## Calcul

Identification de la population cible et des actes redondants :

```
Population cible : patients hospitalisés en chirurgie élective (programmée)
  → PMSI RSA : mode entrée = P (programmé) + CCAM chirurgical (famille 01-12 de la CCAM chirurgie)
  → Ou GHM en CM01-20 avec acte CCAM chirurgical

Période de référence : J-30 à J-1 avant la date d'entrée PMSI (DATEENT)

Actes de biologie redondants (DCIR ER_BIO_F ou ER_PRS_F) :
  → Identifiés par cotation NABM (ex. : NFS=0110, créatinine=1401, TP/TCA=0111,
    glycémie=0109, ionogramme=1501, bilan hépatique=1104...)
  → Redondance = même cotation NABM, ≥2 prescripteurs distincts (PSP_PPS_NUM différents),
    ≥2 exécutants distincts (ORG_EXE_NUM différents),
    dans la fenêtre J-30 à J-1
```

Calcul du taux principal et des indicateurs dérivés :

```
Taux de biologie redondante :
  Numérateur   = patients avec ≥1 doublon de biologie sur période J-30 à J-1
  Dénominateur = total patients chirurgie élective du GHT en période N
  Taux (%)     = Numérateur / Dénominateur × 100

Indicateurs dérivés :
  → Nombre moyen de doublons par patient concerné
  → Taux de redondance par type de biologie (NFS, créatinine, TP, glycémie...)
  → Taux de redondance par spécialité chirurgicale (orthopédie, digestif, urologie...)
  → Coût moyen des biologies redondantes par patient (BSE_REM_MNT doublons)
  → Délai moyen entre les deux prescriptions de biologie identique
```

## Utilité

- **Quantification du coût de la redondance** : calculer le montant total remboursé pour les biologies préopératoires redondantes sur le territoire du GHT — argument économique direct pour les médecins et la CPAM dans le cadre du CAQES
- **Identification des filières chirurgicales à risque de redondance** : certaines spécialités (orthopédie programmée, chirurgie bariatrique) sont plus exposées en raison du nombre d'intervenants dans le parcours préopératoire — permet de cibler les actions d'amélioration
- **Évaluation de la coordination ville-hôpital en préopératoire** : la redondance est un marqueur de défaut de communication entre le médecin traitant (qui prescrit une biologie de routine) et l'anesthésiste (qui prescrit son propre bilan) — indicateur du niveau d'intégration du parcours préopératoire sur le territoire du GHT
- **Impact des protocoles de bilan préopératoire standardisé** : mesurer l'évolution du taux de redondance avant et après l'introduction d'un protocole de bilan préopératoire validé entre les services hospitaliers et les médecins généralistes du territoire
- **Dialogue CAQES** : la biologie redondante est un indicateur de pertinence des actes inclus dans les Contrats d'Amélioration de la Qualité et de l'Efficience des Soins — cet indicateur peut alimenter directement les objectifs contractuels
- **Formation des prescripteurs** : identifier les prescripteurs (médecins généralistes, spécialistes) présentant les taux de redondance les plus élevés afin de conduire des actions de retour d'information ciblées, anonymisées et collectives

## Sources de Données

- **DCIR ER_BIO_F** : table des actes de biologie médicale du DCIR, contenant la cotation NABM, l'identification du prescripteur (PSP_PPS_NUM), l'identification du laboratoire exécutant (ORG_EXE_NUM), la date d'exécution et les montants remboursés (BSE_REM_MNT)
- **DCIR ER_PRS_F** : table des prestations du DCIR, utilisée en complément pour les actes de biologie intégrés dans des prestations de ville non ventilées dans ER_BIO_F
- **PMSI MCO RSA** : table des résumés de sortie anonymisés, fournissant la date d'entrée (DATEENT), le mode d'entrée (= P pour programmé), les actes CCAM chirurgicaux et le GHM permettant d'identifier les séjours de chirurgie élective
- **DCIR IR_BEN_R** : référentiel bénéficiaire du DCIR, permettant le chaînage entre PMSI et DCIR via le NIR crypté (BEN_NIR_PSA) et fournissant les informations démographiques et géographiques du patient
- **NABM** : Nomenclature des Actes de Biologie Médicale, référentiel des codes cotation permettant d'identifier et de comparer les actes biologiques entre prescriptions distinctes

## Exemple de Valeurs

- **Prévalence nationale estimée** : 15 à 25 % des patients en chirurgie élective présentent au moins un doublon biologique dans les 30 jours précédant l'intervention
- **Actes les plus fréquemment dupliqués** : NFS (numération formule sanguine, NABM 0110), créatinine (NABM 1401), TP/TCA (coagulation, NABM 0111), glycémie (NABM 0109) — tous inclus dans les batteries préopératoires standard
- **Coût moyen des biologies redondantes par patient** : 30 à 80 € selon le nombre de doublons et les actes concernés
- **Coût national estimé** : 200 à 400 M€ par an pour l'ensemble de la biologie préopératoire et pré-procédure redondante
- **Réduction après protocole standardisé** : les études disponibles montrent une réduction de 40 à 60 % des prescriptions redondantes après mise en place d'un protocole de bilan préopératoire formalisé
- **Délai médian entre deux prescriptions identiques** : 7 à 14 jours — la seconde prescription est généralement réalisée par l'anesthésiste lors de la consultation préanesthésique

## Limites

- Un examen biologique répété n'est pas systématiquement cliniquement inapproprié : si le premier résultat était anormal, un contrôle est justifié ; l'indicateur ne peut pas distinguer ces situations sans données cliniques, ce qui entraîne une surestimation de la redondance inappropriée
- Le DCIR renseigne la spécialité du prescripteur mais non l'indication clinique de la prescription — toutes les répétitions sont signalées comme potentiellement redondantes sans possibilité de vérification de l'inappropriateness réelle
- Certains actes biologiques sont réalisés à l'hôpital lors de la consultation préanesthésique (biologie externalisée ou réalisée en PUI) et peuvent ne pas figurer dans le DCIR si elles ne font pas l'objet d'une facturation en ville
- La fenêtre de 30 jours est une définition raisonnable mais arbitraire de la période préopératoire — certains patients ont une chirurgie planifiée plus de 30 jours à l'avance, ce qui peut conduire à une sous-estimation de la redondance réelle
- Le chaînage entre la date de chirurgie PMSI et les actes de biologie DCIR requiert un identifiant patient fiable (NIR crypté BEN_NIR_PSA) et un codage précis de la date d'entrée — toute imprécision de codage dégrade la qualité du calcul

## Références

- [HAS — Recommandations sur les examens préopératoires systématiques, 2012](https://www.has-sante.fr/)
- [CNAM — Indicateurs de pertinence des actes de biologie, CAQES](https://www.ameli.fr/)
- [SNDS — Table ER_BIO_F : biologie du DCIR](https://www.snds.gouv.fr/)
- [Société Française d'Anesthésie et Réanimation (SFAR) — Recommandations sur le bilan préopératoire](https://www.sfar.org/)
- [Fischer M. et al. — Preoperative testing: the role of the systematic review in the French context, Ann Fr Anesth Reanim 2012](https://www.sfar.org/)
