# Indice de Viabilité Métapopulationnelle des Services du GHT

## Définition
L'**indice de viabilité métapopulationnelle des services du GHT** évalue la pérennité de chaque service ou spécialité d'un établissement membre du GHT en appliquant le cadre théorique des **métapopulations** (Levins, 1969). En écologie, une métapopulation est un ensemble de populations locales spatialement séparées — les "patches" d'habitat — qui s'éteignent et se recolonisent au fil du temps selon un équilibre entre taux d'extinction locale et taux de recolonisation par migration depuis les patches voisins. La grande découverte de ce modèle est l'**effet de sauvetage** (*rescue effect*) : un patch dont la population locale est trop faible pour se maintenir peut survivre indéfiniment grâce aux apports continus de migrants provenant des patches voisins. Privé de ces apports, il s'éteint.

Appliqué au GHT, chaque service hospitalier dans chaque établissement est un "patch" : sa viabilité dépend à la fois de son activité locale (recrutement propre, fidélisation des patients du bassin de vie) et des flux entrants de patients adressés par les autres établissements membres (effet de sauvetage intra-GHT). Un service en dessous du [[volume_seuil_actes_chirurgicaux|seuil d'activité minimale de l'ATIH]] est un patch "en voie d'extinction" — il peut être maintenu artificiellement s'il reçoit suffisamment de patients des partenaires du GHT, ou condamné à la fermeture si ces flux s'interrompent. La modélisation métapopulationnelle permet de distinguer les services viables de façon autonome, les services viables uniquement grâce à l'effet de sauvetage GHT, et les services non viables même avec l'appui inter-établissements — trois situations appelant des réponses stratégiques radicalement différentes.

## Calcul

### 1. Modèle de Levins adapté aux services hospitaliers

```
Équation de Levins (continue) :
  dp/dt = m × p × (1 − p) − e × p

  → p  = fraction de services "occupés" (au-dessus du seuil de viabilité)
          dans une famille de spécialités sur les établissements du GHT
  → m  = taux de colonisation (création ou réactivation d'un service)
  → e  = taux d'extinction (fermeture ou passage sous seuil d'activité)
  → Équilibre : p* = 1 − (e/m)   [fraction de services viables à l'équilibre]
  → Extinction globale de la spécialité dans le GHT si e > m (p* < 0)
```

### 2. Indice de viabilité locale (IVL) par service

```
IVL = Volume_activité_local / Seuil_ATIH_spécialité

  → IVL ≥ 1,0 : service autonomement viable (au-dessus du seuil ATIH)
  → IVL 0,5–1,0 : service fragile, dépendant partiellement de l'effet de sauvetage
  → IVL < 0,5 : service non viable de façon autonome (patch "quasi-éteint")

Seuils ATIH de référence (exemples) :
  Chirurgie cardiaque avec CEC       : 200 interventions/an
  Pose de prothèse totale de hanche  : 30 actes/an par opérateur
  Thrombolyse AVC                    : 20 actes/an
  Endoscopies digestives thérapeutiques : 50 actes/an
```

### 3. Effet de sauvetage inter-établissements (ES)

```
ES(service S, établissement E) =
  Flux_entrants_GHT(S, E) / Activité_totale(S, E)

  → Part de l'activité du service S dans l'établissement E
    provenant de transferts ou d'adressages depuis les autres membres du GHT
  → ES > 0,3 : service fortement dépendant de l'effet de sauvetage
               (> 30 % de l'activité provient des partenaires GHT)
  → ES > 0,5 : service en survie artificielle — vulnérable à toute
               modification des conventions de transfert intra-GHT

Indice de viabilité effective (IVE) :
  IVE = (Volume_local + Flux_entrants_GHT) / Seuil_ATIH_spécialité
  → IVE ≥ 1,0 ET IVL < 1,0 : service sauvé par l'effet de sauvetage GHT
  → IVE < 1,0 : service non viable même avec l'appui GHT
```

### 4. Matrice de viabilité métapopulationnelle du GHT

```
Quatre profils stratégiques :

  ┌─────────────────────────┬──────────────────────────┐
  │  IVL ≥ 1,0              │  IVL ≥ 1,0               │
  │  ES faible              │  ES élevé                 │
  │  → "Patch autonome"     │  → "Hub attracteur"       │
  │  Viable seul, peu       │  Viable seul ET génère     │
  │  dépendant du GHT       │  de l'effet de sauvetage  │
  │                         │  pour les autres patches  │
  ├─────────────────────────┼──────────────────────────┤
  │  IVL < 1,0              │  IVL < 1,0                │
  │  IVE ≥ 1,0              │  IVE < 1,0                │
  │  → "Patch sauvé"        │  → "Patch éteint"         │
  │  Survie conditionnelle  │  Non viable même avec     │
  │  aux flux GHT —         │  l'appui GHT —            │
  │  à sécuriser par        │  reconversion ou          │
  │  convention formelle    │  fermeture à planifier    │
  └─────────────────────────┴──────────────────────────┘
```

**Précisions méthodologiques** :
- Les [[taux_transferts_intra_ght|flux entrants GHT]] sont identifiés dans le PMSI par le mode d'entrée (= 6 transfert) combiné au FINESS de l'établissement d'origine, filtré sur les FINESS membres du GHT (liste issue du répertoire FINESS / ARS).
- L'activité locale correspond aux séjours dont le patient réside dans le bassin de vie propre de l'établissement (code géographique de résidence du patient).
- Les seuils ATIH sont ceux publiés dans les décrets d'autorisation d'activité de soins (autorisation de chirurgie cardiaque, neurochirurgie, oncologie, etc.) — complétés par les seuils de bonnes pratiques HAS pour les actes sans seuil réglementaire.
- L'analyse est réalisée par famille de spécialité (CMD ou regroupement GHM) pour maintenir des effectifs suffisants ; une granularité à la racine GHM est possible pour les spécialités à fort volume.

## Utilité

- **Identification précoce des services à risque d'extinction** : un service avec IVL < 0,5 et ES > 0,4 est structurellement dépendant de flux GHT qui peuvent s'interrompre à tout moment (départ d'un chirurgien partenaire, modification d'une convention, changement de filière) — l'indicateur permet d'anticiper la fragilité avant la crise plutôt que de réagir en urgence à une fermeture.
- **Planification stratégique du projet médical de territoire** : la matrice de viabilité fournit aux directions de GHT une cartographie objective des services à consolider (patches sauvés à sécuriser), à développer (patches autonomes à renforcer comme hubs) et à reconvertir (patches éteints à orienter vers d'autres missions), en substitution aux décisions politiques mal étayées.
- **Sécurisation juridique des conventions intra-GHT** : les services identifiés comme "patches sauvés" (IVL < 1,0, IVE ≥ 1,0) doivent faire l'objet de conventions de transfert formalisées et opposables, garantissant les flux entrants indispensables à leur survie — l'indicateur fournit l'argument quantifié pour imposer ces conventions.
- **Simulation des impacts de fermeture** : modéliser l'effet en cascade d'une fermeture de service dans un établissement membre du GHT sur la viabilité des services des établissements partenaires — comme la disparition d'un patch modifie l'équilibre de la métapopulation entière.
- **Dialogue avec l'ARS pour les autorisations** : un établissement qui demande le maintien d'une autorisation d'activité sous le seuil ATIH peut s'appuyer sur l'IVE pour démontrer que la viabilité est assurée par les flux GHT, et sur l'ES pour quantifier l'effet de sauvetage que ce service produit en retour pour les partenaires.
- **Prévention des déserts médicaux spécialisés** : les patches éteints (IVE < 1,0) représentent des spécialités non viables sur le territoire même avec la coopération GHT — leur identification précoce permet de planifier des solutions alternatives (télémédecine, consultations avancées depuis le CHU, filières régionales) — voir aussi [[indice_dependance_chu]] avant que leur disparition ne crée un désert médical de facto.

## Sources de Données

- **PMSI MCO** : volume d'activité par service et par établissement (GHM, CMD), mode d'entrée (= 6 pour les transferts entrants), FINESS de l'établissement d'origine — pour le calcul de l'IVL, de l'ES et de l'IVE par spécialité.
- **Répertoire FINESS (DREES / ARS)** : liste des établissements membres de chaque GHT et leurs autorisations d'activité — pour définir le périmètre des flux intra-GHT et les seuils réglementaires par spécialité.
- **Décrets et arrêtés d'autorisation ATIH / Ministère de la Santé** : seuils minimaux d'activité par spécialité (chirurgie cardiaque, neurochirurgie, cancérologie, obstétrique, etc.) — pour le calcul de l'IVL.
- **ScanSanté** : données agrégées de volumes par GHM et par établissement — pour le benchmarking des seuils et la comparaison inter-GHT.
- **ROR — Répertoire Opérationnel des Ressources (ANS)** : cartographie des services ouverts, des équipements et des capacités par établissement — pour compléter l'analyse PMSI par les ressources humaines et matérielles disponibles.

## Exemple de Valeurs

- **Patches autonomes (IVL ≥ 1,0, ES < 0,2)** : services MCO de médecine générale et de chirurgie orthopédique dans les CHG de taille moyenne — viabilité propre, faible dépendance aux transferts GHT (60-70 % des services MCO dans un GHT type).
- **Patches sauvés (IVL < 1,0, IVE ≥ 1,0)** : neurochirurgie légère, cardiologie interventionnelle ou chirurgie thoracique dans les CHG disposant d'une autorisation mais à faible volume local — maintenus grâce à 35-60 % de patients adressés par les autres membres du GHT (15-20 % des services dans un GHT type).
- **Patches éteints (IVE < 1,0)** : chirurgie cardiaque avec CEC dans les CHG sous 150 interventions/an malgré les flux GHT, ou unités de soins palliatifs dédiées dans les petits établissements ruraux — représentent 5-15 % des spécialités autorisées dans un GHT, mais concentrent les enjeux de désert médical spécialisé les plus critiques.
- **Hubs attracteurs (IVL ≥ 1,0, ES > 0,4)** : plateau technique d'imagerie interventionnelle ou bloc de chirurgie complexe dans l'établissement support du GHT — génèrent 40-60 % de leur activité à partir d'adressages des établissements partenaires, jouant un rôle de patch "source" dans la métapopulation (voir [[centralite_betweenness_ght_reseau_soins]]).
- **Équilibre de Levins p* typique** : dans un GHT de taille moyenne, p* ~ 0,75-0,85 pour les spécialités chirurgicales (75-85 % des autorisations sont effectivement exercées au-dessus du seuil de viabilité, contre 15-25 % en situation précaire).

## Limites

- **Les seuils ATIH sont des seuils réglementaires, pas des seuils de qualité optimale** : un service à 105 % du seuil minimal ATIH est réglementairement "viable" mais peut avoir des résultats cliniques médiocres en raison d'un volume insuffisant pour maintenir la compétence — l'IVL mesure la viabilité administrative, pas la qualité des soins produits.
- **Le modèle de Levins suppose des patches équivalents et des migrations aléatoires** — hypothèse non vérifiée dans un GHT où les établissements sont de tailles très différentes et où les flux de patients suivent des logiques géographiques et médicales structurées. Les extensions du modèle (patches hétérogènes, modèles source-puits) sont plus réalistes mais nécessitent davantage de paramètres.
- **Dépendance aux conventions intra-GHT** : l'effet de sauvetage mesuré par l'ES suppose que les flux actuels de transferts sont stables et durables — une fragilité que l'indicateur signale mais ne corrige pas. Un ES élevé sans convention formelle est un risque non sécurisé.
- **Les flux entrants PMSI ne distinguent pas les transferts organisés** (conventionnés, planifiés) des transferts circonstanciels (urgence, débordement) — un ES calculé sur des transferts d'urgence saisonniers ne garantit pas la viabilité annuelle du service.
- **L'indicateur ne capture pas les ressources humaines** : un service peut être au-dessus du seuil d'activité ATIH tout en étant fragilisé par un déficit de praticiens — la perte d'un chirurgien unique dans un service à IVL = 1,1 peut l'amener instantanément sous le seuil sans que l'indicateur PMSI l'anticipe.

## Références

- [Levins R., *Some demographic and genetic consequences of environmental heterogeneity for biological control*, Bulletin of the Entomological Society of America, 1969](https://doi.org/10.1093/besa/15.3.237) — article fondateur du modèle métapopulationnel
- [Hanski I., *Metapopulation Ecology*, Oxford University Press, 1999](https://global.oup.com/academic/product/metapopulation-ecology-9780198540655) — référence théorique complète
- [ATIH — Seuils d'activité minimale par spécialité (décrets d'autorisation)](https://www.atih.sante.fr/)
- [Ministère de la Santé — Réforme des autorisations d'activités de soins, 2023](https://solidarites-sante.gouv.fr/)
- [ANS — Répertoire Opérationnel des Ressources (ROR)](https://esante.gouv.fr/produits-services/repertoire-ror)
- [ScanSanté — Volumes d'activité par établissement et par GHM](https://www.scansante.fr/)
- [DREES — Dynamique des services hospitaliers et déserts médicaux spécialisés](https://www.drees.solidarites-sante.gouv.fr/)
