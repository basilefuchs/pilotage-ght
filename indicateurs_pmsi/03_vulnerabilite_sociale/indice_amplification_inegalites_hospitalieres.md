# Indice d'Amplification des Inégalités Hospitalières

## Définition

L'**indice d'amplification des inégalités hospitalières (IAIH)** mesure si l'hôpital — pris comme système — agit comme **amplificateur**, **neutre**, ou **correcteur** des inégalités sociales de santé observées à l'entrée. L'indicateur compare le **gradient social FDep Q5/Q1** mesuré à trois étapes du séjour :

1. **À l'admission** : sévérité GHM (proxy de l'état de santé à l'entrée)
2. **Pendant le séjour** : DMS ajustée et accès aux ressources techniques (chirurgie ambulatoire, RAAC, plateaux techniques)
3. **À la sortie** : événements indésirables à 7-30j (retour urgences 7j, réadmission 30j, mortalité 30j)

Le principe : si le gradient Q5/Q1 reste **stable** entre l'admission et la sortie, l'hôpital est neutre vis-à-vis des inégalités. Si le gradient **s'accentue** (les Q5 ont des outcomes proportionnellement pires que ce que leur sévérité d'entrée laissait prévoir), l'hôpital amplifie. S'il **diminue**, l'hôpital corrige.

**Formules :**

```
G_severite        = mean(sévérité_GHM | Q5) / mean(sévérité_GHM | Q1)
G_DMS_aj          = DMS_ajustée(Q5) / DMS_ajustée(Q1)
G_RU7J            = TX_RU7J(Q5) / TX_RU7J(Q1)
G_REA30           = TX_réadm_30j(Q5) / TX_réadm_30j(Q1)
G_MORT30          = TX_mortalité_30j_post_sortie(Q5) / TX_mortalité_30j(Q1)
```

**Indice d'amplification (deux versions) :**

```
IAIH_RU7J   = G_RU7J  / G_severite
IAIH_REA30  = G_REA30 / G_severite
IAIH_MORT30 = G_MORT30 / G_severite
```

- IAIH = 1 : neutre, l'hôpital reproduit le gradient d'entrée
- IAIH > 1 : amplificateur (l'hôpital « ajoute » aux inégalités)
- IAIH < 1 : correcteur

## Positionnement vs indicateurs existants

Le projet contient :
- `ratio_surrecours_urgences_fdep_q5_q1.md` (ce dossier) — gradient d'usage urgences
- `taux_recours_ajuste_fdep.md` — recours ajusté
- `score_vulnerabilite_sociale.md` — score patient
- `taux_retour_urgences_7j_post_sortie_mco.md` (cat. 07)

Aucun indicateur ne **décompose explicitement le gradient social en trois étapes** pour déterminer si l'hôpital amplifie ou corrige les inégalités. C'est une approche d'**audit d'équité système** transposée du cadre des « disparities measures » de l'AHRQ (Agency for Healthcare Research and Quality) — habituellement réservée aux études, ici opérationnalisée comme indicateur de pilotage.

## Calcul

### 1. Définition des cohortes

```
Q1 = séjours MCO de patients IRIS FDep quintile 1 (national)
Q5 = séjours MCO de patients IRIS FDep quintile 5 (national)
Restreindre aux séjours « index » : 1 séjour par patient et par épisode
de soins, sortie vivante (pour les indicateurs d'aval).
```

### 2. Mesure du gradient à l'admission (G_severite)

```
Pour chaque cohorte Q :
  sévérité_s = niveau de sévérité (4e caractère du GHM) ∈ {1, 2, 3, 4}
  pondérer en variable continue selon les coefficients de complexité de
  la version GHM en vigueur (à confirmer dans le manuel ATIH)
mean_sev_Q = moyenne pondérée sur Q
G_severite = mean_sev_Q5 / mean_sev_Q1
```

### 3. Mesure du gradient sur la DMS ajustée

```
Modèle mixte :
  log(`duree`) ~ racine_GHM + sévérité + age + sexe + Charlson + (1|FINESSGEO)
DMS_ajustée_Q = exponentielle des effets fixes attribuables à Q
G_DMS_aj = DMS_aj(Q5) / DMS_aj(Q1)
```

### 4. Mesure des gradients d'événements indésirables

```
TX_RU7J(Q)     = nb_séjours_avec_RPU_<= 7j / nb_séjours_éligibles_Q
TX_REA30(Q)    = nb_séjours_avec_réadm_<= 30j / nb_séjours_éligibles_Q
TX_MORT30(Q)   = nb_décès <= 30j post-sortie / nb_séjours_éligibles_Q
(standardisés sur âge, sexe, racine_GHM, sévérité)

G_RU7J  = TX_RU7J(Q5)  / TX_RU7J(Q1)
G_REA30 = TX_REA30(Q5) / TX_REA30(Q1)
G_MORT30= TX_MORT30(Q5)/ TX_MORT30(Q1)
```

### 5. Indices d'amplification

```
IAIH_RU7J   = G_RU7J   / G_severite
IAIH_REA30  = G_REA30  / G_severite
IAIH_MORT30 = G_MORT30 / G_severite

Score composite : IAIH_global = mean(IAIH_RU7J, IAIH_REA30, IAIH_MORT30)
ou plus prudemment : présenter les trois séparément.

Intervalles de confiance par bootstrap (B = 1000).
```

### 6. Sous-indicateurs

- **IAIH par CMD** : repère les filières amplificatrices vs neutres ; typiquement les filières « organisées » (cancer, chirurgie programmée) corrigent, celles « non organisées » (urgences-médecine polyvalente) amplifient.
- **IAIH par établissement** dans le GHT : compare les sites sur leur équité interne.
- **Décomposition mécanique** : IAIH peut être amplificateur sur l'aval (RU7J élevé) tout en étant correcteur sur la DMS — décomposer pour orienter l'action.

## Utilité

- **Diagnostic d'équité système** : un GHT peut, pour la première fois, savoir s'il **ajoute** ou **soustrait** aux inégalités sociales. C'est un méta-indicateur de mission de service public.
- **Pilotage d'actions correctrices** : un IAIH_RU7J > 1,3 sur une CMD signale un défaut d'organisation de la sortie pour les Q5 — programme de coordination renforcée, IPA précarité, lettre de liaison adaptée.
- **Inscription dans le CPOM ARS** : indicateur d'équité opposable, aligné sur la stratégie DGOS 2025-2027 et sur les axes IRDES/DREES.
- **Comparaison inter-GHT** : à profil d'entrée comparable, identifier les GHT correcteurs et étudier leurs pratiques.
- **Évaluation des interventions ciblées** : déploiement d'une PASS, d'une consultation interprète, d'une IPA aval → suivi IAIH avant/après.
- **Argumentaire pour financement spécifique précarité** : un IAIH_MORT30 > 1,2 démontre un sur-risque non corrigé, justifiant un financement MIG précarité ou une dotation populationnelle ajustée.
- **Articulation avec la HAS et la certification** : la HAS inscrit progressivement des dimensions d'équité dans la certification ; IAIH fournit un proxy quantitatif.

## Sources de Données

- **PMSI MCO — RSA** : `GHM`, sévérité, `duree`, `SOR_MOD`, `modeentree`, `age`, `SEXE`, `DAS` (Charlson), `FINESSGEO`, identifiant chaîné ANO
- **RPU urgences** : pour `TX_RU7J`
- **SNDS — DCIR** :
  - `IR_BEN_R` : commune/IRIS résidence (lien avec FDep)
  - `IR_DECES_F` ou équivalent : décès pour `TX_MORT30`
- **FDep INSERM/CépiDc** : IRIS → quintile national
- **Référentiels** :
  - [ATIH — Notice technique PMSI 2025](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf) — niveaux de sévérité GHM
  - [ATIH — Variables RPU](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf)
  - [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
  - [Documentation SNDS — variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
  - [DREES — ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- **Cadre conceptuel** : « disparities measures » AHRQ, transposé.

## Exemple de Valeurs

Ordres de grandeur experts ; pas de restitution publique équivalente directe connue dans la session :

- **G_severite typique** : 1,05-1,20 (les Q5 entrent un peu plus sévères, mais l'écart est modéré).
- **G_DMS_aj** : 1,03-1,10 (DMS ajustée plus longue pour Q5 — déjà documenté).
- **G_RU7J** : 1,2-1,7 (retour urgences plus fréquent chez Q5).
- **G_REA30** : 1,15-1,5.
- **G_MORT30** : 1,1-1,4.
- **IAIH_RU7J typique France** : 1,1-1,4 (légère amplification d'aval).
- **IAIH_REA30** : 1,0-1,3.
- **IAIH_MORT30** : 1,0-1,2 (souvent peu d'amplification mortalité — les soins aigus sont relativement équitables).
- **Filière oncologie** : IAIH souvent proche de 1 ou < 1 (filière organisée corrigeant).
- **Filière médecine polyvalente / urgences** : IAIH > 1,3 fréquent (sortie peu coordonnée).
- **Seuils d'alerte** : IAIH > 1,3 sur 2 ans = amplification structurelle, plan d'action ; IAIH > 1,5 = alerte forte.

## Limites

- **Causalité non démontrée** : IAIH > 1 indique une amplification *observée* mais ne dit pas si elle est due à l'hôpital (qualité de soins différentielle) ou à l'environnement post-sortie (logement, soutien familial). Une IAIH > 1 ne désigne donc pas un coupable, mais signale une zone d'action conjointe ville-hôpital.
- **Ajustement risque** : l'efficacité de la décomposition dépend de la qualité de l'ajustement (Charlson, sévérité, casemix). Une sévérité GHM sous-codée chez les Q5 fait paraître artificiellement l'hôpital plus amplificateur. Audit de codage préalable obligatoire.
- **Fdep écologique** : tous les Q5 ne sont pas individuellement défavorisés — biais d'agrégation (lecture territoriale, pas individuelle).
- **Effet offre vs effet hôpital** : un Q5 qui rentre chez lui dans un logement insalubre sans suivi MG aura un RU7J élevé indépendamment de ce que l'hôpital fait. IAIH attribue à l'hôpital une partie de cet effet.
- **Mort différentielle (informative censoring)** : un patient Q5 décédé pendant son séjour n'apparaît pas dans les indicateurs post-sortie, ce qui peut fausser à la baisse `G_MORT30`. Inclure mortalité intra-séjour en alternative.
- **Volumes** : nécessite Q1 et Q5 avec N ≥ 500 séjours/an pour stabilité ; sinon agréger 2-3 ans ou utiliser des quartiles.
- **Comparaisons inter-GHT** : la composition Q1/Q5 du bassin diffère ; comparer à structure casemix-âge-sexe identique.
- **Disponibilité SNDS** : `TX_MORT30` nécessite l'accès SNDS / INSEE — non disponible en routine sur le seul PMSI partagé.
- **Stigmatisation** : présenter avec pédagogie ; un IAIH > 1 n'est pas un blâme mais un signal d'action.
- **Évolution version GHM / RPU** : changements de codage peuvent créer des ruptures de série ; figer les versions.
- **Pas d'indicateur causalement validé** : IAIH est un indicateur de signal, à valider par audits cliniques de cas.

## Références

D'après PubMed :

- [Baker KM et al. — Z codes scoping review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — sous-codage social, condition de validité de IAIH. PMID 39570573
- [Lahbib H et al. — Frailty prediction in French claims, Sci Rep 2025](https://doi.org/10.1038/s41598-025-95629-z) — modèle de prédiction risque, utile pour ajustement. PMID 40175586

Sources officielles vérifiées dans la session :

- [HAS — Indicateurs qualité parcours de soins (cadre méthodologique)](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [ATIH — Notice technique PMSI 2025](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Variables RPU](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf)
- [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [DREES — Indicateurs Sociaux Départementaux MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- [CNAM — Observatoire accès aux soins](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
- [DGOS — Stratégie 2025-2027](https://www.gpm.fr/strategie-dgos-2025-2027/)
- [IRDES — Actualités santé / protection sociale](https://www.irdes.fr/documentation/news-en-economie-de-la-sante.html)

Référence conceptuelle non re-vérifiée :
- AHRQ — National Healthcare Quality and Disparities Reports — méthodologie originelle des « disparities measures ». À confirmer DOI/URL avant publication officielle.
