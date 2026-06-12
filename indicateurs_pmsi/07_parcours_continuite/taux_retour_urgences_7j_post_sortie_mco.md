# Taux de Retour aux Urgences à 7 Jours Post-Sortie MCO

## Définition

Le **taux de retour aux urgences à 7 jours** mesure la proportion de séjours MCO suivis d'un passage aux urgences (RPU) du même patient dans les 7 jours calendaires après la sortie. Il est largement utilisé en santé publique anglo-saxonne comme **indicateur de qualité de la transition hôpital-domicile** (Michelson 2018, Miró 2023) et complète la mesure classique des réadmissions à 30 jours en captant des **événements indésirables précoces et de moindre gravité** : effet rebond avant stabilisation thérapeutique, ordonnance de sortie inadaptée, lettre de liaison absente ou tardive, défaut de relai ville.

À la différence d'une réadmission, un retour aux urgences peut se solder par un retour à domicile sans hospitalisation : le signal est plus sensible (capture des événements n'aboutissant pas à un nouveau RUM) mais aussi plus bruité.

**Formule :**

**RU7J = N_séjours_index_avec_passage_RPU≤7j / N_séjours_index_éligibles**

avec
- séjour index : RSA MCO sortie domicile (SOR_DEST_DOM)
- passage RPU≤7j : retour aux urgences (RPU) du même patient (chaînage NIR/IPP via fichier ANO) avec date d'admission ≤ J+7 après date de sortie

La fenêtre 7 jours est privilégiée par les guidelines HAS et la littérature internationale (Michelson 2018, Miró 2023) car elle isole les événements imputables à la sortie elle-même, alors que la fenêtre 30 jours (CMS, ScanSanté) capture davantage la trajectoire post-hospitalière globale.

## Positionnement vs indicateurs existants

Le projet contient :
- `taux_mortalite_30j_post_sortie.md` (cat. 05) — événement extrême, taux faible
- `psi90_patient_safety_indicators.md` — événements pendant le séjour, pas après
- catégorie 08 (réadmissions évitables) — événements à 30j aboutissant à un séjour

Aucun indicateur du projet ne couvre les **passages aux urgences sans hospitalisation après sortie**, qui sont pourtant le signal le plus précoce d'un défaut de transition. L'axe IQSS HAS 2026 met explicitement en avant la qualité de la lettre de liaison (recueil biennal MCO/SMR/HAD/chir ambulatoire) — l'indicateur RU7J est un proxy quantitatif PMSI/RPU directement aligné sur cet axe.

## Calcul

### 1. Définition du périmètre

```
Inclusion (séjour index) :
  - RSA MCO complet
  - Adulte (>= 18 ans) — pédiatrie en sous-cohorte séparée
  - Sortie vers le domicile (`destination` = "D" / domicile)
  - Durée séjour >= 1 jour (exclusion de l'hospitalisation de jour pure HJ
    si étude ciblée hospit. complète)

Exclusion :
  - Décès intra-séjour (SOR_MOD = 9)
  - Sorties vers SSR/HAD/USLD (`destination` != "D") : transfert direct, pas une
    sortie domicile
  - Soins palliatifs en DP (Z51.5) ou en mode de prise en charge palliatif
  - Séjours d'obstétrique pour accouchement (CMD 14)
  - Séjours dialyse / chimiothérapie itératifs (Z49, Z51.1) — passages
    programmés
```

### 2. Chaînage RSA-RPU

```
1. Récupérer fichier ANO du patient (clé chaînage : NIR haché, sexe, date
   naissance) : produit l'identifiant chaîné national.
2. Joindre RSA(s) du patient avec RPU(s) sur cet identifiant.
3. Pour chaque séjour index s :
     date_sortie_s = date_entrée_s + DUREE_SEJOUR_s
     Identifier le premier RPU r tel que :
        date_admission_RPU_r >= date_sortie_s
        date_admission_RPU_r <= date_sortie_s + 7 jours
     Si trouvé : RU7J(s) = 1, sinon RU7J(s) = 0.
4. Indicateur agrégé :
     RU7J = Σ_s RU7J(s) / Σ_s 1{séjour éligible}
```

### 3. Sous-indicateurs cliniques utiles

Stratifier RU7J par :
- **CMD du séjour index** (insuffisance cardiaque, BPCO, chir digestive, etc.)
- **Motif de retour aux urgences** (DP du RPU)
- **Issue du RPU** : retour domicile / hospitalisation / décès aux urgences
- **Établissement du retour** : même FINESS / autre FINESS du GHT / hors GHT
  → permet de mesurer la **fidélisation territoriale** post-sortie

```
RU7J_même_etab(s)  = 1 si RPU dans le même FINESSGEO que le séjour index
RU7J_autre_GHT(s)  = 1 si RPU dans un autre FINESS du GHT
RU7J_hors_GHT(s)   = 1 si RPU hors périmètre GHT
```

Michelson 2018 a montré qu'omettre les retours dans un autre établissement **sous-estime de ~17 %** le taux réel — d'où l'importance du chaînage SNDS.

### 4. Ajustement de risque

GLM logistique sur âge, sexe, score Charlson via DAS, GHM-racine, niveau de sévérité, mode d'entrée du séjour index, durée de séjour, ALD codée. Production d'un O/E pour comparaison inter-sites du GHT.

## Utilité

- **Pilotage de la qualité de la sortie MCO** : RU7J décortique les zones de fragilité par CMD/UM ; un service avec RU7J élevé sans réadmission élevée signale un défaut de communication ville (ordonnance de sortie, RDV de suivi, lettre de liaison non transmise au médecin traitant).
- **Alignement avec axes IQSS HAS 2026** : la HAS a inscrit dans l'arrêté du 18 février 2026 le recueil biennal de la qualité des lettres de liaison ; RU7J fournit un proxy quantitatif PMSI/RPU directement comparable d'une campagne à l'autre.
- **Indicateur précoce vs réadmissions 30j** : RU7J détecte les défauts de sortie 3 à 4 semaines plus tôt qu'un taux de réadmission à 30 jours, permettant des plans d'action correctifs intra-année.
- **Fidélisation territoriale du GHT** : la stratification même_etab / autre_GHT / hors_GHT mesure la **fuite urgences** — un patient sortant du CHU et retournant aux urgences d'un CH du GHT (bonne fluidité) vs hors GHT (fuite, défaut de réseau) sont deux signaux opposés.
- **Évaluation d'interventions post-hospitalières** : déploiement d'un programme PRADO, hôpital-en-ligne ou IPA de coordination → suivi temporel RU7J avant/après comme indicateur principal d'efficacité.
- **Identification des cohortes à risque pour RAAC / hôpital de jour** : les CMD avec RU7J > seuil sont candidates à un parcours renforcé (consultation à J+3, hotline) ; ROI mesurable directement.
- **Outil de pilotage CME et ARS** : intégration dans le contrat d'objectifs ARS / contrat GHT comme indicateur cible (réduction de X % en 24 mois).

## Sources de Données

Variables PMSI MCO et RPU (sources ATIH 2024–2025 confirmées dans la session) :

- **RSA / RSS MCO** :
  - `DATE_ENTREE`, `duree` → date de sortie calculée
  - `SOR_MOD` (mode de sortie ; 6 = domicile, 9 = décès, 7 = transfert, 8 = mutation)
  - `destination` (destination de sortie)
  - `DP`, `DR`, `DAS`, `GHM`, niveau de sévérité, `age`, `SEXE`, `FINESSGEO`
- **RPU (Résumé de Passage aux Urgences)** : recueil national obligatoire depuis 2016, transmis via DRUIDES depuis M3 2023 ([atih.sante.fr/varia_rpu.pdf](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf), [consignes recueil RPU](https://www.atih.sante.fr/sites/default/files/public/content/1102/consignes_recueil_rpu.pdf))
  - `date_entree`, `HEURE_ADM_URG`
  - `orientation` (devenir du passage : retour domicile / hospitalisation / décès) — table `passage` RPU
  - `DIAG_PRINC_URG` (CIM-10)
  - `finessgeo`
  - clé de chaînage compatible ANO
- **Fichier ANO PMSI** : permet le chaînage inter-séjours et inter-champs (MCO ↔ RPU ↔ SSR ↔ HAD) sur le même patient (NIR haché + sexe + date de naissance) ([ATIH — Utiliser le PMSI pour analyser les parcours de soins, EMOIS 2023](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf))
- **Référentiels** :
  - *Guide méthodologique PMSI MCO 2024* ([atih.sante.fr](https://www.atih.sante.fr/sites/default/files/public/content/4709/guide_methodo_mco_2024_version_provisoire_1.pdf))
  - *Notice technique ATIH-294-9-2025* (format V016 2026)
  - HAS — IQSS 2026, axe lettre de liaison de sortie
- **Périmètre élargi possible (SNDS)** : pour capter les retours aux urgences hors GHT, l'accès SNDS via DCIR/PMSI est nécessaire. Sur portail ATIH seul, on n'a que les RPU des FINESS déclarants ; un chaînage GHT-only suffit pour les indicateurs de pilotage interne.

Variable de chaînage **NIR_anonymisé** disponible via le fichier ANO et reconnue par l'ATIH ; le détail du process ANO peut évoluer avec DRUIDES — vérifier la documentation en vigueur.

## Exemple de Valeurs

Ordres de grandeur experts, en l'absence de restitution publique ScanSanté équivalente. À recalibrer localement.

- **Toutes spécialités MCO confondues, sortie domicile, adulte** : RU7J ≈ 4–8 %, dont environ 30–40 % aboutissent à une nouvelle hospitalisation.
- **Insuffisance cardiaque (CMD 05, IC décompensée)** : 9–13 % à 7 jours (Miró 2023 cible <10 % comme objectif qualité espagnol post-IC). PMID 37439419
- **BPCO décompensée** : 8–12 %.
- **Chirurgie digestive lourde post-RAAC** : 3–6 % typiquement, signal sensible aux complications post-op tardives (déhiscence, abcès).
- **Pédiatrie (bronchiolite, gastro-entérite)** : 5–10 %, fortement variable selon saison épidémique (Mittal 2019). PMID 30606774
- **Sortie vers EHPAD ou USLD** : à exclure du périmètre principal (parcours différent), à mesurer en cohorte dédiée.
- **Seuil d'alerte de pilotage** : RU7J > moyenne GHT + 2σ sur ≥ 3 trimestres consécutifs → audit qualité de sortie sur la CMD concernée.

## Limites

- **Sensibilité au périmètre RPU déclaré** : les RPU des cliniques privées sont parfois sous-déclarés ; les retours dans des services d'urgences non-MCO (SOS médecins, maisons médicales de garde) ne figurent pas dans les RPU ATIH. Sous-estimation systémique du dénominateur.
- **Chaînage imparfait** : le NIR haché peut échouer pour les patients étrangers, sans NIR (mineurs, AME), ou en cas de mauvaise qualité de saisie. Documenter le taux de non-chaînage et le présenter en complément. Michelson 2018 a montré qu'omettre les retours dans un autre établissement sous-estime le taux de ~17 %. PMID 29650806
- **Casemix entrant** : un site recevant beaucoup de patients précaires, isolés, ou avec comorbidités lourdes aura mécaniquement un RU7J plus élevé indépendamment de la qualité de sortie. Ajustement obligatoire avant comparaison ; intégrer si possible des marqueurs de précarité (CMU, PASS, DAS Z55-Z65).
- **Distinction « retour pour le même motif » vs « événement indépendant »** non triviale : un patient sortant d'orthopédie qui revient pour une pyélonéphrite n'est pas imputable au séjour index. Une analyse fine requiert un croisement DP_séjour_index ↔ DP_RPU.
- **Effet rebond bénin (rassurance)** : certains retours sont des consultations légitimes (douleur post-op modérée, anxiété), non évitables par une meilleure organisation. RU7J n'est jamais à 0 en sortie d'hospitalisation lourde.
- **Saisonnalité** : épidémies hivernales (grippe, bronchiolite) augmentent mécaniquement RU7J ; comparer en cohortes périodiques équivalentes ou ajuster.
- **Pas un indicateur de qualité individuelle** : signal d'alerte pour audit qualité de sortie, pas une mesure de performance d'un service donné en isolé. Toujours lire en complément des indicateurs de réadmission et de mortalité 30j.
- **Disponibilité tardive des RPU** : la consolidation nationale RPU/PMSI met plusieurs mois ; suivi en quasi-temps réel possible uniquement sur le périmètre du GHT producteur des données.

## Références

D'après PubMed :

- [Michelson KA et al. — Timing and Location of Emergency Department Revisits, Pediatrics 2018](https://doi.org/10.1542/peds.2017-4087) — fenêtre 7 jours et impact des retours en autre établissement. PMID 29650806
- [Miró Ò et al. — Decisions to admit vs. discharge patients with acute heart failure from the emergency department, Emergencias 2023](https://doi.org/10.55633/s3me/E041.2023) — RU7J comme indicateur qualité IC, seuil <10 %. PMID 37439419
- [Rajaguru V et al. — LACE Index to Predict the High Risk of 30-Day Readmission in AMI, Front Cardiovasc Med 2022](https://doi.org/10.3389/fcvm.2022.925965) — composante visite urgences dans le LACE. PMID 35898272
- [Mittal S et al. — Successful Use of Quality Improvement Methodology to Reduce Inpatient Length of Stay in Bronchiolitis, Hosp Pediatr 2019](https://doi.org/10.1542/hpeds.2018-0023) — RU7J comme balance measure pédiatrique. PMID 30606774
- [ATIH — Variables RPU (varia_rpu.pdf)](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf) — dictionnaire des variables RPU.
- [ATIH — Consignes de production des RPU](https://www.atih.sante.fr/sites/default/files/public/content/1102/consignes_recueil_rpu.pdf) — règles de remplissage.
- [ATIH — Utiliser le PMSI pour analyser les parcours de soins, EMOIS 2023](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf) — méthodologie chaînage ANO.
- [ATIH — Guide méthodologique PMSI MCO 2024](https://www.atih.sante.fr/sites/default/files/public/content/4709/guide_methodo_mco_2024_version_provisoire_1.pdf) — variables RSA, mode/destination de sortie.
- [HAS — IQSS 2026 (cadre réglementaire indicateurs qualité)](https://www.has-sante.fr/jcms/c_970481/) — axe lettre de liaison, recueil biennal.
- [HDH — Passages aux urgences dans le DCIR/PMSI (FAQ)](https://entraide.health-data-hub.fr/t/passages-aux-urgences-dans-le-dcir-pmsi/1587) — chaînage SNDS.
