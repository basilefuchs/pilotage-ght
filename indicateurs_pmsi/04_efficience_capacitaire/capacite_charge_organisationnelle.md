# Capacité de Charge Organisationnelle

## Définition

En écologie des populations, la **capacité de charge** (carrying capacity, K) est la population maximale qu'un environnement peut soutenir de façon stable : au-delà de K, les ressources s'épuisent, la mortalité augmente, et la population décline. La croissance d'une population suit une courbe logistique — exponentielle au début, qui ralentit à l'approche de K et s'effondre au-delà. K est un seuil de soutenabilité, non une limite physique rigide : on peut dépasser K temporairement, mais au prix d'une dégradation des conditions.

Transposée à l'hôpital, la **Capacité de Charge Organisationnelle** (CCO) est le **niveau de charge (taux d'occupation, volume d'activité) au-delà duquel les indicateurs de qualité se dégradent de façon détectable et reproductible** : la DMS s'allonge, les réadmissions augmentent, les complications s'accumulent, la mortalité dérive. K n'est pas la capacité nominale (nombre de lits installés) ni le taux d'occupation réglementaire (85%) : c'est le seuil empirique, propre à chaque service et dérivé des données PMSI réelles, à partir duquel la surcharge produit une détérioration mesurable de la qualité.

La CCO révèle souvent que K_réel < K_nominal : certains services se dégradent dès 80% d'occupation, d'autres supportent 95% sans dommage. Elle permet également de détecter les **effets de seuil non-linéaires** — un service stable jusqu'à 85% qui se dégrade brutalement au-delà, plutôt que linéairement.

## Calcul

Construction de la relation charge–qualité :

```
Variable de charge X (au choix selon le service) :
  → Taux d'occupation hebdomadaire (journées réalisées / capacité installée × 7j)
  → Volume d'admissions hebdomadaires (nombre d'entrées / semaine)
  → Nombre moyen de patients présents simultanément (depuis la loi de Little)

Variables de qualité Y (indicateurs PMSI) :
  Y₁ = DMS observée de la semaine (ou du mois)
  Y₂ = Taux de réadmission à 30j (fenêtre glissante)
  Y₃ = Taux de complications (DA de complication / séjours)
  Y₄ = Taux de sorties non programmées (transferts urgents, sorties contre avis)
  Y₅ = Taux de déprogrammation chirurgicale (si applicable)

Série temporelle :
  → Calculer X et Y semaine par semaine sur 2-3 ans (100-150 observations)
  → Source : PMSI RSA agrégé par semaine ISO (ou par mois si volume insuffisant)
```

Détection du seuil K par régression segmentée :

```
Modèle de régression segmentée (breakpoint regression) :
  Y = α + β₁ × X                           si X ≤ K  (régime normal)
  Y = α + β₁ × K + β₂ × (X − K)           si X > K  (régime de surcharge)

  → K est le point de rupture (breakpoint) estimé par le modèle
  → β₁ = pente en régime normal (faible variation de Y avec X)
  → β₂ = pente en régime de surcharge (β₂ ≫ β₁ si effet de seuil)

Estimation du breakpoint K :
  → Algorithme de Davies (1987) ou de Muggeo (2003) pour les modèles segmentés
  → Implémentation Python : ruptures (Pelt, Binseg), statsmodels
  → Implémentation R : segmented (Muggeo), strucchange (Zeileis)

  Critère de confirmation du seuil :
    Test de Davies : p < 0.05 pour rejeter H₀ (pas de breakpoint)
    Rapport β₂/β₁ > 2 : la pente post-K est au moins double de la pente pré-K

Indicateur de criticité de la charge :
  IC = X_actuelle / K_estimé × 100   (en %)
  IC < 90%  : charge en dessous du seuil de dégradation → marge de sécurité
  IC 90-100% : approche du seuil → surveillance renforcée
  IC > 100% : au-delà de la capacité de charge → dégradation qualité en cours
```

Modèle de régression non-linéaire (version avancée) :

```
Si la dégradation est progressive (pas de rupture franche) :
  Modèle logistique de dégradation :
    Y(X) = Y_min + (Y_max − Y_min) / (1 + e^(−γ × (X − K)))

  où K = point d'inflexion (niveau de charge à mi-chemin de la dégradation)
  et γ = vitesse de dégradation autour de K

  → Y_min = qualité en régime de faible charge
  → Y_max = qualité en régime de surcharge maximale
  → K = capacité de charge au sens du point d'inflexion
  → γ = raideur de la transition (grand γ = transition brutale,
    petit γ = dégradation progressive)
```

## Utilité

- **Définir des seuils d'alerte de charge fondés sur des données réelles** : remplacer le seuil conventionnel de 85% d'occupation (issu de normes historiques, non empiriques) par un K propre à chaque service, calculé depuis la relation réelle charge-qualité observée dans les données PMSI — deux services peuvent avoir des K très différents selon leur organisation, leur casemix et leurs ressources humaines
- **Anticiper les dégradations de qualité avant qu'elles ne se produisent** : l'indice de criticité IC = X/K × 100, calculé en temps quasi-réel depuis les admissions hebdomadaires, est un signal précoce de tension — dès IC > 90%, déclencher des actions préventives (ouverture de lits supplémentaires, réorientation des admissions, renforcement des sorties organisées) avant que la qualité ne se dégrade effectivement
- **Mesurer l'impact des réorganisations sur la robustesse** : une réorganisation du service (ajout d'une infirmière de nuit, création d'une équipe mobile de sortie, refonte des protocoles) devrait augmenter K — démontrer quantitativement que la CCO a progressé après l'investissement organisationnel, pas seulement que le taux d'occupation moyen a changé
- **Comparer la robustesse entre établissements du GHT** : deux établissements avec le même taux d'occupation moyen peuvent avoir des K très différents — l'établissement avec K élevé est plus robuste et peut absorber des pics de charge sans dégradation ; identifier les facteurs organisationnels associés à un K élevé pour les diffuser dans le GHT
- **Justifier les demandes de capacité auprès des ARS** : "notre service dépasse sa CCO 18 semaines par an, générant une augmentation mesurable de la DMS de +1,8 jours et du taux de réadmission de +3 points au-delà du seuil K = 88%" est un argument factuel pour une demande de lits supplémentaires ou de renforcement en personnel

## Sources de Données

- **PMSI MCO RSA** : agrégé par semaine ISO — taux d'occupation (journées/capacité×7), admissions, DMS hebdomadaire, complications (DA), réadmissions calculées sur fenêtre glissante ; toutes les variables nécessaires sont dans le RSA standard
- **Données de capacité installée** (gestion interne) : nombre de lits ouverts par semaine (variable car fermetures estivales, travaux) — dénominateur du taux d'occupation ; si non disponible, utiliser la capacité autorisée constante comme proxy
- **PMSI SSR/PSY** : pour calculer la CCO des services de SSR et psychiatrie — mêmes méthodes, variables adaptées (taux d'occupation SSR, DMS SSR, gain MIF, rechutes en psychiatrie)

## Exemple de Valeurs

- **Service de médecine interne (30 lits, 2 ans de données hebdomadaires)** :
  Régression segmentée sur DMS ~ Taux_occupation :
  K_estimé = 87% (IC95% : 83-91%), p_Davies = 0.003
  β₁ = +0.8 jour de DMS par 10% d'occupation (régime normal, 0-87%)
  β₂ = +3.1 jours de DMS par 10% d'occupation (régime de surcharge, >87%)
  → Au-delà de 87% d'occupation, la DMS s'allonge 4× plus vite
  → En 2023, le service a dépassé K = 87% pendant 22 semaines (42% du temps)

- **Service de chirurgie viscérale (20 lits)** :
  K estimé sur taux de complications = 91% (service chirurgical plus résistant)
  K estimé sur taux de déprogrammation = 84% (les blocs saturent avant les lits)
  → Deux K différents selon l'indicateur — K_déprogrammation est le vrai seuil opérationnel

- **Comparaison inter-établissements (même type de service, GHT)** :
  Établissement A : K = 82%, β₂/β₁ = 5,2 (transition brutale)
  Établissement B : K = 91%, β₂/β₁ = 2,1 (transition progressive)
  → L'établissement B est plus robuste ET sa dégradation est plus progressive
    (plus de temps pour réagir) — organisation de référence à analyser

- **Fréquence de dépassement de K** :
  En France (données ATIH 2022), les services MCO dépassent leur CCO estimée
  en moyenne 15-25% du temps annuel — avec des pics importants en hiver et post-été

## Limites

- L'estimation du breakpoint K par régression segmentée requiert un **nombre suffisant d'observations au-delà du seuil** — si un service ne dépasse jamais 80% d'occupation, la relation charge-qualité au-delà de 80% n'est pas identifiable depuis les données historiques ; le seuil ne peut être estimé que si la charge a effectivement varié dans une plage suffisamment large
- La relation charge-qualité peut être **confondante** : un pic de charge en hiver coïncide avec un casemix plus lourd (patients plus sévères) — la dégradation de la DMS peut refléter le casemix, pas la charge en soi ; un ajustement sur la sévérité (Charlson hebdomadaire moyen) est nécessaire pour isoler l'effet charge net
- K est un **estimé ponctuel avec incertitude** — l'intervalle de confiance sur K peut être large (±5-10 points de taux d'occupation), rendant la définition d'un seuil d'alerte précis difficile ; communiquer une plage de K plutôt qu'une valeur unique et déclencher l'alerte dès IC > K_bas de l'IC95%
- La CCO est une propriété **dynamique** qui évolue avec l'organisation du service — une réorganisation, un recrutement ou un départ modifient K ; le modèle doit être recalibré après chaque changement organisationnel majeur, et les données antérieures à la réorganisation ne sont pas directement comparables aux données postérieures

## Références

- [Verhulst P.F. — Notice sur la loi que la population suit dans son accroissement, Correspondance Mathématique et Physique 1838 : équation logistique et capacité de charge]
- [Muggeo V.M.R. — Estimating regression models with unknown break-points, Statistics in Medicine 2003](https://doi.org/10.1002/sim.1545) — algorithme de référence pour l'estimation des breakpoints (package R segmented)
- [Davies R.B. — Hypothesis testing when a nuisance parameter is present only under the alternative, Biometrika 1987](https://doi.org/10.1093/biomet/74.1.33) — test de Davies pour la détection de breakpoints
- [Needleman J. et al. — Nurse-staffing levels and the quality of care in hospitals, NEJM 2002](https://doi.org/10.1056/NEJMsa012247) — démonstration empirique de la relation non-linéaire entre charge et qualité en soins infirmiers
- [Madsen F. et al. — High levels of bed occupancy associated with increased inpatient and thirty-day hospital mortality, Health Aff 2014](https://doi.org/10.1377/hlthaff.2013.1303) — effet de seuil empirique du taux d'occupation sur la mortalité
- [ATIH — Statistiques d'activité hospitalière MCO : taux d'occupation et indicateurs de qualité par GHM (rapports annuels)](https://www.atih.sante.fr/)
