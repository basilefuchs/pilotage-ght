# Indice de Fragmentation du Parcours Patient

## Définition
L'indice de fragmentation du parcours patient mesure le nombre moyen de structures de soins distinctes fréquentées par un patient sur une période de 12 mois glissants, tous secteurs confondus : établissements MCO, SSR, HAD, psychiatrie, consultations externes hospitalières et soins de ville (médecins, spécialistes, infirmiers, kinésithérapeutes). Calculé depuis le SNDS par chaînage longitudinal des séjours PMSI et des actes DCIR, il quantifie la dispersion géographique et institutionnelle du parcours de soins. Un indice élevé signale un parcours morcelé entre de nombreux acteurs sans coordination apparente — facteur de risque de ruptures thérapeutiques, d'actes redondants, de pertes d'information et de réadmissions évitables. Un indice faible peut refléter un parcours concentré et coordonné, ou au contraire un sous-recours aux soins. Contrairement à l'indice de continuité intra-GHT (qui mesure uniquement si le parcours reste dans le GHT), la fragmentation capture la dispersion réelle du patient dans l'ensemble du système de soins.

## Calcul
L'indice de fragmentation du parcours patient est calculé comme suit :

```
Indice de fragmentation (IF) = Nombre de structures de soins distinctes fréquentées sur 12 mois

  → Structure distincte = établissement PMSI (FINESS unique) ou offreur de soins de ville (RPPS du praticien)
  → Comptage sur 12 mois glissants à partir de la date de sortie du séjour index

Fragmentation hospitalière seule (SNDS-PMSI) :
  IF_hosp = Nombre de FINESS MCO/SSR/HAD/PSY distincts fréquentés sur 12 mois

Fragmentation totale (SNDS-PMSI+DCIR) :
  IF_total = Nombre de FINESS hospitaliers + Nombre de praticiens de ville distincts (RPPS) sur 12 mois
```

**Indicateurs dérivés :**
```
Taux de patients très fragmentés (%) = (Patients avec IF ≥ 5 structures / Total patients) × 100
  → Seuil de 5 structures = patients nécessitant une coordination active

Taux de patients mono-structure (%) = (Patients avec IF = 1 / Total patients) × 100
  → Patients suivis dans un seul établissement — peut signaler un bon suivi ou un isolement

Indice de Bice-Boxerman (IFB) :
  IFB = 1 - Σ(ni²) / (Σni)²   où ni = nombre de visites chez le praticien/établissement i
  → Varie de 0 (toutes les visites chez un seul praticien) à 1 (chaque visite chez un praticien différent)
  → Indicateur de régularité du suivi au-delà du simple comptage de structures
```

**Précisions méthodologiques** :
- L'analyse est réalisée sur les patients adultes (≥ 18 ans) ayant eu au moins un séjour MCO dans l'année.
- La fenêtre temporelle de 12 mois glissants est centrée sur le séjour index ou calculée sur l'année civile.
- La fragmentation est stratifiée par profil de comorbidité (CCI, Elixhauser) pour distinguer la fragmentation liée à la complexité médicale (légitime) de la fragmentation organisationnelle (évitable).

## Utilité
- **Identification des patients nécessitant une coordination active** : les patients avec IF ≥ 5 structures distinctes sur 12 mois sont les candidats prioritaires aux dispositifs de coordination (DAC, infirmière de liaison, case manager), représentant typiquement 10-20 % des patients mais 40-50 % des coûts.
- **Évaluation de la coordination territoriale du GHT** : un IF moyen élevé sur le territoire du GHT signale des parcours peu coordonnés — il fournit un argument objectif pour renforcer les outils de partage d'information (DPI partagé, messagerie sécurisée) et les dispositifs de coordination.
- **Détection des actes redondants** : la fragmentation est le principal facteur de redondance diagnostique (un patient vu par 5 médecins différents est plus susceptible d'avoir le même examen répété) — l'IF est complémentaire du taux d'actes diagnostiques redondants.
- **Déclinaison par pathologie** : l'IF des patients atteints d'insuffisance cardiaque, de BPCO ou de cancer est structurellement plus élevé — son suivi par pathologie permet de distinguer la complexité médicale de la fragmentation organisationnelle évitable.
- **Suivi de l'impact des politiques de coordination** : mesurer l'évolution de l'IF avant/après le déploiement d'un DAC (Dispositif d'Appui à la Coordination), d'un programme de gestion de cas ou d'une CPTS sur le territoire.

## Sources de Données
- **SNDS (PMSI + DCIR)** : accès obligatoire — chaînage par NIR crypté des séjours PMSI (FINESS hospitaliers) et des actes DCIR (praticiens de ville identifiés par RPPS) sur 12 mois glissants.
- **PMSI MCO seul** : permet le calcul d'une fragmentation hospitalière partielle (FINESS MCO distincts) sans accès SNDS — moins complet mais réalisable par les DIM sur les données locales du GHT.
- **Référence méthodologique** : Bice T.W., Boxerman S.B., *A quantitative measure of continuity of care*, Medical Care, 1977 (indice de Bice-Boxerman, référence internationale pour la mesure de la continuité/fragmentation des soins).
- **CNAM** : publications sur la fragmentation des parcours de soins par pathologie chronique, disponibles dans les rapports Charges et Produits annuels.

## Exemple de Valeurs
- **IF moyen (population générale hospitalisée)** : 3-5 structures distinctes sur 12 mois pour l'ensemble des patients MCO.
- **Patients polypathologiques (CCI ≥ 3)** : IF moyen 6-10 structures, avec une proportion importante fréquentant > 10 structures différentes.
- **Patients atteints de cancer** : IF moyen 8-15 structures (oncologue, chirurgien, radiothérapeute, MG, infirmier, soins de support) — fragmentation élevée mais partiellement coordonnée via les RCP.
- **Taux de patients très fragmentés (IF ≥ 5)** : 20-30 % de la population hospitalisée, concentrant 45-55 % des dépenses de santé totales.
- **Indice de Bice-Boxerman** : IFB proche de 0 (< 0,2) pour les patients avec un médecin traitant déclaré actif et un suivi régulier ; IFB > 0,5 pour les patients sans médecin traitant ou en situation de précarité.
- **Corrélation IF-réadmission** : chaque structure supplémentaire dans le parcours est associée à une augmentation de 5-8 % du risque de réadmission non programmée à 30 jours dans les études françaises (SNDS).

## Limites
- **Accès SNDS obligatoire** pour la fragmentation totale (hospitalière + ville) : le chaînage PMSI-DCIR nécessite une autorisation réglementaire et une infrastructure technique adaptée.
- La fragmentation n'est pas toujours synonyme de mauvaise coordination : un patient atteint de cancer multi-métastatique nécessite légitimement de nombreuses structures différentes — la stratification par profil clinique est indispensable pour interpréter l'indicateur.
- L'indice de Bice-Boxerman sous-estime la fragmentation des patients peu consommateurs de soins (peu de contacts = peu d'opportunités de fragmenter) et sur-estime celle des grands consommateurs — la standardisation est nécessaire pour les comparaisons inter-populations.
- Le comptage des structures distinctes ne tient pas compte de la qualité de la communication entre elles : deux structures bien coordonnées (via un DPI partagé) génèrent le même IF que deux structures totalement cloisonnées.
- La fragmentation calculée sur une année glissante peut être transitoire (période post-hospitalisation intense, bilan initial d'une pathologie) et ne reflète pas nécessairement un problème structurel de coordination.

## Références
- [Bice T.W., Boxerman S.B., A quantitative measure of continuity of care, Medical Care, 1977](https://doi.org/10.1097/00005650-197704000-00010)
- [SNDS - Système National des Données de Santé](https://www.snds.gouv.fr/)
- [CNAM - Fragmentation des parcours et réadmissions](https://www.ameli.fr/)
- [Health Data Hub - Accès aux données longitudinales](https://www.health-data-hub.fr/)
- [DREES - Parcours de soins et coordination](https://www.drees.solidarites-sante.gouv.fr/)
