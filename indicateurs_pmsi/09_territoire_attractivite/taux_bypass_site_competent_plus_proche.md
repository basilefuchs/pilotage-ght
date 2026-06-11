# Taux de Bypass du Site Compétent le Plus Proche

## Définition

Le taux de bypass mesure la proportion de séjours de résidents du territoire du GHT réalisés dans un établissement **plus éloigné** du domicile qu'un site du GHT produisant le même type de prise en charge (même racine de GHM) la même année. Le concept est directement issu de la littérature internationale sur le « hospital bypass » : un patient « bypasse » lorsqu'il contourne l'hôpital compétent le plus proche pour se faire soigner plus loin.

Cet indicateur se distingue du taux de fuite classique (`taux_fuite_attractivite.md`) sur un point essentiel : la fuite mesure tous les séjours réalisés hors GHT, **y compris** ceux pour lesquels le GHT n'offre aucune alternative (recours structurel). Le bypass ne retient que les séjours pour lesquels une **offre GHT existait à distance moindre** — il isole donc la composante « choisie » de la fuite, celle qui relève d'un déficit d'image, de délais d'accès ou de captation par l'amont (médecins adresseurs, urgences concurrentes), et non d'un déficit d'offre.

Formule symbolique :

```
TB = N_bypass / N_éligibles × 100

N_éligibles = séjours de résidents du territoire dont la racine de GHM est produite
              par au moins un site du GHT (volume ≥ seuil) la même année
N_bypass    = séjours éligibles réalisés dans un établissement hors GHT tel que
              d(domicile → établissement réel) > d(domicile → site GHT compétent le plus proche) + δ
```

où `d` est une distance routière inter-communes et `δ` un seuil de tolérance (10–30 km) qui évite de classer en bypass les arbitrages de proximité marginaux. La littérature montre que le niveau mesuré est très sensible au choix de `δ` (Abid et al. 2025) : le seuil doit être fixé une fois pour toutes et documenté.

## Calcul

1. **Champ** : RSA MCO de l'année N (extension possible SSR/PSY), résidents du territoire GHT (liste de codes géographiques de résidence définissant le territoire).
2. **Casemix de référence GHT** : pour chaque racine de GHM (GHM tronqué à 5 caractères, hors niveau de sévérité), identifier les sites du GHT en produisant au moins `V_min` séjours dans l'année (recommandé : `V_min = 30` pour éviter qu'une activité anecdotique rende le site « compétent »).
3. **Distancier** : distances routières entre le code géographique de résidence du RSA et la commune d'implantation de chaque établissement (distancier inter-communes type METRIC INSEE/DREES, ou distancier routier équivalent). Le code géographique PMSI étant un regroupement de codes postaux, la distance est mesurée de centroïde de zone à commune d'implantation.
4. **Classification** de chaque séjour éligible :

```
pour chaque RSA de résident :
    racine = ghm[1:5]
    sites_competents = sites GHT avec volume(racine, N) >= V_min
    si sites_competents vide : séjour exclu (recours structurel, pas de bypass possible)
    d_ght  = min(distance(code_geo_residence, site) pour site dans sites_competents)
    d_reel = distance(code_geo_residence, finess_sejour)
    bypass = (finess_sejour hors GHT) et (d_reel > d_ght + delta)

TB = somme(bypass) / somme(éligibles) × 100
```

5. **Conventions** : séances (CMD 28) analysées séparément ou exclues ; transferts (mode d'entrée mutation/transfert) exclus du numérateur car la destination n'est pas un choix du patient ; codes géographiques hors France ou imprécis exclus.
6. **Déclinaisons** : par racine de GHM, par activité (M/C/O), par niveau de sévérité, par zone géographique de résidence (cartographie des poches de bypass).

## Utilité

- **Cibler la reconquête** : contrairement au taux de fuite global, chaque séjour en bypass correspond à une alternative GHT réelle et plus proche — c'est le périmètre exact des parts de marché récupérables sans investissement capacitaire nouveau.
- **Détecter les déficits d'image par spécialité** : un bypass élevé sur une racine chirurgicale alors que le site GHT est plus proche et actif signale un problème d'adressage, de délais de rendez-vous ou de réputation, à traiter avec la CME.
- **Cartographier les zones de décrochage** : la déclinaison par code géographique révèle les communes où les patients passent devant un site du GHT pour aller ailleurs — support direct des actions vers les médecins adresseurs locaux.
- **Suivre l'effet des coopérations** : l'ouverture d'une consultation avancée ou d'une filière dédiée doit se traduire par une baisse mesurable du bypass sur les racines concernées dans la zone desservie.
- **Objectiver le débat fuite structurelle / fuite évitable** auprès des instances : la décomposition fuite = bypass + recours sans alternative locale clarifie ce qui relève du projet médical partagé et ce qui relève du schéma régional.
- **Arbitrer les seuils d'activité** : un site « compétent » massivement bypassé sur une racine à faible volume pose la question du maintien de cette activité (lien qualité-volume).

## Sources de Données

- **PMSI MCO** (RSA) : GHM (racine = 5 premiers caractères), code géographique de résidence, n° FINESS de l'établissement, mode d'entrée, nombre de séances `[noms de champs exacts selon le format RSA de la campagne en vigueur, à confirmer]`.
- **Référentiel ATIH** : table de correspondance codes postaux → codes géographiques PMSI de l'année (publiée avec les formats RSA sur [atih.sante.fr](https://www.atih.sante.fr/)).
- **Distancier inter-communes** : distancier routier type METRIC (INSEE/DREES, utilisé dans les études d'accès aux soins — cf. DREES, Études et Résultats n° 764) ou calcul OSRM/OpenStreetMap local.
- **FINESS** : géolocalisation (commune d'implantation) des établissements ; périmètre des sites du GHT.
- Accès au **PMSI national** (tous établissements) requis pour observer les séjours réalisés hors GHT : base nationale via le portail ATIH ou SNDS.

## Exemple de Valeurs

Ordres de grandeur issus de la littérature internationale (contextes non français, à transposer avec prudence) et estimation expert pour la France :

- **États-Unis, Medicare rural, chirurgie courante 2016–2020** : 49 % de bypass de l'hôpital chirurgical le plus proche (Mullens et al. 2026).
- **Caroline du Nord, chirurgie urgente, seuil 10 miles** : 26,6 % de bypass (Abid et al. 2025).
- **Chine, AVC** : 78 % de bypass de l'hôpital le plus proche (Wang et al. 2026) — contexte de gradient qualité très marqué.
- **GHT français, ordre de grandeur expert (non sourcé)** : 10–25 % attendu sur les racines de chirurgie programmée courante (concurrence privée), < 10 % en médecine non programmée et obstétrique. Un bypass > 30 % sur une racine donnée avec site GHT actif à moins de 30 minutes constitue un signal d'alerte fort.

## Limites

- **Sensibilité aux paramètres** : le taux varie fortement selon `δ` (seuil de distance) et `V_min` (seuil de compétence) — Abid et al. (2025) montrent que les associations mesurées changent selon la définition du bypass. Comparaisons valables uniquement à paramétrage constant.
- **La distance n'est pas le temps d'accès** : un établissement plus « loin » en kilomètres peut être plus rapide d'accès (autoroute) ; un distancier en temps routier est préférable quand il est disponible.
- **Compétence ≠ capacité** : un site produisant la racine peut être saturé (délais) ; le PMSI ne voit pas les files d'attente, donc une partie du bypass mesuré reste contrainte.
- **Compétence ≠ pertinence clinique** : à racine identique, le niveau de sévérité ou un plateau technique spécifique (réanimation, cardiologie interventionnelle) peut justifier le contournement — croiser avec le niveau de GHM et restreindre aux niveaux 1–2 pour une lecture « évitable » (cf. `taux_fuite_evitable_severite_ajustee.md`).
- **Précision géographique** : le code géographique PMSI agrège plusieurs communes ; l'erreur de distance induite peut dépasser 10 km en zone rurale, d'où l'importance d'un `δ` non nul.
- **Le bypass n'est pas toujours une mauvaise nouvelle pour le patient** : la littérature montre des effets opposés selon le contexte — outcomes dégradés dans le bypass rural américain (Mullens et al. 2026), mais bénéfice de survie quand le bypass mène vers un plateau tertiaire pour l'AVC (Wang et al. 2026). L'indicateur pilote la captation, pas la qualité.

## Références

- Mullens CL, Johnson PL, Rentas C, et al. *Half Of Rural Patients Bypassed Their Local Hospital But Received Lower-Quality Surgical Care Elsewhere, 2016-20.* Health Aff (Millwood). 2026;45(3):313-321. [DOI](https://doi.org/10.1377/hlthaff.2025.00640) — PMID:41770994
- Abid M, Malone T, Holmes M, Charles A. *Clinical Consequences Associated With Bypassing Local Surgical Care for Urgent and Emergent Surgery.* J Surg Res. 2025;315:504-514. [DOI](https://doi.org/10.1016/j.jss.2025.09.034) — PMID:41092603
- Wang Q, Ao L, Tan K, Yan X, Pan J. *Does bypassing nearby hospitals for high-quality care reduce case fatality among inpatients who had a stroke? A retrospective study of 328 206 cases.* BMJ Qual Saf. 2026. [DOI](https://doi.org/10.1136/bmjqs-2025-019330) — PMID:41802852
- DREES. *Distances et temps d'accès aux soins en France métropolitaine.* Études et Résultats n° 764, juin 2011. [PDF](https://drees.solidarites-sante.gouv.fr/sites/default/files/2020-10/er764.pdf)
- ATIH — ScanSanté, restitution « taux de recours » et flux de patients : [scansante.fr/applications/taux-de-recours](https://www.scansante.fr/applications/taux-de-recours)
- Fiche liée : `taux_fuite_attractivite.md` (fuite brute), `taux_fuite_evitable_severite_ajustee.md` (restriction par sévérité), `kilometrage_excedentaire_fuite.md` (intensité du contournement).
