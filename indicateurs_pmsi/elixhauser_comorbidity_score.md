# Score de Comorbidité d'Elixhauser

## Définition
Le score de comorbidité d'Elixhauser (Elixhauser Comorbidity Index, ECI) est un système de pondération des comorbidités développé par Anne Elixhauser et al. (1998) à partir des données administratives hospitalières américaines, puis adapté à la CIM-10 par van Walraven et al. (2009). Il identifie 31 catégories de comorbidités dans les codes de diagnostic des séjours hospitaliers et leur attribue un poids positif ou négatif en fonction de leur association avec la mortalité et la consommation de ressources. Contrairement à l'indice de Charlson (17 comorbidités, poids additifs simples), l'Elixhauser propose une modélisation plus granulaire et statistiquement plus performante pour prédire la mortalité hospitalière, la durée de séjour et les coûts — en particulier pour des populations hétérogènes et des pathologies non cancéreuses. Il est aujourd'hui considéré comme le gold standard international pour l'ajustement au risque en épidémiologie hospitalière.

## Calcul
Le score d'Elixhauser est calculé en deux étapes :

**Étape 1 — Identification des 31 comorbidités par codes CIM-10 (DA uniquement) :**

| Comorbidité | Codes CIM-10 (exemples) | Poids van Walraven |
|---|---|---|
| Insuffisance cardiaque congestive | I09.9, I11.0, I13.0, I50 | +7 |
| Arythmie cardiaque | I44-I49, R00 | +5 |
| Valvulopathie | A52.0, I05-I08, I34-I38 | -1 |
| Maladie pulmonaire | I27.8, I27.9, J40-J47, J67, J68.4 | +3 |
| Troubles cognitifs | F00-F03, F05.1, G30, G31.1 | +5 |
| Maladie cérébro-vasculaire | G45, G46, H34.0, I60-I69 | 0 |
| Maladie périphérique vasculaire | I70, I71, I73.1, I73.8, I77.1 | -3 |
| Diabète sans complication | E10.0, E11.0, E12.0 | 0 |
| Diabète avec complication | E10.2-E10.8, E11.2-E11.8 | -1 |
| Hypothyroïdie | E00-E03 | 0 |
| Insuffisance rénale | I12.0, I13.1, N18, N19, N25.0 | +5 |
| Hépatopathie | B18, I85, I86.4, K70-K77 | +11 |
| Ulcère gastro-duodénal | K25-K28 | 0 |
| SIDA/VIH | B20-B22 | 0 |
| Lymphome | C81-C85, C88, C96 | +9 |
| Cancer métastatique | C77-C80 | +12 |
| Tumeur solide sans métastase | C00-C76 | +4 |
| Polyarthrite rhumatoïde | L40.5, M05-M08, M09, M30-M35 | 0 |
| Coagulopathie | D65-D68, D69.1, D69.3-D69.6 | +3 |
| Obésité | E66 | -5 |
| Perte de poids | E40-E46, R634 | +6 |
| Désordres électrolytiques | E22.2, E86-E87 | +5 |
| Anémie par perte sanguine | D50.0 | -2 |
| Anémie déficitaire | D50.1-D53 | -2 |
| Abus d'alcool | F10, E52, G62.1, Z50.2 | +0 |
| Abus de drogues | F11-F16, F18-F19 | -7 |
| Psychose | F20-F22, F24-F25, F28-F29 | 0 |
| Dépression | F32-F33 | -3 |
| Hypertension non compliquée | I10 | -1 |
| Hypertension compliquée | I11-I13, I15 | -2 |
| Paralysie | G04.1, G11.4, G80-G83, G35 | +5 |

**Étape 2 — Calcul du score composite :**
```
Score Elixhauser = Σ (poids_i × présence_comorbidité_i)

  → Score peut être négatif (comorbidités protectrices comme l'obésité ou la dépression en termes de mortalité)
  → Distribution typique : -10 à +30, médiane autour de 0-5
  → Utilisé en continu ou discrétisé en quartiles pour les analyses
```

**Précisions méthodologiques :**
- Les comorbidités sont identifiées uniquement dans les diagnostics associés (DA), pas dans le DP ni le DR, pour éviter de confondre le motif d'hospitalisation avec les comorbidités.
- La version van Walraven (2009) propose des poids négatifs pour certaines comorbidités (obésité, dépression) qui sont paradoxalement associées à une mortalité plus faible dans les données administratives — reflet d'un biais de sélection (ces patients sont plus souvent hospitalisés pour des pathologies moins sévères).
- Une version simplifiée à 29 comorbidités sans poids (présence/absence) est utilisée pour les analyses multivariées où chaque comorbidité est traitée comme covariable indépendante.

## Transposition PMSI France
La transposition de l'Elixhauser au PMSI français est excellente, avec des adaptations mineures :

- **Codes CIM-10 communs** : la CIM-10 FR utilisée en France est très proche de la CIM-10 CM américaine ; des tables de correspondance validées existent pour les quelques codes divergents.
- **Identification des DA** : le PMSI MCO renseigne systématiquement les diagnostics associés (DA), permettant l'identification des 31 comorbidités selon les règles de l'algorithme original.
- **Algorithmes open-source** : des implémentations en R (package `comorbidity`), Python et SAS sont disponibles et fonctionnent nativement sur des données CIM-10, utilisables directement sur les exports PMSI.
- **Validations françaises** : l'ECI a été validé sur données PMSI françaises dans plusieurs études (IRDES, publications hospitalières) avec des performances prédictives supérieures au Charlson pour la mortalité et les coûts.
- **Limite POA** : comme pour les PSI, l'absence de flag POA en France impose d'utiliser les DA comme proxy des comorbidités préexistantes.

## Utilité
- **Ajustement au risque plus précis que le Charlson** : l'ECI est supérieur au Charlson pour prédire la mortalité hospitalière, les réadmissions et les coûts dans les populations hétérogènes non cancéreuses — il est recommandé pour les études médico-économiques et les comparaisons inter-établissements.
- **Standardisation des indicateurs de qualité** : utiliser l'ECI comme covariable d'ajustement dans le calcul du taux de mortalité standardisé (SHMI, SMR) ou du taux de réadmission améliore l'équité des comparaisons entre établissements de casemix différents.
- **Segmentation des patients** : le score ECI permet de stratifier la patientèle du GHT en groupes homogènes de risque pour cibler les programmes de coordination et de gestion de cas.
- **Recherche clinique et épidémiologique** : l'ECI est la covariable d'ajustement la plus utilisée dans la littérature internationale pour les études sur données administratives hospitalières — son calcul sur PMSI permet la comparaison avec la littérature.
- **Complement du CCI** : l'utilisation conjointe du Charlson (meilleur pour les pathologies cancéreuses) et de l'Elixhauser (meilleur pour les pathologies cardiovasculaires, rénales, psychiatriques) offre une vision plus complète de la charge en comorbidités.

## Sources de Données
- **PMSI MCO** : codes CIM-10 des diagnostics associés (DA) de chaque RSS pour l'identification des 31 comorbidités.
- **Package R `comorbidity`** : implémentation open-source des algorithmes Elixhauser et Charlson en CIM-10, applicable directement sur les exports PMSI (Gasparini A., 2018, JOSS).
- **ATIH / ScanSanté** : base nationale PMSI pour le calcul à grande échelle sur l'ensemble des établissements du GHT.
- **Référence originale** : Elixhauser A. et al., *Comorbidity measures for use with administrative data*, Medical Care, 1998.
- **Adaptation CIM-10** : van Walraven C. et al., *A modification of the Elixhauser comorbidity measures into a point system*, Medical Care, 2009.

## Exemple de Valeurs
- **Score ECI médian en MCO général** : 2-5 points selon le type d'établissement et la spécialité.
- **Services de médecine interne / gériatrie** : ECI médian 8-15, avec une large dispersion (0 à >25).
- **Chirurgie orthopédique programmée** : ECI médian 0-3 (patients sélectionnés, comorbidités contrôlées).
- **Performance prédictive (AUC mortalité hospitalière)** : ECI ~0,78-0,82 vs Charlson ~0,72-0,76 dans les études de comparaison sur données administratives.
- **Performance prédictive (AUC réadmission 30j)** : ECI ~0,68-0,72, légèrement supérieur au Charlson (~0,65-0,69).
- **Corrélation ECI-coût** : chaque point supplémentaire d'ECI est associé à une augmentation de 8-12 % du coût moyen du séjour dans les études médico-économiques françaises.

## Limites
- Dépendance totale à la qualité du codage des DA dans le PMSI : un sous-codage systématique des comorbidités (fréquent en France) sous-estime l'ECI et biaise les comparaisons inter-établissements.
- Les poids de van Walraven (2009) ont été calculés sur des données canadiennes ; leur transposition directe aux données françaises n'est pas validée dans toutes les publications — une recalibration locale est recommandée pour les usages prédictifs.
- Certains poids contre-intuitifs (obésité = -5, dépression = -3) reflètent des biais de sélection dans les données administratives et ne doivent pas être interprétés comme des effets biologiques protecteurs.
- Non disponible nativement dans ScanSanté : le calcul requiert un traitement algorithmique des données PMSI brutes avec un langage de programmation (R, Python, SAS).
- Le score agrégé masque les effets individuels de chaque comorbidité : pour les analyses cliniques fines, l'utilisation des 31 comorbidités comme variables binaires séparées est préférable au score composite.

## Références
- [Elixhauser A. et al., Comorbidity measures for use with administrative data, Medical Care, 1998](https://doi.org/10.1097/00005650-199801000-00004)
- [van Walraven C. et al., A modification of the Elixhauser comorbidity measures into a point system, Medical Care, 2009](https://doi.org/10.1097/MLR.0b013e31819432e5)
- [Package R comorbidity (Gasparini, 2018)](https://CRAN.R-project.org/package=comorbidity)
- [IRDES - Mesure des comorbidités sur données PMSI](https://www.irdes.fr/)
- [ATIH - Base nationale PMSI et diagnostics associés](https://www.atih.sante.fr/)
