# Taux de Substitution Ambulatoire par GHM

## Définition

Le taux de substitution ambulatoire par GHM (TSA_GHM) mesure, pour chaque GHM chirurgical éligible à la prise en charge en chirurgie ambulatoire, la part des séjours effectivement réalisés en ambulatoire parmi l'ensemble des séjours de ce GHM (ambulatoire + hospitalisation complète). Il s'agit d'un **indicateur de conversion GHM-spécifique**, distinct du taux d'ambulatoire global qui agrège l'ensemble des séjours sans distinguer les GHMs éligibles des GHMs non éligibles.

TSA_GHM(g) = N_ambu(g) / N_total(g)

où :
- g ∈ L_ATIH : GHM appartenant à la liste des GHMs éligibles à la chirurgie ambulatoire publiée annuellement par l'ATIH
- N_ambu(g) : nombre de séjours du GHM g réalisés en ambulatoire (GHM de type 'J', c'est-à-dire dernière lettre du code GHM = 'J')
- N_total(g) : nombre total de séjours de la racine GHM g (types 'J' + '1' à '4' + 'T' inclus)

La racine GHM (5 premiers caractères du code GHM sur 6) regroupe sous un même identifiant clinique les déclinaisons ambulatoire (J), les niveaux de sévérité (1 à 4) et les très courtes durées (T). Le TSA_GHM mesure donc le degré de conversion d'un GHM vers l'ambulatoire, indépendamment de la lourdeur des cas restant en hospitalisation complète.

La différence fondamentale avec le taux d'ambulatoire global (indicateur `taux_ambulatoire`) est que le TSA_GHM **restreint le dénominateur aux séjours du GHM éligible**, ce qui isole la performance de conversion sur les cas où l'ambulatoire est techniquement et réglementairement possible, sans dilution par les GHMs non convertibles (médecine, obstétrique, etc.).

Un TSA_GHM proche de 1 signale une conversion quasi-totale vers l'ambulatoire ; un TSA_GHM faible sur un GHM pour lequel d'autres établissements affichent des taux élevés est un signal de sous-performance et un levier d'action prioritaire.

## Calcul

Source : PMSI MCO RSA — variables GHM (6 caractères), numéro FINESS géographique, UM/service, et période d'analyse.

```
Population : tous les séjours MCO avec GHM racine ∈ liste_eligible_ATIH
             sur la période d'analyse (trimestre ou année civile)

Étape 1 — Extraction du code GHM et de la racine :
  ghm_complet  = champ GHM du RSA (6 caractères, ex : "04C04J", "04C041")
  racine_ghm   = substr(ghm_complet, 1, 5)      -- ex : "04C04"
  type_ghm     = substr(ghm_complet, 6, 1)       -- 'J', '1', '2', '3', '4', 'T', etc.

Étape 2 — Restriction aux GHMs éligibles :
  Charger la liste L_ATIH = référentiel annuel ATIH "GHMs éligibles chirurgie ambulatoire"
  (fichier CSV disponible sur portail ATIH, mis à jour chaque version de classification)
  Filtrer : racine_ghm ∈ L_ATIH

Étape 3 — Identification des séjours ambulatoires :
  ambu = (type_ghm == 'J')
  -- NB : en l'absence du code J, le critère DUREE = 0 peut être utilisé en
  --      complément pour les séjours mono-journée non groupés en J (hors chirurgie)
  --      mais la cible principale reste le type 'J' pour la chirurgie ambulatoire

Étape 4 — Calcul du TSA par GHM et FINESS :
  Pour chaque (racine_ghm, FINESS, période) :
    N_total(g) = count(séjours)
    N_ambu(g)  = count(séjours WHERE ambu = TRUE)
    TSA_GHM(g) = N_ambu(g) / N_total(g)
    Convention  : si N_total(g) < seuil_min → TSA_GHM(g) = NA (non interprétable)
    Seuil recommandé : N_total(g) ≥ 30 séjours sur la période

Étape 5 — Indicateurs dérivés :
  TSA_GHM_national(g) = taux de référence national ATIH pour le GHM g
                         (issu de ScanSanté ou des données nationales PMSI)
  Écart_benchmark(g)  = TSA_GHM_etab(g) − TSA_GHM_national(g)
  Écart > 0 : sur-performance vs national
  Écart < 0 : sous-performance, potentiel de conversion non exploité
```

Indicateurs agrégés dérivés :

```
TSA_global_eligible = Σg N_ambu(g) / Σg N_total(g)
  -- Taux global restreint aux seuls GHMs éligibles (≠ taux_ambulatoire global)

Potentiel_non_exploite(g) = (TSA_GHM_national(g) − TSA_GHM_etab(g)) × N_total(g)
  -- Nombre de séjours "convertibles" si l'établissement atteignait le niveau national
  -- Sommé sur tous les GHMs : quantifie le gisement de substitution de l'établissement

Rang_percentile(g) = percentile de l'établissement sur le TSA_GHM(g)
                     dans la distribution nationale par type d'établissement (CHU/CH/clinique)
```

## Utilité

- **Identifier les GHMs prioritaires pour le plan d'action ambulatoire** : un TSA_GHM(g) de 30 % sur un GHM pour lequel la médiane nationale est à 75 % désigne ce GHM comme levier prioritaire, avec un argument chiffré présentable à la commission médicale d'établissement (CME)
- **Comparer les performances intra-GHT** : dans un GHT multi-établissements, la comparaison des TSA_GHM par GHM entre établissements partenaires identifie le site de référence ambulatoire et guide les orientations de flux (quel établissement doit absorber quelle chirurgie ambulatoire)
- **Quantifier le gisement de capacité libérable** : le `Potentiel_non_exploite` agrégé traduit directement en nombre de lits-jours la capacité libérable par conversion ambulatoire, argument central pour les réorganisations capacitaires et les projets immobiliers
- **Suivre l'impact des transformations organisationnelles** : lors de la création ou de la réorganisation d'une unité de chirurgie ambulatoire (UCA), le TSA_GHM permet d'évaluer l'impact GHM par GHM, avec une sensibilité bien supérieure au taux global
- **Appuyer les négociations contractuelles avec l'ARS** : les objectifs de CAQES (Contrat d'Amélioration de la Qualité et de l'Efficience des Soins) incluent des cibles ambulatoires ; le TSA_GHM fournit la granularité nécessaire pour construire des trajectoires crédibles par spécialité chirurgicale
- **Détecter les effets de sélection de patients** : un TSA_GHM élevé couplé à un Charlson moyen élevé en ambulatoire peut signaler un problème de sélection inadaptée — le croisement avec les indicateurs de casemix (`indice_charlson_moyen`) renforce l'analyse

## Sources de Données

- **PMSI MCO RSA** : champ GHM (6 caractères, version en vigueur), FINESS géographique, UM, date d'entrée/sortie — extraction annuelle ou trimestrielle
- **Référentiel ATIH des GHMs éligibles à la chirurgie ambulatoire** : liste officielle publiée à chaque mise à jour de la classification (disponible sur le portail ATIH), indispensable pour filtrer le dénominateur aux seuls GHMs convertibles
- **ScanSanté (ATIH)** : taux ambulatoires nationaux par GHM par type d'établissement, utilisés comme valeurs de référence pour le calcul des écarts de benchmark — accessible via le module comparaison établissements
- **Tables de correspondance GHM → CMD → libellé** : pour l'agrégation par spécialité et la présentation aux équipes médicales (référentiel GHM ATIH, version annuelle)

## Exemple de Valeurs

Valeurs observées en France pour des GHMs chirurgicaux fréquents (source : ATIH données nationales MCO) :

| GHM (racine) | Libellé | TSA national | CHU | CH 300-500 lits | Clinique MCO |
|---|---|---|---|---|---|
| 03C10 | Cataracte | ~97 % | ~95 % | ~96 % | ~98 % |
| 08C47 | PTG (prothèse totale genou) | ~5 % | ~3 % | ~7 % | ~10 % |
| 06C08 | Cholécystectomie | ~65 % | ~55 % | ~60 % | ~80 % |
| 04C04 | Amygdalectomie enfant | ~70 % | ~65 % | ~72 % | ~85 % |
| 08C48 | PTH (prothèse totale hanche) | ~3 % | ~2 % | ~4 % | ~6 % |
| 07C12 | Hernie inguinale adulte | ~75 % | ~65 % | ~72 % | ~88 % |

Seuils d'alerte opérationnels :
- **Écart benchmark > −20 points** sur un GHM à fort volume (> 100 séjours/an) : signal prioritaire, à inscrire dans le plan d'action ambulatoire annuel
- **TSA_global_eligible < 50 %** pour un établissement MCO généraliste en 2025 : en deçà de l'objectif national (plan "Virage Ambulatoire" DGOS)
- **Potentiel_non_exploite agrégé > 500 séjours/an** : justifie une étude de faisabilité de création ou d'extension d'une unité de chirurgie ambulatoire dédiée

## Limites

- **Dépendance au référentiel ATIH annuel** : la liste des GHMs éligibles est révisée à chaque version de la classification (v11c, v12, v12a...) — un GHM nouvellement déclaré éligible fait mécaniquement baisser le TSA_GHM de l'année de transition sans changement de pratique réelle ; les comparaisons inter-annuelles nécessitent un rebasage sur une liste stable
- **Seuil minimal de volume** : un TSA_GHM calculé sur moins de 30 séjours est très instable statistiquement (intervalle de confiance à 95 % de ±30 points) — masquer ou signaler les GHMs sous ce seuil dans les tableaux de bord
- **Hétérogénéité de la patientèle non capturée** : le TSA_GHM ne tient pas compte du profil de comorbidités des patients (age, Charlson) — un établissement qui concentre les patients âgés complexes d'un GHM chirurgical aura structurellement un TSA_GHM plus faible que la moyenne nationale, sans sous-performance réelle ; le croisement avec `indice_charlson_moyen` ou `hospital_frailty_risk_score` est indispensable pour une interprétation honnête
- **Double comptage possible** : les séjours de type 'T' (très courte durée, 1 nuit) ne sont pas comptabilisés comme ambulatoires dans cette définition mais sont souvent proches — selon l'objectif de l'analyse, leur inclusion dans le numérateur peut être pertinente (notamment pour les séjours en unité de semaine)
- **Non applicable au SSR, PSY, HAD** : cet indicateur est exclusivement MCO chirurgical — les modes de prise en charge alternatives dans ces champs ne disposent pas de classification GHM équivalente avec déclinaison ambulatoire

## Références

- [ATIH — Classification des GHMs, guide méthodologique MCO (version en vigueur) : définition des types de séjours J, T, 1-4](https://www.atih.sante.fr/)
- [DGOS — Programme national de développement de la chirurgie ambulatoire 2020-2025 (Virage Ambulatoire) : objectifs nationaux par spécialité](https://solidarites-sante.gouv.fr/)
- [ANAP — Guide de déploiement de la chirurgie ambulatoire, 2019 : indicateurs de pilotage et benchmarks GHM](https://www.anap.fr/)
- Or Z., Häkkinen U. — DRGs and quality: for better or worse?, in Busse R., Geissler A., Quentin W., Wiley M. (eds), *Diagnosis-Related Groups in Europe*, Open University Press / WHO 2011 (chapitre 8) : effets des systèmes de tarification à l'activité sur la substitution ambulatoire
- [Ministère de la Santé / DREES — Panorama des établissements de santé 2023 : données nationales taux ambulatoire par spécialité](https://www.drees.solidarites-sante.gouv.fr/)
- [Fung V. et al. — Understanding variation in outpatient procedure use: the contribution of case mix, Health Services Research 2004](https://doi.org/10.1111/j.1475-6773.2004.00270.x)
