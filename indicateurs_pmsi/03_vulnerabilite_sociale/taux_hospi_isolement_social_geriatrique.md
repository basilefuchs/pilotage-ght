# Taux d'Hospitalisation avec Isolement Social en Gériatrie

## Définition

Le **taux d'hospitalisation avec isolement social en gériatrie** mesure la part des séjours MCO de patients de 75 ans et plus pour lesquels au moins un **diagnostic associé significatif (DAS) marqueur d'isolement social ou de problème d'entourage** est codé. La liste de référence retient les sous-catégories CIM-10 :

- **Z60.2** : Difficultés liées à la vie en isolement (« lives alone »)
- **Z60.3** : Difficultés liées à l'acculturation
- **Z60.4** : Exclusion et rejet social
- **Z63.0** : Problèmes dans les relations conjugales
- **Z63.4** : Disparition / décès d'un membre de la famille
- **Z63.5** : Rupture familiale par séparation ou divorce
- **Z63.6** : Personne dépendante seule au domicile (« absent family member »)
- **Z63.7** : Autres événements stressants affectant la famille
- **Z74** : Problèmes liés à la dépendance vis-à-vis de la personne soignante
- **Z75.1** : Personne attendant son admission dans un autre établissement

L'isolement social est un déterminant majeur de mortalité, ré-hospitalisation, dénutrition et déclin fonctionnel chez la personne âgée (Wang 2023, [DOI](https://doi.org/10.1136/bmjopen-2023-072305) : prévalence 44,3 % en communauté, médiation par dépression et nutrition). Sa captation par le PMSI est cruciale pour cibler les sorties à risque, mais reste très hétérogène entre établissements.

**Formule :**

**TISOL75 = N_séjours_75plus_avec_DAS_isolement / N_séjours_75plus**

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — score composite (général)
- `taux_codage_das_sociaux_z55_z65.md` (ce dossier, généraliste sur Z55-Z65)
- `taux_sortie_contre_avis_medical.md` — proxy détresse
- `taux_fragilite_spf_hospi_75plus.md` (ce dossier) — fragilité gériatrique
- catégorie 07 : `taux_retour_domicile_sortie_ssr.md`, `taux_retour_urgences_7j_post_sortie_mco.md`

Aucun indicateur n'isole spécifiquement la **dimension isolement social en gériatrie**, qui est pourtant le principal frein opérationnel à une sortie sécurisée. À la différence de `taux_codage_das_sociaux_z55_z65` (qui couvre toute la cohorte vulnérable), TISOL75 est restreint à 75+ et cible un sous-ensemble d'isolement, opérationnel pour les équipes UPC / UCC / EMG / assistants sociaux.

## Calcul

### 1. Périmètre

```
Inclusion :
  - RSA MCO complet
  - `age` >= 75
  - Tout mode d'entrée et destination (sauf décès intra-séjour pour
    sous-indicateur de sortie)

Exclusion :
  - Séjours obstétricaux (sans objet)
  - Séjours en HDJ (sauf si étude spécifique HDJ gériatrique)
```

### 2. Détection des DAS d'isolement

```
ISOLEMENT_CIM10 = {
  "Z60.2", "Z60.3", "Z60.4",
  "Z63.0", "Z63.4", "Z63.5", "Z63.6", "Z63.7",
  "Z74.0", "Z74.1", "Z74.2", "Z74.3", "Z74.8", "Z74.9",
  "Z75.1"
}

Pour chaque RSA s :
  has_iso_s = 1 SI au moins un DAS ∈ ISOLEMENT_CIM10
```

### 3. Calcul

```
TISOL75 = Σ_s has_iso_s / Σ_s 1{séjour 75+}
```

### 4. Sous-indicateurs

- **TISOL_par_UM** : urgences, médecine polyvalente, gériatrie aiguë, orthopédie post-chute — révèle où le codage est le plus précis.
- **TISOL_par_motif_sortie** : sortie domicile / EHPAD / SSR — un patient isolé sortant domicile mérite une attention accrue.
- **Croisement avec retour aux urgences 7 j et réadmission 30 j** : test de la valeur prédictive de l'isolement codé.
- **Indicateur dérivé d'écart** :
```
ECART_ISOL_VQS = TISOL75 - (prévalence_VQS_isolement_75+)
```
où la prévalence VQS DREES 2021 sert de cible attendue (à confirmer) — un écart fortement négatif révèle un sous-codage.

- **Indicateur d'action sociale** :
```
TISOL75_AVEC_PEC_SOCIALE = nb_séjours_TISOL_avec_intervention_assistante_sociale / nb_séjours_TISOL
```
Capacité de l'établissement à activer l'aval social. Nécessite un croisement avec les actes/forfaits assistant social hospitalier si tracés [à confirmer dans la nomenclature].

## Utilité

- **Ciblage opérationnel des sorties à risque** : un patient 75+ avec Z63.6 (personne dépendante seule au domicile) sortant domicile doit déclencher une coordination renforcée (HAD, IDE de coordination, signalement CCAS).
- **Évaluation des UPC et UCC** : un déploiement UPC doit améliorer le repérage (TISOL75 croissant) et la prise en charge (TISOL75_AVEC_PEC_SOCIALE croissant).
- **Argumentaire pour renforcement des assistants sociaux hospitaliers** : un TISOL75 codé mais TISOL75_AVEC_PEC_SOCIALE faible révèle un manque de ressources sociales.
- **Mesure de l'effet COVID** : Wang 2023 ([DOI](https://doi.org/10.1136/bmjopen-2023-072305)) documente l'accroissement de l'isolement social pendant la pandémie ; suivi temporel TISOL75 post-COVID permet de mesurer le retour à la normale ou la permanence.
- **Filière fracture col fémoral** : la fracture du col fémoral est très souvent associée à un isolement social (chute non secourue) ; TISOL75 sur cohorte fracture col oriente les protocoles « ortho-gériatrie » et l'orientation SSR vs domicile.
- **Diagnostic territorial** : un TISOL75 supérieur dans certains CH du GHT signale des bassins à forte vulnérabilité gériatrique — alignement avec les politiques de soutien aux aidants et CLIC.
- **Lien réadmissions évitables** : l'isolement augmente significativement les réadmissions ; intégrer TISOL75 comme covariable dans `score_predictif_rehospitalisation.md`.

## Sources de Données

- **PMSI MCO — RSA** :
  - `DP`, `DR`, `DAS` (Z60.x, Z63.x, Z74.x, Z75.x — vérifier liste à figer par le DIM)
  - `age`, `SEXE`, `modeentree`, `SOR_MOD`, `destination`, `UM`, `FINESSGEO`, identifiant chaîné ANO
- **Référentiel CIM-10** :
  - Version ATIH en vigueur (V016 2025 / V017 2026 [à confirmer dans la notice ATIH-31-1-2025])
  - [ATIH — Notice technique PMSI 2025](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- **Données contextuelles** :
  - VQS 2021 — enquête Vie Quotidienne et Santé DREES/INSEE : prévalence de l'isolement à domicile par âge
  - [SPF — Surveillance fragilité](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/) — interaction fragilité × isolement
  - DREES — [ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj) (notamment indicateur « part de personnes âgées vivant seules »)
- **Référentiel HAS** :
  - [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- **Documentation SNDS** : [variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)

## Exemple de Valeurs

Ordres de grandeur experts (faute de restitution publique ScanSanté/HAS dédiée, calibration à partir de VQS DREES 2021 et littérature gériatrique) :

- **Prévalence VQS 2021 isolement 75+ à domicile** : ≈ 25-35 % vivent seuls (DREES).
- **Prévalence réelle isolement « social » fonctionnel 75+** : 40-55 % en cohorte Wang 2023 (Chine post-COVID).
- **TISOL75 codé MCO France, pratique courante 2025** : 2-8 % — sous-codage majeur attendu.
- **CH avec gériatrie aiguë formée et EMG active** : 10-20 %.
- **CHU avec consultation gériatrique systématique + EMG** : 15-25 %.
- **Service d'urgences avec orientation systématique « personne âgée isolée »** : 8-15 % sur séjours 75+ post-passage.
- **Orthopédie post-chute col fémoral** : 15-25 % attendu si codage correct (contexte chute domicile sans secours rapide).
- **TISOL75 < 2 %** : sous-codage majeur, alerte qualité documentaire.
- **Seuils d'alerte** :
  - TISOL75 < 5 % avec EMG active → audit pratiques codage
  - ECART_ISOL_VQS < -15 points → plan d'amélioration documentaire urgent
  - TISOL75_AVEC_PEC_SOCIALE < 30 % des cas codés → renforcement assistants sociaux

## Limites

- **Codage Z60-Z75 extrêmement hétérogène** : la pratique de codage est très dépendante du DIM et de la sensibilisation des équipes ; TISOL75 mesure d'abord la qualité documentaire avant la prévalence réelle.
- **Pas un indicateur fonctionnel** : Z60.2 « lives alone » est codé sur déclaration ; il ne mesure pas l'isolement subjectif (échelle Lubben) ni le réseau social fonctionnel.
- **Confusion isolement géographique vs émotionnel** : un patient vivant seul avec un réseau familial proche n'est pas isolé fonctionnellement ; le PMSI ne distingue pas.
- **Codes très peu valorisés** : la plupart de ces Z-codes ne sont pas des CMA opérantes en V2025 (à vérifier) — donc faiblement incitatifs au codage ; explique en partie le sous-codage.
- **Effet « biais d'attention »** : un service avec assistante sociale présente code mieux que sans — ce qui crée un cercle vertueux mais rend la comparaison inter-établissements piégée.
- **Couplage VQS** : la prévalence DREES VQS est une approximation, pas une cible directement opposable.
- **Période COVID** : 2020-2022 ont vu une explosion de l'isolement social codé ; rupture temporelle à gérer dans les séries longues.
- **Volumes minimaux** : sous 50 séjours 75+ / UM / an, instabilité ; agréger.
- **Pas d'usage individuel** : indicateur populationnel, pas un outil de décision clinique individuelle.
- **Stigmatisation possible** : usage encadré, information patient, gouvernance éthique.
- **Recouvrement avec d'autres indicateurs** : TISOL75 partage des sources avec `taux_codage_das_sociaux_z55_z65.md` ; à lire en complément, pas en redondance.

## Références

D'après PubMed :

- [Wang X et al. — Social isolation, depression, nutritional status and quality of life during COVID-19 among Chinese community-dwelling older adults, BMJ Open 2023](https://doi.org/10.1136/bmjopen-2023-072305) — prévalence isolement 44,3 %, médiation dépression-nutrition. PMID 37723110
- [Baker KM et al. — Using Z Codes to Document Social Risk Factors : Scoping Review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — sous-codage des Z-codes au niveau international. PMID 39570573
- [Guo Y et al. — ICD-10 SDOH codes poorly used in EHR, Medicine 2020](https://doi.org/10.1097/MD.0000000000023818) — sous-codage Z-codes (1-2 % patient). PMID 33350768
- [Lahbib H et al. — Frailty prediction in French claims database, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — corrélation fragilité × isolement chez 75+. PMID 40175586

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Notice technique 2026](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
- [SPF — Odissé : Fragilité prévalence France](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/)
- [SPF — BEH 12 mars 2026 — Surveillance fragilité](https://www.santepubliquefrance.fr/sites/default/files/rdd/document/bullnat_fragilite_20260312.pdf)
- [DREES — ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [Documentation SNDS — variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
