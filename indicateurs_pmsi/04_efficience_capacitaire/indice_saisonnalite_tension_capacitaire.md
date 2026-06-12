# Indice de Saisonnalité et de Tension Capacitaire

## Définition
L'indice de saisonnalité et de tension capacitaire analyse les variations temporelles de l'activité hospitalière — hebdomadaires, mensuelles et saisonnières — calculées depuis les dates de séjour PMSI, pour identifier les périodes de pic et de creux d'activité par CMD, GHM ou service. Il permet de distinguer la saisonnalité structurelle (liée à l'épidémiologie des pathologies et aux comportements de recours) de la saisonnalité organisationnelle (liée aux fermetures de lits, aux congés du personnel, aux programmations chirurgicales). La confrontation des pics d'activité avec les capacités disponibles révèle les périodes de tension capacitaire réelle et permet d'anticiper les besoins en lits, en personnel et en plateaux techniques.

## Calcul
L'indice de saisonnalité est calculé à partir des dates d'entrée des séjours PMSI :

**Indice de saisonnalité mensuelle (IS mensuel) :**
```
IS(mois M) = (Nombre de séjours entrants en mois M / Nombre moyen mensuel de séjours sur l'année) × 100

  → IS = 100 : activité dans la norme annuelle
  → IS > 120 : pic d'activité significatif (>20 % au-dessus de la moyenne)
  → IS < 80 : creux d'activité significatif (>20 % en dessous de la moyenne)
```

**Indice de saisonnalité hebdomadaire :**
```
IS(semaine S) = (Séjours entrants en semaine S / Moyenne hebdomadaire annuelle) × 100
```

**Indice de tension capacitaire (ITC) :**
```
ITC(période P) = IS(période P) × (1 / Taux de disponibilité des lits en période P)

  → Taux de disponibilité = Lits ouverts en période P / Capacité totale autorisée
  → ITC > 1,3 : tension capacitaire critique (forte activité + réduction de capacité)
```

**Précisions méthodologiques** :
- Les dates d'entrée et de sortie des RSS sont disponibles directement dans le PMSI MCO pour l'ensemble des établissements.
- L'analyse distingue les séjours programmés des séjours non programmés (urgences : `modeentree` = 8 et `provenance` = 5) : la saisonnalité des urgences est structurelle (épidémies hivernales, accidents estivaux) tandis que celle de la chirurgie programmée est partiellement maîtrisable.
- La décomposition par CMD permet d'identifier les spécialités portant la saisonnalité (CMD 4 pneumologie en hiver, CMD 8 orthopédie en été, CMD 5 cardiologie en hiver).
- Le calcul sur plusieurs années (3-5 ans) permet de lisser les aléas et de dégager les tendances structurelles.

## Utilité
- **Anticipation des pics d'activité** : identifier les semaines et les mois de forte tension pour planifier les effectifs soignants, les ouvertures de lits supplémentaires et les déprogrammations chirurgicales préventives.
- **Optimisation des fermetures estivales** : quantifier l'impact réel des fermetures de lits en été sur la tension capacitaire, pour calibrer les réductions de capacité sans créer de situations de crise.
- **Planification des activités de chirurgie programmée** : lisser l'activité chirurgicale programmée sur les périodes creuses (janvier-février, octobre-novembre) pour compenser les pics de médecine non programmée.
- **Gestion des épidémies saisonnières** : modéliser l'impact des épidémies de grippe, de bronchiolite et de gastro-entérite sur l'activité MCO hivernale pour préparer les plans de gestion de crise.
- **Benchmarking intra-GHT** : comparer les indices de saisonnalité entre les établissements du GHT pour identifier ceux qui absorbent disproportionnellement les pics saisonniers et ajuster les coopérations inter-sites.

## Sources de Données
- **PMSI MCO** : dates d'entrée et de sortie de chaque séjour (RSS), mode d'entrée (programmé/urgences), CMD et GHM — pour le calcul des indices de saisonnalité par période et par pathologie.
- **SAE (Statistique Annuelle des Établissements)** : capacités en lits par service et par période (ouvertures/fermetures saisonnières) pour le calcul du taux de disponibilité et de l'ITC.
- **RPU (Résumés de Passage aux Urgences)** : dates de passage pour analyser la saisonnalité de l'activité urgentiste indépendamment des hospitalisations.
- **Données météorologiques et épidémiologiques** (Santé Publique France, réseau Sentinelles) : pour corréler les pics d'activité PMSI avec les indicateurs épidémiques (grippe, bronchiolite, canicule).

## Exemple de Valeurs
- **Saisonnalité hivernale** : IS mensuel de 115-130 en janvier-février pour les CMD respiratoires (CMD 4) et cardiovasculaires (CMD 5), contre 70-85 en août.
- **Saisonnalité estivale** : IS de 110-125 en juillet-août pour les CMD traumatologiques (CMD 8, 21) liés aux accidents de loisirs.
- **Chirurgie programmée** : IS de 60-75 en août (fermetures de blocs opératoires) et 105-115 en septembre-octobre (rattrapage post-estival).
- **Creux du week-end** : nombre d'entrées le samedi et dimanche représentant 30-40 % du volume d'une journée de semaine pour la chirurgie programmée, mais 80-90 % pour les urgences.
- **ITC critique (>1,3)** : observé en janvier-février dans la plupart des GHT avec des services de médecine interne et de gériatrie, coïncidant avec les épidémies grippales et les réductions de capacité post-fêtes.
- **Impact d'une épidémie de grippe** : augmentation de 15-25 % des entrées MCO en médecine pendant 4-6 semaines, créant une tension capacitaire significative si les lits estivaux ne sont pas rouverts.

## Limites
- La saisonnalité calculée sur les dates d'entrée PMSI mélange la saisonnalité de la demande (épidémiologique, comportementale) et la saisonnalité de l'offre (fermetures de blocs, congés) : les dissocier nécessite de croiser avec les données de capacité SAE.
- L'indice de saisonnalité sur une seule année est très sensible aux événements exceptionnels (épidémie, grève, travaux) ; le calcul sur 3-5 ans est indispensable pour dégager des tendances robustes.
- La granularité hebdomadaire du PMSI (dates de séjour) ne permet pas une analyse infra-hebdomadaire (par heure ou par demi-journée) nécessaire pour le pilotage opérationnel des urgences.
- L'indice de tension capacitaire (ITC) requiert les données de capacité disponible (lits ouverts) issues de la SAE ou des systèmes de gestion des lits, non disponibles directement dans le PMSI.
- Les projections de saisonnalité future sont incertaines car elles dépendent de variables épidémiologiques difficiles à prévoir (intensité des épidémies, émergence de nouveaux pathogènes).

## Références
- [ATIH - Fichiers PMSI MCO et dates de séjour](https://www.atih.sante.fr/)
- [SAE - Statistique Annuelle des Établissements : capacités et ouvertures de lits](https://www.sae-diffusion.sante.gouv.fr/)
- [Santé Publique France - Surveillance épidémiologique saisonnière](https://www.santepubliquefrance.fr/)
- [ANAP - Gestion des lits et pilotage capacitaire](https://www.anap.fr/)
