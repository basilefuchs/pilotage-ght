# Entropie Conditionnelle des Diagnostics Associés par GHM

## Définition

L'entropie conditionnelle des diagnostics associés (DA) par GHM mesure l'**imprévisibilité du profil de comorbidités d'un séjour, sachant le GHM auquel il appartient**. Elle quantifie la part de complexité clinique que la classification GHM ne parvient pas à capturer.

Formellement, si D désigne l'ensemble des codes DA (CIM-10) et G l'ensemble des GHMs observés :

H(DA | GHM) = −Σ_g p(g) × Σ_d p(d|g) × log₂ p(d|g)

où :
- p(g) = proportion des séjours dans le GHM g sur la période
- p(d|g) = proportion des séjours du GHM g ayant au moins un DA codé d
- la convention 0 × log₂(0) = 0 s'applique

H(DA | GHM) est exprimée en bits. Elle est nulle si, pour chaque GHM, le même ensemble fixe de DAs est systématiquement codé (comorbidités parfaitement prédictibles par le GHM). Elle est maximale lorsque les profils de DA sont uniformément distribués au sein de chaque GHM, reflétant une hétérogénéité maximale des patientèles.

La décomposition par GHM, H(DA | GHM=g), révèle les groupes à forte charge résiduelle :

H(DA | GHM=g) = −Σ_d p(d|g) × log₂ p(d|g)

La version normalisée permet la comparaison entre GHMs de taille différente :

H'(DA | GHM=g) = H(DA | GHM=g) / log₂(nb_DA_distincts_observés_dans_g)    ∈ [0 ; 1]

**Positionnement par rapport aux indicateurs existants :**

| Indicateur | Ce qu'il mesure | Ce qu'il ne voit pas |
|---|---|---|
| `entropie_shannon_casemix` | Diversité de la distribution des GHMs | Hétérogénéité *au sein* de chaque GHM |
| `nombre_moyen_diagnostics_associes` | Volume moyen de DAs par séjour | Structure et diversité des codes DA |
| `indice_charlson_moyen` / `elixhauser` | Lourdeur scalaire des comorbidités | Imprévisibilité du profil de comorbidités |
| `taux_sejours_comorbidites_multiples` | Prévalence des séjours multi-DAs | Distribution conditionnelle par GHM |

L'entropie conditionnelle capte une dimension qualitativement différente : la **complexité résiduelle non expliquée par le groupage GHM**, c'est-à-dire à quel point deux séjours dans le même GHM peuvent avoir des profils de comorbidités radicalement différents.

## Calcul

Sources : PMSI MCO RSA — variables GHM (6 caractères), diagnostics associés (DAS_1 à DAS_n), FINESS géographique, année de sortie.

```
Population : tous les séjours MCO d'un établissement sur la période d'analyse
             (minimum recommandé : 2 000 séjours RSA pour stabilité)

Étape 1 — Expansion en format long (un enregistrement par (séjour, DA)) :
  stays_da = RSA
    .select([NO_RSA, GHM, DAS_1, ..., DAS_30])
    .melt(id_vars=[NO_RSA, GHM], value_vars=[DAS_1..DAS_30])
    .filter(DAS != "" AND DAS IS NOT NULL)
    .deduplicate([NO_RSA, GHM, DAS])
  -- Un DA comptabilisé au plus une fois par séjour (doublons intra-séjour supprimés)
  -- Les codes "" et "0000" (absence de DA) sont exclus

Étape 2 — Distribution marginale p(d|g) :
  Pour chaque GHM g :
    N_g   = count(NO_RSA dans RSA où GHM == g)       -- nb séjours dans le GHM g
    Pour chaque code DA d observé dans stays_da où GHM == g :
      n_dg  = count(NO_RSA distincts dans stays_da où GHM == g ET DAS == d)
      p(d|g) = n_dg / N_g
    -- Convention : p(d|g) = 0 si d absent du GHM g (ne contribue pas à l'entropie)

Étape 3 — Entropie conditionnelle par GHM :
  H_g = −Σ_d p(d|g) × log₂(p(d|g))
  -- Unité : bits
  -- Plage : [0 ; log₂(nb_DA_distincts_observés_dans_g)]
  -- Seuil de stabilité : N_g < 30 → exclure le GHM g du calcul agrégé

Étape 4 — Entropie conditionnelle normalisée par GHM :
  K_g     = count(DA distincts observés dans stays_da où GHM == g)
  H'_g    = H_g / log₂(K_g)    si K_g > 1
  H'_g    = 0                   si K_g <= 1
  -- H'_g ∈ [0 ; 1] ; H'_g = 1 → tous les DAs équiprobables dans ce GHM

Étape 5 — Entropie conditionnelle globale (pondérée) :
  N_total = count(NO_RSA dans RSA)
  p(g)    = N_g / N_total
  H(DA|GHM)  = Σ_g p(g) × H_g     -- en bits, pondérée par le poids de chaque GHM
  H'(DA|GHM) = Σ_g p(g) × H'_g    -- normalisée ∈ [0 ; 1]
```

Indicateurs dérivés :

```
Top-K GHMs à entropie résiduelle maximale :
  top_k = GHMs triés par H'_g décroissant (parmi N_g >= 30)
  → Identification des groupes à hétérogénéité maximale de comorbidités
  → Cibles prioritaires pour audit de codage ou révision de protocoles

Profil d'entropie par CMD :
  H_cmd(c) = Σ_{g ∈ CMD_c} p(g|CMD_c) × H_g
  → Quelle CMD concentre la complexité résiduelle la plus élevée ?

Dérive temporelle d'entropie conditionnelle :
  ΔH'(DA|GHM) = H'(DA|GHM)[année n] − H'(DA|GHM)[année n-1]
  ΔH' > 0 → diversification des profils de comorbidités (patientèle plus hétérogène)
  ΔH' < 0 → homogénéisation (ou sous-codage des DAs secondaires)

Ratio entropie résiduelle / entropie totale (part non expliquée) :
  R_explained = 1 − H(DA|GHM) / H(DA)
  H(DA) = −Σ_d p(d) × log₂(p(d))  (entropie marginale de tous les DAs)
  R_explained → 1 : le GHM explique bien la distribution des comorbidités
  R_explained → 0 : le GHM n'apporte aucune information sur les comorbidités
```

## Utilité

- **Détecter et cibler le sous-codage des DAs** : pour un GHM médical complex (ex. insuffisance cardiaque décompensée, CMD 05), une H'(DA|GHM=g) anormalement basse par rapport aux établissements de référence signale un codage appauvri des comorbidités — chaque bit d'entropie manquant correspond à des DAs non renseignés susceptibles d'activer des CMA/CMAS et de modifier le GHM final ; l'indicateur oriente les sessions d'audit vers les GHMs sous-codés plutôt que vers la totalité du RSA

- **Identifier les GHMs à prise en charge hétérogène nécessitant une segmentation** : les GHMs à H'_g élevée regroupent des patients au profil de comorbidités très variable — ils sont candidats à une analyse de pertinence plus granulaire (sous-groupes par score de comorbidité, par âge, par mode d'entrée) ou à la mise en place de chemins cliniques différenciés ; dans un GHT, ces GHMs sont ceux pour lesquels le protocole unique entre établissements est le moins adapté

- **Comparer la complexité résiduelle entre établissements du GHT à casemix identique** : deux sites ayant le même CMI et la même distribution de GHMs peuvent avoir des H(DA|GHM) très différents ; le site à entropie plus haute prend en charge des patients dont la polypathologie est moins stéréotypée, argument objectif pour une dotation en ressources soignantes différenciée ou pour une orientation préférentielle des cas complexes dans le cadre du projet médical partagé

- **Mesurer l'impact d'une politique de codage exhaustif** : lors du déploiement d'un logiciel de codage assisté (NLP, aide à la saisie) ou d'une formation des médecins DIM, l'indicateur mesure si la politique produit une diversification réelle des profils de DAs (ΔH' > 0) ou seulement un accroissement du nombre de DAs sans diversification (ΔH' ≈ 0 malgré un nombre moyen de DAs croissant) — signal discriminant entre enrichissement qualitatif et inflation quantitative

- **Signal précoce de mutation silencieuse de la patientèle** : une augmentation significative de H(DA|GHM) sur un service sans changement de GHMs dominants indique que les patients du même groupe se présentent avec des profils de comorbidités de plus en plus diversifiés — signal d'alerte d'une prise en charge de recours croissante ou d'un vieillissement de la patientèle, visible avant que le CMI ou les volumes n'évoluent

- **Évaluer la pertinence d'une classification GHM lors des mises à jour ATIH** : si une révision de la classification (passage v11 → v12) est censée mieux segmenter la complexité clinique, H(DA|GHM) doit diminuer après révision — la persistance d'une forte entropie résiduelle sur les GHMs restructurés démontre que la nouvelle classification capture mal la réalité des comorbidités documentées dans l'établissement

- **Construire un indicateur composite de complexité non tarifée** : combiné au nombre moyen de DAs et au score d'Elixhauser, H(DA|GHM) constitue le troisième axe d'une représentation tridimensionnelle de la complexité : volume (nb DAs), lourdeur (Elixhauser) et imprévisibilité (entropie conditionnelle) — les séjours dans le quadrant "faible lourdeur × haute entropie" sont des candidats à la sous-tarification T2A (comorbidités diversifiées mais légères, non activant de CMA)

## Sources de Données

- **PMSI MCO RSA** : champs `GHM` (6 caractères, version annuelle), `DAS_1` à `DAS_30` (codes CIM-10 des diagnostics associés significatifs), `NO_RSA` (identifiant séjour anonymisé), FINESS géographique, `ANSOR` (année de sortie) — extraction minimale sur 1 an, recommandée sur 3 ans pour la stabilité des distributions par GHM
- **Référentiel CIM-10 FR** : table de correspondance code CIM-10 → libellé → chapitre, pour l'interprétation et la présentation des DAs les plus fréquents par GHM aux équipes médicales — version annuelle ATIH (en vigueur selon l'année du PMSI)
- **Référentiel ATIH des GHMs** : correspondance GHM → CMD → libellé, pour la décomposition par CMD de l'entropie conditionnelle et la présentation aux cliniciens
- **Table des CMA/CMAS ATIH** : liste des codes DA à fort impact sur le groupage (déclencheurs de niveau de sévérité 2/3/4) — utile pour filtrer et identifier les DAs à forte valeur informative parmi ceux contribuant à l'entropie

## Exemple de Valeurs

Ordres de grandeur H'(DA|GHM) — version normalisée, en bits relatifs — estimés sur le PMSI MCO français :

| Type d'établissement / contexte | H(DA\|GHM) brut (bits) | H'(DA\|GHM) normalisé | Interprétation |
|---|---|---|---|
| CHU polyvalent (all CMDs, >30 000 séjours/an) | 4,5–6,5 | 0,55–0,70 | Forte hétérogénéité résiduelle, patientèle de recours |
| CH général 500 lits | 3,5–5,0 | 0,45–0,60 | Hétérogénéité modérée, casemix médico-chirurgical standard |
| Clinique chirurgicale mono-spécialité | 1,5–2,5 | 0,20–0,35 | DAs stéréotypés, chirurgie programmée homogène |
| Service de gériatrie (CMD 23 + poly-CMD) | 5,0–7,0 | 0,62–0,75 | Maximum attendu — polypathologie très diversifiée |
| Service de chirurgie orthopédique programmée | 1,0–2,0 | 0,15–0,28 | Faible hétérogénéité, patientèle standardisée |
| GHM spécifique : Z671 (PTH premier séjour, niv. 2) | 2,0–3,5 | 0,28–0,45 | Hétérogénéité modérée selon la politique de codage des DAs pré-opératoires |
| GHM spécifique : K291 (insuffisance cardiaque, niv. 3) | 4,5–6,5 | 0,58–0,72 | Haute — nombreuses comorbidités, profils très variables |

Seuils d'alerte opérationnels :

- **H'_g < 0,10 pour un GHM médical à N_g > 100** : signal fort de sous-codage des DAs dans ce groupe — déclencher un audit ciblé (sélection de 20 séjours du GHM pour relecture codage)
- **H'_g > 0,80 pour un GHM chirurgical programmé** : profil anormal, possible mélange de sous-groupes hétérogènes dans le même GHM ou codage erratique des DAs
- **ΔH'(DA|GHM) > +0,05 entre deux années sans changement de classification** : mutation significative du profil de comorbidités de la patientèle — analyser par CMD pour identifier les filières en transformation
- **R_explained < 0,15** (ratio entropie résiduelle / entropie totale) : le GHM explique moins de 15 % de la distribution des DAs — signal d'un casemix fortement hétérogène où la classification GHM est peu discriminante des comorbidités réelles

## Limites

- **Distribution marginale, non jointe** : p(d|g) mesure la probabilité individuelle de chaque DA dans un GHM, indépendamment des co-occurrences — deux établissements avec H'_g identiques peuvent avoir des profils de comorbidités très différents si les corrélations entre DAs diffèrent ; l'entropie conditionnelle ne capture pas la structure de dépendance entre comorbidités (ex. diabète + IRC + HTA comptabilisés séparément, alors que leur co-occurrence est cliniquement spécifique)

- **Sensibilité majeure aux politiques de codage** : les établissements avec une politique de codage exhaustif (formation DIM intensive, aide à la saisie NLP) coderont plus de DAs rares, augmentant mécaniquement H(DA|GHM) indépendamment de toute différence clinique réelle — les comparaisons inter-établissements doivent être ajustées sur le nombre moyen de DAs par séjour (NADS = nombre moyen de DAS) avant interprétation ; une corrélation forte entre NADS et H(DA|GHM) à l'échelle inter-établissements est un signal d'artéfact de codage

- **Seuil minimal de volume par GHM** : un GHM avec moins de 30 séjours sur la période a une distribution p(d|g) statistiquement instable — les valeurs H'_g de ces GHMs doivent être exclues du calcul agrégé ou signalées comme non fiables ; pour les petits établissements (< 2 000 séjours MCO/an), agréger sur 3 années glissantes

- **Ruptures de série liées aux mises à jour CIM-10** : le changement annuel de la CIM-10 française (nouvelles versions ATIH) peut créer des codes DA supplémentaires ou supprimer des codes existants, induisant des discontinuités de H(DA|GHM) non liées à des changements cliniques — vérifier les notes de version CIM-10 ATIH pour les comparaisons inter-annuelles sur fenêtre longue (> 3 ans)

- **Ne distingue pas complexité vraie et sur-codage défensif** : dans les établissements pratiquant le sur-codage des DAs pour optimiser la valorisation T2A (ajout de DAs mineurs activant des CMA), H(DA|GHM) sera artificiellement élevé — croiser avec le taux de séjours niveau 3-4 et l'analyse de cohérence DP/DAS pour distinguer les deux phénomènes

- **Interprétation dépendante du contexte de l'établissement** : une H'(DA|GHM) élevée dans un service de médecine interne est normale (polyvalence attendue) ; la même valeur dans un service de chirurgie orthopédique programmée est un signal d'anomalie ; aucun seuil universel ne s'applique — l'interprétation exige une comparaison à la moyenne du type d'établissement (CHU / CH / clinique) et à la propre trajectoire historique de l'entité

## Références

- [Shannon C.E. — A Mathematical Theory of Communication, Bell System Technical Journal 1948 : fondement de la théorie de l'entropie et de l'entropie conditionnelle](https://doi.org/10.1002/j.1538-7305.1948.tb01338.x)
- [Cover T.M., Thomas J.A. — Elements of Information Theory, 2ᵉ éd., Wiley 2006 (chap. 2 : Entropy, Relative Entropy and Mutual Information) : définition formelle de H(Y|X) et propriétés de la réduction d'incertitude conditionnelle]
- [Lucyk K., Tang K., Quan H. — Barriers to data quality resulting from the process of coding health information to administrative data, BMC Health Services Research 2017 : impact des pratiques de codage sur la qualité et la distribution des codes de diagnostic dans les bases PMSI-like](https://doi.org/10.1186/s12913-017-2697-y)
- [Quan H. et al. — Coding algorithms for defining comorbidities in ICD-9-CM and ICD-10 administrative data, Medical Care 2005 : référence pour l'interprétation des codes DA dans les bases médico-administratives](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
- [Pine M. et al. — Enhancement of claims data to improve risk adjustment of hospital mortality, JAMA 2007 : lien entre richesse du codage des comorbidités et qualité de l'ajustement au risque](https://doi.org/10.1001/jama.297.1.71)
- [ATIH — Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation en MCO (version en vigueur) : définition des DAS, règles de codage et rôle dans le groupage GHM](https://www.atih.sante.fr/)
- [ATIH — Classification des GHMs et tables de référence (version annuelle) : liste des CMA/CMAS, correspondances GHM-CMD, indispensables pour l'interprétation de la contribution des DAs au groupage](https://www.atih.sante.fr/)
