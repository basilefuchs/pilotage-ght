# Score CAQES — Consommation d'Antibiotiques Hospitaliers en DDD

## Définition

La **DDD (Defined Daily Dose)** est l'unité de mesure internationale de la consommation médicamenteuse définie par l'Organisation Mondiale de la Santé dans le cadre du système ATC/DDD (Anatomical Therapeutic Chemical / Defined Daily Dose). Elle représente la dose journalière supposée d'un médicament utilisée pour son indication principale chez l'adulte. La consommation d'antibiotiques exprimée en **DDD pour 1 000 journées d'hospitalisation** est l'indicateur officiel de suivi du volet «bon usage des antibiotiques» du CAQES (Contrat d'Amélioration de la Qualité et de l'Efficience des Soins), dispositif contractuel DGOS/CNAM applicable à tout établissement de santé.

```
Score_DDD_ATB = Σ(quantité_dispensée_UCD_j × mg_par_UCD_j / DDD_OMS_j)
                ─────────────────────────────────────────────────────────  × 1 000
                        Σ journées_hospitalisation

où j parcourt l'ensemble des spécialités antibiotiques de classe ATC J01
```

Cet indicateur est fondamentalement distinct de l'`indicateurs_pertinence_antibiotiques_ambulatoire` qui mesure la pertinence des prescriptions en médecine de ville depuis le SNDS. Le Score CAQES DDD porte sur la **consommation intra-hospitalière** mesurée depuis le FICHCOMP MED, avec la métrique DDD reconnue internationalement (ECDC, OMS) pour la comparaison inter-établissements et inter-pays, indépendamment du mix de molécules et des posologies locales.

La réduction de la consommation antibiotique hospitalière est un objectif CAQES avec des valeurs-cibles fixées par l'ARS dans le contrat individuel de chaque établissement, typiquement une réduction de 3 à 5% par an.

## Calcul

Sources : FICHCOMP MED + PMSI MCO RSA (journées) + table ATC/DDD OMS + table UCD → ATC.

```
Population : tous séjours MCO d'un établissement sur une période (trimestre ou année)

Étape 1 — Extraction des dispensations antibiotiques depuis FICHCOMP MED :
  Filtrer les lignes FICHCOMP MED sur la classe ATC J01 (antibactériens systémiques)
  Variables FICHCOMP MED utilisées :
    `ident`    : clé de jointure avec le RSA (identifiant du séjour)
    UCD        : code UCD à 7 chiffres (identifiant unique de la spécialité)
    nbre       : nombre d'unités (UCD) administrées — table med (FICHCOMP)
    delai + adm_annee/adm_mois : délai depuis l'entrée et période d'administration

  Table de correspondance nécessaire : UCD → code ATC (disponible sur la base Claude)
    ou via le répertoire des médicaments ANSM / base THÉRIAQUE / FICHCOMP annexe ATIH

Étape 2 — Jointure avec la table DDD OMS :
  Pour chaque molécule antibiotique j (identifiée par son DCI / code ATC) :
    mg_par_UCD_j = masse en mg de principe actif par unité UCD
                   (ex : amoxicilline 1g injectable = 1 000 mg/UCD)
    DDD_OMS_j    = DDD officielle OMS en mg/jour pour la voie d'administration
                   (ex : amoxicilline IV : DDD = 1 000 mg/jour selon OMS ATC/DDD 2024)

  Source DDD : WHO Collaborating Centre for Drug Statistics Methodology
    https://www.whocc.no/atc_ddd_index/
    Mise à jour annuelle — utiliser la version correspondant à l'année des données

Étape 3 — Calcul des DDD par dispensation :
  DDD_dispensées_j_RSA = nbre × mg_par_UCD_j / DDD_OMS_j
  DDD_totales_ATB = Σ DDD_dispensées_j_RSA   [sur tous les antibiotiques J01 et tous les RSA]

  Regroupements utiles :
    DDD_J01A  = pénicillines (J01C + J01CA)
    DDD_J01D  = céphalosporines (J01DB, J01DC, J01DD, J01DE)
    DDD_J01F  = macrolides
    DDD_J01M  = fluoroquinolones
    DDD_J01X  = antibiotiques de dernier recours (glycopeptides, colistine, linézolide)

Étape 4 — Calcul des journées d'hospitalisation :
  Journées_MCO = Σ (duree + 1)   [par convention PMSI : journées = durée + 1 nuit]
    ou
  Journées_MCO = Σ(DATE_SORTIE − DATE_ENTREE + 1) pour les séjours > 0 jour
  Journées_séances (DUREE = 0) : exclure ou compter comme 0,5 journée selon convention

  Pour intégrer SSR et psychiatrie :
    Journées_SSR = Σ journées RHA (Résumés Hebdomadaires Anonymisés)
    Journées_PSY = Σ journées de présence PSY (depuis RIMP/R-PSY)
    Journées_totales = Journées_MCO + Journées_SSR + Journées_PSY

Étape 5 — Score DDD pour 1 000 journées :
  Score_DDD_ATB_global = DDD_totales_ATB / Journées_totales × 1 000

  Scores par famille ATC :
  Score_DDD_J01A = DDD_J01A / Journées × 1 000   [indicateur de consommation pénicillines]
  Score_DDD_J01X = DDD_J01X / Journées × 1 000   [indicateur critique antibiotiques de recours]

Cas limites :
  - UCD sans code ATC ou sans DDD OMS : reporter comme "non classifiable" — ne pas inclure
    dans le numérateur mais documenter le % de dispensations non classifiables
  - nbre = 0 ou montant nul (tables med_valo_*) : ligne erreur FICHCOMP → exclure
  - FICHCOMP indisponible pour une période : Score = NA — documenter la cause
  - DDD OMS révisée en cours d'année : utiliser la version en vigueur au 1er janvier de l'année N
```

Indicateurs dérivés :

```
Ratio antibiotiques de recours (carbapénèmes + colistine + glycopeptides) :
  Ratio_recours = Score_DDD_J01X / Score_DDD_ATB_global × 100   [en %]
  > 8% : usage élevé des antibiotiques de dernière ligne → risque BMR

Indice de rotation des classes (antibiotic cycling proxy) :
  = nb de classes ATC J01 distinctes représentant > 5% du total DDD / nb_classes_totales
  → diversité de l'antibiothérapie (résistance à la mono-dépendance)

Tendance CAQES (objectif de réduction annuelle) :
  = (Score_DDD_N − Score_DDD_N-1) / Score_DDD_N-1 × 100   [variation en %]
  Objectif CAQES type : réduction de 3–5% par an
```

## Utilité

- **Suivi contractuel CAQES avec l'ARS** : le Score_DDD_ATB est l'indicateur officiel demandé dans le volet bon usage antibiotiques du CAQES — sa production annuelle (voire trimestrielle) et sa présentation à la Commission des médicaments (COMEDIMS) et à l'ARS est une obligation réglementaire pour tous les établissements avec CAQES
- **Détection des services à forte pression antibiotique** : décomposer le Score_DDD_ATB par UM (unité médicale) identifie les services avec une consommation disproportionnée — un service de réanimation avec Score_DDD > 1 500 est dans la norme ; un service de médecine interne à 800 signale une surconsommation à auditer
- **Benchmark ECDC intra-GHT et national** : le réseau EARS-Net (ECDC) et l'ANSM publient des benchmarks nationaux et européens en DDD/1 000 journées par type d'établissement — permettant de positionner chaque établissement du GHT dans un référentiel international validé
- **Surveillance des antibiotiques de recours (Score_DDD_J01X)** : le suivi des carbapénèmes, glycopeptides et colistine en DDD/1 000 journées est l'indicateur précoce de l'émergence de résistances bactériennes — un Score_DDD_J01X > 50 DDD/1 000 journées est un signal d'alerte pour l'équipe opérationnelle d'hygiène
- **Évaluation des programmes d'antibiogouvernance** : mesurer le Score_DDD avant et après la mise en place d'un programme de stewardship antibiotique (antibiogouvernance) — réévaluation à 48h, antibiothérapie ciblée, protocoles de désescalade — objectiver l'impact sur la consommation
- **Calcul de l'économie réalisée en CAQES** : la réduction du Score_DDD se traduit en nombre de DDD évitées × coût moyen par DDD → quantification financière des gains de bon usage antibiotique, argument pour maintenir les ressources d'infectiologie et de pharmacie clinique

## Sources de Données

- **FICHCOMP MED (table `med` de la base nationale)** : variables `ident`, `code` (UCD 7 chiffres), `nbre` (quantité administrée), `delai` + `adm_annee`/`adm_mois` (chronologie) ; montants dans les tables `med_valo_*`
- **Table UCD → ATC** : correspondance UCD → code ATC (J01*) → DCI → voie d'administration — disponible via la base Claude (ANSM), THÉRIAQUE, ou l'annexe technique ATIH du FICHCOMP
- **Table DDD OMS (ATC/DDD Index)** : doses définies journalières par molécule et voie d'administration — mise à jour annuelle, téléchargeable sur le site du WHO Collaborating Centre for Drug Statistics Methodology (whocc.no)
- **PMSI MCO RSA** : variable `DUREE`, `DATE_ENTREE`, `DATE_SORTIE`, `NOFINESS` — pour le calcul des journées d'hospitalisation dénominateur
- **PMSI SSR RHA et RIMP/R-PSY** : pour intégrer les journées SSR et psychiatriques au dénominateur si l'établissement est multi-champs

## Exemple de Valeurs

- **Réanimation adulte — CHU** : Score_DDD_ATB ≈ 1 200–2 000 DDD/1 000 journées (consommation très élevée, attendue compte tenu de l'intensité des soins)
- **CH 400 lits, toutes UM** : Score_DDD_ATB ≈ 350–600 DDD/1 000 journées
- **Chirurgie programmée — Score hors soins critiques** : Score_DDD ≈ 150–300 (antibioprophylaxie chirurgicale dominante)
- **Médecine interne — signal d'alerte** : Score_DDD > 600 DDD/1 000 journées en dehors des soins critiques → audit des prescriptions recommandé
- **Score_DDD_J01X (recours) d'alerte** : > 60 DDD/1 000 journées toutes UM → surveillance résistance renforcée, consultation infectiologie systématique
- **Objectif CAQES type** : réduction de 5% du Score_DDD_ATB global par rapport à l'année précédente ; maintien du Score_DDD_J01X < 40 DDD/1 000 journées

## Limites

- **FICHCOMP MED incomplet** : si les dispensations antibiotiques ne sont pas intégralement tracées dans le FICHCOMP (dispensations hors liste en sus non codées, dispensations urgentes non transmises), le Score_DDD sous-estime la consommation réelle — les pharmacies hospitalières ont souvent des données plus complètes dans leur logiciel de gestion de pharmacie (SGPH) qui constituent une source alternative plus exhaustive
- **Table de correspondance UCD → DDD** : la construction de la table UCD → mg/DDD est la principale difficulté technique — elle requiert soit l'accès à une base médicamenteuse (Claude, THÉRIAQUE) soit une construction manuelle par la pharmacie sur les UCD les plus fréquents ; les UCD sans correspondance doivent être documentés
- **DDD OMS révisées annuellement** : les modifications de DDD d'une année sur l'autre (rares mais existantes) peuvent affecter le score sans changement de consommation réelle — versionner la table DDD utilisée et la documenter dans le rapport
- **Journées dénominateur** : l'inclusion ou l'exclusion des séances (DUREE = 0) impacte le dénominateur — les séances de chimiothérapie ou dialyse ne reçoivent généralement pas d'antibiotiques ; les inclure au dénominateur dilue artificiellement le Score_DDD dans les établissements à forte activité de séances
- **Non-exhaustivité des champs SSR et psychiatrie** : si l'établissement est multi-champs, l'ajout des journées SSR et psychiatrie au dénominateur sans les dispensations antibiotiques correspondantes (non tracées dans le FICHCOMP MCO) crée une sous-estimation du ratio

## Références

- [WHO Collaborating Centre for Drug Statistics Methodology — ATC/DDD Index, mise à jour annuelle : définition des DDD par molécule](https://www.whocc.no/atc_ddd_index/)
- [DGOS/CNAM — Contrat d'Amélioration de la Qualité et de l'Efficience des Soins (CAQES) : volet bon usage des antibiotiques, indicateurs et cibles](https://solidarites.gouv.fr/)
- [ECDC — European Surveillance of Antimicrobial Consumption Network (ESAC-Net) : méthodologie DDD et benchmarks européens](https://www.ecdc.europa.eu/en/antimicrobial-consumption/surveillance-and-disease-data/database)
- [ANSM — Suivi des ventes de médicaments antibiotiques en France : rapports annuels avec indicateurs DDD](https://www.ansm.sante.fr/)
- [Barlam T.F. et al. — Implementing an Antibiotic Stewardship Program, Clinical Infectious Diseases 2016 : référence internationale sur l'antibiogouvernance et les indicateurs DDD](https://doi.org/10.1093/cid/ciw118)
- [Goossens H. et al. — Outpatient antibiotic use in Europe and association with resistance, Lancet 2005 : fondements épidémiologiques de l'utilisation des DDD comme indicateur de pression antibiotique](https://doi.org/10.1016/S0140-6736(05)17907-0)
