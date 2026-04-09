# Taux de Mortalité à 30 Jours Post-Sortie

## Définition
Le taux de mortalité à 30 jours post-sortie mesure la proportion de patients décédés dans les 30 jours suivant leur sortie de l'hôpital, quels que soient le lieu et la cause du décès. Cet indicateur complète le taux de mortalité hospitalière en incluant les décès survenant après la sortie, notamment à domicile ou en établissement médico-social.

## Calcul
Le taux de mortalité à 30 jours post-sortie est calculé comme suit :

```
Taux de mortalité à 30j (%) = (Nombre de patients décédés dans les 30 jours post-sortie / Nombre total de sorties) × 100
```

**Critères d'inclusion** :
- Décès toutes causes confondues.
- Patients sortis vivants de l'hôpital (exclusion des décès hospitaliers).

## Utilité
- **Qualité des soins** : Évaluer l'impact des prises en charge sur la survie à court terme.
- **Coordination post-hospitalisation** : Identifier les besoins en suivi renforcé.
- **Benchmarking** : Comparaison entre établissements ou GHT pour des pathologies similaires.

## Sources de Données
- **PMSI** : Données de sortie (date, statut).
- **SNDS** : Données de décès (Causes Médicales de Décès - CépIDC).
- **Chaînage** : Via le numéro de sécurité sociale (NIR) anonymisé.

## Exemple de Valeurs
- **Taux national moyen** : 3-5% (variable selon les pathologies).
- **Pathologies à risque** : Insuffisance cardiaque (8-12%), cancers avancés (15-20%).
- **Objectif** : Réduction via des programmes de suivi post-hospitalisation.

## Limites
- Nécessite un chaînage PMSI-SNDS robuste.
- Peut être influencé par des facteurs socio-économiques (ex : isolement).

## Références
- [ATIH - Mortalité Post-Sortie](https://www.atih.sante.fr/)
- [SNDS - Causes de Décès](https://www.snds.gouv.fr/)
