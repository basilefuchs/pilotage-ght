# Indice d'Allométrie Volume-Complexité

## Définition

L'allométrie est la relation de mise à l'échelle entre deux variables biologiques d'un organisme, formalisée par une loi de puissance : Y = a · X^β. La loi de Kleiber (1932) en est l'exemple canonique — le métabolisme basal des mammifères croît comme la masse corporelle à la puissance 3/4, et non linéairement. West, Brown et Enquist (1997) ont généralisé ce principe aux réseaux de distribution biologiques : les relations allométriques en β ≠ 1 révèlent des contraintes structurelles profondes, non réductibles à un simple rapport de proportionnalité.

Transposé à l'activité hospitalière, l'indice d'allométrie volume-complexité mesure la **relation de mise à l'échelle entre le volume de séjours et la sévérité moyenne** par famille GHM, sur un panel d'établissements :

```
log(sévérité_moy_f,e) = α_f + β_f · log(nb_RSA_f,e) + ε_f,e
```

où f désigne la famille GHM (racine 5 caractères), e l'établissement, et β_f l'exposant allométrique spécifique à cette famille.

- **β_f > 1** (superlinéarité) : la complexité des cas croît plus vite que le volume — les établissements à fort volume attirent des cas proportionnellement plus lourds sur cette famille (effet de recours). Analogue aux villes qui concentrent disproportionnellement les activités créatives à mesure qu'elles grandissent (loi d'échelle urbaine de Bettencourt 2007).
- **β_f = 1** (isométrie) : croissance linéaire — la complexité est indépendante du volume, chaque établissement voit le même mix de sévérité quelle que soit sa taille.
- **β_f < 1** (sublinéarité) : la sévérité relative diminue avec le volume — les grands volumes absorbent proportionnellement plus de cas légers (économies de gamme, effet centre de référence qui normalise son casemix).

Cet indicateur est absent des outils PMSI actuels : le CMI (Case Mix Index) mesure la lourdeur absolue mais ne modélise pas sa relation au volume ; l'indice de lourdeur des cas (ILC) est un ratio non scalé ; aucun indicateur existant ne teste si la relation volume-complexité est linéaire ou non.

## Calcul

Source : PMSI MCO RSA — variables `ghm2` (6 caractères), `finessgeo`, période annuelle.

```
Population : panel d'établissements MCO sur une année civile
             (minimum 20 établissements avec activité non nulle sur la famille f)

Étape 1 — Construction de la variable de sévérité :
  Sévérité CMA : utiliser le niveau de sévérité GHM (6e caractère du GHM à 6 car.)
  score_sev_RSA ∈ {1, 2, 3, 4} (niveaux J, T, U, E pour les GHMs à 4 niveaux)
  Pour GHMs sans niveau (chirurgie ambulatoire, séances) : score_sev = 1 par convention

  sév_moy_f,e = Σ(score_sev_RSA) / nb_RSA_f,e
  → variable continue ∈ [1 ; 4]

Étape 2 — Log-transformation :
  log_sev_f,e   = log(sév_moy_f,e)
  log_vol_f,e   = log(nb_RSA_f,e)

Étape 3 — Régression OLS par famille GHM (panel établissements) :
  Modèle : log_sev_f,e = α_f + β_f · log_vol_f,e + ε_f,e
  Estimateurs : MCO, erreurs standards robustes (HC3)
  Critère d'inclusion : nb_RSA_f,e ≥ 30 pour l'établissement e sur la famille f

  Sorties :
    β_f       : exposant allométrique ± IC 95%
    R²_f      : qualité d'ajustement du modèle allométrique
    p-value   : test β = 1 (test t bilatéral sur H0: β_f = 1)

Étape 4 — Score allométrique par établissement :
  résidu_f,e = log_sev_f,e − (α_f + β_f · log_vol_f,e)
  > 0 : complexité observée > attendue pour ce volume (case-mix plus lourd que prévu)
  < 0 : complexité observée < attendue (case-mix plus léger que prévu)

  Ce résidu est comparable entre établissements et entre années,
  indépendamment de la taille absolue de l'établissement.

Cas limites :
  - Si nb_établissements avec nb_RSA_f,e ≥ 30 < 20 : famille f non analysable
  - Si R²_f < 0,10 : relation allométrique non significative sur cette famille
    → interpréter β_f avec précaution
  - Division par zéro : exclure les établissements sans activité sur f
```

Indicateurs dérivés :

```
β_f moyen toutes familles (β_global) :
  = médiane pondérée de β_f par le volume national de la famille f
  β_global > 1 : signal systémique d'effet de recours (grandes structures plus lourdes)
  β_global < 1 : signal de normalisation (grandes structures lèvent les cas légers)

Trajectoire allométrique (β_f par année) :
  Mesurer β_f sur 3 ans successifs
  β croissant : la concentration des cas lourds vers les gros volumes s'accentue
  β décroissant : homogénéisation du casemix entre établissements de volumes différents

Score de surcharge allométrique d'un établissement :
  = nb de familles GHM avec résidu_f,e > +1 écart-type du panel
  → nombre de familles sur lesquelles l'établissement est disproportionnellement lourd
```

## Utilité

- **Benchmark volume-complexité équitable** : comparer la sévérité entre un CH de 300 lits et un CHU sur la même famille GHM sans tenir compte de leur différence de volume est biaisé si β ≠ 1 ; le résidu allométrique fournit une comparaison corrigée du volume, équivalent d'un Z-score contextualisé
- **Identification des établissements en tension de recours** : un résidu positif élevé sur plusieurs familles signale un établissement qui absorbe des cas plus lourds que son volume ne le prédit — tension potentielle sur les ressources humaines et matérielles, sous-financement si le poids GHM ne compense pas
- **Calibration des seuils de volume d'autorisation** : si β_f > 1 pour la chirurgie oncologique (CMD 17), les grands volumes concentrent disproportionnellement les cas complexes — argument pour rehausser les seuils minimaux d'autorisation sur cette famille
- **Détection des dérives de recrutement** : une trajectoire de résidu croissant sur 3 ans sans croissance du volume correspondant signale un glissement vers des cas plus lourds, potentiellement lié à la fermeture de concurrents ou à un changement de politique d'admission
- **Négociation des financements MERRI et soins de recours** : l'exposant β élevé sur les familles de recours (greffes, neurochirurgie, cardiologie interventionnelle) justifie des surfinancements structurels liés à la complexité systémique et non aux seuls volumes
- **Recherche de services** : identifier les familles GHM à β_f < 0,80 dans l'établissement — ces familles voient leur complexité diminuer avec le volume, signal d'une activité de routine normalisée sur laquelle une délégation ou une ambulatoire accrue est envisageable

## Sources de Données

- **PMSI MCO RSA** : variable `ghm2` (6 caractères — 6e caractère pour le niveau de sévérité), `finessgeo`, période annuelle — extraction sur panel national (base nationale ATIH ou données régionales ARS)
- **Référentiel ATIH des GHMs** : correspondance GHM → niveau de sévérité (J/T/U/E) → poids relatif — nécessaire pour vérifier que les niveaux de sévérité sont comparables entre versions de classification
- **Base nationale PMSI ATIH** : pour construire le panel d'établissements (minimum 20 établissements actifs par famille GHM) et calculer les paramètres allométriques nationaux de référence

## Exemple de Valeurs

- **CMD 05 (Affections de l'appareil circulatoire) — panel national** : β = 1,12 (IC 95% [1,08 ; 1,16]) — superlinéaire : les CHU voient des cas cardiovasculaires proportionnellement plus lourds — R² = 0,41
- **CMD 08 (Orthopédie-traumatologie) — chirurgie programmée** : β = 0,88 (IC 95% [0,84 ; 0,92]) — sublinéaire : les grands volumes ont un casemix plus standardisé (PTH/PTG de niveau 1 dominant)
- **CMD 01 (Neurologie) — panel national** : β = 1,05 (p = 0,04 pour H0: β = 1) — légèrement superlinéaire
- **Résidu allométrique d'alerte** : résidu > +1,5 σ sur ≥ 3 familles GHM simultanément → signal de surcharge de recours non compensée financièrement
- **R² minimal d'interprétation** : R²_f > 0,15 recommandé pour conclure à une structure allométrique sur la famille f ; en dessous, la relation volume-complexité est trop hétérogène sur le panel

## Limites

- **Sensibilité au codage des comorbidités** : le niveau de sévérité GHM est directement déterminé par la présence de CMA (complications et morbidités associées) en diagnostic associé ; un codage des DA insuffisant dans certains établissements crée un biais vers des niveaux de sévérité sous-estimés, faussant β vers zéro
- **Hétérogénéité des pratiques de niveau** : pour certaines familles GHM, le passage de niveau 1 à niveau 2 dépend de codes CIM-10 codés de manière très variable entre établissements (ex. dénutrition, obésité) — contrôler la qualité de codage avant toute interprétation
- **Taille de panel requise** : β n'est interprétable que si le panel comprend au moins 20 établissements avec ≥ 30 séjours sur la famille — les familles GHM rares (greffes, chirurgie robotique) ne sont pas allométriquement modélisables sur un panel régional
- **Stabilité temporelle** : les changements de version ATIH (GHM v11 → v12) reconfigurent les niveaux de sévérité et peuvent faire changer β d'une année à l'autre sans changement réel de pratiques ; utiliser une série homogène sur une même version
- **Non-causalité** : β > 1 ne prouve pas que les gros établissements *attirent* les cas lourds — la relation peut refléter une géographie (CHU en centre urbain avec population plus comorbide) ; toujours croiser avec l'indice d'Elixhauser ou de Charlson

## Références

- [West G.B., Brown J.H., Enquist B.J. — A general model for the origin of allometric scaling laws in biology, Science 1997 : fondements théoriques des lois de puissance en biologie](https://doi.org/10.1126/science.276.5309.122)
- [Bettencourt L.M.A. et al. — Growth, innovation, scaling, and the pace of life in cities, PNAS 2007 : extension des lois allométriques aux systèmes socio-économiques (villes)](https://doi.org/10.1073/pnas.0610172104)
- [Kleiber M. — Body size and metabolism, Hilgardia 1932 : loi de Kleiber originale sur l'allométrie métabolique]
- [Dranove D., Shanley M., Simon C. — Is hospital competition wasteful?, RAND Journal of Economics 1992 : relation volume-qualité/complexité en économie hospitalière]
- [ATIH — Classification des GHMs, guide méthodologique PMSI MCO, version en vigueur](https://www.atih.sante.fr/)
