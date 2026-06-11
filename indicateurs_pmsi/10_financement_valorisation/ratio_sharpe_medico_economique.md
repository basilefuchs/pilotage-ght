# Ratio de Sharpe Médico-Économique

## Définition
Le **ratio de Sharpe médico-économique** mesure la performance financière d'un service, d'une unité ou d'un établissement **ajustée du risque de variabilité de ses recettes**. Emprunté à la finance quantitative, où il évalue le rendement excédentaire d'un portefeuille par rapport à son écart-type (sa volatilité), ce ratio est transposé ici au portefeuille d'activité hospitalière : il rapporte la recette moyenne par séjour (au-delà d'un seuil de référence) à la variabilité de cette recette d'un séjour à l'autre. Un ratio élevé indique un service qui génère des recettes supérieures à la norme de façon *stable et prévisible* — le profil idéal pour la planification financière. Un ratio faible signale soit une performance financière insuffisante, soit une forte imprévisibilité des recettes (casemix instable, codage irrégulier, dépendance à quelques GHM rares et mal valorisés), ce qui constitue un risque financier structurel indépendamment du volume d'activité.

L'analogie avec la finance est directe : tout comme un gestionnaire de fonds préfère un portefeuille avec un Sharpe élevé (rendement stable plutôt que sporadique), un directeur financier doit piloter ses services non seulement sur leur recette moyenne, mais aussi sur la fiabilité de cette recette — particulièrement critique dans un contexte T2A où la valorisation dépend du groupage séjour par séjour.

## Calcul

### 1. Recette ajustée par séjour (r_i)

```
r_i = Valorisation T2A du séjour i (€) − Tarif GHM médian national du GHM correspondant (€)

  → r_i > 0 : séjour valorisé au-dessus de la médiane nationale (surperformance)
  → r_i < 0 : séjour valorisé en dessous de la médiane nationale (sous-performance)
  → Le tarif GHM médian national joue le rôle du "taux sans risque" en finance

Valorisation T2A du séjour i :
  V_i = Tarif GHM × Coefficient géographique × Correctifs (suppléments, DMT, bornes)
```

### 2. Ratio de Sharpe Médico-Économique (RSME)

```
RSME = (r̄ − r_f) / σ_r

  → r̄   = moyenne des recettes ajustées par séjour sur la période (ex : 12 mois)
  → r_f  = "taux sans risque" = recette ajustée d'un séjour GHM de niveau 1
             (la recette plancher prévisible, équivalent du taux sans risque en finance)
  → σ_r  = écart-type des recettes ajustées par séjour (mesure de la volatilité)

  → RSME > 1,0 : performance financière robuste, recettes supérieures à la norme
                 avec une variabilité maîtrisée
  → RSME 0,5–1,0 : performance correcte mais variabilité notable
  → RSME < 0,5 : risque financier significatif (faible rendement ou forte volatilité)
  → RSME < 0 : recettes systématiquement inférieures à la médiane nationale
```

### 3. Décomposition de la volatilité

```
σ_r² = σ²_casemix + σ²_codage + σ²_duree + σ²_supplements

  → σ²_casemix    : variance liée à l'instabilité du mix de GHM (risque épidémiologique)
  → σ²_codage     : variance liée à l'irrégularité du codage (risque organisationnel)
  → σ²_duree      : variance liée aux dépassements de borne haute (risque de séjours longs)
  → σ²_supplements: variance liée aux suppléments (réanimation, ambulatoire, etc.)

  → La décomposition identifie la source dominante de risque financier
```

### 4. RSME standardisé et benchmarking

```
RSME-s = RSME service / RSME médian des services comparables (même CMD)

  → Neutralise l'effet spécialité (la chirurgie cardiaque a structurellement
    une variance plus élevée que la chirurgie orthopédique programmée)
  → Permet la comparaison intra-GHT et inter-GHT

Matrice de pilotage (4 quadrants) :
  ┌─────────────────────┬─────────────────────┐
  │  Rendement élevé    │  Rendement élevé    │
  │  Volatilité faible  │  Volatilité élevée  │
  │  → "Vache à lait"   │  → "Star risquée"   │
  │  RSME élevé ✓       │  RSME moyen         │
  ├─────────────────────┼─────────────────────┤
  │  Rendement faible   │  Rendement faible   │
  │  Volatilité faible  │  Volatilité élevée  │
  │  → "Activité socle" │  → "Zone critique"  │
  │  RSME faible        │  RSME négatif ✗     │
  └─────────────────────┴─────────────────────┘
```

**Précisions méthodologiques** :
- Le calcul est réalisé au niveau du séjour individuel (RSS) pour capturer la variabilité intra-service, puis agrégé par service, par établissement et par GHT.
- Les tarifs GHM de référence sont ceux publiés annuellement par l'ATIH dans l'arrêté tarifaire.
- Le calcul porte sur les séjours MCO (et SSR avec DAF en dotation modulée) ; l'HAD et la psychiatrie sous dotation globale sont exclues du calcul principal mais peuvent faire l'objet d'une adaptation.
- La fenêtre temporelle recommandée est de 12 mois pour lisser les aléas saisonniers ; une analyse glissante sur 3 ans permet de détecter les tendances structurelles.

## Utilité

- **Identification des services à risque financier** : un service avec un RSME faible ou négatif constitue une fragilité financière structurelle — non pas parce qu'il est déficitaire en volume, mais parce que ses recettes sont imprévisibles ou systématiquement inférieures à la norme. La direction financière peut cibler ses plans d'action sur ces services.
- **Arbitrages d'investissement intra-GHT** : face à plusieurs projets de développement d'activité, le RSME permet de comparer leur attractivité financière ajustée du risque — préférer un service avec RSME = 1,2 à un service avec RSME = 0,3, même si ce dernier affiche un volume plus important.
- **Pilotage du codage PMSI** : la composante σ²_codage de la décomposition de la volatilité identifie les services où l'irrégularité du codage crée une incertitude financière évitable — argument quantifié pour cibler les efforts de formation des DIM.
- **Détection des effets de borne haute** : un RSME dégradé par σ²_duree révèle un service où les séjours longs (au-delà de la borne haute T2A) sont fréquents et variables — signal d'un problème de gestion des lits ou d'un casemix mal couvert par le financement.
- **Négociation CPOM et contrats de pôle** : le RSME fournit un langage commun entre la direction financière et les chefs de pôle pour discuter de la soutenabilité financière des activités — plus opérationnel qu'un simple suivi de recettes brutes.
- **Benchmarking inter-GHT** : le RSME-s normalisé par CMD permet de comparer la qualité de la gestion financière entre établissements à casemix comparable, indépendamment de la spécialité dominante.

## Sources de Données

- **PMSI MCO (RSA — Résumé de Sortie Anonymisé)** : GHM, tarif applicable, suppléments (réanimation, soins intensifs, ambulatoire), durée de séjour, indicatrice de borne haute — pour le calcul de la valorisation V_i séjour par séjour.
- **Arrêté tarifaire annuel ATIH** : liste des tarifs GHM par niveau de sévérité et par secteur (ex-DG / ex-OQN), coefficients géographiques — pour le calcul du tarif médian national de référence r_f.
- **OVALIDE (ATIH)** : outil de valorisation et de contrôle du PMSI, fournissant la valorisation estimée par séjour et par service, utilisable comme base de calcul du RSME.
- **ScanSanté** : données agrégées de valorisation par GHM et par établissement pour le benchmarking national et la construction des distributions de référence.
- **Comptabilité analytique hospitalière (CREA/TCCM)** : pour affiner le calcul en croisant la recette T2A avec les coûts de production par séjour — permet de calculer un RSME sur la *marge* plutôt que sur la recette brute (variante plus proche de l'usage financier original).

## Exemple de Valeurs

- **RSME médian (chirurgie orthopédique programmée)** : 0,8-1,2 — activité stable, casemix prévisible, codage bien maîtrisé dans la plupart des établissements.
- **RSME élevé (chirurgie ambulatoire de cataracte)** : 1,5-2,5 — recette supérieure à la médiane nationale, très faible variabilité (GHM unique, acte standardisé, codage simple).
- **RSME faible (médecine interne/gériatrie)** : 0,2-0,5 — recette souvent inférieure à la médiane nationale (patients lourds, séjours longs non valorisés au-delà de la borne haute), forte variabilité du casemix.
- **RSME négatif (SSR en dotation modulée)** : peut être négatif si la valorisation modulée est structurellement inférieure au tarif de référence PMSI classique, révélant un sous-financement.
- **Impact d'un plan d'amélioration du codage** : amélioration du RSME de +0,3 à +0,6 point observable en 12 mois dans les services ayant fait l'objet d'un audit DIM intensif (réduction de σ²_codage par meilleure exhaustivité des diagnostics associés).
- **RSME "vache à lait" typique** : chirurgie ambulatoire (cataracte, hernie, varices), endoscopie digestive diagnostique — RSME > 1,5 avec σ très faible.
- **RSME "zone critique" typique** : urgences non suivies d'hospitalisation, séjours de < 24h en gériatrie aiguë, séjours psychiatriques en unité somatique — RSME < 0 ou très faible.

## Limites

- **Le RSME mesure la performance financière T2A, pas la valeur clinique ou sociale** : un service de soins palliatifs ou de psychiatrie aura structurellement un RSME faible sans que cela reflète une inefficacité — l'interprétation doit impérativement tenir compte de la mission de service public et de l'intérêt territorial.
- **Sensibilité aux modifications tarifaires annuelles** : les révisions de tarifs GHM publiées chaque année par l'ATIH modifient la distribution de référence et peuvent faire varier le RSME sans changement réel de la pratique — la comparaison inter-années nécessite une rebasage annuel.
- **Le tarif T2A n'est qu'une partie des recettes hospitalières** : les financements complémentaires (MIG, MERRI, DAF, dotations populationnelles) ne sont pas capturés dans le RSME basé sur le PMSI seul — une vision complète nécessite d'intégrer la comptabilité analytique.
- **Le ratio de Sharpe original suppose des distributions normales des rendements** — hypothèse rarement vérifiée pour les recettes hospitalières (distributions asymétriques avec queues épaisses liées aux séjours très longs ou très coûteux). La robustesse du RSME doit être vérifiée ; le ratio de Sortino (qui ne pénalise que la volatilité négative) peut lui être préféré dans les services à forte variabilité haute.
- **Risque de pilotage pervers** : optimiser le RSME peut inciter à sélectionner les patients "bien valorisés" et à éviter les cas complexes peu rentables — le suivi du RSME doit être accompagné d'indicateurs de qualité et d'accès aux soins pour prévenir tout effet de sélection.

## Références

- [Sharpe W.F., *Mutual Fund Performance*, Journal of Business, 1966](https://doi.org/10.1086/294846) — article fondateur du ratio de Sharpe en finance
- [ATIH — Arrêtés tarifaires annuels MCO](https://www.atih.sante.fr/tarification/la-tarification-a-l-activite)
- [ATIH — OVALIDE : outil de valorisation et contrôle PMSI](https://www.atih.sante.fr/ovalide)
- [ScanSanté — Valorisation par GHM et par établissement](https://www.scansante.fr/)
- [ANAP — Comptabilité analytique et CREA hospitalier](https://www.anap.fr/)
- [Or Z. — Implementation of DRG payment in France: issues and recent developments, Health Policy 2014](https://doi.org/10.1016/j.healthpol.2014.05.006) — risque financier de la valorisation T2A séjour par séjour
