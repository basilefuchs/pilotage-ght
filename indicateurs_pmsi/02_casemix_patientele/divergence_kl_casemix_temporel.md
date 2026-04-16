# Divergence de Jensen-Shannon du Casemix Temporel

## Définition

La divergence de Jensen-Shannon (JSD) du casemix temporel mesure la **distance statistique entre la distribution des GHMs d'une période courante et celle d'une période de référence**, révélant une transformation structurelle du casemix hospitalier indépendamment des variations de volume ou de lourdeur moyenne.

Elle est fondée sur la divergence de Kullback-Leibler (KL), issue de la théorie de l'information (Kullback & Leibler, 1951), qui mesure la "surprise" moyenne encodée dans la distribution P si l'on s'attend à Q :

D_KL(P ‖ Q) = Σᵢ pᵢ × log(pᵢ / qᵢ)

où pᵢ est la proportion du GHM i dans la distribution courante P, et qᵢ sa proportion dans la distribution de référence Q. D_KL est **non symétrique** et **non bornée** (→ ∞ si un GHM présent dans P est absent dans Q), ce qui rend son usage direct difficile pour le pilotage hospitalier.

La **divergence de Jensen-Shannon** corrige ces deux défauts en symétrisant autour de la distribution moyenne M = ½(P + Q) :

JSD(P, Q) = ½ D_KL(P ‖ M) + ½ D_KL(Q ‖ M)

JSD est **symétrique**, **bornée** dans [0 ; log(2)] ≈ [0 ; 0,693 nats] (ou [0 ; 1 bit] en log₂), et vaut 0 si et seulement si P = Q. Sa racine carrée √JSD est une **distance métrique** au sens mathématique strict, ce qui autorise les comparaisons triangulaires et le positionnement dans un espace de casemix.

La différence fondamentale avec les indicateurs existants est la suivante :
- Le **CMI** (`case_mix_index`) mesure la lourdeur moyenne scalaire — invariant à une permutation de GHMs de même poids
- L'**entropie de Shannon** (`entropie_shannon_casemix`) mesure la diversité de la distribution courante — sans référence temporelle
- L'**indice de diversité GHM** (`indice_diversite_ghm`) compare la richesse structurelle — mais sans capturer la dérive par rapport à un état passé

La JSD capte une information qualitativement différente : la **dérive silencieuse** du casemix, c'est-à-dire les glissements progressifs de la structure de l'activité (GHMs qui disparaissent, GHMs émergents, réallocation entre CMDs) invisibles dans tout indicateur scalaire non référencé temporellement.

## Calcul

Source : PMSI MCO RSA — variable GHM (6 caractères) par séjour, FINESS géographique, année (ou trimestre) d'analyse.

```
Population : tous les séjours MCO d'un établissement ou d'une UM
             sur deux périodes comparables (même fenêtre calendaire)

Étape 1 — Construction des distributions GHM :
  Période de référence Q (ex. : année 2019, pré-COVID) :
    N_Q      = nombre total de séjours sur la période Q
    q_i      = N_Q(GHM=i) / N_Q   pour chaque GHM i observé

  Période courante P (ex. : année n) :
    N_P      = nombre total de séjours sur la période P
    p_i      = N_P(GHM=i) / N_P   pour chaque GHM i observé

  Union des GHMs : I = I_P ∪ I_Q  (tous les GHMs présents dans au moins une période)
  -- GHMs présents dans P mais absents de Q → q_i = 0 avant lissage
  -- GHMs présents dans Q mais absents de P → p_i = 0 avant lissage

Étape 2 — Lissage de Laplace (éviter log(0)) :
  ε = 0,5 / N  (pseudo-compte de Laplace; N = max(N_P, N_Q))
  p_i_lissé = (N_P(GHM=i) + ε) / (N_P + ε × |I|)
  q_i_lissé = (N_Q(GHM=i) + ε) / (N_Q + ε × |I|)
  -- Renormaliser pour que Σ p_i_lissé = 1 et Σ q_i_lissé = 1

Étape 3 — Calcul de la JSD :
  M_i = ½ × (p_i_lissé + q_i_lissé)
  D_KL(P‖M) = Σᵢ p_i_lissé × ln(p_i_lissé / M_i)
  D_KL(Q‖M) = Σᵢ q_i_lissé × ln(q_i_lissé / M_i)
  JSD(P, Q)  = ½ × D_KL(P‖M) + ½ × D_KL(Q‖M)
  JS_dist    = √JSD(P, Q)     -- distance métrique, ∈ [0 ; √ln(2)] ≈ [0 ; 0,832]
  Unité : nats si ln, bits si log₂

Étape 4 — Attribution par GHM (contribution à la divergence) :
  contrib_i = ½ × p_i × ln(p_i/M_i) + ½ × q_i × ln(q_i/M_i)
  -- GHMs à contrib_i élevée = moteurs de la transformation du casemix
  -- Trier par contrib_i décroissant → top 10 "GHMs divergents"

Étape 5 — Attribution par CMD :
  JSD_cmd(c) = Σᵢ∈CMD_c contrib_i
  -- Quelle CMD explique l'essentiel de la dérive ?
  -- Représentation : treemap des contributions CMD
```

Indicateurs dérivés :

```
JSD glissante trimestrielle (vs Q fixe 2019) :
  JSD_T(n) = JSD(P_T_n, Q_2019)  pour T ∈ {T1, T2, T3, T4} × n
  → Courbe d'évolution de la dérive casemix depuis la référence pré-COVID

JSD symétrique inter-établissements (comparaison GHT) :
  JSD_etab(A, B) = JSD(P_A, P_B)  même période, établissements différents
  → Matrice de distances casemix entre établissements du GHT
  → √JSD utilisable pour clustering hiérarchique des établissements

Taux de renouvellement du casemix :
  turnover = (Σᵢ max(p_i - q_i, 0))  -- flux net entrant dans le casemix courant
  -- Variation de JSD avec turnover faible = redistribution interne
  -- Variation de JSD avec turnover élevé = véritables nouveaux GHMs
```

## Utilité

- **Détecter la dérive silencieuse du casemix stratégique** : un établissement dont le CMI et les volumes restent stables peut néanmoins subir une transformation structurelle majeure (glissement de CMD 08 orthopédie vers CMD 01 neurologie par ex.) que seul un JSD élevé révèle — information décisive pour anticiper les besoins en compétences, équipements et accréditations avant qu'ils ne deviennent urgents
- **Évaluer la persistance de l'impact COVID sur le casemix** : la JSD trimestrielle glissante vs 2019 permet de quantifier à quelle vitesse chaque établissement du GHT a reconstitué son casemix pré-pandémique, spécialité par spécialité — un JSD(2023 vs 2019) encore élevé sur la CMD 10 (endocrinologie) signale une récupération incomplète justifiant une analyse de la filière
- **Comparer la congruence des casemix intra-GHT** : la matrice de distances JS_dist entre établissements d'un GHT identifie les sites au casemix proche (risque de doublon stratégique) et ceux au casemix orthogonal (complémentarité) — argument quantitatif pour le projet médical partagé (PMSP) et la répartition des missions
- **Qualifier l'impact d'une réorganisation** : lors d'une fusion de services, d'une ouverture d'autorisation ou d'un départ de praticien, la JSD avant/après chiffre l'amplitude réelle de la transformation du casemix — distingue les réorganisations à fort impact (JSD > 0,10) des ajustements mineurs (JSD < 0,02)
- **Détecter les artefacts de codage à grande échelle** : un saut brutal de JSD sans événement clinique ou organisationnel connu est un signal fort d'une modification des pratiques de codage (changement de codeuse, nouvelle version du logiciel de groupage) — l'analyse des GHMs les plus divergents cible l'audit de codage
- **Construire un tableau de bord de stabilité stratégique** : la JSD trimestrielle agrégée sur 3 ans produit une "courbe de dérive casemix" intégrable dans le rapport d'activité destiné au directoire, plus informative qu'une liste de volumes par CMD pour communiquer sur la trajectoire de l'établissement

## Sources de Données

- **PMSI MCO RSA** : champ `GHM` (6 caractères, version annuelle), FINESS géographique, année (ou mois+année pour granularité trimestrielle) — extraction sur au minimum 2 années (référence + courante) ; recommandé 5 ans pour la JSD glissante
- **Référentiel ATIH des GHMs** : table de correspondance GHM → CMD → libellé, pour l'attribution par CMD et la présentation des GHMs divergents aux équipes médicales — indispensable pour identifier les GHMs apparus/disparus liés à des changements de version de classification
- **Historique des versions de classification GHM (ATIH)** : pour identifier les GHMs renommés ou restructurés entre versions (v11c → v12 → v12a) afin de ne pas confondre un changement nomenclatural avec une dérive clinique réelle — disponible dans les notes de version ATIH

## Exemple de Valeurs

Ordres de grandeur observés sur le PMSI MCO français (unités : nats, log naturel) :

| Contexte | JSD | Interprétation |
|---|---|---|
| Même établissement, années consécutives stables (2017 vs 2018) | 0,005–0,020 | Stabilité structurelle normale |
| Même établissement, légère évolution stratégique (2022 vs 2019) | 0,030–0,080 | Dérive modérée post-COVID |
| Impact COVID fort (2020 vs 2019) | 0,150–0,350 | Transformation majeure (chirurgie effondrée) |
| Ouverture d'une nouvelle activité (chirurgie cardiaque ex-nihilo) | 0,080–0,200 | Signal de développement de filière |
| Deux CH généraux comparables, même année | 0,050–0,150 | Casemix proches mais distincts |
| CHU vs clinique spécialisée, même année | 0,300–0,600 | Profils structurellement éloignés |
| Artefact codage seul (changement codeuse) | 0,020–0,060 | Faux signal, sans évolution clinique |

Seuils d'alerte opérationnels :
- **JSD > 0,05** entre deux années consécutives sans événement organisationnel documenté : déclencher une analyse des GHMs les plus divergents (top 10 par contrib_i)
- **JSD > 0,10** entre n et référence 2019 en 2023+ : la reconstitution post-COVID est incomplète — identifier les CMDs à forte contribution résiduelle
- **JS_dist inter-établissements < 0,10** entre deux sites du GHT pour la même période : risque de doublon stratégique à instruire dans le PMSP

## Limites

- **Sensibilité aux changements de version GHM** : le passage d'une version de classification ATIH à une autre peut créer des GHMs nouveaux ou supprimer des GHMs existants sans modification clinique réelle — calculer la JSD sur des racines GHM stables (5 premiers caractères) ou sur des regroupements CMD pour les comparaisons inter-annuelles sur fenêtres longues
- **Dépendance au lissage choisi** : la valeur de ε dans le lissage de Laplace influence les GHMs rares (1-2 séjours) — pour les établissements à fort volume (> 10 000 séjours/an), l'impact est négligeable ; pour les petits établissements ou les services peu actifs, tester la sensibilité au lissage avant interprétation
- **Non interprétable sans analyse d'attribution** : la valeur brute de JSD est un signal d'alarme, pas un diagnostic — sans la décomposition par CMD et par GHM (contrib_i), il est impossible de distinguer une transformation clinique réelle d'un artefact de codage ou d'une modification nomenclaturale
- **Seuil minimal de volume** : calculé sur moins de 500 séjours par période, la JSD est instable statistiquement — les petites unités (< 200 séjours/an) doivent agréger sur 2-3 ans pour obtenir une distribution GHM suffisamment peuplée
- **Insensibilité à la lourdeur** : deux distributions P et Q peuvent avoir une JSD nulle (structures identiques) avec des CMIs très différents si la lourdeur au sein de chaque GHM a évolué — la JSD doit être complétée par le CMI pour une analyse complète du casemix

## Références

- [Kullback S., Leibler R.A. — On information and sufficiency, Annals of Mathematical Statistics 1951 : définition originale de la divergence KL](https://doi.org/10.1214/aoms/1177729694)
- [Lin J. — Divergence measures based on the Shannon entropy, IEEE Transactions on Information Theory 1991 : définition et propriétés de la divergence de Jensen-Shannon](https://doi.org/10.1109/18.61115)
- [Cover T.M., Thomas J.A. — Elements of Information Theory, 2ᵉ éd., Wiley 2006 : référence théorique complète sur KL, JSD et métriques de distributions]
- [Endres D.M., Schindelin J.E. — A new metric for probability distributions, IEEE Transactions on Information Theory 2003 : démonstration que √JSD est une distance métrique](https://doi.org/10.1109/TIT.2003.813506)
- [Österreicher F., Vajda I. — A new class of metric divergences on probability spaces, Annals of the Institute of Statistical Mathematics 2003 : propriétés métriques de la JS distance](https://doi.org/10.1007/BF02517812)
- [ATIH — Guide méthodologique PMSI MCO, notes de version de la classification GHM : référence pour la gestion des ruptures de série nomenclaturales](https://www.atih.sante.fr/)
