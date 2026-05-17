# Taux d'Identification FISH-PIC chez les Hospitalisés

## Définition

Le **taux d'identification FISH-PIC chez les hospitalisés** mesure la part des patients hospitalisés MCO ou SSR d'un établissement repérés comme porteurs de **limitations d'activité d'origine psychique, intellectuelle ou cognitive (PIC)** par l'algorithme FISH (Faisabilité d'Identification des personnes à risque de Situation de Handicap) développé par l'IRDES.

L'algorithme FISH-PIC, présenté dans le rapport IRDES n°592 (septembre 2024), repère sur le SNDS les individus dont le profil de consommation de soins est compatible avec une limitation PIC : ALD psychiatriques (ALD 23), traitements neuroleptiques, antidémentiels (anticholinestérasiques, mémantine), passages psychiatriques, séjours en SMR « affections du système nerveux » (catégorie majeure 50 SMR), recours en CMP, prises en charge par MDPH (proxy). Sur la période 2012-2019, FISH-PIC identifie **4,5 millions de personnes** (6,6 % de la population SNDS) en 2019, âge moyen 55 ans (59,6 ans femmes / 49,8 ans hommes). La comparaison avec l'enquête VQS 2021 montre une bonne sensibilité aux âges jeunes (psychiatrie) et une moindre performance aux âges très avancés au domicile.

**Formule :**

**TFISH = N_patients_FISH_PIC_positifs ∩ N_patients_hospitalisés / N_patients_hospitalisés**

calculée sur la file active annuelle, séjours MCO + SSR + Psy chaînés via le fichier ANO.

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — vulnérabilité sociale composite
- `indice_permeabilite_sociale_soins_preventifs.md` — accès prévention
- `taux_recours_ajuste_fdep.md` — FDep territorial

Aucun indicateur ne mesure le **handicap psychique/cognitif** au niveau de la patientèle hospitalisée, alors que cette population a des besoins spécifiques (accompagnement consentement, transport, aménagement de séjour, sortie sécurisée). Le PMSI Psy lui-même n'est pas exhaustif : un patient avec trouble léger suivi en CMP mais hospitalisé en MCO pour pathologie somatique ne sera pas repéré par les seuls codes F en DP/DR.

L'algorithme FISH-PIC, déposé dans la **Bibliothèque Ouverte des Algorithmes Santé (BOAS) du Health Data Hub**, est utilisable et réplicable.

## Calcul

### 1. Périmètre

```
Inclusion :
  - File active MCO + SSR + Psy de l'établissement / GHT, année t
  - Patient avec ≥ 24 mois d'historique SNDS (cohérent avec algo FISH)
  - Tout âge (l'algorithme couvre adulte ; mineurs en sous-cohorte)

Exclusion :
  - Patients sans historique SNDS exploitable
  - Patients étrangers en court séjour (NIR non disponible)
```

### 2. Application de l'algorithme FISH-PIC

```
Variables d'entrée (SNDS, fenêtre glissante 24 mois) :
  - ALD 23 (affections psychiatriques de longue durée), code ALD CNAM
  - Médicaments marqueurs (DCIR ER_PHA_F) :
      neuroleptiques (ATC N05A)
      antidémentiels (ATC N06D : donépézil, rivastigmine, galantamine, mémantine)
      psychostimulants TDAH (ATC N06BA)
      certains thymorégulateurs
  - Séjours PMSI Psy (RPS / R3A) : nb d'épisodes, hospitalisation libre
    vs sans consentement, suivi ambulatoire en CMP
  - Séjours SMR catégorie majeure 50 (système nerveux) avec spécialités
    neuro-cognitives
  - Hospitalisations MCO avec DP/DAS F00-F99 (troubles mentaux) ou G30
    (Alzheimer), G31
  - [liste exhaustive : voir IRDES Rapport 592 et code BOAS-HDH]

Algorithme : règles déterministes hiérarchisées (pas un modèle prédictif),
chaque patient est classé "PIC positif" ou non, avec sous-types
(psychique, intellectuel, cognitif).
```

### 3. Calcul de l'indicateur

```
1. Pour chaque patient i de la file active hospitalière :
     FISH_PIC_i ∈ {0, 1} selon algorithme IRDES
2. TFISH = Σ_i FISH_PIC_i / Σ_i 1{patient file active}
3. Stratifier par sous-type PIC (psychique / intellectuel / cognitif)
4. Stratifier par champ d'hospitalisation index (MCO somatique / MCO psychiatrique / SSR / Psy)
```

### 4. Sous-indicateurs

- **TFISH_psychique**, **TFISH_intellectuel**, **TFISH_cognitif** — décomposition par sous-type
- **TFISH_MCO_somatique** — proportion de patients FISH-PIC dans la file MCO non-psy. Indicateur de l'« invisibilité » du handicap psy/cog en MCO classique.
- **TFISH_par_CMD** : sur-représentation attendue en CMD 19 (psy), 23 (signes mal définis), 04 (respi — co-morbidité fréquente), 05 (cardio).
- **Indicateur dérivé d'écart** :
```
ECART_FISH_DP = TFISH - (nb_patients_avec_DP/DAS_F_ou_G30 / file_active)
```
Mesure le sous-codage en DP/DAS des limitations PIC : un écart positif élevé révèle un sous-codage hospitalier significatif.

## Utilité

- **Quantification du handicap PIC sous-codé dans le PMSI** : un patient suivi en CMP pour schizophrénie hospitalisé pour pneumonie est rarement codé F20 en DAS — FISH le repère via l'historique. ECART_FISH_DP > 30 points = sous-codage massif.
- **Pilotage des dispositifs d'accompagnement** : déploiement de référents handicap, partenariats MDPH, ESI (Équipe Sécurité Intervention), Handi-soin — TFISH est l'indicateur d'amont permettant de calibrer le besoin.
- **Sécurisation du parcours hospitalier** : un patient PIC a un risque accru de fugue, refus de soins, sortie non sécurisée — la stratification par UM permet de cibler les services à former.
- **Adaptation des consultations et de la programmation** : TFISH élevé en chirurgie programmée justifie une consultation pré-anesthésique adaptée (temps doublé, accompagnant, anxiolyse).
- **Inscription dans les obligations Loi 2005 (handicap) et dispositif Romain Jacob** : TFISH fournit une mesure quantitative opposable de la patientèle handicapée accueillie.
- **Détection de filières spécialisées de fait** : un service avec TFISH > 25 % devrait être labellisé / structuré en filière handi-accueillante.
- **Suivi des transitions psychiatrie ↔ somatique** : combiné à `delai_transfert_mco_ssr.md` et aux indicateurs de réadmission, mesure l'efficience du parcours intégré PIC.

## Sources de Données

- **PMSI MCO / SSR / Psy** : `RSA` / `RHA` / `RPS R3A` ; identifiant chaîné ANO ; DP/DR/DAS (codes F, G30-G31)
- **SNDS — DCIR** :
  - `ER_PHA_F` — médicaments marqueurs (codes ATC N05A, N06D, N06BA, etc.)
  - `ER_PRS_F` — consultations spécialistes psychiatre, neurologue, gériatre
  - `IR_IMB_R` — ALD actives (notamment ALD 23)
- **Référentiel FISH-PIC** :
  - [IRDES Rapport 592 (septembre 2024) — Faisabilité d'identification des personnes à risque de handicap (FISH) — limitations PIC](https://www.irdes.fr/recherche/2024/rapport-592-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html) — méthodologie complète
  - [IRDES Rapport 587 (2023) — FISH version initiale](https://www.irdes.fr/recherche/2023/rapport-587-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html)
  - [Health Data Hub — BOAS : algorithme limitations PIC SNDS](https://www.health-data-hub.fr/bibliotheque-ouverte-algorithmes-sante/developpement-dun-algorithme-de-reperage-des-individus-0) — code partagé
  - [Projet RISH IRDES — mise en œuvre opérationnelle](https://www.irdes.fr/recherche/enquetes/rish-realisation-d-identification-des-personnes-en-situation-de-handicap/actualites.html)
- **Référence comparative** : enquête VQS 2021 (DREES / INSEE) — utilisée pour la validation indirecte FISH.
- **Documentation SNDS** : [variables sociodémographiques SNDS](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)

## Exemple de Valeurs

Ordres de grandeur calibrés sur le rapport IRDES 592 et l'expertise terrain :

- **Population SNDS générale 2019 (IRDES)** : 6,6 % FISH-PIC positifs ; soit 4,5 M individus.
- **TFISH file active hospitalière tout établissement confondu** : 8-15 % attendu (sur-représentation par rapport à la pop. générale).
- **TFISH MCO somatique (CH général)** : 6-12 %.
- **TFISH CHU avec gros plateau neuro / psy** : 12-20 %.
- **TFISH SSR système nerveux / gériatrique** : 30-50 % (filière de fait).
- **TFISH Psy** : 80-95 % par construction.
- **ECART_FISH_DP** : typiquement +20 à +40 points en MCO somatique — révèle un sous-codage important.
- **Sous-type cognitif (G30/G31, Alzheimer)** : 3-7 % de la file 75+, croissant avec l'âge.
- **Seuil d'alerte** : ECART_FISH_DP > 40 points → audit codage DIM ; TFISH > 30 % en service non spécialisé → besoin de formation handicap et d'un référent handi-soin.

## Limites

- **Algorithme basé sur des règles** (pas un modèle probabiliste) : sensibilité et spécificité non chiffrées par une AUC, validation par comparaison à VQS uniquement.
- **Sous-détection chez les très âgés au domicile** : IRDES 2024 indique une moindre performance après 80 ans en domicile, où la limitation cognitive peut être non médicalisée.
- **Surdétection adultes jeunes femmes** : FISH identifie plus de troubles psychiques chez les femmes en adulte que VQS — biais probable lié à la consommation de psychotropes hors handicap caractérisé.
- **Versions évolutives** : la version FISH-PIC publiée en 2024 peut être révisée ; documenter la version utilisée et figer pour comparabilité inter-année.
- **Disponibilité SNDS** : accès via HDH/CNAM avec autorisation CNIL ; un GHT n'y accède pas en routine. Une version restreinte au PMSI seul est possible (DP/DAS F + G30/G31 + ALD 23 récupérables via codage local) mais perd la dimension médicament et CMP ambulatoire — sensibilité ↓.
- **Confusion handicap / pathologie aiguë** : un patient en épisode dépressif sévère ponctuel est PIC-positif transitoirement — l'indicateur ne distingue pas durée du handicap.
- **Stigmatisation et usage éthique** : le repérage doit servir à l'accompagnement, pas à la sélection — usage encadré CNIL et avec gouvernance éthique GHT.
- **Volumes minimaux** : sous 200 patients de file active, instabilité statistique sur les sous-types ; consolider sur 2 ans.
- **Comparaison inter-établissement** : un CHU avec un grand service psy aura mécaniquement un TFISH plus élevé ; ajuster sur le casemix.

## Références

D'après PubMed :

- [Baker KM et al. — Using Z Codes to Document Social Risk Factors : Scoping Review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — référence internationale sur le sous-codage des Z-codes sociaux, conceptuellement proche du sous-codage des codes F/G30 en MCO. PMID 39570573

Sources officielles vérifiées dans la session :

- [IRDES — Rapport 592 — Faisabilité d'identification des personnes à risque de handicap (FISH) — limitations PIC, sept. 2024](https://www.irdes.fr/recherche/2024/rapport-592-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html)
- [IRDES — Rapport 587 — FISH version initiale, 2023](https://www.irdes.fr/recherche/2023/rapport-587-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html)
- [Health Data Hub — BOAS — Algorithme limitations psychiques/intellectuelles/cognitives SNDS](https://www.health-data-hub.fr/bibliotheque-ouverte-algorithmes-sante/developpement-dun-algorithme-de-reperage-des-individus-0)
- [IRDES — Projet RISH (mise en œuvre)](https://www.irdes.fr/recherche/enquetes/rish-realisation-d-identification-des-personnes-en-situation-de-handicap/actualites.html)
- [Bibliographie thématique IRDES — Handicap](https://www.irdes.fr/recherche/thematiques/handicap.html)
- [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
