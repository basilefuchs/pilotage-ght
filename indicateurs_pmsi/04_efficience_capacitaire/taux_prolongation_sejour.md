# Taux de Prolongation de Séjour

## Définition
Le taux de prolongation de séjour mesure la proportion de séjours dépassant significativement la durée attendue pour un groupe homogène de malades (GHM) donné. Cet indicateur, issu des Patient Safety Indicators (PSI), peut refléter des complications, des retards dans la prise en charge, ou des difficultés de sortie.

## Calcul
Le taux de prolongation de séjour est calculé comme suit :

```
Taux de prolongation de séjour (%) = (Nombre de séjours > percentile 90 / Nombre total de séjours pour le GHM) × 100
```

**Critères de prolongation** :
- Durée de séjour > percentile 90 de la distribution pour le GHM.
- Exclusion des séjours avec complications documentées (CIM-10).

## Utilité
- **Efficacité des parcours** : Identifier les retards dans la prise en charge.
- **Optimisation des lits** : Réduire les séjours injustifiablement longs.
- **Benchmarking** : Comparaison entre établissements ou GHT.

## Sources de Données
- **PMSI MCO** : Données issues des RSS, incluant les durées de séjour et les GHM.
- **ATIH** : Référentiels de durées attendues par GHM.

## Exemple de Valeurs
- **Taux national moyen** : 5-10% (variable selon les GHM).
- **GHM cibles** : Chirurgie orthopédique (prothèses), médecine interne.

## Limites
- Peut être influencé par des facteurs externes (ex : disponibilité des SSR).
- Nécessite un ajustement par complexité des cas.

## Références
- [DREES - PSI](https://drees.solidarites-sante.gouv.fr/)
- [ATIH - Durée de Séjour](https://www.atih.sante.fr/)
