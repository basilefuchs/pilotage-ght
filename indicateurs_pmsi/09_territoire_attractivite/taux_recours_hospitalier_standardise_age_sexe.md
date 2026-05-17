# Taux de recours hospitalier standardisé sur âge et sexe

## Définition

Le **taux de recours hospitalier standardisé** mesure la consommation de soins hospitaliers d'une population résidant dans une zone géographique donnée, en neutralisant l'effet de sa structure démographique (âge × sexe) par rapport à une référence nationale. Il répond à la question : « le territoire consomme-t-il plus, moins, ou autant que la moyenne nationale, à pyramide démographique comparable ? »

**Deux méthodes co-existent**, recommandées selon l'usage :

### Méthode A — Standardisation **directe** (méthode officielle ATIH / ScanSanté)

Produit un taux en **séjours (ou journées) pour 1 000 habitants**, directement comparable entre territoires :

```
TR_direct(z) = Σ_k [ taux_obs(z, k) × pop_ref(k) ] / Σ_k pop_ref(k)
```

avec `taux_obs(z, k) = séjours(z, k) / pop(z, k)` pour chaque strate âge × sexe *k*, et `pop_ref(k)` = population française dans la strate *k*.

Unités officielles ATIH :
- **MCO** : séjours ou patients pour 1 000 habitants
- **HAD, SSR, Psy** : patients ou journées pour 1 000 habitants

C'est la métrique publiée par ScanSanté.

### Méthode B — Standardisation **indirecte** (TRHS, analogue au SMR)

Produit un ratio Observés/Attendus exprimé en base 100, plus stable en petits effectifs :

```
TRHS(z) = (Séjours_observés / Séjours_attendus) × 100

Séjours_attendus = Σ_{(a,s)} [ Pop_zone_{(a,s)} × TauxNat_{(a,s)} ]
```

Interprétation :
- TRHS = 100 → recours conforme à la norme nationale
- TRHS > 100 → sur-recours (au-delà de l'effet démographique)
- TRHS < 100 → sous-recours

La méthode indirecte est l'analogue épidémiologique du **SMR** (Standardized Mortality Ratio, Breslow & Day 1987 ; IC à 95 % via Ulm 1990).

### Quand choisir laquelle

| Usage | Méthode |
|---|---|
| Publication ScanSanté, comparaison absolue entre territoires | Directe (A) |
| Petites zones, CMD rares, IC stables, alignement SMR | Indirecte (B) |
| Reporting ARS, dialogue de gestion GHT | Directe (A) |
| Analyse fine type Atlas IRDES / Dartmouth | Indirecte (B) avec shrinkage |

Positionnement vs autres indicateurs du projet :
- `taux_recours_100k_zone_attractivite.md` calcule un **taux brut** (non standardisé).
- `taux_recours_ajuste_fdep.md` neutralise la précarité.
- `coefficient_variation_pondere_recours_irdes.md` et `ratio_extreme_p90_p10_recours_chirurgie.md` agrègent la dispersion **inter-territoires** du présent indicateur.

## Calcul

**Sources** : RSA MCO (ou RHA SSR, RPSA HAD, RIM-P Psy) — agrégés par lieu de **résidence** du patient (pas par lieu de prise en charge) + INSEE RP + tables de référence ATIH.

**Variables PMSI mobilisées** :
- `CODE_GEO_RESIDENCE` (PMSI 5 caractères) → mapping zone *z* (territoire de santé, département, GHT, zone d'attraction ATIH)
- `AGE_ANNEE` (ou `AGE_JOUR` pour nouveau-nés)
- `SEXE` (1 = M, 2 = F)
- `NUM_SEJ_ANO` (comptage)

**Population de référence** : INSEE RP par âge × sexe (millésime cohérent avec l'année PMSI, souvent N-2) ou table de population diffusée par l'ATIH.

### Pseudocode — Méthode A (directe, ScanSanté)

```r
# 1. Compter les séjours par strate âge × sexe × zone
denom_strate <- pmsi %>%
  filter(annee == A, secteur == "MCO") %>%
  mutate(
    classe_age = cut(age_annee, breaks = c(0,1,5,10,15,20,25,30,35,40,
                                            45,50,55,60,65,70,75,80,85,200)),
    zone = mapping_geo(code_geo_residence)
  ) %>%
  count(zone, classe_age, sexe, name = "n_sejours")

# 2. Joindre la population résidente par strate
taux_strate <- denom_strate %>%
  left_join(pop_insee, by = c("zone","classe_age","sexe")) %>%
  mutate(taux_brut = n_sejours / pop * 1000)   # /1000 hab MCO

# 3. Standardisation directe sur population française
pop_ref_nat <- pop_insee %>%
  group_by(classe_age, sexe) %>%
  summarise(pop_ref = sum(pop), .groups = "drop")

tr_direct <- taux_strate %>%
  left_join(pop_ref_nat, by = c("classe_age","sexe")) %>%
  group_by(zone) %>%
  summarise(
    tr_std = sum(taux_brut * pop_ref) / sum(pop_ref),
    .groups = "drop"
  )
```

### Pseudocode — Méthode B (indirecte, TRHS)

```r
# 1. Observés par zone
obs <- pmsi %>%
  filter(annee == A, secteur == "MCO") %>%
  filter(!cmd %in% c("14","15")) %>%     # exclusions standard
  mutate(
    classe_age = cut(age_annee, breaks = quinquennales),
    zone       = mapping_geo(code_geo_residence)
  ) %>%
  count(zone, classe_age, sexe, name = "obs")

# 2. Taux nationaux de référence par strate
taux_nat <- pmsi_national %>%   # ATIH open data ou SAE DREES
  group_by(classe_age, sexe) %>%
  summarise(
    taux_nat = sum(n_sejours) / sum(pop_nationale),
    .groups  = "drop"
  )

# 3. Attendus par zone
att <- pop_insee %>%
  left_join(taux_nat, by = c("classe_age","sexe")) %>%
  group_by(zone) %>%
  summarise(att = sum(pop * taux_nat), .groups = "drop")

# 4. TRHS et IC 95 % (Ulm 1990)
trhs <- obs %>%
  group_by(zone) %>% summarise(obs_total = sum(obs), .groups = "drop") %>%
  left_join(att, by = "zone") %>%
  mutate(
    trhs    = (obs_total / att) * 100,
    ic_low  = trhs - 1.96 * trhs / sqrt(obs_total),
    ic_high = trhs + 1.96 * trhs / sqrt(obs_total)
  )
```

**Conventions cas limites (les deux méthodes)** :
- Codes géographiques `99xxx` (étranger, indéterminé) : exclure du numérateur ET du dénominateur.
- Strate avec `pop = 0` : exclure (pas de population à risque).
- Volume minimal recommandé : ≥ 500 séjours observés pour TRHS global, ≥ 100 séjours par CMD pour déclinaison par CMD.
- Att = 0 → TRHS = NA (zone trop petite, < 500 hab.).
- Effet version PMSI : ne pas comparer des années avec changement de version GHM sans correction.

### Déclinaisons utiles

```
Écart absolu de séjours (méthode B) :
  ΔSéjours = Obs_total − Att_total

TRHS par CMD (décomposition du sur/sous-recours) :
  Contribution_cmd = (Obs_cmd − Att_cmd)
  → trier les CMD les plus contributrices au sur-recours global

TRHS tendanciel sur 3 ans :
  ΔTRHS = TRHS(N) − TRHS(N−3)
  > +5 pts : aggravation du sur-recours
  < −5 pts : convergence vers la norme
```

## Utilité

1. **Diagnostic territorial ARS / GHT** : identifier les zones en sous- ou sur-recours, après neutralisation de l'effet démographique — entrée principale du Projet Régional de Santé.
2. **Cible CPOM** : trajectoire de recours pour un territoire vieillissant, en distinguant ce qui relève du vieillissement (à exclure) de ce qui relève des pratiques (à cibler).
3. **Détection de pratiques atypiques** : un écart standardisé > ±15 % sur un GHM ou une CMD signale soit une offre excédentaire/insuffisante, soit un comportement de prescription atypique.
4. **Prioriser les CMD à auditer en pertinence** : décomposition par CMD du sur-recours → triage des spécialités à investiguer.
5. **Argumenter capacités auprès de l'ARS** : un TRHS global > 115 sur 2 exercices est un argument objectif pour justifier des renforts capacitaires.
6. **Détecter le renoncement aux soins** : TRHS < 85 persistant sur plusieurs CMD médicales → croisement avec `taux_patients_sans_medecin_traitant.md`, `score_vulnerabilite_sociale.md`.
7. **Suivi virage ambulatoire** : décliner sur séjours ambulatoires pour mesurer l'avancement indépendamment de la démographie.
8. **Benchmark inter-GHT** : seul indicateur permettant une comparaison équitable entre territoires aux démographies très différentes.

## Sources de Données

- **PMSI MCO** : RSA — variables `CODE_GEO_RESIDENCE`, `AGE_ANNEE`, `SEXE`, `NUM_SEJ_ANO`, `CMD`, `GHM`. Guide méthodologique MCO ATIH en vigueur.
- **PMSI SSR/SMR (RHA)**, **HAD (RPSA)**, **RIM-P (Psy)** : variables équivalentes.
- **INSEE Recensement de la Population** : populations légales par commune × tranche d'âge quinquennale × sexe — millésime N-1 ou N-2 (Filosofi pour communes < 2 000 hab.).
- **SAE DREES** : tableaux nationaux de séjours MCO par âge × sexe — disponibles dans *Les établissements de santé* et sur data.drees.fr.
- **ATIH Open Data** (préféré pour TauxNat car homogène avec PMSI local) : opendata.atih.sante.fr.
- **Référentiel Zones d'attraction ATIH** : correspondance commune → établissement de rattachement (méthode pluralité des séjours par commune).
- **Référentiel ATIH** : table de correspondance `CODE_GEO_PMSI ↔ commune ↔ territoire de santé ↔ département ↔ région ↔ GHT`.

**Restitutions publiques équivalentes** :
- ScanSanté → application *Taux de recours par région ou par territoire de santé* (méthode directe).
- DREES → panoramas annuels et data.drees (taux nationaux).

## Exemple de Valeurs

### Méthode A (directe, /1000 hab) — plages observées (ordre de grandeur, ScanSanté)

| Domaine | National | Plage régionale |
|---|---|---|
| MCO – séjours / 1000 hab | ~270 | 220 – 320 |
| HAD – journées / 1000 hab | ~30 | 10 – 70 |
| SSR – journées / 1000 hab | ~110 | 70 – 160 |
| Psy – journées / 1000 hab | ~140 | 90 – 220 |

### Méthode B (indirecte, TRHS base 100)

| Contexte | TRHS global | Interprétation |
|---|---|---|
| Zone rurale vieillissante, accès limité ambulatoire | 88 – 94 | Sous-recours probable malgré démographie âgée |
| Zone péri-urbaine équilibrée | 96 – 104 | Recours conforme |
| Zone à fort tissu industriel | 108 – 118 | Sur-recours CMD 4, CMD 8 |
| Zone de CHU avec recours spécialisé | 115 – 130 | Sur-recours CMD 1, 16, 17 |

**Par CMD (TRHS_cmd, exemples plausibles)** :
- CMD 5 (Circulatoire) = 112 → sur-recours cardiologique
- CMD 8 (Orthopédie) = 125 → à croiser avec `taux_pertinence_actes_ccam.md`
- CMD 11 (Rein) = 78 → possible substitution HAD/dialyse ambulatoire

**Seuils d'alerte** :
- TRHS < 85 ou > 115 sur 2 exercices consécutifs → analyse par CMD obligatoire.
- Écart > +20 % vs national (méthode A) → sur-recours marqué.

**Volume minimal** : zone > 30 000 habitants, ≥ 500 séjours observés (global), ≥ 100 par CMD.

Sources des plages : ScanSanté + ordres de grandeur experts, non sourcés au chiffre près sur campagne en cours.

## Limites

- **Standardisation âge/sexe uniquement** : ne neutralise ni précarité, ni morbidité de fond, ni densité de premier recours. Croiser avec FDep, score vulnérabilité sociale.
- **Lieu de résidence vs lieu de prise en charge** : un sur-recours en zone *z* peut être consommé hors *z* (fuite). Lire toujours en parallèle de `taux_fuite_attractivite.md`.
- **Méthode directe vs indirecte** : les deux ne sont pas strictement interchangeables. La directe est plus sensible aux petits effectifs ; l'indirecte est plus stable mais perd l'unité (séjours/1000) et ne se compare qu'à la norme nationale.
- **Définition de la zone** : MAUP (Modifiable Areal Unit Problem) — changement de maille (commune, EPCI, territoire de santé, GHT) peut inverser le diagnostic.
- **Qualité du code géographique** : sous-codage, codes regroupés `99xxx`, résidents EHPAD codés au siège.
- **Population de référence INSEE** : sous-estime les résidents saisonniers (littoral, montagne) → TRHS gonflé artificiellement.
- **Année de référence des taux nationaux** : décalage 2 ans habituel — documenter systématiquement le millésime utilisé.
- **Petits effectifs / CMD rares** : IC très large, instabilité — appliquer un shrinkage bayésien ou ne pas publier.
- **Effet version PMSI** : changements GHM annuels → corriger avant comparaison pluriannuelle.
- **Fuites hors zone non capturées** par le PMSI local : si la fuite est forte, l'indicateur sous-estime le recours réel.

## Références

- ATIH / ScanSanté, *Taux de recours par région ou par territoire de santé* — méthodologie de standardisation directe sur âge × sexe. URL : https://www.scansante.fr/applications/taux-de-recours
- ATIH, *Caractériser et suivre un GHT avec ScanSanté* — usage du taux de recours dans le diagnostic GHT. URL : https://www.scansante.fr/caracteriser-et-suivre-un-groupement-hospitalier-de-territoire-ght
- ATIH, *Flux inter-régionaux* — restitution complémentaire. URL : https://www.atih.sante.fr/flux-inter-regionaux
- ATIH, Guide méthodologique de production des informations relatives à l'activité médicale (PMSI MCO/HAD/SSR/Psy), campagne en vigueur. URL : https://www.atih.sante.fr/pmsi-mco
- DREES, *Les établissements de santé*, édition annuelle (SAE) — tableaux de séjours par âge et sexe. URL : https://www.drees.solidarites-sante.gouv.fr/publications/panoramas-de-la-drees/les-etablissements-de-sante
- Breslow N.E., Day N.E. — *Statistical Methods in Cancer Research, Vol. II : Indirect standardization methodology (SMR/SHR)*, IARC, 1987. URL : https://publications.iarc.fr/Book-And-Report-Series/Iarc-Scientific-Publications/Statistical-Methods-In-Cancer-Research-Volume-II-The-Design-And-Analysis-Of-Cohort-Studies-1987
- Ulm K. — *A simple method to calculate the confidence interval of a standardized mortality ratio*, Am J Epidemiol, 1990. DOI : 10.1093/oxfordjournals.aje.a115633
- OECD, *Geographic Variations in Health Care: What Do We Know and What Can Be Done to Improve Health System Performance?* OECD Health Policy Studies, 2014. DOI : 10.1787/9789264216594-en
- IRDES, *Variations géographiques des taux de recours hospitalier en France*, Questions d'économie de la santé n° 249, 2019. URL : https://www.irdes.fr/recherche/questions-d-economie-de-la-sante/249-variations-geographiques-des-taux-de-recours-hospitalier-en-france.pdf
- Dormont B., Huber H. — *Causes of health expenditure growth: the predominance of changes in medical practices over population ageing*, Annals of Economics and Statistics, 2006. DOI : 10.2307/20079145
- Voir aussi `coefficient_variation_pondere_recours_irdes.md`, `ratio_extreme_p90_p10_recours_chirurgie.md`, `taux_recours_ajuste_fdep.md`, `taux_fuite_attractivite.md`.
