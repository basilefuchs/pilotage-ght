# Taux de Recours à la Liste en Sus

## Définition

La **liste en sus** (LES) est la liste officielle des médicaments et dispositifs médicaux implantables (DMI) dont le coût est remboursé par l'Assurance Maladie **en sus du GHS** (Groupe Homogène de Séjours), car leur coût d'acquisition est jugé trop élevé pour être inclus dans la tarification forfaitaire. Elle est définie par arrêté ministériel et comprend deux sous-listes :

- **LES médicaments** : molécules onéreuses (anticancéreux, immunosuppresseurs, biothérapies...) identifiées par leur code UCD (Unité Commune de Dispensation)
- **LES DMI** : dispositifs médicaux implantables onéreux (prothèses valvulaires, stents, neurostimulateurs...) identifiés par leur code LPP (Liste des Produits et Prestations)

Ces deux sous-listes sont tracées dans le **FICHCOMP** (Fichier Complémentaire au RSA) — fichier PMSI obligatoire pour les établissements ayant des dispensations en sus.

```
Taux_LES = nb_RSA_avec_au_moins_1_ligne_FICHCOMP / nb_RSA_total × 100
```

Cet indicateur est absent des outils PMSI standards : le CMI mesure la lourdeur du casemix en poids GHM mais ne capture pas l'intensité thérapeutique hors-forfait ; le `taux_sejours_actes_ccam_valorises` porte sur les actes CCAM, non sur les médicaments/DMI. Le taux de recours LES mesure la **fraction des séjours nécessitant des thérapeutiques hors-forfait**, reflet direct de l'intensité et de la complexité des soins dispensés.

L'ATIH suit ce taux dans ses publications annuelles sur la dépense hospitalière en sus, et les ARS l'utilisent dans le cadre des **Contrats de Bon Usage (CBU)** pour le suivi de l'utilisation conforme aux autorisations de mise sur le marché (AMM).

## Calcul

Sources : PMSI MCO RSA + FICHCOMP MED (médicaments) + FICHCOMP DMI (dispositifs médicaux implantables).

```
Population : tous RSA transmis pour un FINESS/période

Étape 1 — Chargement du FICHCOMP :
  FICHCOMP_MED : fichier des médicaments en sus
    Variables clés : NOFINESS, NUM_RSA (clé de jointure avec le RSA),
                     UCD (code médicament), NB_UCD (quantité), MONTANT_TOTAL
  FICHCOMP_DMI : fichier des DMI en sus
    Variables clés : NOFINESS, NUM_RSA, COD_LPP (code DMI), MONTANT_TOTAL

Étape 2 — Jointure FICHCOMP × RSA par NUM_RSA :
  RSA_avec_LES_MED = RSA distincts ayant ≥ 1 ligne dans FICHCOMP_MED
  RSA_avec_LES_DMI = RSA distincts ayant ≥ 1 ligne dans FICHCOMP_DMI
  RSA_avec_LES     = union(RSA_avec_LES_MED, RSA_avec_LES_DMI)
                   = RSA avec au moins 1 LES médicament OU DMI

Étape 3 — Calcul des taux :
  nb_RSA_total   = count(RSA)
  nb_RSA_LES     = count(RSA_avec_LES)  [dédupliqué]
  nb_RSA_LES_MED = count(RSA_avec_LES_MED)
  nb_RSA_LES_DMI = count(RSA_avec_LES_DMI)

  Taux_LES_global = nb_RSA_LES     / nb_RSA_total × 100
  Taux_LES_MED    = nb_RSA_LES_MED / nb_RSA_total × 100
  Taux_LES_DMI    = nb_RSA_LES_DMI / nb_RSA_total × 100

Étape 4 — Montant moyen en sus par RSA LES :
  Montant_total_LES = Σ(MONTANT_TOTAL_FICHCOMP_MED) + Σ(MONTANT_TOTAL_FICHCOMP_DMI)
  Montant_moyen_LES = Montant_total_LES / nb_RSA_LES   [€ par séjour avec LES]

Étape 5 — Ventilation par CMD et famille GHM :
  Taux_LES_CMD = nb_RSA_LES_CMD / nb_RSA_CMD × 100   [pour chaque CMD active]
  → identifier les CMDs à fort recours LES (CMD 17 oncologie, CMD 05 cardio-interventionnelle)

Étape 6 — Conformité CBU (Contrat de Bon Usage) :
  Pour chaque molécule UCD en sus :
    Taux_conformité_AMM = nb_prescriptions_dans_AMM / nb_prescriptions_total × 100
    [nécessite le registre CBU interne — non disponible dans FICHCOMP seul]

Cas limites :
  - RSA sans FICHCOMP : tous les établissements n'ont pas d'activité en sus
    → Taux_LES = 0% est une valeur légitime pour un établissement sans oncologie ni cardiologie interventionnelle
  - Arrêté liste en sus révisé en cours d'année : une molécule peut entrer ou sortir de la LES
    → utiliser la version de l'arrêté en vigueur à la date de dispensation (FICHCOMP date)
  - Double comptage possible : si un même RSA a des lignes MED et DMI,
    ne compter qu'une fois dans nb_RSA_LES (union, pas somme)
```

Indicateurs dérivés :

```
Intensité moyenne en sus (€/séjour LES) :
  = Montant_total_LES / nb_RSA_LES
  Mesure le coût moyen d'une dispensation en sus — proxy de complexité thérapeutique

Part des dépenses LES dans la recette T2A totale :
  = Montant_total_LES / (Σ GHS + Montant_total_LES) × 100
  Alerte si > 25% : dépendance élevée aux remboursements hors-forfait

Top-10 UCD par montant total :
  → identifier les molécules concentrant >80% des dépenses LES
  → cible prioritaire des négociations pharmaceutiques et des CBU

Taux LES par CMD (carte de chaleur) :
  → visualisation de la distribution de l'intensité thérapeutique en sus par spécialité
```

## Utilité

- **Mesure de l'intensité thérapeutique hors-forfait** : le taux LES complète le CMI pour caractériser la complexité réelle des soins — un service d'oncologie avec Taux_LES = 85% et Montant_moyen = 4 500€/séjour a une charge de travail pharmaceutique et un risque financier très différents d'un service avec Taux_LES = 5%
- **Suivi des Contrats de Bon Usage (CBU) avec l'ARS** : les CBU exigent le suivi du taux d'utilisation conforme à l'AMM pour chaque molécule en sus — le FICHCOMP est la source officielle ; un suivi mensuel du Taux_LES par molécule permet d'anticiper les revues CBU et d'éviter les pénalités de remboursement
- **Négociation des achats pharmaceutiques** : le classement des Top-10 UCD par montant total fournit au pharmacien hospitalier les données de négociation avec les laboratoires pharmaceutiques — un établissement qui représente 2% du volume national d'une molécule onéreuse a un levier de négociation réel
- **Anticipation des impacts des sorties de liste en sus** : quand l'ATIH retire une molécule de la LES (intégration dans le GHS), l'établissement subit une baisse des remboursements en sus compensée théoriquement par la hausse des GHS — mesurer le Montant_total_LES de la molécule concernée permet d'estimer l'impact financier avant la publication officielle
- **Benchmark intra-GHT sur la prise en charge oncologique** : comparer les Taux_LES_CMD17 entre établissements du GHT ayant une activité de cancérologie révèle des différences de protocoles thérapeutiques — un écart > 15 points sur la même CMD justifie un audit des pratiques
- **Identification des sous-déclarations FICHCOMP** : un établissement avec une activité oncologique connue (PMSI CMD 17 élevée) mais un Taux_LES < 20% présente un risque de sous-déclaration FICHCOMP — chaque médicament non déclaré est une recette en sus non perçue

## Sources de Données

- **FICHCOMP MED** : fichier complémentaire médicaments en sus — variables `NOFINESS`, `NUM_RSA`, `UCD` (code médicament 7 caractères), `NB_UCD` (quantité), `MONTANT_TOTAL` (€), `DATE_DISPENSATION` — transmission mensuelle à l'ATIH
- **FICHCOMP DMI** : fichier complémentaire DMI en sus — variables `NOFINESS`, `NUM_RSA`, `COD_LPP` (code LPP), `MONTANT_TOTAL` (€) — transmission mensuelle à l'ATIH
- **PMSI MCO RSA** : pour le dénominateur `nb_RSA_total`, la jointure par `NUM_RSA`, et la ventilation par CMD/GHM
- **Arrêtés liste en sus** (Journal Officiel) : liste officielle des UCD et LPP en sus, révisée par arrêté ministériel — téléchargeable sur le site ATIH et sur Légifrance

## Exemple de Valeurs

- **CHU avec cancérologie et cardiologie interventionnelle** : Taux_LES_global = 12–20% ; Taux_LES_MED = 10–18% ; Montant_moyen_LES = 3 000–8 000€/séjour LES
- **CH généraliste sans oncologie** : Taux_LES_global = 1–4% (principalement DMI : stents, prothèses)
- **Centre de lutte contre le cancer (CLCC)** : Taux_LES_global = 50–80% (activité quasi-exclusivement oncologique)
- **CMD 17 (Affections malignes) — CHU** : Taux_LES_CMD17 = 60–85% (la majorité des séjours d'oncologie reçoit au moins un médicament en sus)
- **CMD 05 (Cardiologie interventionnelle)** : Taux_LES_CMD05 = 20–40% (stents et dispositifs valvulaires dominants dans FICHCOMP DMI)
- **Alerte sous-déclaration FICHCOMP** : CMD 17 avec Taux_LES < 20% dans un établissement avec > 500 RSA oncologiques → audit FICHCOMP urgent

## Limites

- **FICHCOMP non exhaustif dans toutes les configurations SIH** : l'interface entre le logiciel de pharmacie et le système de production PMSI n'est pas toujours complète — des dispensations réelles peuvent ne pas alimenter le FICHCOMP, conduisant à une sous-estimation du taux et une perte de recettes en sus
- **Liste en sus révisée annuellement** : les entrées et sorties de la LES par arrêté modifient le périmètre de l'indicateur d'une année sur l'autre — les comparaisons longitudinales nécessitent d'identifier et d'exclure les molécules dont le statut a changé
- **Hétérogénéité des pratiques de codage DMI** : le codage des LPP dans le FICHCOMP DMI est moins standardisé que le codage UCD médicaments — certains établissements sous-codent les DMI, rendant la comparaison inter-établissements sur le FICHCOMP DMI moins fiable
- **Non-portabilité hors MCO** : la liste en sus ne s'applique qu'au champ MCO — le SSR et la psychiatrie n'ont pas de FICHCOMP équivalent ; l'indicateur est non calculable pour ces champs
- **Montants en sus ≠ coût réel** : les montants FICHCOMP sont les prix de facturation, non les prix d'achat réels (remises, marchés groupés) — pour le pilotage économique, les montants FICHCOMP doivent être croisés avec les prix d'achat du marché pharmaceutique

## Références

- [ATIH — Manuel FICHCOMP médicaments et DMI, documentation technique de production](https://www.atih.sante.fr/)
- [Arrêté fixant la liste des médicaments pouvant être pris en charge en sus des prestations d'hospitalisation (Journal Officiel — actualisé annuellement)]
- [Arrêté fixant la liste des DMI pouvant être pris en charge en sus des prestations d'hospitalisation (Journal Officiel — actualisé annuellement)]
- [ATIH — Rapports annuels sur les dépenses en sus : analyse nationale des médicaments et DMI facturés en sus du GHS](https://www.atih.sante.fr/)
- [Circulaire DHOS/DSS relative aux Contrats de Bon Usage des médicaments et des DMI en sus : cadre réglementaire du suivi CBU]
