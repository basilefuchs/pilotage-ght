# Contexte du projet — pilotage-ght

Base de connaissances de 161 indicateurs de pilotage hospitalier pour les GHT,
calculables depuis le PMSI MCO/SSR/PSY/HAD et le SNDS.

## Structure du dépôt

```
index.md               Index Obsidian racine (liens vers les 10 thématiques)
indicateurs_pmsi/
├── 01_activite_production/
│   ├── 01_activite_production.md  Index Obsidian de la thématique
│   └── ...                        13 indicateurs
├── 02_casemix_patientele/
│   ├── 02_casemix_patientele.md
│   └── ...                        21 indicateurs
├── 03_vulnerabilite_sociale/
│   ├── 03_vulnerabilite_sociale.md
│   └── ...                         7 indicateurs
├── 04_efficience_capacitaire/
│   ├── 04_efficience_capacitaire.md
│   └── ...                        21 indicateurs
├── 05_qualite_securite/
│   ├── 05_qualite_securite.md
│   └── ...                        24 indicateurs
├── 06_pertinence_pratiques/
│   ├── 06_pertinence_pratiques.md
│   └── ...                        13 indicateurs
├── 07_parcours_continuite/
│   ├── 07_parcours_continuite.md
│   └── ...                        27 indicateurs
├── 08_readmissions_evitables/
│   ├── 08_readmissions_evitables.md
│   └── ...                        11 indicateurs
├── 09_territoire_attractivite/
│   ├── 09_territoire_attractivite.md
│   └── ...                        18 indicateurs
└── 10_financement_valorisation/
    ├── 10_financement_valorisation.md
    └── ...                         6 indicateurs

convert_to_json.py     Exporte les fiches vers pmsi_indicateurs.json
pmsi_indicateurs.json  Export JSON de tous les indicateurs
```

## Création d'une nouvelle fiche indicateur

Lors de la création d'une fiche `nom_indicateur.md` dans un dossier thématique, effectuer **obligatoirement** ces deux actions dans le même temps :

1. **Mettre à jour l'index de la thématique** — ajouter `- [[nom_indicateur]]` dans le fichier `XX_thematique/XX_thematique.md`, en respectant l'ordre alphabétique de la liste.
2. **Mettre à jour le compteur dans CLAUDE.md** — incrémenter le nombre d'indicateurs du dossier concerné dans l'arborescence ci-dessus.

Ne jamais créer une fiche sans faire ces deux mises à jour.

## Format des fiches indicateurs

Chaque fiche `.md` suit ce schéma :
- `## Définition` — description courte
- `## Formule` — formule de calcul
- `## Sources de données` — PMSI MCO/SSR/PSY/HAD, SNDS DCIR, référentiels ATIH
- `## Exemple de valeurs` — ordre de grandeur
- `## Limites` — biais, précautions d'interprétation
- `## Références` — liens externes

## Conventions

- Langue : fiches en français, code en anglais
- Indicateurs "innovants" : adaptent des cadres d'autres disciplines (physique, finance, écologie…)
- Sources primaires : ATIH, HAS, OCDE, DREES, références académiques
