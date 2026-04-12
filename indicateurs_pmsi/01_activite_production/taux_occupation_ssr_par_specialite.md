# Taux d'Occupation SSR par Spécialité

## Définition

Proportion de lits/places SSR (Soins de Suite et Réadaptation) effectivement occupés par rapport aux capacités autorisées, calculée par spécialité SSR (rééducation de l'appareil locomoteur, affections neurologiques, affections cardiovasculaires et pulmonaires, affections oncologiques et hématologiques, affections de la personne âgée polypathologique/gériatrie, addictologie, etc.). Les spécialités SSR sont définies par décret (articles R.6123-118 à R.6123-120 du CSP) et chaque établissement SSR dispose d'une autorisation par spécialité avec un nombre de lits agréés.

Le taux d'occupation mesure l'utilisation des capacités autorisées, qui diffère du taux d'occupation réel sur lits ouverts (un établissement peut avoir des lits autorisés mais temporairement fermés faute de personnel soignant). Cette distinction est opérationnellement importante : un taux de 95% sur lits autorisés avec 20% de lits fermés indique une saturation réelle de 100% sur lits ouverts. Indicateur fondamental pour le pilotage capacitaire d'un GHT : identifie les spécialités en tension (> 92% = saturation, liste d'attente, bed-blocking MCO en amont) et les spécialités en sous-utilisation (< 75% = sous-activité, financement T2A sous-optimal, efficience à questionner).

## Calcul

Sources :

```
1. PMSI SSR RHS (journées réalisées) :
   → Chaque RHS = résumé d'une semaine de présence du patient
   → Variable "nombre de jours de présence" dans la semaine (0-7)
   → Journées réalisées = Σ jours de présence de tous les RHS sur la période
   → Ventilées par spécialité SSR (code spécialité dans le RHS) et
     par établissement FINESS géographique

2. SAE — Statistique Annuelle des Établissements de Santé (capacités autorisées) :
   → Source officielle DREES : capacités autorisées par spécialité SSR
     et par établissement (lits d'hospitalisation complète + places d'HDJ)
   → Collecte annuelle, données N-1 disponibles en milieu d'année N
   → Format : lits autorisés par spécialité (code SPE SSR de la SAE)
```

Formule principale :

```
Taux d'occupation sur lits autorisés (%) =
  (Journées réalisées SSR / Journées théoriques autorisées) × 100

Journées théoriques autorisées = Lits autorisés × Nombre de jours dans la période
  → Année complète : Lits × 365
  → Trimestre      : Lits × 91 (ou 92)

Taux d'occupation sur lits ouverts (%) =
  (Journées réalisées SSR / Journées théoriques sur lits ouverts) × 100
  → Lits ouverts = Lits autorisés − Lits fermés temporairement
  → Source lits ouverts : tableaux de bord de gestion interne
    ou reconstruction via PMSI (lits ouverts = journées max observées / 7j)
```

Codification des spécialités SSR (PMSI et SAE) :

```
Code SPE SSR | Libellé
-------------|----------------------------------------------------------
01 / S01     | Affections de l'appareil locomoteur
02 / S02     | Affections du système nerveux (neurologie de rééducation)
03 / S03     | Affections cardiovasculaires
04 / S04     | Affections respiratoires
05 / S05     | Affections des systèmes digestif, métabolique et endocrinien
06 / S06     | Affections des systèmes urinaire et géniteur-reproducteur
07 / S07     | Affections oncologiques et hématologiques
08 / S08     | Affections du système nerveux — grands syndromes (cérébro-lésés lourds)
09 / S09     | Affections de la personne âgée polypathologique (gériatrie)
11 / S11     | Conduites addictives
```

Sous-indicateurs recommandés :

```
Taux par spécialité SSR et par établissement du GHT
Évolution trimestrielle (4 trimestres N vs N-1) — détection saisonnalité
Taux de lits fermés temporairement (%) = (Lits autorisés − Lits ouverts)
                                          / Lits autorisés × 100
  → Indicateur de tension RH (fermetures liées à des postes vacants)
Taux d'occupation des places de SSR partiel (HDJ, CAAP) séparément
  des lits d'hospitalisation complète
```

## Utilité

- **Identifier les spécialités SSR en saturation chronique** (> 92% sur l'année) qui génèrent du bed-blocking en amont dans les services MCO et justifient une demande d'autorisation de lits supplémentaires auprès de l'ARS, avec les données PMSI comme preuve objective
- **Repérer les spécialités sous-utilisées** (< 75%) pour analyser les causes et prendre des mesures correctives : tarification SSR inadaptée, offre non connue des prescripteurs MCO (défaut d'orientation), recrutement paramédical insuffisant (lits fermés), ou demande réelle insuffisante sur le territoire
- **Planification saisonnière** : le pic hivernal de la gériatrie (+8-12 points en jan-fév) et le creux estival de l'orthopédie programmée sont des patterns réguliers qui permettent d'anticiper les ouvertures/fermetures de lits et les besoins en personnel intérimaire
- **Dialogue CPOM ARS** : le taux d'occupation SSR est fréquemment un indicateur contractualisé dans les CPOM et les contrats de retour à l'équilibre — sa production depuis le PMSI permet un suivi continu entre deux collectes SAE
- **Pilotage RH SSR** : la corrélation entre le taux de lits fermés (faute de personnel) et le taux de bed-blocking MCO quantifie l'impact direct des vacances de postes paramédicaux SSR sur le fonctionnement global du GHT
- **Benchmarking GHT** : comparer les taux d'occupation SSR entre établissements membres du GHT sur une même spécialité pour identifier si la saturation est homogène (problème territorial global) ou concentrée sur un site (problème local d'organisation ou de capacités)

## Sources de Données

- **PMSI SSR RHS** : journées de présence par patient (variable "nb_jours_présence" dans chaque RHS), spécialité SSR (variable spé codée dans le RHS), FINESS géographique de l'établissement — base pour le calcul des journées réalisées
- **SAE (Statistique Annuelle des Établissements)** : capacités autorisées par spécialité SSR et par établissement — source officielle DREES, publiée annuellement (données N-1 disponibles en milieu d'année N sur data.drees.fr)
- **Tableau de bord ATIH SSR** : données d'activité SSR publiques par établissement et par spécialité, utiles pour le benchmarking régional et national
- **Données de gestion interne** : état journalier des lits ouverts/fermés par service — indispensable pour calculer le taux sur lits ouverts (non disponible dans le PMSI)

## Exemple de Valeurs

- **Taux d'occupation SSR national moyen (ATIH 2022)** : ~85-88% sur lits autorisés (hospitalisation complète)
- **Par spécialité** :

| Spécialité | Taux moyen national | Commentaire |
|---|---|---|
| Gériatrie polyvalente (S09) | 88-93% | Forte tension, pic hivernal |
| Neurologie de rééducation (S02/S08) | 85-90% | Offre concentrée, forte demande AVC/TC |
| Locomoteur (S01) | 80-87% | Saisonnalité chirurgie programmée |
| Cardiovasculaire/Pneumologie (S03/S04) | 78-85% | — |
| Oncologie (S07) | 75-82% | Fluctuations liées aux cycles de chimiothérapie |

- **Seuil de saturation opérationnel** : > 92% (liste d'attente documentée, bed-blocking MCO en amont)
- **Seuil de sous-activité** : < 75% (révision du projet médical ou des conventions de coopération à envisager)
- **Variation saisonnière gériatrie** : +8 à +12 points en janvier-février vs juillet-août

## Limites

- La SAE est renseignée annuellement par les établissements et peut présenter des décalages avec la réalité capacitaire infra-annuelle (fermetures temporaires, ouvertures de lits non reportées en cours d'année) — le numérateur PMSI (journées réalisées) est disponible mensuellement mais le dénominateur SAE (lits autorisés) est annuel, ce qui limite la granularité infra-annuelle
- Le taux sur lits autorisés peut être trompeur si l'établissement a des lits durablement fermés faute de personnel — un taux de 85% sur lits autorisés peut correspondre à 100% sur lits ouverts ; toujours croiser avec le taux de lits fermés issu des données de gestion
- La comparaison inter-établissements est limitée par les différences de case-mix intra-spécialité : un SSR neurologique spécialisé en cérébro-lésés lourds (DMS ~55j) a un profil d'occupation très différent d'un SSR neurologique généraliste (DMS ~30j), même à spécialité SAE identique
- Les séjours très longs (> 90 jours, souvent liés à des blocages médico-sociaux) occupent des lits sur de longues périodes et masquent le nombre de rotations réelles — le taux d'occupation brut est à compléter par le nombre de séjours et la DMS pour une lecture complète de l'activité

## Références

- [ATIH — Statistiques nationales PMSI SSR par établissement et par spécialité (données publiques annuelles)](https://www.atih.sante.fr/)
- [DREES — SAE : Statistique Annuelle des Établissements de Santé, documentation méthodologique](https://data.drees.solidarites-sante.gouv.fr/)
- [DREES — Les soins de suite et de réadaptation : panorama de l'offre, de l'activité et des besoins (2021)](https://www.drees.solidarites-sante.gouv.fr/)
- [IGAS — Rapport sur l'organisation des soins de suite et de réadaptation en France (2018)](https://www.igas.gouv.fr/)
- [HAS — Recommandations sur l'organisation du SSR spécialisé par spécialité (neurologique, locomoteur, gériatrique)](https://www.has-sante.fr/)
