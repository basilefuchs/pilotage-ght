# Taux Ajusté de Mortalité Intra-hospitalière à 30 Jours après AVC Ischémique (I63)

## Définition
Le **taux ajusté de mortalité à 30 jours après accident vasculaire cérébral ischémique** (CIM-10 I63) est un **indicateur OCDE HCQO acute care** suivant la qualité de la prise en charge en phase aiguë de l'AVC ischémique. La méthodologie OCDE recommande **explicitement de distinguer** l'AVC ischémique (I63 — ~80 % des AVC) de l'AVC hémorragique (I61 — ~15-20 % des AVC), car les filières de prise en charge, les pronostics et les leviers d'amélioration diffèrent fondamentalement (fibrinolyse / thrombectomie pour ischémique, neurochirurgie / réanimation pour hémorragique).

Formule :

```
Taux Mortalité_30j_AVCi = (décès intra-hospitaliers ≤30j post-admission AVC I63)
                          / (RSA admis pour AVC ischémique I63 en DP)
                          × 100

Taux ajusté = ratio_observé / ratio_attendu
              avec attendu calculé par modèle logistique :
                     âge × sexe × Charlson × type d'AVC × mode d'entrée
```

Positionnement vs indicateurs existants : version **plus spécifique** de `ocde_mortalite_30j_ami_avc.md` (qui agrège AMI + AVC). Cet indicateur cible exclusivement l'AVC ischémique, conformément à la nouvelle recommandation OCDE 2025 de désagrégation. Complémentaire de `delai_porte_aiguille_avc.md` (délai fibrinolyse) qui mesure le **processus** alors que la mortalité mesure le **résultat**.

## Calcul

```
Étape 1 — Population cible
  RSA avec :
    a) DP = I63 (infarctus cérébral, AVC ischémique)
       Sous-codes : I63.0–I63.9 inclus
       Exclus : I61 (hémorragie intracérébrale), I60 (HSA),
                I62 (autres hémorragies), I64 (AVC non précisé)
    b) Âge ≥ 18 ans (ou selon spec OCDE : tous âges, à préciser)
    c) Mode d'entrée ≠ 7 (transfert entrant) pour éviter double comptage
    d) Premier séjour AVC du patient dans la période (chaînage anti-doublon)

Étape 2 — Détection du décès à 30 jours
  Méthode 1 — Mortalité intra-hospitalière (OCDE classique) :
    Décès durant le séjour index avec MODE_SORTIE = 9
  Méthode 2 — Mortalité 30j post-admission (OCDE actualisée 2025) :
    Décès dans les 30 jours suivant la date d'admission, qu'il soit
    intra-hospitalier ou post-sortie (nécessite chaînage SNDS pour
    inclure les décès post-sortie)

Étape 3 — Calcul brut
  N = patients cible décédés à 30j
  D = patients cible
  Taux brut = N / D × 100

Étape 4 — Ajustement (méthode OCDE par standardisation indirecte)
  Modèle logistique (régression sur l'ensemble France) :
    log(odds_décès) = β0 + β1·âge + β2·sexe + β3·Charlson
                       + β4·type_admission + β5·sévérité_proxy
  Pour chaque établissement :
    Décès_attendus = Σ_patients prob_estimée(patient_i)
    Ratio standardisé = N_observé / N_attendu
  Restitution : ratio + IC 95% (Byar)

Étape 5 — Stratifications
  - Par âge (< 65, 65-74, 75-84, ≥ 85)
  - Par sexe
  - Par UNV (Unité Neurovasculaire) vs hors UNV
  - Par établissement / GHT
```

Variables PMSI clés : `DP`, `DR`, `DA`, `MODE_ENTREE`, `MODE_SORTIE`, `AGE_ANNEES`, `SEXE`, `DATE_ENTREE`, `DATE_SORTIE`, `N°ANONYME`. Pour version 30j post-admission : chaînage avec données de mortalité SNDS (table BENEFICIAIRE, `BEN_DCD_DTE`).

## Utilité
- **Pilotage filière neurovasculaire GHT** : positionnement comparatif pour les UNV et les établissements participant à la filière AVC.
- **Comparaison internationale OCDE** : indicateur standardisé Health at a Glance 2025, lecture européenne directe.
- **Évaluation de l'impact UNV** : différentiel de mortalité entre patients pris en charge en UNV vs hors UNV (cible filière SFNV).
- **Suivi du Plan AVC** : indicateur clé du Plan national d'action AVC (mortalité, autonomie, accès UNV).
- **Articulation avec le délai de fibrinolyse** : couplage avec `delai_porte_aiguille_avc.md` pour vérifier l'effet processus → résultat.
- **Justification d'investissements** : argumentaire pour télémédecine de l'AVC (téléthrombolyse), équipement IRM h24, équipes dédiées.
- **Mortalité ajustée** : protection contre les biais de case-mix, comparaisons inter-établissements valides.
- **Détection d'établissements en alerte** : ratio standardisé > 1,2 avec IC 95% > 1,0 → revue de pratiques.

## Sources de Données
- **PMSI MCO** : RSA avec DP I63, dates d'entrée/sortie, mode de sortie.
- **SNDS** : chaînage avec table mortalité INSEE (`DC` ou `DCD_DTE`) pour mortalité 30j post-sortie.
- **Référentiel CIM-10 FR** : codes I63 (versus I61, I60, I62, I64).
- **OCDE Health at a Glance 2025** : référence méthodologique et benchmark.
- **OCDE HCQO Definitions** : spécifications du numérateur, dénominateur, ajustements.
- **HAS — Indicateurs mortalité hospitalière** : transposition française.
- **SFNV (Société Française Neurovasculaire)** : recommandations de structuration des UNV.

## Exemple de Valeurs
*Sources : OCDE Health at a Glance 2023, OCDE Health at a Glance 2025, HAS rapport mortalité hospitalière 2017.*

- **Taux mortalité intra-hospitalière 30j AVC ischémique France** : ~7-9 % (vs ~12-15 % AVC hémorragique).
- **Moyenne OCDE** : ~7,5 %.
- **Pays nordiques (Norvège, Suède)** : 5-6 % (filière UNV très développée).
- **Pays sud-OCDE** : 8-10 %.
- **France 2010** : ~9-10 % ; **France 2020-2023** : ~7-8 % (effet UNV + télé-AVC).
- **Plage par établissement (ratio standardisé)** : 0,7 – 1,3.
- **Seuil d'alerte** : ratio > 1,2 avec IC 95% > 1,0.
- **Différentiel UNV vs hors UNV** : -3 à -5 pts de mortalité absolue (effet majeur, cible 100 % UNV).
- **Volume cible minimal** : ≥ 100 AVC ischémiques/an pour stabilité statistique.

## Limites
- **Codage I63 vs I64** : I64 (AVC non précisé) est un code « refuge » fréquent en l'absence d'imagerie ; sa présence en DP biaise le dénominateur.
- **Sévérité initiale non capturée** : NIHSS (échelle de gravité AVC) absent du PMSI ; les CHU recevant les AVC graves (transferts pour thrombectomie) peuvent voir leur ratio standardisé biaisé.
- **Mortalité intra-hospitalière vs 30j post-admission** : la méthodologie OCDE évolue vers la 30j post-admission (incluant décès post-sortie), nécessitant SNDS.
- **Transferts secondaires** : les transferts vers le CHU thrombectomie créent des doublons à exclure.
- **Sous-typage I63** : I63.x distingue cardio-embolique, athérothrombotique, lacunaire, etc. ; rarement utilisé en pratique de codage français → ajustement par sous-type difficile.
- **Décès vs séquelles graves** : la mortalité à 30j ne capture pas l'aspect autonomie / Rankin score, qui est l'autre dimension clé de la qualité AVC.
- **Volume minimal** : un CH périphérique avec < 50 AVC/an a un IC 95% trop large pour comparaison fiable.
- **Effet de case-mix résiduel** : malgré l'ajustement Charlson, des spécificités (FA, démence) peuvent persister.

## Références
- [OCDE — Health at a Glance 2025](https://www.oecd.org/en/publications/health-at-a-glance-2025_8f9e3f98-en.html)
- [OCDE — Health at a Glance 2025 — Quality and outcomes of care](https://www.oecd.org/en/publications/2025/11/health-at-a-glance-2025_a894f72e/full-report/component-41.html)
- [OCDE — HCQO Definitions](https://www.oecd.org/content/dam/oecd/en/topics/policy-sub-issues/measuring-health-care-quality/definitions-of-health-care-quality-outcomes.pdf)
- [OCDE — Health at a Glance 2023](https://www.oecd.org/en/publications/2023/11/health-at-a-glance-2023_e04f8239/full-report.html)
- [HAS — IQSS 2017 Rapport « Indicateurs de mortalité hospitalière »](https://www.has-sante.fr/jcms/c_2800716/fr/)
- SFNV — Société Française Neurovasculaire — Recommandations UNV.
- Plan national AVC — Ministère de la Santé.
