# Taux de Césariennes — Classification de Robson Groupe 1

## Définition
La **classification de Robson** (Robson, 2001) est la classification de référence recommandée par l'OMS et la HAS pour analyser les taux de césariennes de manière comparable entre maternités. Elle répartit toutes les parturientes en **10 groupes mutuellement exclusifs** définis par 5 caractéristiques obstétricales objectives : parité, antécédent de césarienne, début du travail (spontané, induit, programmé), nombre de fœtus, présentation, terme.

Le **groupe 1 de Robson** cible la population de référence la plus discriminante pour évaluer les pratiques d'une maternité : **nullipare, grossesse unique, fœtus en présentation céphalique, terme ≥ 37 semaines, travail spontané**. Le taux de césariennes dans ce groupe est l'indicateur le plus utilisé dans la littérature pour comparer les pratiques entre établissements car la population est homogène et le recours à la césarienne y est le plus directement attribuable aux décisions cliniques.

Formule :

```
Taux Robson G1 = (séjours d'accouchement Robson G1 avec césarienne)
                 / (séjours d'accouchement Robson G1)
```

Positionnement vs indicateurs existants : le taux global de césariennes (~21 % France) est confondu par la composition de population (CHU = haut risque, niveau III). Robson G1 normalise ce biais et permet une comparaison directe inter-établissements.

## Calcul

```
Étape 1 — Identifier les séjours d'accouchement
  RUM/RSA avec :
    - DP ou DR : O80–O84 (accouchement) OU Z37.x (résultat de l'accouchement)
    - OU acte CCAM JQGD (accouchement par voie basse) ou JQGA (césarienne)

Étape 2 — Identifier le groupe Robson 1 (proxy PMSI)
  Critères cumulatifs :
    a) Nullipare : codes CCAM avec extension de parité « -11 » (primipare)
       (JQGA002-11, JQGA003-11, JQGD002-11 etc., extensions PMSI 2019+)
    b) Grossesse unique : Z37.0 (enfant unique né vivant) OU Z37.1 (mort-né unique)
    c) Présentation céphalique : absence de O32.1 (siège), O32.2 (transverse), etc.
    d) Terme ≥ 37 SA : O80.x, O81.x, O82.x ; exclusion O60.x (prématurité)
    e) Travail spontané : exclusion O61.x (échec déclenchement), exclusion césariennes
       AVANT travail (JQGA002 = césarienne programmée)
       Inclusion : JQGA003 (césarienne au cours du travail) et JQGD (voies basses)

Étape 3 — Numérateur (césariennes du G1)
  Séjours G1 avec acte CCAM JQGA003 (césarienne au cours du travail)

Étape 4 — Dénominateur
  Tous les séjours G1 (numérateur + accouchements voie basse en G1)

Étape 5 — Calcul
  Taux brut = N / D × 100
  Restitution : taux + IC 95% binomial exact
```

Variables PMSI clés : `DP`, `DR`, `DA`, codes `CCAM` avec **extensions PMSI** (parité, gémellarité), `Z37.x`, `O60`–`O84`. Les extensions CCAM-PMSI introduites depuis 2019 (suffixes -11, -12, -21, -22) codent parité et gémellarité directement sur l'acte d'accouchement, ce qui rend la classification de Robson désormais calculable sur PMSI seul (avec une concordance ~85-90% au dossier patient validée par étude française).

## Utilité
- **Comparaison inter-maternités GHT** : seul indicateur comparable car il neutralise le case-mix obstétrical ; permet de positionner chaque maternité du GHT.
- **Audit clinique ciblé** : un taux Robson G1 > 12-15 % oriente vers une revue des indications de césarienne pour souffrance fœtale et stagnation de la dilatation.
- **Suivi pertinence des soins** : indicateur clé de la stratégie nationale de réduction des césariennes non médicalement justifiées.
- **Rapport annuel maternité** : composante recommandée par l'OMS depuis 2015.
- **Détection de dérive** : suivi temporel mensuel/trimestriel via cartes de contrôle, alerte si dépassement +3σ.
- **Stratification de la stratégie GHT** : adaptation du niveau de soin et des transferts in utero entre maternités niveau I/II/III.

## Sources de Données
- **PMSI MCO** : RUM/RSA des séjours d'accouchement (CMD 14), DP, DR, DA, actes CCAM avec extensions parité/gémellarité.
- **Référentiel CCAM** (ATIH, mis à jour annuellement) : codes JQGA (césariennes) et JQGD (voies basses) avec leurs extensions PMSI.
- **Référentiel CIM-10 FR** : chapitre XV (grossesse, accouchement) O00–O99, Z37.x.
- **Outils ATIH** : table des actes CCAM-PMSI, format RSA en vigueur.

## Exemple de Valeurs
*Sources : DREES Panorama des établissements de santé ; études françaises Robson sur PMSI (Le Ray et al.).*

- **Taux Robson G1 France** : ~12-15 % en moyenne nationale (MCO public + privé).
- **Taux Robson G1 OMS recommandé** : < 10 % pour les maternités à bas risque, < 15 % pour les niveaux II/III.
- **Plage inter-établissement** : 6 % – 25 % (forte hétérogénéité, surtout entre privé et public).
- **Taux global toutes patientes** France 2023 : ~21,4 % (DREES).
- **Niveau I (bas risque)** : Robson G1 attendu 8-12 %.
- **Niveau III (CHU/CHR)** : Robson G1 attendu 12-18 % (population G1 plus restreinte mais plus à risque résiduel).
- **Seuil d'alerte interne** : Robson G1 > 18 % → audit indications.

## Limites
- **Concordance imparfaite avec dossier patient** : études de validation (concordance kappa ~0,75-0,90 selon le critère) — la parité et l'antécédent de césarienne peuvent être mal codés.
- **Travail spontané vs induit** : la distinction repose sur l'absence de O61 (échec de déclenchement) ; le déclenchement réussi sans complication n'est pas toujours codé, risque de mauvais classement.
- **Volume minimal** : ≥ 100 accouchements G1/an recommandé pour stabilité statistique.
- **Évolutions CCAM** : avant 2019, extensions de parité non disponibles → indicateur calculable rétrospectivement uniquement à partir de 2019+.
- **Petites maternités** : effet établissement faible (peu de césariennes), IC 95% large.
- **Sous-déclaration des sièges externalisés** : les versions par manœuvre externe réussies ne changent pas la présentation codée à l'accouchement.

## Références
- Robson MS. Classification of caesarean sections. *Fetal Matern Med Rev*. 2001;12(1):23-39.
- Le Ray C, et al. Classification de Robson : un outil d'évaluation des pratiques de césarienne en France. [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0368231515000629)
- [OMS — Robson Classification: Implementation Manual (2017)](https://www.who.int/reproductivehealth/publications/maternal_perinatal_health/robson-classification/en/)
- [HAS — IQSS et indicateurs en obstétrique](https://www.has-sante.fr/jcms/c_970481/fr/iqss-recueils-des-indicateurs-de-qualite-et-de-securite-des-soins)
- [Notice technique ATIH — Évolutions CCAM PMSI 2019](https://www.atih.sante.fr/sites/default/files/public/content/3498/notice_technique_atih_ndeg_2-790-2019_nouveautes_pmsi_2019.pdf)
- [Réseau périnatal — Codage des situations cliniques en obstétrique](https://www.reseau-naissance.fr/data/mediashare/8k/qddspv591yl3evbbqq6wi1mdsi3hvh-org.pdf)
