# Dépenses de Transport Sanitaire par Habitant sur le Territoire

## Définition

L'indicateur de transport sanitaire mesure le total des dépenses de transport médical remboursées (VSL — véhicule sanitaire léger, ambulances, taxis conventionnés) par habitant et par an, stratifié par commune et par IRIS au sein du territoire du GHT. Cet indicateur est calculé à partir du DCIR (table ER_TRS_F ou ER_PRS_F avec les codes d'actes transport) et constitue à la fois un proxy d'accessibilité géographique aux soins (les résidents éloignés des structures de soin voyagent davantage) et un indicateur de pertinence (les prescriptions de transport peuvent être inappropriées). La France a dépensé environ 5,5 milliards d'euros en remboursements de transport sanitaire en 2022 (deuxième poste de dépenses ambulatoires après les médicaments), avec des variations géographiques massives : les départements ruraux dépensent 2 à 4 fois plus par habitant que les zones urbaines en raison de l'éloignement des structures de soins. Pour un GHT pilotant son offre de soins, la cartographie des dépenses de transport révèle directement où les soins ambulatoires font défaut, où la télémédecine pourrait se substituer au déplacement, et où les pratiques de prescription de transport sont potentiellement inappropriées.

## Calcul

```
Source DCIR — ER_PRS_F ou ER_TRS_F (table transport) :
  PRS_NAT_REF codes transport :
    → TM : transport en taxi médicalisé
    → TSA : transport par ambulance (brancard)
    → VSL : véhicule sanitaire léger
    → TR : transport en commun remboursé
    → TK : transport en taxi conventionné

Dépenses transport par habitant :
  Numérateur = Σ montants remboursés (BSE_REM_MNT) pour actes transport
    par commune de résidence du bénéficiaire (BEN_RES_COM)
  Dénominateur = Population INSEE de la commune (dernier recensement)
  Résultat = Dépenses transport / habitant / an (en euros)
```

```
Indicateurs dérivés :

Dépenses par mode de transport :
  → Part ambulance (%) : transport couché/assis urgent
  → Part VSL (%) : transport assis non-urgent, prescrit
  → Part taxi (%) : transport prescrit mais non-médicalisé

Dépenses transport par motif (croisement PMSI) :
  → Transport vers/depuis établissement MCO du GHT
  → Transport vers/depuis dialyse (ALD19)
  → Transport vers/depuis séances de chimiothérapie
  → Transport vers/depuis consultations externes

Taux de transports prescrits sans hospitalisation ultérieure :
  → Proxy d'inadéquation : patient transporté à l'hôpital, rentré à domicile sans hospitalisation
  → Suggère une prescription de transport non justifiée par une urgence vraie

Distance médiane domicile–établissement de recours (km) :
  → Calculée par géocodage BEN_RES_COM → coordonnées établissement
  → Corrélation avec dépenses transport
```

## Utilité

- **Cartographie de l'accessibilité géographique** : les communes à forte dépense de transport/habitant signalent un éloignement structurel des soins — argument géographique pour l'implantation de consultations avancées, MSP ou téléconsultations dans les zones identifiées
- **Identification des transports potentiellement évitables** : les séries de transports VSL pour dialyse (3×/semaine) représentent 40% du budget transport — la transplantation rénale ou la dialyse à domicile sont des alternatives coût-efficaces à quantifier
- **Évaluation de la pertinence des prescriptions de transport** : un taux élevé de transports en ambulance pour des patients assis (non-allongés) est un signal de sur-prescription — dialogue avec les prescripteurs et CPAM
- **Retour sur investissement des MSP et consultations avancées** : mesurer la réduction des dépenses de transport dans les zones équipées d'une nouvelle offre de soins de proximité après ouverture
- **Benchmark territorial** : comparer les dépenses de transport/habitant entre les communes du GHT pour identifier les zones structurellement défavorisées en termes d'accessibilité physique
- **Négociation avec l'ARS** : argument financier pour justifier des investissements en offre de soins locale — "1 MSP créée dans la commune X économiserait Y euros/an de transport sanitaire"

## Sources de Données

- **DCIR ER_PRS_F / ER_TRS_F** : transport remboursé, montant BSE_REM_MNT, code acte PRS_NAT_REF — source principale des dépenses de transport sanitaire
- **DCIR IR_BEN_R** : commune de résidence du bénéficiaire (BEN_RES_COM) — permet la géolocalisation des dépenses par commune
- **INSEE — population communale** : dénominateur pour le calcul des dépenses par habitant (dernier recensement disponible)
- **PMSI MCO** : motif d'hospitalisation pour croisement avec les transports — identification du motif du recours ayant généré le transport
- **IGN — géocodage communes** : calcul de la distance domicile-établissement à partir des coordonnées géographiques des communes et des établissements de soins

## Exemple de Valeurs

- **Moyenne nationale (2022)** : ~80-90 €/habitant/an en remboursements de transport sanitaire
- **Départements ruraux (Creuse, Cantal)** : 150-200 €/habitant/an — 2 à 3 fois la moyenne nationale
- **Part dialyse dans le budget VSL** : ~35-40% des dépenses VSL nationales sont liées aux transports pour dialyse
- **Ambulances pour patients non-allongés** : 15-20% des actes ambulance potentiellement inappropriés (patients assis transportés en brancard)
- **Effet distance** : chaque 10 km supplémentaires vers l'hôpital le plus proche est associé à ~25 €/habitant/an de dépenses de transport additionnelles
- **Potentiel de substitution téléconsultation** : 20-30% des consultations nécessitant un transport identifiées comme potentiellement substituables par téléconsultation dans les études pilotes ARS

## Limites

- BEN_RES_COM correspond à la résidence administrative du bénéficiaire, non au point de départ réel du transport — légère surestimation ou sous-estimation des distances réelles parcourues
- Les taxis conventionnés n'apparaissent dans le DCIR que s'ils font l'objet d'une demande de remboursement — les arrangements de transport privé informels ne sont pas captés
- Ne distingue pas les transports longue distance nécessaires (orientation vers un centre spécialisé) des transports évitables (absence d'offre de soins locale)
- La standardisation IQSS des dépenses de transport n'est pas encore établie au niveau national — les comparaisons interdépartementales nécessitent une prudence compte tenu des pratiques conventionnelles locales
- Ne capture pas les frais de transport non remboursés par l'Assurance Maladie (véhicule personnel du patient, participations forfaitaires)

## Références

- [CNAM — Données de remboursement des transports sanitaires](https://www.ameli.fr/)
- [DREES — Les dépenses de transport sanitaire en France](https://www.drees.solidarites-sante.gouv.fr/)
- [SNDS — ER_TRS_F table transport du DCIR](https://www.snds.gouv.fr/)
- [HAS — Référentiel de prescription des transports](https://www.has-sante.fr/)
- [IGAS — Rapport sur les transports sanitaires 2019](https://www.igas.gouv.fr/)
