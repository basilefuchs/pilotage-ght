# Distance de Levenshtein des Séquences de Soins

## Définition

La distance d'édition de Levenshtein (Vladimir Levenshtein, 1965) mesure le nombre minimal d'opérations élémentaires — **insertions**, **suppressions** et **substitutions** — nécessaires pour transformer une chaîne de caractères en une autre. Initialement développée pour la correction orthographique et la comparaison de séquences ADN en bioinformatique, elle quantifie la dissimilarité entre deux séquences ordonnées sans exiger qu'elles aient la même longueur.

Appliquée aux parcours de soins, la **Distance de Levenshtein des Séquences de Soins** (DLSS) mesure l'écart entre la séquence d'actes réellement réalisée par un patient et une séquence de référence (protocole, parcours type, recommandation HAS). Contrairement au Taux de Dérive des Plans de Soins (TDPS) qui ne mesure que la présence/absence des actes, la DLSS capture également **l'ordre** dans lequel les actes sont réalisés — une inversion de deux actes majeurs (bilan biologique après et non avant l'ajustement thérapeutique) est une erreur de séquence que le TDPS ignore mais que la DLSS détecte.

**DLSS(P, Q) = d_Levenshtein(P, Q)**

où P est la séquence de référence (protocole) et Q la séquence observée (parcours réel), chaque élément de la séquence étant un acte codé (CCAM, GHM, ATCq ou code BHN). Une DLSS = 0 signifie que le parcours réel est identique au parcours de référence. Une DLSS élevée indique une divergence structurelle — non seulement des actes manquent ou s'ajoutent, mais leur ordre est différent de ce qui était prévu.

## Calcul

Encodage des séquences :

```
Séquence de référence P = [a₁, a₂, …, aₙ]
  → Chaque aᵢ est un acte codé : code CCAM, code GHM, code ATC niveau 4,
    ou code BHN (biologie), selon la granularité choisie
  → Exemple (parcours diabète type 2, suivi annuel HAS) :
    P = [HbA1c, Créatinine, Consultation_diabétologue, Fond_oeil,
         Metformine_dispensation, Consultation_MG]

Séquence observée Q = [b₁, b₂, …, bₘ]  (m ≠ n possible)
  → Extraite depuis :
    - PMSI RSA (actes CCAM horodatés dans le séjour ou consultations externes)
    - DCIR ER_PRS_F (consultations de ville, ordonnées chronologiquement)
    - DCIR ER_PHA_F (dispensations médicamenteuses, chronologiques)
    - DCIR ER_BIO_F (actes de biologie, chronologiques)
  → Les actes sont triés par date d'exécution pour former la séquence temporelle
  → Fenêtre temporelle : 12 mois glissants par défaut
```

Algorithme de calcul (programmation dynamique) :

```
Matrice d'édition D de dimensions (n+1) × (m+1) :

  Initialisation :
    D[i][0] = i   (supprimer i éléments de P pour obtenir une séquence vide)
    D[0][j] = j   (insérer j éléments pour construire Q depuis une séquence vide)

  Récurrence (pour i ∈ {1..n}, j ∈ {1..m}) :
    Si aᵢ = bⱼ : coût_substitution = 0
    Sinon       : coût_substitution = 1 (ou coût_pondéré selon la gravité clinique)

    D[i][j] = min(
      D[i-1][j]   + 1,              ← suppression de aᵢ (acte de P omis dans Q)
      D[i][j-1]   + 1,              ← insertion  de bⱼ  (acte de Q absent dans P)
      D[i-1][j-1] + coût_substitution  ← substitution
    )

  DLSS = D[n][m]
```

Normalisation :

```
DLSS_norm = DLSS / max(n, m)   ∈ [0 ; 1]
  → Indépendant de la longueur des séquences, comparable entre protocoles
  → DLSS_norm = 0 : séquences identiques
  → DLSS_norm = 1 : séquences totalement différentes (distance maximale)

DLSS_norm > 0.3 : divergence significative (> 30% des actes de référence
                   sont insérés, supprimés ou substitués)
DLSS_norm > 0.5 : divergence majeure — le parcours réel n'est plus
                   reconnaissable par rapport au protocole
```

Coûts d'édition pondérés (version clinique avancée) :

```
En pratique clinique, toutes les opérations d'édition n'ont pas le même impact :
  → Suppression d'un acte critique (HbA1c pour diabète, INR pour AVK) : coût = 3
  → Substitution d'une molécule par une molécule de la même classe ATC : coût = 0.5
  → Insertion d'un acte supplémentaire non prévu (consultation supplémentaire) : coût = 0.5
  → Inversion de l'ordre de deux actes adjacents (transposition) : coût = 1

La matrice de coûts est définie par des experts cliniques par protocole.
La DLSS pondérée reflète la gravité clinique de la divergence,
pas seulement son volume.
```

Analyse de cohorte :

```
DLSS_cohorte = médiane(DLSS_norm_i) sur tous les patients i suivant le même protocole
  → P25, P75 : distribution de la divergence dans la cohorte
  → DLSS_outlier : patients avec DLSS_norm > P75 + 1.5 × IQR

Matrice de substitution fréquentielle :
  → Pour chaque paire (aᵢ, bⱼ) avec coût de substitution > 0,
    compter la fréquence de cette substitution dans la cohorte
  → Identifier les substitutions les plus fréquentes = les déviations
    protocolaires systématiques (acte X systématiquement remplacé par Y)
  → Exemple : HbA1c remplacée par glycémie à jeun dans 30% des cas =
    dérive systématique du suivi biologique diabétique
```

## Utilité

- **Mesurer la conformité aux protocoles en capturant l'ordre des actes** : contrairement aux indicateurs de présence/absence (TDPS), la DLSS détecte les inversions de séquence cliniquement significatives — un bilan hépatique réalisé après l'introduction d'une hépatotoxique plutôt qu'avant est une erreur de séquence grave que seule la distance d'édition peut quantifier
- **Identifier les sous-types de divergence protocolaire** : en analysant les opérations d'édition dominantes (suppressions vs insertions vs substitutions), distinguer les profils de déviation — un service avec beaucoup de suppressions manque de ressources pour réaliser tous les actes prévus ; un service avec beaucoup d'insertions sur-traite ; un service avec beaucoup de substitutions applique des alternatives non recommandées
- **Clustering des parcours par similarité** : en calculant la matrice de distances DLSS entre tous les parcours d'une cohorte, appliquer un algorithme de clustering (k-médoïdes, clustering hiérarchique) pour identifier des sous-groupes de parcours similaires — révèle des patterns d'organisation des soins non visibles dans les statistiques descriptives
- **Détection des trajectoires aberrantes en temps quasi-réel** : calculé en continu sur une fenêtre glissante, la DLSS individuelle croissante est un signal précoce de décrochage du protocole — outil d'alerte pour les infirmières de coordination avant que la déviation ne génère un événement indésirable
- **Évaluation de l'impact des outils d'aide à la décision** : mesurer la DLSS des prescriptions avant/après l'implémentation d'un outil d'aide à la décision (CDSS) ou d'un protocole électronique dans le DPI — la réduction de la DLSS_cohorte est l'indicateur de résultat de ces investissements informatiques
- **Benchmarking inter-établissements sur la fidélité protocolaire** : comparer la distribution des DLSS pour le même protocole entre établissements du GHT — les établissements avec DLSS_cohorte faible ont des processus de suivi protocolaire plus matures (peut-être un logiciel de gestion de protocoles, une infirmière de coordination, des rappels automatiques)

## Sources de Données

- **PMSI MCO RSA** : séquences d'actes CCAM horodatés dans les séjours d'hospitalisation, actes des consultations externes (ATU, DMI) — pour les protocoles à actes hospitaliers
- **DCIR ER_PRS_F** : consultations et actes médicaux ambulatoires avec date d'exécution et code RPPS — pour reconstituer la chronologie des consultations dans les parcours chroniques
- **DCIR ER_PHA_F** : dates de dispensation et code ATC des médicaments — pour les séquences thérapeutiques (introduction, ajustement, switch de traitement)
- **DCIR ER_BIO_F** : dates des actes biologiques et codes BHN — pour les séquences de suivi biologique (HbA1c, INR, créatinine, BNP)
- **Référentiels de protocoles formalisés** (base INCa, algorithmes HAS, RBPSO) : source de la séquence de référence P — leur formalisation en séquence ordonnée d'actes codés est un prérequis ; l'ATIH et les sociétés savantes publient des algorithmes décisionnels codifiables en séquence

## Exemple de Valeurs

- **Parcours diabète type 2 (suivi annuel HAS, 8 actes de référence)** :
  Patient bien suivi : DLSS = 1 (1 acte décalé, fond d'œil réalisé en mois 11 au lieu de mois 6) → DLSS_norm = 0,13 (divergence mineure)
  Patient mal suivi : DLSS = 4 (fond d'œil absent, créatinine absente, consultation diabétologue substituée par urgences) → DLSS_norm = 0,50 (divergence majeure)
  DLSS_cohorte médiane : 0,20-0,30 dans les études disponibles sur les ALD diabète

- **Protocole FOLFOX colorectal (6 cycles, 12 actes) — oncologie** :
  DLSS_norm = 0,08-0,15 dans les centres experts (logiciel de chimiothérapie dédié)
  DLSS_norm = 0,25-0,40 dans les centres sans coordination protocoles formalisée

- **Parcours AVC (filière urgences → UNV → SSR)** :
  Séquence de référence : [Scanner_cérébral, IRM_DWI, Thrombolyse/Thrombectomie, UNV_admission, Bilan_étiologique, SSR_neuro, Anticoagulation]
  DLSS = 0 pour les patients pris en charge dans un centre expert avec filière dédiée
  DLSS = 3-4 pour les patients pris en charge hors filière (actes dans le mauvais ordre ou manquants)

- **Substitution la plus fréquente identifiée** : glycémie à jeun à la place de HbA1c dans 25-35% des suivis diabétiques — identifiable par la matrice de substitution fréquentielle de la cohorte ALD diabète

## Limites

- La définition de la **séquence de référence P** est le principal obstacle opérationnel : les recommandations HAS et INCa décrivent les actes à réaliser mais rarement leur ordre temporel précis ; la formalisation en séquence ordonnée nécessite une expertise clinique et un consensus d'experts par pathologie
- La DLSS est sensible à la **granularité du codage** : avec des codes CCAM à 7 caractères (très fin), deux actes légèrement différents sont traités comme des substitutions même si cliniquement équivalents ; regrouper les actes par famille (CCAM chapitres, ATC niveau 3) réduit ce biais au prix d'une perte de précision
- La **complexité de calcul** est quadratique en O(n×m) — pour des séquences longues (parcours sur 24 mois avec des dizaines d'actes) et des cohortes larges (plusieurs milliers de patients), le calcul peut être coûteux ; des approximations (distance de Hamming pour séquences de même longueur, DTW pour séquences temporelles) peuvent être préférées à grande échelle
- La DLSS traite les actes comme des **symboles discrets** et ignore les dimensions temporelles (deux séquences identiques réalisées à 3 mois d'intervalle vs à 12 mois d'intervalle ont la même DLSS) — l'intégration de la dimension temporelle nécessite d'utiliser la Dynamic Time Warping (DTW) plutôt que la distance de Levenshtein standard

## Références

- [Levenshtein V.I. — Binary codes capable of correcting deletions, insertions, and reversals, Soviet Physics Doklady 1966 : article fondateur de la distance d'édition]
- [Needleman S.B., Wunsch C.D. — A general method applicable to the search for similarities in the amino acid sequence of two proteins, Journal of Molecular Biology 1970](https://doi.org/10.1016/0022-2836(70)90057-4) — généralisation en bioinformatique (alignement de séquences ADN)
- [Huang Z. et al. — Similarity measure between patient traces for clinical pathway analysis: problem, methods, and challenges, IEEE J Biomed Health Inform 2014](https://doi.org/10.1109/JBHI.2013.2274281) — application clinique de la distance d'édition aux parcours de soins
- [Bouarfa L., Dankelman J. — Workflow mining and outlier detection from clinical activity logs, J Biomed Inform 2012](https://doi.org/10.1016/j.jbi.2011.12.003)
- [INCa — Algorithmes de prise en charge par pathologie (cancer sein, colorectal, poumon)](https://www.e-cancer.fr/)
- [HAS — Parcours de soins des maladies chroniques : algorithmes décisionnels par ALD](https://www.has-sante.fr/)
