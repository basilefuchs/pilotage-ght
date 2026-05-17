# Indice de Séquentialisation RAAC

## Définition

L'**indice de séquentialisation RAAC** mesure le degré d'alignement de la durée moyenne de séjour (DMS) observée d'un établissement sur une **cible RAAC** (Récupération Améliorée Après Chirurgie, équivalent ERAS), pour une liste fermée de **racines GHM chirurgicales éligibles** (colectomie, prothèse de hanche/genou, hystérectomie, cystectomie, gastrectomie, pancréatectomie, hépatectomie, prostatectomie radicale, sleeve, etc.).

La littérature ERAS récente (Feng 2026 [DOI](https://doi.org/10.1007/s13304-026-02634-6) ; Al-Awadhi 2026 [DOI](https://doi.org/10.7759/cureus.101209)) confirme qu'une adhérence ERAS ≥ 70 % réduit la DMS d'environ 2 jours et le taux de complications majeures sans surcroît de réadmission. La DMS est donc un **proxy populationnel d'adhérence RAAC** mesurable directement à partir du PMSI MCO, sans questionnaire ni audit dossier-à-dossier.

**Formule :**

Pour chaque racine GHM cible r :

**ISR_r = max(0, 1 − (DMS_obs_r − DMS_cible_r) / DMS_cible_r) borné dans [0, 1]**

Indice agrégé :

**ISR = Σ_r (n_r × ISR_r) / Σ_r n_r**

où :
- DMS_obs_r : DMS observée sur la racine r dans l'établissement
- DMS_cible_r : DMS de référence RAAC (consensus GRACE / SFAR / sociétés savantes par racine ; à défaut, percentile 25 national ScanSanté)
- n_r : volume de séjours sur la racine r

Un score ISR = 1 signifie « DMS observée ≤ cible RAAC » ; ISR = 0 signifie « DMS observée ≥ 2 × cible ». L'indice est borné pour limiter l'effet des outliers très longs.

## Positionnement vs indicateurs existants

Le projet contient :
- `taux_compression_algorithmique_parcours.md` — compression informationnelle, pas spécifique RAAC
- `taux_parcours_optimises.md` / `taux_conformite_parcours.md` — conformité à un parcours générique
- `indice_complexite_parcours_multi_rum.md` — complexité multi-RUM
- `delai_admission_ssr_post_mco.md` — délai d'aval

Aucun indicateur ne mesure spécifiquement l'**adoption de la RAAC** au sein du GHT pour la chirurgie programmée. L'indice ISR fournit un score unique, comparable, agrégeable et inscriptible dans un CPOM.

## Calcul

### 1. Liste des racines cibles

```
RAAC_RACINES (à figer annuellement par décision DIM/CME) :
  Chirurgie digestive :
    06C04, 06C05, 06C06, 06C07, 06C08 (colectomies / résections grêle)
    07C02, 07C03 (pancréatectomies, hépatectomies)
    08C09 (cystectomies — CMD 11 selon nomenclature)
  Orthopédie :
    08C24, 08C48 (PTH / PTG)
  Gynéco / uro :
    13C03 (hystérectomies)
    12C03, 12C04 (prostatectomie radicale)
  Obésité :
    10C13, 10C14 (sleeve, bypass)
  [Liste à confirmer annuellement avec la classification V2026 ATIH ; ne
   pas inventer de racines sans vérification]
```

### 2. Définition des cibles RAAC par racine

Trois conventions possibles, à choisir explicitement :

```
Convention A — Cible consensus sociétés savantes :
  DMS_cible_r = DMS de référence publiée par GRACE / SFAR / ESPEN.
  Avantage : aligné protocole. Inconvénient : cibles non disponibles
  pour toutes les racines.

Convention B — Percentile 25 national (ScanSanté MCO) :
  DMS_cible_r = P25 national de DMS sur la racine r, année t-1.
  Avantage : universel. Inconvénient : cible mobile, intègre des
  pratiques non RAAC.

Convention C — Top quartile établissements RAAC labellisés :
  DMS_cible_r = DMS médiane des établissements labellisés RAAC sur r.
  Avantage : opérationnel. Inconvénient : nécessite référentiel de
  labellisation tenu à jour.
```

### 3. Calcul ISR_r par racine et établissement

```
1. Pour chaque RSA MCO de l'établissement :
     filtrer GHM dont la racine appartient à RAAC_RACINES
     exclure : décès (SOR_MOD = 9), durée < 0, séjours en court extrême
     (très courte durée ambulatoire « en J » — déjà capturés par autre
     indicateur), CMA / complications sévères majeures (sévérité 3-4)
2. DMS_obs_r = mean(DUREE_SEJOUR) sur les RSA filtrés
3. ISR_r = max(0, 1 − (DMS_obs_r − DMS_cible_r) / DMS_cible_r)
4. ISR = Σ_r n_r × ISR_r / Σ_r n_r
```

### 4. Ajustement risque

```
Modèle linéaire mixte :
  DUREE_SEJOUR ~ racine_GHM + sévérité + age + sexe + ALD +
                 score_Charlson + (1 | FINESSGEO)
DMS_ajustée_r par établissement = effet aléatoire + DMS racine moyenne
ISR_ajusté calculé sur DMS_ajustée plutôt que DMS_obs brute.
```

### 5. Sous-indicateurs utiles

- **ISR_orthopédie** vs **ISR_digestif** vs **ISR_gynéco** : par grande filière, identifie les blocs déjà RAAC vs ceux à investir.
- **ISR_séjour_programmé** (mode d'entrée = 8 domicile, ALD planifiée) — la RAAC ne s'applique qu'au programmé, séjours en urgence à exclure.
- **ISR_couplé_taux_complications** : ISR seul ne dit rien sur la sécurité ; à lire en parallèle de PSI-90 et taux de reprise précoce (Feng 2026 : adhérence ≥ 70 % réduit complications de 16,7 % vs 29,3 %).
- **ISR_couplé_BHAD48** : RAAC + HAD précoce = doctrine de virage ambulatoire renforcé.

## Utilité

- **Tableau de bord chirurgie programmée GHT** : score unique, agrégeable par pôle / établissement / filière, inscriptible CPOM.
- **Identification des racines à fort potentiel** : un ISR_orthopédie élevé et un ISR_digestif faible orientent l'effort d'animation RAAC vers le digestif.
- **Évaluation d'un déploiement protocolaire** : suivi temporel ISR avant/après mise en place d'un protocole RAAC formalisé ou d'une cellule de coordination chirurgie-anesthésie.
- **Comparaison inter-établissements GHT à casemix ajusté** : ISR_ajusté gère le biais de complexité.
- **Détection des effets pervers** : ISR très élevé associé à un taux de réadmission 30 j ou retour aux urgences 7 j en hausse → indication de sortie prématurée, à investiguer (Al-Awadhi 2026 souligne l'importance de l'analgésie multimodale pour sécuriser le raccourcissement).
- **Pilotage capacitaire** : 1 jour de DMS gagné par racine × volume = lits libérés calculables — argumentaire pour fermeture/redéploiement de capacités.
- **Indicateur d'amont du virage ambulatoire** : ISR croissant prépare la conversion progressive de racines actuellement « en non-J » vers des racines « en J » (cf. `taux_substitution_hdj_hospi_complete.md`).

## Sources de Données

- **PMSI MCO — RSA complet** :
  - `GHM` (racine extractible : caractères 1-5)
  - `DUREE_SEJOUR`
  - `SOR_MOD`, `SOR_DEST`
  - `AGE_AN`, `SEXE`, sévérité (4ᵉ caractère du GHM), `DP`, `DAS`, `ALD`
  - `MODE_ENTREE` (8 = domicile = programmé)
  - `FINESSGEO`, `FINESSJUR`
- **Référentiels** :
  - Manuel des GHM V2026 (à confirmer version en vigueur, [ATIH Notice technique 2026](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0))
  - [ATIH — Notice technique PMSI 2025](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
  - DMS de référence ScanSanté par racine GHM (P25, médiane, P75 nationaux)
  - Référentiels RAAC GRACE (Groupe francophone de Réhabilitation Améliorée après ChirurgiE) / SFAR
- **ScanSanté — Restitution MCO** pour les DMS nationales par racine GHM (P25 utilisé en convention B).
- **Croisement recommandé** : table des établissements labellisés RAAC (référentiel GRACE) pour convention C.

## Exemple de Valeurs

Ordres de grandeur experts (calibrés sur valeurs publiques ScanSanté et littérature ERAS).

- **PTH primaire programmée (racine 08C24)** :
  - DMS_cible RAAC (consensus) ≈ 3-4 jours ; DMS médiane nationale ≈ 5-6 j.
  - ISR_obs établissement RAAC mature : 0,85-1,0 ; CH non-RAAC : 0,50-0,70.
- **PTG primaire programmée (racine 08C48)** :
  - DMS_cible ≈ 3-4 j ; DMS médiane nationale 5-7 j.
  - Idem.
- **Colectomie programmée (06C0x)** :
  - DMS_cible RAAC ≈ 5-6 j (Feng 2026 reporte 8,2 ± 2,6 j en haut compliance vs 10,1 ± 3,1 j en bas compliance) ; DMS médiane FR ≈ 8-10 j.
  - ISR CHU spécialisé RAAC : 0,75-0,90 ; CH périphérique : 0,40-0,65.
- **Sleeve gastrique (10C14)** :
  - DMS_cible ≈ 2 j ; DMS médiane FR ≈ 3 j.
  - ISR élevé général (0,80+) car la racine est de facto RAAC-isée.
- **Hystérectomie pour pathologie bénigne (13C03)** :
  - DMS_cible ≈ 2-3 j ; nationale ≈ 4-5 j. ISR moyen 0,60-0,80.
- **ISR global établissement** : 0,55 (CH non engagé RAAC) à 0,90 (CHU labellisé GRACE multi-racines).
- **Seuil d'alerte de pilotage** : ISR_r < 0,5 sur ≥ 2 années consécutives sur racine à volume ≥ 100 séjours/an → diagnostic protocolaire RAAC.

## Limites

- **DMS = proxy d'adhérence, pas une mesure directe** : un séjour court peut être obtenu sans RAAC (sortie précoce non sécurisée) ; un séjour RAAC bien conduit peut être long du fait d'une complication. Toujours coupler ISR à des indicateurs de sécurité (PSI-90, réadmission 30 j, retour urgences 7 j).
- **Sensibilité à la définition de la cible** : trois conventions A/B/C donnent des ISR différents ; la convention doit être fixée et constante d'une année à l'autre. Toute comparaison inter-établissement nécessite la même convention.
- **Sélection de patients** : un établissement peut améliorer son ISR en sélectionnant les patients les plus simples (cherry-picking) ; obligation d'ajustement casemix et déclaration du taux d'exclusion.
- **Sévérité GHM** : les niveaux 3 et 4 sont à exclure (complications majeures incompatibles avec RAAC standard) — règle à figer.
- **Effet weekend / fermeture bloc** : les sorties prévues le vendredi peuvent être reportées au lundi, gonflant la DMS sans rapport avec l'adhérence RAAC. Sous-analyse par jour de sortie utile.
- **Racines hétérogènes** : certaines racines GHM regroupent des actes très divers (par exemple colectomies droite vs sigmoïdectomie laparoscopique vs cancer rectal) — affiner par acte CCAM principal pour une comparaison plus fine.
- **Évolution de classification** : la version GHM change (V2025 → V2026) ; les racines peuvent être redéfinies, rendant la comparaison inter-années risquée. Documenter la version utilisée.
- **Pas d'adhérence individuelle** : un audit dossier-à-dossier reste nécessaire pour comprendre les écarts ; l'ISR est un indicateur de pilotage, pas un outil d'amélioration de pratique.
- **Volumes minimaux** : ISR_r non interprétable sous 30 séjours/an/racine ; cumuler sur 2 ans ou agréger plusieurs racines voisines.

## Références

D'après PubMed :

- [Feng L et al. — Compliance with an enhanced recovery pathway and postoperative outcomes in elderly colorectal cancer patients, Updates Surg 2026](https://doi.org/10.1007/s13304-026-02634-6) — adhérence ERAS ≥ 70 % réduit DMS de 1,9 j et complications majeures ; SEM montre effet direct sur LOS et indirect sur réadmission. PMID 42053955
- [Al-Awadhi AA et al. — Navigating the Post-opioid Era : Non-opioid Perioperative Analgesics, Cureus 2026](https://doi.org/10.7759/cureus.101209) — composante analgésique multimodale au cœur des protocoles ERAS modernes. PMID 41669605

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Notice technique 2026 nouveautés](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
- [ATIH — Manuel des GHM, présentation générale](https://www.atih.sante.fr/sites/default/files/public/content/1857/Presentation_generale_1.pdf)
- [ScanSanté — Restitutions MCO](https://www.scansante.fr/) — DMS nationales par racine GHM

Référentiels professionnels (non re-vérifiés en session, à confirmer avant publication officielle) :
- GRACE — Groupe francophone de Réhabilitation Améliorée après Chirurgie : référentiels par spécialité.
- SFAR — Société Française d'Anesthésie et Réanimation : RFE RAAC.
