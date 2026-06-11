# Base de connaissances — Indicateurs PMSI/GHT

Base de référence d'indicateurs de pilotage hospitalier pour les GHT, calculables depuis le PMSI MCO/SSR/PSY et le SNDS.

## Structure

```
indicateurs_pmsi/
├── 01_activite_production/       (29 indicateurs)
├── 02_casemix_patientele/        (27 indicateurs)
├── 03_vulnerabilite_sociale/     (17 indicateurs)
├── 04_efficience_capacitaire/    (24 indicateurs)
├── 05_qualite_securite/          (40 indicateurs)
├── 06_pertinence_pratiques/      (19 indicateurs)
├── 07_parcours_continuite/       (42 indicateurs)
├── 08_readmissions_evitables/    (11 indicateurs)
├── 09_territoire_attractivite/   (30 indicateurs)
└── 10_financement_valorisation/  (9 indicateurs)
```

Total : **248 fiches**, dont 20 implémentées en script R (`scripts_r/`).

Chaque fiche documente : définition, formule de calcul, sources de données, exemple de valeurs, limites et références.

## Site web (GitHub Pages)

Une page de recherche statique est publiée depuis `docs/` :
**https://basilefuchs.github.io/pilotage-ght/**

Elle permet de chercher parmi les 248 fiches par mots-clés, filtrer par catégorie, et consulter le script R associé quand il existe.

Après ajout/modification de fiches, régénérer l'index de recherche. Le plus simple est la skill **`/ght-page-refresh`** (cf. plus bas) : elle relance `build_docs.py`, affiche un diff lisible (fiches ajoutées/retirées, scripts R liés) et **ne commit ni ne push rien**. À défaut, directement :

```
python3 build_docs.py
```

Aperçu local :

```
cd docs && python3 -m http.server 8000
```

> Activation initiale : *Settings → Pages → Source : Deploy from branch → `main` / `/docs`*.

## Indicateurs innovants

Une trentaine d'indicateurs adaptent des cadres théoriques d'autres disciplines scientifiques à l'analyse hospitalière. Quelques exemples :

| Indicateur | Discipline d'origine | Répertoire |
|---|---|---|
| Entropie de Shannon du casemix | Théorie de l'information | 02 |
| Loi de Little hospitalière | Théorie des files d'attente | 04 |
| Fonction de risque Weibull des réadmissions | Ingénierie de fiabilité | 08 |
| Loi Gutenberg-Richter des événements indésirables | Sismologie | 05 |
| Exposant de Lyapunov du parcours chronique | Systèmes dynamiques | 07 |
| Centralité betweenness du réseau GHT | Théorie des graphes | 09 |
| Coefficient de Gini de la consommation hospitalière | Économie | 03 |

## Utilisation des skills

Des skills Claude Code permettent de générer et implémenter de nouveaux indicateurs selon un pipeline en 3 phases, puis de tenir la page de recherche à jour :

### `/ght-gen <domaine>` — Exploration
Génère une liste compressée de candidats d'indicateurs au format `[i,d,c,u,l,t]` (identifiant, description, calcul, unité, limites, thématique). Optimisé pour explorer rapidement un domaine sans consommer trop de tokens.

```
/ght-gen efficience capacitaire
```

### `/ght-dev <nom_indicateur>` — Développement
Développe un indicateur compressé en fiche markdown complète au standard du projet (définition, formule, sources, valeurs indicatives, limites, références). Fichier écrit dans `indicateurs_pmsi/<cat>/`.

```
/ght-dev entropie_shannon_casemix
```

### `/ght-r <fiche>` — Implémentation R
Génère le code R/dplyr exécutable (portail ATIH via Teradata/dbplyr, SNDS, datamarts locaux) à partir d'une fiche d'indicateur. La skill détecte automatiquement un profil de mapping existant dans `profils/<base>_<champ>.md` ; à défaut elle demande le mapping schéma → colonnes, et **enrichit le profil partagé** en fin d'exécution pour que les prochaines invocations n'aient plus à le redemander.

```
/ght-r indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md
/ght-r <fiche> --no-save-profil   # mapping ad-hoc, sans persistance
```

Voir `profils/README.md` pour les détails du mécanisme.

### `/ght-page-refresh` — Mise à jour de la page
Régénère l'index de recherche de la GitHub Page (`docs/data/index.json`) à partir des fiches `indicateurs_pmsi/` et des scripts `scripts_r/` courants, puis affiche un diff lisible (nouvelles fiches, fiches retirées, scripts R ajoutés). Sans elle, la page web continue de servir l'ancien index après l'ajout d'une fiche. La skill **ne commit ni ne push jamais** : elle ne touche qu'à `docs/data/index.json` et rappelle les commandes de publication à lancer soi-même. Proposée spontanément en fin de `/ght-dev` et `/ght-r`.

```
/ght-page-refresh
```

**Pipeline type** : `/ght-gen` → sélection d'un candidat → `/ght-dev` → `/ght-r` → script prêt à exécuter → `/ght-page-refresh` pour publier dans la recherche.

## Sources de données

- **PMSI MCO RSA** — séjours, GHM, diagnostics, actes CCAM
- **PMSI SSR RHS / PMSI PSY** — activité SSR et psychiatrie
- **SNDS DCIR** — consommations ambulatoires, médicaments, biologie
- **Référentiels ATIH** — poids GHM, IP-DMS, DMS nationales
