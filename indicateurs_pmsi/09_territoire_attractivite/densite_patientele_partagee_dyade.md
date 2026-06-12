# Densité de Patientèle Partagée d'une Dyade d'Établissements

## Définition

La densité de patientèle partagée mesure l'intensité du partage **réel** de patients entre deux établissements A et B sur 12 mois : la part des patients de la dyade hospitalisés dans **les deux** établissements au cours de la période. Contrairement aux indicateurs de flux (transferts, adressages), elle capte l'intégration des files actives indépendamment de l'ordre et du délai des séjours — y compris le patient suivi en parallèle sur les deux sites (chimiothérapie à B, complications à A).

Le concept transpose au niveau inter-établissements la **care density** de Pollack et al. (2013) — la fréquence avec laquelle les médecins d'un patient partagent d'autres patients, validée comme proxy de coordination associé à de moindres coûts et hospitalisations — et les mesures de structure des réseaux de patient-sharing construits sur claims (Barnett et al. 2012 ; Ishikawa et al. 2024). Des travaux récents l'utilisent pour objectiver l'effet d'organisations inter-sites sur la coordination (Scodari et al. 2024). Mathématiquement, la forme principale est un **indice de Jaccard** sur les ensembles de patients :

```
D = |P_A ∩ P_B| / |P_A ∪ P_B|                       ∈ [0 ; 1]   (Jaccard)

P_X = ensemble des patients (chaînage anonyme) avec ≥ 1 séjour à X sur 12 mois

Formes directionnelles :  d_A = |P_A ∩ P_B| / |P_A|  ;  d_B = |P_A ∩ P_B| / |P_B|
Forme de recouvrement  :  O   = |P_A ∩ P_B| / min(|P_A|, |P_B|)   (overlap, insensible au déséquilibre de tailles)
```

Aucun indicateur PMSI standard ne mesure le recouvrement de files actives entre deux établissements : les parts de marché comparent des zones, les taux de transfert comptent des événements séquentiels. D est le seul à répondre à « combien de patients ces deux établissements ont-ils en commun ? » — la matière première d'une convention.

## Calcul

1. **Champ** : PMSI MCO chaîné (extensible SMR/HAD/Psy selon le périmètre de la convention), 12 mois glissants ou année civile. Calculable sur le portail ATIH en se restreignant aux séjours de A et B (pas besoin de base nationale).
2. **Exclusions recommandées** : séances (CMD 28) — un patient dialysé/chimio génère un partage mécanique massif ; les compter à part. Erreurs de groupage (CMD 90).
3. **Pseudocode** :

```
P_A = patients distincts (clé de chaînage) avec ≥ 1 séjour MCO à A sur la période
P_B = idem pour B

partage = |P_A ∩ P_B|
D   = partage / |P_A ∪ P_B|
d_A = partage / |P_A| ; d_B = partage / |P_B|
O   = partage / min(|P_A|, |P_B|)
# non calculé si min(|P_A|, |P_B|) < 200
```

4. **Conventions** : patients avec clé de chaînage défaillante exclus du numérateur et du dénominateur ; période identique pour les deux établissements.
5. **Indicateurs dérivés** : D par CMD ou par filière conventionnée (le partage est-il là où la convention le prévoit ?) ; évolution annuelle de D avant/après signature ; part des patients partagés dont les séjours dans les deux sites concernent la **même pathologie** (DP de même chapitre CIM-10) vs des prises en charge indépendantes.

## Utilité

- **Mesurer l'intégration effective post-convention** : une convention qui fonctionne doit faire croître D (et surtout D restreint aux filières conventionnées) ; un D plat à deux ans signale une coopération de papier.
- **Choisir le bon partenaire avant de signer** : la matrice D de tous les couples d'établissements du territoire révèle les dyades à fort partage spontané — là où une convention formalise (et sécurise) un fonctionnement déjà réel, ses chances de succès sont maximales.
- **Dimensionner les outils de coordination** : dossier patient partagé, RCP communes, messagerie sécurisée se justifient par le volume de patients effectivement partagés — D fournit le chiffrage opposable.
- **Détecter le nomadisme non coordonné** : un D élevé avec un taux de transferts directs faible et des pathologies identiques sur les deux sites suggère du double recours subi (doublons de bilans, ruptures) plutôt qu'une coopération — croiser avec `../06_pertinence_pratiques/taux_actes_diagnostiques_redondants.md`.
- **Suivre la fusion de filières** : lors d'une mise en commun de spécialité (équipe de territoire), d_A et d_B doivent converger ; leur divergence persistante localise le site qui reste à l'écart.
- **Alimenter le volet coopération de la certification GHT** : la littérature associe la densité de partage à la coordination perçue et mesurée (Pollack et al. 2013 ; Scodari et al. 2024) — D en est la déclinaison établissement.

## Sources de Données

- **PMSI MCO chaîné** : numéro de chaînage anonyme (MAGIC/ANO `[modalités exactes selon documentation ATIH en vigueur, à confirmer]`), FINESS géographique, GHM/CMD, DP pour les dérivés par pathologie.
- **Référentiels** : FINESS (entités géographiques) ; CIM-10 pour le regroupement par chapitre.
- Champs SMR/HAD/Psy via leurs équivalents chaînés si la convention dépasse le MCO.

## Exemple de Valeurs

Ordres de grandeur expert (non sourcés — pas de restitution nationale équivalente) :

- **Deux CH d'un même GHT, bassins contigus** : D = 0,03–0,10 ; O = 0,05–0,15.
- **CH et son CHU de recours régional** : D = 0,02–0,06 (dilué par la taille du CHU : préférer d_A et O, typiquement d_A = 0,05–0,15).
- **Dyade en direction commune avec filières intégrées** : O = 0,15–0,30.
- **Alerte basse** : D stable ou en baisse deux ans après une convention censée intégrer les filières.
- **Alerte haute** : O > 0,3 sans convention ni coordination formalisée = partage subi massif, à organiser d'urgence.

## Limites

- **Le partage n'est pas la coopération** : D compte aussi le double recours non coordonné ; le distinguer exige les dérivés (même pathologie, délais courts, redondances d'actes). D mesure le *potentiel* et l'*intensité* du lien, pas sa qualité.
- **Sensibilité au déséquilibre de tailles** : le Jaccard d'une dyade CH–CHU est mécaniquement faible ; toujours fournir O et les formes directionnelles pour les dyades asymétriques.
- **Séances** : leur inclusion change radicalement les valeurs ; les exclure du calcul principal et les suivre à part.
- **Chaînage** : ~1–2 % de clés défaillantes ; un différentiel de qualité entre A et B biaise les formes directionnelles.
- **Effet périmètre temporel** : D croît mécaniquement avec la longueur de la période (plus de chances de croiser les deux sites) ; comparer uniquement à période identique.
- **Volume minimal** : ne pas interpréter si min(|P_A|, |P_B|) < 200 patients/an.
- **Transposition** : la care density originale est définie au niveau des médecins d'un patient ; la version établissement est une adaptation — les valeurs de la littérature américaine (Medicare) ne sont pas des références directes pour le PMSI.

## Références

- Pollack CE, Weissman GE, Lemke KW, Hussey PS, Weiner JP. *Patient sharing among physicians and costs of care: a network analytic approach to care coordination using claims data.* J Gen Intern Med. 2013;28(3):459-465. [DOI](https://doi.org/10.1007/s11606-012-2104-7) — PMID:22696255
- Barnett ML, Christakis NA, O'Malley J, Onnela JP, Keating NL, Landon BE. *Physician patient-sharing networks and the cost and intensity of care in US hospitals.* Med Care. 2012;50(2):152-160. [DOI](https://doi.org/10.1097/MLR.0b013e31822dcef7) — PMID:22249922
- Scodari BT, Schaefer AP, Kapadia NS, O'Malley AJ, Moen EL. *Associations Between Oncology Outreach and Patient-Sharing Measures of Care Coordination.* Cancer Med. 2024;13(23):e70489. [DOI](https://doi.org/10.1002/cam4.70489) — PMID:39659048
- Ishikawa T, Kako A, Yoshimoto H, Hattori J, Goda K, Mitsutake N. *Analyzing Patient-Sharing Network Using an Administrative Claim Database in Japan.* Stud Health Technol Inform. 2024;310:1126-1130. [DOI](https://doi.org/10.3233/SHTI231140) — PMID:38269990
- Fiches liées : `indice_reciprocite_flux_dyade.md` (symétrie des flux), `taux_adressage_preferentiel_convention.md` (effectivité), `collaboration_etablissements.md` (vue GHT globale), `../06_pertinence_pratiques/taux_actes_diagnostiques_redondants.md` (coût du partage non coordonné).
