# Indice de Diversité des GHM

## Définition
L'**Indice de Diversité des GHM** mesure le degré de variété des groupes homogènes de malades (GHM) pris en charge dans un établissement ou un GHT. Cet indicateur permet d'évaluer si l'activité est concentrée sur quelques pathologies ou, au contraire, très diversifiée. Une forte diversité peut refléter une offre de soins large (typique des CHU), tandis qu'une faible diversité peut indiquer une spécialisation (ex : clinique de chirurgie orthopédique).

## Calcul
L'indice de diversité des GHM est calculé à partir de la répartition des séjours par GHM, en utilisant des indices écologiques classiques :

### 1. Indice de Shannon (H')
```
H' = -Σ (pi × ln(pi))
Où :
- pi = proportion des séjours pour le GHM i (ni / N)
- ni = nombre de séjours pour le GHM i
- N = nombre total de séjours
- ln = logarithme naturel
```
**Interprétation** : Plus H' est élevé, plus la diversité est grande.

### 2. Indice de Simpson (D)
```
D = 1 - Σ (pi²)
Où : pi = proportion des séjours pour le GHM i
```
**Interprétation** : D proche de 1 = diversité très élevée ; D proche de 0 = diversité faible.

### 3. Nombre équivalent de GHM (e^H')
```
e^H' = e^(H')
```
**Interprétation** : Nombre théorique de GHM également répartis qui donneraient la même diversité.

## Utilité
- **Caractérisation de l'activité** : Distinguer les établissements généralistes des spécialisés dans le GHT.
- **Benchmarking** : Comparer la diversité entre établissements ou avec des références nationales.
- **Stratégie GHT** : Identifier les complémentarités entre établissements pour une offre territoriale optimale.
- **Pilotage financier** : Corréler la diversité avec la stabilité des recettes (diversité = réduction du risque de dépendance à une activité).

## Sources de Données
- **PMSI MCO/SSR/PSY/HAD** : Données issues des Résumés de Sortie Standardisés (RSS), incluant le code GHM pour chaque séjour.
- **ScanSanté** : Extraction des volumes de séjours par GHM et par établissement.

## Exemple de Valeurs
- **CHU de référence** : Indice de Shannon (H') ~4,5 à 5,0 (e^H' ~ 90-150 GHM équivalents).
- **Clinique spécialisée (ex : chirurgie orthopédique)** : H' ~1,5 à 2,5 (e^H' ~ 5-12 GHM équivalents).
- **GHT type** : Diversité variable selon la taille et la mission (ex : H' = 3,5 pour un GHT moyen).
- **Seuil de spécialisation** : Un établissement avec e^H' < 20 peut être considéré comme très spécialisé.

## Limites
- Dépend de la **taille de l'établissement** : les grands hôpitaux auront mécaniquement une diversité plus élevée.
- Influence des **odes de tarification** : Certains GHM regroupent des pathologies très différentes.
- **Biais de codage** : Une mauvaie qualité du codage peut fausser la répartition des GHM.
- Ne prend pas en compte le **volume** par GHM (un GHM rare mais très fréquent compte autant qu'un GHM rare).

## Références
- [ATIH - Clé de groupage des GHM](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
- [ScanSanté - Analyse des volumes par GHM](https://www.scansante.fr/groupement-hospitalier-territoire)
- [Indice de Shannon - Wikipedia](https://fr.wikipedia.org/wiki/Indice_de_Shannon)
- [Indice de Simpson - Ecologie numérique](https://fr.wikipedia.org/wiki/Indice_de_Simpson)
- [Guide d'analyse PMSI - ATIH](https://www.atih.sante.fr/)