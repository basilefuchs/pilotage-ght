---
name: ght-gen
description: Génère des indicateurs GHT/PMSI candidats en format compressé [i,d,c,u,l,t] pour exploration rapide
trigger: /ght-gen
---

# /ght-gen

Phase 1 du pipeline — exploration token-efficiente. Produit une liste d'indicateurs candidats en format compressé pour sélection rapide avant développement complet avec `/ght-dev`.

## Usage

```
/ght-gen <domaine>                     # génère 5 candidats sur un domaine (ex: parcours, efficience)
/ght-gen <transform> <domaine>         # ciblé par transformation (ex: entropy casemix)
/ght-gen <domaine> --n <nb>            # nombre de candidats (défaut: 5)
/ght-gen <domaine> --lvl <niveau>      # granularité cible: rsa, ghm, cmd, um, finess, temps
/ght-gen <domaine> --excl              # exclure les indicateurs déjà présents dans indicateurs_pmsi/
```

## Format de sortie

Chaque indicateur sur une ligne numérotée :

```
N. [i:<nom_snake_case>] [d:<définition 1 phrase>] [c:<formule compacte>] [u:<usage clé>] [l:<limite principale>] [t:<auteur année>]
```

## Règles de génération

- Chaque indicateur doit respecter : 1 type + 1 dim + 1 lvl (+ transform optionnel)
- Types : rate(A/B) | flow(nb/t) | delay(t2-t1) | dur(sum(t)/n) | occ(used/cap)
- Transforms : entropy | concentration | variance | distance | network | control
- Dimensions : activité | qualité | parcours | efficience | réadmissions | organisation | territoire | financement
- Données : PMSI MCO/SSR/PSY ou SNDS uniquement — indicateur doit être calculable
- Pas de doublon avec l'existant — vérifier avant de proposer
- Pas de reformulation d'un indicateur déjà présent
- Pas d'analogie sans formule calculable sur les données

## Anti-patterns

- Indicateur non calculable depuis PMSI/SNDS → rejeté
- Formule vague ou non opérationnelle → rejeté
- Doublon conceptuel avec existant → rejeté

## Workflow recommandé

1. `/ght-gen <domaine>` → liste de candidats numérotés
2. Sélectionner par numéro(s) les candidats retenus
3. `/ght-dev <nom_indicateur>` → développement complet en markdown

## Exemples

```
/ght-gen parcours
/ght-gen entropy casemix
/ght-gen territoire --lvl finess
/ght-gen efficience --n 8 --excl
```
