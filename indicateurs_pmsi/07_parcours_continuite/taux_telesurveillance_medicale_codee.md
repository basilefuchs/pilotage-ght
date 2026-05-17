# Taux de Télésurveillance Médicale Codée

## Définition

Le **taux de télésurveillance médicale codée** mesure la part des patients chroniques d'un établissement bénéficiant d'au moins un acte ou un forfait de **télésurveillance médicale (TLM)** sur une fenêtre annuelle glissante, par rapport à la file active des mêmes patients ayant une indication TLM reconnue (insuffisance cardiaque, insuffisance respiratoire chronique, insuffisance rénale chronique, diabète, prothèses cardiaques implantables, télésurveillance oncologique).

La télésurveillance médicale a été intégrée dans le **droit commun** par les décrets n° 2022-1769 et n° 2022-1767 et le décret d'application n° 2023-1395 ; les arrêtés d'inscription des activités à l'article L. 162-52 CSS du **23 février 2024** (cardiologie rythmologie) et du **23 juin 2025** ont fixé les forfaits opérateurs et techniques. La TLM remonte au PMSI au sein des **actes et consultations externes (ACE)** pour les patients hospitaliers et via les **suppléments / forfaits** pour les patients hospitalisés ([Guide PMSI MCO 2025 — DIM](https://www.departement-information-medicale.com/guide-pmsi-mco-2025/), [Arrêté 23 février 2024 — Légifrance](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000049205222), [Arrêté 13 mars 2025 — montants forfaitaires](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051336518)).

**Formule :**

**TTLM = N_patients_avec_forfait_TLM_indication / N_patients_file_active_indication**

avec
- patient avec forfait TLM : patient identifié (chaînage NIR haché) avec au moins un acte/forfait/supplément TLM codé sur la période, dans le périmètre PMSI ACE ou suppléments ou DCIR
- file active indication : patients de l'établissement avec un séjour ou un suivi pour une pathologie inscrite à l'art. L. 162-52 CSS

## Positionnement vs indicateurs existants

Le projet contient :
- `taux_adherence_medicamenteuse_post_sortie.md` — adhérence pharmacologique
- `taux_suivi_ambulatoire_post_hospitalier.md` — suivi clinique en ville
- `indice_upc_continuite_medecin_traitant.md` — UPC médecin traitant

Aucun indicateur ne mesure spécifiquement la **pénétration de la télésurveillance numérique** dans le parcours, alors que la TLM est devenue un dispositif **opposable** depuis 2023 avec une cible nationale de déploiement portée par le programme ETAPES puis le passage en droit commun. Auener 2023 ([DOI](https://doi.org/10.2196/43038)) a montré aux Pays-Bas que l'adoption hospitalière de la TLM IC est très variable (37 % des hôpitaux, 5,8 % des patients IC) — d'où l'intérêt d'un indicateur de pilotage local opposable au GHT.

## Calcul

### 1. Périmètre par indication

Liste des activités TLM inscrites au L. 162-52 CSS au 2026-05 (arrêtés vérifiés dans la session) :

```
INDICATIONS_TLM (à actualiser annuellement) :
  - Insuffisance cardiaque chronique
  - Insuffisance respiratoire chronique
  - Insuffisance rénale chronique (hors dialyse)
  - Diabète (sous-cohorte type 1 / type 2 sous insuline)
  - Prothèses cardiaques implantables (DAI, PMK, CRT, MERLIN.NET inscrit
    par arrêté du 23 juin 2025)
  - Oncologie (selon dispositifs spécifiques inscrits)
```

### 2. Détection des patients TLM dans le PMSI / DCIR

```
Sources de codage potentielles :
  - ACE PMSI : codes de prestation TLM (forfait opérateur + forfait technique),
    libellés et codes à figer chaque année selon la nomenclature CPAM en
    vigueur — voir CCAM en cours et nomenclature forfaits TLM
    [codes prestations à confirmer dans la notice tarifaire annuelle]
  - Suppléments PMSI MCO : si TLM débute pendant un séjour, repérage par
    le code de supplément TLM (V016 2025 et notice 2026)
  - DCIR (SNDS) : remboursements forfaits TLM (préférable pour file active
    en ville, qui dépasse le PMSI hospitalier)
```

### 3. Construction de la file active par indication

```
Pour chaque indication d :
  Patients_d = patients avec
     - séjour MCO avec DP/DAS de la liste CIM-10 indicative d
       (ex. IC : I50.0–I50.9, I11.0, I13.0, I13.2 ; IRC : N18.x ;
        IResp : J44.x sévère, J96.1 ; diabète : E10–E14 sous traitement)
     - ou consultation externe (ACE) avec code prestation correspondant
     - ou ALD active (ALD 5 IC, ALD 8 diabète, etc.) via DAS Z51 / Z76
       ou via SNDS

  TTLM_d = |Patients_d ∩ Patients_avec_forfait_TLM_d| / |Patients_d|
```

### 4. Agrégation et stratification

- **TTLM_global** = moyenne pondérée des TTLM_d par taille de file active.
- **Stratification** : par indication, par âge (< 65 / 65-79 / 80+), par sexe, par niveau socio-économique (proxy CMU/AME via DAS Z55-Z65).
- **Indicateur dérivé d'équité** : ratio TTLM_(80+) / TTLM_(< 65) — Auener 2023 a montré un OR = 0,30 pour les 80+ ([DOI](https://doi.org/10.2196/43038)), l'objectif est de tendre vers 1.

## Utilité

- **Suivi du déploiement opérationnel du droit commun TLM** : indicateur direct du virage numérique post-décret 2022.
- **Comparaison inter-GHT et opposabilité ARS** : TTLM peut être inscrit dans le contrat d'objectifs ARS / CPOM, avec cible de progression annuelle.
- **Détection des inégalités d'accès** : ratio TTLM_(80+)/TTLM_(< 65) et ratio par DAS de précarité — la TLM peut accentuer la fracture numérique si non-pilotée (Auener 2023).
- **Évaluation d'un programme TLM-IC à l'échelle GHT** : suivi avant/après déploiement d'une plateforme TLM IC sur la file active CMD 05, à coupler avec `taux_retour_urgences_7j_post_sortie_mco.md` et le taux de réadmission 30j IC.
- **Identification des indications sous-dotées** : un TTLM_IRC < 5 % alors que le GHT compte un service de néphrologie signale un défaut de déploiement opérateur, audit à mener.
- **Pilotage économique** : combiné aux forfaits techniques (arrêté du 23 juin 2025), permet de modéliser la dépense TLM à comparer aux économies de réadmission attendues.
- **Cohérence avec les indicateurs HAS-IPAQSS et IFAQ** : une augmentation du TTLM doit corréler à une baisse des réadmissions évitables — cohérence à objectiver pour valoriser la stratégie GHT.

## Sources de Données

- **PMSI ACE (actes et consultations externes)** :
  - codes de prestation forfait opérateur TLM et forfait technique TLM [codes exacts à confirmer dans la nomenclature CPAM/CCAM en vigueur — non vérifiée numéro par numéro dans la session]
  - patient identifié, date de prestation, FINESSGEO
- **PMSI MCO** :
  - DP / DR / DAS pour caractériser les indications (I50.x, N18.x, J44.x, E10-E14)
  - Suppléments éventuels si TLM intra-séjour (format V016 2025 — vérifier nomenclature suppléments TLM dans la notice ATIH-31-1-2025)
- **DCIR SNDS** : table `ER_PHA_F` / `ER_PRS_F` pour la consommation TLM en ville et la file active patient — [documentation SNDS télémédecine](https://documentation-snds.health-data-hub.fr/snds/fiches/telemedecine_v1)
- **Fichier ANO** : chaînage patient inter-séjours / inter-actes
- **Référentiels réglementaires** (vérifiés dans la session) :
  - [Arrêté du 23 février 2024 portant inscription d'activités TLM (rythmologie)](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000049205222)
  - [Arrêté du 23 février 2024 — forfaits défibrillateurs / stimulateurs](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000049205200)
  - [Arrêté du 13 mars 2025 — montants forfaitaires TLM](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051336518)
  - [Arrêté du 23 juin 2025 — inscription activité TLM MERLIN.NET](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051795508)
  - [Arrêté du 23 juin 2025 — forfait technique TLM](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051795537)
  - [Décrets actant l'intégration de la TLM en droit commun (ANS)](https://esante.gouv.fr/espace-presse/telesurveillance-medicale-2-decrets-actent-lintegration-de-la-telesurveillance-medicale-dans-le-droit-commun)
  - [Guide PMSI MCO 2025 — synthèse DIM (chapitre TLM)](https://www.departement-information-medicale.com/guide-pmsi-mco-2025/)

## Exemple de Valeurs

Ordres de grandeur experts (pas de restitution ScanSanté équivalente publique connue dans la session) ; calibrés à partir d'Auener 2023 (Pays-Bas, données 2019) et de la dynamique française post-droit commun.

- **TTLM_IC** (insuffisance cardiaque, file active hospitalière) : 5–15 % en 2025-2026 selon présence d'une cellule TLM dédiée ; cible à 25 % à 3 ans dans les GHT structurés.
- **TTLM_DAI / PMK** (rythmologie implantée) : 60–85 % car la TLM rythmologique est mature et le forfait défibrillateurs/stimulateurs est en place depuis l'arrêté du 23 février 2024.
- **TTLM_diabète** : 1–5 %, déploiement encore embryonnaire en 2026.
- **TTLM_IResp** : 2–8 %, croissance liée aux dispositifs PPC connectés.
- **TTLM_IRC** : 1–4 % hors dialyse.
- **Ratio équité 80+ / < 65** : observé 0,2–0,4 dans la littérature pré-2024 (Auener 2023), cible > 0,7 à 3 ans.
- **Seuils d'alerte** : TTLM_d stagne sur ≥ 3 trimestres consécutifs OU ratio équité < 0,3 → audit des freins (recrutement patient, prescripteur, opérateur).

## Limites

- **Codage TLM hétérogène** : la nomenclature forfaitaire TLM (opérateur + technique) est récente et son codage en ACE/PMSI peut être tardif, partiel ou erroné en début de campagne. Sous-estimation systématique attendue sur 2024 et probablement 2025. Documenter le taux de complétude par croisement DCIR-PMSI.
- **Patients TLM suivis en ville hors hôpital** : si le forfait TLM est facturé par un opérateur ambulatoire, le patient n'apparaît pas dans le PMSI hospitalier. Le calcul fiable nécessite l'accès SNDS.
- **Numérateur ≠ usage effectif** : un patient avec forfait TLM codé peut n'avoir transmis aucune mesure ; la qualité d'utilisation (taux d'observance des transmissions) n'est pas captée par cet indicateur. À compléter par des indicateurs d'usage côté plateforme TLM.
- **Indications évolutives** : la liste TLM inscrite au L. 162-52 CSS est révisée tous les 6 mois ; figer la version à comparer.
- **Casemix file active** : un service de cardiologie de référence aura mécaniquement plus de patients IC sévères éligibles ; comparaison inter-sites à risque casemix-ajusté (Auener 2023 : OR femmes 0,52, OR 80+ 0,30).
- **Substitution vs addition** : la TLM peut générer des consultations ajoutées sans réduire les hospitalisations. Coupler à un indicateur d'événement (réadmissions IC à 30 j) pour évaluer l'impact net.
- **Sustainability** : Auener 2023 ([DOI](https://doi.org/10.1177/20552076231196998)) montre que l'adoption durable de la TLM dépend de la sélection patient, du modèle économique et de l'intégration au parcours ; le seul TTLM ne garantit pas la pérennité.
- **Volumes minimaux** : sous 50 patients par indication par an, instabilité statistique majeure.

## Références

D'après PubMed :

- [Auener SL et al. — Characteristics Associated With Telemonitoring Use Among Patients With Chronic Heart Failure, J Med Internet Res 2023](https://doi.org/10.2196/43038) — premier panorama claims-based de l'adoption hospitalière TLM-IC, déterminants patients, inégalités âge/sexe. PMID 37851505
- [Auener SL et al. — Sustainable Adoption of Noninvasive Telemonitoring for Chronic Heart Failure : Qualitative Study, Digit Health 2023](https://doi.org/10.1177/20552076231196998) — facteurs de pérennité et freins. PMID 37654710
- [Cheng SA et al. — Remote Vital Signs Monitoring in HAH or Postacute Patients : Systematic Review, J Med Internet Res 2025](https://doi.org/10.2196/64753) — effet TLM sur mortalité 30 j. PMID 40418800
- [Roubille F et al. — PRADOC, J Am Heart Assoc 2024](https://doi.org/10.1161/JAHA.123.032931) — contexte français du parcours IC, plaide pour intégration TLM. PMID 39023055

Sources officielles vérifiées dans la session :

- [ANS — TLM en droit commun (décrets 2022-1769 et 2022-1767)](https://esante.gouv.fr/espace-presse/telesurveillance-medicale-2-decrets-actent-lintegration-de-la-telesurveillance-medicale-dans-le-droit-commun)
- [Arrêté 23 février 2024 — inscription activités TLM](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000049205222)
- [Arrêté 23 février 2024 — forfaits défibrillateurs/stimulateurs](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000049205200)
- [Arrêté 13 mars 2025 — montants forfaitaires TLM](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051336518)
- [Arrêté 23 juin 2025 — inscription MERLIN.NET](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051795508)
- [Arrêté 23 juin 2025 — forfait technique TLM](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000051795537)
- [Documentation SNDS — Télémédecine](https://documentation-snds.health-data-hub.fr/snds/fiches/telemedecine_v1)
- [Guide PMSI MCO 2025 — synthèse DIM](https://www.departement-information-medicale.com/guide-pmsi-mco-2025/)
