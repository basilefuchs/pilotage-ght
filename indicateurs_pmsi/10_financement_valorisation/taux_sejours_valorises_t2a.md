# Taux de Séjours Valorisés T2A

## Définition

Dans le système de financement T2A (Tarification à l'Activité), chaque RSA (Résumé de Sortie Anonymisé) est affecté à un GHM (Groupe Homogène de Malades) par l'algorithme de groupage ATIH, qui lui associe un GHS (Groupe Homogène de Séjours) et une tarification. Cependant, une fraction des RSA produits ne génère aucune recette GHS : ce sont les **séjours non valorisés**, principalement issus de la CMD 90 (erreurs de groupage), mais aussi des séjours facturés zéro en raison de conventions particulières ou de configurations tarifaires spécifiques.

```
Taux_valorisés = nb_RSA | GHS_montant > 0€ / nb_RSA_total × 100
```

Cet indicateur se distingue du `taux_exhaustivite_pmsi_sae` (qui mesure si les séjours sont bien présents dans le PMSI) : ici, tous les RSA sont comptabilisés, mais on mesure quelle fraction d'entre eux génère effectivement un financement T2A. Un RSA transmis mais non valorisé est une **activité produite et codée mais non rémunérée**.

Les séjours non valorisés sont principalement :
- **CMD 90** : séjours en erreur de groupage (DP manquant, actes incompatibles, durée incohérente)
- **Séjours zéro-tarif contractuels** : dans le secteur ex-OQN, certains séjours facturés directement au patient ou à l'assurance complémentaire sans GHS
- **Séjours avec GHM à tarif nul** : certains GHMs de surveillance post-opératoire très courte ont un tarif de 0€ dans les grilles tarifaires ATIH
- **Séjours facturés en "MO"** (missions d'intérêt général hors T2A)

L'ATIH publie annuellement les taux de valorisation dans ses rapports de synthèse T2A, permettant un benchmark national.

## Calcul

Source : PMSI MCO RSA + fichier de tarification ATIH (grille GHS).

```
Population : tous RSA transmis et intégrés dans la base ATIH pour un FINESS/année

Étape 1 — Jointure RSA × grille tarifaire GHS ATIH :
  Pour chaque RSA :
    GHM_RSA = GHM affecté par le groupeur (8 caractères)
    CMD_RSA  = substr(GHM_RSA, 1, 2)          [2 premiers caractères]
    GHS_code = correspondance GHM → GHS        [table officielle ATIH]
    Tarif_GHS = montant du GHS dans la grille tarifaire ATIH de l'année
               (grille ex-DGF pour hôpitaux publics, ex-OQN pour cliniques)

  Source grilles : fichiers tarifaires ATIH publiés annuellement (formats CSV/XLS)
    → "tarifs_GHS_MCO_exDGF_AAAA.csv" ou "tarifs_GHS_MCO_exOQN_AAAA.csv"

Étape 2 — Identification des RSA non valorisés :
  RSA_non_valorisé : Tarif_GHS = 0€ OU GHM_RSA starts with '90'

  Catégories d'exclusion détaillée :
    Cat_A — CMD 90 (erreur de groupage) :
      count(RSA | CMD_RSA = '90')
    Cat_B — GHM à tarif nul dans la grille ATIH :
      count(RSA | CMD_RSA ≠ '90' AND Tarif_GHS = 0)
    Cat_C — Séjours hors champ T2A déclarés (MIG, MERRI) :
      → Non identifiables dans le RSA seul ; nécessite le fichier de facturation ATIH (VID-HOSP)

Étape 3 — Calcul du taux :
  nb_valorisés  = count(RSA | Tarif_GHS > 0)
  nb_total      = count(RSA)
  Taux_valorisés = nb_valorisés / nb_total × 100   [en %]

Étape 4 — Décomposition par motif de non-valorisation :
  Taux_CMD90     = count(RSA | CMD_RSA = '90') / nb_total × 100
  Taux_tarif_nul = count(RSA | CMD_RSA ≠ '90' AND Tarif_GHS = 0) / nb_total × 100

Étape 5 — Recette théorique non perçue (estimation) :
  Recette_perdue = Σ Tarif_GHS_moyen_GHM_apparenté × nb_RSA_Cat_A
  → Pour CMD 90 : apparier au GHM probable selon DP + actes si possible
    (re-groupage post-correction pour estimer le manque à gagner)

Cas limites :
  - RSA sans GHM affecté (transmission incomplète) : compter en non-valorisé
  - Grille tarifaire annuelle : utiliser la grille correspondant à l'année de sortie du séjour
    (les tarifs GHS sont actualisés chaque année par arrêté ministériel)
  - Secteur ex-OQN vs ex-DGF : les grilles tarifaires sont distinctes ;
    ne pas croiser les deux grilles sur un même établissement
```

Indicateurs dérivés :

```
Taux CMD 90 (indicateur de qualité de codage ATIH) :
  = count(RSA | CMD = '90') / nb_total × 100
  Seuil ATIH acceptable : < 1%
  Seuil alerte : > 2%

Impact financier des non-valorisés :
  = Σ(Tarif_GHS_moyen × nb_RSA_non_valorisés_par_CMD) — estimation par simulation

Taux de valorisation par CMD :
  = nb_valorisés_CMD / nb_total_CMD × 100
  → identifier les CMDs productrices de non-valorisés (spécialités ou pathologies à fort taux d'erreur)
```

## Utilité

- **Quantification du manque à gagner T2A** : transformer le taux de non-valorisation en montant financier donne à la direction un levier de mobilisation du DIM — un taux CMD 90 de 2% sur 15 000 RSA représente ~300 séjours manqués, soit potentiellement 600 000–1 500 000€ de GHS non perçus selon le casemix
- **Pilotage de la qualité de codage DIM** : le taux CMD 90 est l'indicateur de retour d'information le plus direct sur la qualité du codage DP — chaque RSA en CMD 90 est un séjour dont le DP est manquant, erroné ou incompatible avec les actes codés
- **Suivi de l'impact des formations DIM** : mesurer le taux de non-valorisation avant/après une action de formation des TIM ou des médecins codeurs permet d'objectiver le ROI des investissements en qualité de codage
- **Benchmark intra-GHT** : comparer les taux de valorisation entre établissements du GHT sur une même CMD révèle des pratiques de codage hétérogènes à harmoniser — un établissement avec 3% de CMD 90 en chirurgie digestive alors que la médiane GHT est à 0,8% est un signal d'audit ciblé
- **Préparation des CPOM et contrats qualité** : ATIH et ARS utilisent le taux CMD 90 comme indicateur de qualité dans les contractualisations — un suivi documenté et une trajectoire d'amélioration constituent un argument lors des négociations
- **Identification des interfaces SIH défaillantes** : une fraction des CMD 90 est produite par des bugs d'interface entre le DPI (dossier patient informatisé) et le logiciel de groupage — le taux de non-valorisation par unité médicale peut localiser ces interfaces défaillantes

## Sources de Données

- **PMSI MCO RSA** : variable `ghm2` (6 caractères — CMD = 2 premiers), `finessgeo`, `annee`/`mois` de sortie — extraction annuelle depuis espace ATIH ou SIH local
- **Grilles tarifaires ATIH** : fichiers CSV/XLS publiés annuellement par arrêté ministériel (grille ex-DGF et grille ex-OQN) — téléchargeables sur le site ATIH, rubriques «tarification MCO» — variables : `GHM`, `GHS`, `tarif_base`, `borne_basse`, `borne_haute`
- **VID-HOSP (optionnel)** : fichier de facturation individuelle des séjours — permet d'identifier les séjours facturés en dehors du GHS (MIG, MERRI) et de les exclure du dénominateur

## Exemple de Valeurs

- **CHU** : taux de valorisation 98,5–99,2% ; taux CMD 90 : 0,5–1,0%
- **CH 300–600 lits** : taux de valorisation 97,0–98,5% ; taux CMD 90 : 1,0–2,0%
- **Clinique privée (ex-OQN)** : taux de valorisation 98,0–99,5% (codage souvent plus contrôlé financièrement)
- **Seuil ATIH acceptable CMD 90** : < 1% — au-delà, signal systématique dans les rapports OVALIDE
- **Seuil d'alerte CMD 90** : > 3% → audit DIM urgent ; peut indiquer un problème systémique (changement de version groupeur non appliqué, interface SIH cassée)
- **Manque à gagner estimé** : pour un CH à 12 000 RSA avec taux CMD 90 = 2,5% → 300 séjours non valorisés × GHS moyen 2 500€ = 750 000€ de recettes T2A manquées

## Limites

- **Grille tarifaire versionnée** : les tarifs GHS sont révisés annuellement par arrêté ministériel (généralement en mars) — utiliser impérativement la grille de l'année de sortie du séjour ; les comparaisons inter-annuelles sont faussées par les évolutions tarifaires
- **Secteur public vs privé** : les grilles ex-DGF et ex-OQN sont structurellement différentes (base GHM identique, mais niveaux de tarifs différents et champ d'application distinct) — ne jamais comparer les taux de valorisation entre secteurs sans retraitement
- **CMD 90 surestimée en début d'année** : le changement de version du groupeur ATIH (habituellement en mars) crée mécaniquement une vague de CMD 90 sur les séjours codés avant la mise à jour — le taux du T1 est structurellement plus élevé que les autres trimestres
- **GHM à tarif nul légitimes** : certains GHMs de surveillance courte ont délibérément un tarif nul dans la grille ATIH (séjours de moins d'un jour sans acte) — leur inclusion dans les non-valorisés est légitime mais peut alarmer à tort sur la qualité du codage
- **Non-couverture des MIGAC/MERRI** : les financements hors-T2A (missions d'intérêt général, enseignement, recherche) ne sont pas tracés dans le RSA — l'indicateur ne porte que sur la composante T2A et ignore ces financements complémentaires

## Références

- [ATIH — Guide méthodologique du PMSI MCO : description du groupage GHM, CMD 90 et tarification GHS](https://www.atih.sante.fr/)
- [Arrêté annuel fixant les tarifs nationaux des prestations MCO (Journal Officiel) : grilles tarifaires ex-DGF et ex-OQN, publiées annuellement]
- [ATIH — Rapports annuels de synthèse T2A : taux de valorisation nationaux par type d'établissement](https://www.atih.sante.fr/)
- [Ministère de la Santé — Rapport d'activité T2A : éléments de cadrage sur la valorisation de l'activité hospitalière MCO]
