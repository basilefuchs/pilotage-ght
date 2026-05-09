# Part des Séjours Non Programmés chez les 10 % Patients les Plus Consommateurs

## Définition

Les patients les plus consommateurs en MCO (top décile en valorisation, cf. fiche `part_valorisation_top_decile_patients_mco`) suivent deux trajectoires-types très différentes :

- **trajectoire programmée** : patients chir lourde élective, oncologie planifiée, transplantation — coûts élevés mais gérés en mode anticipé, faible marge de réduction par coordination ;
- **trajectoire subie** : patients chroniques décompensés à répétition (insuffisance cardiaque, BPCO, cirrhose, IRC, cancer chronique mal stabilisé), entrant majoritairement par les urgences ou en non-programmé — **cible privilégiée des programmes de coordination amont** (DAC, CPTS, ETP, télésuivi).

L'indicateur **part de séjours non programmés chez le top 10 %** mesure :

τ_NP_top10 = Σ_{séjours i ∈ patients top10%} 𝟙(mode_entrée(i) = urgences ∪ non programmé) / Σ_{séjours i ∈ patients top10%} 1

Un τ_NP_top10 élevé signale une part importante de la queue de coût qui est **évitable par coordination amont** ; un τ_NP_top10 faible suggère une queue dominée par la chirurgie programmée et la cancérologie planifiée.

Positionnement vs existant : les indicateurs `taux_activite_non_programmee` et `taux_bed_blocking_mco_attente_ssr` raisonnent au niveau des séjours toutes patientèles confondues. Cet indicateur **conditionne** la non-programmation à l'appartenance au top décile, ce qui en fait un signal de **défaut de coordination amont sur la patientèle complexe** plutôt qu'une mesure d'engorgement des urgences.

## Calcul

```
Périmètre :
  → Tous les séjours MCO (RSA) sur fenêtre annuelle, chaînés par ANO
  → Identification du top 10 % patients en valorisation (cf. fiche P10)

Étapes :
  1. Calculer V_i (valorisation totale) pour chaque patient i
  2. top10% = { i : V_i ≥ percentile_90(V) }
  3. Filtrer les séjours des patients du top10% : S_top = { séjours j : patient(j) ∈ top10% }
  4. Identifier les séjours non programmés :
       NP = { j : mode_entrée(j) ∈ {entrée par urgences, mutation/transfert non programmé} }
  5. τ_NP_top10 = |S_top ∩ NP| / |S_top|
```

**Définition « non programmé »** dans le RSA :

```
Variables RSA (guide méthodologique MCO ATIH) :
  - mode d'entrée
  - provenance
  - passage par les urgences (UF urgences avant l'UMA d'hospitalisation)

Convention recommandée :
  Non programmé = passage urgences = OUI
                  OU (mode_entrée = mutation/transfert ET provenance = urgences)
                  OU (caractère urgent du séjour explicitement codé)

  Programmé = absence de passage urgences ET admission directe en service d'hospi
```

Indicateurs dérivés :

```
τ_NP_top1   : sur la queue extrême (signal très ciblé sur les chroniques décompensés)
τ_NP_reste  : pour la population hors top10% (référence de comparaison)
Ratio NP    : τ_NP_top10 / τ_NP_reste
              → > 1 : non-programmation surreprésentée chez les gros consommateurs
              → < 1 : queue dominée par le programmé (chir/onco lourde)
```

Stratifications utiles :
- par CMD (où la non-programmation se concentre-t-elle dans la queue ?) ;
- par tranche d'âge (≥ 75 ans versus < 65 ans : profils gériatrique chronique vs chronique sévère adulte) ;
- par établissement du GHT (le centre de support concentre-t-il les patients top10% non programmés ?).

## Utilité

- **Identifier les défauts de coordination amont sur la patientèle complexe** : un τ_NP_top10 > 60 % suggère qu'une majorité des séjours de patients gros consommateurs arrive en mode subi — déclencheur de programme parcours, télésuivi, IDE de coordination.
- **Cibler les filières prioritaires** : la décomposition par CMD du top 10 % non programmé identifie les pathologies à plus fort potentiel de coordination (IC, BPCO, IRC, cancer chronique).
- **Mesurer l'efficacité d'un programme parcours** : une intervention efficace doit faire **baisser τ_NP_top10** (les patients enrôlés ont moins d'épisodes décompensés).
- **Argumenter en CME / ARS** : « 70 % des séjours du top 10 % de nos patients arrivent par les urgences » est un message synthétique fort pour justifier des moyens de coordination.
- **Différencier les profils d'établissements du GHT** : un site chir programmée pure aura un τ_NP_top10 bas (queue = chir lourde élective) ; un CH généraliste avec gériatrie aura un τ_NP_top10 élevé (queue = chroniques décompensés).
- **Identifier les patients « high-need high-cost actionnable »** : top10% × non-programmé = sous-population sur laquelle l'effet attendu d'un programme de coordination est maximal.

## Sources de Données

- **PMSI MCO — RSA** : variables ANO patient, mode d'entrée, provenance, passage urgences (UF urgences en amont de l'UMA), valorisation GHS.
- **PMSI MCO — FICHCOMP** : molécules onéreuses + DMI pour calcul exact de V_i.
- **Tarifs GHS / UCD / LPP** ATIH pour la valorisation.
- **Optionnel** : RPU (Résumé de Passage aux Urgences) pour caractériser plus finement le passage amont (motif de recours, gravité).

## Exemple de Valeurs

Ordres de grandeur (sources : Amundsen 2024 [DOI](https://doi.org/10.1186/s12913-024-12051-3) — patients à coût élevé majoritairement hospitalisés ; ATIH analyse activité MCO 2023 [URL](https://www.atih.sante.fr/analyse-de-l-activite-hospitaliere-2023) ; transposition expert) :

- **CHU généraliste, population MCO totale** : τ_NP ≈ 35–45 %.
- **CHU, top 10 % gros consommateurs** : τ_NP_top10 ≈ 50–65 % (queue plus subie que la moyenne, ratio NP ≈ 1,3–1,6).
- **CH généraliste avec gériatrie** : τ_NP_top10 ≈ 60–75 % (queue dominée par chroniques décompensés).
- **Clinique chir programmée** : τ_NP_top10 ≈ 10–20 % (queue dominée par chir lourde élective).
- **Top 1 % patients** : τ_NP_top1 souvent > τ_NP_top10 dans les CH (queue extrême = très polyhospitalisés en décompensation).

Seuils d'alerte indicatifs :
- τ_NP_top10 > 70 % et τ_NP_top10 / τ_NP_reste > 1,5 → forte non-programmation concentrée sur la queue, prioriser un programme parcours ciblé.
- Δτ_NP_top10 > +5 points/an à structure constante → dégradation de la coordination amont.

## Limites

- **Hétérogénéité du codage du mode d'entrée** : les conventions varient entre établissements (passage urgences en UF dédiée vs admission directe avec passage médecin urgentiste). Standardiser localement la définition « non programmée » avant tout benchmark.
- **« Non programmé légitime »** : tout passage urgences n'est pas évitable (AVC ischémique, IDM ST+, polytrauma) — le τ_NP_top10 ne mesure pas l'évitabilité, seulement le caractère non programmé. Pour mesurer l'évitabilité, croiser avec une liste ACSC (Ambulatory Care Sensitive Conditions) — cf. indicateurs de réadmission.
- **Effet de la sortie des urgences sans hospi** : les patients qui passent aux urgences sans admission ne figurent pas dans le RSA — ne pas confondre cet indicateur avec un taux de recours aux urgences.
- **Composition de patientèle** : un GHT à forte activité chir programmée aura mécaniquement un τ_NP_top10 bas — toujours stratifier ou ajuster sur le case-mix.
- **Indicateur retardé** : nécessite la fin de l'année pour identifier le top 10 % définitif ; en pilotage infra-annuel, utiliser un top 10 % glissant 12 mois ou un seuil V_i absolu (ex. > 50 k€/an).
- **Volume minimal** : sous 5 000 patients/an, le top 10 % est trop petit (<500 patients, faible nombre de séjours) pour une mesure stable.

## Références

- Amundsen O. et al. — Patient characteristics and healthcare use for high-cost patients with musculoskeletal disorders in Norway. *BMC Health Serv Res* 2024 — [DOI](https://doi.org/10.1186/s12913-024-12051-3) (PMID:39695620)
- Trenaman L. et al. — High-need high-cost patient prediction. *Qual Life Res* 2025 — [DOI](https://doi.org/10.1007/s11136-025-04008-8) (PMID:40632370)
- Garcia J. et al. — Concentration of High-Cost Surgical Patients. *Laryngoscope* 2024 — [DOI](https://doi.org/10.1002/lary.31618) (PMID:38973626)
- ATIH — Analyse de l'activité hospitalière 2023 — [URL](https://www.atih.sante.fr/analyse-de-l-activite-hospitaliere-2023)
- ATIH — Guide méthodologique MCO en vigueur (variables mode d'entrée, provenance, passage urgences) — [atih.sante.fr](https://www.atih.sante.fr/)
- Purdy S. et al. — Ambulatory care sensitive conditions: terminology and disease coding need standardization. *Public Health* 2009 — référence ACSC pour notion d'évitabilité
