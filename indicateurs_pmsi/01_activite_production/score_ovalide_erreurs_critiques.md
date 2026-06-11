# Score OVALIDE — Taux d'Erreurs Critiques de Codage

## Définition

OVALIDE (Outil de Validation des Informations de la base de Données des Établissements) est l'outil officiel de contrôle qualité PMSI développé par l'ATIH. Il analyse l'ensemble des RSA transmis par un établissement et produit des **états de contrôle** classés en quatre niveaux de gravité :

| Code | Niveau | Description |
|---|---|---|
| **E1** | Erreur bloquante | Incohérence empêchant la valorisation T2A ou la production du RSA |
| **E2** | Erreur majeure | Incohérence probable, impactant la qualité du groupage |
| **A** | Avertissement | Anomalie possible à investiguer |
| **I** | Information | Signal statistique, pas nécessairement une erreur |

Le score OVALIDE — taux d'erreurs critiques — est défini comme :

```
Score_E1 = nb_RSA_avec_au_moins_1_erreur_E1 / nb_RSA_total × 1 000
```

exprimé **pour 1 000 RSA** (pour 1 millier), suivant la convention ATIH. Le seuil de conformité ATIH est de **< 5 erreurs E1 pour 1 000 RSA**.

Cet indicateur complète le `taux_sejours_valorises_t2a` (qui mesure les conséquences financières du mauvais codage) et le `taux_exhaustivite_pmsi_sae` (qui mesure la complétude) en ciblant la **qualité interne** des RSA produits : un RSA peut être transmis et valorisé tout en contenant des incohérences E2 ou A susceptibles de conduire à un mauvais groupage, donc à une sous- ou sur-valorisation.

## Calcul

Source : rapports OVALIDE ATIH — accessibles depuis l'espace sécurisé ATIH de l'établissement après chaque transmission PMSI.

```
Population : tous RSA transmis à l'ATIH pour un FINESS/période

Étape 1 — Export des états OVALIDE :
  Depuis l'espace ATIH : télécharger le rapport OVALIDE au format CSV/Excel
  Colonnes disponibles dans l'export OVALIDE :
    - CODE_CONTROLE    : identifiant unique du contrôle (ex : M01, M12, C04...)
    - LIBELLE          : description de l'erreur
    - TYPE_CONTROLE    : E1 / E2 / A / I
    - NB_OCCURRENCES   : nombre total d'occurrences de l'erreur
    - NB_RSA_TOUCHES   : nombre de RSA différents concernés par ce contrôle

Étape 2 — Agrégation par RSA (niveau E1) :
  nb_RSA_E1 = count(RSA distincts ayant au moins 1 erreur de type E1)

  Note : un RSA peut déclencher plusieurs codes d'erreur E1 différents ;
  il ne compte qu'une fois dans nb_RSA_E1
  → utiliser la colonne NB_RSA_TOUCHES et dédupliquer par NUM_RSA

Étape 3 — Score principal :
  nb_RSA_total = count(RSA transmis intégrés)
  Score_E1 = nb_RSA_E1 / nb_RSA_total × 1 000   [pour 1 000 RSA]

  Seuil ATIH : Score_E1 < 5 → conforme
               Score_E1 ∈ [5 ; 20] → à surveiller
               Score_E1 > 20 → non conforme — action DIM requise

Étape 4 — Scores complémentaires par niveau :
  Score_E2 = nb_RSA_avec_E2 / nb_RSA_total × 1 000
  Score_A  = nb_RSA_avec_A  / nb_RSA_total × 1 000

  Score_global_pondéré = 3 × Score_E1 + Score_E2 + 0,1 × Score_A
  → pondération suggérée, non officielle ATIH ; à calibrer localement

Étape 5 — Analyse par code de contrôle (top 10 erreurs) :
  Top_E1 = trier les contrôles E1 par NB_RSA_TOUCHES décroissant
  → identifier les 3 codes d'erreur concentrant >50% des RSA E1
  → chaque code E1 correspond à une incohérence spécifique documentée
     dans le guide OVALIDE ATIH

Cas limites :
  - OVALIDE non disponible (transmission hors délai) : Score = NA
    → noter la cause dans le tableau de suivi
  - Mise à jour de version OVALIDE en cours d'année :
    Les codes de contrôle et leurs seuils peuvent changer entre versions
    → toujours spécifier la version OVALIDE utilisée dans le rapport
  - Séances (CMD 28) : certains contrôles E1 s'appliquent différemment aux séances
    → possible de calculer Score_E1 hors séances et sur séances séparément
```

Indicateurs dérivés :

```
Taux de RSA sans aucune erreur OVALIDE :
  RSA_propres = count(RSA | aucun contrôle E1, E2, A déclenché)
  Taux_propres = RSA_propres / nb_RSA_total × 100
  → indicateur positif (vs Score_E1 qui est négatif)
  CHU cible : > 85% de RSA propres

Top-3 codes E1 par UM (unité médicale) :
  → localise les services à fort taux d'erreur pour cibler les formations DIM
  → exploite la ventilation OVALIDE par UM quand disponible

Évolution trimestrielle Score_E1 :
  → graphique de suivi sur 4 trimestres
  → permet de mesurer l'impact des actions correctives DIM en temps réel
```

## Utilité

- **Tableau de bord DIM opérationnel** : le Score_E1 est la métrique de synthèse la plus actionnable pour le responsable DIM — il cible précisément les RSA à re-coder et les codes d'erreur les plus fréquents, avec un accès direct depuis l'espace ATIH sans traitement statistique supplémentaire
- **Priorisation des audits de codage par service** : en croisant le Score_E1 par UM avec les volumes de séjours et les tarifs GHS moyens par UM, on identifie les services où l'investissement de re-codage est le plus rentable financièrement (beaucoup d'E1 sur des GHMs lourds)
- **Benchmark intra-GHT** : comparer les Score_E1 entre établissements du GHT pour une même spécialité (ex : chirurgie orthopédique) révèle des hétérogénéités de pratiques de codage — un établissement à Score_E1 = 35 sur l'orthopédie vs 8 dans l'établissement voisin du GHT est un signal de formation ou de réorganisation DIM
- **Suivi des plans d'amélioration qualité** : intégrer le Score_E1 comme KPI dans les contrats d'objectifs du DIM et des équipes médicales — une trajectoire de baisse de 20% par an est un objectif réaliste pour un établissement partant de Score > 20
- **Préparation aux contrôles ATIH/Assurance Maladie** : un Score_E1 élevé et non traité augmente le risque d'un contrôle T2A ciblé par l'Assurance Maladie (CCAM, plan de contrôle annuel) — maintenir le Score sous le seuil ATIH est une mesure préventive documentable
- **Évaluation de l'impact des changements de version GHM** : chaque nouvelle version du groupeur ATIH crée de nouveaux contrôles E1 sur les codes qui ne sont plus compatibles — mesurer le Score_E1 au T1 post-mise à jour permet de calibrer l'effort de re-formation nécessaire

## Sources de Données

- **OVALIDE ATIH** : application web accessible depuis l'espace sécurisé ATIH de chaque établissement après transmission PMSI — exportation des états au format Excel/CSV — variables : `CODE_CONTROLE`, `TYPE_CONTROLE` (E1/E2/A/I), `NB_RSA_TOUCHES`, `NB_OCCURRENCES`
- **Guide des contrôles OVALIDE** : document officiel ATIH décrivant chaque code de contrôle, sa définition, son niveau de gravité et les actions correctives attendues — mis à jour à chaque version du groupeur
- **PMSI MCO RSA** : pour calculer le dénominateur `nb_RSA_total` et pour ventiler le Score_E1 par UM (`UM` ou `CODE_UM` dans le RSA)

## Exemple de Valeurs

- **CHU** : Score_E1 typique = 2–8 pour 1 000 RSA ; Taux_propres > 88%
- **CH 300–600 lits** : Score_E1 = 5–20 pour 1 000 RSA selon la maturité DIM
- **Petit CH ou DIM sous-dimensionné** : Score_E1 = 20–60 pour 1 000 RSA
- **Seuil ATIH de conformité** : < 5 pour 1 000 RSA
- **Seuil d'alerte** : > 20 pour 1 000 RSA → plan d'action DIM formalisé requis
- **Impact typique post-formation DIM** : réduction de 30–50% du Score_E1 dans les 2 trimestres suivant une formation ciblée sur les codes d'erreur les plus fréquents
- **Top codes E1 fréquents** : M01 (DP absent ou non renseigné), C04 (incompatibilité acte-diagnostic), M12 (durée de séjour incohérente avec le mode de prise en charge)

## Limites

- **Dépendance à la version OVALIDE** : les codes de contrôle et leurs seuils de déclenchement varient entre versions — une hausse du Score_E1 d'une année sur l'autre peut refléter un durcissement des contrôles OVALIDE plutôt qu'une dégradation du codage ; toujours vérifier les notes de version ATIH
- **Non-accessible en temps réel** : OVALIDE n'est disponible qu'après la transmission PMSI officielle (mensuelle ou trimestrielle selon les établissements) — le suivi infra-mensuel nécessite d'autres outils de contrôle qualité internes (groupeurs locaux avec contrôles similaires)
- **Score agrégé masquant des hétérogénéités** : un Score_E1 global de 8 peut cacher un service à 80 et neuf services à 0 — toujours analyser la distribution par UM avant toute conclusion sur la qualité globale
- **Périmètre OVALIDE** : OVALIDE couvre les contrôles de cohérence interne des RSA mais ne valide pas la pertinence clinique du DP choisi (un DP cliniquement discutable mais techniquement cohérent passe OVALIDE sans erreur)
- **Non-comparabilité directe inter-établissements** : ATIH ne publie pas de benchmark national des Score_E1 par type d'établissement — les comparaisons intra-GHT restent la référence la plus fiable

## Références

- [ATIH — OVALIDE, outil de validation des informations PMSI MCO : guide des contrôles et documentation technique](https://www.atih.sante.fr/ovalide-mco-2025)
- [ATIH — Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation, version annuelle](https://www.atih.sante.fr/)
- [Ministère de la Santé — Circulaire DHOS/E1/2006/119 : organisation du contrôle de la qualité des données PMSI dans les établissements de santé]
- [DREES — Études sur la qualité du codage PMSI : variabilité inter-établissements et impact sur la valorisation T2A]
