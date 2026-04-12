# Entropie de Shannon du Casemix

## Définition

L'entropie de Shannon H, issue de la théorie de l'information (Claude Shannon, 1948), mesure la diversité ou l'incertitude d'une distribution de probabilités. Appliquée à la distribution des GHMs (Groupes Homogènes de Malades) d'un service ou d'un établissement, elle quantifie le degré de **spécialisation vs polyvalence** du casemix hospitalier.

H = −Σᵢ pᵢ × log₂(pᵢ)

où pᵢ est la proportion du GHM i dans le total des séjours du service ou de l'établissement sur la période. H est exprimée en bits (si log₂) ou en nats (si ln). L'entropie est maximale (H_max = log₂(N_GHM)) lorsque tous les GHMs sont également représentés (service totalement polyvalent) et minimale (H = 0) lorsqu'un seul GHM concentre toute l'activité (service mono-pathologique).

Pour faciliter les comparaisons inter-services disposant de volumes différents, l'entropie normalisée H' = H / H_max (comprise entre 0 et 1) est préférable : H' = 1 correspond à une diversité maximale, H' = 0 à une spécialisation absolue.

Cet indicateur est fondamentalement absent des outils PMSI actuels : le CMI (Case Mix Index) mesure la lourdeur moyenne du casemix mais pas sa diversité structurelle ; le nombre de GHMs différents ne pondère pas par les volumes. L'entropie capture une information qualitativement différente — la **structure** de répartition de l'activité — inatteignable par les indicateurs scalaires classiques.

## Calcul

Source : PMSI MCO RSA — variable GHM (8 caractères) par séjour.

```
Population : tous les séjours MCO d'un service ou d'un établissement
             sur la période d'analyse (trimestre ou année civile)

Étape 1 — Distribution des GHMs :
  N_total = nombre total de séjours dans la période
  N_i     = nombre de séjours du GHM i
  p_i     = N_i / N_total  (proportion du GHM i)

Étape 2 — Entropie brute :
  H = −Σᵢ p_i × log₂(p_i)
  Convention : 0 × log₂(0) = 0 (limite mathématique)
  Unité : bits
  Plage : [0 ; log₂(nombre de GHMs distincts observés)]

Étape 3 — Entropie normalisée :
  H_max = log₂(N_GHM_distincts)
  H'    = H / H_max
  Plage : [0 ; 1]
  H' proche de 1 = casemix très polyvalent
  H' proche de 0 = casemix très concentré / spécialisé

Étape 4 — Granularité du groupage :
  Option A : GHM complet (8 car.) → entropie maximalement sensible
  Option B : Racine GHM (6 car., sans niveau de sévérité) → moins sensible
             aux variations de codage de comorbidités
  Option C : CMD (2 car.) → vision grands ensembles, moins fine
  → Recommandation : utiliser la racine GHM (6 car.) pour le benchmarking
    inter-établissements (neutralise les effets de codage des CMA)
```

Indicateurs dérivés :

```
Dérive d'entropie (drift) :
  ΔH' = H'(N) − H'(N-1)
  ΔH' < 0 → spécialisation croissante (concentration sur moins de GHMs)
  ΔH' > 0 → diversification (ouverture à de nouveaux GHMs)

Entropie par CMD (Command Medical Domain) :
  Calculer H' séparément pour chaque CMD active du service
  → Distinguer la polyvalence inter-CMDs (diversité des grandes familles)
    de la polyvalence intra-CMD (diversité au sein d'une spécialité)

Comparaison entropie observée vs entropie attendue par type d'établissement :
  → CHU : H' attendue ~0,75-0,85 (très polyvalent)
  → CH général : H' attendue ~0,65-0,75
  → Clinique spécialisée : H' attendue ~0,20-0,40
  → Écart à la norme de type = signal de sur- ou sous-spécialisation
```

## Utilité

- **Mesurer objectivement la spécialisation stratégique d'un service** : un service d'orthopédie avec H' = 0,25 (très concentré sur PTH/PTG) et un autre avec H' = 0,65 (orthopédie générale) ont des profils stratégiques, économiques et de ressources humaines fondamentalement différents que le CMI seul ne distingue pas
- **Détecter les dérives de casemix** : une baisse de H' sur 3 ans dans un service de médecine interne signale une spécialisation progressive (possiblement non décidée) vers quelques pathologies au détriment de la polyvalence initiale — information utile pour la gouvernance médicale et la révision des projets de service
- **Appuyer les demandes d'autorisation d'activité** : un H' très faible sur une spécialité (ex. H' = 0,15 en neurochirurgie vasculaire) est l'argument quantitatif d'une expertise concentrée qui justifie une autorisation d'activité spécifique
- **Optimiser la mutualisation au sein du GHT** : comparer les entropies des services similaires entre établissements du GHT identifie les services qui se chevauchent (H' élevées similaires = risque de doublon) et ceux qui se complètent (H' faibles sur des GHMs distincts = complémentarité)
- **Calibrer les besoins en formation continue** : un service à H' élevée nécessite des soignants avec des compétences larges (formation généraliste) ; un service à H' faible peut concentrer sa formation continue sur les protocoles des rares GHMs dominants
- **Indicateur de recherche et d'enseignement** : pour un CHU, la diversité du casemix (H' élevée) est une condition de la richesse pédagogique du terreau de stage — l'entropie peut être utilisée comme indicateur de qualité des terrains de formation en collaboration avec l'université

## Sources de Données

- **PMSI MCO RSA** : variable GHM (8 caractères), service médical (UM), FINESS géographique — extraction annuelle ou trimestrielle selon la granularité souhaitée
- **Référentiel ATIH des GHMs** : correspondance GHM → CMD → libellé, indispensable pour les analyses par groupe nosologique et la présentation des résultats aux équipes médicales
- **Tables de structure ATIH** : nombre total de GHMs actifs par version de la classification (v11, v12...) — nécessaire pour calculer H_max théorique si on veut normaliser sur tous les GHMs possibles plutôt que sur les seuls GHMs observés

## Exemple de Valeurs

- **CHU polyvalent (all specialties)** : H' ≈ 0,78-0,85 (casemix très diversifié, quasi-maximal)
- **CH général 500 lits** : H' ≈ 0,65-0,72
- **Service de chirurgie orthopédique programmée** : H' ≈ 0,20-0,35 (PTH, PTG, arthroscopies dominent)
- **Service de neurochirurgie** : H' ≈ 0,30-0,45 (quelques GHMs lourds concentrent l'activité)
- **Service de médecine interne polyvalente** : H' ≈ 0,70-0,80
- **Clinique bariatrique mono-activité** : H' ≈ 0,05-0,15 (un seul GHM domine à >80%)
- **Valeur de dérive d'alerte** : ΔH' > ±0,05 sur deux années consécutives pour un même service = signal d'analyse de la dynamique stratégique

## Limites

- L'entropie est sensible au volume total de séjours : un service avec peu de séjours (< 200/an) aura une entropie instable d'une année à l'autre par simple variabilité statistique — recommander un seuil minimal de 500 séjours sur la période pour une interprétation fiable
- L'entropie normalisée H' dépend du nombre de GHMs distincts observés : un service qui n'a vu que 15 GHMs distincts et un autre qui en a vu 150 ont des H_max très différents — la comparaison directe des H' brutes entre services de taille très différente est à faire avec précaution
- L'entropie ne distingue pas la polyvalence subie (service sous-dimensionné qui accepte tout faute de spécialistes) de la polyvalence choisie (service de médecine interne délibérément généraliste) — l'interprétation clinique des valeurs extrêmes nécessite un dialogue avec les équipes médicales
- Les changements de version de la classification ATIH (ex. passage GHM v11 → v12) modifient le nombre et la définition des GHMs, rendant les comparaisons inter-annuelles difficiles sans recodage rétrospectif

## Références

- [Shannon C.E. — A Mathematical Theory of Communication, Bell System Technical Journal 1948](https://doi.org/10.1002/j.1538-7305.1948.tb01338.x)
- [Jost L. — Entropy and diversity, Oikos 2006 : fondements mathématiques de l'entropie comme mesure de diversité](https://doi.org/10.1111/j.2006.0030-1299.14714.x)
- [Gibberd R.W. et al. — Measuring diversity of hospital activity, Health Services Research 2005 : application de l'entropie de Shannon à l'analyse du casemix hospitalier]
- [ATIH — Classification des GHMs et guide de lecture du PMSI MCO (version en vigueur)](https://www.atih.sante.fr/)
- [Luft H.S., Garnick D.W. — Hospital volume, physician volume and patient outcomes, Health Services Research 1990 : lien entre concentration d'activité (faible entropie) et outcomes cliniques]
