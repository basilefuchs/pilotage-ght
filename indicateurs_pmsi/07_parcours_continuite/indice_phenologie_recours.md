# Indice de Phénologie du Recours aux Soins

## Définition

La phénologie est la science qui étudie les cycles et rythmes naturels des phénomènes biologiques (floraison, migration, feuillaison) en lien avec les variations climatiques. Transposée aux parcours de soins, la **phénologie du recours** mesure la régularité temporelle des consommations de soins d'un patient par rapport au rythme attendu pour sa pathologie : un patient diabétique qui consulte tous les trois mois exactement présente une phénologie stable, tandis qu'un patient avec des bursts de consultations entrecoupés de longues périodes d'absence présente une phénologie perturbée.

L'indicateur retenu est le **coefficient de variation des intervalles inter-recours** (CV-IIR), défini pour chaque patient comme :

IPhR = σ(Δt) / μ(Δt)

où Δtₖ = date_recours_{k+1} − date_recours_k (en jours), calculé sur l'ensemble des recours de soins d'un patient sur la période d'observation (12 mois glissants, minimum 4 recours). IPhR est sans dimension : IPhR → 0 traduit des recours très réguliers (intervalle constant), IPhR → 1 une variabilité forte, IPhR > 1 des recours en rafales entrecoupées de vides.

Cet indicateur est absent des outils PMSI/SNDS actuels : l'indice de fragmentation du parcours patient mesure les ruptures binaires de continuité ; l'indice UPC mesure la concentration sur un médecin traitant ; le score d'intensité de consommation ambulatoire mesure le volume total. Aucun ne capture la **structure rythmique** du recours — information qualitativement différente, accessible uniquement par l'analyse des séquences temporelles individuelles dans le SNDS chaîné.

## Calcul

**Source :** SNDS — table `ER_PRS_F` (prestations de soins) chaînée par NIR pseudonymisé, filtrée sur les types de prestations ambulatoires (consultations généraliste, spécialiste, actes paramédicaux infirmiers, biologiques).

```
Population : patients avec ALD active ou GHM index MCO dans la période
             ET ≥ 4 recours ambulatoires documentés dans les 12 mois glissants

Étape 1 — Extraction des dates de recours :
  Pour chaque patient NIR :
    Recueillir toutes les dates EXE_SOI_DTD (date de début de soin) dans ER_PRS_F
    Filtrer par codes prestations : consultations (C, CS, V, VS), actes infirmiers (DE, DI),
    actes de biologie (B), actes de kinésithérapie (AMK, AMS)
    Trier par date croissante → séquence [t₁, t₂, ..., tₙ]

Étape 2 — Calcul des intervalles inter-recours :
  Δtₖ = t_{k+1} − tₖ  (en jours entiers), pour k = 1 à n−1
  Exclure les intervalles Δt = 0 (actes le même jour = une seule consultation groupée)
  Seuil minimal : n ≥ 4 recours ⟹ au moins 3 intervalles calculables

Étape 3 — IPhR individuel :
  μ(Δt) = moyenne arithmétique des intervalles
  σ(Δt) = écart-type non biaisé (diviseur n−1)
  IPhR  = σ(Δt) / μ(Δt)
  Convention : si μ(Δt) = 0 (tous les recours le même jour) → IPhR = NaN, exclusion

Étape 4 — Agrégation populationnelle :
  IPhR_moy(groupe) = moyenne des IPhR individuels du groupe (ALD, GHM, UF, FINESS)
  IPhR_med(groupe) = médiane (plus robuste aux outliers)
  Distribution : déciles D1 à D9 pour caractériser la dispersion intra-groupe

Étape 5 — Indicateurs dérivés :
  Dérive phénologique : ΔIPhR = IPhR(année N) − IPhR(année N-1) par patient
    → ΔIPhR > +0.30 : dégradation du rythme de recours (signal de rupture)
    → ΔIPhR < −0.30 : régularisation (signal favorable, ex. après éducation thérapeutique)
  Indice phénologique stratifié : calculer séparément par type de prestation
    (IPhR_MT pour médecin traitant seul, IPhR_spe pour spécialistes, IPhR_global)
```

**Cas limites :**
- Patients avec < 4 recours/an : exclus du calcul individuel, comptabilisés dans le taux d'exclusion
- Changement de médecin traitant dans la période : ne modifie pas le calcul (date-based, non provider-based)
- Hospitalisation longue dans la période : les actes PMSI MCO/SSR sont exclus des Δt ambulatoires (filtrer sur `ETE_CAT_COD` ≠ 01 pour l'hôpital)

## Utilité

- **Détecter précocement les ruptures de suivi progressives** : un patient ALD diabète dont l'IPhR passe de 0.25 à 0.90 sur deux ans n'a pas forcément diminué son nombre de consultations (invisible avec le seul volume), mais les espace de façon croissante — signal d'alerte pour la coordination de proximité avant décompensation
- **Stratifier les cohortes ALD pour les programmes d'accompagnement** : les patients IPhR > 1.0 sont candidats prioritaires aux rappels proactifs (télécoordination, messagerie sécurisée MT/patient) car leur rythme de recours est structurellement instable
- **Évaluer l'impact d'une intervention de coordination** : comparer IPhR avant/après mise en place d'un protocole de suivi coordonné (PRADO, équipes de soins coordonnées) — une baisse significative de l'IPhR médian valide l'effet de régularisation
- **Benchmarker les bassins de vie du GHT** : comparer IPhR_moy par commune/canton pour les ALD prioritaires identifie les zones où le recours est structurellement irrégulier, corrélables avec la densité médicale et les déserts de soins
- **Piloter la pertinence des filières de soins chroniques** : dans une filière insuffisance cardiaque, l'IPhR attendu post-décompensation est élevé (recours fréquents et rapprochés en phase de stabilisation), puis doit baisser — une filière efficace se lit aussi dans la trajectoire phénologique de ses patients
- **Identifier les patients à risque d'hospitalisation non programmée** : l'IPhR élevé (> 1.2) combiné à un allongement du dernier intervalle (Δt_last > 2 × μ) est un signal prédictif de décompensation immédiate — peut alimenter un score de priorisation des appels sortants de la plateforme de coordination GHT

## Sources de Données

- **SNDS — `ER_PRS_F`** : date de soin (`EXE_SOI_DTD`), code prestation (`PRS_NAT_REF`), identifiant bénéficiaire pseudonymisé (`BEN_NIR_PSA`), code exécutant (`EXE_PRO_NAT`) — extraction mensuelle ou annuelle selon la granularité
- **SNDS — `IR_ALD_R`** : table des ALD actives par bénéficiaire, pour stratifier la population par groupe nosologique (`ALD_TYP` 1-30)
- **SNDS — `IR_BEN_R`** : référentiel bénéficiaires pour les attributs démographiques (âge, sexe, commune de résidence `BEN_RES_COM`) permettant la stratification géographique
- **PMSI MCO** : dates d'hospitalisation (`ENT_DAT`, `SOR_DAT`) pour exclure les périodes intra-hospitalières du calcul des intervalles ambulatoires

## Exemple de Valeurs

| Groupe pathologique | IPhR médian attendu | Interprétation |
|---|---|---|
| Diabète type 2 bien équilibré (ALD 8) | 0.15 – 0.30 | Suivi trimestriel régulier |
| BPCO stable | 0.25 – 0.40 | Suivi semestriel avec visites en dehors |
| Insuffisance cardiaque en phase aiguë | 0.80 – 1.50 | Recours en rafales post-décompensation |
| Cancer en traitement actif | 0.10 – 0.20 | Protocoles très réguliers |
| Patient en rupture partielle de suivi | > 1.50 | Signal d'alerte |
| Population générale sans ALD | 0.60 – 1.20 | Recours opportunistes, variable |

**Seuils d'alerte :**
- IPhR individuel > 1.5 → inclusion dans la liste de suivi proactif du coordinateur de parcours
- ΔIPhR annuel > +0.40 → déclenchement d'une revue de dossier en équipe de soins

## Limites

- **Volume minimal requis** : le CV est instable statistiquement en dessous de 4 recours ; pour une interprétation fiable à l'échelle d'un service ou d'une UF, recommander un minimum de 50 patients inclus dans le groupe
- **Nature des recours non différenciée** : l'IPhR global mélange des recours de natures très différentes (urgences, consultations programmées, actes infirmiers) — l'IPhR stratifié par type de prestation est plus interprétable cliniquement mais requiert un travail de nomenclature supplémentaire
- **Irrégularité choisie vs irrégularité pathologique** : un patient en rémission complète de cancer qui espace légitimement ses consultations présente un IPhR élevé sans que cela soit un signal négatif — l'interprétation clinique du contexte est indispensable
- **Sensibilité aux changements de codage SNDS** : les modifications de nomenclature des actes (NGAP → CCAM) et les changements de règles de remboursement peuvent modifier artificiellement les séquences et biaiser le calcul longitudinal
- **Non-couverture des actes non remboursés** : les consultations hors nomenclature (médecines alternatives, professionnels non conventionnés) sont invisibles dans le SNDS, sous-estimant le recours réel pour certaines populations

## Références

- [Morisita M. — Measuring of interspecific association and similarity between communities, Memoirs of the Faculty of Science, Kyushu University 1959 : fondements de la mesure de dispersion temporelle et spatiale](https://doi.org/10.1071/BI9590065)
- [Bramer G.R. et al. — International Statistical Classification of Diseases and Related Health Problems, WHO 2004 — codification des ALD dans les bases médico-administratives]
- [Tuppin P. et al. — Value of a national administrative database to guide public decisions: From the système national d'information interrégimes de l'Assurance Maladie (SNIIRAM) to the système national des données de santé (SNDS) in France, Revue d'Épidémiologie et de Santé Publique 2017](https://doi.org/10.1016/j.respe.2017.05.004)
- [Haggerty J.L. et al. — Continuity of care: a multidisciplinary review, BMJ 2003 : cadre conceptuel de la continuité des soins, dont la continuité longitudinale et la régularité du contact](https://doi.org/10.1136/bmj.327.7425.1219)
- [Bähler C. et al. — Multimorbidity, health care utilization and costs in an elderly community-dwelling population, BMC Health Services Research 2015 : patterns de recours dans les populations multimorbides](https://doi.org/10.1186/s12913-015-0698-2)
- [ATIH — Documentation SNDS / SNIIRAM : guide d'accès aux tables et variables](https://www.atih.sante.fr/)
