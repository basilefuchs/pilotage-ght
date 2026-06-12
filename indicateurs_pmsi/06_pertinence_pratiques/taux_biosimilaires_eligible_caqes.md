# Taux de Recours aux Biosimilaires Éligibles CAQES

## Définition

Un **médicament biosimilaire** est un médicament biologique dont la substance active est similaire à celle d'un médicament biologique de référence déjà autorisé («médicament originator» ou «médicament de référence»), dont le brevet est expiré. Contrairement aux génériques des petites molécules chimiques, les biosimilaires sont des protéines complexes produites par des organismes vivants ; leur interchangeabilité est encadrée par des recommandations spécifiques de l'EMA et de la HAS.

Le CAQES (Contrat d'Amélioration de la Qualité et de l'Efficience des Soins) impose aux établissements de santé un suivi du **taux de recours aux biosimilaires** pour les molécules biologiques pour lesquelles des biosimilaires sont disponibles et approuvés. Ce taux est calculé depuis le FICHCOMP MED :

```
Taux_biosimilaires = Σ UCD_biosimilaires_dispensées (molécule m)
                     ──────────────────────────────────────────────  × 100
                     Σ UCD_(biosimilaires + originator)_dispensées (molécule m)
```

calculé pour chaque molécule éligible m de la liste CAQES, puis agrégé en score composite pondéré par les volumes.

L'enjeu économique est majeur : les biosimilaires sont en moyenne 25 à 40% moins onéreux que les originators correspondants. L'ATIH et la CNAM estiment que l'atteinte des cibles CAQES biosimilaires représente un potentiel d'économies de plusieurs centaines de millions d'euros par an à l'échelle nationale.

Cet indicateur est distinct du `taux_recours_liste_en_sus` (qui mesure la proportion de séjours ayant une dispensation en sus, toutes molécules confondues) et du `score_caqes_ddd_antibiotiques_hospitaliers` (antibiotiques uniquement). Il cible spécifiquement la **substitution biosimilaire** sur les molécules onéreuses à fort enjeu économique.

## Calcul

Sources : FICHCOMP MED + liste CAQES des molécules éligibles biosimilaires + table UCD → statut biosimilaire/originator.

```
Population : toutes lignes FICHCOMP MED d'un FINESS/période pour les molécules CAQES éligibles

Étape 1 — Chargement de la liste CAQES des molécules biologiques éligibles :
  Référence : Annexe de l'arrêté CAQES en vigueur (actualisé annuellement)
  Format : table avec colonnes DCI, CODE_ATC, STATUT (biosimilaire / originator), UCD_REF

  Molécules éligibles principales (liste indicative — vérifier la version en vigueur) :
    Érythropoïétines (EPO)  : ATC B03XA01 (époétine alfa, bêta, zêta, theta)
    Filgrastim / G-CSF       : ATC L03AA02 (filgrastim biosimilaire vs Neupogen®)
    Infliximab               : ATC L04AB02 (biosim vs Remicade®)
    Étanercept               : ATC L04AB01 (biosim vs Enbrel®)
    Adalimumab               : ATC L04AB04 (biosim vs Humira®)
    Rituximab                : ATC L01XC02 (biosim vs MabThera®)
    Bevacizumab              : ATC L01XC07 (biosim vs Avastin®)
    Trastuzumab              : ATC L01XC03 (biosim vs Herceptin®)
    Insuline glargine        : ATC A10AE04 (biosim vs Lantus®)
    Insuline lispro          : ATC A10AB04 (biosim vs Humalog®)
    [+ autres selon l'arrêté CAQES en vigueur]

Étape 2 — Identification du statut biosimilaire dans FICHCOMP MED :
  Table de correspondance UCD → statut : {biosimilaire, originator, non_eligible}
  Source : répertoire ANSM des médicaments (liste des biosimilaires autorisés)
           ou base Claude / THÉRIAQUE (filtre champ "biosimilaire" = oui)

  Pour chaque ligne FICHCOMP MED :
    Si UCD ∈ liste_CAQES_éligibles :
      statut_UCD = biosimilaire OU originator (selon répertoire ANSM)
    Sinon : exclure de l'analyse

Étape 3 — Calcul du taux par molécule :
  Pour chaque molécule éligible m :
    NB_UCD_biosim_m    = Σ NB_UCD pour UCD biosimilaires de la molécule m
    NB_UCD_originator_m = Σ NB_UCD pour UCD originators de la molécule m
    NB_UCD_total_m      = NB_UCD_biosim_m + NB_UCD_originator_m

    Taux_biosim_m = NB_UCD_biosim_m / NB_UCD_total_m × 100   [en %]

  Cas limite : NB_UCD_total_m = 0 → molécule non prescrite dans l'établissement,
    exclure du score composite

Étape 4 — Score composite CAQES biosimilaires :
  Pondération par le nombre total d'UCD dispensées (proxy du volume financier) :
  Score_biosim_CAQES = Σ(Taux_biosim_m × NB_UCD_total_m) / Σ(NB_UCD_total_m)
                       pour m ∈ molécules_actives_dans_établissement

  Alternative : pondération par montant financial (NB_UCD × prix_unitaire)
    → plus représentative des enjeux économiques réels
    → nécessite la table des prix UCD (base Claude / tarif Sécurité Sociale)

Étape 5 — Cible CAQES par molécule et calcul de l'écart :
  Cible_CAQES_m = cible fixée par l'ARS dans le CAQES de l'établissement
    (ex : adalimumab biosimilaire ≥ 80%, infliximab ≥ 90%)
  Écart_m = Taux_biosim_m − Cible_CAQES_m
  Gap_économique_m = (Cible_CAQES_m − Taux_biosim_m) × NB_UCD_total_m
                     × (prix_originator_m − prix_biosim_m) / 100
    → estimation du gain financier atteignable en montant €

Cas limites :
  - Molécule sans biosimilaire commercialisé dans l'année (rupture de stock) :
    → exclure du calcul, documenter en note
  - Substitution médicalement contre-indiquée (patient avec anticorps anti-originator) :
    → non identifiable depuis FICHCOMP seul ; accept comme limite intrinsèque
```

Indicateurs dérivés :

```
Part des dépenses LES évitables par substitution biosimilaire :
  = Gap_économique_total / Montant_total_LES × 100   [% des dépenses en sus potentiellement substituables]

Taux de progression annuelle :
  = (Taux_biosim_m_N − Taux_biosim_m_N-1) / Taux_biosim_m_N-1 × 100
  → mesure la vitesse de transition vers les biosimilaires par molécule

Top 3 molécules par gain économique atteignable :
  = classer par Gap_économique_m décroissant
  → priorisation des actions pharmaceutiques
```

## Utilité

- **Suivi contractuel CAQES avec l'ARS** : le taux de recours aux biosimilaires par molécule est une des clauses mesurables du CAQES — la non-atteinte des cibles contractuelles peut entraîner une modulation du financement de la liste en sus (récupération partielle des remboursements sur les originators quand des biosimilaires sont disponibles)
- **Quantification du gisement d'économies pharmaceutiques** : le Gap_économique_total traduit le taux de sous-substitution en montant financier annuel — argument concret pour la direction générale et la COMEDIMS (Commission des Médicaments et des Dispositifs Médicaux Stériles) pour investir dans des consultations pharmaceutiques de substitution
- **Pilotage clinique par molécule** : certaines molécules (adalimumab, infliximab) ont des enjeux de substitution très différents selon les spécialités (rhumatologie, gastroentérologie, dermatologie) — le taux par molécule permet d'identifier les spécialités où la substitution est insuffisante et d'engager un dialogue médico-pharmaceutique ciblé
- **Benchmark intra-GHT** : comparer les taux de biosimilaires par molécule entre établissements du GHT révèle des pratiques hétérogènes — un établissement à 92% de biosimilaires pour l'infliximab alors que le voisin GHT est à 45% est un signal de partage de bonnes pratiques et d'harmonisation des marchés groupés
- **Négociation des marchés groupés GHT** : la connaissance du volume total (NB_UCD × tous établissements GHT) pour chaque molécule éligible est le levier de négociation avec les laboratoires pharmaceutiques — un marché groupé GHT sur les biosimilaires d'adalimumab peut générer 20 à 35% d'économies supplémentaires par rapport à des marchés individuels
- **Veille sur les nouvelles éligibilités CAQES** : de nouvelles molécules entrent chaque année dans la liste CAQES biosimilaires — surveiller les taux dès la première année d'éligibilité d'une nouvelle molécule permet d'anticiper les cibles ARS avant qu'elles soient formalisées dans un avenant CAQES

## Sources de Données

- **FICHCOMP MED (table `med` de la base nationale)** : variables `ident`, `code` (UCD 7 chiffres), `nbre` (quantité = NB_UCD des formules), `delai`/`adm_annee`/`adm_mois` ; montants dans les tables `med_valo_*`
- **Répertoire ANSM des biosimilaires** : liste officielle des médicaments biologiques similaires autorisés en France, avec statut (biosimilaire vs originator) par spécialité — téléchargeable sur le site ANSM, mis à jour régulièrement
- **Arrêté CAQES** : annexe listant les molécules biologiques éligibles à substitution biosimilaire et les cibles contractuelles — transmis par l'ARS avec le contrat CAQES de l'établissement
- **Base Claude / THÉRIAQUE** : correspondance UCD → DCI → code ATC → statut biosimilaire — ressource pharmacologique de référence pour construire la table de classification des UCD

## Exemple de Valeurs

- **Adalimumab (Humira® et biosimilaires) — CHU rhumatologie** : Taux_biosim = 78% (cible CAQES 85%) ; Gap_économique = 45 000€/an
- **Infliximab (Remicade® et biosimilaires) — CH gastroentérologie** : Taux_biosim = 92% (cible CAQES 90%) — conforme
- **Filgrastim / G-CSF — Onco-hématologie** : Taux_biosim = 88% (cible CAQES 90%) — proche de la cible
- **Score composite CAQES biosimilaires — CHU polyvalent** : 82% (80% de la valeur des UCD éligibles dispensée en biosimilaire)
- **Gain économique potentiel médian** : 200 000–800 000€/an pour un CHU avec activité oncologique et rhumatologique significative si toutes les cibles CAQES biosimilaires sont atteintes
- **Seuil d'alerte** : Taux_biosim_m < 50% pour une molécule avec > 100 UCD dispensées/an ET cible CAQES ≥ 80% → action pharmaceutique et médicale urgente

## Limites

- **Contre-indications médicales à la substitution** : certains patients ne peuvent pas être substitués (immunisation anti-originator, pathologies spécifiques) — la non-atteinte des cibles peut être partiellement justifiée médicalement mais n'est pas identifiable depuis le FICHCOMP seul ; une validation clinique est nécessaire avant toute conclusion
- **Ruptures d'approvisionnement biosimilaires** : les biosimilaires subissent régulièrement des ruptures de stock, forçant le recours temporaire à l'originator — le taux peut baisser sans défaillance de la politique de substitution ; documenter les périodes de rupture dans le rapport
- **Hétérogénéité des prix biosimilaires** : le prix des biosimilaires varie selon les marchés (appel d'offres national, régional, local) ; le Gap_économique calculé sur la base des prix de référence CNAM peut surestimer ou sous-estimer les gains réels selon le marché local
- **Liste CAQES révisée annuellement** : les molécules éligibles et les cibles contractuelles changent par arrêté — les comparaisons longitudinales nécessitent de vérifier si le périmètre a évolué avant d'interpréter une variation du Score composite
- **FICHCOMP partiel pour les dispensations hors séjour** : les biosimilaires prescrits en consultation externe ou en HAD peuvent ne pas être tracés dans le FICHCOMP MCO — le taux calculé depuis le FICHCOMP MCO ne reflète que les dispensations intra-séjours MCO

## Références

- [DGOS/CNAM — Arrêté relatif au CAQES et à ses annexes : liste des molécules éligibles biosimilaires et cibles contractuelles](https://solidarites.gouv.fr/)
- [ANSM — Répertoire des médicaments biologiques similaires autorisés en France](https://www.ansm.sante.fr/)
- [EMA — Guideline on similar biological medicinal products : cadre réglementaire européen de l'autorisation des biosimilaires](https://www.ema.europa.eu/)
- [HAS — Recommandations sur la substitution des médicaments biologiques par des biosimilaires](https://www.has-sante.fr/)
- [Danese S. et al. — Biosimilars in inflammatory bowel disease: a practical guide, Nature Reviews Gastroenterology 2017](https://doi.org/10.1038/nrgastro.2017.40)
- [ATIH — Suivi des médicaments de la liste en sus : rapports annuels incluant les biosimilaires](https://www.atih.sante.fr/)
