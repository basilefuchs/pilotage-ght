# Indicateurs de Pertinence des Antibiotiques en Ambulatoire

## Définition
Ces indicateurs mesurent la pertinence des prescriptions antibiotiques en soins ambulatoires (pharmacies de ville) pour la population assurée du territoire du GHT. Ils sont calculés à partir des dispensations pharmaceutiques de la table DCIR ER_PHA_F. Le mésusage des antibiotiques — en volume excessif, sur indications non fondées ou avec des molécules inadaptées — constitue un enjeu majeur de santé publique en raison de ses conséquences sur l'émergence de résistances bactériennes, la survenue d'infections à *Clostridioides difficile* et la survenue d'effets indésirables évitables.

Thilly N. et al. (Euro Surveillance, 2020) ont validé 10 indicateurs proxy de pertinence antibiotique calculables à partir des données d'assurance maladie françaises (DCIR), sans nécessiter l'accès aux dossiers médicaux individuels. Ces 10 proxies sont : (1) proportion d'antibiotiques à large spectre, (2) antibiothérapie lors d'infections respiratoires virales (bronchite, rhinopharyngite — CIM-10 J00–J22), (3) dispensations sans consultation médicale préalable, (4) prescriptions en double (même antibiotique prescrit deux fois simultanément), (5) antibiothérapie chez l'enfant de moins de 2 ans, (6) durées de traitement longues (> 10 jours pour des indications courantes), (7) co-prescription fluoroquinolones + AINS, (8) taux d'antibiotiques de la catégorie « Watch » selon la classification AWaRe de l'OMS, (9) prescriptions répétées et courtes chez un même patient sur 12 mois (≥ 4 cures), (10) dispensations à des résidents d'établissements d'hébergement pour personnes âgées (EHPAD).

## Calcul
Le taux d'antibiothérapie ambulatoire de base est calculé comme suit :

```
Taux d'antibiothérapie ambulatoire =
    (Nombre de dispensations d'antibiotiques / Population assurée) × 1 000 personnes-années
```

Les antibiotiques sont identifiés dans ER_PHA_F par leur code CIP13, rattaché à la classe ATC J01* via la base nationale BDPM. Le croisement avec ER_PRS_F permet de récupérer la spécialité du prescripteur et le contexte de la consultation.

**Structure des 10 indicateurs proxy (Thilly 2020) :**

| Proxy | Numérateur | Dénominateur |
|---|---|---|
| 1. Large spectre | Dispensations d'antibiotiques large spectre (amoxicilline-acide clavulanique, céphalosporines 3G, fluoroquinolones) | Total dispensations d'antibiotiques |
| 2. Infections virales respiratoires | Dispensations avec diagnostic J00–J22 (en lien avec PMSI ou arrêt maladie) | Total dispensations pour épisode respiratoire |
| 3. Sans consultation préalable | Dispensations sans acte de consultation dans les 7 jours précédents (ER_PRS_F) | Total dispensations d'antibiotiques |
| 4. Doublons | Chevauchements de prescriptions d'un même antibiotique sur la même période | Total dispensations d'antibiotiques |
| 5. Enfants < 2 ans | Dispensations chez les bénéficiaires de moins de 2 ans | Total dispensations d'antibiotiques |
| 6. Durées longues | Dispensations équivalant à > 10 jours de traitement pour une indication courante | Total dispensations pour indication courante |
| 7. Fluoroquinolone + AINS | Dispensations simultanées de fluoroquinolone (J01MA*) et d'AINS (M01A*) | Total dispensations de fluoroquinolones |
| 8. Antibiotiques « Watch » | Dispensations d'antibiotiques classés « Watch » (AWaRe OMS) | Total dispensations d'antibiotiques |
| 9. Cures répétées | Patients ayant ≥ 4 cures d'antibiotiques sur une fenêtre de 12 mois glissants | Nombre total de patients ayant eu au moins une dispensation |
| 10. Résidents EHPAD | Dispensations à des bénéficiaires résidant en EHPAD (croisement avec données de facturation établissement) | Total dispensations d'antibiotiques |

**Granularité géographique :** analyse possible par commune, IRIS, ou par spécialité du prescripteur (médecin généraliste, pédiatre, urgentiste) à partir des champs de ER_PRS_F.

## Utilité
- **Identification des zones à prescriptions excessives** : repérer les communes ou IRIS du territoire GHT présentant des taux d'antibiothérapie ambulatoire significativement supérieurs à la médiane nationale ou régionale.
- **Benchmarking des médecins généralistes** : comparer anonymisées les pratiques des prescripteurs du territoire, avec restitution individualisée pour alimenter des démarches de retour d'information (feedback) et de DPC.
- **Évaluation des programmes de bon usage (AMS)** : mesurer l'effet des interventions de stewardship antibiotique (campagnes de sensibilisation, outils d'aide à la prescription) sur les taux de dispensations et la distribution des proxies.
- **Dialogue avec la CPAM et l'ARS** : fournir aux instances de régulation des indicateurs territoriaux argumentés pour les conventions avec les professionnels de santé et les plans régionaux de maîtrise des résistances.
- **Identification des patients à risque** : repérer les patients présentant des cures répétées ou une co-prescription à risque (fluoroquinolones + AINS) pour des actions de prévention des infections à *C. difficile*.
- **Ciblage des interventions éducatives** : orienter les actions de formation vers les zones ou spécialités présentant les profils de prescription les moins conformes.

## Sources de Données
- **DCIR ER_PHA_F** : table principale des dispensations pharmaceutiques remboursées en ville — contient le code CIP13 du médicament dispensé, la date de dispensation, le code du prescripteur et le bénéficiaire pseudonymisé.
- **DCIR ER_PRS_F** : table des prestations de soins — permet de retrouver la spécialité du prescripteur (PS_SPE_COD), le contexte de la consultation et de croiser la dispensation avec un acte médical préalable.
- **BDPM (Base de Données Publique des Médicaments)** : table de correspondance CIP13 → code ATC, permettant de filtrer la classe J01* (antibactériens à usage systémique) et d'identifier les sous-classes (fluoroquinolones J01MA*, céphalosporines J01D*, etc.).
- **Classification AWaRe de l'OMS** : liste de référence permettant de stratifier les antibiotiques en catégories Access, Watch et Reserve pour le suivi des antibiotiques à usage restreint.
- **CIM-10** : codes diagnostiques utilisés pour le contexte clinique, disponibles lorsqu'un croisement est réalisé avec le PMSI MCO/HAD ou avec les formulaires d'arrêt de travail (IJ) contenant un diagnostic.

## Exemple de Valeurs
- **Taux national moyen** : 800 à 900 dispensations d'antibiotiques pour 1 000 personnes-années — la France reste l'un des pays européens les plus consommateurs d'antibiotiques en ambulatoire.
- **Proportion d'antibiotiques « Watch » (AWaRe)** : environ 25 à 30 % au niveau national ; la cible recommandée par l'OMS est inférieure à 20 % des volumes dispensés.
- **Antibiothérapie pour infections respiratoires virales** : environ 30 à 40 % des cures antibiotiques hivernales seraient prescrites pour des pathologies virales ne justifiant pas d'antibiothérapie.
- **Réduction par les programmes AMS** : les programmes d'antibiothérapie raisonnée documentés en France et en Europe ont montré des réductions de 10 à 20 % des prescriptions inappropriées.
- **Taux de fluoroquinolones** : en baisse continue depuis les restrictions de l'ANSM en 2019, passant d'environ 12 % à 8 % des doses définies journalières (DDJ) antibiotiques dispensées.

## Limites
- Le DCIR trace les dispensations pharmaceutiques, non les diagnostics cliniques : il est impossible de vérifier l'indication médicale d'une prescription sans croisement avec les formulaires d'arrêt de travail ou le PMSI, ce qui limite la distinction entre antibiothérapie injustifiée et antibiothérapie justifiée non documentée dans les données remboursement.
- Les indicateurs proxy sont des mesures indirectes : une dispensation classée « potentiellement inappropriée » peut être cliniquement justifiée dans un contexte non capturé par les données administratives.
- L'analyse au niveau du prescripteur individuel est contrainte par les règles d'anonymisation du DCIR dans les extractions standard ; une mise en oeuvre dans un cadre conventionnel CPAM ou via le portail SNDS nécessite des autorisations spécifiques.
- Le DCIR ne couvre pas l'antibiothérapie intra-hospitalière, gérée par les pharmacies à usage intérieur (PUI) et tracée dans les systèmes d'information hospitaliers — une analyse du bon usage en établissement requiert une source complémentaire (OMéDIT, ATB-Raisonné).

## Références
- [Thilly N. et al. — Euro Surveillance 2020 : Proxy indicators of antibiotic appropriateness from French claims data](https://doi.org/10.2807/1560-7917.ES.2020.25.27.1900468)
- [OMS — Classification AWaRe des antibiotiques](https://www.who.int/publications/i/item/WHO-MHP-HPS-EML-2023.04)
- [ANSM — Consommation d'antibiotiques et résistances aux antibiotiques en France](https://www.ansm.sante.fr/)
- [SNDS — Documentation de la table ER_PHA_F (DCIR)](https://www.snds.gouv.fr/)
