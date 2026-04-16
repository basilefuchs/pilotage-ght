---
name: ght-dev
description: Développe un indicateur GHT compressé [i,d,c,u,l,t] en fichier markdown complet, au standard des indicateurs existants
trigger: /ght-dev
---

# /ght-dev

Phase 2 du pipeline — développement qualité. Prend un indicateur issu de `/ght-gen` (ou un nom d'indicateur) et produit le fichier markdown complet, au même niveau de rigueur que les indicateurs de référence du projet.

## Usage

```
/ght-dev <nom_indicateur>              # développe depuis le contexte courant (après /ght-gen)
/ght-dev "<[i,d,c,u,l,t]>"            # développe depuis une entrée compressée explicite
/ght-dev <nom> --cat <N>               # force la catégorie (01 à 10)
/ght-dev <nom> --write                 # écrit le fichier dans indicateurs_pmsi/ sans confirmation
```

## Format de sortie

Fichier markdown complet avec toutes les sections obligatoires :

```markdown
# <Titre de l'indicateur>

## Définition
[Concept, formule mathématique, positionnement vs indicateurs existants, pourquoi c'est nouveau]

## Calcul
[Source PMSI, pseudocode ou blocs de code, étapes numérotées, indicateurs dérivés si pertinents]

## Utilité
[5 à 7 cas d'usage concrets pour le pilotage GHT, avec valeurs de référence si possible]

## Sources de Données
[Tables PMSI/SNDS précises, variables utilisées, référentiels ATIH nécessaires]

## Exemple de Valeurs
[Plages de valeurs réalistes par type d'établissement ou contexte, seuils d'alerte]

## Limites
[Biais, conditions d'interprétation, seuils minimaux, limites de comparabilité]

## Références
[Citations académiques avec DOI, références ATIH, sources officielles]
```

## Règles qualité

- La **Définition** doit : expliquer le concept mathématique/scientifique source, justifier pourquoi les indicateurs PMSI actuels ne capturent pas cette information, poser la formule symbolique
- Le **Calcul** doit : donner les variables PMSI exactes (noms de champs), un pseudocode en blocs de code, les conventions pour les cas limites (division par 0, valeurs manquantes)
- L'**Utilité** doit : lister des cas d'usage opérationnels spécifiques au GHT, pas des généralités
- Les **Exemples de Valeurs** doivent : donner des plages réalistes par type d'établissement (CHU, CH, clinique) avec des chiffres concrets
- Les **Limites** doivent : mentionner les seuils minimaux (volume de séjours), les effets de version PMSI, les biais d'interprétation
- Les **Références** doivent : inclure les DOI quand disponibles

## Chemin de fichier

```
indicateurs_pmsi/<NN>_<categorie>/<nom_snake_case>.md
```

Catégories disponibles :
- 01_activite_production
- 02_casemix_patientele
- 03_vulnerabilite_sociale
- 04_efficience_capacitaire
- 05_qualite_securite
- 06_pertinence_pratiques
- 07_parcours_continuite
- 08_readmissions_evitables
- 09_territoire_attractivite
- 10_financement_valorisation

## Exemples

```
/ght-dev entropie_casemix_cmd
/ght-dev "[i:indice_resilience_flux] [d:mesure la capacité...] [c:...] [u:...] [l:...] [t:...]"
/ght-dev concentration_ghm --cat 02 --write
```
