# Taux d'Activité Programmée les Jours Non Ouvrés

## Définition

Le taux d'activité programmée les jours non ouvrés (TAJNO) mesure la part des séjours en hospitalisation complète (HC) programmés dont la **date d'entrée tombe un samedi, un dimanche ou un jour férié**, parmi l'ensemble des séjours HC programmés de la période. Il capture la **structure temporelle de l'activité programmée**, information absente des indicateurs de volume (`nombre_sejours`, `activite_mco`) ou de mode de prise en charge (`taux_ambulatoire`) qui agrègent sans distinguer les jours d'admission.

TAJNO = N_prog_HC(date_entree ∈ JNO) / N_prog_HC

où :
- N_prog_HC : séjours HC programmés (durée ≥ 1 nuit, admission non issue des urgences — voir Calcul)
- JNO : ensemble des jours non ouvrés = {samedi} ∪ {dimanche} ∪ {jours fériés légaux}
- Jours fériés légaux en France (11/an) : 1ᵉʳ janvier, Lundi de Pâques, 1ᵉʳ mai, 8 mai, Jeudi de l'Ascension, Lundi de Pentecôte, 14 juillet, 15 août, 1ᵉʳ novembre, 11 novembre, 25 décembre

La différence fondamentale avec le `taux_activite_non_programmee` est que ce dernier mesure **quel type d'activité** entre dans l'hôpital (urgente vs programmée), alors que le TAJNO mesure **quand** l'activité programmée entre, révélant ainsi des choix d'organisation ou des contraintes capacitaires. Un TAJNO élevé peut signaler deux réalités opposées qu'il faut distinguer : (1) une **extension délibérée de la semaine opératoire** (utilisation optimale des capacités installées, objectif soutenu par l'ANAP) ou (2) un **pré-admission hôtelier** (patient admis le samedi pour libérer le chirurgien le lundi matin, consommation de lits à faible valeur ajoutée). Le croisement avec les données bloc opératoire (actes CCAM le jour d'entrée ou J+1) permet de distinguer ces deux cas.

## Calcul

Source : PMSI MCO RSS (interne) — variables `DATE_ENTREE` (date complète, jour+mois+année), `MODE_ENTREE`, `PROVENANCE`, `DUREE`, GHM, FINESS.

**Contrainte d'accès** : la date d'entrée complète (avec le jour) est disponible dans les RSS internes à l'établissement. Les extraits anonymisés nationaux (RSA publics) ne contiennent que le mois et l'année — cet indicateur n'est donc pas calculable directement sur ScanSanté mais est pleinement exploitable dans le système d'information hospitalier.

```
Population : séjours MCO HC (DUREE ≥ 1) sur la période d'analyse

Étape 1 — Identification des séjours HC programmés :
  prog = séjour n'étant PAS issu des urgences
  Définition opérationnelle (cohérente avec taux_activite_non_programmee) :
    prog = TRUE si NOT (mode_entree = '8' AND provenance IN ('4','5'))
    prog = TRUE si mode_entree IN ('6','7')     -- mutations/transferts (programmés par défaut)
    -- Exclure séances (GHM de type 'Z' pour dialyse/chimio si hors périmètre)
    -- Exclure séjours ambulatoires (DUREE = 0)

Étape 2 — Identification des jours non ouvrés :
  jour_semaine = dayofweek(DATE_ENTREE)          -- lundi=1 ... dimanche=7
  jno_weekend  = (jour_semaine IN (6, 7))         -- samedi=6, dimanche=7
  jno_ferie    = (DATE_ENTREE IN calendrier_feries_annee)
  -- Calendrier jours fériés : à charger par année (fériés mobiles calculables
  --   par algorithme de Butcher/Meeus pour Pâques ; Ascension = Pâques+39j ;
  --   Pentecôte = Pâques+50j)
  jno = (jno_weekend OR jno_ferie)

Étape 3 — Calcul du TAJNO par (FINESS, service/CMD, période) :
  N_prog_HC       = count(séjours WHERE prog = TRUE)
  N_prog_HC_JNO   = count(séjours WHERE prog = TRUE AND jno = TRUE)
  TAJNO           = N_prog_HC_JNO / N_prog_HC
  Convention      : si N_prog_HC < 50 → TAJNO = NA (volume insuffisant)

Étape 4 — Décomposition samedi / dimanche / férié :
  TAJNO_sam  = N_prog_HC(jour=sam) / N_prog_HC
  TAJNO_dim  = N_prog_HC(jour=dim) / N_prog_HC
  TAJNO_fer  = N_prog_HC(jour=ferie) / N_prog_HC
  -- Les entrées du dimanche sont le signal le plus fort d'admission hôtelière
  --   (quasi-absence de blocs opératoires le dimanche → valeur médicale quasi nulle)
```

Indicateurs dérivés :

```
Taux d'activité opératoire le jour d'entrée JNO :
  TAJNO_op = N_prog_HC_JNO avec acte CCAM opératoire le jour DATE_ENTREE /
             N_prog_HC_JNO
  -- TAJNO_op élevé = extension semaine opératoire (positif)
  -- TAJNO_op faible = pré-admission hôtelière (à réduire)

Délai entrée-premier acte chirurgical pour entrées JNO :
  delta_op_JNO = median(DATE_ACTE_CCAM - DATE_ENTREE) pour séjours JNO chirurgicaux
  -- delta > 1 jour = patient admis à l'avance (hôtelier)

TAJNO par service (UM) :
  → Identifier les services systématiquement élevés en TAJNO dimanche
    (signal d'organisation à revoir vs services en semaine opératoire étendue)
```

## Utilité

- **Quantifier le gisement de lits libérables par réduction des pré-admissions hôtelières** : un TAJNO_dim de 8 % dans un service de chirurgie orthopédique de 30 lits représente ~2,4 lits occupés le dimanche sans activité opératoire le jour J — convertis sur l'année, c'est ~870 journées-lits consommées sans valeur ajoutée médicale directe, argument tangible pour réviser les protocoles d'admission
- **Évaluer l'effectivité de la semaine opératoire étendue** : après mise en place d'une semaine opératoire du samedi, le TAJNO_op_sam permet de vérifier que les entrées du samedi génèrent bien des actes opératoires le jour même — distinguer l'extension réussie de l'effet d'annonce sans changement de pratique
- **Comparer les organisations intra-GHT** : dans un GHT avec plusieurs sites chirurgicaux, des TAJNO_dim très hétérogènes entre établissements de même spécialité signalent des protocoles d'admission divergents — standardiser les pratiques autour du site le plus efficient
- **Détecter les tensions capacitaires en semaine** : un TAJNO élevé peut être un signal de saturation des créneaux d'admission en semaine, forçant les services à anticiper les entrées sur le weekend pour sécuriser les plannings — le croisement avec le taux d'occupation et l'IP-DMS contextualise ce signal
- **Optimiser la charge soignante du weekend** : un TAJNO élevé mais sans activité opératoire génère une charge soignante (accueil, bilan d'entrée) sans la contrepartie de soins techniques — argument RH pour concentrer les entrées sur la semaine et réduire le travail du weekend
- **Argument pour les négociations de CAQES et de contrats de retour à l'équilibre** : le stock de journées hôtelières JNO, valorisé en coût de journée standard, permet de chiffrer des gains d'efficience réalistes dans les dialogues de performance avec l'ARS

## Sources de Données

- **PMSI MCO RSS (extraction interne)** : champs `DATE_ENTREE` (date complète J/M/A), `MODE_ENTREE`, `PROVENANCE`, `DUREE`, `GHM` (6 caractères), `FINESS`, `UM` — l'accès à la date complète avec le jour est indispensable et disponible uniquement dans les extractions internes (non disponible dans les RSA anonymisés publics ATIH)
- **Calendrier des jours fériés légaux français** : à construire par année (11 jours fixes ou mobiles) — l'algorithme de calcul de Pâques (méthode de Meeus/Jones/Butcher) est disponible dans tous les langages de traitement de données ; intégrer une table de référence par année de 2015 à N+1
- **Données bloc opératoire (optionnel)** : actes CCAM opératoires du PMSI MCO (champ `CCAM` du RSA) avec date de réalisation, pour calculer le TAJNO_op et détecter les pré-admissions hôtelières — disponible dans le fichier RSA avec date d'acte selon le format d'extraction

## Exemple de Valeurs

Ordres de grandeur observés en chirurgie programmée MCO française :

| Contexte | TAJNO global | TAJNO samedi | TAJNO dimanche |
|---|---|---|---|
| Chirurgie orthopédique élective (CH général) | 12–18 % | 9–14 % | 2–5 % |
| Chirurgie digestive programmée | 10–15 % | 8–12 % | 1–4 % |
| Médecine interne / polyvalente | 18–28 % | 10–16 % | 6–12 % |
| Service ayant instauré semaine opératoire sam. | 20–30 % | 18–28 % | 1–3 % |
| Obstétrique (programmée : déclenchements) | 15–22 % | 8–14 % | 5–10 % |

Seuils d'alerte opérationnels :
- **TAJNO_dim > 5 %** en chirurgie programmée (hors urgences codées) : investiguer la proportion de pré-admissions hôtelières (délai entrée → acte > 1 jour)
- **TAJNO_op_sam < 40 %** malgré un TAJNO_sam > 15 % : la semaine opératoire du samedi est annoncée mais les entrées du samedi ne génèrent pas d'actes le jour même — revoir le protocole
- **TAJNO > 25 %** en médecine non urgente : signal d'une pression en semaine qui déborde sur le weekend, à croiser avec le taux d'occupation hebdomadaire

## Limites

- **Accès à la date complète** : cet indicateur n'est calculable que depuis les RSS internes à l'établissement — les RSA publics ATIH ne contenant que le mois et l'année, toute comparaison nationale directe est impossible ; le benchmarking inter-établissements nécessite un accord de partage de données ou passe par un tiers de confiance (ARS, GRADeS)
- **Ambiguïté du codage mode_entree** : certains établissements codent les admissions directes en urgence (hors service d'urgences déclaré) avec des codes différents de la convention standard — un TAJNO anormalement bas peut résulter d'une pratique de codage du mode_entree qui masque des admissions non programmées dans le dénominateur
- **Effet des rotations de garde et protocoles locaux** : un service qui impose par protocole l'admission la veille d'une intervention pour bilan préopératoire génère structurellement un TAJNO_dim élevé sans dysfonctionnement réel — l'interprétation doit intégrer les protocoles d'admission du service
- **Non calculable en ambulatoire** : les séjours ambulatoires (DUREE = 0), par définition, débutent et se terminent dans la même journée — le TAJNO sur l'ambulatoire n'aurait de sens que pour mesurer l'extension de la chirurgie ambulatoire au weekend, ce qui constitue un indicateur distinct
- **Jours fériés en semaine** : un jour férié tombant un lundi ou un vendredi réduit mécaniquement le dénominateur des séjours programmés (moins d'entrées cette semaine) et peut augmenter le TAJNO apparent — contrôler par le nombre de JNO effectifs dans la période d'analyse (les périodes comportant 5 fériés en semaine vs 0 ne sont pas comparables)

## Références

- [Litvak E., Long M.C. — Cost and quality under managed care: irreconcilable differences?, American Journal of Managed Care 2000 : fondements de la variabilité contrôlée vs non-contrôlée dans les flux hospitaliers](https://pubmed.ncbi.nlm.nih.gov/11067378/)
- [ANAP — Semaine opératoire étendue : guide méthodologique de déploiement, 2018 : indicateurs de suivi de l'extension de la semaine chirurgicale au samedi](https://www.anap.fr/)
- [Aylin P. et al. — Weekend mortality for emergency admissions, BMJ 2010 : contexte du weekend effect — montre que les admissions programmées le weekend ont un profil radicalement différent des urgences](https://doi.org/10.1136/bmj.c4396)
- [HAS — Référentiel de certification des établissements de santé V2020 : critères d'organisation de la prise en charge programmée et utilisation des capacités](https://www.has-sante.fr/)
- [DGOS — Instruction relative à la chirurgie ambulatoire et à l'optimisation capacitaire, 2019 : objectifs de réduction des admissions hôtelières et d'extension de semaine opératoire](https://solidarites-sante.gouv.fr/)
- [Meeus J.-M. — Astronomical Algorithms, 1991 : algorithme de calcul des dates de Pâques et fêtes mobiles (méthode de Butcher-Meeus), référence pour la construction du calendrier des jours fériés]
