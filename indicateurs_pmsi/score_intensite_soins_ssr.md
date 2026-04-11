# Score d'Intensité de Soins en SSR

## Définition
Le score d'intensité de soins en SSR est un indicateur composite combinant les données de dépendance fonctionnelle issues des grilles d'autonomie AVQ (Actes de la Vie Quotidienne) du PMSI SSR et le volume d'actes de rééducation et de réadaptation codés par semaine de présence. Il vise à mesurer la lourdeur réelle de la prise en charge en SSR au-delà de la seule classification en Groupes Médico-Économiques (GME), qui ne capture pas toujours fidèlement l'intensité des soins prodigués. Un score élevé caractérise un patient très dépendant nécessitant une rééducation intensive ; un score faible peut signaler une orientation SSR inadaptée (patient trop peu dépendant) ou une sous-utilisation des ressources de rééducation disponibles.

## Calcul
Le score d'intensité de soins en SSR est calculé à partir des données hebdomadaires du Résumé Hebdomadaire de Soins (RHS) :

**Composante 1 — Score de dépendance AVQ (0-12 points) :**
```
Score AVQ = Σ cotations sur 6 items AVQ (habillage, déplacement, alimentation, continence, hygiène, comportement)
  → Chaque item coté de 0 (autonome) à 2 (totalement dépendant)
  → Score total : 0 (autonomie complète) à 12 (dépendance totale)
```

**Composante 2 — Intensité de rééducation (actes CSARR par semaine) :**
```
Intensité rééducation = Nombre de points CSARR réalisés par semaine de présence
  → CSARR : Catalogue Spécifique des Actes de Rééducation et Réadaptation (référentiel PMSI SSR)
  → Actes pondérés par leur coefficient CSARR (complexité et durée)
```

**Score composite d'intensité de soins SSR :**
```
Score IS-SSR = α × Score AVQ normalisé + β × Intensité CSARR normalisée

  → Normalisation : chaque composante ramenée entre 0 et 1 sur la distribution observée
  → Pondération par défaut : α = 0,5, β = 0,5 (ajustable selon la filière)
  → Score final entre 0 et 1 : < 0,3 (faible intensité), 0,3-0,7 (intensité modérée), > 0,7 (haute intensité)
```

**Précisions méthodologiques** :
- Le calcul est réalisé semaine par semaine (unité du RHS) puis agrégé en moyenne sur la durée du séjour SSR.
- L'analyse distingue les filières (neurologie, orthopédie, gériatrie, cardiologie, oncologie) car les niveaux d'intensité attendus diffèrent structurellement.
- Le score peut être calculé à l'entrée en SSR (RHS de la première semaine) pour évaluer la pertinence de l'orientation, et à la sortie pour mesurer la progression fonctionnelle.

## Utilité
- **Évaluation de la pertinence de l'orientation en SSR** : un patient avec un score IS-SSR faible à l'entrée (peu dépendant, peu d'actes de rééducation) pourrait être pris en charge en HAD ou en consultation de rééducation ambulatoire, libérant des lits SSR pour des patients nécessitant une intensité supérieure.
- **Mesure de la progression fonctionnelle** : la variation du score AVQ entre l'entrée et la sortie du SSR (delta AVQ) quantifie le gain fonctionnel apporté par la prise en charge — indicateur de résultat de soins directement issu du PMSI SSR.
- **Benchmarking inter-SSR** : comparer les scores d'intensité entre les SSR du GHT pour identifier les structures qui sous-utilisent leur potentiel de rééducation intensive ou qui accueillent des patients trop peu dépendants.
- **Pilotage des ressources paramédicales** : calibrer les effectifs de kinésithérapeutes, ergothérapeutes et orthophonistes en fonction du score IS-SSR moyen des patients pris en charge.
- **Optimisation des durées de séjour SSR** : un score IS-SSR décroissant en fin de séjour (dépendance et actes de rééducation en baisse) signale la possibilité de préparer la sortie vers une structure d'aval moins intensive.

## Sources de Données
- **PMSI SSR - Résumé Hebdomadaire de Soins (RHS)** : grilles AVQ (6 items cotés hebdomadairement) et actes CSARR (Catalogue Spécifique des Actes de Rééducation et Réadaptation) codés par semaine.
- **ATIH - Référentiel CSARR** : catalogue des actes de rééducation avec leurs coefficients de pondération, mis à jour annuellement.
- **ATIH - Groupes Médico-Économiques SSR (GME)** : classification SSR intégrant partiellement le score AVQ et les actes de rééducation, mais de façon agrégée et moins fine que le score IS-SSR.
- **ScanSanté** : module SSR permettant l'analyse des RHS par établissement, bien que le score IS-SSR composite nécessite un calcul local sur les données brutes.

## Exemple de Valeurs
- **Score AVQ moyen à l'entrée en SSR neurologique post-AVC** : 7-10/12 (forte dépendance), contre 3-5/12 en SSR orthopédique post-prothèse de hanche (dépendance modérée).
- **Intensité CSARR moyenne** : 50-80 points CSARR par semaine en SSR neurologique intensif, contre 20-40 points en SSR gériatrique de faible intensité.
- **Delta AVQ entrée/sortie** : gain de 3-5 points en SSR neurologique performant (AVC), gain de 1-2 points en SSR gériatrique (amélioration plus limitée par les comorbidités).
- **Taux de patients avec score IS-SSR faible à l'entrée** : 15-25 % des admissions SSR selon les établissements, signalant un potentiel de réorientation vers des structures moins intensives.
- **Corrélation IS-SSR et DMS** : les patients à score IS-SSR élevé ont une DMS 30-50 % supérieure à ceux à faible score dans la même filière, justifiant des ressources différenciées.

## Limites
- La cotation des grilles AVQ est réalisée par les soignants et peut varier selon les établissements et les équipes, introduisant un biais inter-observateur dans le calcul du score.
- Le CSARR ne couvre pas tous les actes de rééducation : certaines thérapies (neuropsychologie, médecine physique non cotée) ne sont pas tracées dans le PMSI SSR, sous-estimant l'intensité réelle des soins.
- La pondération des deux composantes du score (AVQ et CSARR) est arbitraire et doit être adaptée à la filière analysée : une pondération unique est insuffisante pour des filières aussi différentes que la neurologie et l'orthopédie.
- La disponibilité des données RHS brutes avec les cotations AVQ semaine par semaine requiert un accès aux fichiers PMSI SSR locaux ; ces données ne sont pas exploitables directement depuis ScanSanté.
- Le score IS-SSR mesure l'intensité de soins délivrée, pas nécessairement l'intensité optimale : un patient peut recevoir peu d'actes non par manque de besoin mais par défaut de ressources paramédicales disponibles.

## Références
- [ATIH - Guide méthodologique PMSI SSR : RHS, AVQ et CSARR](https://www.atih.sante.fr/)
- [ATIH - Catalogue Spécifique des Actes de Rééducation et Réadaptation (CSARR)](https://www.atih.sante.fr/)
- [HAS - Référentiels de bonnes pratiques en SSR par filière](https://www.has-sante.fr/)
- [ScanSanté - Analyse de l'activité SSR](https://www.scansante.fr/)
