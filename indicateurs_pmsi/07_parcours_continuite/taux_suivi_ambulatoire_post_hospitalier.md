# Taux de Suivi Ambulatoire Post-Hospitalier

## Définition
Le taux de suivi ambulatoire post-hospitalier mesure la proportion de patients ayant bénéficié d'au moins une consultation médicale en ville (médecin généraliste ou spécialiste) dans les 7 et 30 jours suivant leur sortie d'hospitalisation MCO. Calculé depuis le Système National des Données de Santé (SNDS) par croisement des données PMSI (séjour index) et du DCIR (Données de Consommation Inter-Régimes — remboursements de soins ambulatoires), cet indicateur est un marqueur clé de la qualité de la transition hôpital-ville. L'absence de consultation post-hospitalière précoce est l'un des principaux facteurs de risque de réadmission non programmée, de rupture thérapeutique et de décompensation de pathologies chroniques — en particulier pour les patients âgés, polypathologiques ou sous traitements complexes.

## Calcul
Le taux de suivi ambulatoire post-hospitalier est calculé comme suit :

```
Taux de suivi à J+7 (%) = (Patients avec ≥ 1 consultation médicale remboursée dans les 7j post-sortie / Total des patients sortis vivants) × 100

Taux de suivi à J+30 (%) = (Patients avec ≥ 1 consultation médicale remboursée dans les 30j post-sortie / Total des patients sortis vivants) × 100
```

**Construction depuis le SNDS :**
```
Étape 1 — Identification des séjours index dans le PMSI MCO :
  → Mode de sortie ≠ 9 (décès), ≠ 6 (transfert immédiat vers un autre MCO)
  → Pathologies traceurs prioritaires : IDM (I21-I22), IC (I50), AVC (I63-I64),
    BPCO (J44), diabète (E10-E14), insuffisance rénale (N18), cancers (C00-C97)

Étape 2 — Chaînage PMSI-DCIR par NIR crypté :
  → Appariement du séjour PMSI avec les actes du DCIR dans la fenêtre [J+1, J+7] et [J+1, J+30]

Étape 3 — Identification des consultations médicales remboursées :
  → Actes CCAM ou NGAP de consultation (C, CS, CSC, Cs) remboursés par l'Assurance Maladie
  → Médecin généraliste (spécialité 1), cardiologue (5), neurologue (6), pneumologue (15), etc.
  → Téléconsultations incluses (actes TC remboursés depuis 2019)

Sous-indicateurs :
  Taux de consultation MG à J+7 (%)   → suivi de proximité
  Taux de consultation spécialiste à J+30 (%)  → suivi spécialisé adapté
  Délai médian de première consultation (jours) → rapidité de la transition
  Taux de patients sans aucun contact médical à J+30 (%) → rupture de soins
```

## Utilité
- **Évaluation de la transition hôpital-ville** : identifier les pathologies et les populations pour lesquelles la transition est la moins assurée, pour cibler les interventions de coordination (appel infirmier à J+3, consultation post-hospitalisation systématique, HAD de transition).
- **Prédiction et prévention des réadmissions** : un taux de suivi à J+7 < 50 % est associé à un doublement du risque de réadmission à 30 jours — cet indicateur prédit les réadmissions évitables mieux que la plupart des variables cliniques.
- **Déclinaison par pathologie** : le suivi post-IDM (cardiologue à J+30), post-AVC (neurologue + MG), post-insuffisance cardiaque (cardiologue à J+7) correspond à des recommandations HAS précises — le taux de suivi mesure le respect de ces recommandations à l'échelle du territoire.
- **Pilotage des coopérations ville-hôpital** : un faible taux de suivi dans une zone géographique du territoire du GHT cible les actions à mener avec les acteurs de ville (MSP, CPTS, DAC) pour structurer la prise en charge post-hospitalière.
- **Évaluation des programmes de transition care** : mesurer l'impact des consultations post-hospitalisation à J+7 mises en place par le GHT sur le taux de réadmission à 30 jours — indicateur d'efficacité clé pour ces programmes.

## Sources de Données
- **SNDS (PMSI + DCIR)** : accès obligatoire pour cet indicateur — le PMSI seul ne contient pas les actes ambulatoires. Le chaînage PMSI-DCIR via le NIR crypté est réalisé dans l'entrepôt SNDS, accessible sur autorisation CNIL/INDS ou via les portails sécurisés (Health Data Hub).
- **CNAM - Données open data** : la CNAM publie des statistiques agrégées sur le suivi post-hospitalier par pathologie et par région, utilisables pour le benchmarking sans accès direct au SNDS.
- **PMSI MCO** : identification des séjours index (pathologie, mode de sortie, date de sortie) pour le numérateur et le dénominateur.
- **Référence méthodologique** : CNAM, *Améliorer la qualité du système de santé et maîtriser les dépenses*, rapport annuel Charges et Produits, indicateurs de suivi post-hospitalier.

## Exemple de Valeurs
- **Taux de consultation MG à J+7 post-hospitalisation (toutes causes)** : 45-60 % en France selon les régions et les pathologies (données CNAM).
- **Post-IDM, consultation cardiologue à J+30** : 55-70 % selon les établissements et les territoires ; objectif recommandé HAS > 80 %.
- **Post-insuffisance cardiaque, consultation à J+7** : 35-55 % en France — l'une des transitions les moins bien assurées, associée à un fort taux de réadmission.
- **Post-AVC, consultation neurologue à J+30** : 30-50 %, très variable selon la disponibilité des neurologues libéraux sur le territoire.
- **Patients sans aucun contact médical à J+30** : 15-25 % selon les pathologies et les territoires — une proportion préoccupante signalant des ruptures de soins potentiellement évitables.
- **Impact d'une consultation à J+7** : réduction de 20-30 % des réadmissions à 30 jours documentée dans les études françaises (CNAM, HAS) pour l'insuffisance cardiaque et le diabète.

## Limites
- **Accès SNDS obligatoire** : cet indicateur ne peut pas être calculé depuis le seul PMSI ou ScanSanté — le chaînage avec le DCIR (actes ambulatoires) nécessite une autorisation réglementaire (CNIL/INDS) et une infrastructure technique adaptée (entrepôt SNDS ou Health Data Hub).
- **Non-représentation des consultations non remboursées** : les consultations non remboursées (dépassements d'honoraires non pris en charge, médecines alternatives) ou les échanges téléphoniques médecin-patient ne sont pas tracés dans le DCIR.
- **Biais de sélection** : les patients les plus graves ou les plus complexes peuvent avoir un taux de suivi paradoxalement plus élevé (hospitalisations fréquentes, suivi spécialisé intense) — la stratification par profil de risque est indispensable.
- **Couverture DCIR** : le DCIR couvre les actes remboursés par l'Assurance Maladie obligatoire ; les consultations réalisées dans le cadre de l'hospitalisation de suite (SSR, HAD) ou à l'hôpital ne sont pas comptabilisées comme suivi ambulatoire.
- **Délai de disponibilité** : les données DCIR sont disponibles avec un délai de 3 à 6 mois après l'acte ; un suivi en temps réel de cet indicateur n'est pas possible depuis le SNDS standard.

## Références
- [CNAM - Rapport Charges et Produits : suivi post-hospitalier](https://www.ameli.fr/l-assurance-maladie/statistiques-et-publications/rapports-et-conventions/)
- [HAS - Recommandations sur la consultation post-hospitalisation](https://www.has-sante.fr/)
- [SNDS - Système National des Données de Santé](https://www.snds.gouv.fr/)
- [Health Data Hub - Accès aux données de santé](https://www.health-data-hub.fr/)
- [DREES - Transition hôpital-ville et réadmissions](https://www.drees.solidarites-sante.gouv.fr/)
