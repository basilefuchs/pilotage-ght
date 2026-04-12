# Ratio de Sharpe de la Performance Qualité

## Définition

Adapté de la finance (William Sharpe, 1966), le ratio de Sharpe mesure le rendement ajusté au risque d'un portefeuille : rendement excédentaire (au-dessus du "taux sans risque") divisé par la volatilité (écart-type des rendements). Appliqué à la performance qualité hospitalière, il mesure l'excédent de performance par rapport à un benchmark de référence, rapporté à la variabilité de cette performance dans le temps. Formule de base en finance : S = (R_p − R_f) / σ_p, où R_p est le rendement du portefeuille, R_f le taux sans risque, et σ_p l'écart-type des rendements.

En performance qualité PMSI, le Ratio de Sharpe-Qualité (RSQ) est défini comme :

**RSQ = (Performance_observée − Performance_de_référence) / Volatilité_mensuelle**

où la "performance de référence" est le benchmark national (taux moyen national ATIH ou HAS pour l'indicateur choisi) — l'équivalent du "taux sans risque" financier — et la "volatilité" est l'écart-type des mesures mensuelles ou trimestrielles de l'indicateur sur la période d'observation.

La rupture conceptuelle par rapport aux indicateurs classiques est décisive : **deux établissements avec la même performance moyenne ont des RSQ très différents si leur variabilité diffère**. Un établissement avec un taux de réadmission moyen de 12% (meilleur que la moyenne nationale de 14%) mais avec une forte variabilité mensuelle (σ = 4%) a un RSQ de 0,5 ; un autre établissement avec le même taux moyen de 12% mais une variabilité de 1% a un RSQ de 2,0. Le second est qualitativement supérieur car sa performance est stable et prévisible — c'est la dimension que tous les indicateurs de moyenne ignorent.

## Calcul

Construction du RSQ pour un indicateur de qualité donné :

```
Paramètres d'entrée :
  → Indicateur de qualité I (ex. taux de réadmission à 30j, taux de complication
    PSI-90, taux de retour domicile SSR, gain MIF moyen, FPY)
  → Série temporelle : I_m = valeur de l'indicateur pour le mois m
    (recommandé : 24-36 mois d'historique pour stabilité statistique)
  → Benchmark de référence I_ref = valeur nationale de référence (ATIH, HAS, IQSS)
    → Équivalent du "taux sans risque" financier = performance atteignable
      sans effort différenciant, représentant la norme du marché

Calcul :
  Performance_excédentaire = Ī − I_ref
    où Ī = moyenne de la série I_m sur la période

  Volatilité = σ = écart-type de la série I_m

  RSQ = (Ī − I_ref) / σ

Conventions de signe (adapter selon le sens de l'indicateur) :
  Pour les indicateurs "plus bas = meilleur" (taux de complication, réadmission) :
    Performance_excédentaire = I_ref − Ī  (positif si meilleur que référence)
    RSQ = (I_ref − Ī) / σ

  Pour les indicateurs "plus haut = meilleur" (gain MIF, FPY, retour domicile) :
    RSQ = (Ī − I_ref) / σ  (positif si meilleur que référence)
```

Interprétation du RSQ :

```
RSQ < 0    : Performance inférieure à la référence nationale
             → Priorité d'amélioration absolue
RSQ 0-0.5  : Performance légèrement supérieure à la référence
             mais très variable → gains instables, non consolidés
RSQ 0.5-1  : Bonne performance avec variabilité modérée
             → Résultats satisfaisants mais perfectibles en termes de stabilité
RSQ 1-2    : Excellente performance ajustée au risque
             → Service fiable, résultats stables et supérieurs à la norme
RSQ > 2    : Performance exceptionnelle très stable
             → Benchmark interne à étudier et dupliquer
```

RSQ multi-indicateurs et score composite :

```
RSQ composite d'un service (pondération à définir) :
  RSQ_composite = w1 × RSQ(FPY) + w2 × RSQ(réadmission) + w3 × RSQ(complication)
                  + w4 × RSQ(MIF ou autre outcome)

Matrice RSQ × Volatilité pour un portefeuille d'indicateurs :
  Quadrant 1 (RSQ élevé, σ faible)  : zone d'excellence stable → benchmark
  Quadrant 2 (RSQ élevé, σ élevée)  : bons résultats mais instables → consolider
  Quadrant 3 (RSQ faible, σ faible)  : mauvais résultats stables → corriger
  Quadrant 4 (RSQ faible, σ élevée) : mauvais résultats instables → urgence
```

## Utilité

- **Réhabiliter la notion de régularité dans l'évaluation de la qualité** : un service peut être "bon en moyenne" mais peu fiable (un mois excellent, un mois très mauvais) — ce profil est pire pour les patients qu'un service légèrement moins bon mais constant. Le RSQ formalise cette intuition clinique en un ratio objectif
- **Priorisation des actions d'amélioration** : un service en quadrant 4 (RSQ < 0 ET σ élevée) doit être traité en priorité absolue ; un service en quadrant 2 (RSQ > 1 mais σ élevée) a des bases solides mais a besoin d'un travail de standardisation des pratiques (protocoles, checklists) pour réduire la variance
- **Évaluation des démarches de standardisation** : mesurer si l'introduction d'un protocole chirurgical, d'une checklist, ou d'un programme de formation réduit σ (volatilité) sans dégrader Ī (performance moyenne) — un RSQ qui augmente grâce à une baisse de σ traduit une montée en maturité organisationnelle
- **Outil de management par la qualité** : le RSQ est directement utilisable dans les revues de performance qualité des CME et des pôles — il offre une conversation différente de "votre taux de complication est de X%", en posant la question "votre performance est-elle fiable et reproductible ?"
- **Comparaison inter-spécialités sur une base commune** : un RSQ exprimé en unités de σ est comparable entre des indicateurs de natures très différentes (taux de réadmission MCO, gain MIF SSR, taux de retour domicile) — il permet un classement des spécialités par performance ajustée au risque sans problème d'unités
- **Suivi de l'évolution dans le temps** : l'amélioration du RSQ peut provenir d'une hausse de la performance (Ī − I_ref augmente) ou d'une réduction de la variabilité (σ diminue) ou des deux — la décomposition de la progression du RSQ en ses deux composantes guide les leviers d'action

## Sources de Données

- **PMSI MCO RSA** : série temporelle mensuelle de l'indicateur de qualité retenu (taux de complication PSI-90, taux de réadmission 30j, FPY) — sur 24-36 mois pour la stabilité statistique du σ
- **PMSI SSR RHS** : série temporelle mensuelle du gain MIF, taux de retour à domicile, taux de réhospitalisation MCO depuis SSR — pour les services SSR
- **Référentiels ATIH / HAS / IQSS** : valeurs de référence nationales (I_ref) par indicateur — source du "taux sans risque" de la formule
- **Extraction mensuelle régulière** : la qualité du RSQ dépend de la granularité temporelle — des données trimestrielles (N=8 points sur 2 ans) donnent un σ moins stable que des données mensuelles (N=24 points) ; privilégier l'extraction mensuelle

## Exemple de Valeurs

- **Service de chirurgie orthopédique exemple** :
  - Taux de réadmission moyen 30j : 8,2% (référence nationale : 10,5%)
  - σ mensuelle : 1,8% → RSQ = (10,5 − 8,2) / 1,8 = **1,28** → Excellente performance stable
- **Service de cardiologie exemple** :
  - Taux de réadmission moyen 30j : 9,1% (référence nationale : 14,0%)
  - σ mensuelle : 6,2% → RSQ = (14,0 − 9,1) / 6,2 = **0,79** → Bonne performance mais très variable
- **Service SSR gériatrie exemple** :
  - Taux de retour domicile : 52% (référence nationale : 50%)
  - σ mensuelle : 3,5% → RSQ = (52 − 50) / 3,5 = **0,57** → Performance légèrement supérieure mais instable
- **Benchmark financier** : un ratio de Sharpe > 1 est considéré "bon" en finance ; en qualité hospitalière, RSQ > 1 traduit une performance stable et significativement supérieure au benchmark national

## Limites

- Le RSQ requiert une série temporelle de 24-36 mois minimum pour que l'écart-type σ soit statistiquement stable — les établissements ne disposant pas d'un historique PMSI local de cette longueur ne peuvent pas calculer un RSQ fiable ; l'approche est inapplicable pour les nouveaux services ou les indicateurs récemment définis
- Sensibilité à la valeur de référence choisie : le RSQ dépend directement du benchmark I_ref — une valeur de référence sous-estimée (trop basse) gonfle artificiellement le RSQ de tous les établissements ; utiliser systématiquement les valeurs ATIH/HAS publiées pour l'année N-1, et documenter la source
- La normalité de la distribution de I_m est implicitement supposée dans l'interprétation standard du ratio de Sharpe — si la distribution est fortement asymétrique (queues épaisses = quelques mois très mauvais), le σ sous-estime le risque réel ; recommander de vérifier la distribution et d'utiliser le Ratio de Sortino (qui ne pénalise que les déviations négatives) si l'asymétrie est prononcée
- Risque de "volatility suppression" : un service qui reporte moins fréquemment ses événements indésirables (sous-codage PMSI) aura mécaniquement un σ plus faible et donc un RSQ plus élevé — le RSQ doit être interprété conjointement avec le taux de complétude du codage diagnostique

## Références

- [Sharpe W.F. — Mutual fund performance, Journal of Business 1966 : définition originale du ratio de Sharpe](https://doi.org/10.1086/294846)
- [Sortino F.A., Price L.N. — Performance measurement in a downside risk framework, Journal of Investing 1994 : ratio de Sortino, variante pénalisant uniquement les déviations négatives]
- [Berwick D.M. — Continuous improvement as an ideal in health care, NEJM 1989 : application des méthodes de contrôle statistique de la qualité aux soins](https://doi.org/10.1056/NEJM198901053200110)
- [Mohammed M.A. et al. — Statistical process control charts in healthcare, BMJ 2008 : limites de contrôle statistique et détection des variations de performance](https://doi.org/10.1136/bmj.a1739)
- [ATIH — Indicateurs de qualité et sécurité des soins IQSS : valeurs nationales de référence (publiées annuellement)](https://www.atih.sante.fr/)
