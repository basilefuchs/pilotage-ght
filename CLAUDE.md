# Contexte — pilotage-ght

Base de connaissance d'indicateurs GHT calculables PMSI / SNDS.

## Structure
10 thématiques hospitalières (activité, casemix, qualité, parcours, efficience, etc.)

## Indicateurs
Chaque indicateur suit un format standard :
- Définition
- Formule
- Sources de données
- Valeurs indicatives
- Limites
- Références

## Règles
- Indicateurs en français
- Code en anglais si nécessaire
- Innovation = adaptation de cadres scientifiques existants
- Données uniquement PMSI / SNDS / référentiels officiels
- Vérification humaine d'une fiche : flag `<!-- verifie: AAAA-MM-JJ nom -->` en première ligne, ajouté uniquement par l'utilisateur après relecture → pastille ✓ sur la GitHub Page
- La pastille est invalidée automatiquement par `build_docs.py` si la fiche est commitée après la date du flag

## Pipeline de génération

3 phases pour combiner efficience token et qualité :

**Phase 1 — exploration** `/ght-gen <domaine>`
→ liste compressée `[i,d,c,u,l,t]` de candidats à sélectionner

**Phase 2 — développement** `/ght-dev <nom_indicateur>`
→ fichier markdown complet au standard du projet, écrit dans `indicateurs_pmsi/<cat>/`

**Phase 3 — implémentation** `/ght-r <fiche>`
→ script R/dplyr exécutable (portail ATIH Teradata/dbplyr, SNDS, datamarts locaux), après mapping schéma → colonnes avec l'utilisateur

Dès qu'une fiche d'indicateur est finalisée (phase 2) et que l'utilisateur évoque calcul, code, requête ou implémentation, proposer `/ght-r`.

Référence qualité : `indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md`, `indicateurs_pmsi/05_qualite_securite/psi90_patient_safety_indicators.md`