# Part de la Valorisation Captée par le Top Décile de Patients en MCO

## Définition

La concentration extrême des dépenses hospitalières sur une fraction réduite de la patientèle est un fait stylisé robuste dans tous les systèmes de santé étudiés (« règle des 80/20 », loi de Pareto). Le **Gini de consommation hospitalière** (cf. fiche `coefficient_gini_consommation_hospitaliere`) résume la totalité de la distribution en un scalaire ; il est inadapté lorsqu'on veut **chiffrer la masse financière captée par les patients « high-need high-cost » (HNHC)** que les programmes de case management ciblent explicitement.

L'indicateur **part de la valorisation top décile (P10)** mesure la fraction de la valorisation T2A annuelle d'un GHT (ou d'un établissement) consommée par les 10 % de patients les plus coûteux sur l'année :

P10 = Σ_{i ∈ top10%} V_i / Σ_i V_i

où V_i est la valorisation totale (séjours + suppléments + molécules onéreuses + DMI) du patient i sur la fenêtre annuelle.

Positionnement vs existant :
- complément du Gini (information ciblée sur la queue droite de la distribution, pas sur la totalité de la courbe de Lorenz) ;
- complément de `file_active_patients_hospitalises_annuelle` (qui dénombre les patients sans pondérer par coût) ;
- équivalent français de la métrique « top-decile cost share » utilisée dans la littérature internationale HNHC (Trenaman 2025, Guo 2025, Amundsen 2024).

L'intérêt opérationnel est de fournir un **dimensionnement direct de l'enveloppe financière mobilisable** par un programme parcours complexe : si P10 = 55 %, alors une réduction de 5 % des coûts évitables sur le top 10 % représente ≈ 2,75 % du budget MCO total — un ordre de grandeur communicable aux directions.

## Calcul

```
Périmètre :
  → Tous les séjours MCO (RSA) avec un identifiant patient chaîné (ANO) valide
  → Fenêtre : année civile glissante (12 mois)
  → Exclusion des séances itératives (CMD 28) si l'on cible le HNHC "structurel"
    (option à documenter — cf. Limites)

Étapes :
  1. Pour chaque RSA, calculer la valorisation totale V_séjour =
       valorisation GHS + suppléments (REA, SI, SC, etc.)
       + molécules onéreuses (liste en sus)
       + DMI (liste en sus)
  2. Agréger par patient : V_i = Σ_{séjours du patient i} V_séjour
  3. Trier les patients par V_i décroissant
  4. Identifier le top 10 % (N_top = ⌈0,10 × N_patients⌉)
  5. Calculer :
       P10 = Σ_{i ∈ top10%} V_i / Σ_i V_i
       Coût moyen top10% = mean(V_i, i ∈ top10%)
       Coût médian non-top10% = median(V_i, i ∉ top10%)
       Ratio Pareto = Coût moyen top10% / Coût médian non-top10%
```

Indicateurs dérivés utiles :

```
P5  = part de valorisation captée par le top 5 %    (cible HNHC stricte)
P1  = part de valorisation captée par le top 1 %    (queue extrême — souvent 15–25 %)
Effectif top10% = nombre de patients du top décile (dimensionnement file active programme)
ΔP10 = P10(N) − P10(N−1) → tendance de concentration
```

Stratifications recommandées :
- par CMD dominante du top10% (cancérologie, hémato, dialyse, chir lourde) ;
- par mode d'entrée majoritaire (programmé vs urgences) — voir `part_sejours_non_programmes_top_decile_consommateurs` ;
- par statut ALD si chaînage SNDS disponible.

## Utilité

- **Dimensionner un programme parcours complexes / case management GHT** : connaître la masse financière en jeu sur le top décile permet de calibrer l'investissement (ETP coordinateurs, plateforme téléphonique, IDE de parcours) à un retour attendu sur la queue de coût.
- **Argumenter en CME et devant l'ARS** : le ratio « 10 % des patients = X % du budget MCO » est un message synthétique fort pour justifier les ressources de coordination ciblées.
- **Suivre l'efficacité d'un programme HNHC** : une intervention efficace doit, à structure de patientèle constante, faire **baisser P10** (les coûts du top décile diminuent davantage que ceux du reste, ou la composition du top décile change).
- **Benchmarking inter-établissements du GHT** : les sites avec un P10 anormalement élevé concentrent souvent des patients chroniques décompensés mal coordonnés en aval — déclencheur d'analyse parcours.
- **Cibler les filières prioritaires** : la décomposition de P10 par CMD identifie les domaines cliniques surreprésentés dans la queue (oncohématologie, dialyse, brûlés, chir digestive lourde).
- **Modéliser l'impact d'une bascule en HAD ou ambulatoire** : simuler le décalage de coût d'une fraction de la queue vers des modes alternatifs et son effet sur P10.

## Sources de Données

- **PMSI MCO — fichier RSA** (variables principales : numéro de RSA, ANO patient chaîné, GHM, GHS, durée, suppléments journaliers).
- **PMSI MCO — fichier FICHCOMP** (molécules onéreuses et DMI en sus de la T2A).
- **Tarifs GHS** : barème ATIH de la campagne tarifaire en cours (référentiel `tarifs_ghs_<année>.csv` ATIH).
- **Tarifs molécules onéreuses / DMI** : référentiels ATIH UCD et LPP.
- **Optionnel — chaînage SNDS** : pour enrichir V_i avec les dépenses ambulatoires post-séjour (vue patient totale, non strictement MCO).

Variables critiques (nomenclature guide méthodologique MCO ATIH) :
- ANO crypté patient (chaînage inter-séjours)
- N° séjour / N° RSA
- Code GHS, valorisation GHS
- Code GHM, niveau de sévérité

## Exemple de Valeurs

Ordres de grandeur (sources : IRDES QES n°20 « Concentration des dépenses » 1999 ; Guo 2025 [DOI](https://doi.org/10.2196/54234) ; Amundsen 2024 [DOI](https://doi.org/10.1186/s12913-024-12051-3) ; Garcia 2024 [DOI](https://doi.org/10.1002/lary.31618) — transposition aux ordres français à valider localement) :

- **CH généraliste type** : P10 ≈ 45–55 % de la valorisation MCO totale
- **CHU avec activité cancéro/hémato/réa lourde** : P10 ≈ 55–65 % (queue plus épaisse)
- **Clinique chirurgicale programmée** : P10 ≈ 35–45 % (population plus homogène, moins de queue)
- **Top 5 %** : généralement 30–45 % de la valorisation
- **Top 1 %** : généralement 15–25 % de la valorisation
- **Ratio coût moyen top10% / médiane reste** : 8 à 20 selon mix d'activité

Seuils d'alerte indicatifs :
- ΔP10 > +2 points/an à structure de patientèle constante → croissance de la concentration, à investiguer
- Effectif top10% explosant (>+10 %/an) → dérive de la file active complexe

## Limites

- **Effet de censure annuelle** : un patient hospitalisé en décembre puis janvier est artificiellement « scindé » sur deux années. Préférer l'année glissante centrée sur le patient ou un suivi cohorte 24 mois pour les analyses fines.
- **Patients décédés** : la fin de vie concentre mécaniquement les coûts ; un P10 élevé peut traduire une part importante de patients en fin de vie, non actionnables par un programme de coordination classique. Stratifier en excluant ou identifiant les patients décédés en cours d'année.
- **Effet « one-shot » chirurgical** : un patient transplanté ou polytraumatisé apparaît dans le top décile mais ne récidivera pas — non « HNHC structurel ». Croiser avec `taux_persistance_hnhc_top5_annee_n1` pour distinguer les deux populations.
- **Sensibilité au périmètre** : inclure ou non SSR/HAD/PSY chaînés modifie sensiblement P10. Documenter explicitement le périmètre.
- **Comparabilité inter-GHT** : la composition de patientèle (recours, niveau de spécialisation) explique une grande part de la variation de P10 — toute comparaison nécessite stratification par CMD ou ajustement sur case-mix.
- **Volume minimal** : sous 5 000 patients/an, le top 10 % est trop instable pour piloter (<500 patients dans la queue).

## Références

- IRDES — Concentration des dépenses et grands consommateurs de soins médicaux (Questions d'Économie de la Santé n°20, 1999) — [PDF](https://www.irdes.fr/Publications/Qes/Qes20.pdf)
- Trenaman L. et al. — Can patient-reported data improve predictions about who will be a high-need, high-cost patient in British Columbia? *Qual Life Res* 2025 — [DOI](https://doi.org/10.1007/s11136-025-04008-8) (PMID:40632370)
- Guo M. et al. — Characterizing Cross-Provincial High-Cost Patients in Rural China. *JMIR Public Health Surveill* 2025 — [DOI](https://doi.org/10.2196/54234) (PMID:40499037)
- Amundsen O. et al. — Patient characteristics and healthcare use for high-cost patients with musculoskeletal disorders in Norway. *BMC Health Serv Res* 2024 — [DOI](https://doi.org/10.1186/s12913-024-12051-3) (PMID:39695620)
- Garcia J. et al. — Concentration of High-Cost Head and Neck Cancer Surgical Patients. *Laryngoscope* 2024 — [DOI](https://doi.org/10.1002/lary.31618) (PMID:38973626)
- ATIH — Analyse de l'activité hospitalière 2023 — [atih.sante.fr](https://www.atih.sante.fr/analyse-de-l-activite-hospitaliere-2023)
