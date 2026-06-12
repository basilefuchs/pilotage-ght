# File Active Annuelle des Patients Hospitalisés

## Définition
La **file active annuelle des patients hospitalisés** correspond au **nombre de patients distincts** ayant été hospitalisés au moins une fois dans l'année calendaire, tous secteurs confondus (MCO, SSR/SMR, HAD, Psy). Contrairement au nombre de séjours — qui compte les passages — la file active mesure une **densité d'usage** du système hospitalier sur la population.

C'est un indicateur structurant mis en avant par la DREES dans le **Panorama des établissements de santé édition 2025** (données 2023), qui chiffre à **13,2 millions de patients** la file active hospitalière nationale. Il complète le compteur traditionnel de séjours (pondéré par les hospitalisations multiples des patients chroniques) et fournit un dénominateur juste pour les indicateurs de qualité de parcours, d'inégalité d'accès et de récurrence d'hospitalisation.

Formule :

```
File active(année y) = | { patient i : ∃ ≥1 séjour dont DATE_SORTIE ∈ [01/01/y, 31/12/y] } |

Indicateurs dérivés :
  Récurrence_moyenne(y) = nombre_séjours(y) / file_active(y)
  Densité_FA(y, territoire) = file_active(y) / population_résidente(y)
```

Positionnement vs indicateurs existants : différent du compteur de séjours (`nombre_sejours.md`) et du taux de recours pour 1 000 (`taux_recours_hospitalier_standardise_age_sexe.md`). La file active est l'unité « personne » alors que les autres sont l'unité « séjour ». Elle est nécessaire pour calculer correctement la récurrence (nb séjours par patient) et permet de distinguer la croissance d'activité par augmentation du nombre de patients de celle par augmentation des hospitalisations chez les mêmes patients.

## Calcul

```
Étape 1 — Identification du chaînage patient
  Variable clé : N°ANONYME (chaînage PMSI ATIH) ou identifiant SNDS (NIR pseudonymisé)
  Périmètre : tous les RSA, RHA (SSR/SMR), RAPSS (HAD), RPSA (Psy) de l'année

Étape 2 — Décompte distinct
  File_active = COUNT(DISTINCT N°ANONYME) sur la période d'analyse

Étape 3 — Décompositions recommandées
  Par secteur : FA_MCO, FA_SSR, FA_HAD, FA_Psy
  Par classe d'âge × sexe (suivi démographique)
  Par établissement (FA_etab) — pour la part de la population captée par chaque finess
  Par territoire de résidence (CODGEO patient) — pour densité populationnelle

Étape 4 — Indicateurs dérivés
  Récurrence_moyenne = N_séjours / FA
  Part poly-hospitalisés = | { patients avec ≥3 séjours/an } | / FA
  Densité_FA / 1000 hab = FA × 1000 / population INSEE résidente
  Taux de chevauchement = | FA_MCO ∩ FA_SSR | / FA_MCO  (parcours MCO→SSR)

Étape 5 — Cas particuliers
  Patients avec n°anonyme manquant (chaînage défaillant) :
    → comptés comme distincts (sur-estime FA) ; à signaler
  Patients pris en charge en plusieurs secteurs :
    → comptés une seule fois pour la FA tous secteurs
```

Variables PMSI clés : `N°ANONYME` (chaînage), `DATE_ENTREE`, `DATE_SORTIE`, `FINESS` (établissement), `CODGEO` (résidence patient), `age`, `SEXE`, type de format (RSA / RHA / RAPSS / RPSA).

## Utilité
- **Suivi DREES Panorama** : alignement national avec l'indicateur structurant publié annuellement (13,2 M en 2023).
- **Dénominateur pour les indicateurs de qualité** : nombre d'événements indésirables / FA donne une intensité par patient, plus pertinente que par séjour pour les pathologies chroniques.
- **Couverture territoriale GHT** : part de la population résidente qui a fréquenté au moins une fois un établissement du GHT (densité de captation).
- **Pilotage filières chroniques** : récurrence (nb séjours/patient) identifie les patients à hospitalisations multiples, cible pour les programmes de coordination.
- **Comparaison inter-GHT** : la FA / population standardisée permet de positionner le GHT versus d'autres territoires comparables.
- **Détection de l'ambulatorisation** : une FA stable avec une baisse du nombre de séjours indique une réduction des hospitalisations multiples chez les mêmes patients (effet positif des parcours).
- **Veille démographique** : suivi par classe d'âge, anticipation du vieillissement populationnel.

## Sources de Données
- **PMSI MCO/SSR/HAD/Psy** : RSA, RHA, RAPSS, RPSA avec n°anonyme.
- **SNDS** : chaînage exhaustif inter-établissements et inter-secteurs (recommandé pour FA tous secteurs).
- **DREES Panorama des établissements de santé** : référence nationale annuelle.
- **INSEE** : population résidente pour normalisation territoriale.
- **ATIH** : règles de chaînage et qualité du n°anonyme.

## Exemple de Valeurs
*Source : DREES Panorama 2025 (données 2023), DREES ER 1344 (juillet 2025).*

- **File active nationale 2023** : 13,2 millions de patients (DREES Panorama 2025).
- **Récurrence nationale** : ~1,8 séjour / patient / an en MCO (10,5 M séjours / ~5,8 M patients MCO 2022).
- **File active MCO** : ~5,5 – 6 M / an.
- **File active HAD** : ~140 – 170 000 / an.
- **File active Psy** : ~400 000 / an (temps plein + temps partiel + ambulatoire).
- **FA / 1000 hab France** : ~190 – 200 / 1000.
- **FA / 1000 hab par territoire** : 130 – 240, fort gradient géographique (offre + démographie).
- **Part poly-hospitalisés (≥3 séjours/an)** : ~10-15 % de la FA, concentrant 40-50 % des séjours.

## Limites
- **Qualité du chaînage** : un n°anonyme manquant ou erroné peut compter un même patient deux fois ; taux d'exhaustivité du chaînage à surveiller (>98 % attendu en MCO).
- **Période calendaire** : la FA dépend de la fenêtre — cumul glissant 12 mois ≠ année calendaire.
- **Sans SNDS** : les établissements isolés voient leur FA limitée à leurs propres séjours, sans visibilité sur les patients suivis ailleurs.
- **N°anonyme transitoire** : changements de NIR (mariage, régularisation) peuvent fragmenter la trajectoire patient.
- **Patients étrangers / non assurés** : chaînage parfois absent, conduit à sur-comptage.
- **Confusion avec « nombre de séjours »** : interprétation publique parfois erronée.
- **Pas de granularité finess multi-établissements** : un patient suivi dans 2 établissements du GHT compte une fois en FA tous-GHT, mais 2 fois en FA-finess agrégée.

## Références
- [DREES — Panorama Établissements de santé édition 2025](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- [DREES — ER n°1344, juillet 2025 (séjours MCO 2024)](https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-07/ER1344%20Etablissements%20de%20sante%CC%81_MEL.pdf)
- [DREES — Panorama Établissements de santé édition 2024](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/panoramas-de-la-drees/240718_Panorama_EtablissementsSante2024)
- [ATIH — Format PMSI MCO et règles de chaînage](https://www.atih.sante.fr/)
- [DREES — Sources hospitalières SNDS / PMSI](https://drees.solidarites-sante.gouv.fr/etablissements-de-sante)
