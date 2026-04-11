# Indice UPC (Usual Provider Continuity) — Concentration des Soins Ambulatoires

## Définition
L'indice UPC (Usual Provider Continuity) mesure la part des consultations ambulatoires d'un patient réalisées auprès de son prestataire habituel le plus fréquent, sur une période de 12 mois glissants. Introduit par Breslau et Reeb (1975) et largement utilisé dans la littérature internationale sur la coordination des soins, il quantifie la **concentration** des soins ambulatoires : un UPC proche de 1 indique que le patient consulte quasi exclusivement un seul professionnel (typiquement son médecin traitant), tandis qu'un UPC proche de 0 signale une dispersion des soins entre de nombreux intervenants sans prestataire dominant. À la différence de l'indice de fragmentation de Bice-Boxerman (qui compte le nombre de structures distinctes fréquentées) ou de l'indice de fragmentation SNDS (qui mesure la dispersion multi-établissements), l'UPC capture la loyauté au prestataire principal — une dimension distincte de la continuité relationnelle des soins. Edwards et al. (JAMA Network Open 2022) ont démontré sur une cohorte de patients à risque élevé que les patients avec UPC élevé avaient 23 % moins de visites aux urgences et 22 % moins d'hospitalisations pour pathologies ambulatoires sensibles que les patients avec UPC faible, après ajustement sur les comorbidités.

## Calcul
L'indice UPC est calculé depuis les données SNDS (composante DCIR — Données de Consommation Inter-Régimes) :

```
UPC = N_principal / N_total

Où :
  N_principal = nombre de consultations/actes réalisés par le prestataire
                le plus fréquent du patient sur les 12 mois glissants
  N_total     = nombre total de consultations/actes ambulatoires du patient
                sur les mêmes 12 mois glissants

UPC ∈ [0, 1]
  → UPC = 1 : toutes les consultations sont réalisées par le même prestataire
  → UPC = 0 : impossible en pratique (au moins une consultation par définition)
  → UPC > 0,75 : forte concentration — bonne continuité relationnelle
  → UPC < 0,50 : forte dispersion — risque élevé de fragmentation des soins
```

**Construction depuis le SNDS/DCIR :**
```
Étape 1 — Extraction des actes ambulatoires par patient (NIR crypté) sur 12 mois :
  → Actes DCIR : consultations médecins (C, CS, CSC), visites (V, VS),
    actes infirmiers, kinésithérapie, actes de spécialistes
  → Identification du prestataire par numéro RPPS anonymisé ou code établissement

Étape 2 — Comptage par prestataire pour chaque patient :
  → Pour chaque patient : tableau [prestataire, nb_actes] sur 12 mois
  → N_principal = max(nb_actes par prestataire)
  → N_total = somme de tous les actes ambulatoires

Étape 3 — Calcul de l'UPC individuel puis agrégation :
  → UPC individuel = N_principal / N_total
  → UPC moyen par groupe de patients = moyenne des UPC individuels
  → Distribution des UPC par décile pour identifier les patients à très faible continuité
```

**Sous-indicateurs dérivés :**
```
UPC médecin traitant (%) :
  → Variante : N_principal restreint aux consultations du médecin traitant déclaré
  → Mesure spécifiquement la fidélité au médecin traitant vs. tout prestataire

Taux de patients avec UPC < 0,50 (%) = proportion de patients à faible continuité
  → Indicateur de pilotage : cible les patients nécessitant une intervention de coordination

UPC par profil de comorbidités :
  → Calculé séparément pour les patients Charlson ≥ 3, diabétiques, insuffisants cardiaques
  → Les patients chroniques complexes avec UPC bas sont la cible prioritaire des programmes
     de case management et de coordination de parcours

Corrélation UPC — hospitalisations potentiellement évitables :
  → Taux de HPE (PMSI) stratifié par tertile d'UPC (SNDS)
  → Quantifie l'impact de la continuité ambulatoire sur le recours hospitalier
```

**Précisions méthodologiques :**
- Le calcul nécessite le SNDS (PMSI + DCIR) pour accéder aux actes ambulatoires — non calculable depuis le seul PMSI MCO local.
- L'UPC est interprétable uniquement pour les patients ayant au moins 3 consultations sur la période — en dessous, la valeur est peu robuste.
- Dans le contexte français, le médecin traitant déclaré (données CNAM) peut servir de référence pour une variante de l'UPC spécifiquement centrée sur la fidélité au médecin traitant.
- L'UPC ambulatoire doit être distingué de l'indice de continuité intra-GHT (`indice_continuite_parcours_patient.md`) qui mesure la rétention hospitalière, et de l'indice de fragmentation Bice-Boxerman (`indice_fragmentation_parcours_patient.md`) qui mesure la dispersion multi-structures.

## Utilité
- **Identification des patients à risque de rupture de parcours** : les patients avec UPC < 0,50 n'ont pas de prestataire ambulatoire dominant — ils sont candidats prioritaires aux dispositifs de coordination (DAC, infirmière de parcours, consultation de coordination post-hospitalière) avant leur prochaine décompensation.
- **Évaluation de l'impact des médecins traitants du territoire sur le recours hospitalier** : croiser l'UPC moyen par commune/secteur avec le taux d'hospitalisations potentiellement évitables (PQI/HPE) permet de démontrer le lien entre désert médical, faible continuité ambulatoire et sur-recours aux urgences.
- **Dialogue ARS/CNAM sur la coordination territoriale** : l'UPC moyen par territoire du GHT quantifie la cohérence de l'offre de soins primaires — un UPC structurellement bas sur un bassin signale un déficit d'offre (sous-densité médicale) plutôt qu'un problème d'organisation hospitalière.
- **Évaluation des dispositifs de soins coordonnés** : mesurer l'évolution de l'UPC des patients inscrits dans une Communauté Professionnelle Territoriale de Santé (CPTS) ou dans une Maison de Santé Pluriprofessionnelle (MSP) avant/après inscription pour évaluer l'impact de ces structures sur la continuité relationnelle des soins.
- **Stratification pour le score de réhospitalisation** : intégrer l'UPC comme variable prédictive dans le score prédictif de réhospitalisation (`score_predictif_rehospitalisation.md`) — un UPC bas à la sortie est un facteur de risque indépendant de réadmission à 30 jours.

## Sources de Données
- **SNDS/DCIR** : composante inter-régimes des remboursements de soins ambulatoires — seule source permettant le calcul complet de l'UPC avec identification du prestataire habituel ; nécessite un accès SNDS (CNAM, bureau des études, DREES) ou une extraction réalisée par la CPAM territoriale dans le cadre d'un protocole de recherche ou de la convention GHT-CNAM.
- **Données médecin traitant (CNAM)** : référentiel des médecins traitants déclarés par les patients du territoire — permet la variante "UPC médecin traitant" sans nécessiter l'identification de tous les prestataires.
- **PMSI MCO (croisement)** : les patients avec UPC bas identifiés dans le SNDS peuvent être chaînés avec les séjours PMSI pour calculer leur taux d'HPE et de réadmissions non programmées.

## Exemple de Valeurs
- **UPC moyen en population générale** : 0,60-0,75 dans les études françaises et européennes sur les patients adultes avec au moins 3 consultations par an.
- **Patients chroniques avec comorbidités multiples** : UPC 0,55-0,70 — paradoxalement plus bas que la population générale malgré un besoin de continuité plus fort, en raison de la multiplication des spécialistes.
- **Patients avec faible UPC (< 0,50) et leur risque** : Edwards et al. (2022) montrent que les patients dans le tertile le plus faible d'UPC ont un risque ajusté d'hospitalisation pour pathologie ambulatoire sensible multiplié par 1,28 (IC95 : 1,16-1,40) par rapport au tertile le plus élevé.
- **Impact de la CPTS/MSP** : les études françaises et allemandes (Iashchenko et al., Eur J Public Health 2023) montrent une augmentation de l'UPC de 5-15 points dans les territoires avec réseaux de soins coordonnés structurés.
- **Déserts médicaux** : dans les zones sous-dotées en médecins généralistes (< 4 MG pour 10 000 habitants), l'UPC moyen tombe à 0,45-0,55 — seuil en dessous duquel le sur-recours aux urgences est statistiquement significatif.

## Limites
- Le calcul requiert l'accès au SNDS/DCIR — non réalisable par le DIM hospitalier seul depuis les données PMSI locales, contrairement à la plupart des autres indicateurs de cette base de connaissance.
- L'UPC peut être artificiellement élevé pour les patients ayant peu de consultations (1 ou 2 par an) : une consultation unique donne UPC = 1 mais ne reflète pas une vraie continuité relationnelle — filtrer les patients avec N_total < 3.
- L'indicateur ne distingue pas la continuité choisie (patient fidèle à son médecin traitant par confiance) de la continuité contrainte (patient vivant en zone à faible densité médicale n'ayant pas d'alternative) — deux situations aux implications politiques très différentes.
- L'UPC ne mesure pas la qualité de la relation avec le prestataire habituel ni la pertinence des soins délivrés — un patient suivi exclusivement par un prestataire sous-qualifié aura un UPC élevé mais une mauvaise qualité de soins.
- Les spécialités avec suivi de longue durée (oncologie, dialyse) génèrent mécaniquement des UPC élevés sans que cela reflète une coordination de parcours supérieure — stratifier l'analyse par type de prestataire dominant.

## Références
- [Edwards S.T. et al. — Outpatient care fragmentation and acute care utilization, JAMA Network Open 2022](https://doi.org/10.1001/jamanetworkopen.2022.30036)
- [Iashchenko I. et al. — Physician networks with audit and feedback vs regular care, Eur J Public Health 2023](https://doi.org/10.1093/eurpub/ckad135)
- [Breslau N., Reeb K.G. — Continuity of care in a university-based practice, J Med Educ 1975](https://pubmed.ncbi.nlm.nih.gov/1142463/)
- [CNAM - Données DCIR et médecin traitant](https://www.ameli.fr/)
- [SNDS - Accès aux données ambulatoires longitudinales](https://www.snds.gouv.fr/)
