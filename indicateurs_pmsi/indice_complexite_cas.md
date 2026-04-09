# Indice de Complexité des Cas (ICC)

## Définition
L'Indice de Complexité des Cas (ICC) mesure la complexité moyenne des cas traités dans un établissement ou un GHT, en pondérant les séjours par leur groupe homogène de malades (GHM) et les comorbidités associées. Cet indicateur est particulièrement pertinent pour les CHU, qui prennent en charge des pathologies plus complexes.

## Calcul
L'ICC est calculé comme suit :

```
ICC = (Somme des poids GHM × facteurs de comorbidité) / Nombre total de séjours
```

Où :
- **Poids GHM** : Poids relatif du GHM (issu de la tarification T2A).
- **Facteurs de comorbidité** : Coefficients liés aux pathologies associées (CMA, CIM-10).

## Utilité
- **Évaluer la charge de travail** : Un ICC élevé indique une prise en charge de cas plus lourds.
- **Benchmarking** : Comparaison entre établissements ou GHT pour ajuster les ressources.
- **Pilotage financier** : Justifier des besoins en moyens supplémentaires pour les cas complexes.

## Sources de Données
- **PMSI MCO** : Données issues des Résumés de Sortie Standardisés (RSS), incluant GHM et comorbidités.
- **ATIH** : Référentiels de poids GHM et facteurs de comorbidité.

## Exemple de Valeurs
- **ICC moyen en CHU** : 1,5-2,0 (vs 1,0-1,2 pour un établissement non universitaire).
- **Variation par service** : Réanimation (ICC > 2,5), Médecine interne (ICC ~1,8).

## Limites
- Dépend des référentiels de pondération (mis à jour annuellement).
- Ne reflète pas la qualité des soins, seulement la complexité.

## Références
- [ATIH - Indice de Complexité](https://www.atih.sante.fr/)
- [Tarification T2A - GHM](https://www.atih.sante.fr/tarification)
