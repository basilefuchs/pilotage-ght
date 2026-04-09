# Taux de Mortalité Hospitalière Ajustée

## Définition
Le taux de mortalité hospitalière ajustée mesure la proportion de décès survenant à l'hôpital, corrigée par des facteurs de risque (âge, comorbidités, sévérité des cas). Cet indicateur est essentiel pour évaluer la qualité et la sécurité des soins, notamment dans les CHU où les cas sont plus complexes.

## Calcul
Le taux de mortalité ajustée est calculé comme suit :

```
Taux de mortalité ajustée (%) = (Nombre de décès observés / Nombre de décès attendus) × 100
```

Où :
- **Décès attendus** : Calculés via des modèles prédictifs (ex : modèle SMR - Standardized Mortality Ratio).
- **Facteurs d'ajustement** : Âge, GHM, comorbidités (CMA), score de sévérité (ex : SAPS II en réanimation).

## Utilité
- **Qualité des soins** : Identifier des écarts par rapport aux attentes.
- **Benchmarking** : Comparaison entre établissements ou services.
- **Amélioration continue** : Cibler les spécialités ou processus à améliorer.

## Sources de Données
- **PMSI MCO** : Statut de sortie (décès) et données cliniques (GHM, CMA).
- **Bases de données cliniques** : Scores de sévérité (ex : SAPS II, APACHE).
- **ATIH** : Modèles de référence pour l'ajustement.

## Exemple de Valeurs
- **Taux national ajusté** : ~2-4% (variable selon les spécialités).
- **Réanimation** : 8-12% (ajusté par SAPS II).
- **Objectif** : Taux inférieur ou égal à la moyenne nationale ajustée.

## Limites
- L'ajustement dépend des modèles utilisés (risque de biais).
- Ne prend pas en compte les décès post-sortie (ex : à domicile).

## Références
- [ATIH - Mortalité Hospitalière](https://www.atih.sante.fr/)
- [HAS - Indicateurs de Qualité](https://www.has-sante.fr/)
