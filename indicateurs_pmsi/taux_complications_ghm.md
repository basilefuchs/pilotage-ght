# Taux de Complications par GHM

## Définition
Le taux de complications par GHM mesure la proportion de séjours pour lesquels des complications spécifiques au groupe homogène de malades (GHM) sont survenues. Ces complications sont identifiées via des codes CIM-10 spécifiques et reflètent la qualité des prises en charge pour des pathologies données.

## Calcul
Le taux de complications par GHM est calculé comme suit :

```
Taux de complications par GHM (%) = (Nombre de séjours avec complications pour un GHM / Nombre total de séjours pour ce GHM) × 100
```

**Critères de complications** :
- Codes CIM-10 spécifiques (ex : infections post-op, complications de procédures).
- Exclusion des complications présentes à l'admission.

## Utilité
- **Qualité des soins** : Identifier les GHM avec des taux de complications anormalement élevés.
- **Benchmarking** : Comparaison entre établissements ou GHT pour un même GHM.
- **Amélioration continue** : Cibler les processus à optimiser.

## Sources de Données
- **PMSI MCO** : Données issues des RSS, incluant les diagnostics associés (CIM-10).
- **ATIH** : Référentiels de complications par GHM.

## Exemple de Valeurs
- **GHM "Prothèse totale de hanche"** : Taux de complications = 2-5%.
- **GHM "Pontage coronarien"** : Taux de complications = 5-10%.
- **Variation inter-établissements** : Peut varier du simple au double.

## Limites
- Dépend de la qualité du codage des complications.
- Ne distingue pas les complications évitables des inévitables.

## Références
- [ATIH - Complications par GHM](https://www.atih.sante.fr/)
- [HAS - Qualité des Soins](https://www.has-sante.fr/)
