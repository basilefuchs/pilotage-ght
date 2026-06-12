# Taux d'Exhaustivité PMSI/SAE

## Définition

Le taux d'exhaustivité PMSI/SAE mesure la **complétude de la chaîne de production PMSI** en rapportant le nombre de RSA (Résumés de Sortie Anonymisés) transmis à l'ATIH au nombre de séjours déclarés en SAE (Statistique Annuelle des Établissements) pour le même établissement et la même période.

```
Taux_exhaustivité = nb_RSA_PMSI_MCO / nb_séjours_MCO_SAE × 100
```

La SAE est la source de référence administrative officielle des séjours hospitaliers (déclaration DREES annuelle obligatoire), indépendante du PMSI. Un écart entre les deux comptages révèle une **perte dans la chaîne de production PMSI** : séjours produits mais non groupés, RSA rejetés en transmission, erreurs d'agrégation de FINESS, ou décalages de clôture de période.

Cet indicateur se distingue de l'`ecart_activite_benchmark_sae` qui compare les volumes en points ISA ou en recettes entre établissements de même type, et du `score_ovalide_erreurs_critiques` qui porte sur la qualité interne des RSA transmis — pas sur leur exhaustivité en nombre. Le taux d'exhaustivité est le premier maillon du contrôle qualité ATIH : un RSA absent ne peut être ni contrôlé ni valorisé.

Le seuil ATIH de conformité est fixé à **≥ 98%** dans les guides méthodologiques de qualité PMSI MCO. En dessous, l'ATIH émet un signal de non-conformité dans le rapport de transmission.

## Calcul

Sources : PMSI MCO RSA (transmission ATIH) + SAE (déclaration DREES).

```
Population : tous séjours MCO terminés et clôturés sur la période annuelle
             pour un FINESS géographique donné

Étape 1 — Comptage PMSI :
  nb_RSA_PMSI = count(RSA transmis à l'ATIH | NOFINESS = e, année = A)
  Source : fichier RSA MCO, table principale — 1 ligne = 1 séjour terminé

Étape 2 — Comptage SAE :
  nb_séjours_SAE = nombre de séjours MCO en hospitalisation complète + hospitalisation partielle
                   déclarés en SAE pour le même FINESS et la même année civile
  Source : questionnaire SAE (volet MCO), rubrique "séjours terminés dans l'année"

  Attention — alignement des périmètres :
    - Exclure de nb_RSA_PMSI : les séances (CMD 28) si SAE les comptabilise séparément
    - Exclure les séjours HAD si FINESS HAD distinct
    - Aligner la définition "séjour terminé" : date de sortie dans l'année civile A
      pour les deux sources (cohérence de clôture)

Étape 3 — Calcul du taux :
  Taux_exhaustivité = nb_RSA_PMSI / nb_séjours_SAE × 100   [en %]

  Si Taux > 100% : séjours PMSI > séjours SAE
    → Causes possibles : RSA de l'année précédente inclus par erreur, FINESS multiples agrégés,
      différence de définition séances vs séjours
    → Action : revoir l'alignement des périmètres avant interprétation

  Si Taux < 98% : perte de RSA dans la chaîne de production
    → Investiguer : nb de RSA rejetés par OVALIDE (CMD 90), RSA produits non transmis,
      erreurs de clôture de période dans le SIH

Étape 4 — Décomposition de l'écart (si Taux < 98%) :
  Δ_absolu  = nb_séjours_SAE − nb_RSA_PMSI  [en nombre de séjours manquants]
  Δ_relatif = (1 − Taux_exhaustivité / 100)  [fraction de séjours perdus]

  Piste 1 — RSA en erreur de groupage (CMD 90) :
    nb_RSA_CMD90 = count(RSA | GHM starts with '90')
    → Ces RSA sont transmis mais non valorisés ; les déduire de nb_RSA_PMSI
      donne le taux d'exhaustivité valorisable

  Piste 2 — RSA non transmis (rejet ATIH) :
    → Consulter le rapport de transmission ATIH (accusé de réception)
      pour le nb de RSA rejetés avant intégration

Cas limites :
  - SAE non disponible en cours d'année : utiliser les données SAE N-1 proratisées
    ou les données issues du bilan d'activité interne validé par la direction
  - FINESS multiples (fusion, multi-sites) : agréger PMSI et SAE sur le même périmètre FINESS
    avant calcul
```

Indicateurs dérivés :

```
Taux d'exhaustivité valorisable :
  = (nb_RSA_PMSI − nb_RSA_CMD90) / nb_séjours_SAE × 100
  → proportion de séjours qui généreront effectivement un GHS

Taux de rejet transmission :
  = nb_RSA_rejetés_ATIH / (nb_RSA_transmis + nb_RSA_rejetés) × 100
  → mesure la perte en aval de la production, en transmission

Écart annualisé en recettes estimées :
  = Δ_absolu × recette_GHS_moyenne_établissement
  → ordre de grandeur financier de la perte d'exhaustivité
```

## Utilité

- **Premier diagnostic de la chaîne de production PMSI** : avant toute analyse de casemix, de DMS ou de valorisation, vérifier que le PMSI est exhaustif — un taux de 95% signifie que 5% des séjours (plusieurs centaines dans un CH de taille moyenne) sont absents de toutes les analyses PMSI et non valorisés
- **Benchmark qualité intra-GHT** : comparer les taux d'exhaustivité entre établissements du GHT pour identifier les structures à renforcer en ressources DIM — un écart > 2 points entre deux établissements de même type est significatif et actionnable
- **Argument dans les dialogues de gestion ARS** : un taux < 98% documenté sur données officielles ATIH constitue une justification recevable d'un sous-financement T2A apparent, distinct d'une perte d'activité réelle
- **Suivi des plans de renforcement DIM** : mesurer l'évolution du taux d'exhaustivité avant et après un recrutement de TIM (technicien d'information médicale) ou après la mise en place d'un outil de contrôle qualité PMSI
- **Alerte précoce sur les pertes de transmission** : un suivi trimestriel (via les accusés de réception ATIH) permet de détecter des problèmes d'interface SIH → PMSI avant la clôture annuelle, laissant le temps de corriger et de re-transmettre
- **Prérequis pour la certification des données PMSI** : dans le cadre des CPOM et des certifications qualité (HAS, ISO), l'exhaustivité PMSI est un indicateur prérequis — documenter son suivi annuel est une bonne pratique de gouvernance des données

## Sources de Données

- **PMSI MCO RSA** : fichier RSA transmis à l'ATIH — variable `finessgeo` (FINESS géographique), `ghm2` (6 caractères — CMD 90 = erreurs), `annee`/`mois` de sortie — extraction annuelle depuis l'espace ATIH de l'établissement
- **SAE (Statistique Annuelle des Établissements)** : questionnaire DREES annuel, volet MCO, rubrique «séjours terminés» — accessible via l'espace SAE DREES ou directement depuis le rapport d'activité SAE validé par la direction
- **Accusé de réception ATIH** : document transmis par l'ATIH après chaque transmission PMSI, indiquant le nombre de RSA intégrés et le nombre rejetés — conservé par le DIM

## Exemple de Valeurs

- **CHU — taux cible** : 99,0–99,8% (organisation DIM structurée, outils de contrôle qualité en place)
- **CH 300–600 lits** : 97,5–99,2% (légères pertes liées aux délais de clôture)
- **Petit CH ou site secondaire** : 94–97% (risque de perte élevé, DIM partagé ou sous-dimensionné)
- **Seuil ATIH de conformité** : ≥ 98% — en dessous, signal de non-conformité dans le rapport de transmission
- **Alerte critique** : < 95% → investiguer en urgence ; à 95%, ~500 séjours/an manquants pour un CH à 10 000 RSA, soit environ 500 000 à 1 000 000€ de recettes T2A non perçues
- **Taux > 100%** : fréquent lors des premières transmissions (RSA de décembre N-1 inclus dans N) — résoudre par alignement strict des dates de sortie

## Limites

- **Définitions non strictement identiques** : SAE comptabilise les séjours terminés selon la date de clôture administrative de l'établissement, PMSI selon la date de sortie réelle — pour les séjours qui chevauchent l'année civile, les deux sources peuvent différer de quelques dizaines de RSA sans erreur de production
- **Périmètre des séances** : la SAE distingue parfois les «séances» (dialyse, chimiothérapie) des «séjours» ; le PMSI les intègre tous en MCO (CMD 28) — l'alignement du périmètre est critique et doit être documenté avant toute comparaison
- **SAE annuelle** : la SAE n'est disponible qu'une fois par an (transmission en avril N+1 pour l'année N) — le suivi infra-annuel du taux d'exhaustivité doit s'appuyer sur des proxies internes (bilan d'activité mensuel validé par la direction)
- **Fusion ou multi-sites** : en cas de FINESS multiples (établissement principal + sites rattachés), l'agrégation PMSI se fait sur le FINESS géographique alors que la SAE peut être déclarée au niveau de l'entité juridique — risque d'erreur de périmètre à neutraliser
- **Non-comparabilité directe entre secteurs** : le taux d'exhaustivité MCO n'est pas comparable au taux SSR ou psychiatrie (périmètres PMSI et SAE différents selon le champ)

## Références

- [ATIH — Guide méthodologique de production du PMSI MCO, version annuelle : spécifications du contrôle d'exhaustivité PMSI/SAE](https://www.atih.sante.fr/)
- [DREES — Statistique Annuelle des Établissements de santé (SAE) : méthodologie et questionnaire annuel](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH — Manuel des groupes homogènes de malades (GHM), description des CMD 90 (séjours en erreur)](https://www.atih.sante.fr/)
- [HAS — Certification des établissements de santé : référentiel qualité des données PMSI (critère exhaustivité)](https://www.has-sante.fr/)
