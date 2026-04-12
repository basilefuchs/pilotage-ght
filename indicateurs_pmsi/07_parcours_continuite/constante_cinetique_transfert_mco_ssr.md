# Constante Cinétique des Transferts MCO→SSR

## Définition

En cinétique chimique, une **réaction du premier ordre** décrit un processus dans lequel le taux de transformation d'un réactif est proportionnel à la quantité de réactif présente : dN/dt = −k × N, dont la solution est N(t) = N₀ × e^(−kt). La constante de vitesse k caractérise entièrement la cinétique de la réaction : grande k = réaction rapide, petite k = réaction lente. La **demi-vie** t₁/₂ = ln(2)/k est le temps nécessaire pour que la moitié du réactif soit transformé.

Transposé aux transferts MCO→SSR, la **Constante Cinétique de Transfert** (CKT) modélise la fraction de patients MCO "en attente de transfert SSR" (réactif) qui transitent effectivement vers le SSR chaque jour (transformation). Si le processus suit une cinétique du premier ordre, la probabilité qu'un patient soit transféré à une date donnée est constante et indépendante de la durée d'attente déjà écoulée — comme la désintégration radioactive. La demi-vie t₁/₂ est le délai médian de transfert MCO→SSR : le délai au-delà duquel 50% des patients éligibles ont été transférés.

**k = ln(2) / t₁/₂_transfert**

Un k élevé = filière fluide, transferts rapides ; un k faible = filière lente, bed-blocking structurel. L'écart entre k_observé et k_attendu (calculé depuis les recommandations HAS ou les meilleures pratiques) quantifie l'inefficience de la filière. La CKT permet aussi de **tester si la cinétique est réellement du premier ordre** — si elle ne l'est pas, cela révèle une hétérogénéité cachée dans la population en attente (certains patients transitent toujours rapidement, d'autres jamais, indépendamment de leur durée d'attente).

## Calcul

Identification de la cohorte et mesure des délais :

```
Cohorte : séjours MCO avec transfert vers SSR sur la période d'analyse
  → Chaînage PMSI MCO RSA + PMSI SSR RHS par NIR crypté
  → Inclure : séjours MCO avec mode de sortie = transfert vers SSR (MODE_SORTIE = 6)
  → Délai de transfert Δᵢ = DATE_ENT_SSR_i − DATE_SOR_MCO_i (en jours)
    → Δᵢ = 0 : transfert le jour même (direct)
    → Δᵢ > 0 : délai entre sortie MCO et entrée SSR (patient en attente)
    → Δᵢ < 0 : incohérence de dates (à exclure ou investiguer)

Populations complémentaires (pour l'analyse de survie) :
  → Patients éligibles au SSR mais non transférés (retour à domicile, décès, HAD)
    → Données censurées à droite dans le modèle de survie
  → Nécessite de définir l'éligibilité SSR : DP MCO dans les CIM-10 ciblées par le SSR
    (ex. AVC → SSR neurologique, PTH/PTG → SSR locomoteur)
```

Estimation de la constante cinétique k (méthode de survie) :

```
Fonction de survie S(t) = P(Δ > t) = fraction de patients pas encore transférés à t jours

Estimation non-paramétrique : Kaplan-Meier sur les délais Δᵢ
  → S(t) tracée sur [0 ; T_max]
  → t₁/₂ = délai médian de transfert = t tel que S(t) = 0.50

Test du modèle cinétique du premier ordre :
  Si la cinétique est du premier ordre : S(t) = e^(−kt)
  → ln(S(t)) doit être linéaire en t
  → Vérifier la linéarité sur le graphe de Nelson-Aalen : H(t) = −ln(S(t))
  → Si H(t) est linéaire en t : cinétique du 1er ordre confirmée, k = pente de H(t)
  → Si H(t) est concave (pente décroissante) : cinétique ralentit avec le temps
    → Interprétation : les patients qui restent longtemps en attente sont
      structurellement moins transférables (hétérogénéité de la cohorte)
  → Si H(t) est convexe (pente croissante) : cinétique accélère avec le temps
    → Interprétation : effet de "mise en route" de la filière,
      ou pression croissante sur le MCO pour libérer les lits

Estimation paramétrique de k :
  Modèle exponentiel : ajustement de S(t) = e^(−kt) par maximum de vraisemblance
  k_MLE = 1 / Δ_moyen    (si cinétique du 1er ordre vérifiée)
  IC95%(k) = [k_MLE / (1 + 1.96/√N) ; k_MLE × (1 + 1.96/√N)]

  Demi-vie : t₁/₂ = ln(2) / k_MLE   (en jours)
```

Indicateurs dérivés :

```
k par type de filière :
  k_neuro    = constante cinétique MCO→SSR neurologique (AVC, traumatisme crânien)
  k_locomot  = constante cinétique MCO→SSR locomoteur (PTH, PTG, fractures)
  k_geriatrie = constante cinétique MCO→SSR gériatrique
  k_cardio   = constante cinétique MCO→SSR cardiovasculaire
  → Comparer les k entre filières : identifier les filières les plus lentes

k par établissement d'origine (MCO) et de destination (SSR) :
  k_A→B = constante cinétique entre le service MCO A et le SSR B
  → Matrice k entre tous les couples (MCO, SSR) du GHT
  → Identifier les couples avec k faible : axes de bed-blocking
    qui méritent une convention bilatérale renforcée ou un lit dédié

Délai de transfert au-delà duquel 90% des patients ont transité :
  t₉₀ = −ln(0.10) / k = 2.303 / k
  → Mesure la "queue lourde" de la distribution (patients bloqués très longtemps)

Score de fluidité de filière (SFF) :
  SFF = k_observé / k_cible × 100
  k_cible = ln(2) / t₁/₂_cible
    avec t₁/₂_cible = délai médian cible selon les recommandations HAS :
    ex. AVC → SSR neuro : t₁/₂_cible = 3 jours (délai < 5j recommandé)
        PTH → SSR locomoteur : t₁/₂_cible = 5 jours
  SFF = 100% : filière exactement conforme à la cible
  SFF < 70% : filière lente, investigation recommandée
  SFF > 130% : filière très rapide (vérifier que les critères d'admission SSR sont respectés)
```

## Utilité

- **Mesurer objectivement la fluidité de chaque filière MCO→SSR** : le délai médian seul (t₁/₂) est insuffisant — deux filières avec le même délai médian peuvent avoir des cinétiques très différentes si l'une a une queue lourde (quelques patients bloqués très longtemps) et l'autre une distribution homogène ; la constante k et la forme de H(t) révèlent cette structure cachée
- **Identifier la nature du goulot d'étranglement** : si H(t) est concave (cinétique ralentit), les patients qui attendent le plus longtemps sont structurellement différents (comorbidités incompatibles avec les critères SSR, absence de place en SSR spécialisé) — action sur les critères d'admission SSR ; si H(t) est linéaire, le goulot est homogène — action sur la capacité SSR ou la fluidité administrative
- **Benchmarking inter-établissements du GHT** : la constante k est comparable entre services et établissements indépendamment du volume de transferts — un service de 50 transferts/mois peut être comparé à un service de 200 transferts/mois si la cinétique du premier ordre est vérifiée ; identifier les établissements SSR avec k élevé (bonnes pratiques d'admission) comme références
- **Simuler l'impact de créations de lits SSR** : avec un modèle cinétique calibré, simuler l'effet d'une augmentation de capacité SSR de X% sur le délai médian de transfert et le nombre de journées de bed-blocking économisées — argument quantitatif pour les demandes de création de lits SSR auprès de l'ARS
- **Suivi de l'impact des conventions MCO-SSR** : avant/après la signature d'une convention de coopération ou la création de lits dédiés de post-réanimation, mesurer l'évolution de k — démonstration quantitative de l'efficacité des actions organisationnelles sur la fluidité de la filière
- **Prévision des journées de bed-blocking** : depuis k et le volume d'entrées en MCO éligibles au SSR, calculer le stock moyen de patients MCO en attente de SSR (loi de Little appliquée à la filière) : L = λ × t₁/₂ — outil de prévision du nombre de lits MCO "bloqués" par la filière à tout moment

## Sources de Données

- **PMSI MCO RSA** : mode de sortie (MODE_SORTIE = 6 pour transfert SSR), DATE_SOR, code FINESS de l'établissement de destination — pour identifier les transferts et calculer la date de sortie MCO
- **PMSI SSR RHS** : DATE_ENT_SSR, code FINESS de l'établissement MCO d'origine (FINESS_ET_ORIGINE dans le RHS) — pour calculer le délai Δᵢ = DATE_ENT_SSR − DATE_SOR_MCO ; le chaînage par NIR crypté est nécessaire pour les transferts inter-établissements
- **Algorithme d'analyse de survie** : Python (lifelines : KaplanMeierFitter, ExponentialFitter), R (survival : survfit, survreg) — estimation de k par maximum de vraisemblance et tests de la forme de H(t)
- **Référentiels de délais cibles** (HAS, DGOS) : délais recommandés de transfert par filière — pour calculer k_cible et le Score de Fluidité de Filière ; publications SOFMER (Société Française de Médecine Physique et de Réadaptation) pour les filières SSR neurologiques et locomotrices

## Exemple de Valeurs

- **Filière AVC → SSR neurologique (GHT semi-rural, N=180 transferts/an)** :
  Distribution des délais Δᵢ : médiane = 4j, P75 = 9j, P90 = 18j
  Test de H(t) : linéaire de 0 à 7j, puis convexe → cinétique du 1er ordre
  sur les 7 premiers jours, queue lourde au-delà
  k_observé = ln(2)/4 = 0,173 transferts/jour
  k_cible (HAS : délai < 5j recommandé) = ln(2)/3 = 0,231 transferts/jour
  **SFF = 0,173/0,231 × 100 = 75%** — filière lente, amélioration possible
  t₉₀ = 18j → 10% des patients AVC attendent plus de 18j leur place SSR neuro

- **Filière PTH/PTG → SSR locomoteur (même GHT)** :
  Médiane = 2j, k = 0,347 transferts/jour, SFF = 115%
  H(t) linéaire → cinétique du 1er ordre homogène → filière fluide et homogène
  → La convention PTH/PTG entre le service orthopédie et le SSR locomoteur fonctionne bien

- **Impact simulé d'une augmentation de 20% de capacité SSR neuro** :
  Stock moyen actuel (loi de Little) : L = λ × t₁/₂ = (180/365) × 4 = 1,97 lits MCO bloqués
  Avec +20% de capacité : t₁/₂ estimé à 2,5j → L = 0,49 × 2,5 = 1,23 lits bloqués
  **Économie : 0,74 lit MCO libéré en permanence = ~270 journées/an désengorgées**

- **Hétérogénéité de la cohorte AVC** : en stratifiant par sévérité (NIHSS < 5 vs ≥ 5),
  deux cinétiques distinctes apparaissent :
  AVC léger : k = 0,231 (SFF = 100%), t₁/₂ = 3j
  AVC sévère : k = 0,087 (SFF = 38%), t₁/₂ = 8j
  → Le goulot concerne exclusivement les AVC sévères (manque de places SSR spécialisé lourd)

## Limites

- Le **chaînage MCO→SSR inter-établissements** requiert le NIR crypté (accès SNDS) — en l'absence d'accès SNDS, seuls les transferts intra-GHT entre établissements partageant leur PMSI sont chaînables ; les transferts vers des SSR extérieurs au GHT (privés, autres GHT) ne sont pas observables depuis les données locales
- La **censure à droite** (patients MCO éligibles qui n'ont jamais été transférés — retour à domicile, décès, HAD) doit être correctement gérée dans le modèle de survie — une exclusion de ces patients biaise k vers le haut (cinétique apparemment plus rapide) car on ne sélectionne que les patients qui ont effectivement transité ; l'analyse de survie avec censure est indispensable
- Le modèle du **premier ordre** est une simplification — en réalité, la probabilité de transfert d'un patient dépend de sa durée d'attente, de la disponibilité des lits SSR (variable externe), et du profil du patient (variables internes) ; un modèle de Cox (risques proportionnels) avec covariables est plus riche mais plus complexe à interpréter opérationnellement
- La **date de sortie MCO** dans le PMSI peut différer de la date réelle de transfert (saisie administrative différée, séjour clos informatiquement avant le transfert physique) — des incohérences de dates (Δᵢ < 0 ou Δᵢ > 30j sans explication) signalent des problèmes de qualité de données avant toute interprétation de la cinétique

## Références

- [Atkins P.W., de Paula J. — Physical Chemistry, Oxford University Press 2014 : cinétique chimique du premier ordre et demi-vie]
- [Cox D.R. — Regression models and life-tables, Journal of the Royal Statistical Society B 1972](https://doi.org/10.1111/j.2517-6161.1972.tb00899.x) — modèle de Cox, fondement de l'analyse de survie moderne
- [Kaplan E.L., Meier P. — Nonparametric estimation from incomplete observations, Journal of the American Statistical Association 1958](https://doi.org/10.2307/2281868) — estimateur Kaplan-Meier
- [HAS — Orientation en soins de suite et de réadaptation : critères et délais (2013)](https://www.has-sante.fr/)
- [SOFMER — Référentiel de bonnes pratiques de la filière de soins en MPR : délais de transfert recommandés par pathologie (2020)](https://www.sofmer.com/)
- [ATIH — Guide méthodologique de production des informations relatives à l'activité médicale SSR : chaînage MCO-SSR](https://www.atih.sante.fr/)
