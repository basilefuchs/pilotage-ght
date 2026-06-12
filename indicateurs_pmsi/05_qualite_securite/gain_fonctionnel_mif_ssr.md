# Gain Fonctionnel MIF (Delta Entrée-Sortie SSR)

## Définition

La MIF (Mesure de l'Indépendance Fonctionnelle), version française du FIM (Functional Independence Measure), est un score standardisé évaluant le niveau d'autonomie fonctionnelle du patient. **Attention : la MIF n'est pas recueillie dans la base nationale PMSI SMR** (aucune variable MIF au dictionnaire ATIH) — elle n'est disponible que si l'établissement la cote dans son dossier de rééducation. Le RHS recueille en revanche les **dépendances AVQ** (6 items cotés 1-4, score 6-24 : `alim`, `comport`, `conti`, `habill`, `loco`, `rel`, agrégés en `dep_phys`/`dep_cogn`), à chaque séquence hebdomadaire — elles fournissent l'équivalent calculable du gain fonctionnel sur la base nationale. Score MIF total : 18 à 126 points, composé de 18 items répartis en deux domaines :

- **Domaine moteur** (13 items, max 91 points) : soins personnels (alimentation, hygiène, habillage, toilette périnéale), contrôle sphinctérien, mobilité/transferts, locomotion
- **Domaine cognitif** (5 items, max 35 points) : compréhension, expression, conscience sociale, résolution de problèmes, mémoire

Chaque item est coté de 1 (dépendance totale — aide totale requise) à 7 (indépendance complète sans assistance). Seuils cliniques : MIF < 36 = dépendance totale/très sévère ; MIF 36-72 = dépendance modérée ; MIF 73-107 = dépendance légère ; MIF ≥ 108 = quasi-indépendance.

Le **gain fonctionnel MIF** = MIF_sortie − MIF_entrée mesure la valeur ajoutée clinique réelle du séjour SSR. C'est l'indicateur de résultat clinique le plus direct et le plus objectif du SSR. L'**efficience rééducative** (gain MIF par jour de séjour) permet de comparer la productivité des programmes de rééducation entre unités ou établissements, en neutralisant l'effet de la durée de séjour.

## Calcul

Deux modes de calcul selon la source :

- **Données locales** (MIF cotée dans le dossier de rééducation) : MIF_entrée (1er RHS du séjour) et MIF_sortie (dernier RHS) — les formules ci-dessous s'appliquent telles quelles.
- **Base nationale ATIH** (pas de MIF) : équivalent AVQ — score de dépendance = somme des 6 cotations AVQ (6-24) ou agrégats `dep_phys` + `dep_cogn`, comparé entre la première et la dernière séquence du séjour (delta négatif = gain d'autonomie, l'échelle AVQ croît avec la dépendance). Transposer les formules en remplaçant MIF par le score AVQ inversé.

Population éligible :

```
Population cible :
  → Séjours SSR avec MIF_ENT et MIF_SOR tous deux renseignés
    et dans les plages valides (18 ≤ MIF ≤ 126)
  → Exclusions :
      - Décès en cours de séjour (MIF_SOR non pertinente cliniquement)
      - Séjours < 7 jours (durée insuffisante pour une rééducation mesurable)
      - MIF_ENT = 126 (score maximum à l'entrée = pas de marge de progression,
        admission SSR à questionner)
```

Formules principales :

```
1. Delta MIF absolu :
   ΔMif = MIF_SOR − MIF_ENT
   → Positif  = amélioration fonctionnelle
   → Nul      = stabilisation (maintien de l'autonomie)
   → Négatif  = dégradation fonctionnelle (signal d'alerte hors soins palliatifs)

2. Efficience rééducative :
   Efficience = ΔMif / Durée de séjour (jours)
   → Exprimée en points de MIF gagnés par jour
   → Référence nationale : ~0.8-1.5 points/jour selon GME

3. Taux de récupération relative (TRR) :
   TRR (%) = (MIF_SOR − MIF_ENT) / (126 − MIF_ENT) × 100
   → Exprimé en % du potentiel de gain théorique maximal
   → Neutralise l'effet du niveau fonctionnel initial (patients très atteints ont
     un delta absolu élevé mais un TRR potentiellement faible)
```

Sous-indicateurs de résultat :

```
Indicateurs binaires cliniquement significatifs :
  → Proportion de séjours avec ΔMif > 0 (amélioration)
  → Proportion de séjours avec ΔMif ≥ 10 (amélioration cliniquement significative,
    seuil Dodds 1993)
  → Proportion de séjours avec MIF_SOR ≥ 80 (seuil associé au retour domicile
    sans aide majeure selon littérature)
  → Proportion de séjours avec MIF_SOR ≥ MIF_ENT (stabilisation ou amélioration)
  → Proportion de dégradation (ΔMif < −5, hors GME soins palliatifs) — indicateur
    de sécurité en SSR

Sous-indicateurs par domaine :
  → ΔMif moteur seul (items 1-13, max progression +78 pts)
  → ΔMif cognitif seul (items 14-18, max progression +30 pts)
  → Utile pour les AVC : dissocier récupération motrice vs cognitive
```

## Utilité

- **Mesurer la valeur ajoutée clinique du SSR** : le delta MIF est la démonstration chiffrée que la rééducation a amélioré l'autonomie fonctionnelle du patient — c'est l'argument clinique central du SSR dans son dialogue avec les financeurs et les prescripteurs MCO
- **Benchmarking inter-unités et inter-établissements** : l'efficience MIF/jour permet de comparer les programmes de rééducation entre unités d'un même GHT en neutralisant les différences de durée de séjour ; le TRR permet de comparer des patients avec des niveaux fonctionnels initiaux très différents
- **Optimiser la durée de séjour SSR** : la courbe de récupération MIF suit généralement un profil sigmoïde (gain rapide dans les premières semaines, puis plateau) ; l'analyse longitudinale des MIF hebdomadaires permet d'identifier le moment où le plateau est atteint et la sortie peut être organisée
- **Identifier les patients à faible gain malgré séjour long** : ΔMif/jour < 0.3 après 3 semaines de rééducation = signal de révision du projet thérapeutique (obstacle non identifié : dépression, douleur chronique, trouble cognitif, facteur social)
- **Argument pour la certification HAS et les CPOM ARS** : le gain MIF est un indicateur de résultat directement mesurable qui démontre la qualité des soins de rééducation et leur impact sur l'autonomie des patients
- **Corrélation prédictive avec le retour à domicile** : MIF_SOR ≥ 80 est le meilleur prédicteur individuel d'un retour à domicile réussi ; l'indicateur permet d'anticiper les décisions de sortie et de préparer les filières médico-sociales en conséquence

## Sources de Données

- **PMSI SMR RHS (base nationale)** : cotations de dépendance AVQ par séquence (`alim`, `comport`, `conti`, `habill`, `loco`, `rel`, `dep_phys`, `dep_cogn`), GME, FP (finalité principale de prise en charge), dates d'entrée/sortie du séjour, chaînage `anonyme` — **pas de variable MIF**
- **Dossier de rééducation local** : scores MIF entrée/sortie si l'établissement les cote (mode MIF des formules)
- **Référentiel ATIH** : distributions nationales de dépendance AVQ par GME publiées dans les statistiques annuelles SMR
- **Guide méthodologique ATIH PMSI SSR** : définition précise des 18 items MIF, modalités de cotation dans le RHS, règles de complétude

## Exemple de Valeurs

- **AVC (neurologie cérébro-lésée)** : ΔMif moyen ~20-35 points selon sévérité initiale ; efficience ~0.8-1.2 pts/jour ; MIF_ENT typique ~55-75, MIF_SOR ~80-100
- **PTH/PTG (locomoteur)** : ΔMif moyen ~15-25 points, DMS ~15-25 jours, efficience ~1.0-1.5 pts/jour
- **Fracture du col du fémur** : ΔMif moyen ~10-20 points ; MIF_ENT ~45-65 (dépendance post-fracture)
- **Gériatrie polyvalente** : ΔMif moyen ~5-15 points ; efficience ~0.4-0.8 pts/jour (population âgée, polypathologie, gains plus modestes mais cliniquement importants)
- **Seuil cliniquement significatif** : ΔMif ≥ 10 points (Dodds et al. 1993, validé dans de multiples populations SSR)
- **Seuil retour domicile** : MIF_SOR ≥ 80 points associé à retour domicile sans aide majeure dans ~70-80% des cas

## Limites

- La MIF est cotée par les soignants (ergothérapeute, kinésithérapeute, infirmière) — variabilité inter-cotateurs documentée, avec un risque de biais de désirabilité sociale (gonflement possible du score de sortie dans certaines équipes) ; la formation à la cotation standardisée et les audits de concordance inter-cotateurs sont essentiels
- La MIF ne capture pas la qualité de vie, la douleur, la fatigue, ni la récupération cognitive fine pour les AVC (aphasie, héminégligence, syndrome dysexécutif) — indicateur à compléter par des outils spécifiques (NIHSS, Rankin, MoCA) dans les filières neurologiques
- Le score MIF à l'entrée SSR est influencé par le délai MCO→SSR : une admission SSR tardive (> J7) laisse une récupération spontanée précoce déjà intégrée dans le score d'entrée, réduisant artificiellement le delta SSR apparent — le délai MCO→SSR (indicateur SSR-1) doit être lu conjointement
- Complétude variable selon les établissements : le renseignement des MIF entrée et sortie n'est pas exhaustif dans tous les SSR ; un taux de complétude < 80% doit conduire à interpréter l'indicateur avec prudence
- **L'équivalent AVQ de la base nationale est moins sensible que la MIF** : 6 items cotés 1-4 (score 6-24) contre 18 items cotés 1-7 (18-126) — les seuils cliniques de la littérature MIF (Dodds, retour domicile ≥ 80) ne se transposent pas directement ; comparer en distribution (quartiles de delta AVQ par GME) plutôt qu'en seuils absolus

## Références

- [Dodds T.A. et al. — A validation of the functional independence measure and its performance among rehabilitation inpatients, Arch Phys Med Rehabil 1993](https://doi.org/10.1016/0003-9993(93)90119-U)
- [Granger C.V. et al. — Functional Assessment Scales: a study of persons with multiple sclerosis, Arch Phys Med Rehabil 1990 (PMID 2222154)](https://pubmed.ncbi.nlm.nih.gov/2222154/)
- [ATIH — Guide méthodologique du recueil d'informations médicalisé en SSR (PMSI RHS, cotation MIF)](https://www.atih.sante.fr/)
- [HAS — Recommandations de bonne pratique : rééducation après AVC, évaluation fonctionnelle et MIF (2012)](https://www.has-sante.fr/)
- [Prvu Bettger J., Stineman M.G. — Effectiveness of multidisciplinary rehabilitation services in postacute care, Arch Phys Med Rehabil 2007](https://doi.org/10.1016/j.apmr.2007.06.768)
