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
/ght-gen <domaine> --no-web            # désactive la veille (mode hors-ligne)
/ght-gen <domaine> --since <YYYY>      # restreint la veille aux publications depuis cette année (défaut: année courante - 2)
```

## Veille préalable (obligatoire sauf `--no-web`)

Avant toute génération, exécuter une veille ciblée et produire une synthèse de **3 à 8 puces horodatées et sourcées** (URL ou PMID), placée juste avant la liste des candidats. Si rien de pertinent n'émerge : écrire explicitement « Veille : aucune nouveauté pertinente sur <domaine> ».

**Sources officielles** — via `WebSearch` puis `WebFetch` ciblé :
- ATIH — `atih.sante.fr` (notices techniques PMSI, guides méthodologiques, campagne tarifaire en cours)
- HAS — `has-sante.fr` (IPAQSS, indicateurs qualité-sécurité)
- DGOS / Ministère santé — `sante.gouv.fr` (instructions, circulaires GHT)
- IRDES — `irdes.fr` (méthodes, working papers)
- DREES — `drees.solidarites-sante.gouv.fr` (panoramas, études)
- ScanSanté — `scansante.fr` (nouveaux restituts)

**PubMed** — via le serveur MCP `claude.ai PubMed` :
- `mcp__claude_ai_PubMed__search_articles` avec mots-clés du domaine + filtres `("hospital indicator" OR "case-mix" OR "PMSI" OR "DRG" OR "quality measure")`, fenêtre par défaut = 24 derniers mois (paramétrable via `--since`)
- `mcp__claude_ai_PubMed__get_article_metadata` pour confirmer titre/année/PMID avant citation

**Cache de session** : ne pas relancer la veille si un appel `/ght-gen` sur le même `<domaine>` a déjà eu lieu dans la session courante — réutiliser la synthèse existante.

**Règle anti-hallucination** : aucune URL, PMID ni attribution `auteur année` ne doit être cité sans avoir été obtenu et confirmé via `WebSearch`/MCP PubMed dans la session — pas de citation « de tête ». Si la veille n'a rien donné sur un candidat, son `t:` reste générique (cadre théorique) et son `s:` vaut `interne`. Note : `WebFetch` est souvent bloqué (403) sur les sites institutionnels FR (dont `atih.sante.fr`) — utiliser `WebSearch` pour localiser l'info ; un 403/timeout ne signifie pas que la page est morte.

## Format de sortie

Chaque indicateur sur une ligne numérotée :

```
N. [i:<nom_snake_case>] [d:<définition 1 phrase>] [c:<formule compacte>] [u:<usage clé>] [l:<limite principale>] [t:<auteur année>] [s:<URL courte | PMID:xxxxx | interne>]
```

Champ `t:` (origine conceptuelle) :
- Par défaut, nommer le **cadre théorique / la discipline source** (ex. `t:théorie de l'information`, `t:files d'attente`), **pas** un article précis.
- N'écrire un `t:<auteur année>` spécifique que si ce papier a été **confirmé pendant la veille** (PubMed/Crossref) — et dans ce cas le champ `s:` doit porter le PMID/DOI vérifié correspondant. **Jamais d'« auteur année » de mémoire** : c'est la source n°1 des citations fantômes qui se propagent ensuite dans `/ght-dev`.

Champ `s:` :
- `s:interne` → candidat issu des connaissances modèle uniquement (aucune attribution `t:` à un article précis dans ce cas)
- `s:<url>` ou `s:PMID:12345` → candidat dérivé d'une source **identifiée et vérifiée** pendant la veille (PMID confirmé via `mcp__claude_ai_PubMed__get_article_metadata`, URL confirmée)

⚠️ Les champs `t:`/`s:` d'un candidat sont **provisoires** : `/ght-dev` re-validera chaque DOI/PMID via `doi.org/api/handles` (responseCode 1) avant de l'inscrire dans une fiche. Ne pas présenter ici une attribution comme établie ; en cas de doute, rester sur le cadre théorique générique.

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
- Citation d'une source non vérifiée (URL ou PMID inventé) → rejeté
- `t:<auteur année>` spécifique non confirmé par la veille (au lieu du cadre théorique générique) → rejeté
- Veille omise sans flag `--no-web` → rejeté

## Workflow recommandé

0. Veille web (sources officielles + PubMed) → synthèse 3–8 puces sourcées
1. `/ght-gen <domaine>` → liste de candidats numérotés (avec champ `s:`)
2. Sélectionner par numéro(s) les candidats retenus
3. `/ght-dev <nom_indicateur>` → développement complet en markdown

## Exemples

```
/ght-gen parcours
/ght-gen entropy casemix
/ght-gen territoire --lvl finess
/ght-gen efficience --n 8 --excl
```
