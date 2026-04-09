# Taux de Réadmissions Évitables

## Définition
Le taux de réadmissions évitables mesure la proportion de réadmissions non programmées dans les 30 jours suivant la sortie initiale, identifiées comme potentiellement évitables par des modèles prédictifs. Cet indicateur est un marqueur clé de la qualité des soins et de l'efficacité de la coordination post-hospitalisation.

## Calcul
Le taux de réadmissions évitables est calculé comme suit :

```
Taux de réadmissions évitables (%) = (Nombre de réadmissions évitables dans les 30 jours / Nombre total de sorties) × 100
```

**Critères d'évitabilité** :
- Modèles prédictifs basés sur des algorithmes (ex : LACE, HOSPITAL).
- Exclusion des réadmissions pour des pathologies non liées au séjour initial.

## Utilité
- **Qualité des soins** : Identifier les séjours avec un risque élevé de réadmission.
- **Coordination ville-hôpital** : Évaluer l'efficacité des dispositifs de suivi post-hospitalisation.
- **Impact financier** : Estimer le coût des réadmissions évitables.

## Sources de Données
- **PMSI** : Chaînage des séjours via l'identifiant patient (NIR/NIP).
- **SNDS** : Données cliniques pour les modèles prédictifs.
- **ATIH** : Référentiels d'évitabilité.

## Exemple de Valeurs
- **Taux national moyen** : 5-10% (variable selon les pathologies).
- **Pathologies cibles** : Insuffisance cardiaque (15-20%), BPCO (10-15%).
- **Objectif** : Réduction de 20% des réadmissions évitables (programmes nationaux).

## Limites
- Dépend des modèles prédictifs utilisés (risque de biais).
- Nécessite des données cliniques complémentaires (SNDS).

## Références
- [ATIH - Réadmissions](https://www.atih.sante.fr/)
- [HAS - Parcours de Soins](https://www.has-sante.fr/)
