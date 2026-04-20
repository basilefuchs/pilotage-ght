# profils/

Profils de mapping concepts PMSI ↔ schéma réel, consommés par la skill
`/ght-r` pour éviter de redemander le mapping à chaque génération.

## Utilisation

| Mode                     | Commande                                        |
|--------------------------|-------------------------------------------------|
| Via flag                 | `/ght-r <indicateur> --profil profils/<fichier>.md` |
| Collé en tête de prompt  | Coller le contenu sous un bloc `# PROFIL DE BASE` |

## Convention de nommage

```
<base>_<champ>.md
```

| Fichier                  | Base         | Champ(s)     |
|--------------------------|--------------|--------------|
| `portail_atih_mco.md`    | Portail ATIH | MCO          |
| `portail_atih_ssr.md`    | Portail ATIH | SSR          |
| `portail_atih_had.md`    | Portail ATIH | HAD          |
| `portail_atih_multi.md`  | Portail ATIH | MCO+SSR+HAD  |
| `snds_mco.md`            | SNDS         | MCO          |

## Structure attendue d'un profil

| Section                | Contenu                                      |
|------------------------|----------------------------------------------|
| Méta                   | Base, SGBD, connexion, schéma, clé universelle |
| Une section par vue    | Tableau concept → colonne, avec granularité  |
| Pièges                 | Tableau piège → traitement (capital métier)  |
| Défauts recommandés    | Paramètres par défaut du script R généré     |

## Maintenance

| Événement                        | Action                                   |
|----------------------------------|------------------------------------------|
| Nouvelle année PMSI              | Vérifier stabilité des vues (rare changement) |
| Nouvelle vue utilisée            | Ajouter une section                      |
| Nouveau piège identifié          | Ligne supplémentaire dans "Pièges"       |
| Nouveau paramètre standardisé    | Ligne supplémentaire dans "Défauts"      |
