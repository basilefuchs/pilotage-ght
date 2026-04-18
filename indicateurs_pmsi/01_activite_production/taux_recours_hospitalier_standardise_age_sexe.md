# Taux de Recours Hospitalier Standardisé sur l'Âge et le Sexe (TRHS)

## Définition

Le TRHS est un ratio de standardisation indirecte (analogue au SMR — Standardized Mortality Ratio) appliqué au recours à l'hospitalisation MCO. Il compare le nombre de séjours **observés** dans un territoire à celui qui serait **attendu** si la population locale présentait le même taux de recours, âge par âge et sexe par sexe, que la population nationale de référence publiée par la DREES (Statistique Annuelle des Établissements de santé — SAE).

**TRHS = (Séjours_observés / Séjours_attendus) × 100**

où :

- **Séjours_observés** = RSA MCO produits pour les patients domiciliés dans la zone d'attraction de l'établissement sur la période
- **Séjours_attendus** = Σ_{(a,s)} [ Pop_zone_(a,s) × Taux_national_(a,s) ]
  - Pop_zone_(a,s) = population résidente de la zone d'attraction par tranche d'âge a (quinquennale) et sexe s, source INSEE RP
  - Taux_national_(a,s) = taux de recours national observé sur la même période, par tranche d'âge et sexe, issu de la SAE DREES ou du PMSI national ATIH

**Interprétation :**
- TRHS = 100 → recours conforme à la structure démographique nationale
- TRHS > 100 → sur-recours : le territoire consomme plus de séjours qu'attendu compte tenu de sa démographie (vieillissement avancé, prévalence de pathologies, offre hospitalière induite)
- TRHS < 100 → sous-recours : renoncement aux soins, barrières géographiques, substitution par le secteur ambulatoire ou les établissements hors zone

Cet indicateur est structurellement absent des tableaux de bord PMSI courants : le nombre brut de séjours (activite_mco.md) et le taux d'occupation (taux_occupation.md) ne neutralisent pas l'effet de la structure d'âge et de sexe de la population locale. Le TRHS, en revanche, isole le sur/sous-recours net de la démographie, rendant comparables des zones urbaines jeunes et des bassins ruraux vieillissants.

## Calcul

Sources : PMSI MCO RSA (ATIH) + Référentiel Zones d'attraction ATIH + INSEE Recensement de la Population + SAE DREES (taux nationaux par âge/sexe).

```
Population d'analyse :
  Tous les RSA MCO d'un exercice complet (janvier–décembre)
  Filtre : code_postal_patient ∈ zone_attraction_FINESS_geo
  Exclusions standard : séjours en CMD 14 (grossesse), CMD 15 (nouveau-nés),
                        séjours < 24h comptabilisés en 0-jour selon règle PMSI
  Granularité : global établissement | par CMD | par racine GHM

Étape 1 — Extraction des séjours observés par tranche d'âge et sexe :
  Obs_{(a,s)} = COUNT(RSA)
    WHERE code_postal IN zone_attraction
      AND tranche_age = a    -- quinquennales : 0-4, 5-9, ..., 85-89, 90+
      AND SEXE = s           -- 1 = masculin, 2 = féminin
  Obs_total = Σ_{(a,s)} Obs_{(a,s)}

Étape 2 — Population de la zone d'attraction par tranche d'âge et sexe :
  Pop_zone_{(a,s)} = population INSEE RP millésimée (N-1 ou N-2 selon disponibilité)
                     agrégée sur les communes de la zone d'attraction ATIH

Étape 3 — Taux nationaux de référence par tranche d'âge et sexe :
  TauxNat_{(a,s)} = Séjours_nationaux_{(a,s)} / Pop_nationale_{(a,s)}
  Source A : SAE DREES — tableau « séjours MCO par tranche d'âge et sexe »
  Source B : PMSI national ATIH open data (fichier Éco-santé ou RPU national)
  → La source B est préférable car homogène avec le PMSI local (même règle de décompte)

Étape 4 — Calcul des séjours attendus :
  Att_total = Σ_{(a,s)} [ Pop_zone_{(a,s)} × TauxNat_{(a,s)} ]

Étape 5 — Calcul du TRHS :
  TRHS = (Obs_total / Att_total) × 100
  IC 95% (Ulm 1990) : TRHS ± 1,96 × (TRHS / √Obs_total)
  Convention : si Att_total = 0 → TRHS = NA (zone trop petite, <500 hab.)

Étape 6 — Déclinaison par CMD (TRHS_cmd) :
  Obs_cmd_{(a,s)}    = COUNT(RSA) WHERE CMD = c AND tranche_age = a AND SEXE = s
  TauxNat_cmd_{(a,s)} = Séjours_nationaux_cmd_{(a,s)} / Pop_nationale_{(a,s)}
  Att_cmd            = Σ_{(a,s)} [ Pop_zone_{(a,s)} × TauxNat_cmd_{(a,s)} ]
  TRHS_cmd           = (Obs_cmd / Att_cmd) × 100
```

Indicateurs dérivés :

```
Écart absolu de séjours :
  ΔSéjours = Obs_total − Att_total
  ΔSéjours > 0 : excédent lié au recours (hors effet démographique)
  ΔSéjours < 0 : déficit de recours à corriger ou à analyser (renoncement ? fuite ?)

TRHS tendanciel sur 3 ans :
  ΔTRHS = TRHS(N) − TRHS(N-3)
  ΔTRHS > +5 pts = aggravation du sur-recours ou dégradation de l'offre ambulatoire
  ΔTRHS < −5 pts = convergence vers la norme (amélioration de la substitution)

TRHS ajusté CMD — décomposition du sur/sous-recours :
  Contribution_cmd = (Obs_cmd − Att_cmd)  [en séjours absolus]
  Triage des CMD les plus contributrices au sur-recours global
```

## Utilité

- **Identifier le sur/sous-recours territorial net de la démographie** : un GHT en zone âgée peut afficher un volume brut élevé sans sur-recours réel (TRHS ≈ 100) ; inversement, une ville jeune avec TRHS = 115 révèle une utilisation anormalement haute indépendante de l'âge, signal d'exploration de la pertinence des hospitalisations ou des déterminants socioéconomiques locaux.
- **Prioriser les CMD à analyser en pertinence** : le TRHS par CMD expose les spécialités en sur-recours (ex. CMD 8 Orthopédie TRHS = 135) et celles en sous-recours (ex. CMD 11 Rein TRHS = 72), guidant les audits de pertinence et les décisions de redéploiement de lits.
- **Argumenter une demande de financement ou d'autorisation auprès de l'ARS** : un TRHS global > 115 sur une zone de santé est un argument objectif de tension démographique non démographique pour justifier des capacités supplémentaires ou des équipes mobiles.
- **Détecter le renoncement aux soins à l'échelle du GHT** : un TRHS < 85 persistant sur plusieurs CMD médicales dans un sous-territoire du GHT est cohérent avec un renoncement aux soins ou une barrière d'accès (distance, désertification médicale ambulatoire) — croisement possible avec le taux_patients_sans_medecin_traitant.md.
- **Suivre l'impact de la politique de substitution ambulatoire** : si TRHS décroît sur 3 ans sur les CMD concernées par la chirurgie ambulatoire (CMD 1, 5, 8), c'est le signal que la substitution effective déprime le recours hospitalier conventionnel, conformément aux objectifs ANAP/DREES.
- **Benchmarking inter-GHT via les données DREES** : le TRHS produit un indicateur directement comparable entre GHT de démographies différentes — un GHT périurbain et un GHT rural peuvent être mis en regard sur une même échelle normalisée à 100.

## Sources de Données

- **PMSI MCO RSA** (ATIH) : variables `FINESS_GEO`, `CODE_POSTAL` (ou `CODE_INSEE_COMMUNE`) du patient, `AGE` (ou date de naissance), `SEXE`, `CMD`, `GHM` — extraction annuelle.
- **Référentiel Zones d'attraction des établissements** (ATIH) : fichier de correspondance commune → établissement de rattachement, mis à jour annuellement. Disponible dans les fichiers de référence ATIH ou reconstruit à partir des flux PMSI (méthode pluralité des séjours par commune).
- **INSEE Recensement de la Population (RP)** : populations légales par commune, tranche d'âge quinquennale et sexe — millésime N-2 (dernière année disponible au moment du calcul). Tables `pop_struct` ou fichier Filosofi pour les communes de moins de 2 000 habitants.
- **SAE DREES** : tableaux nationaux de séjours MCO par tranche d'âge et sexe, publiés annuellement dans « Les établissements de santé » et sur data.drees.fr — ou équivalent calculé depuis le PMSI national ATIH open data pour cohérence de source.
- **ATIH Open Data** (optionnel, source B pour TauxNat) : fichiers de statistiques nationales PMSI MCO disponibles sur opendata.atih.sante.fr, permettant de calculer les taux nationaux par âge et sexe directement depuis le PMSI, garantissant l'homogénéité de la règle de comptage.

## Exemple de Valeurs

| Contexte | TRHS global | Interprétation |
|---|---|---|
| Zone rurale vieillissante, accès limité ambulatoire | 88–94 | Sous-recours probable malgré démographie âgée — barrière d'accès |
| Zone péri-urbaine équilibrée, offre ambulatoire dense | 96–104 | Recours conforme à la norme nationale |
| Zone à fort tissu industriel, pathologies professionnelles | 108–118 | Sur-recours CMD 4 (Respiratoire), CMD 8 (Musculo-squelettique) |
| Zone de CHU avec effet de recours spécialisé | 115–130 | Sur-recours capté par le CHU pour des CMD de recours (CMD 1, 16, 17) |
| Zone littorale avec forte population saisonnière | Variable | TRHS instable si pop INSEE ne capture pas les résidents secondaires |

**Par CMD (exemples de valeurs plausibles) :**
- CMD 5 (Appareil circulatoire) TRHS = 112 → sur-recours cardiologique dans une zone à forte prévalence
- CMD 11 (Rein) TRHS = 78 → sous-recours néphro, possiblement substitué par HAD ou dialyse ambulatoire
- CMD 8 (Orthopédie) TRHS = 125 → sur-recours chirurgical, à croiser avec taux_pertinence_actes_ccam.md

**Seuil d'alerte :** TRHS < 85 ou > 115 sur 2 exercices consécutifs → déclencher une analyse par CMD avec ΔTRHS et ΔSéjours absolus.

**Volume minimal recommandé :** zone d'attraction de plus de 30 000 habitants et au moins 500 séjours MCO observés sur la période pour une stabilité statistique suffisante des TRHS par CMD.

## Limites

- **Dépendance à la définition de la zone d'attraction** : la zone ATIH (pluralité des séjours par commune) peut différer de la zone ARS ou de la zone de santé administrative. Un changement de méthode de définition de zone entre deux années rend les TRHS incomparables, même si l'établissement n'a pas changé de comportement.
- **Instabilité pour les petites zones ou les CMD rares** : pour des CMD avec moins de 50 séjours observés, l'IC 95% est très large (TRHS ± 30-40 pts) et l'interprétation devient non fiable — imposer un seuil minimum de 100 séjours par CMD avant de publier un TRHS_cmd.
- **Résidents saisonniers et populations mobiles** : dans les zones touristiques ou frontalières, la population INSEE sous-estime la population réellement présente sur l'année, gonflant artificiellement le TRHS (séjours sur une base de population trop petite).
- **Taux nationaux sensibles à l'année de référence** : les taux DREES/SAE sont disponibles avec 2 ans de décalage. Un TRHS calculé en 2025 sur les taux 2022 peut masquer des évolutions structurelles de l'offre nationale intervenues depuis (virage ambulatoire, ouverture de nouveaux centres). Documenter systématiquement l'année des taux de référence utilisés.
- **Absence de standardisation sur le statut socioéconomique** : le TRHS neutralise l'âge et le sexe mais pas la prévalence des pathologies ni la précarité sociale. Un TRHS élevé peut refléter une population défavorisée à morbidité accrue — croiser avec score_vulnerabilite_sociale.md pour désambiguïser.
- **Fuites hors zone non capturées** : les séjours des résidents de la zone réalisés dans un établissement hors zone ne sont pas dans le PMSI local. Le TRHS sous-estime le recours réel si la fuite est importante — croiser avec taux_fuite_attractivite.md.

## Références

- [DREES — Les établissements de santé, édition annuelle (SAE) — tableaux de séjours par âge et sexe](https://www.drees.solidarites-sante.gouv.fr/publications/panoramas-de-la-drees/les-etablissements-de-sante)
- [Breslow N.E., Day N.E. — Statistical Methods in Cancer Research, Vol. II : indirect standardization methodology (SMR/SHR)](https://publications.iarc.fr/Book-And-Report-Series/Iarc-Scientific-Publications/Statistical-Methods-In-Cancer-Research-Volume-II-The-Design-And-Analysis-Of-Cohort-Studies-1987)
- [OCDE — Geographic Variations in Health Care: What Do We Know and What Can Be Done to Improve Health System Performance? OECD Health Policy Studies, 2014](https://doi.org/10.1787/9789264216594-en)
- [ATIH — PMSI MCO : guide méthodologique de production des données d'activité](https://www.atih.sante.fr/pmsi-mco)
- [Ulm K. — A simple method to calculate the confidence interval of a standardized mortality ratio, American Journal of Epidemiology 1990](https://doi.org/10.1093/oxfordjournals.aje.a115633)
- [Dormont B., Huber H. — Causes of health expenditure growth: the predominance of changes in medical practices over population ageing, Annals of Economics and Statistics 2006](https://doi.org/10.2307/20079145)
- [IRDES — Variations géographiques des taux de recours hospitalier en France, Questions d'économie de la santé 2019](https://www.irdes.fr/recherche/questions-d-economie-de-la-sante/249-variations-geographiques-des-taux-de-recours-hospitalier-en-france.pdf)
