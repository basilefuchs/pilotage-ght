# Taux de Traçabilité RCP pour les Séjours de Cancer

## Définition

La **Réunion de Concertation Pluridisciplinaire (RCP)** est une obligation réglementaire du Plan Cancer (DGOS/INCa) : tout patient atteint d'un cancer doit bénéficier d'une discussion de son dossier en RCP avant le démarrage du traitement. Cette obligation, inscrite dans la circulaire DHOS du 22 février 2005 relative à l'organisation des soins en cancérologie et réaffirmée dans les Plans Cancer successifs (2014-2019 et 2021-2030), vise à garantir que la décision thérapeutique est issue d'une délibération collégiale pluridisciplinaire.

Le taux de traçabilité RCP mesure la proportion de séjours MCO dont le diagnostic principal est un cancer (CIM-10 C*) pour lesquels au moins un acte de concertation pluridisciplinaire est codé dans les actes CCAM du séjour :

```
Taux_RCP = nb_RSA | DP ∈ CIM-10 C* ET ≥1 acte_CCAM_RCP
           ──────────────────────────────────────────────  × 100
           nb_RSA | DP ∈ CIM-10 C*
```

L'acte CCAM de référence pour la RCP est le **YYYY001** («Concertation pluridisciplinaire pour la prise en charge d'un patient atteint d'un cancer»), codable en CCAM dans le PMSI MCO lorsque la RCP a lieu pendant ou en lien avec le séjour d'hospitalisation.

Cet indicateur est distinct du `delai_diagnostic_traitement_cancer` (qui mesure le délai entre diagnostic et traitement) et du `taux_sejours_chirurgicaux_cancer` (qui mesure la proportion de cancers pris en charge chirurgicalement). Il mesure la **conformité procédurale au parcours cancer DGOS** — la collégialité de la décision thérapeutique —, non les délais ni les résultats.

Il reconnaît une limite structurelle importante : de nombreuses RCP se tiennent **avant l'hospitalisation** (RCP pré-thérapeutique en consultation externe) et ne génèrent pas d'acte CCAM dans le RSA de l'hospitalisation. Le taux calculé depuis le PMSI MCO est donc un **taux de traçabilité intra-séjour** qui sous-estime le taux de conformité réelle à l'obligation RCP.

## Calcul

Sources : PMSI MCO RSA + actes CCAM codés dans le RSA.

```
Population : tous RSA MCO pour un FINESS/période dont le DP est un cancer (CIM-10 C*)

Étape 1 — Identification des séjours de cancer :
  RSA_cancer = {RSA | substr(DP_CIM10, 1, 1) = 'C'}
    → Codes CIM-10 C00 à C97 (tumeurs malignes)
    → Inclure ou non les codes D00–D09 (carcinomes in situ) selon le périmètre retenu
       (recommandé : inclure les D0* pour les cancers débutants tracés en RCP)
    → Exclure si souhaité : C44 (carcinome basocellulaire/spinocellulaire cutané)
       si l'établissement ne réunit pas de RCP pour ces cancers

  nb_RSA_cancer = count(RSA_cancer)
  Seuil minimal : nb_RSA_cancer ≥ 50 sur la période pour une interprétation fiable

Étape 2 — Identification de l'acte CCAM RCP dans les RSA :
  Acte CCAM RCP de référence : YYYY001
    «Concertation pluri-professionnelle pour la prise en charge d'un patient
     atteint de cancer, pour le choix et l'organisation du traitement»

  RSA_avec_RCP = {RSA ∈ RSA_cancer | YYYY001 ∈ liste_actes_CCAM_du_RSA}
    → Le RSA contient jusqu'à ~20 actes CCAM codés ; vérifier la présence de YYYY001
      dans la liste des actes CCAM du séjour (tableau des actes du RSA)

  nb_RSA_avec_RCP = count(RSA_avec_RCP)

Étape 3 — Calcul du taux de traçabilité RCP :
  Taux_RCP = nb_RSA_avec_RCP / nb_RSA_cancer × 100   [en %]

Étape 4 — Ventilation par localisation cancéreuse (CMD/CIM-10) :
  Taux_RCP_sein       = RSA_avec_RCP | DP ∈ C50 / RSA_cancer | DP ∈ C50
  Taux_RCP_colorectal = RSA_avec_RCP | DP ∈ {C18,C19,C20} / RSA | DP ∈ {C18,C19,C20}
  Taux_RCP_poumon     = RSA_avec_RCP | DP ∈ C34 / RSA | DP ∈ C34
  Taux_RCP_prostate   = RSA_avec_RCP | DP ∈ C61 / RSA | DP ∈ C61
  [idem pour les 5-10 localisations les plus fréquentes dans l'établissement]

Étape 5 — Identification des séjours sans RCP tracée (pour audit) :
  RSA_cancer_sans_RCP = RSA_cancer \ RSA_avec_RCP
  → liste exportable par service/UM pour audit ciblé de la traçabilité
  → croiser avec `modeentree` pour distinguer :
    - Entrées urgentes (`modeentree` = 8 et `provenance` = 5) : RCP peut légitimement être différée
    - Hospitalisations programmées (`modeentree` = 6,7) : RCP préalable attendue

Cas limites :
  - Acte YYYY001 absent mais RCP tenue : sous-codage — identifiable par audits dossiers
    → le taux PMSI est toujours une sous-estimation du taux réel
  - Séjours de chimiothérapie (séances, CMD 28) : la RCP est habituellement tenue
    avant le premier cycle, non répétée à chaque séance ; exclure les séances du
    dénominateur (ne compter que les séjours de diagnostic/bilan/chirurgie cancer)
  - RSA multi-DP : si le DP est un cancer mais que le motif principal d'hospitalisation
    est une complication (sepsis, embolie...), la RCP peut ne pas être retracée dans ce RSA ;
    envisager d'inclure DR ∈ C* si le DP est une complication d'un cancer connu
```

Indicateurs dérivés :

```
Taux de non-traçabilité RCP par mode d'entrée :
  = RSA_cancer_sans_RCP | `modeentree` = 6 (programmé) / RSA_cancer_programmé × 100
  → Les entrées programmées sans RCP sont le signal le plus alarmant
    (entrée urgente sans RCP = plus acceptable cliniquement)

Taux RCP par UM (unité médicale) :
  → localise les services où la traçabilité est la plus faible
  → permet un dialogue ciblé avec les équipes médicales de chaque spécialité

Délai médian RCP → hospitalisation :
  → Si la date d'acte CCAM YYYY001 est disponible dans le RSA : calculer l'écart
    DATE_RCP (date acte YYYY001) − DATE_ENTREE
  Valeur négative : RCP tenue avant hospitalisation (idéale)
  Valeur ≥ 0 : RCP tenue pendant l'hospitalisation (acceptable pour urgences)
```

## Utilité

- **Conformité aux obligations réglementaires Plan Cancer DGOS/INCa** : la traçabilité de la RCP est auditée par les Agences Régionales de Santé dans le cadre des autorisations de traitement du cancer (autorisation d'activité de soins en cancérologie) — un taux < 80% est un signal de non-conformité susceptible d'affecter le renouvellement de l'autorisation
- **Pilotage de la qualité du parcours cancer par localisation** : comparer les Taux_RCP par localisation cancéreuse révèle les spécialités où la traçabilité est insuffisante — un taux à 95% en chirurgie du sein mais à 55% en oncologie digestive dans le même établissement signale une hétérogénéité de pratiques à corriger
- **Audit de sous-codage CCAM** : un établissement avec activité de cancérologie connue (nombreux RSA C*) mais Taux_RCP < 40% est très probablement confronté à un sous-codage de l'acte YYYY001 — des RCP sont tenues mais non codées dans le RSA ; cet audit est moins coûteux et plus ciblé que la revue exhaustive des dossiers
- **Benchmark intra-GHT en cancérologie** : si le GHT dispose d'un réseau de cancérologie inter-établissements, comparer les Taux_RCP entre sites permet d'identifier les établissements où la participation aux RCP du réseau est à renforcer
- **Évaluation de l'impact des réorganisations RCP** : mesurer le Taux_RCP avant et après une réorganisation (visioconférence pour les RCP multi-sites, outil de traçabilité RCP connecté au SIH, nouvelle secrétaire médicale dédiée) pour objectiver l'impact sur la traçabilité
- **Identification des séjours urgents de cancer sans RCP différée** : les RSA_cancer_sans_RCP avec `modeentree` urgent permettent de cibler les patients pour lesquels la RCP doit être organisée rapidement en post-hospitalisation — liste nominative exportable pour le médecin coordinateur de parcours

## Sources de Données

- **PMSI MCO RSA** : variable `DP` (diagnostic principal CIM-10, filtrer sur C*), `DR` (diagnostic relié), liste des actes CCAM codés dans le séjour (champ CCAM du RSA, jusqu'à 20 actes), `modeentree`, `NOFINESS`, `DATE_ENTREE`, `CODE_UM`
- **Référentiel CCAM ATIH** : libellé de l'acte YYYY001 et ses éventuels actes complémentaires de RCP — vérifier la version CCAM en vigueur pour les codes exacts de concertation pluridisciplinaire
- **Référentiel CIM-10 FR** : liste des codes C00–C97 (tumeurs malignes), D00–D09 (carcinomes in situ) — disponible sur le site de l'ATIH ou dans les référentiels OMS

## Exemple de Valeurs

- **CHU avec CLCC partenaire** : Taux_RCP_global = 72% — sous-estimation liée aux RCP pré-admission non tracées dans le RSA ; Taux_RCP_sein = 88% ; Taux_RCP_poumon = 65%
- **CH avec unité de cancérologie** : Taux_RCP_global = 55% — fort taux de sous-codage identifié à l'audit (RCP tenues à 85% mais codage YYYY001 à 55%)
- **Clinique chirurgicale privée** : Taux_RCP_global = 82% — séjours programmés dominants, bonne traçabilité
- **Seuil INCa de vigilance** : Taux_RCP < 75% sur les 5 localisations principales → audit obligatoire des dossiers + plan d'amélioration du codage
- **Cible Plan Cancer 2021-2030** : 100% des patients atteints de cancer présentés en RCP avant traitement — le Taux_RCP PMSI mesure la traçabilité, pas le taux réel (toujours inférieur au taux réel)
- **Séjours urgents sans RCP** : un Taux_RCP < 30% sur les entrées programmées (`modeentree` ∈ {6,7}) est un signal sérieux de défaut de coordination pré-hospitalisation

## Limites

- **Sous-estimation structurelle** : la limite principale et irréductible de cet indicateur est que les RCP tenues avant hospitalisation (en consultation externe, par visioconférence du réseau de cancérologie) ne génèrent pas d'acte CCAM dans le RSA MCO — le Taux_RCP PMSI est donc **toujours inférieur au taux de conformité réelle** ; il mesure la traçabilité, pas l'observance
- **Sous-codage CCAM fréquent** : l'acte YYYY001 est régulièrement non codé par les équipes médicales et les TIM, même lorsque la RCP a été effectivement tenue ; une part significative des «non-RCP» PMSI correspond à des RCP non tracées — avant toute conclusion sur la non-conformité, mener un audit sur un échantillon de dossiers
- **Définition du périmètre cancer** : l'inclusion ou l'exclusion des codes D0* (carcinomes in situ), C44 (cancers cutanés), et des cancers secondaires (C77-C79) impacte fortement le dénominateur — documenter le périmètre retenu et l'appliquer de manière constante dans le temps
- **Séjours de chimiothérapie et séances** : les séances de chimiothérapie (CMD 28) ont un DP cancer mais la RCP n'est pas attendue à chaque séance — les exclure du dénominateur est impératif pour ne pas fausser le taux à la baisse sur les établissements à forte activité de séances
- **Version CCAM** : le code YYYY001 est l'acte de référence actuel ; vérifier qu'il n'a pas été remplacé ou précisé dans la dernière version CCAM — les changements de codification CCAM peuvent créer des ruptures de série dans le suivi longitudinal

## Références

- [INCa / DGOS — Plan Cancer 2021-2030 : mesure 4.1, obligation de RCP pour tout patient atteint de cancer](https://www.e-cancer.fr/)
- [Circulaire DHOS/SDO n°2005-101 du 22 février 2005 relative à l'organisation des soins en cancérologie : définition et obligation de la RCP](https://solidarites.gouv.fr/)
- [INCa — Référentiel organisationnel des Réunions de Concertation Pluridisciplinaire en cancérologie](https://www.e-cancer.fr/)
- [ATIH — Classification CCAM, acte YYYY001 : concertation pluridisciplinaire pour patient atteint de cancer](https://www.atih.sante.fr/)
- [Lamb B.W. et al. — Multidisciplinary team working across different tumour types: analysis of a prospective database, Annals of Surgery 2012 : impact des RCP sur la qualité des décisions thérapeutiques en cancérologie](https://doi.org/10.1093/annonc/mdr453)
