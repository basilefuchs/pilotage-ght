# Taux de Césariennes Standardisé par Groupes de Robson (DREES)

## Définition

Le taux de césariennes standardisé par groupes de Robson est la proportion de césariennes rapportée à l'ensemble des accouchements, après stratification par les 10 groupes de Robson définissant des populations obstétricales homogènes en termes de risque et d'indication de césarienne. Il constitue l'outil de référence international (OMS, DREES, HAS) pour comparer la pertinence des pratiques obstétricales entre maternités en neutralisant les effets de casemix.

**Classification de Robson (10 groupes) :**

| Groupe | Définition |
|--------|-----------|
| 1 | Nullipare, grossesse unique, tête en présentation céphalique, ≥37 SA, travail spontané |
| 2 | Nullipare, grossesse unique, tête, ≥37 SA, travail déclenché ou césarienne avant travail |
| 3 | Multipare (sans utérus cicatriciel), grossesse unique, tête, ≥37 SA, travail spontané |
| 4 | Multipare (sans utérus cicatriciel), grossesse unique, tête, ≥37 SA, déclenchement ou césarienne avant travail |
| 5 | Antécédent de césarienne, grossesse unique, tête, ≥37 SA |
| 6 | Nullipare, présentation du siège |
| 7 | Multipare, présentation du siège (y compris utérus cicatriciel) |
| 8 | Grossesses multiples (y compris utérus cicatriciel) |
| 9 | Présentation transverse ou oblique |
| 10 | Grossesse unique, tête, <37 SA (y compris utérus cicatriciel) |

La standardisation calcule pour chaque maternité un **taux attendu de césariennes** basé sur la distribution de ses patientes dans les 10 groupes de Robson et les taux de référence nationaux par groupe (publiés par la DREES dans le Bilan périnatal). Le rapport observé/attendu est l'indicateur de pertinence.

Ratio_Robson = TC_observé / TC_attendu (si > 1 : surrecours aux césariennes vs pratique nationale pour ce casemix)

## Calcul

Source : PMSI MCO RSA — actes CCAM (accouchements et césariennes) + codes CIM-10 (DP/DA/DR obstétricaux).

```
Étape 1 — Identification des séjours d'accouchement
  DP ∈ {O80, O81, O82, O83, O84} (accouchement)  OU
  DP Z37.x (résultat de l'accouchement en diagnostic principal) avec acte CCAM
  Actes CCAM accouchement voie basse : JQHD001, JQHD002, JQHD003, JQHD004
  Actes CCAM césarienne : JQGD001

Étape 2 — Classification de chaque accouchement dans un groupe de Robson
  Variables nécessaires et codes CIM-10 correspondants :

  Parité :
    Nullipare : Z34.0, ou absence de code O34.2/O34.21/O34.22
    Multipare : antécédent de grossesse (code Z35.x ou contexte)

  Utérus cicatriciel :
    O34.2, O34.21, O34.22 (cicatrice utérine antérieure)

  Présentation :
    Céphalique : défaut (pas de code O32.x actif)
    Siège : O32.1, O32.2
    Transverse/oblique : O32.2, O32.3

  Terme gestationnel :
    ≥37 SA : absence de P07.x chez le nouveau-né ou O60 en DA
    <37 SA : DA O60.1x (travail prématuré) ou DA P07.x (nouveau-né)

  Grossesse multiple :
    DA O30.x (grossesse multiple)

  Début du travail :
    Spontané : absence de codes déclenchement (O61.x) et absence de CCAM déclenchement
    Déclenché : DA O61.x, actes CCAM JQJD002 (déclenchement) ou oxytocine CCAM
    Césarienne avant travail : acte CCAM JQGD001 sans O61 ni travail actif

Étape 3 — Calcul du taux brut par groupe de Robson
  Pour chaque groupe g :
    n_cesar_g = nb de césariennes (JQGD001) dans le groupe g
    n_total_g = nb d'accouchements dans le groupe g
    TC_g = n_cesar_g / n_total_g

Étape 4 — Taux attendu par standardisation indirecte
  TC_attendu = Σ_g (poids_g_local × TC_g_national)
    où poids_g_local = n_total_g_local / n_total_local
    et TC_g_national = taux de référence national par groupe (DREES ENP)

Étape 5 — Ratio observé/attendu
  Ratio_Robson = TC_observé / TC_attendu
  IC95% (méthode exacte de Poisson)
  Ratio > 1 : taux de césariennes supérieur à la pratique nationale à casemix identique
  Ratio < 1 : taux inférieur
```

Indicateurs dérivés :

```
Contribution par groupe de Robson :
  Contribution_g = (n_cesar_g / n_total) × 100
  → Identifier quel groupe tire le taux vers le haut (souvent groupe 5 : utérus cicatriciels)

Taux d'accouchement par voie basse après césarienne (AVAC) :
  AVAC = accouchements voie basse chez utérus cicatriciel (groupe 5) / total groupe 5
  → Indicateur DREES tableau de bord périnatalité
```

## Utilité

- **Benchmarker les maternités sur la pertinence des indications de césarienne** : deux maternités avec un taux brut de césariennes de 22% peuvent avoir des Ratios de Robson très différents (0,85 vs 1,30) si leurs casemix diffèrent ; seul le ratio standardisé permet une comparaison équitable au sein d'un GHT ou d'une région.
- **Identifier les leviers de réduction des césariennes primaires** : l'analyse de la contribution par groupe révèle si le surrecours vient des nullipares en travail spontané (groupe 1 — pratiques de surveillance du travail) ou des déclenchements (groupe 2 — politique de déclenchement), orientant les actions de formation ciblée.
- **Suivre l'impact des programmes qualité obstétricaux** : un programme de promotion de l'AVAC (accouchement voie basse après césarienne) doit se traduire par une baisse de la contribution du groupe 5 et une hausse du taux d'AVAC — suivi annuel du Ratio_Robson groupe 5.
- **Répondre aux attentes réglementaires HAS/DREES** : la HAS et la DREES publient des indicateurs de qualité de l'accouchement incluant le taux de césariennes standardisé dans les tableaux de bord des maternités (IPAQSS périnatalité) ; le calcul interne permet d'anticiper les résultats et de prioriser les plans d'action.
- **Informer les contrats de pôle obstétrique** : le Ratio_Robson est un indicateur de pilotage lisible par les équipes médicales et sage-femmes, utilisable dans les objectifs du contrat de pôle et le tableau de bord de la maternité.

## Sources de Données

- **PMSI MCO RSA** : codes CIM-10 (DP, DR, DA), actes CCAM, date d'entrée (pour le calcul du terme par déduction), identifiant séjour
- **DREES — Enquête Nationale Périnatale (ENP)** : taux nationaux de référence par groupe de Robson (2010, 2016, 2021), indispensables pour la standardisation
- **HAS — Indicateurs IPAQSS périnatalité** : définitions complémentaires et seuils d'alerte sur le taux de césariennes
- **OMS — Déclaration sur les taux de césarienne** (WHO/RHR/15.02) : référence pour les seuils cibles (10–15% pour les groupes 1–4)

## Exemple de Valeurs

- **Taux brut national (France 2021)** : ≈ 21,5% (DREES ENP 2021), stable depuis 2010
- **Taux cible OMS (groupes 1-4)** : 10–15%
- **Ratio_Robson attendu** : 1,00 (par définition de la standardisation)
- **Alerte surrecours** : Ratio_Robson > 1,20 (IC95% excluant 1,00) sur une maternité de niveau 2 ou 3
- **Maternité de niveau 1 (maternité périphérique, grossesses à faible risque)** : TC brut ≈ 16–20%, Ratio_Robson attendu ≈ 0,90–1,05
- **Maternité de niveau 3 (CHU, grossesses à haut risque)** : TC brut ≈ 30–40%, Ratio_Robson attendu ≈ 1,10–1,25 (casemix plus lourd justifie un taux plus élevé)
- **Contribution groupe 5 (utérus cicatriciel)** : ≈ 25–35% du total des césariennes dans la plupart des maternités
- **Seuil minimal** : ≥ 300 accouchements/an pour un calcul stable du Ratio_Robson

## Limites

- **Codage du terme gestationnel dans le PMSI** : l'âge gestationnel est souvent absent ou approximatif dans le PMSI français (pas de champ dédié) ; la reconstitution via les codes P07.x (nouveau-né) ou O60.x (travail prématuré) est imparfaite, pouvant mal classer des séjours en groupe 10.
- **Identification de la parité** : la parité n'est pas un champ structuré du PMSI ; l'algorithme de reconstruction à partir des antécédents obstétricaux CIM-10 est une approximation, surtout pour les patientes dont les accouchements précédents ont eu lieu dans d'autres établissements.
- **Exclusion des hôpitaux n'ayant pas de SAU/maternité** : les cliniques privées de niveau 1 ont des casemix de Robson très différents des CHU — la comparaison inter-niveaux nécessite une stratification explicite.
- **Évolution des pratiques non contrôlée** : la standardisation par les groupes de Robson ne neutralise pas toutes les sources de variabilité (pratiques de surveillance du travail, seuils de déclenchement, accès à l'analgésie péridurale) — un Ratio_Robson élevé n'implique pas automatiquement une pratique non conforme.
- **Version ENP de référence** : les taux de référence nationaux par groupe de Robson sont issus de l'ENP (tous les 5–6 ans) ; entre deux ENP, les taux de référence vieillissent et peuvent biaiser le Ratio_Robson.

## Références

- [Robson M. — Classification of caesarean sections, Fetal and Maternal Medicine Review 2001](https://doi.org/10.1017/S0965539501000122)
- [OMS — Déclaration sur les taux de césarienne, WHO/RHR/15.02, 2015](https://www.who.int/publications/i/item/WHO-RHR-15.02)
- [DREES — Enquête Nationale Périnatale 2021 — Rapport](https://www.santepubliquefrance.fr/etudes-et-enquetes/enquete-nationale-perinatale-2021)
- [HAS — Indicateurs de pratique clinique : Accouchement normal, 2017](https://www.has-sante.fr/)
- [Betrán A.P. et al. — Robson classification for caesarean section audit: a systematic review, BJOG 2016](https://doi.org/10.1111/1471-0528.13758)
- [ATIH — Guide méthodologique de production des données du PMSI MCO (version en vigueur)](https://www.atih.sante.fr/)
