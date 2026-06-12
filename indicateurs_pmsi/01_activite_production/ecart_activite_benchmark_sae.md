# Écart d'Activité au Benchmark National par Strate SAE (ÉA-SAE)

## Définition

L'ÉA-SAE mesure l'écart relatif entre le volume d'activité MCO d'un établissement sur une racine de GHM donnée et le volume moyen observé dans sa **strate de pairs nationaux**, définie par le croisement statut juridique × taille × profil de spécialité issu de la SAE DREES. Il est exprimé en pourcentage de déviation par rapport à la médiane de la strate.

**ÉA-SAE_(g) = ( RSA_etab_(g) / RSA_médiane_pairs_(g) − 1 ) × 100**

où :
- **RSA_etab_(g)** = nombre de RSA produits par l'établissement sur la racine GHM g sur la période
- **RSA_médiane_pairs_(g)** = médiane des RSA produits sur la racine g dans la strate de pairs de l'établissement, calculée depuis le PMSI national ATIH

**Signe et interprétation :**
- ÉA-SAE > 0 → l'établissement produit plus que ses pairs sur cette racine (sur-activité relative)
- ÉA-SAE < 0 → l'établissement est en deçà de la médiane de ses pairs (sous-activité relative)
- ÉA-SAE = 0 → alignement exact sur la médiane de la strate

La médiane est préférée à la moyenne car elle est robuste aux établissements extrêmes (CHU atypiques ou petits établissements à activité quasi nulle) qui déforment la moyenne arithmétique dans des strates hétérogènes.

En complément, un **z-score de strate** permet la détection des outliers statistiques :

**z_(g) = ( RSA_etab_(g) − μ_pairs_(g) ) / σ_pairs_(g)**

où μ et σ sont la moyenne et l'écart-type des RSA de la strate sur la racine g. Un |z| > 2 signale une position statistiquement atypique dans la strate.

Cet indicateur comble un angle mort des outils PMSI courants : `nombre_sejours.md` et `activite_mco.md` donnent des volumes bruts sans référentiel de comparaison ; `case_mix_index.md` compare la lourdeur (poids moyen) mais pas le volume par GHM ; `indice_specialisation.md` mesure la concentration interne du casemix mais pas la position relative par rapport aux pairs nationaux. L'ÉA-SAE révèle, racine par racine, où un établissement est structurellement sous- ou sur-développé par rapport à des établissements de même profil.

## Calcul

Sources : PMSI MCO RSA (ATIH) + PMSI national ATIH open data + SAE DREES (stratification des pairs).

```
Étape 1 — Définition de la strate de pairs :
  La strate est définie par 3 critères croisés issus de la SAE :

  A. Statut juridique (4 modalités) :
     - CHU / CHR
     - CH public non-CHU
     - ESPIC (Établissement de Santé Privé d'Intérêt Collectif)
     - MCO privé commercial

  B. Volume d'activité MCO (strates en RSA/an) :
     - Strate 1 : < 5 000 RSA/an
     - Strate 2 : 5 000–15 000 RSA/an
     - Strate 3 : 15 000–30 000 RSA/an
     - Strate 4 : > 30 000 RSA/an

  C. Profil de spécialité dominant (CMD majoritaire > 40% des RSA) :
     - Médecine polyvalente (CMD 1, 4, 7, 11 dominantes)
     - Chirurgie programmée (CMD 1, 5, 8 chirurgicales dominantes)
     - Obstétrique (CMD 14 > 20%)
     - Polyvalent sans dominante identifiable

  → Strate = combinaison (Statut × Volume × Profil) avec au moins 10 établissements
    Si la cellule compte < 10 établissements : remonter d'un niveau de granularité
    (supprimer le critère C, puis B) pour garantir la stabilité du benchmark

Étape 2 — Extraction des RSA de l'établissement par racine GHM :
  RSA_etab_{(g)} = COUNT(RSA) WHERE `finessgeo` = etab AND GHM_racine = g
  Calculé pour toutes les racines GHM avec au moins 1 RSA sur la période

  Variables PMSI utilisées :
    - `finessgeo` : identifiant établissement géographique
    - GHM        : code GHM complet (8 caractères) → racine = 5 premiers caractères
    - NBSEANCES  : exclure les séjours de séances (nbseances > 0) si analyse séjours seuls

Étape 3 — Extraction des RSA nationaux par strate et racine GHM :
  Source : PMSI national ATIH open data (fichier RSA_national_strate_GHM)
  RSA_national_{(strate, g)} = liste des volumes RSA_{g} pour chaque établissement de la strate

  Calcul de la médiane et des statistiques de strate :
    RSA_médiane_pairs_{(g)} = MÉDIANE( {RSA_etab'_{(g)}, etab' ∈ strate} )
    μ_pairs_{(g)}           = MOYENNE( {RSA_etab'_{(g)}, etab' ∈ strate} )
    σ_pairs_{(g)}           = ÉCART-TYPE( {RSA_etab'_{(g)}, etab' ∈ strate} )
    P25_{(g)}, P75_{(g)}   = quartiles pour visualisation boxplot

  Convention : si RSA_médiane_pairs_{(g)} = 0 → ÉA-SAE = NA
               (racine absente de la strate → comparer au niveau CMD)

Étape 4 — Calcul de l'ÉA-SAE par racine GHM :
  ÉA-SAE_{(g)} = ( RSA_etab_{(g)} / RSA_médiane_pairs_{(g)} − 1 ) × 100
  z_{(g)}       = ( RSA_etab_{(g)} − μ_pairs_{(g)} ) / σ_pairs_{(g)}

  Si RSA_etab_{(g)} = 0 et RSA_médiane_pairs_{(g)} > 0 :
    ÉA-SAE_{(g)} = −100% (activité nulle sur une racine présente chez les pairs)
    → Signal fort de GHM absent (non développé ou arrêt d'activité)

Étape 5 — Agrégation par CMD et global :
  ÉA-SAE_CMD_{(c)} = ( RSA_etab_CMD_{(c)} / RSA_médiane_pairs_CMD_{(c)} − 1 ) × 100
  ÉA-SAE_global    = ( RSA_etab_total   / RSA_médiane_pairs_total   − 1 ) × 100
```

Indicateurs dérivés :

```
Portefeuille de sur/sous-activité :
  GHM_sur    = { g | ÉA-SAE_{(g)} > +20% ET RSA_etab_{(g)} ≥ 50 }
  GHM_sous   = { g | ÉA-SAE_{(g)} < −20% ET RSA_médiane_pairs_{(g)} ≥ 50 }
  → Distingue le sous-développement réel (pairs actifs) de l'absence justifiée

Indice de convergence vers les pairs (ICP) :
  ICP = 1 − ( Σ_g |ÉA-SAE_{(g)}| × w_g ) / ( N_GHM × 100 )
  w_g = RSA_médiane_pairs_{(g)} / Σ RSA_médiane_pairs_{(g)}
  ICP proche de 1 = profil d'activité proche des pairs | ICP proche de 0 = profil atypique

Évolution temporelle de l'écart (drift) :
  ΔÉASAE_{(g)} = ÉA-SAE_{(g,N)} − ÉA-SAE_{(g,N-3)}
  ΔÉASAE > +15 pts sur 3 ans = montée en charge sur cette racine
  ΔÉASAE < −15 pts sur 3 ans = érosion d'activité vs pairs, signal de vigilance
```

## Utilité

- **Identifier les GHM sous-développés par rapport aux pairs** : un CH de 20 000 RSA/an avec ÉA-SAE = −65% sur la racine 08C02 (prothèse de hanche) alors que tous ses pairs de même strate la pratiquent signale soit une absence d'autorisation, soit une fuite vers la clinique concurrente, soit un déficit de recrutement chirurgical — information directement actionnable en COPIL médical.
- **Détecter les sur-activités candidates à une revue de pertinence** : une racine avec ÉA-SAE > +50% sur plusieurs années consécutives dans un établissement est un signal de sur-codage potentiel ou d'une attractivité anormale méritant analyse (file active captée, codage des CMA, pratiques de regroupement de séjours).
- **Préparer les dialogues de gestion avec l'ARS** : l'ÉA-SAE global et par CMD fournit l'argumentaire chiffré lors des CPOM — un CH avec ÉA-SAE_CMD14 = −30% vs pairs peut justifier un appui en maternité ; un établissement avec ÉA-SAE global = +18% peut anticiper une question sur le calibrage de son financement.
- **Calibrer la stratégie de développement du GHT** : en consolidant les ÉA-SAE de tous les établissements du GHT par CMD, la direction commune identifie les activités absentes au niveau du GHT vs les peers nationaux de GHT équivalents, et celles où le GHT est surreprésenté (risque de doublon interne).
- **Suivre l'impact d'un recrutement médical ou d'une ouverture d'unité** : si un chirurgien vasculaire est recruté en N, l'ÉA-SAE sur les racines CMD 5 chirurgicales doit progresser sur N+1/N+2 — indicateur de résultat d'une décision de ressources humaines médicales.
- **Benchmark interne au GHT** : comparer les ÉA-SAE des établissements du GHT entre eux (à strate comparable) révèle les complémentarités réelles et les chevauchements d'activité sur un même territoire, préalable à toute réorganisation de l'offre intra-GHT.

## Sources de Données

- **PMSI MCO RSA** (ATIH) : variables `finessgeo`, `ghm2` (6 car.), `nbseance` — extraction annuelle sur exercice complet.
- **PMSI national ATIH open data** : fichiers de statistiques nationales MCO par établissement, GHM et CMD, disponibles sur opendata.atih.sante.fr — utilisés pour construire la distribution de strate (μ, médiane, σ, quartiles) par racine GHM.
- **SAE DREES** : fichier établissements avec statut juridique, nombre de lits MCO, spécialités déclarées — sert exclusivement à la construction et l'affectation des strates. Disponible sur data.drees.fr (millésime N-1).
- **Référentiel GHM ATIH** : table de correspondance GHM complet (8 car.) → racine (5 car.) → CMD (2 car.) → libellé — indispensable pour l'agrégation et la présentation médicale des résultats.

## Exemple de Valeurs

| Contexte | ÉA-SAE global | Lecture |
|---|---|---|
| CH polyvalent 18 000 RSA, strate 3 | +8% | Légèrement au-dessus de la médiane, conforme |
| CH polyvalent 18 000 RSA, CMD 8 (orthopédie) | −42% | Activité orthopédique très inférieure aux pairs — à analyser |
| CHU polyvalent, CMD 1 neurologie | +35% | Sur-activité neurologique typique d'un CHU de recours |
| Clinique MCO privée, CMD 5 chir. cardiaque | −100% | Racine absente (0 RSA) alors que 80% des pairs de la strate la pratiquent |
| CH rural < 5 000 RSA, strate 1 | +2% | Proche de la médiane — profil d'activité normé pour la strate |

**z-scores indicatifs :**
- |z| < 1 : dans la norme de la strate
- 1 ≤ |z| < 2 : position notable, à surveiller
- |z| ≥ 2 : outlier statistique — justifie une analyse approfondie

**Seuils opérationnels recommandés :**
- ÉA-SAE < −20% ET RSA_médiane_pairs ≥ 50 → GHM en sous-développement significatif
- ÉA-SAE > +30% ET z > 1,5 → GHM candidat à une revue de pertinence/codage
- Volume minimal par racine pour publication : RSA_etab ≥ 30 ET RSA_médiane_pairs ≥ 30

## Limites

- **Stratification SAE déclarative** : le statut et les spécialités déclarées à la SAE ne sont pas audités. Deux établissements aux profils réels similaires peuvent se trouver dans des strates différentes selon leurs déclarations, faussant le benchmark. Vérifier la cohérence de la strate attribuée avant interprétation.
- **Hétérogénéité intra-strate** : même dans une strate bien définie, la dispersion des RSA par racine peut être très élevée (σ/μ > 1 fréquent sur les GHM de recours) — un ÉA-SAE de −30% dans une strate très dispersée est moins significatif que dans une strate homogène. Toujours présenter le z-score conjointement.
- **Sensibilité à la version de classification GHM** : un changement de version ATIH (ex. GHM v11 → v12) peut éclater une racine en deux ou fusionner deux racines, rendant les ÉA-SAE non comparables d'une année à l'autre sans recodage rétrospectif sur la nouvelle classification.
- **Absence de neutralisation démographique** : contrairement au TRHS (taux_recours_hospitalier_standardise_age_sexe.md), l'ÉA-SAE compare des volumes bruts sans corriger la structure d'âge de la population locale — un CH en zone très âgée aura mécaniquement plus de séjours médicaux que ses pairs de strate en zone jeune. Croiser les deux indicateurs pour désambiguïser volume et démographie.
- **PMSI national avec délai de publication** : les fichiers ATIH open data nationaux sont disponibles avec 12 à 18 mois de décalage. L'ÉA-SAE calculé en 2025 est construit sur des données nationales 2023, ce qui peut masquer des évolutions récentes de l'activité des pairs (ouvertures/fermetures de services).
- **Non-comparabilité des séjours de séances** : si l'établissement réalise des séjours de séances (chimiothérapie, dialyse) dont les pairs de sa strate en réalisent peu (ou vice versa), l'ÉA-SAE sera artificiellement dévié sur les CMD concernées. Filtrer ou analyser séparément selon l'objectif.

## Références

- [DREES — Statistique Annuelle des Établissements de santé (SAE) — méthodologie et fichiers de données](https://drees.solidarites-sante.gouv.fr/sources-outils-et-enquetes/00-la-statistique-annuelle-des-etablissements-sae)
- [ATIH — PMSI MCO open data national : statistiques par établissement, GHM et CMD](https://www.scansante.fr/)
- [Goldstein H., Spiegelhalter D.J. — League tables and their limitations: statistical issues in comparisons of institutional performance, Journal of the Royal Statistical Society A, 1996](https://doi.org/10.2307/2983325)
- [Iezzoni L.I. — Risk Adjustment for Measuring Health Care Outcomes, 4th ed., Health Administration Press 2012 — fondements du benchmarking en données administratives hospitalières]
- [Normand S.L., Shahian D.M. — Statistical and clinical aspects of hospital outcomes profiling, Statistical Science, 2007](https://doi.org/10.1214/088342307000000096)
- [ANAP — Tableau de bord de pilotage médico-économique des établissements de santé — méthodologie de stratification des pairs](https://www.anap.fr/)
- [ATIH — Guide méthodologique PMSI MCO (version en vigueur) — règles de production et de comptage des RSA](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
