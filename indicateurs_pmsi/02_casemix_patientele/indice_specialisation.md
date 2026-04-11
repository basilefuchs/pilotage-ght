# Indice de Spécialisation (Quotient de Localisation)

## Définition
L'indice de spécialisation, également appelé quotient de localisation (QL) ou location quotient, mesure la surreprésentation ou la sous-représentation d'un domaine d'activité au sein du GHT par rapport à la moyenne nationale (ou régionale). Un indice supérieur à 1 indique que le GHT réalise proportionnellement plus d'activité dans ce domaine que la moyenne de référence, témoignant d'une spécialisation ; un indice inférieur à 1 signale une sous-activité relative. Cet indicateur permet d'identifier le positionnement stratégique réel du GHT et de détecter les spécialités de recours émergentes ou en déclin.

## Calcul
L'indice de spécialisation est calculé comme suit :

```
IS(domaine D) = (Séjours du GHT dans le domaine D / Total des séjours du GHT) / (Séjours nationaux dans le domaine D / Total des séjours nationaux)
```

**Précisions méthodologiques** :
- Les domaines d'activité sont définis par les Catégories Majeures de Diagnostic (CMD) du PMSI, les racines de GHM, ou des regroupements cliniques personnalisés (ex. : cancérologie, cardiologie, neurologie).
- Un IS > 1,2 est généralement interprété comme une spécialisation significative ; un IS < 0,8 comme une sous-spécialisation.
- L'indicateur peut être calculé en nombre de séjours, en journées ou en valorisation T2A pour pondérer par la lourdeur économique des cas.
- La référence nationale (dénominateur) peut être remplacée par la moyenne régionale (ARS) ou par un groupe de GHT comparables pour des benchmarkings plus fins.
- L'analyse longitudinale (évolution de l'IS sur 3-5 ans) permet de détecter les spécialisations émergentes ou les décrochages d'activité.

## Utilité
- **Identification du positionnement stratégique** : objectiver les domaines d'excellence du GHT et les zones de faiblesse relative par rapport à la moyenne nationale.
- **Aide à la décision pour les autorisations d'activité** : appuyer les demandes d'autorisation ou de renouvellement sur les domaines où le GHT est déjà spécialisé et reconnu.
- **Planification des recrutements médicaux** : prioriser les efforts de recrutement dans les domaines sous-représentés stratégiquement importants pour le territoire.
- **Communication institutionnelle** : valoriser les spécialités de recours du GHT auprès des patients, des médecins de ville et des financeurs.
- **Benchmarking entre GHT** : comparer les profils de spécialisation de plusieurs GHT d'une même région pour organiser la complémentarité territoriale.

## Sources de Données
- **PMSI MCO national** : base nationale PMSI pour calculer la structure de l'activité nationale de référence (disponible via ScanSanté ou ATIH).
- **PMSI MCO du GHT** : répartition de l'activité par CMD, racine de GHM ou regroupement clinique pour le numérateur.
- **ScanSanté** : module de comparaison de la structure d'activité entre établissements et par rapport aux moyennes nationales et régionales.
- **ATIH - Tableaux de bord PMSI** : données agrégées par domaine d'activité et par niveau géographique.

## Exemple de Valeurs
- **IS > 1,5 (forte spécialisation)** : fréquent en cancérologie pour les GHT disposant d'un établissement support autorisé, ou en orthopédie pour les GHT ayant développé une filière prothèses.
- **IS entre 0,8 et 1,2 (activité dans la norme)** : la majorité des domaines de médecine polyvalente dans un GHT de taille moyenne.
- **IS < 0,6 (sous-spécialisation significative)** : souvent observé en neurochirurgie, cardiologie interventionnelle ou réanimation spécialisée pour les GHT non-CHU.
- **IS chirurgie ambulatoire** : souvent inférieur à 1 pour les GHT publics face à la concurrence du secteur privé (QL moyen ~0,7).
- **Évolution temporelle** : une augmentation de l'IS en cancérologie de 0,9 à 1,3 sur 5 ans peut traduire l'impact d'une autorisation de traitement du cancer obtenue par le GHT.

## Limites
- L'indice de spécialisation est sensible à la taille du GHT : les petits GHT ont des IS plus volatils car de faibles variations en valeur absolue produisent de grandes variations relatives.
- La référence nationale est un agrégat hétérogène incluant CHU, CHG et cliniques : la comparaison avec un groupe de pairs plus homogène est préférable.
- Un IS élevé peut refléter un manque d'offre concurrente sur le territoire plutôt qu'une réelle excellence clinique du GHT.
- L'indicateur ne dit rien de la qualité des soins dans le domaine considéré, uniquement du volume relatif.
- Les recompositions d'offre (fermetures, fusions) peuvent modifier brutalement l'IS sans changement de pratique du GHT lui-même.

## Références
- [ATIH - Tableaux de bord PMSI et structure d'activité](https://www.atih.sante.fr/)
- [ScanSanté - Comparaison inter-établissements](https://www.scansante.fr/)
- [DREES - Géographie de la santé et offre de soins](https://www.drees.solidarites-sante.gouv.fr/)
- [INSEE - Méthode des quotients de localisation](https://www.insee.fr/)
