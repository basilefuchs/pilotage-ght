# profils/

Profils de mapping concepts PMSI ↔ schéma réel, consommés **et
enrichis** par la skill `/ght-r` pour éviter de redemander le mapping à
chaque génération.

## Trois couches de connaissance du schéma

| Couche                | Contenu                                            | Statut |
|-----------------------|----------------------------------------------------|--------|
| `source/`             | Sources brutes (Excel ATIH, zip Kwikly SNDS) + script de conversion | committé tel quel |
| `dictionnaires/`      | Dictionnaires complets greppables (CSV `;`) générés depuis `source/` | généré, régénérable |
| `*.md` (cette racine) | Profils curatés concept → colonne, **vérifiés à l'usage** | capital métier |

Résolution d'un concept par `/ght-r` : **profil d'abord**, puis grep
dans `dictionnaires/` avec confirmation utilisateur, puis question
libre. Tout mapping confirmé remonte dans le profil (couche 3).

```sh
# Rechercher un concept dans les dictionnaires
grep -i "urgence" profils/dictionnaires/portail_atih.csv
grep -i ";ER_PRS_F;" profils/dictionnaires/snds.csv
```

Régénération : `Rscript profils/source/build_dictionnaires.R`
(voir `source/README.md`, notamment la règle de nommage SAS → Teradata).

## Utilisation

| Mode                          | Commande                                            |
|-------------------------------|-----------------------------------------------------|
| Détection auto (par défaut)   | `/ght-r <indicateur>` — la skill charge d'office le profil correspondant au champ PMSI |
| Via flag explicite            | `/ght-r <indicateur> --profil profils/<fichier>.md` |
| Plusieurs profils fusionnés   | `/ght-r <ind> --profil profils/p1.md,profils/p2.md` |
| Collé en tête de prompt       | Coller le contenu sous un bloc `# PROFIL DE BASE`   |
| Désactiver la sauvegarde      | Ajouter `--no-save-profil` pour mapping ad-hoc      |

## Enrichissement automatique

Quand `/ght-r` reçoit un mapping (saisi par l'utilisateur ou complété
par lui en cas de profil partiel), la skill **persiste les nouveaux
concepts** dans le profil correspondant en fin d'exécution :

- Concept absent → ajouté silencieusement
- Concept présent avec colonne identique → ignoré
- Concept présent avec colonne différente → diff affiché, confirmation
  utilisateur demandée avant écrasement
- `--no-save-profil`, `--dry-run`, ou `--profil` inchangé → pas
  d'écriture

Voir `.claude/skills/ght-r/SKILL.md` (section "Persistance des profils")
pour la procédure complète et `.claude/skills/ght-r/references/profils_format.md`
pour le schéma exact d'un fichier profil.

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
