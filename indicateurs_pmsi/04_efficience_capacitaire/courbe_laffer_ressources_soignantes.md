# Courbe de Laffer des Ressources Soignantes

## Définition

La **courbe de Laffer** (Arthur Laffer, 1974) est l'observation en économie fiscale qu'il existe un taux d'imposition optimal τ* qui maximise les recettes fiscales totales : en dessous de τ*, augmenter les impôts augmente les recettes ; au-delà de τ*, augmenter les impôts réduit les recettes (les contribuables s'évadent fiscalement, réduisent leur activité, ou quittent le territoire). À taux nul, recettes nulles ; à taux 100%, recettes nulles également. Entre les deux, il existe un maximum.

Transposée à la production hospitalière, la **Courbe de Laffer des Ressources Soignantes** (CLRS) modélise la relation entre la **charge de travail infligée aux soignants** (taux d'occupation, nombre d'actes/soignant) et la **production qualité-ajustée** totale (activité × qualité) — et prédit qu'il existe un point optimal au-delà duquel augmenter la charge réduit la production totale qualité-ajustée. Cette relation est distincte de la Capacité de Charge Organisationnelle (CCO) :
- La **CCO** mesure le seuil de charge K au-delà duquel la *qualité* se dégrade
- La **CLRS** mesure le seuil optimal de charge χ* qui *maximise la production totale qualité-ajustée* — qui peut être inférieur à K si la baisse de qualité réduit suffisamment la "valeur" produite pour compenser le gain de volume

**Production_QA(X) = Volume(X) × Qualité(X)**

où X est la charge (taux d'occupation ou actes/soignant), Volume(X) = λ × fonction croissante de X, et Qualité(X) = fonction décroissante de X au-delà de K. La production qualité-ajustée est un produit — elle est maximisée à un point χ* qui peut être inférieur à K.

## Calcul

Construction de la relation charge–production qualité-ajustée :

```
Variable de charge X(t) — taux d'occupation hebdomadaire (cf. CCO et MYO)

Variable de qualité Q(t) — indicateur composite hebdomadaire normalisé [0 ; 1] :
  Q(t) = 1 − [w₁ × Taux_complications(t) + w₂ × Taux_réadmissions(t) + w₃ × ΔDMS(t)]
  w₁ = 0.4, w₂ = 0.4, w₃ = 0.2
  → Q(t) ≈ 1 en période de bonne qualité, Q(t) < 1 en période de dégradation
  → ΔDMS(t) = (DMS_semaine_t − DMS_médiane_GHM) / DMS_médiane_GHM, normalisé

Variable de volume V(t) — activité hebdomadaire normalisée [0 ; 1] :
  V(t) = N_séjours(t) / N_séjours_max_historique

Production Qualité-Ajustée (PQA) :
  PQA(t) = V(t) × Q(t)   ∈ [0 ; 1]
  → Mesure la "valeur" produite chaque semaine : un volume élevé avec mauvaise qualité
    ou un volume faible avec excellente qualité ont la même PQA intermédiaire

Relation PQA(X) — ajustement polynomial :
  PQA(t) = α₀ + α₁ × X(t) + α₂ × X(t)²   (parabole inversée si Laffer existe)
  → Ajustement par régression polynomiale d'ordre 2 (OLS)
  → Condition de Laffer : α₁ > 0, α₂ < 0
    → La relation est en "cloche" : PQA augmente puis diminue avec la charge

Point optimal de Laffer χ* :
  χ* = −α₁ / (2 × α₂)   (maximum de la parabole)
  → χ* ∈ [0 ; 1] (taux d'occupation optimal)
  → IC95%(χ*) via delta-méthode ou bootstrap

Test de la forme en cloche :
  H₀ : α₂ = 0 (relation linéaire, pas de Laffer)
  H₁ : α₂ < 0 (relation en cloche, Laffer existe)
  p_valeur sur α₂ : si p < 0.05, la forme en cloche est confirmée
```

Indicateurs dérivés :

```
Écart au point de Laffer (EPL) :
  EPL = X_actuel − χ*   (en points de taux d'occupation)
  → EPL > 0 : service au-delà du point optimal — réduire la charge augmenterait PQA
  → EPL < 0 : service en dessous du point optimal — de la marge pour augmenter la charge
  → |EPL| < 5 points : service opérant proche de son optimum

Perte de production par rapport à l'optimum :
  Perte_PQA = PQA(χ*) − PQA(X_actuel)
  → Exprimée en % de la production qualité-ajustée maximale théorique
  → Traduit la perte économique et qualitative de l'éloignement du point de Laffer

Asymétrie de la courbe (sensibilité au sur/sous-chargement) :
  γ = (PQA(χ* − 5%) − PQA(X_actuel)) / (PQA(χ* + 5%) − PQA(X_actuel))
  → γ > 1 : la courbe chute plus vite à droite qu'à gauche de χ*
    → Surcharger est plus coûteux que sous-charger (asymétrie courante en soins)
  → γ < 1 : sous-charger est plus coûteux (rare, services avec économies d'échelle)
```

## Utilité

- **Fixer un objectif de taux d'occupation optimal différent du seuil de rupture K** : la CCO fournit le seuil K au-delà duquel la qualité se dégrade ; la CLRS fournit χ*, qui peut être inférieur à K, comme objectif de taux d'occupation maximisant la valeur produite totale — dans les services à forte asymétrie (γ élevé), χ* peut être 5-10 points en dessous de K, suggérant que l'objectif de 85% d'occupation est trop élevé pour certains services
- **Répondre à la question "peut-on augmenter l'activité sans dégrader la qualité globale ?"** : si EPL < 0 (service en dessous de χ*), augmenter l'activité augmente simultanément le volume ET la qualité-ajustée totale ; si EPL > 0 (service au-delà de χ*), augmenter l'activité augmente le volume mais réduit PQA — la "croissance" produit en réalité moins de valeur ; argument factuel pour refuser des objectifs d'activité supplémentaires irréalistes
- **Quantifier le coût caché de la surcharge en termes de production perdue** : "notre service opère à X_actuel = 93% alors que χ* = 85% — la surcharge nous fait perdre 8 points de PQA, soit l'équivalent de X séjours de qualité normale par semaine en réadmissions, complications et prolongations de DMS" ; argument concret pour justifier une réduction de la pression d'activité
- **Comparer les profils de Laffer entre services** : deux services avec le même χ* mais des courbures α₂ différentes ont des tolérances à la surcharge différentes — celui avec α₂ fortement négatif chute vite au-delà de χ* (fragile), celui avec α₂ faiblement négatif est plus tolérant ; cette information guide l'allocation de marges de manœuvre capacitaires dans le GHT
- **Outil de dialogue avec les financeurs sur la pertinence des objectifs d'activité** : dans les CPOM et les contrats de retour à l'équilibre, les objectifs d'activité sont souvent fixés sans considération de leur impact sur la qualité ; la CLRS démontre quantitativement que des objectifs trop ambitieux réduisent la valeur totale produite — argument pour une discussion basée sur la PQA plutôt que sur le volume brut

## Sources de Données

- **PMSI MCO RSA** (séries hebdomadaires sur 2-3 ans) : même base que la CCO et le MYO — taux d'occupation X(t), DMS hebdomadaire, taux de complications (DA), taux de réadmissions (chaînage NIR) ; agrégation par UM/service par semaine ISO
- **La CLRS, la CCO et le MYO forment un triptyque calculé sur la même infrastructure de données** : les trois indicateurs se complètent sans coût additionnel de collecte, et leurs résultats se renforcent mutuellement pour une analyse complète du comportement sous charge du service

## Exemple de Valeurs

- **Service de médecine interne (N=104 semaines, 30 lits)** :
  Ajustement polynomial : PQA = −0,82 + 2,21 × X − 1,43 × X²
  α₁ = 2,21 > 0, α₂ = −1,43 < 0 (forme en cloche confirmée, p = 0,003)
  χ* = 2,21 / (2 × 1,43) = **0,77** (77% d'occupation optimale)
  X_actuel moyen = 0,89 → **EPL = +12 points** (service sur-chargé de 12 points)
  Perte PQA = PQA(0,89) − PQA(0,77) = **−0,09** (9% de la PQA maximale perdus par surcharge)

- **Service de chirurgie ambulatoire (N=104 semaines)** :
  χ* = 0,91 (économies d'échelle importantes, χ* élevé)
  X_actuel = 0,84 → EPL = −7 points (service sous-chargé, marge de croissance)
  → La CLRS légitime une augmentation d'activité : EPL < 0 = pas de risque de Laffer

- **Comparaison de profils de Laffer** :
  Réanimation : χ* = 0,72, α₂ = −2,8 (courbe très courbée → chute rapide au-delà de χ*)
  Chirurgie viscérale : χ* = 0,84, α₂ = −0,9 (courbe aplatie → tolérance à la surcharge)
  → La réanimation chute 3× plus vite que la chirurgie viscérale au-delà de leur optimum
    → Marges de sécurité différentes : réanimation doit rester à X < 0,75, chirurgie peut aller à 0,88

- **Perte PQA annualisée due à la surcharge (service médecine interne)** :
  Perte hebdomadaire PQA = 0,09 (9% de la PQA optimale)
  → Équivalent en séjours perdus : 0,09 × 52 semaines × 3 séjours/semaine = **14 séjours-qualité/an**
  → En termes de coût qualitatif : 14 séjours × coût_réadmission_moyen = estimation financière possible

## Limites

- L'ajustement polynomial d'ordre 2 impose **a priori** une forme en cloche symétrique — or la relation réelle peut être asymétrique (chute plus abrupte à droite) ou suivre une forme différente (plateau puis chute soudaine) ; tester des formes alternatives (splines, LOESS) et vérifier que la parabole est un ajustement acceptable (R², test RESET)
- La **définition de la PQA comme produit V × Q** suppose que volume et qualité ont des poids égaux — ce choix normatif peut être discuté ; une pondération alternative (PQA = V^α × Q^β avec α + β = 1) modifie χ* et doit être explicitée dans tout usage
- La relation charge–qualité varie fortement selon le **casemix** : en période de forte saisonnalité, X est élevé ET le casemix est plus lourd (hiver), ce qui dégrade la qualité indépendamment de la charge ; sans contrôle du casemix dans la régression, χ* est biaisé vers le bas (le système paraît atteindre son optimum à une charge plus faible que la réalité)

## Références

- [Laffer A. — The Laffer Curve: Past, Present and Future, Heritage Foundation 2004 : formalisation de la courbe de Laffer]
- [Needleman J. et al. — Nurse-staffing levels and the quality of care in hospitals, NEJM 2002](https://doi.org/10.1056/NEJMsa012247) — relation charge infirmière/qualité, premier empirical Laffer en soins
- [Aiken L.H. et al. — Hospital nurse staffing and patient mortality, nurse burnout, and job dissatisfaction, JAMA 2002](https://doi.org/10.1001/jama.288.16.1987)
- [Kane R.L. et al. — The association of registered nurse staffing levels and patient outcomes, Medical Care 2007](https://doi.org/10.1097/MLR.0b013e3181468ca3)
- [ATIH — Statistiques MCO : séries temporelles d'activité, de DMS et de complications par GHM et par service](https://www.atih.sante.fr/)
