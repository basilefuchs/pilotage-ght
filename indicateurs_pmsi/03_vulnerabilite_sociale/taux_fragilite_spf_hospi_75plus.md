# Taux de Fragilité SPF chez les Hospitalisés ≥ 75 ans

## Définition

Le **taux de fragilité SPF chez les hospitalisés ≥ 75 ans** mesure la part des séjours MCO de patients de 75 ans et plus pour lesquels l'**algorithme prédictif de fragilité de Santé Publique France** (Lahbib et al., Sci Rep 2025, [DOI](https://doi.org/10.1038/s41598-025-95629-z)) classe le patient comme « fragile » à partir de son historique de consommation de soins SNDS sur les 24 mois précédant l'hospitalisation.

L'algorithme SPF transpose le **phénotype de Fried** (perte de poids, fatigabilité, lenteur, faiblesse, baisse d'activité — gold standard clinique) à des marqueurs administratifs (médicaments psychotropes, consultations spécialistes, hospitalisations antérieures, ALD, recours infirmier, etc.). Il a été développé sur l'enquête ESPS 2012 (n = 2 829) puis appliqué au SNDS national. La validation indirecte (Lahbib 2025) donne un **AUC = 0,80 pour les ≥ 75 ans**, une prévalence prédite SNDS de 12,9 % (vs 12,0 % attendue) et une association forte avec la mortalité à 6 ans (HR = 2,6). L'algorithme est utilisé en surveillance épidémiologique (Odissé SPF) depuis 2024 et publié au BEH du 12 mars 2026.

**Formule :**

**TFRAG75 = N_séjours_MCO_75plus_avec_prediction_fragile / N_séjours_MCO_75plus**

avec prédiction fragile = probabilité prédite par le modèle SPF ≥ seuil de calibration (typiquement la médiane de la population des 75+ ou un seuil produisant 12-15 % de positifs au niveau national).

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — score composite social, pas fragilité gériatrique
- `taux_recours_ajuste_fdep.md` — recours ajusté FDep territorial
- `indice_retention_soins_primaires.md` — rétention soins primaires
- `taux_primo_hospitalisation.md` — primo-hospi

Aucun indicateur ne capture la **fragilité gériatrique au sens du phénotype Fried**, alors que la fragilité est un déterminant majeur de mortalité, ré-hospitalisation et institutionnalisation post-MCO. SPF a mis cet algorithme dans le domaine public (Odissé) en 2024-2025 ; son intégration dans un tableau de bord GHT permet de quantifier la **charge gériatrique invisible** dans le PMSI brut.

## Calcul

### 1. Périmètre

```
Inclusion :
  - RSA MCO complet
  - `age` >= 75
  - Patient avec ≥ 24 mois d'historique SNDS exploitable (sinon
    sous-cohorte « historique insuffisant »)

Exclusion :
  - Séjours obstétricaux (CMD 14) — non applicable
  - Patients en USLD / EHPAD (parcours différent, fragilité par
    construction)
  - Décès intra-séjour : conservés (signal pertinent pour le suivi
    mortalité)
```

### 2. Mise en œuvre de l'algorithme SPF

L'algorithme stratifie par tranche d'âge (55-64, 65-74, ≥ 75). On utilise ici le modèle ≥ 75 ans (AUC = 0,80).

```
Variables d'entrée (SNDS, fenêtre [J - 24m, J - 1] avant séjour index) :
  - Consommation médicamenteuse (psychotropes, antalgiques palier 3,
    diurétiques, etc.) — DCIR table ER_PHA_F
  - Recours spécialisé (consultations gériatre, neuro, cardio) — DCIR ER_PRS_F
  - Hospitalisations antérieures (nombre, durée cumulée, GHM marqueurs
    chute, dénutrition, AVC) — PMSI
  - ALD actives et nombre — référentiel ALD CNAM
  - Recours infirmier libéral (passages/an)
  - Soins palliatifs, kinésithérapie
  - [liste exacte de variables et coefficients : Lahbib 2025 et code BOAS-HDH]

Modèle : régression logistique LASSO stratifiée ≥ 75 ans
Sortie : probabilité_fragilité_i ∈ [0, 1]
Seuil binaire : à calibrer selon objectif (médiane locale, ou seuil
produisant la prévalence attendue 12-15 %)
```

### 3. Calcul de l'indicateur

```
1. Pour chaque séjour index s, patient i ≥ 75 :
     fragile_i = 1 si probabilité_fragilité_i >= seuil
2. TFRAG75 = Σ_s fragile_i / Σ_s 1{séjour 75+}
```

### 4. Sous-indicateurs et stratifications

- **TFRAG75 par CMD index** : forte fragilité attendue en CMD 04 (respi), 05 (cardio), 08 (orthopédie chute), 23 (signes mal définis).
- **TFRAG75 par UM / service** : identifie les services « gériatriques de fait » non labellisés.
- **Croisement avec issue de séjour** : mortalité 30 j, retour aux urgences 7 j, réadmission 30 j stratifiés par état fragile/non fragile.
- **Indicateur dérivé EMG (Équipe Mobile Gériatrique)** :
```
TFRAG_EMG = nb_séjours_fragiles_évalués_par_EMG / nb_séjours_fragiles_total
```
Mesure de la couverture EMG sur la population cible.

## Utilité

- **Pilotage du **virage gériatrique** du GHT** : indicateur opposable du déploiement de l'EMG, de l'UCC, de l'UHCD gériatrique et des UPC (unités post-urgences).
- **Identification des « services gériatriques de fait »** : un service de médecine polyvalente avec TFRAG75 > 50 % devrait être référencé comme tel et bénéficier d'une formation gériatrique des équipes.
- **Modélisation prédictive des réadmissions** : la probabilité de fragilité SPF étant fortement associée à la mortalité (HR 2,6, Lahbib 2025) et probablement aux réadmissions, intégration possible comme covariable dans `score_predictif_rehospitalisation.md`.
- **Argumentaire capacitaire** : un TFRAG75 croissant sur 3 ans justifie l'ouverture de lits gériatriques aigus et la reconfiguration des urgences (filière courte gériatrique).
- **Comparaison inter-établissements GHT** à patientèle ajustée : TFRAG75 contextualise tous les autres indicateurs de qualité (un site avec TFRAG75 élevé doit être benchmarké à fragilité-égale).
- **Suivi des actions de prévention de la fragilité** : programmes type ICOPE OMS, consultations gériatriques de repérage en ville — TFRAG75 hospitalisé est l'indicateur d'aval permettant de mesurer la pertinence de l'amont.
- **Inscription au CPOM ARS / contrat GHT** : SPF promouvant la surveillance fragilité, l'indicateur est aligné avec les attentes de la tutelle.

## Sources de Données

- **PMSI MCO — RSA** : `age`, `SEXE`, `GHM`, `DP`, `DAS`, `duree`, `SOR_MOD`, `FINESSGEO`, identifiant patient chaîné (fichier ANO)
- **SNDS — DCIR** : tables `ER_PHA_F` (médicaments), `ER_PRS_F` (prestations spécialistes/IDE/kiné), `IR_BEN_R` (caractéristiques bénéficiaire)
- **SNDS — Historique PMSI** : séjours antérieurs sur 24 mois
- **Référentiel ALD CNAM** : table `IR_IMB_R` (ALD actives)
- **Algorithme SPF** :
  - [Lahbib H et al. — Development and indirect validation of a model predicting frailty in the French healthcare claims database, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — méthode, AUC, calibration
  - [Odissé SPF — Fragilité prévalence France](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/) — données ouvertes département × année
  - [BEH SPF 12 mars 2026 — Surveillance fragilité](https://www.santepubliquefrance.fr/sites/default/files/rdd/document/bullnat_fragilite_20260312.pdf)
  - [CASD — Algorithme de repérage fragilité/dépendance dans le SNDS](https://www.casd.eu/en/project/development-of-an-algorithm-for-tracking-fragility-and-dependence-in-health-insurance-medico-administrative-databases/) — projet source
- **Référentiel SNDS** : [Variables sociodémographiques SNDS](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)

## Exemple de Valeurs

Ordres de grandeur calibrés sur les publications SPF et l'expertise gériatrique :

- **Population générale 75+ non institutionnalisée (SPF 2022)** : ≈ 12-13 % de prévalence (Lahbib 2025).
- **Patients 75+ hospitalisés MCO (toutes spécialités)** : 30-50 % attendus, la fragilité étant un sur-risque d'hospitalisation. Calibrer localement.
- **CMD 05 (cardio, IC décompensée)** : 50-65 %.
- **CMD 08 (orthopédie, fracture col fémoral)** : 60-75 % — quasi-systématique.
- **CMD 04 (respi, BPCO décompensée)** : 55-70 %.
- **Chirurgie programmée 75+** : 20-35 % (sélection préopératoire opérée).
- **Médecine polyvalente / gériatrie aiguë** : > 70 % (signal de filière gériatrique de fait).
- **Couverture EMG (TFRAG_EMG)** : 15-40 % observée en pratique courante 2024 — cible HAS / SFGG > 60 %.
- **Seuil d'alerte** : TFRAG75 dans un service non gériatrique > 50 % sur 3 trimestres → besoin de formation équipes / EMG renforcée.

## Limites

- **Algorithme entraîné sur ESPS 2012** : un recalibrage SPF en 2024-2025 a confirmé sa validité, mais la consommation de soins évolue (e-prescription, virage ambulatoire) — calibration à actualiser périodiquement.
- **Historique SNDS de 24 mois requis** : patients nouvellement installés en France, patients sans recours antérieur, étrangers en court séjour ne sont pas évaluables. Documenter le taux de non-évaluables.
- **AUC 0,80 ≠ classification parfaite** : 20 % de cas mal classés au seuil optimal ; l'indicateur agrégé est plus fiable que l'usage individuel.
- **Seuil binaire dépendant** : choix du seuil influence la valeur ; toute comparaison inter-année / inter-établissement nécessite un seuil figé. Préférer parfois la *moyenne des probabilités prédites* à un taux binaire.
- **Spécificité ≥ 75 ans** : le modèle 55-64 a un AUC 0,61 — ne pas l'utiliser pour piloter ; le présent indicateur est restreint à 75+.
- **Disponibilité SNDS** : accès via Health Data Hub avec autorisation CNIL ; un GHT n'a pas accès direct au SNDS sauf via convention HDH ou via les portails dédiés CNAM. Pour usage local, une version réduite peut être calibrée sur le seul PMSI 24 mois disponible — perte de performance attendue.
- **Confusion fragilité / multimorbidité** : un patient très malade mais non fragile au sens Fried peut être classé fragile par l'algo (faux positif) ; à confronter aux évaluations cliniques EMG si disponibles.
- **Effet COVID 2020-2022** : la prévalence SPF a augmenté puis diminué (Odissé) ; toute série temporelle doit gérer la rupture COVID.
- **Pas d'usage individuel clinique** : SPF souligne que l'algorithme sert à la surveillance populationnelle, pas à la décision médicale individuelle — respecter ce cadre.
- **Volumes minimaux** : sous 100 séjours 75+ par UM/an, instabilité ; agréger.

## Références

D'après PubMed :

- [Lahbib H et al. — Development and indirect validation of a model predicting frailty in the French healthcare claims database, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — source méthodologique principale, AUC ≥ 75 = 0,80, prévalence SNDS 12,9 %. PMID 40175586

Sources officielles vérifiées dans la session :

- [Santé Publique France — Odissé : Fragilité prévalence France](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/)
- [SPF — BEH du 12 mars 2026 — Surveillance fragilité](https://www.santepubliquefrance.fr/sites/default/files/rdd/document/bullnat_fragilite_20260312.pdf)
- [CASD — Algorithme de repérage fragilité/dépendance SNDS](https://www.casd.eu/en/project/development-of-an-algorithm-for-tracking-fragility-and-dependence-in-health-insurance-medico-administrative-databases/)
- [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [DREES — ISD mise à jour mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
