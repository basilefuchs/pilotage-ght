# Taux d'Interruption ALD puis Admission Aiguë

## Définition

Le **taux d'interruption ALD puis admission aiguë (TIAA)** mesure la part des patients en affection longue durée (ALD) qui présentent une **interruption documentée ≥ 12 mois** de prise en charge codée sur leur affection — absence de consultation spécialisée, absence de délivrance médicamenteuse de la classe thérapeutique attendue, absence de bilan de suivi obligatoire — **suivie d'une admission MCO non programmée** sur la même affection.

Ce schéma de **« gap puis décompensation »** est un proxy administratif du **renoncement effectif aux soins**, qui complète les approches déclaratives (Baromètre DREES 2023, [DREES Dataviz](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre) — 1 personne sur 5 sans consultation médicale en 2023). À la différence des approches d'enquête, le TIAA est entièrement reconstruit sur le SNDS et capture les ruptures révélées par un événement aigu — donc à fort impact clinique et économique.

**Formule :**

**TIAA = N_patients_ALD_gap12m_puis_admission_aigue / N_patients_ALD_avec_historique_complet**

avec :
- gap 12m : aucune trace de prise en charge spécifique à l'ALD (consultation spécialiste filière + délivrance médicamenteuse marqueur) sur ≥ 12 mois calendaires consécutifs avant l'admission
- admission aiguë : RSA MCO non programmé (`modeentree` = 7 ou via urgences) dont DP/DR est cohérent avec l'ALD du patient

## Positionnement vs indicateurs existants

Le projet contient :
- `indice_retention_soins_primaires.md` — rétention soins primaires (général)
- `taux_ald_suivi_minimal_garanti.md` (cat. 07) — suivi minimal ALD
- `taux_patients_ald_sans_medecin_traitant_hospi.md` (ce dossier) — désaffiliation MT
- `score_vulnerabilite_sociale.md` — score patient
- `taux_recours_ajuste_fdep.md` — recours ajusté FDep

L'innovation du TIAA est de **coupler explicitement le gap de soins à un événement d'admission aiguë** sur la même affection. C'est-à-dire de mesurer non pas le renoncement déclaré, mais le **renoncement objectivé par sa conséquence clinique**. Cela en fait un indicateur d'impact, lourd de sens pour le pilotage.

## Calcul

### 1. Périmètre

```
Inclusion :
  - Patient avec au moins une ALD active sur la fenêtre d'observation
  - Historique SNDS exploitable >= 24 mois avant l'admission index
  - Adulte (>= 18 ans)

Exclusion :
  - Patients en EHPAD / USLD (suivi institutionnel, gap codé différemment)
  - Patients en soins palliatifs (Z51.5 actif)
  - Patients récemment ouverts en ALD (< 24 mois — gap non interprétable)
```

### 2. Construction du « gap 12m » par ALD

```
Pour chaque ALD a, on définit un ensemble de marqueurs de prise en charge :

MARQUEURS_PEC(a) = {
  consultations spécialistes filière (ex. ALD 8 diabète : endocrinologue,
    diabétologue, MG marqueur HbA1c)
  délivrance médicamenteuse de classe a (ex. insuline, ADO pour diabète)
  bilans biologiques attendus (HbA1c, microalbumine, etc.)
  actes techniques marqueurs (fond d'œil annuel pour diabète, fonction
    rénale annuelle pour HTA, etc.)
  hospitalisations programmées HDJ sur la filière
}

Pour chaque patient i, ALD a :
  pour chaque mois m sur l'historique :
    actif_m = 1 si au moins un marqueur de MARQUEURS_PEC(a) présent
  GAP_i_a = 1 si on identifie une séquence consécutive de >= 12 mois où
            actif_m = 0, et terminant avant la date d'admission index
```

### 3. Identification de l'admission aiguë cohérente

```
Pour chaque patient i avec GAP_i_a = 1 :
  Chercher la première admission MCO post-gap telle que :
    - `modeentree` ∈ {7 mutation/transfert ; 8 domicile ET passage RPU
      dans les 24h précédant l'admission}  (non programmé)
    - DP ou DR du RSA cohérent avec ALD a (mapping ALD ↔ CIM-10
      à figer ; ex. ALD 5 IC → DP I50.x I11.0 ; ALD 8 diabète →
      DP E10-E14 avec complication ou DAS associé)
  GAP_PUIS_ADM_i_a = 1 si trouvée
```

### 4. Calcul de l'indicateur

```
TIAA = Σ_(i,a) GAP_PUIS_ADM_i_a / N_patients_ALD_éligibles
```

### 5. Sous-indicateurs

- **TIAA par ALD** : ALD 8 diabète (acidocétose, hyperglycémie, complications), ALD 5 IC (décompensation), ALD 14 IRC (urémie), ALD 23 psy (décompensation psy). Profils très différents.
- **TIAA par sévérité d'admission** : sévérité GHM 1-2 (modéré) vs 3-4 (lourd, USC/réa) — sur-représentation 3-4 attendue.
- **TIAA × FDep** : gradient social attendu marqué.
- **TIAA × ALD_sansMT** : interaction avec désaffiliation MT.
- **TIAA × durée du gap** : 12-18m, 18-24m, > 24m — plus le gap est long, plus la sévérité d'admission est élevée.
- **Indicateur économique dérivé** : valorisation T2A moyenne des admissions post-gap vs admissions ALD régulièrement suivies — quantifie le surcoût.

## Utilité

- **Quantification du renoncement « révélé »** : à la différence des enquêtes (Baromètre DREES), TIAA mesure le renoncement par sa conséquence — utile pour les financeurs et tutelles.
- **Pilotage des programmes de rappel et de relance** : un CPAM/ARS peut lancer une campagne « patient ALD sans suivi », mesurée par baisse TIAA à 12-24 mois.
- **Détection des bassins à fort renoncement** : TIAA par EPCI/CPTS révèle les territoires sous-dotés en spécialistes / MG, où le renoncement aboutit fréquemment à des admissions aiguës.
- **Priorisation des « patients à risque imminent »** : un patient ALD avec gap > 12 mois est candidat à un appel proactif (modèle « hot-spotting » de Camden NJ, adapté).
- **Modélisation du surcoût T2A** : admission aiguë décompensée coûte typiquement 5-15 fois une consultation de suivi évitée. Argumentaire pour financement médecine de ville.
- **Évaluation des dispositifs d'aller-vers** : équipes mobiles précarité, IPA, programmes Asalee — effet attendu sur TIAA.
- **Articulation avec mortalité 30j** : un patient post-gap admis a une mortalité supra-attendue ; combiné à `taux_mortalite_30j_post_sortie.md` (cat. 05), précise l'impact.

## Sources de Données

- **PMSI MCO — RSA** : `modeentree`, `DP`, `DR`, `DAS`, GHM, sévérité, `DATE_ENTREE`, `FINESSGEO`, identifiant chaîné
- **RPU urgences** : pour qualifier le caractère non programmé (passage urgences pré-admission)
- **SNDS — DCIR** :
  - `IR_IMB_R` — ALD actives par patient
  - `ER_PRS_F` — consultations, actes (spécialistes filière, bilans)
  - `ER_PHA_F` — délivrances médicamenteuses (classes ATC marqueurs ALD)
  - `IR_BEN_R` — caractéristiques bénéficiaire
- **Référentiels ALD** :
  - Listes CIM-10 par ALD (référentiel CNAM ALD 1-30)
  - Mapping ALD ↔ classes ATC marqueurs (à définir par filière)
  - Mapping ALD ↔ bilans biologiques attendus (référentiels HAS guidelines par pathologie)
- **Référentiels officiels** :
  - [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins) — cadre méthodologique
  - [HAS — Indicateurs parcours BPCO SNDS/PMSI](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi) — modèle de mapping pour BPCO transposable
  - [CNAM — Observatoire accès aux soins](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
  - [DREES — Baromètre santé 2023 (référence comparée)](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre)
- **Documentation SNDS** : [variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)

## Exemple de Valeurs

Ordres de grandeur experts (pas de restitution publique équivalente connue dans la session) :

- **TIAA toutes ALD** : 2-6 % de la file ALD annuelle.
- **TIAA ALD 8 (diabète)** : 3-7 % — gaps de suivi fréquents, complications aiguës.
- **TIAA ALD 5 (IC)** : 5-9 % — décompensations IC sur patient ALD perdu de vue.
- **TIAA ALD 14 (IRC)** : 4-8 %.
- **TIAA ALD 23 (psychiatrie)** : 8-15 % — rupture de suivi psy fréquente.
- **TIAA ALD 30 (cancer)** : 1-3 % — typiquement bien suivi.
- **TIAA × FDep Q5** : généralement 2× TIAA × FDep Q1 (gradient social marqué).
- **TIAA × ALD_sansMT** : 3-5× TIAA × ALD_avec_MT (interaction forte).
- **Durée gap moyenne en TIAA** : 14-20 mois.
- **Seuils d'alerte** :
  - TIAA > 8 % sur une ALD = alerte parcours
  - TIAA × Q5 / TIAA × Q1 > 2,5 = inégalité d'accès à corriger
  - TIAA × ALD_sansMT / TIAA × ALD_avec_MT > 4 = signal très fort d'effet protecteur du MT

## Limites

- **Définition du « gap » très sensible** au choix de marqueurs : marqueurs trop stricts (consultation diabéto annuelle) sous-estiment le suivi ville par MG seul ; marqueurs trop larges (toute consultation) le surestiment. Calibrage filière par filière, ancrage HAS guideline.
- **Confusion gap réel / gap administratif** : déménagement, changement de caisse (RSI → CNAM), passage RNIAM/non-RNIAM, séjour à l'étranger peuvent générer un gap apparent sans renoncement réel. Sous-cohorte à isoler.
- **Lien causal gap → admission** non démontrable rigoureusement : un patient peut décompenser malgré un suivi régulier (échec thérapeutique). TIAA capture une corrélation, pas une causalité.
- **Mapping ALD ↔ CIM-10 d'admission** : un patient ALD 8 admis pour AVC compatible avec complication diabétique sera-t-il compté ? Définir une matrice de cohérence par ALD, validée par cliniciens.
- **Accès SNDS** : indispensable ; les filières médicament + consultation spécialiste ne sont pas dans le PMSI seul. Un GHT sans accès SNDS ne peut pas calculer TIAA en routine.
- **Délai SNDS** : les données SNDS ont 6-12 mois de décalage ; TIAA ne peut pas être calculé en temps réel.
- **Effet COVID 2020-2022** : gaps massifs liés au confinement et aux reports — rupture temporelle dans la série historique.
- **Sous-codage ALD** : un patient avec affection chronique non déclarée en ALD (oubli administratif) est invisible — pas d'inclusion dans le dénominateur.
- **Volumes minimaux** : sous 200 patients ALD/an pour une affection donnée, instabilité. Agréger 2 ans ou cumuler ALD voisines.
- **Indicateur de stigmatisation potentiel** : usage doit être strictement orienté action (relance, accompagnement), pas désignation ; gouvernance éthique nécessaire.

## Références

D'après PubMed :

- [Lahbib H et al. — Frailty prediction in French SNDS, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — modèle de référence pour la construction de marqueurs SNDS chroniques. PMID 40175586
- [Baker KM et al. — Z codes scoping review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — contexte sous-codage SDOH. PMID 39570573

Sources officielles vérifiées dans la session :

- [DREES — Baromètre santé 2023 Dataviz (renoncement déclaré)](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre)
- [CNAM — Observatoire accès aux soins (cadre)](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
- [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [HAS — Indicateurs parcours BPCO SNDS/PMSI (modèle transposable)](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi)
- [Documentation SNDS — variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [IRDES — Actualités santé et protection sociale (gaps de soins, renoncement)](https://www.irdes.fr/documentation/news-en-economie-de-la-sante.html)
- [Sénat — Rapport équité territoriale R21-589](https://www.senat.fr/rap/r21-589/r21-5892.html)
