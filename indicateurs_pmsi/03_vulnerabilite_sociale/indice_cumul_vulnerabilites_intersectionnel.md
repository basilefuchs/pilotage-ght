# Indice de Cumul de Vulnérabilités Intersectionnel

## Définition

L'**indice de cumul de vulnérabilités intersectionnel (ICV)** mesure, par patient hospitalisé, le nombre de marqueurs distincts de vulnérabilité qu'il cumule, à partir d'un ensemble fixé de 6 axes mobilisables sur PMSI/SNDS :

```
AXES_VULN = {
  V1 : précarité socio-économique territoriale (FDep ≥ Q5)
  V2 : couverture sociale dégradée (CMU-C ou AME active)
  V3 : handicap psychique/intellectuel/cognitif (algorithme FISH-PIC IRDES)
  V4 : fragilité gériatrique (algorithme SPF ≥ 75 ans, Lahbib 2025)
  V5 : isolement social codé (DAS Z60-Z63, Z74-Z75)
  V6 : désaffiliation médecin traitant (ALD sans MT 12 mois, Observatoire CNAM)
}
```

**Formule :**

Pour chaque patient i :

**ICV_i = Σ_{k=1..6} 1{patient i présente l'axe V_k}**

Indicateur agrégé sur file active :

**ICV_moyen = mean(ICV_i)** ; **TICV_3plus = Σ_i 1{ICV_i ≥ 3} / N**

Le concept de **vulnérabilité intersectionnelle** (Crenshaw 1989) postule que le cumul de plusieurs axes n'est pas additif mais multiplicatif sur les outcomes ; l'indicateur capture cette dimension qui échappe à chaque marqueur isolé.

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — score composite mais sans dimension intersectionnelle explicite
- `taux_recours_ajuste_fdep.md` — un seul axe (FDep)
- `taux_fragilite_spf_hospi_75plus.md` — un seul axe (fragilité 75+)
- `taux_identification_fish_pic_hospi.md` — un seul axe (PIC)
- `taux_hospi_isolement_social_geriatrique.md` — un seul axe (isolement)
- `taux_patients_ald_sans_medecin_traitant_hospi.md` — un seul axe (désaffiliation MT)

Aucun indicateur ne **croise systématiquement** ces axes et ne quantifie le **cumul** par patient. ICV s'inspire des Social Vulnerability Index (SVI, CDC) et de la littérature intersectionnelle pour produire une métrique simple, agrégeable, repérant les patients « sur-cumulés » qui devraient bénéficier d'un case management renforcé.

## Calcul

### 1. Construction des indicateurs binaires par axe

```
V1 = 1 si IRIS_résidence(i) appartient au quintile Q5 FDep national
V2 = 1 si CMU_C ou AME active dans IR_BEN_R sur [j-365, j]
V3 = 1 si FISH-PIC_positif (algorithme IRDES rapport 592)
V4 = 1 si `age` >= 75 ET probabilité_fragilité_SPF >= seuil (Lahbib 2025)
V5 = 1 si au moins un DAS ∈ {Z60.x, Z63.x, Z74.x, Z75.1} sur le séjour
        index OU sur séjour antérieur dans la fenêtre 24 mois
V6 = 1 si patient avec ≥ 1 ALD active ET aucune déclaration MT active sur
        12 mois précédant l'admission
```

### 2. Calcul de l'indice

```
Pour chaque patient i de la file active hospitalière :
  ICV_i = Σ_k V_k(i)
```

### 3. Agrégation

```
ICV_moyen        = mean(ICV_i) sur cohorte
TICV_3plus       = Σ_i 1{ICV_i ≥ 3} / N        (proportion sur-cumulée)
distribution_ICV = histogramme 0, 1, 2, 3, 4, 5, 6
ICV_par_axe      = pour chaque k, P(V_k = 1)   (prévalence axe)
matrice_intersections = matrice 6×6 des co-occurrences pondérées
```

### 4. Sous-indicateurs

- **TICV_3plus_75+** : sur-cumul gériatrique — souvent V3+V4+V5 ensemble.
- **TICV_3plus_18-44** : sur-cumul adulte jeune — souvent V1+V2+V3+V6 (jeune précaire psychique désaffilié).
- **Composante principale (PCA)** : la première composante des 6 axes binaires donne un score continu plus fin que ICV.
- **Coefficient d'amplification intersectionnel** :
```
AMPL_k = TX_event(ICV ≥ k+1) / TX_event(ICV = k)
```
où event = retour urgences 7j ou mortalité 30j — test de l'effet multiplicatif.

## Utilité

- **Repérage des patients « sur-cumulés » pour case management** : TICV_3plus identifie 5-15 % de la file active à charge socio-médicale très forte, candidats à un suivi renforcé (Charles 2024 [DOI](https://doi.org/10.1097/NCM.0000000000000742)).
- **Justification du déploiement de gestionnaires de cas** : ICV permet de quantifier le besoin, dimensionner les effectifs et démontrer le ROI.
- **Pilotage par filière** : la décomposition de la matrice d'intersections révèle des profils-types : « adulte jeune précaire/psy/désaffilié », « gériatre fragile isolé », « migrant AME urgences » — orientant les programmes ciblés.
- **Comparaison inter-établissements** : ICV ajusté permet de comparer la charge sociale réelle, plus complète qu'un FDep seul.
- **Évaluation des programmes d'intervention sociale** : déploiement d'une équipe précarité-psychiatrie-gériatrie → suivi temporel ICV_moyen et TICV_3plus.
- **Modélisation prédictive** : ICV comme covariable dans `score_predictif_rehospitalisation.md` ; le cumul intersectionnel a typiquement un effet supra-additif sur la réadmission.
- **Argumentaire ARS** : un GHT avec TICV_3plus > 12 % peut argumenter pour un financement spécifique (MIG précarité, FIR).

## Sources de Données

Source unique : combinaison de tous les flux nécessaires aux 6 axes (voir les fiches dédiées par axe pour les détails de chaque source).

- **PMSI MCO** : RSA, DAS, identifiant chaîné ANO
- **SNDS — DCIR** : `IR_BEN_R` (CMU-C, AME, MT déclaré), `IR_IMB_R` (ALD), `ER_PHA_F` (médicaments marqueurs FISH-PIC et SPF)
- **FDep INSERM/CépiDc** : IRIS résidence → quintile FDep
- **Algorithmes** :
  - SPF Fragilité (Lahbib 2025, [DOI](https://doi.org/10.1038/s41598-025-95629-z))
  - FISH-PIC ([IRDES Rapport 592](https://www.irdes.fr/recherche/2024/rapport-592-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html))
  - Désaffiliation MT (méthodologie CNAM Observatoire, [communiqué](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins))
- **Référentiels** :
  - [CNAM — Observatoire de l'accès aux soins](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
  - [SPF — Odissé Fragilité](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/)
  - [Health Data Hub — BOAS algorithme PIC](https://www.health-data-hub.fr/bibliotheque-ouverte-algorithmes-sante/developpement-dun-algorithme-de-reperage-des-individus-0)
  - [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
  - [DREES — ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)

## Exemple de Valeurs

Ordres de grandeur experts (pas de restitution publique équivalente connue dans la session) :

- **Distribution attendue ICV en file MCO** : ICV=0 : 30-40 % ; ICV=1 : 25-30 % ; ICV=2 : 15-20 % ; ICV=3 : 7-12 % ; ICV=4 : 3-5 % ; ICV≥5 : < 2 %.
- **ICV_moyen file MCO toutes spé** : 1,0-1,5.
- **ICV_moyen 75+ MCO** : 1,8-2,5 (V4 fragilité quasi systématique + V5 isolement fréquent).
- **ICV_moyen CMD 19 (psy)** : 2,0-3,0 (V3 et souvent V1+V2+V6).
- **TICV_3plus toutes spé** : 8-15 %.
- **TICV_3plus en CHU avec PASS active** : 12-20 %.
- **CH général sans PASS / non-codeur** : 3-7 % (souvent par défaut de codage V5 plutôt que par cumul plus faible).
- **AMPL pour retour urgences 7j** : typiquement 1,8-2,5 par cran ICV (effet multiplicatif).
- **Seuils d'alerte** :
  - TICV_3plus > 18 % → mobilisation IPA + équipe précarité élargie
  - V5 codé < 3 % et V1 (FDep Q5) > 20 % → défaut de codage social, plan DIM
  - AMPL retour urgences ICV ≥ 4 vs ICV = 0 > 4 → sur-risque intersectionnel manifeste, à protocoliser

## Limites

- **Dépendance aux algorithmes sous-jacents** : ICV hérite des limites de chaque axe (FISH-PIC, SPF, codage Z, etc.) ; les biais s'additionnent voire se renforcent.
- **Pondération uniforme contestable** : sommer 1{V_k} traite tous les axes comme équivalents ; en pratique V4 (fragilité gériatrique) et V2 (CMU-C) sont des marqueurs très différents en intensité. Pondérations possibles à calibrer empiriquement (effet sur outcome cible).
- **Sous-codage de V5 (isolement)** : sous-codage massif documenté ([Baker 2024, DOI](https://doi.org/10.1097/MLR.0000000000002101) ; [Guo 2020, DOI](https://doi.org/10.1097/MD.0000000000023818)) → V5 systématiquement biaisé à la baisse.
- **Période de fenêtre 12-24 mois** : un patient nouvellement arrivé ou récemment ouvert en ALD aura une fenêtre tronquée → sous-cohorte « historique court » à isoler.
- **Accès SNDS nécessaire** : V2, V3, V4, V6 nécessitent l'accès aux tables IR/ER ; un GHT sans accès SNDS doit se restreindre à V1+V5 → ICV simplifié, moins puissant.
- **Effet « pile de vulnérabilités » sans causalité** : ICV agrège sans modéliser les liens (l'isolement cause la fragilité, qui cause la désaffiliation, etc.). Pour l'analyse causale, modèles structurels requis.
- **Stabilité temporelle** : V4 (fragilité) et V5 (isolement) peuvent évoluer entre deux séjours ; figer une « date de mesure ICV » par séjour.
- **Confidentialité et éthique** : ICV est un score de vulnérabilité individuel — usage strictement encadré (case management, action sociale), pas de partage non sécurisé, gouvernance éthique du GHT obligatoire.
- **Comparaison inter-établissement** : un CHU avec PASS code mieux V5 → ICV apparemment plus élevé. Ajuster sur la qualité de codage V5 (`taux_codage_das_sociaux_z55_z65`).
- **Volumes minimaux** : sous 500 patients de file active, instabilité de la distribution ICV ; consolider sur 2 ans.

## Références

D'après PubMed :

- [Lahbib H et al. — Frailty prediction in French claims database, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — axe V4. PMID 40175586
- [Baker KM et al. — Z codes scoping review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — sous-codage axe V5. PMID 39570573
- [Guo Y et al. — ICD-10 SDOH codes EHR, Medicine 2020](https://doi.org/10.1097/MD.0000000000023818) — sous-codage social. PMID 33350768
- [Charles L et al. — Complex Case Management, Prof Case Manag 2024](https://doi.org/10.1097/NCM.0000000000000742) — populations cumulant les vulnérabilités, justifie le case management. PMID 39058563

Sources officielles vérifiées dans la session :

- [CNAM — Observatoire accès aux soins 2025](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins) — axe V6
- [IRDES — Rapport 592 FISH-PIC, 2024](https://www.irdes.fr/recherche/2024/rapport-592-faisabilite-d-identification-des-personnes-a-risque-de-handicap-fish.html) — axe V3
- [Health Data Hub — BOAS algorithme PIC](https://www.health-data-hub.fr/bibliotheque-ouverte-algorithmes-sante/developpement-dun-algorithme-de-reperage-des-individus-0)
- [SPF — Odissé Fragilité](https://odisse.santepubliquefrance.fr/explore/dataset/fragilite-prevalence-france/) — axe V4
- [Documentation SNDS — variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [DREES — ISD MAJ 26 mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- [HAS — Indicateurs qualité parcours](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)

Référence conceptuelle non re-vérifiée :
- Crenshaw KW — Demarginalizing the Intersection of Race and Sex, 1989 — origine du concept intersectionnel. *À vérifier avant publication officielle.*
