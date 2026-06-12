# Taux de Rétrocession d'Aval d'une Convention de Recours

## Définition

Le taux de rétrocession d'aval mesure, pour une convention de recours entre un établissement adresseur A et un établissement de recours B, la part des patients adressés de A vers B (geste ou plateau technique conventionné) qui **reviennent à A** pour la suite de leur prise en charge hospitalière — surveillance, suites médicales, SMR — dans une fenêtre de 90 jours après la sortie de B. Il objective la **clause de retour** qui figure dans la plupart des conventions de recours et qui est presque jamais mesurée : « B opère, A reprend l'aval ».

Le concept correspond à la *repatriation* (rapatriement inter-hospitalier) de la littérature sur la régionalisation des soins : le retour du patient vers son hôpital d'origine après l'étape de recours est le mécanisme qui rend la gradation soutenable, en désaturant le centre receveur — dont les durées de séjour s'allongent de façon disproportionnée quand il garde les patients transférés (Mesfin et al. 2026) — et en préservant l'activité d'aval de l'adresseur. Le *regionalization index* (probabilité d'achever sa prise en charge dans l'hôpital initial, Samuels-Kalow et al. 2023) en est le complément : la rétrocession mesure la part du parcours que la dyade « rend » à la proximité.

Aucun indicateur du projet ne couvre ce sens du flux : `../09_territoire_attractivite/taux_fuite_aval_parcours.md` mesure la perte de l'aval vers l'extérieur du GHT ; `delai_transfert_mco_ssr.md` et `constante_cinetique_transfert_mco_ssr.md` mesurent la vitesse MCO→SMR sans dimension dyadique ; la rétrocession est conditionnelle à un adressage A→B préalable et mesure le retour vers l'adresseur précis.

Formule symbolique :

```
TR = N_parcours(A → B → A, retour ≤ 90 j) / N_parcours(A → B avec suite hospitalière) × 100

Dénominateur : adressages A → B (périmètre conventionné) suivis d'AU MOINS un séjour
               hospitalier (MCO ou SMR, tout établissement) dans les 90 j post-sortie de B
Numérateur   : ceux dont le premier séjour de suite a lieu à A (ou ses structures SMR)
```

Le dénominateur est restreint aux parcours **avec suite hospitalière observée** : le retour direct à domicile sans réhospitalisation est un succès clinique, pas un défaut de rétrocession — le compter en échec rendrait l'indicateur ininterprétable.

## Calcul

1. **Champ** : PMSI MCO + SMR national chaîné (le patient peut être rétrocédé vers le SMR de A), années N et N+1 pour couvrir la fenêtre.
2. **Identification des adressages A→B** : couples chaînés séjour A → séjour B du périmètre conventionné (cf. `../09_territoire_attractivite/taux_adressage_preferentiel_convention.md`), transferts directs ou différés ≤ 90 j.
3. **Identification de la suite** : premier séjour MCO ou SMR, tout établissement, dans les 90 jours suivant la sortie de B — y compris une nouvelle hospitalisation à B (non-rétrocession) ou un séjour dans un établissement tiers (évasion d'aval).
4. **Pseudocode** :

```
adressages = parcours chaînés A → B (périmètre conventionné)
suites     = premier séjour MCO/SMR ≤ 90 j après sortie de B, pour chaque adressage
denominateur = adressages avec suite observée, hors décès pendant le séjour B
retour       = suites[finess ∈ finess_A]                  # MCO ou SMR de A

TR = n(retour) / n(denominateur) × 100      # non calculé si denominateur < 30
Répartition complémentaire : % suite à B, % suite chez un tiers
```

5. **Conventions** : décès pendant le séjour à B exclus ; mutation interne de B (MCO→SMR de B) = non-rétrocession ; présenter systématiquement la répartition complète (retour A / reste B / tiers) plutôt que le seul TR.
6. **Indicateurs dérivés** : délai médian sortie de B → réadmission à A (une rétrocession tardive a souvent transité par les urgences) ; part des retours entrant par les urgences de A (rétrocession subie vs organisée) ; durée de séjour résiduelle à B des patients non rétrocédés (le coût capacitaire de la non-rétrocession, au sens de Mesfin et al. 2026).

## Utilité

- **Faire vivre la clause de retour** : produire le TR au comité de suivi de la convention ; c'est l'indicateur miroir du taux d'adressage — A accepte d'adresser si B s'engage à rendre.
- **Protéger l'activité d'aval de l'adresseur** : la rétrocession alimente la médecine polyvalente et le SMR de A ; un TR faible transforme la convention de recours en captation complète du parcours.
- **Désaturer le centre de recours** : pour B, chaque journée d'aval non rétrocédée occupe un lit de recours — chiffrer les journées récupérables (dérivé n°6) est un argument gagnant-gagnant pour organiser le retour.
- **Détecter la rétrocession subie** : un TR correct mais passant majoritairement par les urgences de A signale l'absence de circuit organisé (fiche de liaison, lit identifié) — la convention fonctionne sur le papier, pas en pratique.
- **Équilibrer la lecture de la réciprocité** : pour une dyade CH–CHU, l'asymétrie des flux (cf. `../09_territoire_attractivite/indice_reciprocite_flux_dyade.md`) est acceptable si TR est élevé — recours avec retour ; les deux indicateurs se lisent ensemble.
- **Préparer les filières SMR territoriales** : le TR par type de suite (SMR locomoteur, gériatrique) dimensionne les lits d'aval à sanctuariser chez A.

## Sources de Données

- **PMSI MCO et SMR nationaux chaînés** : numéro de chaînage anonyme (MAGIC/ANO `[modalités exactes selon documentation ATIH en vigueur, à confirmer]`), FINESS géographique, dates/délais inter-séjours, modes d'entrée et de sortie (entrée par urgences pour le dérivé), GHM/GME, DP.
- **Périmètre conventionné** : annexe de la convention traduite en codes GHM/CCAM (partagée avec `taux_adressage_preferentiel_convention`).
- Le calcul nécessite la **base nationale** pour repérer les suites chez un établissement tiers.

## Exemple de Valeurs

Ordres de grandeur expert (non sourcés — pas de restitution nationale équivalente ; la littérature de *repatriation* nord-américaine ne fournit pas de taux transposables au PMSI) :

- **Convention de recours organisée** (chirurgie programmée, circuit de retour formalisé) : TR = 60–85 % des suites hospitalières.
- **Convention sans circuit de retour** : TR = 20–40 %, avec une part importante de retours via les urgences.
- **Alerte** : TR < 30 % sur une filière où A dispose de l'aval (SMR, médecine) ; ou part des retours par les urgences > 50 %.
- **Lecture en triptyque** : retour A / reste B / tiers — une part « tiers » > 20 % signale une évasion d'aval que ni A ni B ne maîtrise.

## Limites

- **Chaînage à trois séjours** : l'indicateur cumule les défaillances de clé sur trois maillons ; vérifier la complétude du chaînage sur la dyade avant interprétation (~1–2 % de clés défaillantes par séjour).
- **Le retour à domicile sans suite n'est pas observé** : le dénominateur restreint aux suites hospitalières sous-estime le « bon » fonctionnement global ; suivre en parallèle la part des adressages sans aucune suite (succès cliniques + perdus de vue, indissociables sans SNDS).
- **La non-rétrocession peut être médicalement justifiée** : complications nécessitant le plateau de B, choix du patient — interpréter par filière, et garder le seuil de 30 parcours/an.
- **Fenêtre de 90 jours** : trop courte pour les suites différées (réadaptation après chimiothérapie), trop longue pour distinguer la suite directe de la réadmission indépendante ; la pathologie du séjour de suite (même chapitre CIM-10) aide à filtrer.
- **Sens unique** : la fiche mesure la rétrocession B→A après adressage A→B ; pour les dyades symétriques, calculer aussi le sens inverse.
- **Effet structure** : si A n'a pas de SMR, son TR est plafonné — comparer des dyades à offre d'aval comparable, ou restreindre aux suites que A peut produire.

## Références

- Mesfin N, Ingraham NE, Langworthy B, Dudley RA, Pendleton KM. *National Retrospective Cohort Study Assessing Association of Hospital Transfer-In Prevalence With Hospital Outcomes.* Chest. 2026. [DOI](https://doi.org/10.1016/j.chest.2026.03.043) — PMID:42036067
- Samuels-Kalow ME, Gao J, Boggs KM, Camargo CA, Zachrison KS. *Pediatric Patient Insurance Status and Regionalization of Admissions.* Pediatr Emerg Care. 2023;39(11):817-820. [DOI](https://doi.org/10.1097/PEC.0000000000002820) — PMID:36099536
- Ranasinghe I, Barzi F, Brieger D, Gallagher M. *Long-term mortality following interhospital transfer for acute myocardial infarction.* Heart. 2015;101(13):1032-1040. [DOI](https://doi.org/10.1136/heartjnl-2014-306966) — PMID:25736049
- Ministère de la Santé. *Les coopérations territoriales : modalités d'accompagnement* (trames de convention types, clauses de retour). [sante.gouv.fr](https://sante.gouv.fr/professionnels/gerer-un-etablissement-de-sante-medico-social/cooperations/cooperations-territoriales/article/les-cooperations-territoriales-modalites-d-accompagnement)
- Fiches liées : `../09_territoire_attractivite/taux_adressage_preferentiel_convention.md` (sens aller), `../09_territoire_attractivite/indice_reciprocite_flux_dyade.md` (symétrie), `delai_transfert_mco_ssr.md`, `../09_territoire_attractivite/taux_fuite_aval_parcours.md` (évasion hors GHT).
