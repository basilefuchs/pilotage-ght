# Base de connaissances — Indicateurs PMSI/GHT

Base de référence d'indicateurs de pilotage hospitalier pour les GHT, calculables depuis le PMSI MCO/SMR/HAD/PSY et le SNDS, publiée sous forme de page de recherche.

**Ce dépôt est une base d'exemple et de test** des skills ad hoc du dépôt [basilefuchs/skills](https://github.com/basilefuchs/skills) : les fiches y sont produites par `ght-gen` et `ght-dev`, les scripts R par le parcours `to-protocole → pdh-schema → pdh-query` (ou la branche SNDS). Les skills vivent là-bas ; ici ne restent que les fiches, les scripts, la page et l'outillage de la page.

## Structure

```
indicateurs_pmsi/
├── 01_activite_production/       (29 fiches)
├── 02_casemix_patientele/        (27 fiches)
├── 03_vulnerabilite_sociale/     (18 fiches)
├── 04_efficience_capacitaire/    (26 fiches)
├── 05_qualite_securite/          (41 fiches)
├── 06_pertinence_pratiques/      (19 fiches)
├── 07_parcours_continuite/       (43 fiches)
├── 08_readmissions_evitables/    (11 fiches)
├── 09_territoire_attractivite/   (38 fiches)
└── 10_financement_valorisation/  (10 fiches)
scripts_r/<categorie>/            scripts R des indicateurs implémentés (38 scripts, 37 indicateurs)
helpers_r/                        briques R partagées par les scripts (ex. score de Charlson)
docs/                             page de recherche publiée (GitHub Pages)
build_docs.py                     génère l'index de la page depuis les fiches et les scripts
```

Total : **262 fiches**. Chaque fiche documente : définition, calcul, utilité, sources de données, exemple de valeurs, limites et références.

## Site web (GitHub Pages)

Page de recherche statique publiée depuis `docs/` :
**https://basilefuchs.github.io/pilotage-ght/**

Recherche par mots-clés parmi les fiches, filtre par catégorie, script R associé quand il existe (un onglet par variante de base : `<nom>.R`, `<nom>.snds.R`…).

Après ajout ou modification de fiches, régénérer l'index. La skill locale **`/ght-page-refresh`** (`.claude/skills/`) relance `build_docs.py`, affiche un diff lisible et ne commit ni ne push rien. À défaut :

```
python3 build_docs.py
```

Aperçu local :

```
cd docs && python3 -m http.server 8000
```

> Activation initiale : *Settings → Pages → Source : Deploy from branch → `main` / `/docs`*.

**Vérification humaine.** Une fiche relue porte en première ligne `<!-- verifie: AAAA-MM-JJ nom -->`, ajouté à la main après relecture : la page affiche une pastille ✓. `build_docs.py` retire la pastille si la fiche a été commitée après la date du flag.

## Produire de nouvelles fiches et scripts

Les skills s'installent depuis [basilefuchs/skills](https://github.com/basilefuchs/skills) (voir son README pour claude.ai, LibreChat et les autres agents) :

```
npx skills add basilefuchs/skills --skill ght-gen -a claude-code -g
npx skills add basilefuchs/skills --skill ght-dev -a claude-code -g
```

Depuis la racine de ce dépôt :

1. `/ght-gen <domaine>` : candidats compressés, sélection par numéro.
2. `/ght-dev <nom>` : fiche complète, références vérifiées, écrite dans `indicateurs_pmsi/<categorie>/`.
3. `/ght-page-refresh` : index de la page régénéré.

Pour le script R d'un indicateur : `/to-protocole` avec la fiche comme idée d'étude, puis `/pdh-schema` et `/pdh-query` (portail ATIH) ou `/snds-schema` et `/snds-query` (Health Data Hub). Le script obtenu se range dans `scripts_r/<categorie>/<nom>.R` (suffixe `.snds.R` pour une variante SNDS) pour apparaître sur la page.

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

## Sources de données

- **PMSI MCO RSA** — séjours, GHM, diagnostics, actes CCAM
- **PMSI SMR RHS / PMSI PSY / HAD** — activité SMR, psychiatrie, HAD
- **SNDS DCIR** — consommations ambulatoires, médicaments, biologie
- **Référentiels ATIH** — poids GHM, IP-DMS, DMS nationales
