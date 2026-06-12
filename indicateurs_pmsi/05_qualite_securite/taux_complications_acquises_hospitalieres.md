# Taux de Complications Acquises Hospitalières (HAC)

## Définition

Les **Hospital-Acquired Conditions (HAC)** sont des complications survenues **pendant** le séjour, par opposition aux comorbidités et complications **présentes à l'admission** (POA = Present On Admission). La distinction HAC/POA est centrale pour mesurer la qualité de soins imputable à l'établissement : un AVC codé chez un patient hospitalisé pour AVC ne traduit pas un défaut de qualité, alors qu'un AVC ischémique survenu à J+5 d'une chirurgie cardiaque programmée si.

Aux États-Unis, Medicare a rendu le marqueur POA obligatoire en 2008 (HAC-POA program, CMS) et l'utilise pour ajuster paiement et indicateurs publics. En France, **le PMSI ne dispose pas d'un flag POA formel** : un *diagnostic associé significatif* (DAS) au sens du *Guide méthodologique de production des informations relatives à l'activité médicale en MCO* (ATIH 2025) est défini comme « toute affection coexistant avec la morbidité principale ayant fait l'objet d'une prise en charge effective », sans distinction temporelle. Construire un indicateur HAC en PMSI repose donc sur un **proxy par croisement** :
1. liste explicite de codes CIM-10 marqueurs de complications acquises (escarres décubitus L89, septicémie post-opératoire T81.4, embolie pulmonaire post-opératoire I26 + DAS T81, infection urinaire nosocomiale T83.5, etc.) ;
2. exclusion des séjours où ces codes sont **plausiblement présents à l'admission** (DP, DR, DA en première position, ou séjour de moins de 48h sans intervention).

**Formule symbolique :**

**HAC_rate = N_HAC_acquis / N_séjours_éligibles**

avec
- N_HAC_acquis = nb séjours présentant ≥1 code de la liste HAC en DAS, hors codes plausiblement POA
- N_séjours_éligibles = séjours MCO d'au moins 2 jours, hors séjours médecine palliative (Z51.5 en DP) et hors décès dans les 24h

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `psi90_patient_safety_indicators.md` — composite AHRQ adapté français, mais **n'utilise pas POA** ; mêlangee admission et acquisition
- `taux_complications_ghm.md` — taux par GHM, sans tri POA/HAC
- `taux_evenements_indesirables.md` — agrégat EI sans distinction temporelle
- `taux_failure_to_rescue.md` — focus mortalité après complication, pas l'incidence elle-même
- `taux_sepsis_hospitalier_standardise.md` — un cas particulier (sepsis)

L'indicateur HAC ajoute une **dimension d'imputabilité** absente : il cherche à distinguer ce qui est attribuable à l'établissement de ce qui était déjà présent. Il est complémentaire à PSI90 (qui, sans POA, sur-pénalise les hôpitaux à casemix lourd à l'admission, biais documenté par Triche 2021).

## Calcul

### 1. Définition du périmètre

```
Inclusion :
  - Séjours MCO complets (RSA produit, GHM grouppé)
  - Durée de séjour >= 2 jours (pas de HAC plausible en <24h)
  - Adultes >= 18 ans (cohorte optionnelle pédiatrique séparée)

Exclusion :
  - Séjours dont le DP est lui-même un code de la liste HAC
    (= la complication EST le motif d'admission, donc POA par construction)
  - Soins palliatifs en DP (Z51.5)
  - Décès en <24h (peu de fenêtre pour acquérir une HAC)
  - Séjours d'obstétrique pour accouchement (CMD 14) : indicateur dédié
```

### 2. Listes de codes HAC

Construire 6 sous-indicateurs sectoriels (alignés sur les domaines CMS HAC + AHRQ PSI) :

```
HAC_1  Escarres acquises             : L89.x en DAS
HAC_2  Chutes / fractures hospit.    : T14.x, S72.x en DAS si DP non trauma
HAC_3  ITU nosocomiale sur sonde     : T83.5, N39.0 + acte sondage CCAM
HAC_4  Sepsis post-procédure         : T81.4, T81.40-49 en DAS
HAC_5  Embolie pulmonaire post-op    : I26.x en DAS si acte chir CCAM
HAC_6  Infection plaie chirurgicale  : T81.3, T81.4 en DAS si chir CCAM
```

La liste précise des codes CIM-10 est calquée sur le *Fascicule de codage pour le PMSI Maladies infectieuses* (ATIH 2023) et la liste PSI ATIH/AHRQ.

### 3. Règle proxy POA

Faute de flag POA, on **présume** qu'un code est présent à l'admission si :
- il figure en **DP** ou en **DR** (diagnostic relié) du RUM d'entrée, OU
- il figure en DA dans le **premier RUM** du séjour multi-RUM, OU
- la durée séparant l'entrée et la première mention du code est < 48h (non disponible directement en RSA → approximation par RUM si plusieurs UM).

Tous les autres cas sont étiquetés **acquis** (HAC) — proxy imparfait, voir Limites.

### 4. Pseudocode

```
Pour chaque séjour s :
  Si `duree`(s) < 2 OU DP(s) ∈ liste_HAC OU DP(s) = "Z51.5"
    → exclu

  Sinon :
    has_HAC = FALSE
    Pour chaque catégorie c ∈ {HAC_1..HAC_6} :
      codes_c = ensemble des codes CIM-10 de la catégorie
      Si DAS(s) ∩ codes_c ≠ ∅
         ET (codes_c ∩ {DP(s), DR(s), DAS_RUM_1(s)}) = ∅
         ET acte_associé_requis(c, s) = TRUE :
        marquer HAC_c(s) = 1
        has_HAC = TRUE

    HAC_total(s) = has_HAC

Indicateur agrégé :
  HAC_rate(c) = Σ_s HAC_c(s) / Σ_s 1{séjour éligible}
```

### 5. Ajustement de risque

Comme pour SHMI / mortalité ajustée, calculer un O/E par GHM-racine :

```
GLM logistique :
  logit(p_i) = β₀ + β₁·age + β₂·sexe + β₃·Charlson(DAS hors codes HAC)
             + β_GHM + β·entrée_urgence + β·niveau_sévérité

Indicateur standardisé :
  HAC_SR = O / Σ p_i × HAC_rate_national
```

## Utilité

- **Pilotage CME ciblé sur la qualité réellement imputable** : isoler les complications acquises permet d'orienter les plans d'amélioration sur ce que l'établissement peut maîtriser (hygiène, mobilisation, prévention TEV) plutôt que sur des phénomènes hérités du parcours patient.
- **Comparaison équitable inter-FINESS du GHT** : un CHU avec recrutement AVC sévère via SAMU ne peut être comparé à un CH périphérique sur les complications brutes ; le tri HAC/POA neutralise une part substantielle de ce biais.
- **Préparation à la refonte sévérité ATIH 2028** : la notice ATIH-294-9-2025 annonce une refonte du concept de sévérité visant à mieux intégrer multimorbidité et complications acquises. Investir dans un proxy POA dès maintenant prépare la transition.
- **Argumentaire contractuel ARS** : objectivation du « gain qualité » de l'établissement entre deux campagnes en isolant les HAC évitables (escarres, ITU sondage, infections plaies opératoires).
- **Aide à l'auto-codage qualité** : la mise en place d'une distinction proxy POA force les DIM à interroger les services sur la temporalité des diagnostics, ce qui améliore mécaniquement la précision du codage CIM-10 (effet vertueux documenté par Pine 2008).
- **Articulation IPAQSS / IQSS HAS** : alimentation des indicateurs HAS de prévention TEV, ITU sondage, escarres, par une mesure PMSI cohérente avec les recueils manuels existants.
- **Détection de signal pour signalement ANSM/CRPV** : un cluster de HAC_4 (sepsis post-procédure) sur un mois donné peut révéler un défaut équipement ou produit, à signaler.

## Sources de Données

Variables PMSI MCO (Guide méthodologique ATIH 2025) :

- **RSA** :
  - `DP` (diagnostic principal du séjour, après groupage)
  - `DR` (diagnostic relié)
  - `DAS` (diagnostics associés significatifs) — table empilée
  - `duree`
  - `SOR_MOD` (mode de sortie ; 9 = décès)
  - `age`, `SEXE`, `GHM`, niveau de sévérité GHM
  - `FINESSGEO`
- **RUM** (résumé d'unité médicale, avant groupage en RSS/RSA) — **clé pour le proxy POA** : permet d'identifier le DA du **premier** RUM du séjour, marqueur fort que la condition était présente à l'entrée.
  - `RUM_NUM_ORDRE` ou rang du RUM dans le séjour
  - `DA_RUM` (diagnostics associés du RUM)
- **CCAM (actes)** : pour les exclusions / inclusions par type d'intervention (sondage urinaire, chirurgie, voie veineuse centrale).
- **Référentiels** :
  - Liste des codes PSI ATIH ([scansante.fr](https://www.scansante.fr/))
  - *Fascicule de codage maladies infectieuses 2023* ([atih.sante.fr](https://www.atih.sante.fr/sites/default/files/public/content/1288/fascicule_atih_codage_maladies_infectieuses_v2023.pdf))
  - *Guide méthodologique PMSI MCO 2025* ([atih.sante.fr](https://www.atih.sante.fr/sites/default/files/public/content/4935/guide_methodo_mco_2025_version_provisoire_040225_0.pdf))
  - *Notice technique ATIH-294-9-2025* ([atih.sante.fr](https://www.atih.sante.fr/sites/default/files/public/content/5108/notice_technique_pmsi_2026.pdf)) — refonte sévérité 2028
- **Outils** : R/dplyr ou Python/pandas ; sur portail ATIH : Teradata via dbplyr.

## Exemple de Valeurs

Ordres de grandeur experts (non sourcés sur ScanSanté car indicateur non publié sous cette forme) — à recalibrer localement.

- **HAC_1 — escarres acquises (toute MCO adulte)** : 0,3–0,8 % pour court séjour aigu standard ; 1,5–3 % en gériatrie aiguë et soins continus ; au-delà de 4 % → audit hygiène / mobilisation requis.
- **HAC_3 — ITU nosocomiale sur sondage** : 1–2 % des séjours avec sondage prolongé (>48h) ; >5 % anormal.
- **HAC_4 — sepsis post-procédure** : 0,2–0,5 % en chir programmée ; jusqu'à 1,5 % en chir d'urgence digestive ; à mettre en regard de `taux_sepsis_hospitalier_standardise.md`.
- **HAC_5 — embolie pulmonaire post-op** : 0,1–0,4 % en chir programmée majeure ; à croiser avec `taux_prophylaxie_thromboembolique_veineuse.md` (relation inverse attendue).
- **HAC_6 — infection plaie chirurgicale** : 1–3 % en chir digestive lourde ; benchmark européen IQTIG ~1,5 % pour PTH/PTG (cf. `iqtig_indicateurs_arthroplastie.md`).
- **HAC composite (≥1 catégorie)** : 3–6 % CHU, 2–4 % CH, 1–2 % cliniques chir programmée.

## Limites

- **Absence de flag POA officiel** : c'est la limite cardinale ; le proxy par DP/DR/RUM_1 est imparfait. Squitieri 2017 a montré que même avec un POA formel, la concordance inter-établissements est faible (κ = 0,03–0,17 sur les escarres) — l'indicateur PMSI sera nécessairement plus bruité.
- **Sous-codage des DAS** : les complications « bénignes » résolues (ITU traitée, escarre stade 1) sont fréquemment non codées, biais de sélection vers les HAC sévères. Effet documenté par Pine 2008.
- **Effet apprentissage / hétérogénéité de codage** : la mise en place d'un suivi HAC peut paradoxalement **augmenter** le taux mesuré dans les premières années (amélioration du codage, pas de la qualité). Prévoir une période d'apprentissage 12–24 mois sans communication des chiffres aux services.
- **Casemix entrant** : l'ajustement par GHM neutralise partiellement l'effet du recrutement urgent, mais des facteurs non capturés (statut nutritionnel, autonomie pré-admission) influencent fortement les escarres et ITU. Triche 2021 montre que l'ajout du POA augmente l'AUC de +0,03 à +0,05 — donc utile, mais pas miraculeux.
- **Dépendance au format RUM** : le proxy par RUM_1 nécessite un séjour multi-UM ou un découpage temporel ; pour les séjours mono-RUM (la majorité), le proxy se réduit à DP/DR, plus faible.
- **Transition vers V016 et CIM-11** : la notice ATIH-294-9-2025 annonce le format V016 et l'expérimentation CIM-11 — la liste des codes HAC devra être maintenue à jour ; figer l'indicateur dans une version PMSI précise et resaper à chaque bascule.
- **Pas de jugement individuel** : un HAC = signal probabiliste pour le pilotage agrégé, pas une preuve de manquement de soins individuel ; usage CME oui, dossier médico-légal non.
- **Interaction avec la valorisation** : DAS = niveau de sévérité = recettes T2A. La distinction HAC/POA ne doit pas être instrumentalisée pour réduire la valorisation des complications acquises (perversité documentée aux US sur le HAC-POA program).

## Références

D'après PubMed :

- [Triche EW et al. — Incorporating Present-on-Admission Indicators in Medicare Claims to Inform Hospital Quality Measure Risk Adjustment Models, JAMA Netw Open 2021](https://doi.org/10.1001/jamanetworkopen.2021.8512) — démontre l'amélioration de l'ajustement de risque par l'ajout du POA. PMID 33978722
- [Squitieri L et al. — Consistency of pressure injury documentation across interfacility transfers, BMJ Qual Saf 2017](https://doi.org/10.1136/bmjqs-2017-006726) — limites d'accord inter-établissements POA pour escarres. PMID 28754811
- [Avery TR et al. — Inclusion of 30-day postdischarge detection triples the incidence of hospital-onset MRSA, Infect Control Hosp Epidemiol 2012](https://doi.org/10.1086/663714) — détection hors séjour des HAC infectieux. PMID 22227979
- [Pine M et al. — Modifying ICD-9-CM coding of secondary diagnoses to improve risk-adjustment of inpatient mortality rates, Med Decis Making 2009](https://doi.org/10.1177/0272989X08323297) — sous-codage des DAS et impact sur l'ajustement. PMID 18812585
- [ATIH — Guide méthodologique de production des informations PMSI MCO 2025](https://www.atih.sante.fr/sites/default/files/public/content/4935/guide_methodo_mco_2025_version_provisoire_040225_0.pdf) — définition du DAS.
- [ATIH — Fascicule de codage des maladies infectieuses, version 2023](https://www.atih.sante.fr/sites/default/files/public/content/1288/fascicule_atih_codage_maladies_infectieuses_v2023.pdf) — listes de codes complications infectieuses.
- [ATIH — Notice technique ATIH-294-9-2025, novembre 2025](https://www.atih.sante.fr/sites/default/files/public/content/5108/notice_technique_pmsi_2026.pdf) — refonte sévérité 2028, format V016, expérimentation CIM-11.
- [ATIH — Projet DISCo (Déterminants Individuels en Santé et COmorbidités)](https://www.atih.sante.fr/determinants-individuels-en-sante-et-comorbidites-disco) — travaux en cours sur la distinction comorbidités / complications.
- [CMS — Hospital-Acquired Conditions (HAC) Reduction Program](https://www.cms.gov/) — référence du programme américain.
