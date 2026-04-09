# Durée Médiane de Séjour par GHM

## Définition
La durée médiane de séjour par GHM mesure le temps médian passé à l'hôpital pour un groupe homogène de malades (GHM) donné. Contrairement à la durée moyenne, la médiane est moins sensible aux valeurs extrêmes (séjours très longs), offrant une vision plus robuste de la durée typique de séjour.

## Calcul
La durée médiane de séjour est calculée comme suit :

```
Durée médiane de séjour = Médiane des durées de séjour pour un GHM donné
```

**Méthode** :
1. Classer les durées de séjour par ordre croissant pour le GHM.
2. Identifier la valeur centrale (50ème percentile).

## Utilité
- **Pilotage des parcours** : Évaluer la durée typique de prise en charge par pathologie.
- **Benchmarking** : Comparaison entre établissements ou GHT pour un même GHM.
- **Optimisation des lits** : Identifier les GHM avec des durées de séjour anormalement longues.

## Sources de Données
- **PMSI MCO** : Données issues des RSS, incluant les durées de séjour et les GHM.
- **ATIH** : Référentiels de GHM pour l'analyse comparative.

## Exemple de Valeurs
- **GHM "Appendicectomie"** : Durée médiane = 2 jours.
- **GHM "Pneumonie sévère"** : Durée médiane = 7 jours.
- **Variation inter-établissements** : Peut varier de ±20% pour un même GHM.

## Limites
- Ne reflète pas la complexité des cas (contrairement à la DMS ajustée).
- Peut masquer des variations importantes si la distribution est asymétrique.

## Références
- [ATIH - Durée de Séjour](https://www.atih.sante.fr/)
- [HAS - Parcours de Soins](https://www.has-sante.fr/)
