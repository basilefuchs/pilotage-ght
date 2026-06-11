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
/ght-dev <nom> --no-web                # désactive la recherche (mode hors-ligne)
/ght-dev <nom> --since <YYYY>          # restreint la veille bibliographique (défaut: année courante - 5)
/ght-dev <nom> --depth <quick|deep>    # quick = 1 passe PubMed + 1 ATIH ; deep = full A/B/C (défaut: deep)
```

## Recherche ciblée (obligatoire sauf `--no-web`)

Avant rédaction, exécuter une recherche ciblée sur l'indicateur précis et produire une **synthèse pré-rédaction de 5–10 puces sourcées (PMID ou URL)** qui alimentera Définition / Sources / Exemples / Limites / Références.

**A. Méthodologie scientifique** — via MCP PubMed
- `mcp__claude_ai_PubMed__search_articles` avec le nom conceptuel de l'indicateur + dimension (ex. « Shannon entropy case-mix », « readmission risk-adjusted DRG »)
- `mcp__claude_ai_PubMed__find_related_articles` à partir d'un PMID-clé pour élargir
- `mcp__claude_ai_PubMed__get_article_metadata` pour obtenir titre/auteurs/année/DOI **avant** citation
- Cibler : Health Services Research, Med Care, BMC Health Serv Res, Rev Epidemiol Sante Publique, J Epidemiol Community Health
- Objectif : alimenter **Définition + Limites + Références** (3–6 papiers vérifiés)

**B. Réglementaire & technique français** — via WebSearch + WebFetch ciblé
- ATIH `atih.sante.fr` : guide méthodologique PMSI MCO/SSR/HAD/Psy en vigueur, fichier des variables, formats RSA/RHA, notices de campagne
- HAS `has-sante.fr` : si l'indicateur touche qualité/sécurité (IPAQSS, indicateurs nationaux)
- ScanSanté `scansante.fr` : restitutions publiques équivalentes (pour les **Exemples de Valeurs**)
- DREES `drees.solidarites-sante.gouv.fr` : panoramas hospitaliers (plages réalistes)
- Objectif : alimenter **Sources de Données + Exemples de Valeurs**, garantir que les noms de champs PMSI sont à jour

**C. Vérification anti-doublon élargie** — via WebSearch
- chercher si l'indicateur (ou un cousin proche) existe déjà sous un autre nom dans la littérature française/internationale
- influence la section Définition (« positionnement vs indicateurs existants »)

**Cache de session** : si `/ght-gen` a tourné dans la session sur le même domaine, réutiliser sa synthèse et ne lancer que les recherches complémentaires propres à l'indicateur.

**Règle anti-hallucination** : aucun DOI, PMID, URL ATIH ou nom de variable PMSI ne doit apparaître dans la fiche sans avoir été vérifié dans la session courante (cf. « Vérification des références » ci-dessous). Une variable PMSI non confirmée doit être marquée `[à confirmer]` plutôt qu'inventée.

## Vérification des références (obligatoire, sauf `--no-web`)

**Leçon clé** : un DOI écrit « de mémoire » pour un article connu est la première source d'erreur — le modèle produit un DOI *plausible mais faux*, à quelques caractères près, qui ressemble à un vrai. **Ne jamais écrire un DOI de tête.** Le DOI doit toujours provenir d'une API qui l'a renvoyé pour cet article précis.

### Workflow par référence

1. **Trouver l'article, pas le DOI.** `mcp__claude_ai_PubMed__search_articles` (titre + auteur), ou Crossref bibliographique :
   ```bash
   curl -s "https://api.crossref.org/works?rows=3&mailto=<email>&query.bibliographic=<titre+auteurs+année>"
   ```
   Prendre le DOI **renvoyé par l'API**, et exiger une **concordance forte titre + 1er auteur + année** avec la référence visée. ⚠️ Un score Crossref élevé ne garantit rien (il peut pointer une *recommandation F1000*, un *erratum* ou un *working paper* qui contient le même titre) — c'est la concordance titre/auteur/année qui tranche, pas le score.

2. **Valider que le DOI résout**, via le résolveur officiel — **PAS** la page éditeur (qui renvoie 403 aux robots → faux négatifs systématiques) :
   ```bash
   curl -s "https://doi.org/api/handles/<DOI>" | python3 -c "import sys,json;print(json.load(sys.stdin).get('responseCode'))"
   ```
   `1` = le DOI existe → OK ; `100` = introuvable → **DOI faux, ne pas l'utiliser** (revenir à l'étape 1).
   ⚠️ Piège des vieux DOI Elsevier avec parenthèses (`10.1016/S0140-6736(12)60240-2`) : ne pas tronquer la chaîne au premier `)`.

3. **Pas de DOI ? c'est normal et acceptable** (chapitres de livre, rapports officiels ATIH/DREES/IGAS, articles anciens). Ne **jamais** inventer un DOI pour combler le vide :
   - article ancien indexé PubMed → lien `https://pubmed.ncbi.nlm.nih.gov/<PMID>/` (PMID vérifié via MCP PubMed) ;
   - chapitre / rapport → citation texte complète **sans lien**, ou lien vers la page officielle vérifiée à 200.

### Vérification des URL (institutionnelles & autres)

- Vérifier chaque URL avec un User-Agent navigateur, en suivant les redirections :
  ```bash
  curl -sIL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36" -o /dev/null -w "%{http_code}" "<url>"
  ```
  Garder si `2xx`/`3xx`.
- **403 / 429 / timeout (`000`) ≠ lien mort.** Beaucoup de sites vivants bloquent les robots (OECD, Légifrance, NHS Digital, ScienceDirect, Cairn, BCG, e-cancer.fr, scopesante.fr, AHRQ) ou échouent en TLS/DNS depuis un environnement restreint. **Ne pas remplacer un lien seulement bloqué** — le conserver. Seuls `404/410/DNS inexistant/domaine migré` justifient une correction.
- **WebFetch est lui-même bloqué (403)** sur beaucoup de sites institutionnels FR (dont `atih.sante.fr`) : pour trouver l'URL courante, utiliser `WebSearch` (avec `allowed_domains`), puis confirmer le `200` avec `curl` (UA navigateur).
- **Préférer une page stable** (racine de section) à un lien profond daté : ATIH/DREES/WHO réorganisent régulièrement leurs chemins, et `who.int/europe` a remplacé `euro.who.int`.

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
- Les **Références** doivent : pour chaque entrée, soit un DOI **issu d'une API et validé via `doi.org/api/handles` (responseCode 1)**, soit un PMID vérifié, soit (chapitre/rapport sans DOI) une citation texte sans lien ou une URL officielle vérifiée à 200 ; jamais de DOI reconstitué de mémoire
- Les **Sources de Données** doivent : nommer les variables PMSI selon le guide ATIH **en vigueur** confirmé par WebFetch, pas selon les habitudes du modèle
- Les **Exemples de Valeurs** doivent : citer la source des plages (ScanSanté restitution X année Y, DREES panorama Z) ou indiquer explicitement « ordre de grandeur expert, non sourcé »

## Anti-patterns

- DOI écrit de mémoire, ou « vérifié » uniquement en ouvrant la page éditeur (403 = faux positif des deux côtés) → rejet de la fiche
- DOI dont `doi.org/api/handles` renvoie `100`, ou dont le titre/auteur/année ne concorde pas avec la référence → rejet
- DOI inventé pour un chapitre/rapport qui n'en a pas (utiliser PMID, citation sans lien, ou URL officielle 200) → rejet
- Lien remplacé alors qu'il n'était que bloqué anti-bot (403/429/timeout) et non réellement mort → rejet
- Variable PMSI nommée sans confirmation guide ATIH courant → marquer `[à confirmer]` plutôt qu'inventer
- Plages de valeurs sans source ni mention « ordre de grandeur expert » → rejeté
- Recherche omise sans flag `--no-web` → rejeté

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
