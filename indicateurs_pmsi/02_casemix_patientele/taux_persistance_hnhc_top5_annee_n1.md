# Taux de Persistance des Patients HNHC (Top 5 %) d'une Année sur l'Autre

## Définition

La littérature internationale sur les patients « high-need high-cost » (HNHC) — typiquement définis comme le top 5 % des coûts de santé annuels — distingue deux populations très différentes au sein de cette queue de distribution :

- les **HNHC persistants** : patients chroniques polypathologiques, dont les coûts élevés se reproduisent d'une année sur l'autre (cible de programmes de case management de long terme, parcours complexes, ETP) ;
- les **HNHC transitoires** : patients dont l'épisode coûteux est ponctuel (transplantation, polytrauma, chirurgie lourde, fin de vie) — non actionnables par un programme de coordination chronique.

Le **taux de persistance HNHC top 5 %** mesure la part des patients dans le top 5 % des coûts MCO en année N qui restent dans le top 5 % en année N+1 :

τ_persist = | top5%_N ∩ top5%_{N+1} | / | top5%_N ∩ vivants_{N+1} |

Le dénominateur exclut les patients décédés en N ou en N+1 (non éligibles à une intervention en N+1).

Positionnement vs existant : `coefficient_gini_consommation_hospitaliere` et `part_valorisation_top_decile_patients_mco` mesurent la concentration **statique** ; cet indicateur mesure la **stabilité longitudinale** de la queue, information indispensable pour le ciblage des programmes parcours. La métrique est fondée sur les travaux de Trenaman et al. (2025) sur la prédictibilité des HNHC.

## Calcul

```
Périmètre :
  → 2 années civiles N et N+1
  → Tous les patients ayant ≥ 1 séjour MCO en année N
  → Chaînage par identifiant patient (ANO) MCO + statut vital (DCD)

Étapes :
  1. Pour chaque patient i, calculer V_i^N et V_i^{N+1}
     (valorisation totale MCO, cf. fiche part_valorisation_top_decile)
  2. Identifier top5%^N = {i : V_i^N ≥ percentile_95(V^N)}
  3. Exclure de top5%^N les patients décédés avant fin N+1
  4. Identifier top5%^{N+1} parmi les patients vivants en N+1
       (recalculé sur la cohorte vivante de N+1)
  5. τ_persist = |top5%^N ∩ top5%^{N+1}| / |top5%^N \ décédés|
```

Indicateurs dérivés :

```
τ_persist_top1%   : persistance de la queue extrême (souvent 30–50 %)
τ_descent         : part du top5%^N qui sort vers le bas (intervention efficace ou transitoire)
τ_mortalite_top5% : part décédée — informe sur la composante "fin de vie" de la queue
τ_emergence       : part du top5%^{N+1} qui n'était PAS dans le top5%^N
                    (nouveaux entrants imprévus — utile pour calibrer la prédiction)
```

Suivi multi-années :

```
Persistance à 2 ans : top5%^N ∩ top5%^{N+1} ∩ top5%^{N+2}
  → permet d'identifier le noyau dur HNHC (typiquement 10–25 % du top5% initial)
```

Stratifications utiles :
- par tranche d'âge (les <65 ans HNHC persistants sont souvent des chroniques sévères : IRC dialysés, IC, BPCO, cancers chroniques) ;
- par CMD dominante en N ;
- par statut ALD (chaînage SNDS).

## Utilité

- **Distinguer les cibles HNHC** : un τ_persist de 60 % signifie que 60 % du top 5 % de l'année N reste dans le top 5 % l'année suivante — population éligible aux programmes de case management de long terme. Les 40 % restants sont des HNHC transitoires (chir lourde non récidivante, fin de vie, polytrauma) sur lesquels un programme chronique aurait peu d'effet.
- **Calibrer le retour sur investissement d'un programme parcours** : seul τ_persist × P5 (cf. fiche P10) est l'enveloppe réaliste de coûts récurrents potentiellement réductibles.
- **Évaluer la performance prédictive d'un score de risque** : si l'on construit un score HNHC (modèle prédictif sur N pour cibler en N+1), τ_emergence donne le plafond inatteignable (patients HNHC en N+1 invisibles en N).
- **Suivre l'effet d'un programme** : un programme efficace doit faire **baisser τ_persist** sur la cohorte enrôlée par rapport à un comparateur (les patients case-managés sortent davantage du top 5 %).
- **Identifier la composante fin de vie** : τ_mortalite_top5% donne la fraction de la queue MCO qui est en réalité une trajectoire de fin de vie — orientation vers les filières palliatives plutôt que case management.
- **Benchmark territorial** : un GHT avec un τ_persist élevé concentre des patients chroniques mal stabilisés ; un GHT avec τ_persist faible et τ_mortalite élevé a un profil chir lourde / fin de vie.

## Sources de Données

- **PMSI MCO — RSA** sur deux années consécutives, chaîné par ANO patient.
- **PMSI MCO — FICHCOMP** pour molécules onéreuses et DMI (calcul de V_i complet).
- **Tarifs GHS / UCD / LPP** ATIH pour valorisation.
- **Statut vital** : variable « sortie par décès » du RSA pour la mortalité hospitalière ; pour la mortalité totale (toutes causes, hors hôpital), chaînage SNDS / RNIPH ou base CepiDc.
- Optionnel : **PMSI SSR / HAD / PSY** pour une vue HNHC tous champs (recommandé : un patient peut « basculer » MCO → HAD).

## Exemple de Valeurs

Ordres de grandeur (transposition d'études internationales — Trenaman 2025, modèles de persistance HNHC ; à valider sur données françaises) :

- **τ_persist top 5 % à 1 an** : 50–65 % en population MCO générale ; 70–85 % sur cohortes ALD chroniques (dialyse, IC, cancer chronique).
- **τ_persist top 1 %** : 30–45 % à 1 an (queue extrême plus volatile car forte composante fin de vie).
- **τ_persist à 2 ans (intersection N, N+1, N+2)** : 25–40 % (noyau dur HNHC).
- **τ_mortalite_top5%** : 15–25 % par an (vs ≈ 3–5 % en population MCO totale) — la queue concentre mécaniquement la fin de vie.
- **τ_emergence** : 35–50 % du top 5 %^{N+1} est nouveau d'une année sur l'autre — limite intrinsèque de tout modèle prédictif basé sur l'historique.

## Limites

- **Mortalité comme « sortie »** : un patient HNHC qui décède sort mécaniquement du top 5 % l'année suivante ; sans correction, τ_persist serait artificiellement bas. La formule corrigée (dénominateur = top5%^N \ décédés) est indispensable.
- **Censure de cohorte** : nécessite un chaînage ANO robuste sur 2 ans ; les patients changeant de région peuvent être perdus de vue si périmètre limité au GHT (préférer SNDS pour vue exhaustive).
- **Effet seuil arbitraire** : un patient à V_i = percentile_95 + ε peut basculer hors top 5 % pour des raisons de bruit statistique sans changement clinique réel. Compléter par une métrique continue (ex. variation de rang en percentile).
- **Définition du top 5 %** : recalculé sur la cohorte vivante de N+1, il rend les comparaisons strictes — toujours documenter la convention.
- **Volume minimal** : <2 000 patients top 5 % (≈ 40 000 patients MCO totaux), τ_persist devient bruité ; agréger plusieurs années glissantes.
- **Composition mix-d'activité** : un site très chir programmée a un τ_persist structurellement bas (chir = HNHC transitoire) sans que cela traduise une meilleure prise en charge — toujours stratifier par CMD.
- **Indicateur retardé** : nécessite 24 mois de recul minimum pour la première mesure ; non utilisable en pilotage temps quasi-réel.

## Références

- Trenaman L. et al. — Can patient-reported data improve predictions about who will be a high-need, high-cost patient in British Columbia? *Qual Life Res* 2025 — [DOI](https://doi.org/10.1007/s11136-025-04008-8) (PMID:40632370)
- Guo M. et al. — Characterizing Cross-Provincial High-Cost Patients in Rural China. *JMIR Public Health Surveill* 2025 — [DOI](https://doi.org/10.2196/54234) (PMID:40499037)
- Amundsen O. et al. — Patient characteristics and healthcare use for high-cost patients with musculoskeletal disorders in Norway. *BMC Health Serv Res* 2024 — [DOI](https://doi.org/10.1186/s12913-024-12051-3) (PMID:39695620)
- IRDES — Concentration des dépenses et grands consommateurs de soins médicaux (QES n°20) — [PDF](https://www.irdes.fr/Publications/Qes/Qes20.pdf)
- ATIH — Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation en MCO — [atih.sante.fr](https://www.atih.sante.fr/)
