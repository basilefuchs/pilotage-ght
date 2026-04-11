# Score Prédictif de Réhospitalisation à 30 Jours

## Définition
Le score prédictif de réhospitalisation à 30 jours est un modèle statistique multivarié construit à partir des variables disponibles dans le PMSI permettant d'estimer, dès la sortie du séjour index, la probabilité qu'un patient soit réhospitalisé dans les 30 jours suivants. Contrairement au simple taux de réadmission (indicateur rétrospectif), ce score est un outil prospectif d'aide à la décision : il permet d'identifier à la sortie les patients à haut risque de réadmission non programmée pour déclencher des interventions ciblées (contact téléphonique de suivi, coordination avec le médecin traitant, HAD, consultation rapide de post-hospitalisation). Il s'appuie sur des modèles validés dans la littérature internationale (LACE, HOSPITAL score) et adaptables aux données PMSI françaises.

## Calcul
Le score prédictif est construit par régression logistique (ou modèle de gradient boosting) sur les variables suivantes, issues du PMSI :

**Variables prédictives principales :**

| Variable | Source PMSI | Pondération indicative (HOSPITAL score) |
|---|---|---|
| Hémoglobine basse à l'admission | DA (D64, D50-D53) | +1 |
| Séjour pour cancer actif | DP/DA (C00-C97) | +2 |
| Nombre de séjours dans les 12 mois (proxy : réadmissions antérieures) | Chaînage PMSI | +5 si ≥ 5 séjours |
| Procédure spécialisée durant le séjour (acte CCAM lourd) | CCAM | +1 |
| Admission aux urgences (mode d'entrée = 8) | Mode d'entrée MCO | +1 |
| Durée de séjour ≥ 5 jours | DMS séjour | +2 |
| Type de sortie (transfert, sortie contre avis médical) | Mode de sortie MCO | +1 |

**Formule du modèle logistique :**
```
log(P(réadmission) / (1 − P(réadmission))) = β0 + β1×CCI + β2×DMS + β3×âge + β4×mode_sortie + β5×nb_séjours_antérieurs + ...

Score de risque individuel = P(réadmission à 30 j)
  → Faible risque : P < 10 %
  → Risque modéré : P entre 10 % et 20 %
  → Haut risque : P > 20 %
```

**Précisions méthodologiques** :
- Le modèle est entraîné sur les données PMSI historiques du GHT (N ≥ 5 000 séjours recommandé) avec validation croisée (split train/test 70/30 ou validation temporelle).
- Les performances sont évaluées par l'aire sous la courbe ROC (AUC cible ≥ 0,70) et la calibration (courbe de Hosmer-Lemeshow).
- Le score est recalibré annuellement pour tenir compte des évolutions de la patientèle et des pratiques de codage.
- Les variables SNDS (médicaments, consultations ambulatoires, ALD) améliorent significativement la performance du modèle mais nécessitent un accès aux données appariées.

## Utilité
- **Prévention proactive des réadmissions** : déclencher à la sortie des interventions ciblées (appel infirmier à J+3, consultation post-hospitalisation à J+7, coordination DAC) uniquement pour les patients à haut risque, optimisant le rapport coût/efficacité des programmes de prévention.
- **Priorisation des ressources de coordination** : avec un budget limité de coordination, concentrer les assistantes sociales, les infirmières de liaison et les équipes HAD sur les 10-20 % de patients présentant le plus haut risque de réadmission.
- **Réduction des pénalités T2A** : les réadmissions non programmées à 30 jours font l'objet d'une pénalisation financière dans certains systèmes tarifaires ; leur réduction améliore directement le solde financier du GHT.
- **Évaluation des interventions** : mesurer l'impact des programmes de réduction des réadmissions (transition care, suivi téléphonique, HAD) en comparant les taux de réadmission observés vs prédits.
- **Recherche clinique et médico-économique** : le score constitue une variable de stratification pour les études sur les parcours de soins et les évaluations médico-économiques des interventions.

## Sources de Données
- **PMSI MCO** : ensemble des variables du RSS (âge, sexe, DP, DA, DMS, mode d'entrée, mode de sortie, CCAM) pour la construction et l'application du modèle.
- **Chaînage PMSI** : historique des séjours du patient (NIR crypté) pour calculer le nombre de séjours dans les 12 mois précédents, variable prédictive majeure.
- **SNDS** : données ambulatoires (médicaments, consultations, ALD) pour enrichir le modèle et améliorer sa performance prédictive.
- **Référence méthodologique - HOSPITAL score** : Donzé J. et al., *Potentially avoidable 30-day hospital readmissions in medical patients*, JAMA Internal Medicine, 2013.
- **Référence méthodologique - LACE index** : van Walraven C. et al., *Derivation and validation of an index to predict early death or unplanned readmission after discharge*, CMAJ, 2010.

## Exemple de Valeurs
- **AUC du modèle HOSPITAL score** : 0,71-0,74 dans les cohortes de validation françaises, comparables aux performances anglo-saxonnes.
- **Prévalence de la réadmission à 30 jours** : 10-15 % des séjours MCO en France, jusqu'à 25-30 % pour les patients avec CCI ≥ 3.
- **Patients à haut risque (score P > 20 %)** : représentent 15-20 % des séjours mais concentrent 40-50 % des réadmissions.
- **Réduction des réadmissions par intervention ciblée** : programmes de transition care validés (appel téléphonique + consultation J+7) réduisent les réadmissions de 15-25 % chez les patients à haut risque.
- **Impact financier** : chaque réadmission évitée représente une économie de 2 000-5 000 € en coûts directs ; un programme ciblant 500 patients à haut risque peut générer 500 000 à 1,5 M€ d'économies annuelles.

## Limites
- La performance prédictive des modèles basés sur le seul PMSI est limitée (AUC 0,65-0,75) : l'enrichissement avec les données ambulatoires (SNDS) et les données cliniques structurées (dossier patient) améliore significativement la prédiction.
- Le modèle doit être calibré localement sur la patientèle du GHT : un modèle entraîné sur des données nationales ou anglo-saxonnes peut sous- ou sur-estimer le risque sur la population locale.
- Le score prédit la réadmission toutes causes confondues, sans distinguer les réadmissions évitables (liées à la prise en charge initiale) des réadmissions inévitables (évolution naturelle de la maladie).
- L'implémentation opérationnelle du score nécessite une intégration dans le SIH ou dans les outils DIM pour un calcul automatique à la sortie, représentant un investissement informatique non négligeable.
- Des biais éthiques peuvent émerger si le score est utilisé pour orienter des décisions de soins (ex. : prolonger un séjour pour réduire le score) plutôt que pour déclencher des interventions de coordination.

## Références
- [Donzé J. et al., HOSPITAL score, JAMA Internal Medicine, 2013](https://doi.org/10.1001/jamainternmed.2013.6233)
- [van Walraven C. et al., LACE index, CMAJ, 2010](https://doi.org/10.1503/cmaj.091117)
- [HAS - Réadmissions non programmées et qualité des soins](https://www.has-sante.fr/)
- [SNDS - Données longitudinales pour la prédiction du risque](https://www.snds.gouv.fr/)
- [ATIH - Chaînage PMSI et trajectoires patients](https://www.atih.sante.fr/)
