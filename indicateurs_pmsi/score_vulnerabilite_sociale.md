# Score de Vulnérabilité Sociale des Patients

## Définition
Le score de vulnérabilité sociale des patients est un indicateur construit à partir des codes Z de la CIM-10 renseignés dans les diagnostics associés (DA) du PMSI MCO, identifiant les patients présentant des facteurs de vulnérabilité sociale documentés lors de leur hospitalisation : problèmes de logement, isolement social, difficultés économiques, problèmes familiaux, absence de protection sociale, situation irrégulière. Ces codes Z, dits « facteurs influant sur l'état de santé et le recours aux services de santé », sont sous-utilisés en France mais constituent une mine d'informations sur la charge médico-sociale que le GHT doit absorber. Un score élevé sur un service ou un territoire révèle une patientèle socialement fragilisée nécessitant une coordination renforcée avec les travailleurs sociaux, les structures médico-sociales et les dispositifs de droit commun.

## Calcul
Le score de vulnérabilité sociale est calculé à deux niveaux :

**Niveau 1 — Indicateur de présence binaire :**
```
Patient socialement vulnérable = 1 si au moins un code Z de vulnérabilité sociale présent en DA, 0 sinon

Taux de vulnérabilité sociale (%) = (Séjours avec ≥ 1 code Z de vulnérabilité / Total séjours MCO) × 100
```

**Niveau 2 — Score composite (0-10 points) :**

| Domaine | Codes CIM-10 | Poids |
|---|---|---|
| Logement précaire / sans domicile | Z59.0 (SDF), Z59.1 (logement inadéquat), Z59.2 (mésentente au domicile) | +3 |
| Isolement social | Z60.2 (vie seule), Z60.3 (difficulté d'acculturation), Z60.4 (exclusion sociale) | +2 |
| Difficultés économiques | Z59.5 (extrême pauvreté), Z59.6 (faibles revenus), Z59.7 (précarité ressources) | +3 |
| Problèmes familiaux | Z63.0 (problèmes conjugaux), Z63.4 (disparition membre famille), Z63.6 (parent absent) | +1 |
| Absence / rupture de protection sociale | Z59.4 (absence de soins appropriés), Z76.0 (demande de soins répétée injustifiée) | +1 |
| **Score total** | | **0-10** |

```
Score composite de vulnérabilité = Σ poids_i × présence_code_i

Classification :
  Score 0     → Pas de vulnérabilité sociale documentée
  Score 1-3   → Vulnérabilité légère (1 ou 2 facteurs isolés)
  Score 4-6   → Vulnérabilité modérée (plusieurs facteurs combinés)
  Score ≥ 7   → Vulnérabilité sévère (cumul de facteurs, prise en charge médico-sociale indispensable)
```

**Précisions méthodologiques** :
- Les codes Z de vulnérabilité sociale sont identifiés dans les DA uniquement (le DP est réservé au motif médical principal d'hospitalisation).
- Le codage de ces codes Z est très hétérogène entre établissements et entre services — un taux faible peut refléter un sous-codage plutôt qu'une faible prévalence réelle.
- La liste des codes Z pertinents peut être complétée par des codes connexes : Z55 (problèmes liés à l'éducation), Z56 (problèmes liés à l'emploi), Z57 (exposition professionnelle).
- L'indicateur peut être croisé avec le FDep (indice de défavorisation géographique) pour distinguer la vulnérabilité individuelle (codes Z) de la vulnérabilité contextuelle (zone de résidence défavorisée).

## Utilité
- **Identification des patients nécessitant une intervention médico-sociale** : les patients avec un score de vulnérabilité élevé doivent bénéficier d'un bilan social dès l'admission et d'une coordination renforcée à la sortie (assistante sociale, PASS, CCAS, SIAO pour les sans-abri).
- **Dimensionnement du travail social hospitalier** : quantifier la charge médico-sociale réelle du GHT pour justifier les effectifs d'assistantes sociales et de coordinateurs de soins en proportion des besoins documentés.
- **Anticipation des difficultés de sortie** : un score de vulnérabilité élevé est associé à une DMS plus longue (attente de solutions de sortie adaptées) et à un taux de réadmission plus élevé — son calcul précoce dans le séjour permet d'anticiper l'organisation de la sortie.
- **Analyse territoriale intra-GHT** : comparer les scores de vulnérabilité sociale entre les établissements et entre les bassins de vie du GHT pour identifier les zones de concentration de la précarité et adapter les ressources médico-sociales en conséquence.
- **Dialogue avec les collectivités et le médico-social** : les données de vulnérabilité sociale issues du PMSI sont un argument objectif pour les partenariats avec les CCAS, les SIAO, les EHPAD et les associations d'aide à domicile.

## Sources de Données
- **PMSI MCO** : codes Z de la CIM-10 renseignés en diagnostics associés (DA) — disponibles dans les fichiers RSA locaux et dans la base nationale PMSI.
- **ScanSanté** : module de recherche par diagnostic associé permettant d'identifier les séjours avec codes Z de vulnérabilité, sans traitement algorithmique supplémentaire.
- **Données locales DIM** : extraction des codes Z par service, par établissement et par période pour le calcul du score composite et l'analyse des tendances.
- **Croisement FDep (INSEE/INSERM)** : pour distinguer la vulnérabilité individuelle (codes Z PMSI) de la vulnérabilité contextuelle (zone géographique défavorisée) et identifier les situations de double vulnérabilité.

## Exemple de Valeurs
- **Taux de séjours avec au moins un code Z de vulnérabilité sociale** : 2-8 % dans les établissements qui codent activement ces diagnostics ; probablement 15-25 % de prévalence réelle dans les populations hospitalisées urbaines précaires.
- **Services avec taux de vulnérabilité élevé** : psychiatrie adulte (15-30 % de patients vulnérables documentés), médecine interne et gériatrie (10-20 %), UHCD/urgences (8-15 %).
- **Z59.0 (sans domicile fixe)** : 0,5-2 % des séjours MCO dans les CHU et CHG des grandes agglomérations, pouvant dépasser 5 % dans certains services d'urgences urbains.
- **Impact sur la DMS** : les séjours avec codes Z de vulnérabilité sociale ont une DMS 1,5 à 2,5 fois supérieure à la moyenne du GHM, du fait des difficultés d'organisation de la sortie.
- **Taux de réadmission à 30j** : 25-40 % chez les patients avec score de vulnérabilité ≥ 4, contre 10-15 % chez les patients sans vulnérabilité documentée.
- **Sous-codage estimé** : des études comparant le codage Z avec les données des assistantes sociales montrent que seuls 20-40 % des patients réellement précaires sont identifiés par les codes Z dans le PMSI — l'indicateur mesure un plancher, pas la réalité.

## Limites
- **Sous-codage massif** : le codage des codes Z de vulnérabilité sociale est très variable selon les établissements et les cultures de service — un faible score peut refléter un sous-codage systématique plutôt qu'une faible prévalence réelle de la précarité.
- **Dépendance aux pratiques locales** : un établissement qui forme activement ses équipes au codage des codes Z affichera un score plus élevé qu'un établissement identique qui ne code pas ces facteurs — les comparaisons inter-établissements sans audit préalable du codage sont peu fiables.
- **Granularité insuffisante** : les codes Z CIM-10 décrivent des situations générales mais ne capturent pas la complexité des situations sociales réelles (cumul de facteurs, dynamique temporelle, ressources informelles disponibles).
- L'indicateur ne mesure que la vulnérabilité sociale documentée lors de l'hospitalisation — les patients précaires qui n'accèdent pas aux soins ou qui hospitalisent peu sont invisibles dans le PMSI.
- La pondération des codes Z dans le score composite est arbitraire et non validée cliniquement en France — une validation locale sur des données médico-sociales croisées est recommandée avant utilisation en pilotage.

## Références
- [OMS - CIM-10 codes Z : facteurs influant sur l'état de santé](https://icd.who.int/browse10/2019/en#/Z55-Z65)
- [HAS - Précarité et santé : outils d'identification et prise en charge](https://www.has-sante.fr/)
- [ATIH - Codage des diagnostics associés dans le PMSI](https://www.atih.sante.fr/)
- [DREES - Précarité et recours aux soins hospitaliers](https://www.drees.solidarites-sante.gouv.fr/)
- [FNARS / Fédération des acteurs de la solidarité - Santé et précarité](https://www.federationsolidarite.org/)
