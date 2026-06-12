# Taux de Bascule HAD Précoce Post-MCO

## Définition

Le **taux de bascule HAD précoce post-MCO** mesure la part des séjours MCO suivis d'une prise en charge en **Hospitalisation à Domicile** débutant dans les **48 heures** après la sortie du séjour aigu. Il quantifie l'intensité du **virage HAD post-aigu** porté par la stratégie DGOS 2025-2027 (Pacte d'accès aux soins) et le projet stratégique « L'offre de soins de demain ».

À la différence du taux global de recours à l'HAD (qui agrège HAD post-MCO, HAD post-ville, HAD préventive obstétricale), cet indicateur isole la **substitution directe d'une fin de séjour aigu** par une prise en charge HAD — c'est-à-dire le cas d'usage où l'HAD remplace effectivement des journées d'hospitalisation complète. La fenêtre de **48 h** est cohérente avec la définition d'un « passage de relais sans rupture » utilisée par la littérature hospital-at-home (Cheng 2025, [DOI](https://doi.org/10.2196/64753)) et la circulaire HAD française qui caractérise l'« HAD post-hospitalière ».

**Formule :**

**BHAD48 = N_séjours_MCO_avec_admission_HAD≤48h / N_séjours_MCO_éligibles_HAD**

avec
- séjour index MCO : RSA MCO, sortie domicile ou transfert formel vers HAD (`SOR_MOD` mutation/transfert vers HAD)
- admission HAD ≤ 48 h : premier RPSA HAD du même patient avec date de prise en charge ≤ date de sortie + 2 jours calendaires
- séjour éligible HAD : appartenance à une liste de **racines GHM cibles HAD** (cancer en cours de traitement, soins palliatifs, post-chirurgie lourde, IC décompensée stabilisée, plaies complexes, périnatalité, antibiothérapie IV prolongée) — voir guide HAD ATIH

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `delai_admission_ssr_post_mco.md` — mesure le délai vers le SSR, pas l'HAD
- `constante_cinetique_transfert_mco_ssr.md` — cinétique de transfert SSR, pas HAD
- `taux_retour_domicile_sortie_ssr.md` — sortie SSR vers domicile, pas MCO→HAD
- `taux_suivi_ambulatoire_post_hospitalier.md` — suivi en ville, pas en HAD

Aucun indicateur n'évalue spécifiquement le **passage de relais MCO→HAD à 48 h**, alors que l'HAD est l'instrument central de la stratégie DGOS pour désengorger les lits MCO et que le décret n° 2022-1206 et l'instruction DGOS/R4/2023 fixent le développement HAD comme axe ARS. Cet indicateur est complémentaire de `delai_transfert_mco_ssr.md` (transferts post-aigu rééducatifs) mais cible le segment domiciliaire médico-technique.

## Calcul

### 1. Périmètre

```
Inclusion (séjour index MCO) :
  - RSA MCO complet, durée ≥ 1 jour (exclusion HDJ pures)
  - Adulte ou périnatalité (sous-cohortes séparées)
  - Sortie vivante (SOR_MOD ≠ 9)
  - GHM appartenant à la liste de racines éligibles HAD (référentiel
    « modes de prise en charge HAD » MPP/MPA — guide PMSI HAD ATIH 2025)

Exclusion :
  - Sortie vers SSR / USLD / EHPAD (`destination` en clair non-domicile, hors HAD)
  - Transferts intra-MCO ou mutations vers un autre établissement MCO
  - Séjours de moins de 24 h hors urgence
  - Séjours obstétricaux d'accouchement sans complication (sous-cohorte HAD
    péri-natalité distincte)
```

### 2. Chaînage RSA MCO ↔ RPSA HAD

```
1. Récupérer l'identifiant chaîné du fichier ANO (NIR haché, sexe, date
   naissance) pour le séjour MCO et pour les séquences HAD.
2. Pour chaque séjour index s :
     date_sortie_MCO_s = DATE_ENTREE_s + DUREE_SEJOUR_s
     Identifier la première séquence HAD h du même patient telle que :
        DATE_DEBUT_HAD_h >= date_sortie_MCO_s - 0 jour
        DATE_DEBUT_HAD_h <= date_sortie_MCO_s + 2 jours
     Si trouvée : BHAD48(s) = 1, sinon BHAD48(s) = 0.
3. Indicateur agrégé :
     BHAD48 = Σ_s BHAD48(s) / Σ_s 1{séjour éligible}
```

### 3. Sous-indicateurs utiles

Stratifier par :
- **Racine GHM index** (cancérologie, chirurgie digestive, IC, soins palliatifs)
- **Mode de prise en charge HAD** (MPP/MPA : soins palliatifs `MP_04`, pansements complexes `MP_09`, chimio `MP_05`, etc. — codes à confirmer sur le format RPSA HAD en vigueur [à confirmer guide PMSI HAD 2025])
- **Établissement HAD destinataire** : HAD du GHT vs HAD hors GHT — mesure de la **fidélisation territoriale HAD**
- **Délai en heures** (0–24 h, 24–48 h) pour distinguer le transfert direct du relais J+1/J+2
- **Durée du séjour HAD** : médiane par MPP, permet de qualifier la « profondeur » du relais

### 4. Indicateur dérivé : taux de couverture HAD du potentiel

```
TPHAD = N_séjours_MCO_avec_admission_HAD≤48h / N_séjours_MCO_potentiellement_éligibles_modèle
```
où le dénominateur est estimé par un modèle prédictif (logistique ou XGBoost) entraîné sur l'historique des cas effectivement basculés, prédisant la probabilité d'éligibilité HAD à partir des variables casemix (GHM, sévérité, DAS, âge, ALD, score Charlson). Permet la comparaison inter-sites à casemix égal.

## Utilité

- **Pilotage du virage HAD au niveau GHT** : indicateur cible des projets médicaux partagés (PMP) GHT et du contrat d'objectifs ARS, mesurable trimestriellement et opposable.
- **Identification des unités MCO sous-utilisatrices de l'HAD** : la stratification par UM permet de cibler des actions de formation / d'IDE de coordination sur les services à fort potentiel et faible BHAD48.
- **Évaluation des sas HAD intra-hospitaliers** : un GHT mettant en place une cellule de bascule HAD (IDE coordinatrice présente en MCO) peut mesurer un avant/après sur BHAD48 sur les racines cibles.
- **Anticipation capacitaire** : un BHAD48 croissant sur les soins palliatifs et la cancérologie libère des journées MCO valorisables ailleurs (chirurgie programmée).
- **Désengorgement urgences-aval** : BHAD48 élevé sur médecine polyvalente gériatrique signale une bonne fluidité d'aval, complémentaire de `taux_passage_urgences_hospitalisation.md`.
- **Suivi du déploiement post-opioïdes / RAAC chirurgie lourde** : HAD précoce comme relais antalgique multimodal (Al-Awadhi 2026, [DOI](https://doi.org/10.7759/cureus.101209)), à coupler avec `indice_sequentialisation_raac.md`.
- **Évaluation des programmes hospital-at-home avec télésurveillance** : Cheng 2025 ([DOI](https://doi.org/10.2196/64753)) montre une réduction de mortalité 30 j (RR 0,65) en HAH post-aigu instrumenté ; BHAD48 est l'indicateur d'amont permettant d'évaluer la pénétration du dispositif.

## Sources de Données

Variables PMSI confirmées dans la session ATIH 2025 :

- **RSA / RSS MCO** :
  - `DATE_ENTREE`, `duree` → date de sortie calculée
  - `SOR_MOD` (mode de sortie), `destination` (destination), notamment mutation/transfert vers HAD
  - `GHM`, niveau de sévérité, `DP`, `DAS`, `age`, `SEXE`, `FINESSGEO`
- **RPSA HAD** (résumé par sous-séquence HAD) :
  - `DATE_DEBUT_SEQUENCE` (date de prise en charge HAD) [à confirmer libellé exact format RPSA 2025]
  - `mpp` (mode de prise en charge principal) et `mpa` (mode de prise en charge associé) — table `fixe` HAD
  - `FINESS_HAD`, durée de séquence
- **Fichier ANO PMSI** : chaînage inter-champs (MCO ↔ HAD ↔ SSR) par NIR haché + sexe + date de naissance — [ATIH EMOIS 2023 « Utiliser le PMSI pour analyser les parcours de soins »](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf)
- **Référentiels** :
  - [Notice technique ATIH PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf) — formats et règles
  - [Notice technique ATIH 2026 (nouveautés)](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
  - Guide méthodologique PMSI HAD en vigueur (liste MPP/MPA et règles de production RPSA)
  - [DGOS — Stratégie 2025-2027](https://www.gpm.fr/strategie-dgos-2025-2027/) — cible HAD nationale
- **ScanSanté — Territoires et parcours** : [scansante.fr/applications/territoires-et-parcours-soins](https://www.scansante.fr/applications/territoires-et-parcours-soins) — exposition publique des flux MCO↔HAD pour benchmarking
- **Périmètre élargi SNDS** : nécessaire pour capter les patients basculés vers une HAD hors périmètre PMSI déclaré du GHT.

## Exemple de Valeurs

Ordres de grandeur experts, en l'absence de restitution publique ScanSanté équivalente. À recalibrer après bilan ScanSanté HAD 2025.

- **Toutes racines GHM éligibles confondues, CHU** : BHAD48 ≈ 4–8 %.
- **CH général sans HAD intégrée mais conventionnée GHT** : 2–5 %.
- **Soins palliatifs (DP Z51.5 ou MPP palliatif)** : 18–30 %, marqueur central de structuration de la filière palliative.
- **Cancérologie en cours de traitement (chimio Z51.1, suites cures lourdes)** : 6–12 %.
- **Plaies chroniques / pansements complexes post-chirurgie** : 8–15 %.
- **Post-chirurgie digestive lourde sous protocole RAAC** : 3–6 %, sensible à l'organisation locale.
- **Périnatalité (HAD post-couches)** : 12–20 % selon présence du PRADO-MAT.
- **Seuil d'alerte pilotage** : BHAD48 < moyenne nationale ScanSanté - 1σ sur ≥ 4 trimestres → audit des sorties MCO et des freins HAD (médecin coordonnateur, transports, environnement).

## Limites

- **Définition des « racines éligibles HAD »** sensible : la liste MPP/MPA évolue par notice ATIH ; l'indicateur doit être recalculé à liste figée pour comparabilité inter-années. Documenter la version utilisée.
- **HAD hors PMSI déclaré du GHT** : si le patient bascule vers une HAD privée hors PMSI partagé, sous-estimation. Le chaînage SNDS résout partiellement.
- **Fenêtre 48 h** : un transfert HAD à J+3 (par exemple en attendant un consilium) reste qualitativement positif mais sera classé comme non-bascule précoce. Présenter en parallèle un BHAD7 (fenêtre 7 jours) pour comparaison.
- **Casemix entrant** : un site avec une forte chirurgie ambulatoire ou un mix gériatrique très lourd a un potentiel HAD structurellement différent. L'ajustement sur GHM/sévérité est obligatoire ; le sous-indicateur dérivé `TPHAD` (taux de couverture du potentiel) gère cette hétérogénéité.
- **Effet offre** : un GHT sans HAD interne ou sans convention avec un opérateur HAD voisin a un BHAD48 faible par absence d'offre, pas par défaut de pratique. Toujours croiser avec la cartographie HAD ARS.
- **Substitution vs ajout** : un BHAD48 élevé peut traduire un raccourcissement vrai des séjours MCO (substitution) ou un simple ajout d'HAD après séjour MCO de durée inchangée. Suivre en parallèle la DMS des GHM concernés pour qualifier l'effet.
- **Effet PRADO** : selon les résultats PRADOC 2024 (Roubille et al., [DOI](https://doi.org/10.1161/JAHA.123.032931)), un programme transitionnel administratif type PRADO-IC seul n'a pas démontré de bénéfice clinique sur l'IC ; une bascule HAD plus médicalisée (avec télésurveillance) est requise pour transformer l'indicateur en effet clinique mesurable.
- **Volumes minimaux** : sous 100 séjours éligibles annuels par UM, l'indicateur a une variance trop élevée — agréger au niveau pôle ou GHT.

## Références

D'après PubMed :

- [Cheng SA et al. — Value of Remote Vital Signs Monitoring in HAH or Postacute Patients : Systematic Review, J Med Internet Res 2025](https://doi.org/10.2196/64753) — efficacité du couplage HAH + télésurveillance, mortalité 30 j RR 0,65. PMID 40418800
- [Roubille F et al. — PRADOC : Pragmatic Transition Care Management Plan for Heart Failure in France, J Am Heart Assoc 2024](https://doi.org/10.1161/JAHA.123.032931) — évaluation française du PRADO-IC, base pour la définition du « relais sans rupture ». PMID 39023055
- [Charles L et al. — Characteristics of Patients Receiving Complex Case Management in an Acute Care Hospital, Prof Case Manag 2024](https://doi.org/10.1097/NCM.0000000000000742) — LACE et discharge planning. PMID 39058563
- [Miró Ò et al. — Very early return of older persons to the ED (EDEN-26), Maturitas 2026](https://doi.org/10.1016/j.maturitas.2026.108853) — fragilité de la sortie chez le sujet âgé, contexte de la fenêtre 48-72 h. PMID 41616671

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Notice technique nouveautés PMSI 2026](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
- [ATIH — EMOIS 2023 — Utiliser le PMSI pour analyser les parcours de soins](https://www.atih.sante.fr/sites/default/files/public/content/4512/emois_2023_utiliser_le_pmsi_pour_analyser_les_parcours_de_soins.pdf)
- [DGOS — Stratégie 2025-2027 « L'offre de soins de demain »](https://www.gpm.fr/strategie-dgos-2025-2027/)
- [ScanSanté — Territoires et parcours de soins](https://www.scansante.fr/applications/territoires-et-parcours-soins)
