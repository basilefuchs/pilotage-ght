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

## Pipeline de génération

2 phases pour combiner efficience token et qualité :

**Phase 1 — exploration** `/ght-gen <domaine>`
→ liste compressée `[i,d,c,u,l,t]` de candidats à sélectionner

**Phase 2 — développement** `/ght-dev <nom_indicateur>`
→ fichier markdown complet au standard du projet, écrit dans `indicateurs_pmsi/<cat>/`

Référence qualité : `indicateurs_pmsi/02_casemix_patientele/entropie_shannon_casemix.md`, `indicateurs_pmsi/05_qualite_securite/psi90_patient_safety_indicators.md`