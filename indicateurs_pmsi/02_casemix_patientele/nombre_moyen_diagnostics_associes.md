# Nombre Moyen de Diagnostics Associés par Séjour

## Définition
Le **nombre moyen de diagnostics associés par séjour** mesure la complexité médicale des patients pris en charge en calculant le nombre moyen de **diagnostics secondaires et associés** (hors diagnostic principal) codés par séjour. Cet indicateur reflète la **charge en comorbidités** et la **sévérité globale** des cas, influençant la durée de séjour, les ressources nécessaires et la tarification (via les CMA - Comorbidités Majeures Associées).

## Calcul
```
Nombre moyen = (Somme des diagnostics secondaires + associés pour tous les séjours) / (Nombre total de séjours)
```

### Composantes des diagnostics associées
Dans le PMSI, les diagnostics sont classés en :
- **Diagnostic principal (DP)** : 1 par séjour (non inclus dans ce calcul).
- **Diagnostics secondaires (DS)** : Pathologies ou affections associées au DP.
- **Diagnostics associés (DA)** : Comorbidités ou complications survenues pendant le séjour.

### Méthode de décompte
- Chaque code CIM-10 (hors DP) compte pour **1 diagnostic associé**.
- Les **CMA (Comorbidités Majeures Associées)** sont incluses dans ce décompte.
- Les codes **Z** (ex : Z51.2 - Chimiothérapie) sont comptabilisés s'ils sont pertinents.

## Utilité
- **Évaluation de la complexité** : Identifier les services ou pathologie avec une charge de comorbidités élevée.
- **Optimisation des ressources** : Anticiper les besoins en personnel et en lits (ex : patients avec >3 diagnostics associés = séjours plus lourds).
- **Benchmarking** : Comparer la complexité entre établissements ou avec des références nationales.
- **Tarification T2A** : Corréler avec les CMA pour vérifier la juste valorisation des séjours.
- **Surveillance épidémiologique** : Détecter des tendances (ex : augmentation des comorbidités dans une population).

## Sources de Données
- **PMSI MCO/SSR/PSY** : Données issues des Résumés de Sortie Standardisés (RSS), incluant tous les codes CIM-10 (DP, DS, DA).
- **ScanSanté** : Extraction des diagnostics par séjour, service ou établissement.
- **Base CIM-10** : Nomenclature officielle pour l'interprétation des codes.

## Exemple de Valeurs
- **Moyenne nationale (MCO)** : ~2,5 à 3,0 diagnostics associés par séjour.
- **Par discipline** :
  - Médecine interne : 4,0-5,5 (patients âgés, polymorbides).
  - Chirurgie orthopédique : 1,5-2,5 (patients souvent moins comorbides).
  - Réanimation : 5,0-7,0 (sévérité élevée).
  - Obstétrique : 0,5-1,5 (populations souvent jeunes et saines).
- **Par tranche d'âge** :
  - <65 ans : ~2,0 diagnostics associés.
  - 65-80 ans : ~3,5 diagnostics associés.
  - >80 ans : ~4,5 diagnostics associés.
- **Seuils** :
  - <1,5 : Population relativement jeune/saine.
  - >4,0 : Population très comorbide (alertes ressources).

## Limites
- **Qualité du codage** : Sous-estimation si les comorbidités ne sont pas clairement documentées.
- **Variabilité des pratiques** : Certains établissements codent plus de diagnostics secondaires que d'autres.
- **Biais de sélection** : Les séjours courts peuvent avoir moins de diagnostics documentés.
- **Codes CIM-10 non spécifiques** : Certains codes (ex : R68.8 - "Autres symptômes généraux") peuvent gonfler artificiellement le score.

## Références
- [ATIH - Codage CIM-10 en PMSI](https://www.atih.sante.fr/nomenclatures-de-recueil-de-linformation/cim-10)
- [ATIH - Comorbidités Majeures Associées (CMA)](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
- [ScanSanté - Analyse des diagnostics](https://www.scansante.fr/groupement-hospitalier-territoire)
- [Guide de codage CIM-10 - ATIH](https://www.atih.sante.fr/)
- [OMS - Classification CIM-10](https://icd.who.int/fr)