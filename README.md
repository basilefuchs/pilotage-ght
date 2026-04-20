# Base de connaissances — Indicateurs PMSI/GHT

Base de référence de 185 indicateurs de pilotage hospitalier pour les GHT, calculables depuis le PMSI MCO/SSR/PSY et le SNDS.

## Structure

```
indicateurs_pmsi/
├── 01_activite_production/       (27 indicateurs)
├── 02_casemix_patientele/        (22 indicateurs)
├── 03_vulnerabilite_sociale/     (7 indicateurs)
├── 04_efficience_capacitaire/    (23 indicateurs)
├── 05_qualite_securite/          (24 indicateurs)
├── 06_pertinence_pratiques/      (17 indicateurs)
├── 07_parcours_continuite/       (26 indicateurs)
├── 08_readmissions_evitables/    (11 indicateurs)
├── 09_territoire_attractivite/   (20 indicateurs)
└── 10_financement_valorisation/  (8 indicateurs)
```

Chaque fiche documente : définition, formule de calcul, sources de données, exemple de valeurs, limites et références.

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

Trois skills Claude Code permettent de générer et implémenter de nouveaux indicateurs selon un pipeline en 3 phases :

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
Génère le code R/dplyr exécutable (portail ATIH via Teradata/dbplyr, SNDS, datamarts locaux) à partir d'une fiche d'indicateur. Demande le mapping schéma → colonnes avant finalisation.

```
/ght-r indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md
```

**Pipeline type** : `/ght-gen` → sélection d'un candidat → `/ght-dev` → `/ght-r` → script prêt à exécuter.

## Sources de données

- **PMSI MCO RSA** — séjours, GHM, diagnostics, actes CCAM
- **PMSI SSR RHS / PMSI PSY** — activité SSR et psychiatrie
- **SNDS DCIR** — consommations ambulatoires, médicaments, biologie
- **Référentiels ATIH** — poids GHM, IP-DMS, DMS nationales
