# Indice de Continuité du Parcours Patient au sein du GHT

## Définition
L'indice de continuité du parcours patient mesure la proportion de patients dont l'ensemble du parcours de soins (MCO → SSR → HAD, ou toute combinaison multi-séjours) reste au sein des établissements du GHT, sans recours à des structures extérieures au groupement. Il évalue la capacité du GHT à assurer une prise en charge complète et coordonnée du patient, de l'hospitalisation aiguë jusqu'à la réadaptation ou le retour à domicile accompagné, sans rupture de filière vers l'extérieur. Un indice élevé traduit une offre de soins intra-GHT suffisamment diversifiée et une bonne organisation des transitions entre structures membres.

## Calcul
L'indice de continuité du parcours patient est calculé comme suit :

```
Indice de continuité (%) = (Nombre de parcours multi-séjours entièrement réalisés au sein du GHT / Nombre total de parcours multi-séjours initiés au sein du GHT) × 100
```

**Précisions méthodologiques** :
- Un parcours multi-séjours est défini comme une séquence d'au moins deux séjours consécutifs pour le même patient dans un délai défini (ex. : 30 ou 90 jours), avec continuité clinique identifiable (même pathologie ou lien de causalité entre les séjours).
- Le chaînage des séjours est réalisé via le NIR crypté disponible dans le PMSI (accès SNDS requis) ou via les identifiants locaux appariés entre établissements du GHT.
- Les parcours sont classés selon leur complétude : entièrement intra-GHT, partiellement intra-GHT (au moins un séjour hors GHT), ou entièrement hors GHT (fuite complète de parcours).
- L'analyse est segmentée par type de parcours (MCO → SSR, MCO → HAD, MCO → SSR → HAD) et par filière pathologique (AVC, fracture de hanche, cancérologie, chirurgie orthopédique, etc.).

## Utilité
- **Évaluation de la cohérence de l'offre intra-GHT** : identifier les maillons manquants dans la chaîne de soins du GHT (ex. : manque de SSR neurologique, absence de HAD sur certaines zones).
- **Suivi du projet médical partagé** : mesurer l'avancement de la structuration des filières inscrites dans le projet médical partagé du GHT.
- **Réduction des ruptures de parcours** : repérer les étapes où les patients quittent le GHT (MCO → SSR externe, SSR → HAD externe) pour cibler les actions correctives.
- **Optimisation des capacités** : dimensionner les capacités SSR, HAD et médico-sociales du GHT en fonction des besoins réels de continuité générés par l'activité MCO.
- **Communication institutionnelle** : valoriser la capacité du GHT à offrir un parcours complet et intégré auprès des patients, des médecins de ville et des tutelles.

## Sources de Données
- **PMSI MCO, SSR et HAD** : chaînage des séjours par NIR crypté pour reconstituer les parcours multi-structures au sein du GHT.
- **SNDS (Système National des Données de Santé)** : accès au chaînage longitudinal inter-séjours et inter-structures (requiert une autorisation CNIL/INDS).
- **Plateforme Trajectoire** : traçabilité des admissions SSR et HAD permettant de vérifier si l'orientation reste intra-GHT.
- **Données locales** : systèmes d'information hospitaliers (SIH) des établissements du GHT pour les appariements locaux sans recours au SNDS.

## Exemple de Valeurs
- **Filière fracture de hanche** : indice de continuité intra-GHT de 40-60 % dans les GHT bien organisés, contre 20-30 % dans les GHT fragmentés.
- **Filière AVC** : continuité MCO → SSR neurologique intra-GHT souvent inférieure à 50 % faute de SSR neurologique de proximité.
- **Filière cancérologie** : indice élevé (60-80 %) lorsque le GHT dispose d'un établissement support avec autorisation de traitement du cancer.
- **Parcours MCO → HAD intra-GHT** : très faible dans la majorité des GHT (<30 %), la HAD étant souvent assurée par des structures associatives extérieures.
- **Cible de continuité** : un objectif de 60-70 % de parcours entièrement intra-GHT est généralement retenu pour les filières prioritaires du projet médical partagé.

## Limites
- Le chaînage inter-séjours via le NIR crypté nécessite un accès au SNDS, soumis à des autorisations réglementaires strictes (CNIL, comité éthique).
- Un indice de continuité élevé n'implique pas nécessairement la meilleure qualité de soins : l'orientation vers une structure extérieure spécialisée peut être cliniquement préférable.
- La définition du délai maximal entre deux séjours pour constituer un parcours (30, 60 ou 90 jours) est arbitraire et influence fortement les résultats.
- Certaines ruptures de parcours sont choisies par le patient (retour à domicile volontaire, préférence pour un établissement connu) et ne reflètent pas une défaillance organisationnelle du GHT.
- L'indicateur agrège des parcours de complexité très différente, rendant les comparaisons globales peu informatives sans segmentation par filière.

## Références
- [ATIH - Méthodologie de chaînage PMSI](https://www.atih.sante.fr/)
- [SNDS - Système National des Données de Santé](https://www.snds.gouv.fr/)
- [Plateforme Trajectoire - Suivi des admissions SSR et HAD](https://trajectoire.sante-ra.fr/)
- [HAS - Guide méthodologique des parcours de soins](https://www.has-sante.fr/)
