# Indice de Charlson Moyen par Séjour (CCI)

## Définition
L'indice de Charlson (Charlson Comorbidity Index, CCI) est un score de comorbidité calculé algorithmiquement à partir des codes CIM-10 présents dans les diagnostics associés (DA) du PMSI. Il attribue un poids à chacune des 17 pathologies chroniques de l'index original (infarctus du myocarde, insuffisance cardiaque, BPCO, diabète, insuffisance rénale, cancer, VIH, etc.) et produit un score composite reflétant la charge globale en comorbidités du patient. Plus le CCI est élevé, plus le risque de mortalité et de consommation de ressources est important. Le CCI moyen par séjour, calculé à l'échelle d'un établissement ou d'un GHT, est un indicateur de lourdeur clinique réelle, bien plus précis que le nombre brut de diagnostics associés ou l'indice de lourdeur des cas (ILC) basé sur les seuls GHM.

## Calcul
Le CCI moyen par séjour est calculé comme suit :

```
CCI séjour = Σ (poids_i × présence_comorbidité_i)   pour i dans les 17 comorbidités de Charlson

CCI moyen GHT = Σ CCI séjours / Nombre total de séjours
```

**Pondération des comorbidités (Charlson 1987, adapté CIM-10) :**

| Poids | Comorbidités |
|---|---|
| 1 | Infarctus du myocarde, Insuffisance cardiaque congestive, Maladie vasculaire périphérique, Maladie cérébrovasculaire, Démence, BPCO, Connectivite, Ulcère gastro-duodénal, Hépatopathie légère, Diabète sans complication |
| 2 | Hémiplégie, Insuffisance rénale modérée à sévère, Diabète avec complications, Tumeur solide sans métastase, Leucémie, Lymphome |
| 3 | Hépatopathie modérée à sévère |
| 6 | Tumeur solide avec métastases, SIDA |

**Codes CIM-10 associés** (exemples) :
- Insuffisance cardiaque : I50
- BPCO : J44
- Diabète sans complication : E10.0-E14.0
- Tumeur solide sans métastase : C00-C26, C30-C34, C37-C41, C43, C45-C58, C60-C76, C81-C85, C88, C90-C97
- Insuffisance rénale modérée à sévère : N03, N05, N18, N19, N25

**Précisions méthodologiques** :
- Le calcul porte sur l'ensemble des diagnostics du RSS (DP + DR + DA) pour maximiser la capture des comorbidités.
- La version de Quan et al. (2005) propose une adaptation CIM-10 validée avec des codes actualisés, préférable à la version originale.
- Le CCI peut être calculé par séjour, puis agrégé en moyenne, médiane ou distribution par classe (CCI 0, 1-2, 3-4, ≥5) à l'échelle d'un établissement ou d'une filière.

## Utilité
- **Mesure de la lourdeur clinique réelle** : le CCI capture la charge en comorbidités indépendamment de la classification GHM, révélant des différences de complexité invisible dans l'ILC ou le CMI.
- **Ajustement au risque** : le CCI est la covariable d'ajustement de référence pour les analyses de mortalité, de réadmission et de durée de séjour — il permet des comparaisons entre établissements équitables et robustes.
- **Identification des patients complexes** : les séjours avec CCI ≥ 3 représentent une population nécessitant une coordination renforcée et des ressources spécifiques (gériatrie, HAD, soins palliatifs).
- **Benchmarking casemix clinique** : comparer le CCI moyen du GHT avec des établissements comparables pour objectiver la prise en charge de patients plus lourds que la moyenne nationale.
- **Pilotage des filières chroniques** : segmenter les patients par CCI pour prioriser les programmes de gestion de cas (ETP, HAD, coordination DAC) sur les profils à plus fort risque.

## Sources de Données
- **PMSI MCO** : ensemble des codes CIM-10 renseignés dans les RSS (DP, DR, DA) pour l'application de l'algorithme de Charlson.
- **ATIH / ScanSanté** : les diagnostics associés par séjour sont disponibles dans la base nationale PMSI pour le calcul du CCI à grande échelle.
- **SNDS** : pour le calcul du CCI sur des trajectoires longitudinales multi-séjours (CCI cumulatif sur 12 mois glissants), plus robuste que le CCI intra-séjour.
- **Référence algorithmique** : Quan H. et al., *Coding Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data*, Medical Care, 2005.

## Exemple de Valeurs
- **CCI moyen national (MCO, adultes)** : entre 1,5 et 2,5 selon les établissements et les spécialités.
- **Services de médecine interne / gériatrie** : CCI moyen souvent > 4, avec une forte proportion de séjours CCI ≥ 5.
- **Chirurgie orthopédique programmée** : CCI moyen 1,0-1,5 (patients sélectionnés, comorbidités gérées préopératoirement).
- **Urgences / médecine polyvalente** : CCI moyen 2,0-3,5, reflet de la polyvalence et de la précarité de la patientèle.
- **Patients CCI ≥ 3** : mortalité à 30 jours 3 à 5 fois supérieure à celle des patients CCI = 0 (données Charlson originales et réplications françaises).
- **CCI et DMS** : chaque point de CCI supplémentaire est associé en moyenne à 0,5-1 jour de DMS additionnelle en MCO.

## Limites
- Le CCI dépend directement de la qualité et de l'exhaustivité du codage des diagnostics associés dans le PMSI : un sous-codage des DA (fréquent) sous-estime systématiquement le CCI réel.
- Le score original date de 1987 et n'intègre pas certaines pathologies chroniques contemporaines (obésité morbide, apnée du sommeil, etc.) ; des versions étendues (Elixhauser, CCI-Quan) sont préférables.
- Le CCI intra-séjour ne capture que les comorbidités codées lors de l'hospitalisation : le calcul sur trajectoire longitudinale (SNDS, 12 mois glissants) est plus représentatif du fardeau réel du patient.
- N'est pas directement disponible en tant qu'indicateur natif dans ScanSanté : son calcul nécessite un traitement algorithmique des données PMSI brutes.
- La comparaison inter-établissements est biaisée si les pratiques de codage des DA diffèrent significativement.

## Références
- [Charlson M.E. et al., A new method of classifying prognostic comorbidity in longitudinal studies, Journal of Chronic Diseases, 1987](https://doi.org/10.1016/0021-9681(87)90171-8)
- [Quan H. et al., Coding Algorithms for Defining Comorbidities in ICD-9-CM and ICD-10 Administrative Data, Medical Care, 2005](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
- [ATIH - Base nationale PMSI et diagnostics associés](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des diagnostics associés](https://www.scansante.fr/)
