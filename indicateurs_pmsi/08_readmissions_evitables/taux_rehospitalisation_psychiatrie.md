# Taux de Réhospitalisation à 30 Jours en Psychiatrie

## Définition

Cet indicateur mesure la proportion de patients hospitalisés en psychiatrie (hospitalisation temps plein — HTP) qui sont réhospitalisés dans un établissement de psychiatrie dans les 30 jours suivant leur sortie, tous modes de sortie confondus à l'exception des décès et des transferts programmés. Il est stratifié par groupe diagnostique principal (CIM-10 : schizophrénie F20-F29, épisodes dépressifs F32-F33, troubles bipolaires F30-F31, troubles anxieux/névrotiques F40-F48, troubles liés aux substances F10-F19) pour distinguer les profils de rechute selon la pathologie. La réhospitalisation précoce en psychiatrie est à la fois un indicateur de résultat (qualité de la prise en charge intra-hospitalière et préparation de la sortie) et un indicateur de continuité des soins (efficacité du relais ambulatoire par les Centres Médico-Psychologiques, Hôpital De Jour, structures médico-sociales). Elle est reconnue comme indicateur de qualité par la Haute Autorité de Santé dans le cadre du programme IFAQ et du Manuel de Certification 2020. La réhospitalisation à 30 jours est aussi un proxy des ruptures de parcours en santé mentale, particulièrement sensible dans les territoires avec faible densité en psychiatres ambulatoires ou délais d'accès aux CMP élevés.

## Calcul

La population d'index et les modalités de calcul sont les suivantes :

```
Population d'index (séjour index) :
  → Tous les séjours en Hospitalisation à Temps Plein (HTP) en psychiatrie
  → PMSI RIM-P : RSP avec champ "psychiatrie" (PMSI RIM-P, anciennement RPS)
  → Mode de prise en charge : temps plein (TP=1 dans la variable MODE_HEB)
  → Date de sortie disponible (DATESOR non manquante)
  → Exclusions :
      - Décès en cours de séjour index (MODE_SORT = 9)
      - Transferts directs vers un autre établissement MCO/SSR (MODE_SORT = 6, 7)
      - Séjours index < 24h (hospitalisations de moins d'un jour)
      - Patients < 18 ans (indicateur adulte ; pédopsychiatrie = indicateur distinct)

Identification des réhospitalisations :
  → Chaînage par NIR crypté (identifiant pseudonymisé SNDS)
  → Toute nouvelle HTP en psychiatrie dans les 30 jours suivant DATESOR du séjour index
  → Établissements du GHT uniquement (pilotage interne) OU tous établissements France
    (vision territoriale globale recommandée pour éviter le biais d'attribution)
  → Fenêtre de temps : J1 à J30 post-sortie (J0 = date de sortie, non incluse)
```

Formule de l'indicateur principal :

```
Taux de réhospitalisation à 30j en psychiatrie (%) :
  = (Nombre de séjours index suivis d'une réhospitalisation HTP dans les 30j
     / Total de séjours index éligibles) × 100

Unité d'analyse : le SEJOUR (et non le patient), conformément à la méthodologie HAS
Période de calcul recommandée : année civile glissante (N-1) ou trimestre
```

Stratification diagnostique par groupe CIM-10 :

```
Stratification par diagnostic principal (DP) du séjour index :
  Groupe F20-F29 : Schizophrénie et troubles psychotiques
  Groupe F30-F31 : Troubles de l'humeur bipolaires
  Groupe F32-F33 : Épisodes dépressifs et dépression récurrente
  Groupe F40-F48 : Troubles anxieux, névrotiques, somatoformes
  Groupe F10-F19 : Troubles liés à l'utilisation de substances psychoactives
  Groupe F60-F69 : Troubles de la personnalité
  Autres F*     : Autres diagnostics psychiatriques
```

Sous-indicateurs de parcours ambulatoire post-sortie (PMSI RIM-P + DCIR) :

```
Sous-indicateurs de continuité des soins :
  → Taux de contact CMP/HDJ à J7 : proportion de patients avec ≥1 consultation
    ambulatoire en psychiatrie (PMSI ambulatoire ou DCIR actes CCAM/NGAP psychiatrie)
    dans les 7 jours suivant la sortie HTP
  → Taux de contact CMP/HDJ à J30 : idem, fenêtre élargie à 30 jours
  → Délai médian première consultation ambulatoire post-sortie (en jours)
  → Taux de patients sans aucun contact ambulatoire à J30 (rupture totale de parcours)
  → Taux de passage aux urgences à J30 avant réhospitalisation éventuelle
    (Mode d'entrée = 8 pour le séjour de réhospitalisation)
```

Indicateur sentinelle de risque suicidaire :

```
Indicateur additionnel : comportements suicidaires à 30j post-sortie
  → DP ou DA du séjour de réhospitalisation contenant :
      X60-X84 (lésions auto-infligées volontaires)
      T36-T50 + X61-X64 (intoxications médicamenteuses volontaires)
      Z91.5 (antécédent d'automutilation)
  → Calcul : (réhospitalisations avec codage suicidaire / total séjours index) × 100
  → Seuil d'alerte : > 5% dans les 30j pour les groupes F32-F33 et F20-F29
```

## Utilité

- **Indicateur de qualité des soins et de préparation de sortie** : un taux élevé de réhospitalisation à 30 jours signale soit une sortie prématurée (stabilisation insuffisante), soit une planification de sortie défaillante (absence de rendez-vous CMP à la sortie, rupture de traitement) — il permet d'identifier les unités ou les médecins avec des pratiques de sortie à améliorer
- **Mesure de l'efficacité du relais ambulatoire** : le croisement avec les sous-indicateurs de contact CMP/HDJ à J7 permet de démontrer que les réhospitalisations évitables sont concentrées chez les patients sans contact ambulatoire précoce — argument pour renforcer les dispositifs de contact J3-J7 post-sortie (protocoles de suivi téléphonique, consultations infirmières)
- **Pilotage territorial de la santé mentale** : en vision GHT, l'indicateur met en évidence les disparités territoriales d'accès aux soins psychiatriques ambulatoires — les secteurs avec délai CMP > 14 jours présentent structurellement des taux de réhospitalisation plus élevés, ce qui appuie les demandes de renforcement de capacité ambulatoire
- **Dialogue avec les ARS et le financement** : la psychiatrie est en cours de réforme tarifaire (passage de la dotation annuelle de financement vers un modèle à l'activité) — les indicateurs de qualité de parcours, dont la réhospitalisation, seront probablement intégrés aux mécanismes de financement à la qualité (IFAQ psychiatrie)
- **Surveillance du risque suicidaire post-hospitalisation** : la fenêtre J0-J30 est reconnue comme la période de risque suicidaire maximal post-hospitalisation psychiatrique ; l'indicateur sentinelle (comportements suicidaires à 30j) est un outil de vigilance pour les équipes de direction et les CME
- **Évaluation des programmes de case management** : mesurer l'impact des programmes de suivi intensif en milieu ouvert (SIAO, équipes mobiles psychiatrie-précarité) sur le taux de réhospitalisation en comparant les patients bénéficiaires versus non-bénéficiaires via le chaînage NIR

## Sources de Données

- **PMSI RIM-P (Recueil d'Information Médicalisé en Psychiatrie)** : base nationale des séjours psychiatriques HTP, avec diagnostic principal (DP CIM-10), date d'entrée/sortie, mode d'hospitalisation (temps plein/partiel), mode de sortie — base principale pour l'identification des séjours index et des réhospitalisations
- **NIR crypté SNDS** : identifiant pseudonymisé permettant le chaînage longitudinal entre séjours de psychiatrie d'établissements différents — indispensable pour la vision territoriale (réhospitalisations hors GHT incluses)
- **PMSI RIM-P ambulatoire** : consultations et actes réalisés dans les structures ambulatoires psychiatriques (CMP, CATTP, HDJ) — permet le calcul des sous-indicateurs de contact ambulatoire post-sortie
- **DCIR ER_PRS_F** : actes de consultation psychiatrique en ville (codés en nomenclature CCAM ou NGAP : consultation psychiatre de ville = C = cotation de référence) — complète le PMSI ambulatoire pour les prises en charge entièrement réalisées hors structures hospitalières
- **DCIR ER_PHA_F** : dispensations de médicaments psychotropes (antipsychotiques ATC N05A, antidépresseurs N06A, thymorégulateurs N03A) — permet de calculer le PDC (Proportion of Days Covered) post-sortie comme proxy de l'observance thérapeutique ambulatoire

## Exemple de Valeurs

- **Taux national de réhospitalisation à 30j en HTP psychiatrie (France, ATIH 2022)** : environ 15-20 % tous diagnostics confondus — avec une forte variabilité inter-établissements (8-30 %)
- **Schizophrénie (F20-F29)** : taux le plus élevé, typiquement 20-28 % à 30 jours — pathologie chronique avec rechutes fréquentes, particulièrement sensible aux ruptures de traitement antipsychotique
- **Épisodes dépressifs (F32-F33)** : 10-15 % à 30j — indicateur sentinelle particulièrement important en raison du risque suicidaire élevé dans cette fenêtre temporelle
- **Troubles bipolaires (F30-F31)** : 15-22 % à 30j — forte sensibilité à la rupture de thymorégulateur (lithium, valproate) traçable via DCIR
- **Impact du contact CMP à J7 (Knudsen S.V. et al., Clin Epidemiol 2022)** : les patients ayant un contact ambulatoire dans les 7 jours post-sortie présentent un taux de réhospitalisation à 30j réduit de 30-40 % par rapport aux patients sans contact précoce — effet le plus marqué pour la schizophrénie
- **Patients sans aucun contact ambulatoire à J30** : environ 35-40 % en France selon les secteurs — proportion qui double dans les territoires à faible densité psychiatrique (zones rurales, DOM-TOM)

## Limites

- Le PMSI RIM-P historiquement moins exhaustif que le PMSI MCO : des séjours courts ou des ré-hospitalisations dans des établissements privés non lucratifs (ESPIC) peuvent être manqués selon la qualité du chaînage SNDS disponible au niveau du GHT
- La distinction hospitalisation volontaire / sous contrainte (soins sous contrainte : SDT, SDRE) n'est pas toujours finement codée dans le PMSI RIM-P, alors qu'elle est cliniquement déterminante pour interpréter un taux de réhospitalisation (un patient sous contrainte réhospitalisé n'a pas le même profil de risque qu'un patient en soins libres)
- Le chaînage avec les CMP (PMSI ambulatoire psychiatrie) est variable selon les établissements : certains CMP ne transmettent pas encore leur activité en format RIM-P ambulatoire, entraînant une sous-estimation du taux de contact ambulatoire post-sortie dans certains secteurs
- Le taux brut n'est pas standardisé sur la sévérité diagnostique ni sur la durée du séjour index — un service prenant en charge des patients schizophrènes très sévères présentera structurellement un taux plus élevé qu'un service orienté troubles anxieux, d'où la nécessité de la stratification diagnostique pour tout benchmark inter-établissements
- Les réhospitalisations planifiées (hospitalisation de semaine récurrente, programme de reconditionnement) ne sont pas distinguées des réhospitalisations non planifiées dans le codage PMSI actuel — elles peuvent artificiellement gonfler le taux dans certaines unités utilisant ce mode de prise en charge

## Références

- [Knudsen S.V. et al. — Quality indicators for inpatient psychiatric care: challenges and perspectives, Clin Epidemiol 2022, DOI: 10.2147/CLEP.S322392](https://doi.org/10.2147/CLEP.S322392)
- [HAS — Indicateurs de qualité et sécurité des soins en psychiatrie (IFAQ 2022-2024)](https://www.has-sante.fr/jcms/p_3315729/fr/indicateurs-de-qualite-et-de-securite-des-soins-en-psychiatrie)
- [ATIH — Rapport annuel PMSI psychiatrie RIM-P 2022 : analyse de l'activité et des indicateurs de qualité](https://www.atih.sante.fr/)
- [Haute Autorité de Santé — Manuel de Certification 2020, critère 3.5 : continuité et coordination des soins en psychiatrie](https://www.has-sante.fr/)
- [Fond FHF / DGOS — Plan de transformation de la psychiatrie et de la santé mentale 2018-2023 : indicateurs de suivi du parcours post-hospitalisation](https://solidarites-sante.gouv.fr/)
