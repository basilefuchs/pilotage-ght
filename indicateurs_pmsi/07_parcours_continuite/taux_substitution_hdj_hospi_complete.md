# Taux de Substitution HDJ vs Hospitalisation Complète

## Définition

Le **taux de substitution HDJ vs hospitalisation complète** mesure, sur une liste figée de **couples de racines GHM substituables** (1 racine « en J » = ambulatoire 0 nuitée, 1 racine « en non-J » équivalente en hospitalisation conventionnelle), la part des séjours réalisés en **hospitalisation de jour** parmi le total des séjours du couple. Il étend le classique taux de chirurgie ambulatoire à l'ensemble des prises en charge médicales et interventionnelles substituables.

Les GHM « en J » regroupent exclusivement des séjours de 0 nuitée réalisés dans une autorisation de prise en charge ambulatoire ; ils ne sont ni interchangeables ni groupables avec les GHM « en T » (très courte durée) ([blog lespmsi.com — GHM en J](https://www.lespmsi.com/lire-et-interpreter-le-code-dun-ghm/)). L'indicateur s'inscrit dans la trajectoire « virage ambulatoire » portée par la DGOS depuis le programme national de gestion du risque (GdR) chirurgie ambulatoire ([ScanSanté GdR chirurgie ambulatoire — notice juin 2015](https://www.scansante.fr/sites/default/files/content/25/notice_gdr_chirurgie_ambulatoire_juin2015.pdf)) et la stratégie 2025-2027 ([gpm.fr/strategie-dgos-2025-2027](https://www.gpm.fr/strategie-dgos-2025-2027/)).

**Formule :**

Pour chaque couple substituable c = (racine_J, racine_non_J) :

**TSC_c = N_séjours_racine_J / (N_séjours_racine_J + N_séjours_racine_non_J_éligibles)**

Indicateur agrégé :

**TSC = Σ_c (n_c × TSC_c) / Σ_c n_c**

avec n_c = volume du couple, et **racine_non_J_éligibles** = sous-ensemble des séjours non-J du couple qui répondent aux critères d'éligibilité ambulatoire (sévérité 1, absence de comorbidité disqualifiante, conditions sociales et géographiques permettant la sortie le jour même).

## Positionnement vs indicateurs existants

Le projet contient :
- `indicateurs_pmsi/01_activite_production/` — production / volumes, pas substitution
- `taux_parcours_optimises.md` — optimisation générale
- `indice_sequentialisation_raac.md` (ce dossier) — DMS sur hospitalisation complète RAAC

Aucun indicateur ne mesure spécifiquement le **virage ambulatoire étendu**. L'indicateur classique « taux de chirurgie ambulatoire » publié par ScanSanté est limité à la chirurgie ; TSC l'étend aux racines médicales et interventionnelles (oncologie HDJ, néphrologie, gastro-entérologie, allergologie, rhumato-bilan, hôpital de jour gériatrique, etc.).

## Calcul

### 1. Définition de la liste de couples substituables

```
Étape critique — à figer par décision DIM/CME, version PMSI documentée.

Sources de référence pour construire COUPLES_SUB :
  - Manuel ATIH des GHM (version en vigueur) : repérer les racines « en J »
    et associer la racine non-J correspondante
  - Listes GdR chirurgie ambulatoire ScanSanté (5 gestes marqueurs
    historiques + extensions)
  - Référentiels HAS / sociétés savantes (gastro, cardio interventionnelle,
    onco, etc.)

Exemple de structure (illustratif, à valider sur classification V2026) :
COUPLES_SUB = {
  ('06K02J', '06K02x_non_J'),  # endoscopies digestives
  ('09Z02J', '09Z02x_non_J'),  # gestes ORL ambu
  ('05K10J', '05K10x_non_J'),  # cardio interventionnelle ambu
  ('11K02J', '11K02x_non_J'),  # dialyse en HDJ
  ...
}
```

### 2. Calcul TSC_c

```
1. Pour chaque couple c = (racine_J, racine_non_J) :
     N_J = count(RSA avec racine_GHM = racine_J)
     N_NJ_total = count(RSA avec racine_GHM = racine_non_J, durée ≥ 1 j)
     Filtre éligibilité ambulatoire sur N_NJ_total :
        sévérité = 1
        absence DAS disqualifiant (insuffisance cardiaque sévère,
        insuffisance respiratoire sous O2, démence)
        mode_entrée = 8 (domicile, programmé)
        durée_séjour ≤ 3 jours (proxy de la « substituabilité »)
     N_NJ_elig = count après filtre
     TSC_c = N_J / (N_J + N_NJ_elig)
2. TSC = Σ_c n_c × TSC_c / Σ_c n_c
```

### 3. Ajustement de risque

```
Modèle logistique :
  ambulatoire_J ~ couple + age + sexe + ALD + score_Charlson + précarité +
                  distance_domicile + (1 | FINESSGEO)
Production d'un TSC standardisé (O/E) par établissement permettant la
comparaison inter-sites à casemix et conditions sociales ajustés.
```

### 4. Sous-indicateurs

- **TSC_chirurgie** : sous-cohorte chirurgicale stricte — comparable au taux ScanSanté « chirurgie ambulatoire ».
- **TSC_médecine** : sous-cohorte médecine + interventionnel non-chirurgical (innovation du présent indicateur).
- **TSC_par_couple** : score par geste / racine pour identifier les gestes en retard.
- **Indicateur dérivé d'effet revenus** : combiné à la valorisation T2A J vs non-J, permet de chiffrer le gain (ou la perte) tarifaire de la substitution réalisée.

## Utilité

- **Pilotage du virage ambulatoire étendu** : tableau de bord opposable inscrit en CPOM, comparable à l'indicateur ScanSanté chirurgie ambulatoire mais élargi à la médecine.
- **Identification des gestes en retard** : couple par couple, ciblage des actions (organisation du bloc, parcours d'admission, programmation, RDV anesthésie).
- **Comparaison inter-établissements GHT** : TSC ajusté permet de comparer un CH périphérique à un CHU à casemix égal.
- **Impact capacitaire et économique** : 1 séjour passé de non-J à J libère typiquement 1-2 nuits MCO, valorisables ailleurs. Modélisation lits-équivalents directe.
- **Articulation avec ISR RAAC** : la RAAC raccourcit les séjours non-J ; TSC mesure la bascule complète en HDJ. Une racine à ISR élevé est candidate à devenir un couple substituable et à migrer vers TSC.
- **Suivi des restitutions ScanSanté « Territoires et parcours »** : nouvel applicatif ATIH ([scansante.fr/territoires-et-parcours-soins](https://www.scansante.fr/applications/territoires-et-parcours-soins)) expose des flux qui rendent TSC interprétable au niveau territorial.
- **Détection de cherry-picking ou de transfert d'activité** : un TSC très élevé non corrélé à la qualité (taux de retour urgences 7 j en hausse) signale une bascule mal accompagnée — alerte qualité.
- **Préparation des plans capacitaires GHT** : TSC croissant sur ≥ 3 ans est un signal solide pour reconvertir des lits MCO en places HDJ ou en HAD.

## Sources de Données

- **PMSI MCO** : RSA, racine GHM (5 caractères), niveau de sévérité (4ᵉ caractère), nature de séjour (`J` vs autre), `duree`, `modeentree`, `destination`, `DP`, `DAS`, `age`, `FINESSGEO`
- **Référentiels classification** :
  - [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
  - [ATIH — Notice technique 2026](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
  - [ATIH — Manuel des GHM — présentation générale](https://www.atih.sante.fr/sites/default/files/public/content/1857/Presentation_generale_1.pdf)
  - [Annexe ATIH V11 (historique GHM en J)](https://www.atih.sante.fr/sites/default/files/public/content/2210/annexes_notice_technique_mco_jan_2009.pdf) — référence historique
- **ScanSanté** :
  - [ScanSanté — Restitution chirurgie ambulatoire / GdR](https://www.scansante.fr/sites/default/files/content/25/notice_gdr_chirurgie_ambulatoire_juin2015.pdf)
  - [ScanSanté — Territoires et parcours](https://www.scansante.fr/applications/territoires-et-parcours-soins)
- **Source réglementaire stratégique** : [DGOS — Stratégie 2025-2027 — virage ambulatoire et HAD](https://www.gpm.fr/strategie-dgos-2025-2027/)

## Exemple de Valeurs

Ordres de grandeur experts en partie calibrés sur les restitutions ScanSanté GdR chirurgie ambulatoire :

- **TSC_chirurgie ambulatoire (5 gestes marqueurs historiques GdR)** : 80-95 % en 2025-2026 dans les CHU matures ; 60-80 % en CH général.
- **TSC_chirurgie globale (tous gestes substituables)** : 55-72 % nationalement, cibles DGOS à 70 %+ à 3 ans.
- **TSC_endoscopie digestive** : 90-98 % (déjà très ambulatoire).
- **TSC_cardio interventionnelle (coro programmée)** : 25-50 % selon plateau et organisation, fort potentiel.
- **TSC_HDJ médecine onco (chimio)** : > 95 % (norme structurelle).
- **TSC_médecine gériatrique évaluation** : 40-65 % (HDJ gériatriques en montée).
- **TSC_global établissement** : 50-70 % selon profil ; CHU 60-72 %, CH 45-60 %.
- **Seuil d'alerte de pilotage** : TSC_c stagnant ≥ 2 ans sous la médiane nationale ScanSanté − 5 pts → audit organisation HDJ sur la racine concernée.

## Limites

- **Liste de couples substituables instable** : la classification GHM évolue annuellement ; la liste des couples doit être revue à chaque version (V2025 → V2026) sous peine de comparaisons faussées. Documenter strictement la version.
- **Définition de l'éligibilité ambulatoire** : le filtre « éligible non-J » est défini par des seuils (sévérité 1, durée ≤ 3 j, DAS exclusifs) qui sont des proxys, pas une décision médicale. Sous-estimation possible de la substituabilité réelle.
- **Hétérogénéité intra-racine** : une racine GHM regroupe des actes CCAM divers ; affiner par acte principal CCAM est nécessaire pour les couples complexes (ex. chirurgie digestive).
- **Cherry-picking** : un établissement peut artificiellement augmenter TSC en sélectionnant les patients les plus simples ; obligation d'ajustement casemix.
- **Effet offre / contraintes territoriales** : un CH sans plateau HDJ ad hoc ou un patient vivant à plus de 60 min de l'établissement a une éligibilité ambulatoire réduite indépendamment de la pratique. Intégrer une variable distance domicile / contexte social.
- **Tarification J vs non-J** : le passage en J peut être pénalisant tarifairement sur certaines racines, créant un frein économique non lié à la qualité ; suivre en parallèle l'arrêté tarifaire en vigueur ([ATIH — Tarifs MCO et HAD](https://www.atih.sante.fr/tarifs-mco-et-had)).
- **Sécurité / qualité** : un TSC élevé non corrélé à la qualité (retour urgences 7 j en hausse, taux réadmission en hausse) signale un transfert d'activité mal sécurisé. Lecture obligatoire en couplage avec `taux_retour_urgences_7j_post_sortie_mco.md`.
- **Confusion avec GHM « en T »** : ne pas confondre racines J (ambu autorisé, 0 nuitée) et T (très courte durée) — les groupes ne sont pas interchangeables ([clarification blog les PMSI](https://www.lespmsi.com/les-idees-fausses-concernant-les-ghm-en-t-tres-courte-duree/)).
- **Volumes minimaux** : sous 30 séjours/an/couple, indicateur instable ; cumuler sur 2 ans ou agréger plusieurs couples voisins.

## Références

D'après PubMed :

- [Feng L et al. — ERAS compliance and outcomes in elderly colorectal cancer, Updates Surg 2026](https://doi.org/10.1007/s13304-026-02634-6) — RAAC comme amont du virage ambulatoire. PMID 42053955
- [Cheng SA et al. — Remote Vital Signs Monitoring HAH/Postacute, J Med Internet Res 2025](https://doi.org/10.2196/64753) — modèle d'aval permettant la sécurisation des HDJ. PMID 40418800

(Pas de méta-analyse PubMed directement transposable sur le taux de substitution HDJ tous champs — littérature ScanSanté/ATIH dominante.)

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Notice technique 2026 nouveautés](https://www.atih.sante.fr/notice-technique-nouveautes-pmsi-mco-had-smr-psychiatrie-2026-0)
- [ATIH — Manuel des GHM (présentation générale)](https://www.atih.sante.fr/sites/default/files/public/content/1857/Presentation_generale_1.pdf)
- [ATIH — Annexe historique évolution classification GHM V11](https://www.atih.sante.fr/sites/default/files/public/content/2210/annexes_notice_technique_mco_jan_2009.pdf)
- [ATIH — Tarifs MCO et HAD](https://www.atih.sante.fr/tarifs-mco-et-had)
- [ScanSanté — GdR Chirurgie ambulatoire (notice juin 2015)](https://www.scansante.fr/sites/default/files/content/25/notice_gdr_chirurgie_ambulatoire_juin2015.pdf)
- [ScanSanté — Territoires et parcours](https://www.scansante.fr/applications/territoires-et-parcours-soins)
- [DGOS — Stratégie 2025-2027](https://www.gpm.fr/strategie-dgos-2025-2027/)
- [Lespmsi — Lire et interpréter un code GHM (rappel « en J »)](https://www.lespmsi.com/lire-et-interpreter-le-code-dun-ghm/)
- [Lespmsi — Idées fausses sur les GHM « en T »](https://www.lespmsi.com/les-idees-fausses-concernant-les-ghm-en-t-tres-courte-duree/)
