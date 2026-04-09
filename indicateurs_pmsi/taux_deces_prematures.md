# Taux de Décès Prématurés

## Définition
Le taux de décès prématurés mesure la proportion de décès survenant pendant l'hospitalisation pour des pathologies ou procédures à faible mortalité attendue. Cet indicateur, issu des Patient Safety Indicators (PSI), est un marqueur de la sécurité des soins et de la qualité des prises en charge.

## Calcul
Le taux de décès prématurés est calculé comme suit :

```
Taux de décès prématurés (%) = (Nombre de décès pour des pathologies à faible mortalité / Nombre total de séjours pour ces pathologies) × 100
```

**Pathologies cibles** :
- Séjours pour des pathologies ou procédures avec un taux de mortalité attendu < 1% (ex : appendicectomie, hernie inguinale).
- Exclusion des patients avec comorbidités sévères (score de Charlson élevé).

## Utilité
- **Sécurité des soins** : Identifier des écarts par rapport aux attentes.
- **Benchmarking** : Comparaison entre établissements ou GHT.
- **Amélioration continue** : Cibler les spécialités ou processus à risque.

## Sources de Données
- **PMSI MCO** : Données issues des RSS, incluant les diagnostics (CIM-10) et le statut de sortie.
- **ATIH** : Référentiels de pathologies à faible mortalité.

## Exemple de Valeurs
- **Taux national moyen** : 0,1-0,5% (variable selon les pathologies).
- **Seuil d'alerte** : > 1% (investigation recommandée).

## Limites
- Dépend de la qualité du codage des diagnostics et des comorbidités.
- Nécessite un ajustement par score de sévérité (ex : Charlson).

## Références
- [DREES - PSI](https://drees.solidarites-sante.gouv.fr/)
- [ATIH - Mortalité Hospitalière](https://www.atih.sante.fr/)
