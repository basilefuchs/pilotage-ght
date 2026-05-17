# Densité d'Épisode Multimodal à 90 Jours

## Définition

La **densité d'épisode multimodal à 90 jours** mesure le nombre moyen de **modalités de prise en charge hospitalière distinctes** mobilisées par un patient sur un épisode glissant de 90 jours suivant un séjour MCO index. Les modalités considérées appartiennent à un ensemble fini :

```
MODALITES = {
   MCO_hospit_complete,
   MCO_HDJ,
   SSR_hospit_complete,
   SSR_HDJ,
   HAD,
   PSY_hospit_complete,
   PSY_ambulatoire,
   Urgences (RPU sans hospitalisation),
   Dialyse_chronique,
   Chimiothérapie_HDJ
}
```

**Formule :**

Pour chaque patient i ayant un séjour MCO index :

**DEM90_i = | { m ∈ MODALITES : patient i a au moins un séjour/séquence de modalité m dans [J_sortie_index, J_sortie_index + 90j] } |**

Indicateur agrégé :

**DEM90 = mean(DEM90_i) sur la cohorte d'index**

L'idée est qu'un **parcours innovant intégré** mobilise plusieurs modalités complémentaires (MCO → HAD → HDJ de suivi), tandis qu'un parcours fragmenté ou peu structuré reste mono-modal (MCO seul) ou hyper-redondant (MCO répété). La densité **n'est pas linéaire en qualité** : on attend une forme de cloche, avec optimum vers 2-3 modalités.

## Positionnement vs indicateurs existants

Le projet contient :
- `indice_fragmentation_parcours_patient.md` — fragmentation (Bice-Boxerman, basé sur visites ville)
- `indice_continuite_parcours_patient.md` — continuité (UPC, ville)
- `indice_complexite_parcours_multi_rum.md` — multi-RUM intra-séjour MCO
- `score_synchronisation_parcours_chronique.md` — synchronisation chronique
- `taux_compression_algorithmique_parcours.md` — compression informationnelle

Aucun indicateur ne mesure spécifiquement la **diversité des modalités hospitalières** mobilisées en aval d'un MCO sur une fenêtre courte. DEM90 capture le degré d'**intégration multi-champs** (MCO/SSR/HAD/Psy/HDJ) qui caractérise les parcours « innovants » au sens de la stratégie DGOS 2025-2027 (« L'offre de soins de demain »).

Le positionnement vs l'indice de fragmentation : la fragmentation mesure une dispersion *non souhaitée* sur des consultations ville ; la densité multimodale mesure une diversité *souhaitable* sur des modalités hospitalières complémentaires.

## Calcul

### 1. Sélection cohorte index

```
Inclusion (séjour MCO index) :
  - RSA MCO sortie vivante
  - Patient adulte (sous-cohortes pédiatrique / obstétricale séparées)
  - DP ou DR appartenant à une cohorte cible (cancer, IC chronique,
    BPCO, AVC, fracture col fémoral, etc.) — pour parcours chronique
  - Premier séjour MCO sur la pathologie cible dans l'année (séjour
    index = épisode index)

Exclusion :
  - Décès intra-séjour ou dans les 90 j (sous-cohorte séparée)
  - Patient hors résidence GHT (faible probabilité de chaînage complet)
```

### 2. Identification des modalités sur [J_sortie, J_sortie+90j]

```
1. Chaîner via fichier ANO le patient sur :
     RSA MCO (en distinguant nature de séjour : J vs non-J)
     RSS SSR / RHA SSR
     RPSA HAD
     RPS Psy
     RPU urgences
     ACE MCO (chimio Z51.1, dialyse Z49)
2. Pour chaque modalité m ∈ MODALITES :
     présence_m_i = 1 si ≥ 1 enregistrement dans la fenêtre
3. DEM90_i = Σ_m présence_m_i
```

### 3. Sous-indicateurs et profils

- **DEM90 brut** : valeur moyenne sur la cohorte.
- **Distribution** : histogramme du nombre de patients ayant 1, 2, 3, 4, 5+ modalités (signal de profil).
- **Profils typiques** (par clustering ou règles déterministes) :
  - mono-modal MCO seul (parcours non structuré)
  - bi-modal MCO + HAD ou MCO + SSR (parcours classique)
  - tri-modal MCO + HAD + HDJ suivi (parcours intégré innovant)
  - hyper-modal 4+ (souvent décompensations itératives — patient à risque)
- **DEM90_pondéré** : poids associés à chaque modalité reflétant l'intégration (HAD = 2, HDJ chronique = 1.5, urgences = -1) pour orienter le score vers l'intégration et pénaliser le passage urgences répété.
- **Indicateur dérivé d'intégration** :
```
INT90 = (présence_HAD + présence_HDJ_chronique + présence_SSR) /
        (1 + nombre_passages_urgences_dans_les_90j)
```

## Utilité

- **Mesure quantitative de l'intégration multi-champs** : un parcours BPCO « cible » mobilise MCO + HAD ponctuel + HDJ pneumologique mensuel + éventuellement réhabilitation respiratoire en SSR → DEM90 ≈ 3-4 si parcours structuré, ≈ 1-2 si parcours non structuré.
- **Pilotage des filières innovantes GHT** : évaluation d'une cellule de coordination parcours sur une pathologie cible, suivi avant/après.
- **Identification des trous d'aval** : un DEM90 faible (1 modalité) avec une mortalité 30 j élevée signale un défaut d'aval structuré sur la pathologie.
- **Caractérisation des « high utilizers »** : les patients DEM90 ≥ 4 sont souvent des patients chroniques décompensés répétés ; à orienter vers un programme de case management (Charles 2024, [DOI](https://doi.org/10.1097/NCM.0000000000000742)).
- **Détection des doublons inutiles** : un DEM90 élevé sur urgences + HDJ + MCO sans HAD ni SSR suggère un parcours répétitif et non intégré ; à articuler avec `indice_fragmentation_parcours_patient.md`.
- **Comparaison inter-GHT** : DEM90 ajusté casemix permet de positionner les territoires sur leur capacité à proposer des parcours alternatifs à l'hospitalisation complète.
- **Indicateur d'alignement avec HAS parcours BPCO** : le référentiel HAS sur les indicateurs de parcours BPCO ([has-sante.fr/p_3326301](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi)) propose plusieurs indicateurs unitaires ; DEM90 fournit un indicateur composite synthétique pour la même cohorte.

## Sources de Données

- **PMSI MCO** : RSA, `nature_séjour` (J vs non-J), `DATE_ENTREE`, `DUREE_SEJOUR`, GHM, FINESSGEO
- **PMSI SSR / SMR** : RHA, séquences de soins SSR
- **PMSI HAD** : RPSA, dates de séquence
- **PMSI Psy** : RPS / R3A
- **RPU urgences** : `DATE_ADM_URG`, `MODE_SORTIE_URG`, `FINESSGEO_URG`
- **ACE PMSI MCO** : prestations chimio (`Z51.1`), dialyse (`Z49.x`) pour distinguer les HDJ itératifs structurels
- **Fichier ANO** : chaînage inter-champs PMSI
- **DCIR SNDS** (optionnel) : pour intégrer les soins de ville (consultations spécialistes, kinésithérapie) en élargissement de la définition des modalités
- **Référentiels** :
  - [ATIH — EMOIS 2023 — Utiliser le PMSI pour analyser les parcours](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf)
  - [HAS — Indicateurs parcours BPCO SNDS / PMSI](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi)
  - [HAS — Indicateurs de qualité des parcours de soins](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins) — cadre méthodologique de validation
  - [ScanSanté — Territoires et parcours](https://www.scansante.fr/applications/territoires-et-parcours-soins)

## Exemple de Valeurs

Ordres de grandeur experts (pas de restitution publique équivalente connue dans la session).

- **Cohorte BPCO post-exacerbation MCO** :
  - DEM90 médian ≈ 2,0-2,5 (MCO index + HDJ pneumo + éventuel SSR respiratoire)
  - Parcours intégré (présence HAD + HDJ + SSR) attendu chez 15-25 % de la cohorte.
- **Cohorte IC chronique post-décompensation** :
  - DEM90 médian ≈ 1,8-2,3 ; cible programme structuré (PRADOC, [DOI](https://doi.org/10.1161/JAHA.123.032931)) > 2,5.
- **Cohorte AVC post-MCO** :
  - DEM90 médian ≈ 2,2-3,0 (MCO + SSR neuro fréquent + HAD rare + HDJ rééducation).
- **Cohorte cancer en cours de traitement** :
  - DEM90 médian ≈ 3,0-3,8 (MCO + HDJ chimio + éventuel HAD + éventuel SSR).
- **Cohorte fracture col fémoral âgée** :
  - DEM90 médian ≈ 2,5-3,2 (MCO orthopédie + SSR + HAD parfois).
- **Profil mono-modal (DEM90 = 1)** :
  - Acceptable < 25 % pour BPCO et IC ; au-delà, défaut d'aval structuré.
- **Profil hyper-modal (DEM90 ≥ 5)** :
  - < 5-10 % attendu ; signal d'alerte parcours chaotique ou décompensations répétées.
- **Seuil d'alerte** : DEM90 stagnant en dessous de la médiane GHT − 1σ sur ≥ 4 trimestres sur cohorte cible structurée → audit filière.

## Limites

- **Diversité ≠ qualité** : DEM90 élevé peut traduire un parcours intégré ET réussi, OU une succession d'événements indésirables (passages urgences répétés, ré-hospitalisations). À lire impérativement en parallèle d'indicateurs d'événements (réadmission, mortalité, retour urgences).
- **Non-monotonie** : la relation DEM90 ↔ qualité n'est pas monotone — l'optimum dépend de la pathologie cible (2-3 pour BPCO, 3-4 pour cancer). Définir des cibles par cohorte, pas universelles.
- **Sensibilité à la définition des modalités** : inclure ou non la chimio HDJ comme modalité distincte change la valeur de l'indicateur — figer la définition.
- **Chaînage SNDS recommandé** : sur le seul périmètre PMSI partagé du GHT, on rate les modalités prises dans d'autres établissements (HAD privée, SSR hors GHT, urgences hors GHT). Sous-estimation systématique.
- **Fenêtre 90 j arbitraire** : peut être trop courte pour des parcours cancer (cycles de 21 j × 6 = 126 j) ou trop longue pour des post-chirurgicaux aigus (30 j suffisent). Définir la fenêtre par cohorte.
- **Modalités hétérogènes en intensité** : un séjour MCO de 15 j compte autant qu'un passage HDJ de 4 h. DEM90 ne pondère pas, c'est un nombre de modalités distinctes. Utiliser un DEM90_pondéré pour nuancer.
- **Patients perdus de vue** : un patient déménageant hors région verra son DEM90 artificiellement bas. Documenter le taux de chaînage complet sur 90 j.
- **Casemix très variable** : comparaison inter-établissement nécessite un ajustement multi-niveaux sur la cohorte cible (âge, sévérité, comorbidités, précarité — voir DAS Z55-Z65).
- **Volumes minimaux** : sous 100 patients d'index, instabilité majeure ; agréger plusieurs trimestres pour les pathologies à faible volume.
- **Fragmentation des soins** (Snow 2017 — care fragmentation, PMID 28851313) : la diversité de modalités sans coordination peut elle-même générer des erreurs ; DEM90 ne mesure pas la coordination réelle entre acteurs.

## Références

D'après PubMed :

- [Charles L et al. — Characteristics of Patients Receiving Complex Case Management, Prof Case Manag 2024](https://doi.org/10.1097/NCM.0000000000000742) — caractérisation des high utilizers et impact case management sur LOS et orientation domicile. PMID 39058563
- [Roubille F et al. — PRADOC, J Am Heart Assoc 2024](https://doi.org/10.1161/JAHA.123.032931) — parcours IC structuré multimodal en France. PMID 39023055
- [Cheng SA et al. — Remote Vital Signs Monitoring HAH/Postacute, J Med Internet Res 2025](https://doi.org/10.2196/64753) — modalités d'aval HAH + TLM. PMID 40418800
- [Miró Ò et al. — Very early ED return EDEN-26, Maturitas 2026](https://doi.org/10.1016/j.maturitas.2026.108853) — composante urgences à 72 h, à intégrer comme signal négatif. PMID 41616671

Sources officielles vérifiées dans la session :

- [HAS — Indicateurs de qualité des parcours de soins (cadre)](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)
- [HAS — Indicateurs parcours BPCO SNDS / PMSI](https://www.has-sante.fr/jcms/p_3326301/fr/outils-pour-calculer-les-indicateurs-du-parcours-bpco-a-partir-du-snds-dcir/pmsi)
- [ATIH — EMOIS 2023 chaînage parcours](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf)
- [DGOS — Stratégie 2025-2027 (parcours intégrés)](https://www.gpm.fr/strategie-dgos-2025-2027/)
- [ScanSanté — Territoires et parcours](https://www.scansante.fr/applications/territoires-et-parcours-soins)
