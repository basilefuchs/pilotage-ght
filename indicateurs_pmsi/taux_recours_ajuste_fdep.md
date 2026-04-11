# Taux de Recours Ajusté sur la Précarité (FDep)

## Définition
Le taux de recours ajusté sur la précarité croise les taux d'hospitalisation PMSI avec l'indice de défavorisation sociale FDep (French Deprivation Index), calculé à l'échelle des communes ou des IRIS par l'INSEE et l'INSERM. Cet indicateur révèle les inégalités sociales d'accès aux soins hospitaliers : une population défavorisée peut avoir un taux de recours plus élevé pour les hospitalisations potentiellement évitables (signe de mauvaise prise en charge ambulatoire) et simultanément un taux de recours plus faible pour les soins programmés et les actes préventifs (signe de renoncement aux soins). Le FDep est un score composite basé sur le revenu médian, le taux de bacheliers, le taux d'ouvriers et le taux de chômage par unité géographique.

## Calcul
Le taux de recours ajusté sur la précarité est calculé en deux étapes :

**Étape 1 — Calcul du FDep par commune ou IRIS :**
```
FDep = score composite standardisé (revenu médian, % bacheliers, % ouvriers, % chômeurs)
       → quintiles Q1 (favorisé) à Q5 (très défavorisé)
```

**Étape 2 — Croisement avec les taux de recours PMSI :**
```
Taux de recours stratifié (pour 100 000 hab.) = Nombre de séjours PMSI des patients résidant dans les communes du quintile Qx / Population du quintile Qx × 100 000
```

**Indicateurs dérivés :**
```
Indice d'inégalité de recours = Taux de recours Q5 (très défavorisé) / Taux de recours Q1 (favorisé)
  → Indice > 1 : surrecours dans les zones défavorisées (HPE, urgences)
  → Indice < 1 : sous-recours dans les zones défavorisées (chirurgie programmée, cancérologie)
```

**Précisions méthodologiques** :
- Le code postal de résidence du patient dans le PMSI est apparié à la commune INSEE, puis au quintile FDep correspondant.
- L'analyse est stratifiée par type de séjour : hospitalisations potentiellement évitables (HPE), chirurgie programmée, cancérologie, soins palliatifs, urgences.
- Les taux sont standardisés par âge et sexe pour isoler l'effet de la précarité de celui de la structure démographique.

## Utilité
- **Détection des inégalités sociales d'accès aux soins** : identifier les segments d'activité où les populations défavorisées du territoire du GHT sont sous- ou sur-représentées par rapport à leur poids démographique.
- **Ciblage des actions de santé publique** : prioriser les zones géographiques et les pathologies pour lesquelles l'inégalité de recours est la plus marquée (dépistage, éducation thérapeutique, permanence des soins).
- **Dialogue avec l'ARS et les collectivités** : objectiver les besoins spécifiques des populations précaires du territoire pour les Contrats Locaux de Santé (CLS) et les Projets Régionaux de Santé (PRS).
- **Analyse de la demande non exprimée** : un faible taux de recours en chirurgie programmée dans les quintiles défavorisés peut signaler un renoncement aux soins ou une barrière d'accès (transport, information, délai d'attente).
- **Évaluation des politiques d'équité** : mesurer dans le temps l'impact des actions du GHT sur la réduction des inégalités de recours (permanence des soins, consultations avancées, PASS).

## Sources de Données
- **PMSI MCO** : code postal de résidence du patient dans les RSS, pour le calcul des taux de recours par zone géographique.
- **FDep — French Deprivation Index** : indice disponible au niveau communal et infra-communal (IRIS), produit par l'INSERM/CépiDc et l'INSEE. Dernière version disponible : FDep2015, FDep2019.
- **INSEE** : données de population par commune et IRIS pour le dénominateur des taux de recours.
- **SNDS** : pour les analyses longitudinales croisant précarité, hospitalisations et consommation ambulatoire.
- **Référence méthodologique** : Rey G. et al., *The FDep index: a validated French deprivation index*, European Journal of Public Health, 2009.

## Exemple de Valeurs
- **Hospitalisations potentiellement évitables (HPE)** : taux 1,5 à 2,5 fois plus élevé dans le quintile Q5 (très défavorisé) que dans le quintile Q1 (favorisé) — inégalité structurelle documentée en France.
- **Chirurgie de la cataracte** : taux de recours 20-30 % plus faible dans les communes défavorisées, malgré une prévalence similaire ou supérieure de la pathologie.
- **Cancérologie** : stade de diagnostic plus avancé et recours à la chirurgie curative plus tardif dans les quintiles défavorisés.
- **Urgences** : taux de passage aux urgences 30-50 % plus élevé dans les zones Q5, avec un taux d'HPE associé proportionnellement supérieur.
- **Indice d'inégalité de recours HPE** : valeurs observées entre 1,4 et 2,2 selon les territoires et les pathologies traceurs.

## Limites
- Le FDep est calculé à l'échelle géographique (commune/IRIS) et non à l'échelle individuelle : il mesure la défavorisation du voisinage, pas nécessairement celle du patient (erreur écologique).
- La version disponible du FDep peut ne pas correspondre à l'année des données PMSI utilisées ; le croisement temporel doit être cohérent.
- Le code postal de résidence dans le PMSI est parfois manquant ou erroné pour les patients précaires (sans domicile fixe, SDF), qui sont précisément les plus défavorisés.
- L'ajustement simultané sur l'âge, le sexe et le FDep nécessite une modélisation statistique (régression de Poisson ou binomiale négative) pour éviter les confusions.
- Indicateur nécessitant un traitement statistique avancé non disponible nativement dans ScanSanté ; requiert des compétences en analyse de données géographiques et épidémiologiques.

## Références
- [Rey G. et al., The FDep index: a validated French deprivation index, European Journal of Public Health, 2009](https://doi.org/10.1093/eurpub/ckp029)
- [INSERM CépiDc - FDep, indice de défavorisation française](https://www.cepidc.inserm.fr/)
- [INSEE - Données infra-communales IRIS](https://www.insee.fr/)
- [DREES - Inégalités sociales de recours aux soins hospitaliers](https://www.drees.solidarites-sante.gouv.fr/)
- [SNDS - Croisement données PMSI et précarité](https://www.snds.gouv.fr/)
