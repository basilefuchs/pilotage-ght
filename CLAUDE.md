# Contexte — pilotage-ght

Base de connaissance d'indicateurs GHT calculables PMSI / SNDS, avec une page de recherche publiée (GitHub Pages depuis `docs/`).

Ce dépôt est une **preuve de concept (POC)** : base d'exemple et de test des skills ad hoc de `basilefuchs/skills` (`ght-gen`, `ght-dev`, parcours `to-protocole → pdh-schema → pdh-query`). Les skills vivent là-bas et s'installent avec `npx skills add basilefuchs/skills --skill <nom> -a claude-code -g`. Ici : les fiches, les scripts R, la page et son outillage.

## Structure
- `indicateurs_pmsi/<NN>_<categorie>/` : 10 thématiques hospitalières (activité, casemix, qualité, parcours, efficience, etc.)
- `scripts_r/<categorie>/` : scripts R hérités de l'ancienne skill `ght-r`, `<nom>.R` ou `<nom>.<base>.R` par variante de base ; plus alimentés, les nouveaux calculs passent par le parcours protocole hors du dépôt
- `helpers_r/` : briques R partagées par les scripts
- `docs/`, `build_docs.py` : page de recherche et son index
- `.claude/skills/ght-page-refresh` : seule skill locale, régénère l'index de la page sans commit ni push

## Fiches
Chaque fiche suit un format standard : définition, calcul, utilité, sources de données, exemple de valeurs, limites, références.

## Règles
- Indicateurs en français
- Code en anglais si nécessaire
- Innovation = adaptation de cadres scientifiques existants
- Données uniquement PMSI / SNDS / référentiels officiels
- Vérification humaine d'une fiche : flag `<!-- verifie: AAAA-MM-JJ nom -->` en première ligne, ajouté uniquement par l'utilisateur après relecture → pastille ✓ sur la GitHub Page
- La pastille est invalidée automatiquement par `build_docs.py` si la fiche est commitée après la date du flag
- Après l'ajout d'une fiche ou d'un script, proposer `/ght-page-refresh`

Référence qualité : `indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md`, `indicateurs_pmsi/05_qualite_securite/psi90_patient_safety_indicators.md`
