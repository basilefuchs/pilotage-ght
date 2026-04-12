# Rendement de Carnot de la Filière de Soins

## Définition

Le **cycle de Carnot** (Sadi Carnot, 1824) est le cycle thermodynamique théorique d'efficacité maximale : il définit la borne supérieure du rendement de toute machine thermique opérant entre une source chaude (température T_H) et une source froide (température T_C). Aucune machine réelle ne peut dépasser ce rendement théorique :

**η_Carnot = 1 − T_C / T_H**

Le rendement de Carnot augmente quand l'écart entre T_H et T_C est grand (grand potentiel à transformer) et approche de 1 quand T_C → 0 (extraction maximale du potentiel). Le rendement réel d'une machine est toujours inférieur à η_Carnot en raison des irréversibilités (frottements, pertes thermiques) — l'écart entre rendement réel et rendement de Carnot mesure les pertes.

Transposé à une filière de soins, le **Rendement de Carnot de la Filière** (RCF) adapte cette logique à la transformation de la sévérité clinique à l'entrée en résultat de santé à la sortie :

- **T_H (source chaude)** = sévérité clinique initiale du patient à l'entrée (potentiel de dégradation — énergie à transformer)
- **T_C (source froide)** = état résiduel après prise en charge (complications non évitées, morbidité résiduelle)
- **η_réel** = fraction du potentiel de sévérité effectivement "transformée" en amélioration de santé (réduite par les complications, les actes non pertinents, les pertes d'information)

**RCF = 1 − Morbidité_résiduelle / Sévérité_initiale**

Un RCF = 1 signifierait une prise en charge parfaite (zéro complication, zéro morbidité résiduelle). Un RCF = 0 signifierait que la prise en charge n'a rien apporté (état de sortie identique à l'entrée). Un RCF négatif (théoriquement possible) signifierait que la prise en charge a aggravé l'état du patient.

## Calcul

Construction des proxies de sévérité initiale et de morbidité résiduelle depuis le PMSI :

```
T_H — Sévérité initiale à l'entrée (potentiel de soins) :
  T_H = score composite calculé à partir des données du séjour index MCO :

  Option 1 — Indice de Charlson (comorbidités des séjours antérieurs + DA actuels) :
    T_H = Charlson_i   (calculé sur les DA + DP + séjours MCO des 24 mois précédents)
    → Plage : 0-30+

  Option 2 — Poids GHM du séjour (proxy de la sévérité économique) :
    T_H = Poids_GHM_i × Niveau_GHM_i   (niveau 1-4)
    → Niveau 4 (avec CMAS) = plus forte comorbidité associée

  Option 3 — Score composite normalisé [0 ; 1] :
    T_H = 0.5 × (Charlson_normalisé) + 0.3 × (Niveau_GHM/4) + 0.2 × (N_DA/N_DA_max)
    → Pondérations ajustables par pathologie

T_C — Morbidité résiduelle à la sortie (irréversibilités de la prise en charge) :
  T_C = score de complications et de pertes liées à la prise en charge :

  Composante 1 — Complications intra-séjour (irréversibilités internes) :
    C_intra = (N_DA_complications_YT / N_DA_total) × poids_complication
    → DA des chapitres T80-T88 (complications des soins), Y40-Y84 (effets adverses)

  Composante 2 — Réadmission post-sortie (irréversibilités résiduelles) :
    C_readm = 1 si réadmission à 30j, 0 sinon
    → Proxy : la réadmission révèle une résolution incomplète de la pathologie

  Composante 3 — Prolongation de séjour (irréversibilités temporelles) :
    C_DMS = max(0 ; DMS_i − DMS_médiane_GHM) / DMS_médiane_GHM
    → Fraction de la DMS dépassant la médiane nationale de référence

  T_C = w₁ × C_intra_normalisée + w₂ × C_readm + w₃ × C_DMS
    w₁ = 0.4, w₂ = 0.4, w₃ = 0.2   (pondérations suggérées)
    → T_C ∈ [0 ; 1] par construction

Calcul du RCF individuel et de cohorte :
  RCF_i = 1 − T_C_i / T_H_i   (avec T_H_i et T_C_i normalisés sur [0 ; 1])

  Note : si T_H_i = 0 (patient sans comorbidité et GHM niveau 1),
    le RCF est non défini (division par zéro) → exclure les séjours avec T_H = 0

  RCF_service = médiane(RCF_i) sur tous les séjours du service
    ou moyenne pondérée par T_H_i (pondérer les patients plus lourds)

  Distribution : P25, P50, P75, P10, P90 des RCF individuels
    → P10 identifie les séjours avec les moins bons rendements (cibles d'amélioration)
```

Rendement de Carnot maximal théorique (borne supérieure) :

```
Par analogie directe avec Carnot :
  η_max = 1 − T_C_min / T_H_max
  → T_C_min = morbidité résiduelle minimale observée (meilleurs cas de la cohorte)
  → T_H_max = sévérité initiale maximale de la cohorte

  Écart au Carnot = η_max − RCF_service_observé
  → Mesure le potentiel d'amélioration restant avant d'atteindre le maximum théorique
  → Un écart élevé = beaucoup de "pertes d'irréversibilité" à réduire

  Efficience relative = RCF_service / η_max × 100 (%)
  → % du rendement maximal théorique atteint par le service
```

## Utilité

- **Mesurer l'efficience thérapeutique nette d'une filière en une seule valeur** : le RCF synthétise en un seul indicateur ce que le service "fait avec" la sévérité de ses patients — un service traitant des patients très sévères (T_H élevé) avec peu de complications et peu de réadmissions a un RCF élevé ; un service traitant des patients légers (T_H faible) avec beaucoup de complications a un RCF faible, révélant des irréversibilités disproportionnées
- **Benchmarking ajusté sur la sévérité d'entrée** : deux services avec des taux de complications identiques mais des T_H très différents ne sont pas comparables — le RCF intègre la sévérité dans le calcul et rend les comparaisons équitables entre des services à casemix différents ; un service de réanimation avec RCF = 0,65 n'est pas comparable à un service de chirurgie élective avec RCF = 0,65
- **Identifier les "irréversibilités" dominantes** : la décomposition T_C en trois composantes (complications intra-séjour, réadmissions, prolongation de DMS) identifie quelle source de "pertes" domine dans un service — si C_intra est forte mais C_readm faible, les irréversibilités sont internes au séjour (agir sur les protocoles de prévention des complications) ; si C_readm domine, les irréversibilités sont post-sortie (agir sur le suivi ambulatoire)
- **Évaluation de l'impact des protocoles de qualité** : un protocole de prévention des infections nosocomiales, une politique de récupération rapide après chirurgie (RAAC), ou un programme de prévention des chutes devrait augmenter le RCF en réduisant T_C sans changer T_H — mesurer ΔρCF avant/après est l'indicateur de résultat du programme, ajusté sur la sévérité des patients
- **Détection des séjours à faible rendement** : les séjours individuels avec RCF_i < P10 (bas rendement) identifient les cas où la prise en charge a produit le moins d'amélioration par rapport au potentiel initial — candidats prioritaires pour les revues de morbi-mortalité ciblées sur l'efficience et non seulement sur les événements graves

## Sources de Données

- **PMSI MCO RSA** : DP, DA (pour Charlson et complications T80-T88, Y40-Y84), GHM et niveau (1-4), DMS individuelle, MODE_SORTIE — toutes les variables nécessaires à T_H et T_C sont dans le RSA standard
- **PMSI MCO RSA (chaînage NIR)** : séjours antérieurs pour le calcul du Charlson sur 24 mois, séjour de réadmission à 30j pour C_readm — chaînage nécessaire mais possible sur données PMSI locales intra-GHT ou SNDS pour les séjours inter-établissements
- **Base ATIH DMS nationales par GHM** : DMS_médiane_GHM de référence nationale pour calculer C_DMS — publiée annuellement par l'ATIH

## Exemple de Valeurs

- **Service de chirurgie cardiaque (N=180 séjours)** :
  T_H médian = 0,62 (patients sévères), T_C médian = 0,19
  RCF médian = 1 − 0,19/0,62 = **0,69**
  η_max = 1 − T_C_min/T_H_max = 1 − 0,04/0,85 = 0,95
  Efficience relative = 0,69/0,95 × 100 = **73%** — 27% du potentiel théorique non atteint
  Irréversibilité dominante : C_DMS (DMS fréquemment > médiane nationale) = 0,11/0,19 = 58%
  → Action prioritaire : réduire les prolongations de DMS

- **Service de médecine interne (N=1200 séjours)** :
  T_H médian = 0,38, T_C médian = 0,14
  RCF médian = 1 − 0,14/0,38 = **0,63**
  Irréversibilité dominante : C_readm (réadmissions à 30j = 14%) = 0,06/0,14 = 43%
  → Action prioritaire : programme de sortie structuré et suivi post-hospitalisation

- **Distribution des RCF individuels (service de pneumologie)** :
  P10 = 0,25, P25 = 0,48, P50 = 0,67, P75 = 0,82, P90 = 0,91
  → Les 10% de séjours avec RCF < 0,25 (RCF très faibles) constituent la cible
    de la démarche qualité — revue individuelle de ces séjours par la CME

- **Impact d'un protocole RAAC (chirurgie colorectale)** :
  RCF avant RAAC : médian = 0,61, C_DMS = 0,08 (composante principale)
  RCF après RAAC : médian = 0,74, C_DMS = 0,03
  ΔρCF = +0,13 — amélioration significative de l'efficience thérapeutique

## Limites

- Le RCF est très sensible à la **normalisation des scores T_H et T_C sur [0 ; 1]** — le choix des bornes de normalisation (Charlson max = 10 vs 20 vs 30) modifie les valeurs absolues de RCF et rend les comparaisons inter-études délicates ; standardiser les bornes de normalisation et les documenter explicitement
- La composante **C_readm** est binaire (réadmission oui/non) — elle traite une réadmission à J1 et une réadmission à J29 de façon identique, ce qui est une approximation grossière ; une version continue (pondérée par le délai de réadmission depuis la FRWR) serait plus précise mais plus complexe à calculer
- L'analogie avec le cycle de Carnot est **métaphorique** — le rendement de Carnot est un résultat mathématique exact pour les machines thermiques, pas pour les systèmes de soins ; les "températures" T_H et T_C ne sont pas de vraies températures thermodynamiques mais des proxies construits de façon ad hoc ; l'analogie guide la construction de l'indicateur mais ne doit pas être poussée au-delà de ce qu'elle peut supporter

## Références

- [Carnot S. — Réflexions sur la puissance motrice du feu, Bachelier 1824 : premier énoncé du cycle de Carnot et du rendement thermodynamique maximal]
- [Clausius R. — Über die bewegende Kraft der Wärme, Annalen der Physik 1850 : formalisation du deuxième principe de la thermodynamique]
- [Quan H. et al. — Coding algorithms for defining comorbidities in ICD-9-CM and ICD-10 administrative data, Med Care 2005](https://doi.org/10.1097/01.mlr.0000182534.19832.83)
- [ATIH — Classification des GHM et niveaux de sévérité (CM, CMA, CMAS) : guide méthodologique](https://www.atih.sante.fr/)
- [HAS — Indicateurs de résultats en chirurgie : réadmissions, complications, durée de séjour (2021)](https://www.has-sante.fr/)
