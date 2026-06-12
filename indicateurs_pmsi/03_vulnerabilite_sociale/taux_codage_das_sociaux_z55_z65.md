# Taux de Codage des DAS Sociaux Z55-Z65

## Définition

Le **taux de codage des DAS sociaux Z55-Z65** mesure la part des séjours hospitaliers MCO d'un établissement comportant au moins un **diagnostic associé significatif (DAS) de la sous-section CIM-10 Z55-Z65** (« Sujets dont la santé peut être menacée par des conditions socioéconomiques et psychosociales »), parmi les séjours de patients dont la vulnérabilité sociale est par ailleurs probable (quintile FDep le plus défavorisé, CMU-C/AME active, ou DAS Z59 antérieur).

Les codes Z55-Z65 (CIM-10) regroupent :
- **Z55** : difficultés liées à l'éducation et à l'alphabétisation
- **Z56** : difficultés liées à l'emploi et au chômage
- **Z57** : exposition professionnelle à risque
- **Z58** : difficultés liées à l'environnement physique
- **Z59** : difficultés liées au logement et aux conditions économiques (sans-abri Z59.0, isolement Z59.6, etc.)
- **Z60** : difficultés liées à l'environnement social (isolement, exclusion, acculturation)
- **Z61** : difficultés liées à l'enfance
- **Z62** : autres difficultés liées à l'éducation
- **Z63** : autres difficultés liées à l'entourage immédiat (deuil, départ d'un proche, problèmes avec famille)
- **Z64** : difficultés liées à certaines circonstances psychosociales
- **Z65** : difficultés liées à d'autres circonstances psychosociales

La littérature internationale (Baker 2024 [DOI](https://doi.org/10.1097/MLR.0000000000002101) ; Guo 2020 [DOI](https://doi.org/10.1097/MD.0000000000023818)) documente un **taux d'utilisation médian de 1,2 % au niveau patient** et 1,4 % au niveau passage aux États-Unis — donc un **sous-codage massif** ne reflétant pas la prévalence réelle des déterminants sociaux. L'indicateur capture **la pratique de codage**, pas la prévalence — donc un proxy de la qualité documentaire DIM.

**Formule :**

**TZSOC = N_séjours_avec_DAS_Z55_Z65 / N_séjours_patients_vulnérables**

où **patient vulnérable** = patient avec au moins un des critères :
- FDep ≥ quintile 4 (IRIS de résidence)
- CMU-C ou AME active (SNDS)
- DAS Z55-Z65 sur un séjour antérieur dans les 24 mois

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — score composite social du patient
- `taux_recours_ajuste_fdep.md` — recours ajusté FDep
- `taux_primo_hospitalisation.md` — primo-hospi
- `indice_permeabilite_sociale_soins_preventifs.md` — accès prévention
- `taux_sortie_contre_avis_medical.md` — proxy détresse sociale

Aucun indicateur ne mesure spécifiquement la **qualité du codage des Z-codes sociaux**, qui est un préalable à toute analyse de précarité issue du PMSI lui-même. L'indicateur sert deux objectifs : (1) connaître la vulnérabilité sociale codée localement, (2) identifier le sous-codage et déclencher des actions correctives DIM.

## Calcul

### 1. Identification de la cohorte vulnérable (dénominateur)

```
Patient_vulnérable_i = 1 SI :
   IRIS_résidence(i) appartient au quintile FDep ≥ Q4 national
   OU CMU_C_active(i, fenêtre 24m) = 1 (SNDS — table IR_BEN_R)
   OU AME_active(i, fenêtre 24m) = 1
   OU au moins un séjour antérieur 24m avec DAS Z55-Z65
```

Précisions :
- **FDep** : indice écologique territorial Rey calculé à l'IRIS, mis à jour DREES/INSEE, fourni avec les données SNDS ou via la documentation SNDS [variables sociodémo](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo).
- **CMU-C / AME** : disponible dans `IR_BEN_R` (SNDS) ; à défaut, proxy par les variables PMSI assurance et complémentaire (limité, peu fiable).

### 2. Détection des DAS Z55-Z65 (numérateur)

```
Pour chaque séjour s du patient vulnérable i :
   has_Z_social_s = 1 SI au moins un DAS du RSA appartient à
      Z55* ∪ Z56* ∪ Z57* ∪ Z58* ∪ Z59* ∪ Z60* ∪
      Z61* ∪ Z62* ∪ Z63* ∪ Z64* ∪ Z65*
   (codage CIM-10-FR en vigueur — vérifier la version annuelle utilisée
   par l'ATIH dans le manuel de la classification CIM-10)
```

### 3. Calcul de l'indicateur

```
TZSOC = Σ_s has_Z_social_s / Σ_s 1{séjour patient vulnérable}
```

### 4. Sous-indicateurs

- **TZSOC par code** : décomposition par grand bloc (Z59 logement, Z60 environnement social, Z63 entourage, Z65 autres) — révèle le profil de codage.
- **TZSOC par UM/service** : identifie les services « bons codeurs » vs « non codeurs » des Z-codes — souvent les urgences, gériatrie, médecine interne sont meilleures que les blocs chirurgicaux.
- **TZSOC par codeur DIM** : si traçabilité interne possible, formation ciblée.
- **Indicateur dérivé d'évolution** :
```
Δ_TZSOC = TZSOC(t) - TZSOC(t-1)
```
mesure l'effet d'un plan d'action de codage (formation DIM, lettre à direction, kit codage).

## Utilité

- **Diagnostic de la qualité documentaire DIM** : un TZSOC < 3 % sur cohorte vulnérable signale un sous-codage massif, à confronter au benchmark international (Baker 2024 : médiane 1,2 % — encore plus bas aux US).
- **Plan d'action codage Z-social** : la HAS a inscrit les déterminants sociaux dans plusieurs axes (parcours BPCO, etc.) ; la formation DIM sur Z55-Z65 améliore directement les autres indicateurs sociaux.
- **Pré-requis à toute analyse PMSI sur précarité** : sans codage, les indicateurs comme `score_vulnerabilite_sociale` perdent leur sensibilité. TZSOC est l'indicateur de fiabilité.
- **Valorisation T2A et CMA** : certains Z-codes (notamment Z59.0 sans-abri, Z63.x deuil aigu) peuvent contribuer aux complications/morbidités associées et impacter la sévérité GHM. Le codage est donc aussi un enjeu financier.
- **Détection des sans-abri et grands précaires** : Z59.0 (« absence de logement ») et Z59.1 (« logement inadéquat ») doivent être systématiquement codés en présence d'une PASS active ou d'un signalement social ; suivi spécifique.
- **Alignement avec axes HAS et DGOS** : la DGOS pousse une politique d'amélioration de la captation des déterminants sociaux ; TZSOC est un indicateur opposable.
- **Comparaison inter-GHT** : à FDep et casemix ajustés, TZSOC compare les pratiques de codage indépendamment de la prévalence territoriale réelle.

## Sources de Données

- **PMSI MCO — RSA** :
  - `DP`, `DR`, `DAS` (multiples) — chercher les codes commençant par Z55 à Z65
  - `age`, `SEXE`, `FINESSGEO`, `UM`
  - Identifiant chaîné via fichier ANO
- **SNDS — DCIR** :
  - `IR_BEN_R` — bénéficiaire (CMU-C, AME, date d'ouverture des droits)
  - Croisement IRIS résidence ↔ table FDep (ou autre indice : EDI, French Deprivation Index Townsend équivalent)
- **Référentiels** :
  - [CIM-10-FR — version ATIH en vigueur](https://www.atih.sante.fr/) (vérifier version annuelle utilisée pour le groupage : V016 2025 / V017 2026 [à confirmer dans la notice ATIH-31-1-2025])
  - [Guide méthodologique PMSI MCO en vigueur](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
  - [Documentation SNDS — variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
  - DREES — indice FDep Rey publié à l'IRIS
- **Référentiels HAS** :
  - [HAS — Indicateurs de qualité des parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins) — cadre validité indicateurs PMSI
  - [HAS — Indicateurs parcours BPCO SNDS](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi)

## Exemple de Valeurs

Ordres de grandeur calibrés sur la littérature internationale (Baker 2024, Guo 2020) et l'expérience PMSI française (codage Z encore plus rare).

- **Données US niveau patient** (Baker 2024) : médiane 1,2 %, étendue 0,4 % à 17,6 %.
- **TZSOC France, cohorte vulnérable, moyenne attendue** : 2-6 % en pratique courante 2024-2025.
- **CH avec PASS (Permanence d'Accès aux Soins de Santé) active** : 8-20 % grâce à un codage systématique par la PASS.
- **CHU avec service social hospitalier dense et formation DIM ciblée** : 10-15 %.
- **CH général sans dispositif spécifique** : 1-4 %.
- **Clinique privée** : < 1 % typiquement (codage Z-social non valorisé tarifairement, négligé).
- **Z59 (logement) sur séjours urgences précarité** : 5-15 % dans un CH avec PASS.
- **Z63 (entourage / deuil)** : très rarement codé en France (< 0,5 % toutes cohortes).
- **Seuil d'alerte** : TZSOC < 2 % sur cohorte FDep Q5 → audit codage et formation DIM ; ratio TZSOC_urgences / TZSOC_blocs_chir > 5 = signal qualité hétérogène, à uniformiser.

## Limites

- **L'indicateur mesure le codage, pas la vulnérabilité réelle** : un TZSOC élevé ne signifie pas une patientèle plus précaire, mais un meilleur codage. À interpréter en parallèle de FDep et indicateurs externes.
- **Sous-codage massif documenté internationalement** (Baker 2024, Guo 2020) : médianes 1-2 % — TZSOC français probablement encore plus bas. Donc l'indicateur a une plage d'évolution forte.
- **Dénominateur dépendant** : la définition de « patient vulnérable » (FDep Q4-Q5 vs Q5 seul vs CMU-C) change radicalement la valeur. Documenter la convention.
- **Codes Z et T2A** : la valorisation des Z-codes peut être marginale ou nulle (la plupart ne sont pas des CMA opérantes en V2025 — à vérifier dans la table CMA en vigueur), ce qui ne motive pas le codeur. L'indicateur révèle alors un défaut structurel d'incitation.
- **Hétérogénéité des codes Z** : Z55 (éducation) très rarement pertinent en MCO, Z59 (logement) souvent pertinent et sous-codé ; affiner par bloc plutôt que masse globale.
- **Évolution de la CIM** : la CIM-11 (déjà disponible OMS) modifiera ces catégories ; suivre la version utilisée pour le groupage PMSI français.
- **Disponibilité FDep** : FDep est calculé à l'IRIS — patients avec adresse mal renseignée (sans-abri par exemple) sont eux-mêmes mal classés. Paradoxe : la cohorte la plus à risque est partiellement invisible à l'algorithme FDep.
- **Confidentialité** : les Z-codes sociaux sont des données très sensibles ; usage encadré CNIL et information patient à respecter.
- **Volumes minimaux** : sous 200 séjours dans la cohorte vulnérable annuelle, instabilité ; agréger 2 ans.
- **Comparaison internationale** : taux US (Baker 2024, Guo 2020) non directement transposables à la France (système de codage et incitations différents).

## Références

D'après PubMed :

- [Baker KM et al. — Using Z Codes to Document Social Risk Factors in the EHR : Scoping Review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — synthèse de 32 études, médiane 1,2 % au patient. PMID 39570573
- [Guo Y et al. — ICD-10 Social Determinants of Health codes poorly used in EHR, Medicine 2020](https://doi.org/10.1097/MD.0000000000023818) — analyse OneFlorida, taux 2,03 % patient, croissance post-guidelines 2018. PMID 33350768

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Notice technique 2026](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
- [Documentation SNDS — variables sociodémographiques (CMU-C, AME, FDep)](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [HAS — Indicateurs de qualité des parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [DREES — Indicateurs Sociaux Départementaux ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
