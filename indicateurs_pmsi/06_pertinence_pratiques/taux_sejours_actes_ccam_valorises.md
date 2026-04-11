# Taux de Séjours avec Actes CCAM Valorisés

## Définition
Le **taux de séjours avec actes CCAM valorisés** mesure la proportion de séjours incluant au moins un acte de la Classification Commune des Actes Médicaux (CCAM) **facturable** dans le cadre de la tarification T2A. Cet indicateur évalue l'**exhaustivité du codage des actes** et l'**optimisation de la valorisation financière** des séjours. Un taux élevé reflète une bonne pratique de codage et une maximisation des recettes liées aux actes.

## Calcul
```
Taux (%) = (Nombre de séjours avec ≥1 acte CCAM valorisé / Nombre total de séjours) × 100
```

### Critères d'inclusion des actes CCAM
Un acte est considéré comme **valorisé** s'il remplit les conditions suivantes :
- Code CCAM **valide** (présent dans la nomenclature en vigueur).
- Acte **réalisé** pendant le séjour (date compatible avec la durée de séjour).
- Acte **autorisé** pour le type de séjour (hospitalisation complète, partielle, ou ambulatoire).
- Acte **codé dans le RSS** (présent dans le Résumé de Sortie Standardisé).

### Exclusions
- Actes **non facturables** (ex : actes de prévention non tarifés en sus).
- Actes **erronés ou incomplets** (codes invalides, dates aberrantes).
- Actes **déjà inclus dans le GHM** (certains actes sont valorisés via le GHM et non en sus).

## Utilité
- **Optimisation des recettes** : Identifier les séjours sous-valorisés par manque de codage des actes.
- **Audit du codage** : Détecter les services ou pathologie avec un taux anormalement bas.
- **Benchmarking interne** : Comparer les pratiques entre services ou établissements du GHT.
- **Formation des équipes** : Cibler les formations en codage CCAM pour les services concernés.
- **Analyse par spécialité** : Évaluer la part des actes valorisés par discipline (ex : chirurgie vs médecine).

## Sources de Données
- **PMSI MCO/SSR** : Données issues des Résumés de Sortie Standardisés (RSS), incluant les codes CCAM.
- **Base CCAM** : Nomenclature officielle des actes (ATIH) pour vérifier la validité des codes.
- **ScanSanté** : Extraction des actes CCAM par séjour, service ou établissement.

## Exemple de Valeurs
- **Taux moyen national (MCO)** : ~60-70% (variable selon les spécialités).
- **Par discipline** :
  - Chirurgie : 85-95% (actes systématiques : interventions, gestes techniques).
  - Médecine : 40-60% (moins d'actes techniques, plus de consultations).
  - Obstétrique : 70-80% (accouchements, césariennes, surveillances).
  - SSR : 30-50% (actes de rééducation, soins).
- **Objectif GHT** : >80% pour les séjours chirurgicaux, >50% pour la médecine.
- **Seuils d'alerte** :
  - <30% : Risque de sous-codage important.
  - >90% : Audit pour vérifier l'absence de sur-codage.

## Limites
- **Variabilité selon les spécialités** : Un taux bas en médecine n'est pas forcément anormal.
- **Actes non tarifés en sus** : Certains actes CCAM sont inclus dans le GHM (ex : actes de réanimation).
- **Qualité du codage** : Un taux élevé peut cacher des erreurs de codage (actes non réalisés).
- **Données manquantes** : Les actes réalisé en ambulatoire ou en externalisé ne sont pas inclus.

## Références
- [ATIH - Classification CCAM](https://www.atih.sante.fr/codage-et-tarification/la-classification-commune-des-actes-medicaux-ccam)
- [ATIH - Règles de valorisation des actes CCAM](https://www.atih.sante.fr/tarification/la-tarification-a-l-activite/les-supplements)
- [ScanSanté - Analyse des actes CCAM](https://www.scansante.fr/groupement-hospitalier-territoire)
- [Guide de codage CCAM - ATIH](https://www.atih.sante.fr/)