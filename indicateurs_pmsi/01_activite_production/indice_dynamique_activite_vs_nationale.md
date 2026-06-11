# Indice de Dynamique d'Activité vs Tendance Nationale (IDAN)

## Définition

L'IDAN mesure l'**écart de vitesse de croissance** entre l'activité MCO d'un établissement et la tendance nationale observée sur la même période et la même CMD. Il repose sur la différence de TCAM (Taux de Croissance Annuel Moyen sur 3 ans) entre l'établissement et le marché national — ce que la théorie de la dynamique de marchés (Henderson, BCG 1970) applique au pilotage hospitalier : un acteur croît « vite » ou « lentement » non pas en absolu, mais **relativement à l'évolution de son marché**.

**TCAM sur K années :**

**TCAM_(etab,c) = ( RSA_etab_(c,N) / RSA_etab_(c,N-K) )^(1/K) − 1**

**TCAM_(national,c) = ( RSA_national_(c,N) / RSA_national_(c,N-K) )^(1/K) − 1**

**Indice de Dynamique (en points de %) :**

**IDAN_(c) = TCAM_(etab,c) − TCAM_(national,c)**

où c désigne la CMD (ou la racine GHM pour une granularité fine), K = 3 ans (horizon stratégique standard), N = dernier exercice complet disponible.

**Interprétation :**
- IDAN_(c) > 0 → l'établissement croît plus vite que le marché national sur cette CMD : gain de dynamique relatif (pénétration croissante ou attractivité en hausse)
- IDAN_(c) < 0 → l'établissement croît moins vite que le marché : érosion relative (perte de parts de marché dynamiques, même si l'activité absolue augmente)
- IDAN_(c) = 0 → dynamique exactement alignée sur la tendance nationale

La différence avec `taux_croissance_activite_trimestrielle.md` (TCAT) est structurelle : le TCAT mesure la vitesse absolue de l'établissement sur un trimestre, sans référentiel externe. L'IDAN mesure la position **relative** sur un horizon stratégique de 3 ans. Un établissement avec TCAT = +3%/trimestre mais IDAN = −1,5 pt/an croît en absolu mais perd du terrain face au marché national — signal que la croissance observée ne suffit pas à maintenir le positionnement.

## Calcul

Sources : PMSI MCO RSA (ATIH) + PMSI national ATIH open data (séries longues par CMD) + SAE DREES (séries temporelles d'activité).

```
Paramètres :
  K = 3  (horizon TCAM en années — modifiable à 5 pour vision long terme)
  N = dernier exercice PMSI complet (ex. 2023 si calcul en 2025)
  N-K = N − 3 = exercice de référence (ex. 2020)

Étape 1 — Extraction des RSA de l'établissement par CMD sur N et N-K :
  RSA_etab_{(c,N)}   = COUNT(RSA) WHERE FINESS_GEO = etab AND CMD = c AND ANNEE = N
  RSA_etab_{(c,N-K)} = COUNT(RSA) WHERE FINESS_GEO = etab AND CMD = c AND ANNEE = N-K

  Variables PMSI utilisées :
    FINESS_GEO : identifiant établissement géographique
    GHM        : code GHM (8 car.) → CMD = SUBSTR(GHM, 1, 2)
    ANNEE      : année de sortie du séjour (dérivée de DATE_SORTIE)

  Convention : exclure CMD 90 (séances isolées si non pertinent) et CMD 28 (séances de dialyse)
               selon la définition d'activité retenue

Étape 2 — Extraction des RSA nationaux par CMD sur N et N-K :
  Source A (recommandée) : PMSI national ATIH open data
    RSA_national_{(c,N)}   = Σ_{tous étab} RSA_{(c,N)}  [fichier national par CMD et année]
    RSA_national_{(c,N-K)} = Σ_{tous étab} RSA_{(c,N-K)}

  Source B (alternative) : SAE DREES séries longues
    → Utiliser le nombre de séjours MCO par CMD publié annuellement
    → Moins précis car la SAE agrège public + privé avec des définitions parfois hétérogènes

  → Documenter la source retenue : l'écart entre source A et source B peut atteindre ±0,5 pt
    de TCAM national selon la couverture du champ

Étape 3 — Calcul des TCAM :
  TCAM_etab_{(c)}     = ( RSA_etab_{(c,N)} / RSA_etab_{(c,N-K)} )^(1/K) − 1
  TCAM_national_{(c)} = ( RSA_national_{(c,N)} / RSA_national_{(c,N-K)} )^(1/K) − 1

  Conventions cas limites :
    RSA_etab_{(c,N-K)} = 0 ET RSA_etab_{(c,N)} > 0  → activité créée ex nihilo
      TCAM_etab = NA (non calculable) ; reporter en "ouverture d'activité" — analyser séparément
    RSA_etab_{(c,N-K)} > 0 ET RSA_etab_{(c,N)} = 0  → activité arrêtée
      TCAM_etab = NA ; reporter en "fermeture d'activité"
    RSA_etab_{(c,N-K)} < 100  → TCAM instable (faible base) ; calculer avec flag « instable »

Étape 4 — Calcul de l'IDAN par CMD :
  IDAN_{(c)} = TCAM_etab_{(c)} − TCAM_national_{(c)}  [en points de %, ex. +2,1 pts]

Étape 5 — IDAN global (toutes CMD) :
  TCAM_etab_global     = ( RSA_etab_total_{(N)} / RSA_etab_total_{(N-K)} )^(1/K) − 1
  TCAM_national_global = ( RSA_national_total_{(N)} / RSA_national_total_{(N-K)} )^(1/K) − 1
  IDAN_global          = TCAM_etab_global − TCAM_national_global
```

Indicateurs dérivés :

```
1. Matrice de positionnement stratégique (BCG hospitalier) :
   Axe X : ÉA-SAE_{(c)} [position volumique vs pairs] — depuis ecart_activite_benchmark_sae.md
   Axe Y : IDAN_{(c)}   [dynamique relative vs marché national]

   Quadrants :
   ┌────────────────────┬────────────────────┐
   │  CHALLENGER        │  ÉTOILE            │
   │  IDAN > 0          │  IDAN > 0          │
   │  ÉA-SAE < 0        │  ÉA-SAE > 0        │
   │  (croît vite,      │  (croît vite et    │
   │   mais sous-vol)   │   déjà dominant)   │
   ├────────────────────┼────────────────────┤
   │  POIDS MORT        │  VACHE À LAIT      │
   │  IDAN < 0          │  IDAN < 0          │
   │  ÉA-SAE < 0        │  ÉA-SAE > 0        │
   │  (décroît et       │  (décroît mais     │
   │   sous-volume)     │   encore dominant) │
   └────────────────────┴────────────────────┘

   → Guide les arbitrages stratégiques CMD par CMD :
     Étoile    = investir et consolider
     Challenger = recruter ou partenariat pour accélérer
     Vache à lait = maintenir, surveiller l'érosion
     Poids mort = décision d'arrêt ou de reconversion

2. Score de convergence nationale (SCN) :
   SCN = COUNT(c | IDAN_{(c)} > 0) / COUNT(c actives) × 100
   SCN > 60% → plus de la moitié des CMD ont une dynamique supérieure au marché

3. IDAN pondéré par la valorisation T2A :
   IDAN_val_{(c)} = IDAN_{(c)} × (Recettes_T2A_{(c)} / Recettes_T2A_total)
   → Pondère les CMD selon leur contribution financière ; les CMD à forte valorisation
     avec IDAN négatif sont les plus critiques économiquement
```

## Utilité

- **Détecter l'érosion dynamique masquée par la croissance brute** : un établissement dont l'activité MCO croît de +1,5%/an en absolu peut simultanément perdre du terrain si le marché national progresse de +3,5%/an (IDAN = −2 pts) — ce signal n'est visible ni dans le volume absolu ni dans le TCAT, mais est directement actionnable pour la direction médicale (CMD concernées : diagnostic, arbitrage stratégique).
- **Arbitrer les investissements de développement par CMD lors du Plan Stratégique** : la matrice BCG hospitalière (IDAN × ÉA-SAE) classe les 28 CMD en 4 quadrants — les CMD « Étoile » bénéficient des investissements en lits, équipements et recrutements ; les CMD « Challenger » font l'objet d'un plan de rattrapage accéléré ; les « Poids mort » sont candidates à une réorganisation intra-GHT.
- **Identifier les CMD en risque de décrochage avant que le volume ne soit affecté** : un IDAN_(c) < −1 pt/an sur 2 exercices consécutifs est un signal précoce de décrochage (érosion progressive de la dynamique) qui précède de 2-3 ans la baisse visible du volume absolu — fenêtre d'intervention stratégique avant perte irréversible de capacité médicale.
- **Évaluer l'impact d'un recrutement médical ou d'une réorganisation de service** : si un chirurgien viscéral est recruté en N, l'IDAN CMD 6 (tube digestif) doit passer de négatif à positif en N+1/N+2 — critère de résultat objectif d'une décision de ressources humaines médicales, indépendant des variations du marché.
- **Préparer le volet activité des CPOM ARS** : l'IDAN global et par CMD fournit une narrative chiffrée sur la trajectoire de l'établissement : un IDAN global = +1,8 pt illustre une dynamique supérieure au marché justifiant des demandes capacitaires ; un IDAN global = −2,1 pts oblige à présenter un plan de redressement de l'attractivité.
- **Détecter les fuites d'activité vers le secteur privé ou vers un CHU concurrent** : si le marché national d'une CMD croît (+2%/an) mais que l'établissement recule (−1%/an, IDAN = −3 pts), les séjours existent dans le territoire mais vont ailleurs — croisement avec `taux_fuite_attractivite.md` et `parts_marche_territoire.md` pour identifier le bénéficiaire de la fuite.

## Sources de Données

- **PMSI MCO RSA** (ATIH) : variables `FINESS_GEO`, `GHM` (8 car. → CMD sur 2 car.), `DATE_SORTIE` (→ ANNEE) — extractions sur 4 exercices complets (N-3, N-2, N-1, N) pour calculer K=3 et vérifier la stabilité.
- **PMSI national ATIH open data** : fichiers de statistiques nationales MCO par CMD et par année — source recommandée pour `RSA_national_(c,N)` et `RSA_national_(c,N-K)`. Disponible sur opendata.atih.sante.fr avec un délai de publication de 12-18 mois.
- **SAE DREES séries longues** : tableau « séjours MCO par CMD » sur plusieurs années, disponible sur data.drees.fr — source alternative si l'open data ATIH n'est pas encore disponible pour l'exercice le plus récent. Hétérogénéité possible avec le PMSI local pour les séjours de séances.
- **Référentiel GHM ATIH** : table de correspondance GHM (8 car.) → CMD (2 car.) → libellé — indispensable pour le regroupement et la présentation médicale des résultats par spécialité.

## Exemple de Valeurs

| CMD | TCAM_etab | TCAM_national | IDAN | Quadrant BCG |
|---|---|---|---|---|
| CMD 5 – Appareil circulatoire | +4,2%/an | +2,1%/an | +2,1 pts | Étoile (si ÉA-SAE > 0) |
| CMD 8 – Orthopédie | +1,0%/an | +3,5%/an | −2,5 pts | Vache à lait ou Poids mort |
| CMD 14 – Obstétrique | −1,5%/an | −0,8%/an | −0,7 pts | Signal de vigilance |
| CMD 1 – SNC | +5,0%/an | +2,8%/an | +2,2 pts | Challenger → Étoile |
| CMD 6 – Tube digestif | −3,0%/an | +1,5%/an | −4,5 pts | Poids mort — action urgente |

**IDAN global par type d'établissement :**
- CHU en développement de recours spécialisé : IDAN global +1,5 à +3 pts
- CH polyvalent stable : IDAN global −0,5 à +0,5 pts (aligné sur le marché)
- CH en décroissance structurelle : IDAN global −2 à −4 pts
- Clinique MCO avec stratégie ambulatoire agressive : IDAN global +2 à +5 pts

**Seuils opérationnels :**
- IDAN_(c) > +2 pts sur 2 exercices consécutifs → CMD en sur-dynamique — surveiller la soutenabilité (capacité, codage)
- IDAN_(c) < −1 pt sur 2 exercices consécutifs → CMD en décrochage — déclenchement d'analyse
- IDAN_(c) < −3 pts sur 1 exercice → signal d'alerte immédiate (restructuration, fermeture, fuite)
- Volume minimal : RSA_etab_(c,N-K) ≥ 100 pour TCAM stable ; < 100 → valeur calculée mais non publiée

## Limites

- **Sensibilité aux restructurations discontinues** : une fusion-absorption, une fermeture de service ou un transfert d'activité intra-GHT entre N-K et N crée un IDAN artificiellement extrême (positif ou négatif) qui ne reflète pas la dynamique organique de l'établissement. Documenter tout événement structurel sur la période et exclure les CMD concernées de l'interprétation automatisée.
- **Délai de publication du PMSI national** : les données nationales ATIH open data sont disponibles avec 12-18 mois de décalage. En 2025, l'IDAN calculé sur K=3 utilise la fenêtre 2020-2022 pour le national et 2020-2023 pour le local (si disponible) — décalage d'un an qui peut biaiser la comparaison si le marché national a connu un choc en 2023 (post-COVID, grève, etc.). Vérifier l'alignement temporel exact des deux sources.
- **Changement de version de la classification GHM** : le passage d'une version GHM à une autre (ex. v11 → v12) modifie la définition de certaines CMD et le périmètre de rattachement de certains GHM. Un TCAM calculé sur une période straddling un changement de version doit être recalculé sur la classification homogène — sans cette précaution, le TCAM intègre l'effet de reclassification comme une variation d'activité.
- **Asymétrie public/privé dans le PMSI national** : le champ du PMSI national MCO inclut les établissements ex-DG (public, ESPIC) et ex-OQN (privé commercial) depuis 2012. Cependant, la couverture et les règles de codage diffèrent selon les secteurs. Un TCAM national calculé sur l'ensemble peut être dominé par la dynamique du secteur privé, peu représentative pour un CH public. Calculer le TCAM national sur le champ public seul si l'établissement est public.
- **Horizon K = 3 : sensibilité aux années atypiques** : l'année N-K de référence peut être une année atypique (ex. 2020 = COVID, 2021 = rattrapage post-COVID) — le TCAM 2020-2023 est biaisé par cet effet. Calculer un IDAN alternatif sur K=5 (2018-2023, neutralisant l'effet COVID) et présenter les deux valeurs pour les CMD les plus sensibles.
- **Non-neutralisation de l'effet démographique** : l'IDAN compare des TCAM bruts. Si le bassin de population de l'établissement vieillit plus vite que la moyenne nationale, une partie du sur-dynamique (IDAN > 0) sur les CMD médicales est mécanique (plus de patients âgés, plus de séjours médicaux). Croiser avec le TRHS (`taux_recours_hospitalier_standardise_age_sexe.md`) pour séparer dynamique démographique et dynamique de recours.

## Références

- [Henderson B.D. — The Product Portfolio, BCG Perspectives 1970 : fondements de la matrice croissance-part de marché (BCG) transposée ici à la dynamique d'activité hospitalière par CMD](https://www.bcg.com/publications/1970/strategy-the-product-portfolio)
- [DREES — Les établissements de santé : séries longues d'activité MCO par CMD (éditions annuelles)](https://drees.solidarites-sante.gouv.fr/etablissements-de-sante)
- [ATIH — PMSI MCO open data national : statistiques d'activité par établissement, CMD et année](https://www.scansante.fr/)
- [Véga A. et al. — Analyse des variations de l'activité hospitalière en France, Questions d'économie de la santé IRDES 2021](https://www.irdes.fr/)
- [Goldstein H., Spiegelhalter D.J. — League tables and their limitations: statistical issues in comparisons of institutional performance, Journal of the Royal Statistical Society A, 1996](https://doi.org/10.2307/2983325)
- [ANAP — Tableau de bord de pilotage médico-économique : indicateurs d'évolution d'activité et de part de marché](https://www.anap.fr/)
- [Porter M.E. — Competitive Strategy: Techniques for Analyzing Industries and Competitors, Free Press 1980 — fondements de l'analyse dynamique de positionnement concurrentiel]
