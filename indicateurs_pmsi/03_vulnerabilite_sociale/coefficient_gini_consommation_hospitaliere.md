# Coefficient de Gini de la Consommation Hospitalière

## Définition

Le coefficient de Gini, développé par l'économiste Corrado Gini en 1912 pour mesurer les inégalités de revenus dans une population, se définit comme le rapport entre l'aire de la courbe de Lorenz et l'aire du triangle de parfaite égalité. Transposé à la consommation hospitalière, le **Gini de consommation hospitalière** mesure le degré d'inégalité dans la distribution des hospitalisations (ou des dépenses de santé) sur un territoire : dans quelle mesure les séjours hospitaliers sont-ils concentrés sur un petit nombre de patients grands consommateurs, ou au contraire répartis de façon homogène dans la population ?

G = 1 − 2 × ∫₀¹ L(x) dx

où L(x) est la courbe de Lorenz : L(x) = fraction cumulée des séjours (ou dépenses) détenue par les x% de patients les moins consommateurs.

G = 0 : consommation parfaitement égale (chaque patient consomme autant)
G = 1 : consommation totalement concentrée (un seul patient consomme tout)

Dans la réalité hospitalière française, la règle des 20/80 (ou "loi de Pareto") est bien documentée : 20% des patients concentrent 80% des dépenses hospitalières. Le Gini quantifie précisément cette concentration et permet de la comparer dans le temps, entre territoires, entre pathologies, et avant/après des politiques de santé visant à réduire les inégalités d'accès ou à gérer les grandes polyconsommateurs.

## Calcul

Construction de la courbe de Lorenz hospitalière :

```
Population de référence : patients hospitalisés au moins une fois
  dans le GHT sur une période de 12 mois (ou sur le territoire du GHT via SNDS)

Variable de consommation Cᵢ (au choix selon l'objectif) :
  → Nombre de séjours MCO sur 12 mois (intensité de recours)
  → Total des valorisations GHS en euros (coût hospitalier individuel)
  → Total des journées d'hospitalisation (charge en lit)
  → Nombre d'actes CCAM (activité médicale consommée)

Calcul du Gini :
  1. Trier les patients par Cᵢ croissant
  2. Calculer les parts cumulées de la population (x) et de la consommation (y = L(x))
  3. G = 1 − 2 × Σᵢ [L(xᵢ₋₁) + L(xᵢ)] / 2 × (xᵢ − xᵢ₋₁)
     (intégrale de la courbe de Lorenz par la méthode des trapèzes)

  Formule de calcul direct (sans courbe) :
  G = (2 × Σᵢ i×Cᵢ) / (N × Σᵢ Cᵢ) − (N+1)/N
    où les Cᵢ sont triés par ordre croissant et i ∈ {1..N}
```

Indicateurs complémentaires :

```
Ratio de concentration (règle de Pareto) :
  P20_80 = part des séjours cumulés par les 20% de patients les plus consommateurs
  P10_90 = part des séjours cumulés par les 10% de patients les plus consommateurs
  → Exemple : P20_80 = 0.72 signifie que 20% des patients réalisent 72% des séjours

Indice de concentration de Kakwani :
  K = G_consommation − G_besoin_ajusté
  → Mesure si la concentration de la consommation est supérieure à la concentration
    du besoin médical (calculé par l'indice de Charlson ou le score de comorbidité)
  → K > 0 : surconsommation concentrée au-delà de ce que justifie le besoin
  → K < 0 : les soins sont relativement mieux distribués que les besoins ne le justifient

Gini par IRIS / commune :
  → Calculer le Gini des taux de recours hospitalier standardisés par IRIS
  → Mesure les inégalités géographiques d'accès sur le territoire du GHT
  → Permet de localiser les zones de sous-recours (non-recours) ou sur-recours

Évolution temporelle :
  ΔG = G_annéeN − G_annéeN-1
  → ΔG > 0 : concentration croissante (les grands consommateurs consomment encore plus)
  → ΔG < 0 : réduction des inégalités de consommation
```

## Utilité

- **Identifier et gérer les patients grands polyconsommateurs** : le Gini élevé dans la plupart des populations hospitalières signifie qu'une petite fraction des patients concentre l'essentiel des ressources — ces patients sont les cibles prioritaires des programmes de gestion de cas (case management) et des parcours de soins intégrés ; le ratio P10_90 permet de chiffrer l'impact potentiel de l'intervention sur 10% des patients
- **Mesurer les inégalités de recours sur le territoire** : calculé par IRIS à partir des taux de recours standardisés, le Gini territorial révèle les poches de sous-recours ou de non-recours à l'hôpital — information clé pour les ARS dans le cadre des Contrats Locaux de Santé (CLS) et des diagnostics territoriaux
- **Évaluer l'impact des politiques de santé** : mesurer si un programme de coordination des soins (DAC, CPTS, parcours Insuffisance Cardiaque) réduit le Gini de consommation de la population cible, en distribuant plus équitablement les hospitalisations dans la cohorte
- **Benchmarking inter-GHT** : comparer le Gini de consommation entre GHTs de caractéristiques similaires pour évaluer si l'organisation des soins d'un territoire est plus ou moins équitable ; les GHTs avec un G élevé ont souvent un déficit d'offre en soins primaires ou de coordination (filières de soins peu développées)
- **Analyse par pathologie chronique** : le Gini de consommation des patients insuffisants cardiaques ou diabétiques est structurellement élevé (quelques patients décompensent à répétition) — son suivi permet de mesurer l'efficacité des programmes de suivi structuré (SOPHIA, télésuivi cardiaque) à "aplatir" la courbe de Lorenz de ces cohortes
- **Outil de dialogue avec les financeurs** : dans les négociations avec les ARS et l'Assurance Maladie sur les programmes de gestion des polyconsommateurs, le Gini et le P20_80 constituent des arguments quantitatifs pour justifier des ressources de coordination ciblées

## Sources de Données

- **PMSI MCO RSA** : chaîné par NIR crypté sur 12 mois glissants — nombre de séjours, valorisation GHS, nombre de journées, actes CCAM par patient ; agrégation par NIR pour obtenir la distribution individuelle des Cᵢ
- **SNDS DCIR** : pour élargir la consommation au-delà de l'hospitalisation MCO (consultations, médicaments, biologie) — permet un Gini de consommation de soins totale, pas seulement hospitalière
- **PMSI SSR, HAD, PSY** : intégration dans le calcul du Gini hospitalier global (tous champs) via chaînage NIR
- **Géolocalisation IRIS** : via code postal de résidence des patients dans le PMSI (commune de résidence) — pour le Gini territorial des taux de recours standardisés
- **Base de données des GHM** (ATIH) : valorisation GHS par GHM pour convertir les séjours en euros et calculer le Gini en valeur monétaire

## Exemple de Valeurs

- **Gini de consommation MCO (nombre de séjours, population générale)** : G ≈ 0,65-0,75 selon les territoires — reflète la forte concentration des hospitalisations répétées chez les polypathologiques
- **Ratio P20_80** : dans la plupart des cohortes hospitalières, 20% des patients concentrent 70-80% des séjours MCO — cohérent avec la règle de Pareto et les études CNAM
- **Gini territorial des taux de recours (par IRIS)** : G ≈ 0,15-0,35 selon le territoire — les zones rurales isolées et les zones urbaines défavorisées ont les taux les plus faibles (non-recours), les zones péri-urbaines aisées les plus élevés
- **Gini insuffisance cardiaque** : G ≈ 0,70-0,80 (quelques patients décompensent très fréquemment, la majorité a 1-2 hospitalisations par an) — le programme de télésuivi cardiaque vise à réduire ce Gini de 0,10-0,15 points en 3 ans
- **Indice de Kakwani** : K ≈ +0,05 à +0,15 dans les cohortes ALD — indique une légère surconsommation chez les patients déjà les plus comorbides, au-delà de ce que leur profil de besoin justifierait

## Limites

- Le Gini de consommation hospitalière mesure la dispersion de l'utilisation, non l'inégalité d'accès au sens strict — un Gini élevé peut refléter une concentration légitime des soins chez les patients réellement les plus malades (et non une inégalité injuste) ; l'indice de Kakwani est nécessaire pour distinguer les deux
- Le Gini est sensible à la définition de la population de référence : s'il est calculé uniquement sur les patients hospitalisés, il exclut les non-recourants (patients qui auraient besoin de soins mais ne se présentent pas) — pour mesurer les inégalités d'accès, il faut l'exprimer en taux de recours sur la population totale du territoire (avec dénominateur INSEE)
- La variation temporelle du Gini peut être due à des effets de composition (vieillissement, arrivée de patients chroniques) indépendants de tout changement organisationnel — une standardisation sur l'âge, le sexe et le profil de comorbidité est nécessaire pour les comparaisons inter-annuelles et inter-territoires
- Le Gini est un indicateur scalaire qui résume la distribution entière en un seul chiffre — deux distributions très différentes peuvent avoir le même Gini ; toujours publier la courbe de Lorenz complète et les déciles de distribution pour donner une vision complète

## Références

- [Gini C. — Variabilità e mutabilità, 1912 : définition originale du coefficient de Gini]
- [Kakwani N. — Measurement of tax progressivity: an international comparison, The Economic Journal 1977](https://doi.org/10.2307/2231833) — indice de Kakwani pour l'équité des soins de santé
- [van Doorslaer E. et al. — Inequalities in the use of physician services : a review of the evidence, Health Economics 2006](https://doi.org/10.1002/hec.1139)
- [CNAM — Charges et Produits annuels : concentration des dépenses de santé en France (rapport annuel)](https://www.ameli.fr/)
- [DREES — Les inégalités sociales de santé dans le contexte du COVID-19 (2021)](https://www.drees.solidarites-sante.gouv.fr/)
- [Lorenz M.O. — Methods of measuring the concentration of wealth, Publications of the American Statistical Association 1905]
