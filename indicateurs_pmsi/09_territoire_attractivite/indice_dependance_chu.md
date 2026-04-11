# Indice de Dépendance au CHU

## Définition
L'indice de dépendance au CHU mesure la proportion de séjours transférés par le GHT vers le CHU de référence qui auraient pu être pris en charge localement, eu égard aux capacités et aux autorisations du GHT. Il se distingue du simple taux de recours au CHU en tentant d'isoler les transferts structurels (GHM de haute complexité nécessitant un plateau technique de référence) des transferts évitables (GHM accessibles au GHT mais orientés vers le CHU par habitude, défaut d'organisation ou absence de compétence disponible localement).

## Calcul
L'indice de dépendance au CHU est calculé comme suit :

```
Indice de dépendance (%) = (Transferts vers le CHU pour des GHM dans le champ d'autorisation du GHT / Total des transferts vers le CHU) × 100
```

**Précisions méthodologiques** :
- Les transferts sont identifiés dans le PMSI par le mode d'entrée (= transfert) et le FINESS de l'établissement d'origine.
- Les GHM « dans le champ d'autorisation du GHT » sont ceux correspondant aux autorisations d'activité détenues par au moins un établissement du GHT.
- Une variante consiste à calculer la part des séjours transférés vers le CHU pour des GHM de niveau 1-2 (faible à modérée complexité) dans le total des transferts.
- L'analyse peut être affinée par spécialité (chirurgie, cardiologie, neurologie, etc.) pour identifier les filières les plus dépendantes.

## Utilité
- **Identification des filières à consolider** : repérer les spécialités où le GHT transfère excessivement vers le CHU, révélant un manque de compétence ou d'organisation à développer localement.
- **Optimisation des conventions CHU-GHT** : objectiver les flux pour calibrer les postes partagés, les consultations avancées et les protocoles de transfert.
- **Développement des compétences médicales** : prioriser les recrutements et les formations pour réduire les transferts évitables.
- **Évaluation des filières de soins** : mesurer l'impact des actions de structuration de filières (AVC, cardiologie, oncologie) sur la réduction des transferts non justifiés.
- **Négociation CPOM** : utiliser l'indicateur pour justifier des demandes d'autorisation ou de renforcement capacitaire.

## Sources de Données
- **PMSI MCO** : champ « mode d'entrée » (code 6 = transfert), FINESS de provenance, GHM de séjour — pour identifier les transferts entrants au CHU en provenance du GHT.
- **Autorisations d'activité** : données issues du Répertoire Opérationnel des Ressources (ROR) et des arrêtés d'autorisation ARS pour définir le champ du GHT.
- **ScanSanté** : analyse des flux de transferts entre établissements.
- **ARS** : fichiers des autorisations de soins par établissement et par activité.

## Exemple de Valeurs
- **Transferts structurels (inévitables)** : représentent généralement 50-70 % des transferts vers le CHU (neurochirurgie, grands brûlés, réanimation lourde, greffes).
- **Transferts potentiellement évitables** : 30-50 % des transferts, notamment en chirurgie digestive, orthopédique et cardiologie interventionnelle selon les GHT.
- **Indice de dépendance cible** : <20 % de transferts évitables dans les filières couvertes par les autorisations du GHT.
- **Variation par spécialité** : neurologie (60-80 % de transferts structurels), chirurgie orthopédique (20-40 % de transferts structurels).

## Limites
- La frontière entre transfert structurel et transfert évitable est difficile à établir automatiquement depuis le seul PMSI : le GHM ne capture pas toujours la sévérité réelle du cas.
- Certains transferts sont justifiés par l'état du patient à l'admission et non par le diagnostic principal, rendant la classification complexe.
- L'indicateur ne distingue pas les transferts programmés (aval chirurgical planifié au CHU) des transferts urgents non anticipés.
- Une réduction des transferts vers le CHU n'est pas toujours souhaitable si elle conduit à des prises en charge de moindre qualité localement.
- Nécessite un appariement des données PMSI entre le GHT et le CHU, ce qui suppose un accord de partage de données.

## Références
- [ATIH - Guide méthodologique PMSI MCO (modes d'entrée et de sortie)](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des flux inter-établissements](https://www.scansante.fr/)
- [Ministère de la Santé - Répertoire Opérationnel des Ressources (ROR)](https://esante.gouv.fr/)
