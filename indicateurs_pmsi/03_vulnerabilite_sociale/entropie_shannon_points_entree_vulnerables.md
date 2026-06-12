# Entropie de Shannon des Points d'Entrée chez les Patients Vulnérables

## Définition

L'**entropie de Shannon des points d'entrée chez les patients vulnérables** mesure la **diversité (ou homogénéité) des modes d'entrée** des séjours MCO d'une cohorte définie de patients vulnérables, par rapport à une cohorte de référence non vulnérable. Une entropie élevée traduit une diversification des canaux d'entrée à l'hôpital ; une entropie faible traduit une **dépendance** à un canal unique (typiquement les urgences), signal d'errance et de défaut d'accès organisé.

L'entropie de Shannon (Shannon 1948) appliquée à une distribution de probabilité finie p = (p_1, ..., p_K) sur K modes d'entrée distincts s'écrit :

**H(p) = − Σ_{k=1..K} p_k × log_2(p_k)**

avec convention 0 · log(0) = 0. H est borné dans [0, log_2(K)] : 0 si concentration totale sur un mode, log_2(K) si distribution uniforme.

**Partition des modes d'entrée PMSI MCO** (à figer par le DIM, illustrative) :

```
MODES_ENTREE = {
  M1 : domicile programmé           (`modeentree` = 8)
  M2 : urgences (UF d'urgences)     (`modeentree` = 8 et `provenance` = 5, passage UHCD via `top_uhcd`)
        — détectable par chaînage RPU-RSA ou par GHM 06Z02 / UF d'urgences
  M3 : transfert depuis autre établissement MCO (`modeentree` = 7)
  M4 : mutation interne (`modeentree` = 6)
  M5 : entrée depuis SSR/HAD/USLD (`modeentree` = 0 ou autre)
  [partition exacte à figer en utilisant les guides ATIH en vigueur ;
   les codes ci-dessus illustrent la logique]
}
```

**Formule appliquée :**

Pour chaque cohorte C (Q5 FDep, Q1 FDep, ALD-sans-MT, ICV≥3) :

**H_C = − Σ_k (p_k_C × log_2 p_k_C)**

avec p_k_C = proportion des séjours de la cohorte C entrant par le mode k.

**Indicateur dérivé d'écart :**

**ΔH = H_Q1 − H_Q5**

ΔH > 0 signifie que les Q1 (favorisés) ont une distribution plus diverse de modes d'entrée — donc des canaux d'accès plus organisés — tandis que les Q5 sont concentrés (urgences-dépendance).

## Positionnement vs indicateurs existants

Le projet contient :
- `coefficient_gini_consommation_hospitaliere.md` — concentration de consommation (Gini)
- `entropie_diffusion_innovation_parcours.md` (cat. 07) — entropie sur les parcours
- `ratio_surrecours_urgences_fdep_q5_q1.md` (ce dossier) — ratio uni-dimensionnel urgences

Aucun indicateur ne mesure la **diversité informationnelle des canaux d'accès** par cohorte sociale. L'entropie capte un signal différent du ratio simple : un patient pouvant entrer par 3 canaux distincts a un meilleur accès qu'un patient cantonné à un seul, indépendamment du volume total.

## Calcul

### 1. Construction des cohortes

```
Cohortes (mutuellement exclusives ou non) :
  C_Q5 : patients résidant en IRIS FDep Q5
  C_Q1 : patients résidant en IRIS FDep Q1
  C_ALD_sansMT : patients ALD sans médecin traitant 12m
  C_ICV3plus : patients avec ICV ≥ 3
  C_REF (témoin) : patients ICV = 0
```

### 2. Affectation du mode d'entrée

```
Pour chaque RSA s :
  MODE_s ∈ MODES_ENTREE (selon règles ATIH en vigueur et chaînage RPU)
  cohorte_s ∈ {C_Q5, C_Q1, ...}
```

### 3. Calcul des fréquences

```
Pour chaque cohorte C, mode k :
  N_k_C = card({s : MODE_s = k ET s ∈ C})
  N_C = Σ_k N_k_C
  p_k_C = N_k_C / N_C       (avec si N_C = 0, indicateur non calculé)
```

### 4. Entropie et indicateurs dérivés

```
H_C = − Σ_k p_k_C × log_2(p_k_C)
H_max = log_2(K)
H_norm_C = H_C / H_max     ∈ [0, 1]

ΔH = H_C_Q1 − H_C_Q5
ratio_H = H_C_Q1 / H_C_Q5

Bootstrap (B = 1000) pour intervalles de confiance.
```

### 5. Sous-indicateurs

- **H par CMD** : un CMD peut avoir une entropie naturelle plus basse (par exemple obstétrique → quasi toujours entrée programmée), à comparer à structure égale.
- **H_dynamique** : suivi temporel sur 12 trimestres glissants pour détecter érosion (urgence-dépendance croissante).
- **Indicateur de concentration inverse** : Herfindahl-Hirschman HHI = Σ p_k² — borné [1/K, 1], lecture inversée vs H.

## Utilité

- **Diagnostic d'errance des patients précaires** : H faible (proche de 0,3-0,5 normalisé) signe une **dépendance aux urgences** chez les Q5, alors que H plus élevé (0,7-0,9) chez les Q1 traduit une diversité de canaux (programmé, transfert, hospitalisation directe spécialiste).
- **Mesure d'efficacité des programmes d'accès** : déploiement d'une PASS, d'une CPTS, ou d'une consultation non programmée → effet attendu = augmentation de H_Q5 (diversification des entrées).
- **Comparaison territoriale** : ΔH inter-bassins révèle les zones où l'hôpital fonctionne « en mode urgences » pour les précaires faute d'amont structuré.
- **Argumentaire pour les lits non programmés organisés (LNPO)** : un H_Q5 anormalement bas justifie l'ouverture de canaux directs hospitalisation pour patients orientés par MG ou PASS, court-circuitant les urgences.
- **Couplage avec mortalité et qualité** : une H faible n'est pas mauvaise en soi (les urgences peuvent être un excellent canal), mais devient un signal d'alerte si elle est couplée à un sur-risque (retour urgences 7j, mortalité 30j élevée).
- **Pilotage de l'innovation organisationnelle** : LiSP (lits identifiés en soins palliatifs), filières courtes, IPA accès direct — H mesure leur effet structurel.
- **Indicateur d'équité** : ΔH = H_Q1 − H_Q5 est un indicateur d'équité dans l'accès aux canaux organisés. Un ΔH grand = inégalité d'accès.

## Sources de Données

- **PMSI MCO — RSA** : `modeentree`, `DATE_ENTREE`, `FINESSGEO`, `UM_admission`, identifiant chaîné ANO
- **RPU urgences** : pour distinguer M2 (urgences) de M1 (programmé), chaînage RPU-RSA via `IDENTIFIANT_CHAINE` + date d'admission
- **SNDS — DCIR** : `IR_BEN_R` (CMU-C, AME, médecin traitant), `IR_IMB_R` (ALD)
- **FDep INSERM/CépiDc** : IRIS résidence → quintile
- **Référentiels** :
  - [ATIH — Notice technique PMSI 2025 (variables mode_entree, mode_sortie)](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
  - [ATIH — Variables RPU](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf)
  - [Documentation SNDS — variables sociodémo (FDep)](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
  - [CNAM — Observatoire accès aux soins](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
- **Référence méthodologique** : Shannon CE, A Mathematical Theory of Communication, Bell Syst Tech J 1948 — origine de l'entropie de Shannon (référence classique, non re-vérifiée par PubMed).

## Exemple de Valeurs

Ordres de grandeur experts, partition à K = 5 modes ; H_max = log_2(5) ≈ 2,32.

- **H_C_REF (file MCO générale)** : 1,5-1,8 (H_norm ≈ 0,65-0,78) ; canaux variés.
- **H_C_Q1 (favorisés)** : 1,7-2,0 (H_norm 0,73-0,86) ; pic diversification (programmé + transferts + spécialistes).
- **H_C_Q5 (défavorisés)** : 0,9-1,4 (H_norm 0,39-0,60) ; concentration sur urgences.
- **H_C_ALD_sansMT** : 0,8-1,3 — concentration urgences encore plus marquée.
- **H_C_ICV3plus** : 0,7-1,2 — quasi exclusivement urgences.
- **ΔH = H_Q1 − H_Q5** : typiquement 0,4-0,8 sur bassin urbain dense ; 0,1-0,3 sur bassin rural homogène.
- **Bassins très inégalitaires (banlieue dense)** : ΔH > 0,7.
- **Seuil d'alerte** : H_Q5 < 1,0 ET ΔH > 0,6 sur 2 ans consécutifs → alerte inégalité d'accès, plan d'action territorial.
- **Cible** : ΔH < 0,3 = équité d'accès canalique satisfaisante.

## Limites

- **Partition des modes d'entrée** : critique. Une partition trop grossière (K = 2) écrase l'entropie ; trop fine (K = 10) la dilue. Choisir K = 4-6 stable et défini.
- **Sensibilité au volume** : H sur petits effectifs (N_C < 100) instable ; bootstrap obligatoire.
- **Pas de direction de causalité** : H faible chez Q5 traduit autant un défaut d'amont (pas de MG) qu'un comportement (recours préférentiel aux urgences) ou un effet offre (pas de filière courte) ; ne désigne pas le coupable.
- **CMD-dépendance** : obstétrique a une entropie naturelle basse (programmé dominant) ; comparaison inter-CMD trompeuse, à standardiser ou cloisonner.
- **Chaînage RPU-RSA** : indispensable pour distinguer M1 (programmé via domicile) de M2 (admission post-urgences) ; sans ce chaînage, M1 et M2 sont confondus dans le ``modeentree` = 8`. Documenter le taux de chaînage.
- **Accès SNDS** : pour ALD_sansMT et CMU-C, accès SNDS nécessaire ; à défaut, restreindre aux cohortes FDep.
- **Lecture pédagogique** : H n'est pas intuitive pour des non-statisticiens ; préférer H_norm ∈ [0,1] et présenter avec des visualisations (distribution empirique p_k).
- **Comparaison inter-établissement** : la partition étant établissement-dépendante (par exemple présence d'une CPTS, d'une PASS), comparer prudemment avec partition strictement identique et codage harmonisé.
- **Effet trompe-l'œil** : un établissement avec 100 % urgences a H = 0 mais ce n'est mauvais que si les urgences sont mal organisées. L'indicateur doit toujours être lu en couplage avec qualité (retour urgences 7j, mortalité 30j) et `ratio_surrecours_urgences_fdep_q5_q1`.
- **Volumes minimaux** : N_C ≥ 200 par cohorte/an pour stabilité ; sinon agréger 2-3 ans.
- **Évolution PMSI** : la codification des modes d'entrée peut évoluer ; figer la version du manuel ATIH utilisée.

## Références

D'après PubMed (concept entropie de Shannon non spécifique au PMSI, donc pas de PMID direct vérifié pour cet usage exact) :

- [Baker KM et al. — Z codes scoping review, Med Care 2025](https://doi.org/10.1097/MLR.0000000000002101) — contexte SDOH. PMID 39570573

Sources officielles vérifiées dans la session :

- [ATIH — Notice technique PMSI 2025 MCO-HAD-SMR-Psy](https://www.atih.sante.fr/sites/default/files/public/content/4903/notice_technique_atih-mco-had-smr-psy-2025_2eme_modif.pdf)
- [ATIH — Variables RPU](https://www.atih.sante.fr/sites/default/files/public/content/1098/varia_rpu.pdf)
- [CNAM — Observatoire accès aux soins](https://www.assurance-maladie.ameli.fr/presse/2025-09-25-cp-lancement-observatoire-acces-soins)
- [Documentation SNDS — Variables sociodémographiques](https://documentation-snds.health-data-hub.fr/snds/fiches/variables_sociodemo)
- [DREES — Baromètre santé 2023 Dataviz](https://drees.solidarites-sante.gouv.fr/communique-de-presse-jeux-de-donnees/240712-Dataviz_Barometre)
- [HAS — Indicateurs qualité parcours](https://www.has-sante.fr/jcms/p_3306659/fr/indicateurs-de-qualite-des-parcours-de-soins)

Référence conceptuelle non re-vérifiée :
- Shannon CE — A Mathematical Theory of Communication, Bell Syst Tech J 1948 — origine du concept d'entropie informationnelle. Classique, à confirmer DOI avant publication officielle.
