# IP-DMS — Indice de Performance de la Durée Moyenne de Séjour

## Définition
L'Indice de Performance de la Durée Moyenne de Séjour (IP-DMS) mesure l'écart entre la durée moyenne de séjour (DMS) observée dans un établissement et la DMS théorique attendue, calculée à partir des DMS nationales de référence pondérées par le casemix réel de l'établissement (ses propres GHM). Un IP-DMS inférieur à 1 indique que l'établissement est plus efficient que la moyenne nationale pour son casemix (séjours plus courts qu'attendu) ; un IP-DMS supérieur à 1 signale des séjours plus longs qu'attendu, révélant un potentiel d'optimisation. Cet indicateur est publié par l'ATIH et disponible dans ScanSanté — c'est l'un des rares indicateurs de performance directement accessible sans traitement supplémentaire, qui neutralise l'effet casemix pour des comparaisons équitables entre établissements de profils d'activité très différents.

## Calcul
L'IP-DMS est calculé comme suit :

```
IP-DMS = DMS observée de l'établissement / DMS théorique

DMS théorique = Σ (Nombre de séjours GHM_i × DMS nationale de référence GHM_i) / Nombre total de séjours

  → DMS nationale de référence GHM_i : DMS moyenne nationale pour le GHM i, publiée par l'ATIH
  → La DMS théorique est la DMS que l'établissement aurait si chaque GHM durait exactement la durée moyenne nationale

Interprétation :
  IP-DMS < 1,0  → Établissement plus court que la moyenne nationale pour son casemix (efficient)
  IP-DMS = 1,0  → Conforme à la moyenne nationale
  IP-DMS > 1,0  → Établissement plus long que la moyenne nationale (potentiel d'optimisation)
  IP-DMS > 1,1  → Seuil d'alerte (>10 % au-dessus de la norme)
  IP-DMS > 1,2  → Seuil critique (>20 % au-dessus de la norme)
```

**Décomposition de l'IP-DMS :**
```
IP-DMS global = f(effet casemix, effet DMS pure)

Effet casemix = DMS théorique / DMS nationale brute
  → Mesure si l'établissement traite des cas plus ou moins lourds que la moyenne

Effet DMS pure = DMS observée / DMS théorique = IP-DMS
  → Mesure l'efficience réelle une fois le casemix neutralisé
```

**Précisions méthodologiques** :
- L'IP-DMS est calculé sur les séjours en hospitalisation complète uniquement (hors ambulatoire < 24h).
- Les séjours en borne haute (EXH) et en borne basse (EXB) sont inclus dans le calcul mais peuvent être analysés séparément pour identifier leur contribution à l'IP-DMS.
- L'indicateur peut être décliné par CMD, par GHM, par service ou par établissement du GHT.
- La DMS nationale de référence est mise à jour annuellement par l'ATIH ; les comparaisons temporelles doivent s'assurer de la cohérence des millésimes utilisés.

## Utilité
- **Comparaison équitable entre établissements** : l'IP-DMS neutralise l'effet casemix, permettant de comparer un CHU (casemix lourd, DMS longue) et un CHG (casemix léger, DMS courte) sur un pied d'égalité — contrairement à la DMS brute qui favorise mécaniquement les établissements traitant des cas simples.
- **Identification des gisements d'optimisation** : un IP-DMS > 1 sur un GHM ou une CMD spécifique cible les filières où la DMS dépasse la norme nationale, orientant les actions d'optimisation (virage ambulatoire, organisation de l'aval SSR, protocoles RAAC).
- **Benchmarking intra-GHT** : comparer les IP-DMS des différents établissements du GHT pour identifier les sites les plus efficients et diffuser leurs bonnes pratiques organisationnelles.
- **Suivi de l'impact des réformes organisationnelles** : mesurer l'évolution de l'IP-DMS avant/après la mise en place d'un protocole RAAC, d'une filière SSR organisée ou d'un programme de développement ambulatoire.
- **Pilotage financier** : chaque point d'IP-DMS au-dessus de 1,0 représente des journées d'hospitalisation non valorisées (coût > recette EXH) — quantifier l'enjeu financier d'un retour à l'IP-DMS = 1,0 guide les décisions d'investissement organisationnel.

## Sources de Données
- **ATIH - ScanSanté** : l'IP-DMS est calculé et publié directement par l'ATIH, accessible dans ScanSanté par établissement, par GHM et par CMD — aucun traitement supplémentaire requis.
- **ATIH - Tableaux de bord PMSI** : IP-DMS disponible dans les tableaux de bord annuels de l'ATIH, avec comparaison aux établissements de même catégorie (CHU, CHG, clinique).
- **PMSI MCO local** : pour un calcul infra-annuel (mensuel, trimestriel) ou par unité fonctionnelle, le DIM peut recalculer l'IP-DMS depuis les données locales en appliquant les DMS nationales de référence ATIH.

## Exemple de Valeurs
- **IP-DMS national moyen** : par construction proche de 1,0 (les DMS de référence sont des moyennes nationales).
- **Établissements publics** : IP-DMS moyen entre 0,95 et 1,10 pour la majorité des CHG et CHU.
- **Cliniques privées** : IP-DMS souvent inférieur à 1,0 (0,85-0,95) reflétant une sélection de cas moins complexes et une organisation plus fluide de la sortie.
- **Établissements à IP-DMS > 1,15** : concernent souvent des établissements avec des problèmes d'aval SSR chroniques, une forte proportion de patients polypathologiques, ou des dysfonctionnements organisationnels identifiés.
- **Variation par CMD** : IP-DMS le plus élevé souvent en CMD 1 (neurologie, AVC) et CMD 5 (cardiologie) dans les établissements sans UNV/USIC organisées ; IP-DMS le plus faible en CMD 8 (orthopédie) dans les établissements avec protocoles RAAC.
- **Impact d'un protocole RAAC** : réduction de l'IP-DMS de 0,10 à 0,15 points documentée après mise en place d'un protocole RAAC en chirurgie orthopédique (PTH/PTG).

## Limites
- L'IP-DMS ne neutralise pas tous les facteurs confondants : la sévérité intra-GHM (non capturée par le GHM terminal), la précarité sociale des patients et les contraintes géographiques (disponibilité SSR) influencent la DMS indépendamment de l'efficience organisationnelle.
- Un IP-DMS bas peut résulter de sorties prématurées non accompagnées, générant des réadmissions — l'IP-DMS doit toujours être analysé conjointement avec le taux de réadmission à 30 jours.
- La DMS nationale de référence intègre les pratiques de tous les établissements, y compris les moins efficients : atteindre IP-DMS = 1,0 n'est pas synonyme de performance optimale mais de conformité à la moyenne.
- L'indicateur est calculé sur l'hospitalisation complète uniquement : la progression du virage ambulatoire peut améliorer l'IP-DMS mécaniquement (les séjours courts partent en ambulatoire, ne tirant plus la DMS vers le bas) sans gain réel d'efficience sur les séjours restants.
- Les comparaisons temporelles sont sensibles aux révisions annuelles des DMS de référence ATIH ; un IP-DMS stable d'une année sur l'autre peut masquer une dégradation si la référence nationale s'est améliorée.

## Références
- [ATIH - IP-DMS et tableaux de bord PMSI MCO](https://www.atih.sante.fr/)
- [ScanSanté - IP-DMS par établissement et par GHM](https://www.scansante.fr/)
- [ANAP - Benchmark des durées de séjour et IP-DMS](https://www.anap.fr/)
- [HAS - Efficience hospitalière et durée de séjour](https://www.has-sante.fr/)
