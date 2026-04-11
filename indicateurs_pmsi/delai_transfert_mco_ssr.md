# Délai de Transfert MCO vers SSR

## Définition
Le délai de transfert MCO vers SSR mesure le temps écoulé entre la date de sortie d'un séjour en Médecine-Chirurgie-Obstétrique (MCO) et la date d'entrée dans une unité de Soins de Suite et de Réadaptation (SSR) pour le même patient. Cet indicateur reflète la fluidité du parcours post-aigu : un délai long signale une rupture de parcours préjudiciable à la récupération fonctionnelle du patient et génératrice de prolongations de séjour MCO injustifiées (présence de patients en attente d'aval SSR).

## Calcul
Le délai de transfert MCO vers SSR est calculé comme suit :

```
Délai de transfert (jours) = Date d'entrée en SSR − Date de sortie du séjour MCO
```

**Précisions méthodologiques** :
- Le calcul nécessite le chaînage des séjours PMSI MCO et SSR par patient (NIR crypté ou identifiant local).
- Seuls les séjours SSR faisant suite à un séjour MCO identifiable sont inclus (mode d'entrée SSR = transfert ou mutation, avec FINESS MCO renseigné).
- On distingue les transferts directs (délai = 0 jour, mutation le jour même) des transferts différés (délai ≥ 1 jour).
- L'indicateur est calculé en médiane (moins sensible aux valeurs extrêmes) et en distribution par tranches (0 j, 1-3 j, 4-7 j, 8-14 j, >14 j).
- L'analyse est segmentée par pathologie (AVC, fracture de hanche, chirurgie orthopédique, etc.) et par établissement émetteur/receveur.

## Utilité
- **Fluidité du parcours post-aigu** : identifier les filières MCO → SSR où les délais sont excessifs et pénalisent la récupération fonctionnelle du patient.
- **Réduction des journées indues en MCO** : les patients en attente d'aval SSR génèrent des journées MCO non justifiées médicalement, pénalisantes sur le plan tarifaire et organisationnel.
- **Pilotage des capacités SSR** : ajuster les capacités d'admission SSR (lits, délais de réponse de la plateforme Trajectoire) en fonction des flux MCO.
- **Évaluation des filières organisées** : mesurer l'impact des filières structurées (filière AVC, filière orthogériatrique) sur la réduction des délais de transfert.
- **Benchmarking intra-GHT** : comparer les délais entre les établissements MCO du GHT et leurs SSR partenaires pour identifier les dyades les moins fluides.

## Sources de Données
- **PMSI MCO et SSR** : chaînage par NIR crypté ou FINESS + dates de séjour pour reconstituer les parcours MCO → SSR.
- **Plateforme Trajectoire** : outil national de gestion des admissions en SSR, fournissant les délais de réponse aux demandes d'admission et les délais effectifs d'entrée.
- **ScanSanté** : module d'analyse des flux MCO → SSR par territoire.
- **Données locales** : logiciels de gestion des lits (TerritOR, Hexagone) pour les délais observés au niveau de chaque établissement.

## Exemple de Valeurs
- **Délai médian national MCO → SSR** : 3 à 5 jours pour les transferts programmés.
- **Filière AVC** : objectif de transfert en SSR neurologique ≤ 5 jours après stabilisation ; délai médian observé souvent entre 7 et 14 jours.
- **Filière fracture de hanche** : délai optimal ≤ 5 jours post-opératoires ; délais > 10 jours fréquents faute de places SSR disponibles.
- **Transferts directs (délai = 0)** : représentent 20-40 % des transferts MCO → SSR selon les territoires.
- **Journées d'attente en MCO** : estimées à 5-15 % des journées totales MCO dans certains GHT, liées à l'attente d'une place SSR.

## Limites
- Le chaînage MCO-SSR nécessite l'accès au NIR crypté, soumis à des contraintes réglementaires (SNDS, CNIL).
- Les transferts passant par le domicile (retour à domicile transitoire avant entrée en SSR) ne sont pas identifiables dans le PMSI sans chaînage longitudinal.
- Le délai optimal varie selon la pathologie et l'état clinique du patient : un délai court n'est pas toujours cliniquement justifié.
- L'indicateur ne mesure pas la qualité de l'orientation SSR (adéquation de la structure d'accueil aux besoins du patient).
- Les délais peuvent être artificiellement allongés par des refus d'admission SSR pour des raisons non médicales (capacité, financement).

## Références
- [Plateforme Trajectoire - Gestion des admissions SSR](https://trajectoire.sante-ra.fr/)
- [ATIH - Guide méthodologique PMSI SSR](https://www.atih.sante.fr/)
- [HAS - Parcours de soins AVC](https://www.has-sante.fr/)
- [ScanSanté - Flux MCO vers SSR](https://www.scansante.fr/)
