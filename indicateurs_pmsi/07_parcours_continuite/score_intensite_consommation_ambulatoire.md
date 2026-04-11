# Score d'Intensité de Consommation de Soins Ambulatoires

## Définition

Le score d'intensité de consommation de soins ambulatoires est un indicateur composite calculé intégralement à partir du DCIR, mesurant le volume total et la nature de la consommation de soins ambulatoires pour une population de référence (patients ALD résidant sur le territoire du GHT) sur une période de 12 mois. Il combine quatre dimensions : (1) les consultations médicales et paramédicales (médecin généraliste, spécialistes), (2) les dispensations pharmaceutiques (nombre de lignes d'ordonnances, nombre de boîtes dispensées), (3) les actes infirmiers et de rééducation (infirmier à domicile NGAP, kinésithérapie), (4) les examens biologiques (actes de biologie NABM). Contrairement aux indicateurs mono-dimensionnels, ce score composite capture la trajectoire complète de recours aux soins ambulatoires et permet une stratification des patients en profils de consommation : insuffisante (risque de décompensation), appropriée, et excessive (risque de soins fragmentés ou de polymédication). Cette stratification est directement actionnelle par les programmes de coordination et de case management du GHT.

## Calcul

Les quatre dimensions du score sont calculées par patient ALD sur 12 mois à partir des tables DCIR, puis agrégées en un score composite normalisé.

```
Dimensions du score (par patient ALD, sur 12 mois) :

D1 — Consultations médicales (DCIR ER_PRS_F) :
  → Nombre de consultations MG (PSP_SPE_COD=01)
  → Nombre de consultations spécialistes (PSP_SPE_COD ≠ 01)
  → Nombre de praticiens distincts consultés (fragmentation)

D2 — Dispensations pharmaceutiques (DCIR ER_PHA_F) :
  → Nombre de lignes de dispensation (médicaments distincts)
  → Nombre total de boîtes dispensées
  → Nombre de classes ATC distinctes
  → Score de polymédication : ≥5 classes ATC = polymédication ; ≥10 = hyperpolymédication

D3 — Actes infirmiers et rééducation (DCIR ER_PRS_F) :
  → Nombre d'actes NGAP infirmiers (codes AMI/AIS)
  → Nombre de séances de kinésithérapie (codes AMK)
  → Présence d'une HAD ou d'un SSIAD (codes ETE_CAT_COD)

D4 — Biologie ambulatoire (DCIR ER_BIO_F ou ER_PRS_F) :
  → Nombre d'actes de biologie (cotation BHN/B)
  → Nombre de prescripteurs distincts pour la biologie
  → Nombre d'examens redondants (même cotation ≥2× en 30 jours, prescripteurs différents)

Score composite :
  → Score brut = somme pondérée des 4 dimensions (pondération à calibrer sur données locales)
  → Score normalisé par ALD et par tranche d'âge (Z-score par rapport à la moyenne du GHT)
  → Percentile d'intensité : P10 (sous-consommateurs), P50 (médiane), P90 (surconsommateurs)

Profils d'intensité :
  P0–P20   : consommation insuffisante → risque de rupture de suivi
  P20–P80  : consommation appropriée
  P80–P95  : consommation élevée → vérifier pertinence
  P95–P100 : surconsommation critique → fragmentation, polymédication sévère
```

## Utilité

- **Identification des patients en sous-consommation** : les patients ALD au percentile ≤20 sont ceux à risque de rupture de suivi — population prioritaire pour les programmes de case management et de médiation en santé du GHT
- **Détection du surconsommateur fragmenté** : les patients P95+ avec >10 prescripteurs différents dans l'année concentrent les risques d'interactions médicamenteuses, de redondances diagnostiques et d'iatrogénie — indicateur de ciblage pour les bilans de médication (entretien pharmaceutique)
- **Benchmark inter-établissements** : comparer le profil de consommation des patients habitant les zones d'attractivité de chaque établissement membre du GHT pour identifier les disparités territoriales d'accès
- **Évaluation des programmes de coordination** : mesurer si les patients inclus dans les programmes PRADO, HAD, ou télésurveillance ont un profil de consommation plus approprié (déplacement vers les percentiles médians)
- **Anticipation des réadmissions** : les patients passant d'une consommation appropriée à une sous-consommation (chute du score entre deux années consécutives) présentent un risque de réadmission à 6 mois multiplié par 1,8 à 2,5
- **Pilotage de l'offre ambulatoire** : cartographier les zones où la sous-consommation est structurelle (insuffisance d'offre vs non-recours) pour prioriser les investissements du GHT

## Sources de Données

- **DCIR ER_PRS_F** : table des prestations de soins — consultations médicales (MG et spécialistes), actes NGAP infirmiers (AMI/AIS), séances de kinésithérapie (AMK)
- **DCIR ER_PHA_F** : table des dispensations pharmaceutiques — lignes de dispensation, boîtes délivrées, classification ATC
- **DCIR ER_BIO_F** : table des actes de biologie ambulatoire — cotations BHN/B, prescripteurs
- **DCIR IR_IMB_R** : référentiel des ALD — identification des patients ALD, code pathologie, date d'entrée en ALD
- **DCIR IR_BEN_R** : référentiel des bénéficiaires — commune de résidence, identifiant médecin traitant
- **INSEE** : données communales de dérivation sociale (indice de défavorisation, densité médicale) pour contextualiser les profils de consommation

## Exemple de Valeurs

- **Patient ALD médian (diabète type 2, ALD5)** : environ 12 à 15 consultations MG/spécialistes par an, 8 à 10 classes médicamenteuses distinctes, 4 à 6 séries d'examens biologiques
- **Polymédication (≥5 classes ATC)** : 40 à 50 % des patients ALD de plus de 75 ans
- **Hyperpolymédication (≥10 classes ATC)** : 10 à 15 % des patients ALD de plus de 75 ans
- **Patients avec ≥10 prescripteurs distincts dans l'année** : 5 à 8 % des patients ALD à l'échelle nationale
- **Chute du score ≥30 % entre deux années consécutives** : associée à un risque de réadmission multiplié par 2 dans des cohortes françaises validées
- **Sous-consommation (P≤20)** : concerne environ 15 à 20 % des patients ALD, concentrée dans les zones rurales et défavorisées

## Limites

- Les pondérations du score composite sont arbitraires tant qu'elles ne sont pas calibrées sur des résultats cliniques locaux — l'interprétation requiert une validation locale
- Une consommation élevée ne signifie pas nécessairement des soins inappropriés : les patients complexes génèrent structurellement davantage d'actes
- Le DCIR ne trace que les actes remboursés — les soins informels, les consultations en centres de soins gratuits et les actes non remboursés sont invisibles
- Le score est calculé sur une population ALD et n'est pas ajusté sur la charge de comorbidités — la comparaison entre territoires nécessite une standardisation
- L'analyse longitudinale suppose une stabilité de l'identifiant patient dans le temps (stabilité du NIR crypté d'une année sur l'autre)

## Références

- [CNAM — Tableau de bord de la consommation de soins par pathologie (Cartographie des pathologies)](https://www.ameli.fr/)
- [DREES — Enquête sur la consommation de soins ambulatoires des patients ALD](https://www.drees.solidarites-sante.gouv.fr/)
- [SNDS — Documentation des tables DCIR ER_PRS_F, ER_PHA_F, ER_BIO_F](https://www.snds.gouv.fr/)
- [Tuppin P. et al. — Value of a national administrative database to guide public decisions: from the French national health insurance inter-régimes information system (SNIIRAM) to the national health data system (SNDS), Rev Epidemiol Sante Publique 2017](https://pubmed.ncbi.nlm.nih.gov/28756014/)
