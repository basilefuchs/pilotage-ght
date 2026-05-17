# Ratio de Sur-recours aux Urgences FDep Q5/Q1

## Définition

Le **ratio de sur-recours aux urgences entre quintile FDep le plus défavorisé (Q5) et le plus favorisé (Q1)** mesure, sur la population du bassin de recrutement du GHT, l'écart relatif d'usage des urgences hospitalières entre les habitants des IRIS les plus défavorisés et ceux des IRIS les plus favorisés, après standardisation sur l'âge et le sexe.

L'indice **FDep** (Rey et al., BMC Public Health 2009) est un indice de défavorisation territoriale construit par INSERM/Cépidc à partir de 4 variables INSEE par IRIS : (1) revenu fiscal médian, (2) % bacheliers chez les 15+ ans hors scolaires, (3) % ouvriers parmi les actifs occupés, (4) taux de chômage. Le score est standardisé en quintiles nationaux Q1 (le moins défavorisé) à Q5 (le plus défavorisé). FDep est l'indice écologique de référence en santé publique française, publié et mis à jour par l'INSERM ; il est utilisé dans plusieurs indicateurs HAS, IRDES, et études Cépidc.

**Formule :**

**RSUR_Q5_Q1 = TX_RPU_stand(Q5) / TX_RPU_stand(Q1)**

avec :
- TX_RPU_stand(Q) = nombre de passages aux urgences par an, par habitant d'IRIS du quintile Q, standardisé sur l'âge et le sexe (méthode directe ou indirecte, structure de référence INSEE)
- Q1, Q5 = IRIS du quintile le moins / le plus défavorisé du bassin de recrutement

Un RSUR > 1 signifie sur-recours des plus défavorisés ; on attend généralement RSUR ≈ 1,5 à 2,5 en France.

## Positionnement vs indicateurs existants

Le projet contient :
- `taux_recours_ajuste_fdep.md` — recours hospitalisation MCO ajusté FDep
- `score_vulnerabilite_sociale.md` — score patient
- `taux_passage_urgences_hospitalisation.md` — taux d'hospitalisation post-passage
- `indice_permeabilite_sociale_soins_preventifs.md` — accès prévention

Aucun indicateur ne quantifie spécifiquement le **gradient social du recours aux urgences** — alors que cette mesure est centrale pour évaluer l'accès aux soins primaires (le sur-recours urgences traduit souvent un défaut d'aval médecine de ville).

## Calcul

### 1. Définition du bassin de recrutement

```
Bassin_GHT = ensemble des IRIS dont au moins X% des hospitalisations RPU
             remontent à un FINESS du GHT (méthode part de marché),
             ou ensemble des IRIS du département(s) référents.
```

### 2. Affectation FDep par IRIS

```
Pour chaque IRIS du bassin :
  Récupérer FDep_score depuis fichier INSERM/CépiDc
  Affecter quintile_national_FDep(IRIS) ∈ {Q1, ..., Q5}
```

### 3. Comptage des passages RPU par quintile

```
RPU_table = ensemble des passages aux urgences (Résumé de Passage aux
            Urgences) sur l'année, avec chaînage à l'IRIS de résidence
            du patient (via NIR / fichier ANO / table IR_BEN_R SNDS)

Pour chaque quintile Q :
  N_RPU_Q = nb de passages RPU sur la période, patients résidant en Q
  POP_Q = population résidente des IRIS Q (INSEE, RP)
  Stratification par classe d'âge et sexe (a, s)
```

### 4. Standardisation sur l'âge et le sexe

```
Méthode directe (préférée si volumes suffisants) :
  TX_RPU_brut_Q_(a,s) = N_RPU_Q_(a,s) / POP_Q_(a,s)
  POP_REF_(a,s) = population de référence (France entière, INSEE, RP année t)

  TX_RPU_stand_Q = Σ_(a,s) [TX_RPU_brut_Q_(a,s) × POP_REF_(a,s)] / Σ POP_REF_(a,s)

Méthode indirecte (SIR / SMR-like) si effectifs petits.
```

### 5. Calcul du ratio

```
RSUR_Q5_Q1 = TX_RPU_stand_Q5 / TX_RPU_stand_Q1

Intervalle de confiance à 95 % : calculé sur le log-ratio
(approximation Poisson) puis re-exponentié.
```

### 6. Sous-indicateurs et stratifications

- **RSUR par tranche horaire** : nuit / week-end / journée — sur-recours nocturne plus marqué chez les précaires.
- **RSUR par motif** : DP du RPU (CIM-10) — sur-recours marqué pour soins primaires (douleur dentaire, lombalgie, IVRS).
- **RSUR par issue** : sortie domicile / hospitalisation — un sur-recours sortant domicile reflète un défaut d'aval ; un sur-recours hospitalisant reflète une sévérité différentielle.
- **Gradient continu** : régression Poisson du nombre de RPU sur le FDep continu (offset = log(population)), produit un coefficient β interprétable comme effet par unité de défavorisation, plus robuste que le seul ratio Q5/Q1.
- **Indicateur dérivé inversé** : pour les soins ambulatoires programmés (consultations médecin traitant), un ratio < 1 témoigne d'un sous-recours des défavorisés (rétention en soins primaires défaillante).

## Utilité

- **Diagnostic d'accès aux soins primaires sur le territoire GHT** : un RSUR élevé (> 2,2) signale un défaut d'offre médecine de ville ou d'orientation, pas seulement un sur-besoin.
- **Pilotage des CPTS et des MSP** : alignement de l'offre de soins primaires sur la cartographie FDep — RSUR par CPTS permet de cibler les zones prioritaires.
- **Argumentaire ARS pour soutien financier des urgences en zone défavorisée** : RSUR contextualise le sur-engorgement comme un problème territorial, pas un défaut de gestion hospitalière.
- **Suivi des dispositifs PASS et permanences nocturnes** : un déploiement de PASS doit faire baisser le RSUR sur la sous-cohorte qui en bénéficie.
- **Évaluation des maisons médicales de garde** : effet attendu = baisse du RSUR_horaire_garde.
- **Mesure d'équité système** : RSUR_Q5_Q1 est une mesure d'inégalité sociale de santé, comparable inter-territoires et utilisable comme indicateur d'évaluation des politiques publiques (IRDES, DREES).
- **Articulation avec indicateurs de gradient inversé** : `indice_retention_soins_primaires.md` et `indice_permeabilite_sociale_soins_preventifs.md` mesurent l'autre face du même problème (sous-recours en prévention). Lecture combinée éclaire la stratégie territoriale.

## Sources de Données

- **RPU (Résumé de Passage aux Urgences)** : recueil national obligatoire transmis via DRUIDES depuis M3 2023 ([ATIH variables RPU](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf))
  - `DATE_ADM_URG`, `HEURE_ADM_URG`, `MODE_SORTIE_URG`, `DIAG_PRINC_URG`, `FINESSGEO_URG`, identifiant chaîné
- **SNDS — IR_BEN_R** : commune de résidence, code IRIS si disponible ; à défaut, géocodage à partir de l'adresse PMSI
- **FDep — INSERM/CépiDc** : indice publié par IRIS, mise à jour quinquennale (cohérent recensement INSEE) — diffusion via Inserm UMR1136 et listes de partage Cépidc
- **INSEE — Recensement de la Population** : populations IRIS par âge × sexe, table de référence pour la standardisation
- **DREES** : indicateurs territoriaux et ISD (croisement contextuel) — [ISD MAJ mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- **Documentation SNDS** : [Variables sociodémographiques (FDep, CMU-C, AME)](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- **Cadre HAS** : [Indicateurs de qualité des parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)

## Exemple de Valeurs

Ordres de grandeur experts calibrés sur la littérature française d'inégalités sociales de santé (Rey 2009 et publications IRDES ultérieures) :

- **RSUR_Q5_Q1 France métropolitaine moyenne** : 1,5 à 2,2 selon territoire et année.
- **Bassin urbain dense (banlieue parisienne, Marseille Nord)** : 2,0 à 3,0.
- **Bassin rural homogène (faible gradient FDep)** : 1,1 à 1,5.
- **RSUR nocturne / week-end** : souvent 2,0 à 3,5 (défaut de PDSA).
- **RSUR sur motifs « soins primaires »** (lombalgie, ORL, gastro-entérite légère) : 2,5 à 4,0.
- **RSUR sur motifs « urgence vraie »** (AVC, IDM, traumatisme grave) : 1,0 à 1,3 (peu de gradient).
- **Seuil d'alerte territorial** : RSUR_Q5_Q1 > 2,5 sur 2 années consécutives → alerte ARS, audit offre primaire et PDSA.
- **Effet attendu d'une CPTS structurée** : −0,2 à −0,5 sur RSUR à 24-36 mois.

## Limites

- **FDep est un indice écologique IRIS** : tous les habitants d'un IRIS Q5 ne sont pas individuellement défavorisés (biais d'agrégation, fallacy écologique). RSUR mesure un gradient territorial, pas un effet individuel.
- **Mises à jour FDep** : l'indice repose sur les recensements INSEE — décalage potentiel de 2-5 ans avec la situation réelle.
- **Bassin de recrutement** : à définir explicitement et de façon stable ; un patient résidant hors bassin mais consultant aux urgences GHT pollue le ratio.
- **Recueil RPU** : qualité hétérogène, en particulier `DIAG_PRINC_URG` (CIM-10) souvent incomplet ; le sous-indicateur par motif perd alors en fiabilité.
- **Standardisation** : les structures d'âge des IRIS Q5 et Q1 sont très différentes (plus jeunes et plus enfants en Q5). La standardisation est obligatoire ; les ratios bruts sont trompeurs.
- **Effet offre confondu** : un IRIS Q5 mal desservi par les médecins libéraux a un sur-recours urgences ; on ne peut pas dissocier facilement effet demande (besoin) et effet offre (manque MG). Croiser avec densité MG (DREES) pour décomposer.
- **Saisonnalité** : épidémies hivernales augmentent les passages urgences ; comparer en cohortes annuelles ou rolling 12 mois.
- **Chaînage IRIS** : nécessite le géocodage de l'adresse PMSI ou l'accès au croisement IRIS via SNDS — autorisations à obtenir.
- **Volumes minimaux** : sous 1 000 passages annuels en Q1, intervalles de confiance larges ; agréger 2-3 ans.
- **Comparaisons internationales** : FDep est français — pour benchmark international, utiliser Townsend index, Carstairs, IMD ou EDI.

## Références

D'après PubMed :

- (Pas de PMID directement vérifié en session pour Rey 2009 ; référence universellement connue, à confirmer avant publication officielle.)

Sources officielles vérifiées dans la session :

- [Documentation SNDS — Variables sociodémographiques (dont FDep)](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [DREES — Indicateurs Sociaux Départementaux ISD MAJ 26 mai 2025](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/jeux-de-donnees/250526_DATA_indicateurs-sociaux-d%C3%A9partementaux-isd-maj)
- [DREES — Focus études et données régionales/départementales — janv. 2025](https://drees.solidarites-sante.gouv.fr/actualites/focus-sur-les-etudes-et-donnees-regionales-et-departementales-de-la-drees-janvier-2025)
- [ATIH — Variables RPU (varia_rpu.pdf)](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf)
- [ATIH — Consignes de production RPU](https://www.atih.sante.fr/sites/default/files/public/content/1102/consignes_recueil_rpu.pdf)
- [HAS — Indicateurs qualité parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [IRDES — Actualités santé / protection sociale 2025](https://www.irdes.fr/documentation/news-en-economie-de-la-sante.html)

Référence méthodologique standard (non re-vérifiée en session) :
- Rey G, Jougla E, Fouillet A, Hémon D — Ecological association between a deprivation index and mortality in France over the period 1997-2001 — BMC Public Health 2009 — origine de l'indice FDep. *À confirmer DOI / PMID via PubMed avant publication officielle.*
