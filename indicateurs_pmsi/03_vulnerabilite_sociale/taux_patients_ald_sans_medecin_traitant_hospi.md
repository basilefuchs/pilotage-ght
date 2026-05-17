# Taux de Patients ALD sans Médecin Traitant chez les Hospitalisés

## Définition

Le **taux de patients ALD sans médecin traitant chez les hospitalisés** mesure la part des séjours MCO de patients bénéficiant d'une **affection longue durée (ALD)** pour lesquels aucun **médecin traitant** n'est déclaré actif dans le SNDS sur la fenêtre des 12 mois précédant l'admission.

L'indicateur s'inscrit dans le cadre de l'**Observatoire de l'accès aux soins** lancé par la CNAM le 25 septembre 2025 ([communiqué CNAM](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)) qui suit publiquement le taux de patients ALD sans médecin traitant — passé de **5,4 % en 2022 à 3,8 % en décembre 2024**, soit environ 620 000 personnes ALD concernées ; la cible conventionnelle est de **2 %** ([Le Généraliste — 620 000 ALD sans MT](https://www.legeneraliste.fr/actu-pro/politique-de-sante/620-000-patients-en-affection-longue-duree-sans-medecin-traitant-cnam) ; [Egora — chiffres CNAM](https://www.egora.fr/actus-pro/acces-aux-soins/patients-en-ald-sans-medecin-traitant-lassurance-maladie-devoile-de)). La perte du médecin traitant est un signal central de **désaffiliation** : elle prive le patient ALD du parcours de soins coordonné (tarif optimal, ordonnance ALD, suivi annuel obligatoire) et augmente le recours aux urgences.

L'**originalité** de l'indicateur appliqué à l'hospitalisation est de mesurer non pas la prévalence populationnelle (indicateur CNAM), mais la **sur-représentation hospitalière** des patients désaffiliés — proxy direct de l'effet de la désaffiliation sur le recours aigu.

**Formule :**

**TASMT = N_séjours_ALD_sans_MT_12m / N_séjours_ALD**

avec
- patient ALD : référentiel CNAM ALD active à la date d'admission (`IR_IMB_R`)
- sans MT : aucune déclaration de médecin traitant active dans la table `IR_BEN_R` SNDS sur les 12 mois précédant l'admission

## Positionnement vs indicateurs existants

Le projet contient :
- `score_vulnerabilite_sociale.md` — score composite
- `indice_retention_soins_primaires.md` — rétention soins primaires (général)
- `indice_upc_continuite_medecin_traitant.md` (cat. 07) — continuité MT (mesure UPC sur les patients qui ont un MT)
- `taux_primo_hospitalisation.md` — primo-hospi
- `taux_recours_ajuste_fdep.md` — recours ajusté FDep

Aucun indicateur ne mesure spécifiquement la **désaffiliation MT chez les hospitalisés ALD**, alors que ce signal est désormais opposable (Observatoire CNAM) et cible conventionnelle (2 %).

## Calcul

### 1. Périmètre

```
Inclusion :
  - RSA MCO complet
  - Patient avec au moins une ALD active à la date d'admission
    (référentiel CNAM, table IR_IMB_R, codes ALD 1-30)
  - Patient avec historique SNDS ≥ 12 mois (sinon « non évaluable »)

Exclusion :
  - Mineurs (médecin traitant pédiatrique pris en compte séparément, peu
    de patients ALD pédiatriques)
  - Séjours obstétricaux (HOR cohérence)
  - Patients étrangers en court séjour
```

### 2. Détection « sans médecin traitant »

```
Pour chaque patient i de la cohorte :
  Récupérer dans IR_BEN_R les déclarations de médecin traitant actif
  sur la fenêtre [date_admission - 12 mois, date_admission - 1 jour].

  MT_actif_i = 1 SI au moins une déclaration de MT (RAMU / sub MT)
                effective et non-clôturée dans la fenêtre.

  Sans_MT_i = 1 - MT_actif_i
```

### 3. Calcul de l'indicateur

```
TASMT = Σ_i Sans_MT_i / Σ_i 1{ALD admis}
```

### 4. Sous-indicateurs

- **TASMT par ALD** : ALD 8 (diabète), ALD 5 (IC), ALD 30 (cancer), ALD 23 (psychiatrie) — gradient attendu, psychiatrie souvent désaffiliée.
- **TASMT par FDep quintile** : croisement avec gradient social.
- **TASMT par tranche d'âge** : 18-44 (souvent désaffiliés), 65-79, 80+.
- **TASMT par mode d'entrée** : urgences (souvent sans MT) vs programmé.
- **Croisement avec issue** : taux de réadmission 30j, retour urgences 7j stratifiés par MT/sans MT — quantifie le sur-risque.
- **TASMT par bassin (CPTS / EPCI)** : identifie les zones où l'offre primaire ne capte plus la population ALD.

## Utilité

- **Indicateur d'aval direct de l'Observatoire CNAM** : un GHT peut comparer son TASMT (mesuré sur sa file active hospitalisée ALD) avec la cible nationale CNAM 2 % et la prévalence populationnelle 3,8 %. Un écart positif signe une sur-représentation hospitalière des désaffiliés.
- **Pilotage des CPTS et des MSP** : chaque ALD identifié sans MT à l'hôpital doit faire l'objet d'un signalement CPTS pour réaffiliation ; TASMT mesure le flux entrant à traiter.
- **Argumentaire pour le déploiement des « médecins traitants partagés »** et des consultations de cardiologie/pneumologie/oncologie en ville : un TASMT élevé sur une ALD spécifique cible l'effort.
- **Évaluation des programmes d'aide à la déclaration** : lettre ARS, accompagnement CPAM — effet attendu = baisse TASMT.
- **Cohérence ARS/contrat GHT** : indicateur direct du Pacte d'accès aux soins, opposable au contrat d'objectifs.
- **Détection des patients à risque dès l'admission** : un patient ALD sans MT admis doit déclencher une consultation sociale et un effort de réaffiliation à la sortie (sortie en réseau CPTS, lettre au médecin traitant à choisir).
- **Articulation avec les indicateurs de parcours** : TASMT croisé avec `taux_retour_urgences_7j_post_sortie_mco.md` et `taux_suivi_ambulatoire_post_hospitalier.md` quantifie le sur-risque de fragmentation post-sortie.

## Sources de Données

- **PMSI MCO — RSA** : `AGE_AN`, `SEXE`, `GHM`, `DP`, `DAS`, `MODE_ENTREE`, `SOR_MOD`, `FINESSGEO`, identifiant chaîné via fichier ANO
- **SNDS — DCIR** :
  - `IR_BEN_R` — table bénéficiaires : variable de médecin traitant (RAMU MTT)
  - `IR_IMB_R` — table affections longue durée (ALD actives)
- **Référentiels CNAM** :
  - [CNAM — Observatoire de l'accès aux soins (data ameli, MAJ trimestrielle)](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
  - [La Médicale — synthèse Observatoire accès aux soins](https://www.lamedicale.fr/vous-informer/zoom-sur-le-nouvel-observatoire-de-l-acces-aux-soins-de-la-cnam)
- **DREES** :
  - [DREES — Baromètre santé 2023 (Dataviz)](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre) — taux de non-consultation
  - [DREES — ER1301 — Médecins généralistes refusant nouveaux patients](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/etudes-et-resultats/les-deux-tiers-des-generalistes-declarent-0)
- **Documentation SNDS** : [Variables sociodémographiques SNDS](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- **HAS** : [Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins) — cadre méthodologique

## Exemple de Valeurs

Ordres de grandeur calibrés sur les chiffres CNAM 2022-2024 et l'expertise hospitalière :

- **Prévalence populationnelle ALD sans MT (CNAM, déc. 2024)** : 3,8 % ; cible conventionnelle 2 %.
- **TASMT (file hospitalière ALD)** : 5-10 % attendu (sur-représentation hospitalière vs population générale).
- **Bassin urbain dense / banlieue déficitaire** : 8-15 %.
- **Bassin rural sous-dense en MG** : 10-18 %.
- **Bassin urbain bien doté** : 3-6 %.
- **ALD 23 (psychiatrie)** : 12-25 % — fortement désaffiliée.
- **ALD 8 (diabète)** : 4-8 %.
- **ALD 30 (cancer)** : 2-5 % — typiquement bien suivie.
- **Patient admis par urgences** : 2 à 3 fois TASMT_programmé.
- **Seuil d'alerte territorial** : TASMT > 10 % sur 2 années consécutives → alerte CPTS et ARS ; déficit de capacité de captation des ALD par l'offre primaire.

## Limites

- **Déclaration MT ≠ consultation effective** : un patient peut avoir un MT déclaré mais ne plus le voir (MT retraité, déménagement). Indicateur dérivé possible : « MT déclaré ET consultation MT dans les 12 mois ».
- **Décès / disparition MT** : un MT décédé sans réaffectation n'est pas systématiquement marqué « clôturé » dans `IR_BEN_R` — possible faux négatif (patient sans MT effectif mais MT « déclaré » technique).
- **Mobilité géographique** : un patient récemment installé dans le territoire GHT n'a pas encore eu le temps de déclarer ; sous-cohorte « installation récente » à isoler.
- **Disponibilité SNDS** : un GHT n'a pas accès direct en routine au SNDS national ; nécessite une convention HDH ou un accès via la CNAM. Proxy local PMSI seul : insuffisant — la déclaration MT n'est pas dans le RSA.
- **Sensibilité à la définition de l'ALD** : ALD ouverte récemment (< 12 mois) → fenêtre 12 mois mal calibrée. Ajuster la fenêtre à la durée d'ALD ouverte si plus courte.
- **Effet Observatoire CNAM** : le suivi public génère une pression administrative à la déclaration ; la baisse 2022→2024 reflète en partie un effet « régularisation » plus qu'une réelle amélioration d'accès aux soins. Lire en parallèle du taux de consultation MT effective.
- **Indicateur d'aval** : ne mesure pas la qualité de la consultation primaire, seulement son existence administrative.
- **Volumes minimaux** : sous 200 séjours ALD/an dans un bassin, instabilité. Agréger 2 ans.
- **Comparaison avec indicateurs internationaux** : le « médecin traitant » est une spécificité française ; benchmark international peu pertinent.
- **Pédiatrie** : système distinct (médecin référent pédiatrique) — exclure ou traiter en sous-cohorte.

## Références

Pas de PMID PubMed français spécifique vérifié pour cet indicateur dans la session ; la littérature de référence est francophone et institutionnelle.

Sources officielles vérifiées dans la session :

- [CNAM — Observatoire de l'accès aux soins (lancement 25 sept. 2025)](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
- [La Médicale — Présentation Observatoire CNAM](https://www.lamedicale.fr/vous-informer/zoom-sur-le-nouvel-observatoire-de-l-acces-aux-soins-de-la-cnam)
- [Le Généraliste — 620 000 patients ALD sans MT](https://www.legeneraliste.fr/actu-pro/politique-de-sante/620-000-patients-en-affection-longue-duree-sans-medecin-traitant-cnam)
- [Egora — Patients ALD sans MT, chiffres CNAM](https://www.egora.fr/actus-pro/acces-aux-soins/patients-en-ald-sans-medecin-traitant-lassurance-maladie-devoile-de)
- [PharmAnalyses — 11 % patients sans MT (population générale)](https://pharmanalyses.fr/sante-11-des-patients-sont-sans-medecins-traitants/)
- [DREES — Baromètre santé 2023 Dataviz](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre)
- [DREES — ER1301 — MG refusant nouveaux patients](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/etudes-et-resultats/les-deux-tiers-des-generalistes-declarent-0)
- [Sénat — Rapport équité territoriale accès soins (R21-589)](https://www.senat.fr/rap/r21-589/r21-5892.html)
- [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
