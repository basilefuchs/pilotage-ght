# Projection Capacitaire Démographique

## Définition
La projection capacitaire démographique est un modèle de simulation croisant les taux de recours hospitaliers actuels (calculés depuis le PMSI) avec les projections de population INSEE (modèle OMPhale) pour estimer l'évolution de l'activité du GHT à horizon 5, 10 et 20 ans. Ce modèle permet d'anticiper les besoins futurs en lits, en plateaux techniques, en personnel médical et paramédical, et en structures d'aval (SSR, HAD, médico-social), en tenant compte du vieillissement démographique, des évolutions épidémiologiques et des changements de pratiques (virage ambulatoire, médecine de précision). Il constitue le socle quantitatif du projet médical partagé du GHT et des négociations avec l'ARS pour les futurs CPOM.

## Calcul
La projection capacitaire est construite en quatre étapes :

**Étape 1 — Taux de recours actuels par classe d'âge et sexe :**
```
Taux de recours(âge, sexe, pathologie) = Séjours PMSI / Population(âge, sexe) × 100 000
```

**Étape 2 — Projection de la population par l'INSEE (OMPhale) :**
```
Population projetée(âge, sexe, année) = f(natalité, mortalité, migrations)
  → Disponible par commune et département à horizon 2030, 2040, 2050
```

**Étape 3 — Estimation de l'activité future (scénario tendanciel) :**
```
Séjours projetés(pathologie, année) = Σ [Taux de recours(âge, sexe) × Population projetée(âge, sexe, année)]
```

**Étape 4 — Conversion en besoins capacitaires :**
```
Lits nécessaires = (Séjours projetés × DMS cible) / (365 × Taux d'occupation cible)

Places ambulatoires = Séjours projetés ambulatoires / (Jours ouvrés × Rotation cible)
```

**Scénarios à modéliser :**
- **Scénario tendanciel** : maintien des taux de recours actuels, évolution démographique seule.
- **Scénario virage ambulatoire** : intégration d'une cible de taux d'ambulatoire progressivement croissante (-X % de lits MCO, +Y % de places ambulatoires).
- **Scénario épidémiologique** : intégration de l'évolution prévisible des prévalences (diabète +20 %, cancers +15 %, démence +30 % à horizon 2035).
- **Scénario innovant** : hypothèses de réduction des séjours par de nouvelles thérapeutiques (immunothérapies, chimiothérapies orales, télémédecine).

## Utilité
- **Planification des investissements** : dimensionner les futurs projets immobiliers (reconstruction, extension) sur la base d'une estimation robuste de l'activité à 10-15 ans, évitant le sur- ou le sous-dimensionnement.
- **Anticipation des besoins en ressources humaines** : projeter les effectifs médicaux et paramédicaux nécessaires par spécialité pour anticiper les recrutements et les formations 5-10 ans à l'avance.
- **Négociation CPOM et SROS** : objectiver les besoins futurs du territoire pour obtenir des autorisations d'activité et des financements adaptés à l'évolution démographique.
- **Priorisation des filières à développer** : identifier les pathologies dont la croissance projetée est la plus forte (oncologie, gériatrie, psychiatrie) pour concentrer les investissements stratégiques.
- **Scénarios alternatifs pour le projet médical partagé** : comparer plusieurs trajectoires d'évolution (maintien du statu quo vs développement ambulatoire vs spécialisation) pour alimenter les décisions stratégiques du GHT.

## Sources de Données
- **PMSI MCO, SSR, HAD, PSY** : taux de recours actuels par tranche d'âge et sexe, par pathologie (CMD, GHM) et par type de prise en charge.
- **INSEE - OMPhale** : projections de population par commune, département et région, par tranche d'âge quinquennale et sexe, à horizon 2030-2050. Scenarios haut, bas et central disponibles.
- **DREES / InVS / SPF** : données épidémiologiques nationales (prévalences, incidences projetées) pour les principales pathologies chroniques et cancers.
- **ATIH** : évolutions historiques des taux de recours sur 10 ans pour calibrer les tendances séculaires (progression du virage ambulatoire, réduction des DMS).
- **HAS / INCA** : recommandations et projections sur l'évolution des thérapeutiques et des parcours de soins susceptibles de modifier les taux d'hospitalisation.

## Exemple de Valeurs
- **Vieillissement démographique** : dans un territoire à fort vieillissement (part des >75 ans passant de 9 % à 15 % en 2040), l'activité gériatrique et orthopédique peut croître de 30-50 % à volume de population stable.
- **Oncologie** : +15-20 % de nouveaux cas de cancer projetés à horizon 2035 (INCa), avec une augmentation des besoins en chimiothérapie, radiothérapie et soins de support.
- **Psychiatrie** : +20-25 % de besoins en soins psychiatriques projetés à horizon 2030, portés par le vieillissement (démences) et les troubles anxio-dépressifs post-COVID.
- **Virage ambulatoire** : à taux de recours constant, un passage de 40 % à 70 % de chirurgie ambulatoire réduit de 25-30 % le besoin en lits MCO, malgré la croissance démographique.
- **SSR et médico-social** : besoins en SSR projetés en hausse de 20-35 % à horizon 2035 dans les territoires vieillissants, avec un déficit structurel de places si l'offre n'est pas augmentée.
- **Exemple chiffré** : pour un GHT réalisant 20 000 séjours MCO en 2024, le modèle tendanciel projette 23 000-25 000 séjours en 2035 (+15-25 %), nécessitant 50-80 lits supplémentaires au taux d'occupation actuel, ou zéro lit supplémentaire en cas de virage ambulatoire complet.

## Limites
- Les projections de population OMPhale sont incertaines, notamment sur les migrations et les évolutions de natalité ; les scénarios haut et bas encadrent cette incertitude sans l'éliminer.
- Les taux de recours actuels intègrent des hospitalisations non pertinentes : projeter ces taux sans correction surestime les besoins futurs si des politiques de pertinence sont mises en place.
- Les ruptures technologiques (nouvelles thérapeutiques, télémédecine, IA diagnostique) peuvent modifier radicalement les taux de recours de façon difficilement modélisable sur des horizons longs.
- Le modèle tendanciel suppose une stabilité des comportements de recours et d'accès aux soins, ce qui est rarement vérifié sur des horizons de 10-20 ans.
- La granularité communale des projections OMPhale est insuffisante pour des territoires de petite taille ; les intervalles de confiance sont larges pour les communes de moins de 5 000 habitants.

## Références
- [INSEE - Projections de population OMPhale 2021-2070](https://www.insee.fr/fr/information/3683517)
- [INCa - Projections de l'incidence et de la mortalité par cancer en France](https://www.e-cancer.fr/)
- [ATIH - Évolutions historiques des taux de recours PMSI](https://www.atih.sante.fr/)
- [DREES - Projections des besoins en soins de longue durée](https://www.drees.solidarites-sante.gouv.fr/)
- [ANAP - Outil de projection capacitaire](https://www.anap.fr/)
