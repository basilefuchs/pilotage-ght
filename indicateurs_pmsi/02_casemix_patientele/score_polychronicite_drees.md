# Score de Polychronicité DREES (Cartographie des Pathologies)

## Définition

Le score de polychronicité DREES est le nombre moyen de groupes de pathologies chroniques distincts par patient hospitalisé, calculé à partir de la classification en 58 groupes de la **Cartographie des pathologies et des dépenses** (DREES-CNAM, 2019). Cette classification regroupe l'ensemble des assurés du régime général en profils de morbidité homogènes sur la base de leurs codes CIM-10 (diagnostics du PMSI et des ALD du SNDS).

S_poly = (1/N) × Σⱼ card({groupes_i | patientⱼ ∈ groupeᵢ})

où N est le nombre de patients hospitalisés sur la période, et card(.) désigne le nombre de groupes de pathologies distincts attribués à un patient via ses codes CIM-10.

Cet indicateur diffère fondamentalement des scores de comorbidités classiques :
- Le **score de Charlson** pondère 17 comorbidités par leur impact pronostique sur la mortalité.
- L'**Elixhauser** pondère 31 comorbidités pour la prédiction des coûts et de la réadmission.
- Le **score DREES** ne pondère pas par la gravité : il comptabilise la **largeur de la charge pathologique chronique**, indépendante des épisodes aigus. Un patient avec 4 pathologies chroniques stables est aussi polychronique qu'un patient avec 4 pathologies chroniques instables.

La polychronicité mesure donc la **complexité organisationnelle de la prise en charge** (nombre de spécialistes, de filières, de protocoles à coordonner), information absente des scores pronostiques.

## Calcul

Source principale : PMSI MCO RSA — codes CIM-10 (DP, DR, DA). Source complémentaire : SNDS/DCIR pour les ALD identifiées hors PMSI.

```
Étape 1 — Référentiel de mapping CIM-10 → 58 groupes DREES
  Charger la table de correspondance publiée par la DREES :
  - 58 groupes organisés en 7 familles :
      cancers (8 groupes), maladies cardio-neuro-vasculaires (7),
      traitements psychiatriques et psychotropes (5), diabète (2),
      maladies respiratoires chroniques (5), autres affections chroniques (22),
      maternité-périnatalité-prématurité (4), traitement antalgique (5)
  - Chaque groupe = liste de codes CIM-10 (racines ou codes complets)
  - Source : DREES-CNAM "Cartographie des pathologies" — table disponible en open data

Étape 2 — Association patient × groupes sur le PMSI
  Pour chaque RSA de la période :
    Extraire le NIR chiffré (ou identifiant patient anonymisé ATIH)
    Extraire tous les codes CIM-10 : DP, DR, DA1..DA20
  Pour chaque patient (identifiant unique) :
    groupes_patient = DISTINCT(mapping[code] pour tout code ∈ {DP,DR,DA})
    nb_groupes = card(groupes_patient)

Étape 3 — Score de polychronicité
  S_poly = mean(nb_groupes)  sur l'ensemble des patients de la période
  Distribution : median, P25, P75, P90 (distribution asymétrique droite)

Étape 4 — Niveaux de polychronicité
  0 groupe  : patient sans pathologie chronique identifiable en PMSI (aigu pur)
  1         : monomorbide chronique
  2-3       : polymorbide modéré
  4-5       : polymorbide sévère
  ≥6        : hyperpolychronique (≈ top 5% de la population hospitalisée)
```

Indicateurs dérivés :

```
Taux d'hyperpolychroniques :
  rate(patients avec ≥6 groupes / total patients)
  → Signal d'une patientèle à coordination très complexe

Score de polychronicité par service/UM :
  S_poly(UM) → identifier les services accueillant des patients multimorbides
  → Pertinent pour calibrer les ressources de coordination (médecin traitant, IDE de liaison)

Évolution temporelle :
  ΔS_poly(N, N-1) → tendance de complexification de la patientèle sur 3-5 ans
```

## Utilité

- **Positionner la complexité réelle de la patientèle** : le CMI mesure la lourdeur économique (pondération par le coût GHM) ; le score de polychronicité mesure la complexité de coordination. Un service de médecine interne avec CMI = 1,2 et S_poly = 3,8 révèle une patientèle poly-pathologique que le CMI seul masque.
- **Argumenter les besoins en infirmiers de coordination et en médecins traitants** : un GHT dont S_poly monte de 2,4 à 3,1 sur 5 ans justifie l'augmentation de postes dédiés à la coordination ville-hôpital et aux dispositifs d'appui à la coordination (DAC).
- **Identifier les services surreprésentés en hyperpolychroniques** : un taux d'hyperpolychroniques (≥6 groupes) > 15% dans un service de soins de suite alerte sur une inadéquation entre le niveau de soins proposé et la complexité réelle des patients (sous-dimensionnement ou mauvaise orientation).
- **Comparer avec le territoire** : le score de polychronicité de l'hôpital vs la prévalence de multimorbidité DREES dans la population de la zone d'attraction (issue de l'EGB ou des Charges et produits CNAM) mesure si l'hôpital prend en charge la morbidité chronique locale ou si une partie lui échappe (recours à d'autres établissements).
- **Calibrer les programmes de réhabilitation et d'éducation thérapeutique** : les patients avec S_poly ≥ 4 sont les premiers bénéficiaires des programmes ETP multi-pathologies ; leur dénombrement par territoire permet de dimensionner l'offre.
- **Enrichir le profil de case-mix pour le CPOM** : dans les négociations CPOM avec l'ARS, le score de polychronicité documente la prise en charge d'une patientèle complexe indépendamment des GHMs (qui peuvent être peu valorisés pour des séjours courts de coordination).

## Sources de Données

- **PMSI MCO RSA** : codes CIM-10 (DP, DR, DA), identifiant patient anonymisé (NUM_ENQ ou NIR pseudonymisé ATIH)
- **Table de correspondance CIM-10 → 58 groupes DREES** : publiée en open data sur data.drees.solidarites-sante.gouv.fr (fichier "Cartographie des pathologies — table de codage")
- **SNDS/DCIR** (optionnel, enrichissement) : codes ALD, remboursements médicaments (ATC) pour compléter les groupes non détectables en PMSI seul (ex. diabète traité uniquement en ambulatoire)
- **Population ATIH / INSEE** : pour le calcul de la prévalence attendue dans la zone d'attraction en comparaison

## Exemple de Valeurs

- **CHU polyvalent** : S_poly ≈ 2,8–3,5 (patientèle complexe, recours tertaire)
- **CH général 300-500 lits** : S_poly ≈ 2,0–2,8
- **Clinique chirurgicale programmée** : S_poly ≈ 1,2–1,8 (patientèle sélectionnée, peu de comorbidités chroniques multiples)
- **Service de médecine interne / gériatrie** : S_poly ≈ 3,5–5,0 (plus forte densité de polychronicité)
- **Service de chirurgie orthopédique** : S_poly ≈ 1,5–2,2
- **Taux d'hyperpolychroniques (≥6 groupes)** :
  - Gériatrie : 20–35%
  - Médecine interne : 12–22%
  - Chirurgie programmée : 3–8%
- **Seuil minimal de calcul** : ≥300 patients identifiables sur la période pour une stabilité du score

## Limites

- **Dépendance au codage des DA** : les pathologies chroniques ne sont renseignées en diagnostics associés que si le codeur les documente ; un service avec une culture de codage minimal aura un S_poly artificiellement bas, indépendamment de la réalité clinique.
- **Identification patient PMSI incomplète** : sans couplage SNDS, l'identifiant patient PMSI (NIR pseudonymisé) peut être instable entre séjours d'établissements différents, limitant l'agrégation multi-séjours au sein d'un même exercice pour les GHTs multi-sites.
- **PMSI seul sous-estime la polychronicité** : les pathologies chroniques traitées exclusivement en ambulatoire (diabète de type 2 équilibré, HTA sans hospitalisation) n'apparaissent pas dans le PMSI si elles ne sont pas codées en DA. Le score PMSI est donc un minorant du score SNDS complet.
- **Stabilité inter-annuelle du référentiel** : la table DREES des 58 groupes évolue à chaque mise à jour de la Cartographie ; les comparaisons pluriannuelles nécessitent de fixer la version du référentiel ou de reprocesser les années antérieures.
- **Seuil minimal de séjours** : en dessous de 300 patients par service/période, la variabilité statistique du score est trop élevée pour des comparaisons fiables.

## Références

- [DREES-CNAM — Cartographie des pathologies et des dépenses, édition 2019](https://www.drees.solidarites-sante.gouv.fr/publications/etudes-et-resultats/cartographie-des-pathologies-et-des-depenses-edition-2019)
- [Mousquès J., Bourgueil Y. — La notion de « médecin de premier recours », IRDES Questions d'économie de la santé n°157, 2010](https://www.irdes.fr/Publications/Qes/Qes157.pdf)
- [Barnett K. et al. — Epidemiology of multimorbidity and implications for health care, research, and medical education: a cross-sectional study, Lancet 2012](https://doi.org/10.1016/S0140-6736(12)60240-2)
- [ATIH — Guide méthodologique de production du PMSI MCO (version en vigueur)](https://www.atih.sante.fr/)
- [van den Akker M. et al. — Multimorbidity in general practice: prevalence, incidence, and determinants of co-occurring chronic and recurrent diseases, Journal of Clinical Epidemiology 1998](https://doi.org/10.1016/S0895-4356(97)00306-5)
