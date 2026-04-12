# Indice de Simpson de Diversité des Équipes SSR

## Définition

L'indice de diversité de Simpson, développé en écologie par E.H. Simpson en 1949 pour mesurer la biodiversité d'un écosystème, quantifie la probabilité que deux individus tirés au sort dans une population appartiennent à des espèces différentes. Transposé aux équipes de soins de suite et réadaptation (SSR), l'**Indice de Simpson de Diversité des Équipes SSR** (ISDE) mesure la **diversité professionnelle** d'une équipe soignante : la probabilité que deux intervenants choisis au hasard parmi les professionnels ayant pris en charge un patient sur son séjour SSR appartiennent à des professions différentes.

ISDE = 1 − Σᵢ (nᵢ / N)²

où nᵢ est le nombre d'actes ou d'interventions réalisées par la profession i et N le nombre total d'actes ; une valeur proche de 1 indique une équipe très diversifiée (nombreuses professions, réparties équitablement), une valeur proche de 0 indique une équipe mono-professionnelle.

L'analogie écologique est directe : comme un écosystème riche en espèces est plus résilient qu'un écosystème mono-espèce, une équipe SSR pluriprofessionnelle est supposée mieux traiter la complexité des patients polypathologiques. L'ISDE n'est pas un simple comptage de professions (qui donnerait le même score à une équipe avec 1 kiné et 20 infirmiers qu'à une équipe avec 10 kinés et 10 infirmiers) : il prend en compte la **répartition équilibrée** des interventions entre professions.

## Calcul

Construction du vecteur professionnel par séjour SSR :

```
Pour chaque séjour SSR (RHS) :

Professions identifiables dans le PMSI SSR :
  → Médecine physique et réadaptation (MPR) — actes CCAM spécifiques
  → Kinésithérapie — cotation actes de rééducation (AMK, AMS)
  → Ergothérapie — actes de bilan et rééducation occupationnelle
  → Orthophonie — actes AMO
  → Neuropsychologie / Psychologie — actes de bilan cognitif
  → Soins infirmiers — actes CCAM infirmiers, AMI
  → Diététique, Assistante sociale — actes tracés dans certains logiciels SSR
  → Pharmacien — consultation pharmaceutique (dans certains établissements)

Vector nᵢ = nombre d'actes (ou de RHS) attribuables à la profession i
N = Σᵢ nᵢ = total des actes ou RHS du séjour

ISDE_séjour = 1 − Σᵢ (nᵢ / N)²
  → Calculé sur le séjour complet (ensemble des RHS hebdomadaires)
```

Calcul par service et par profil de patient :

```
ISDE_service = moyenne(ISDE_séjour) sur l'ensemble des séjours du service
  → ISDE_service pondéré par la durée de séjour possible pour les comparaisons
    entre séjours courts et longs

Stratification par catégorie majeure clinique (CMD SSR) :
  → CMD SSR 01 (affections du système nerveux) : ISDE attendu élevé
    (équipe neurologique pluriprofessionnelle : MPR, kiné, ergo, ortho, neuropsy)
  → CMD SSR 10 (affections ostéo-articulaires) : ISDE modéré
    (kiné dominant, mais MPR, ergo, IDE)
  → CMD SSR 09 (tumeurs) : ISDE variable selon le stade
    (soins palliatifs : équipe enrichie de psy, AS, diét)

ISDE_attendu(CMD) = valeur de référence calculée sur les cohortes de référence
  → Écart à l'attendu = ISDE_service(CMD) − ISDE_attendu(CMD)
  → Écart négatif : équipe moins diversifiée que la référence pour ce profil → alerte
```

Indice de richesse professionnelle (complémentaire) :

```
S = Nombre de professions distinctes ayant réalisé au moins 1 acte dans le séjour
  → S = 3-4 : équipe de base (kiné, IDE, MPR, assistante sociale)
  → S ≥ 6 : équipe pluriprofessionnelle complète (dont ergo, ortho, neuropsy, diét, pharma)

ISDE normalisé par S :
  ISDE_norm = ISDE / ISDE_max(S) = ISDE / (1 − 1/S)
  → Mesure si la répartition entre les S professions présentes est équilibrée
  → Indépendant du nombre de professions, compare uniquement la répartition
```

## Utilité

- **Évaluer la qualité de la prise en charge pluriprofessionnelle en SSR** : les recommandations HAS (neurologie, gériatrie, rhumatologie) préconisent explicitement des équipes pluriprofessionnelles pour certains profils de patients — l'ISDE mesure si ces équipes fonctionnent effectivement comme pluriprofessionnelles ou si l'une des professions domine au détriment des autres
- **Identifier les équipes sous-dotées en certains professionnels** : un ISDE faible dans un service de SSR neurologique peut signaler un manque d'ergothérapeutes ou d'orthophonistes, professions difficiles à recruter — l'ISDE fournit un argument quantitatif pour justifier un recrutement ou une mutualisation entre établissements du GHT
- **Corrélation avec les résultats fonctionnels (MIF)** : les études en rééducation montrent que la diversité professionnelle effective (et non seulement la présence nominale) est associée à de meilleurs gains fonctionnels (delta-MIF) — l'ISDE peut être mis en relation avec le gain MIF pour évaluer si la pluriprofessionnalité produit les résultats attendus
- **Benchmarking inter-établissements SSR du GHT** : comparer l'ISDE par CMD SSR entre les unités SSR des différents établissements du GHT pour identifier les écarts de pratiques — les unités avec ISDE faible sur les CMD complexes bénéficient d'un transfert de bonnes pratiques ou d'une mutualisation de professionnels spécialisés
- **Suivi de l'impact des restructurations RH** : mesurer l'évolution de l'ISDE avant/après le recrutement d'un ergothérapeute, d'un neuropsychologue, ou la création d'une équipe mobile SSR — démonstration de l'impact organisationnel sur la diversité effective de la prise en charge
- **Identification des séjours à prise en charge insuffisamment diversifiée** : à l'échelle individuelle, un ISDE séjour très faible pour un patient avec une CMD SSR complexe est un signal de prise en charge sous-optimale — peut déclencher une revue par le médecin MPR référent

## Sources de Données

- **PMSI SSR RHS** : résumés hebdomadaires de soins comprenant les actes réalisés par profession (cotation CCAM, AMK, AMO, AMI selon la profession), identifiés par code spécialité dans le vecteur actes du RHS — principale source pour construire le vecteur nᵢ
- **Variables RHS spécifiques** : la variable "type d'acte" et "code intervenant" des RHS permettent d'identifier la profession réalisatrice de chaque acte ; la complétude de ce codage varie selon les établissements et les logiciels SSR (Clinicom, DxCare, SilverSurfer)
- **Données RH de l'établissement** (non PMSI) : effectifs en ETP par profession dans le service SSR — permet de calculer un ISDE structurel (basé sur les ressources disponibles) à comparer avec l'ISDE réalisé (basé sur les actes effectivement tracés)
- **Référentiels HAS de prise en charge SSR** : recommandations de composition des équipes par profil de patient (AVC : HAS 2022, fracture de hanche : HAS 2021, cancer : INCa 2020) — définissent le profil professionnel optimal pour chaque CMD SSR, utilisable comme ISDE_attendu de référence

## Exemple de Valeurs

- **Service SSR neurologique (AVC, traumatisme crânien)** : ISDE moyen = 0,72-0,82 dans les services bien dotés (MPR, kiné, ergo, ortho, neuropsy, IDE, assistante sociale) ; S = 6-7 professions actives par séjour
- **Service SSR orthopédique (prothèse hanche/genou)** : ISDE moyen = 0,55-0,65 (kiné dominant + MPR + IDE) ; S = 3-4 professions — déséquilibre moindre que neurologie mais attendu pour ce profil
- **Service SSR gériatrique** : ISDE moyen = 0,65-0,75 (équipe gériatrique pluriprofessionnelle idéale : MPR, kiné, ergo, diét, AS, IDE, psychogériatre) ; un ISDE < 0,50 en gériatrie signale une équipe appauvrie
- **ISDE minimal acceptable** : ISDE < 0,40 pour un séjour SSR complexe = prise en charge mono-professionnelle, à investiguer
- **Corrélation ISDE-delta MIF** : dans les études disponibles, chaque 0,10 point d'ISDE supplémentaire est associé à +1,5-2,0 points de gain MIF sur le séjour (après ajustement sur la sévérité initiale)

## Limites

- La complétude du codage des actes par profession dans les RHS est très variable selon les établissements et les logiciels — un ISDE faible peut refléter un sous-codage des actes des professions paramédicales plutôt qu'une réelle absence de pluriprofessionnalité ; la comparaison inter-établissements nécessite une vérification préalable de la complétude des données
- L'ISDE mesure la diversité des actes tracés, non la qualité de la coordination entre professionnels — une équipe diversifiée mais non coordonnée (absence de réunion pluridisciplinaire, pas de projet de soins partagé) peut avoir un ISDE élevé avec de mauvais résultats ; l'ISDE est un proxy de pluriprofessionnalité, pas un indicateur de coordination effective
- La définition des "professions" dans le PMSI SSR est limitée par la granularité de la nomenclature d'actes : les actes de diététique, travail social, et accompagnement psychologique sont souvent mal tracés dans les RHS, conduisant à une sous-estimation systématique de la diversité réelle des équipes
- L'ISDE est sensible à la durée de séjour : les séjours longs permettent mathématiquement plus d'actes diversifiés que les séjours courts — la normalisation par la durée de séjour est recommandée pour les comparaisons entre profils cliniques avec des durées très différentes

## Références

- [Simpson E.H. — Measurement of diversity, Nature 1949](https://doi.org/10.1038/163688a0) — article fondateur d'une demi-page définissant l'indice
- [Gittell J.H. et al. — Impact of relational coordination on quality of care, post-operative pain and functioning, Medical Care 2000](https://doi.org/10.1097/00005650-200008000-00005) — lien entre coordination pluriprofessionnelle et résultats en chirurgie orthopédique
- [HAS — Recommandations pour la prise en charge en SSR après AVC (2022)](https://www.has-sante.fr/)
- [HAS — Conditions techniques de fonctionnement des SSR (décret compétences pluriprofessionnelles, 2019)](https://www.has-sante.fr/)
- [Stroke Unit Trialists — Collaborative systematic review of randomised trials of organised inpatient stroke unit care after stroke, BMJ 1997](https://doi.org/10.1136/bmj.314.7088.1151) — démonstration de la supériorité des unités pluriprofessionnelles dédiées
- [ATIH — Guide méthodologique PMSI SSR : codage des actes de rééducation dans les RHS](https://www.atih.sante.fr/)
