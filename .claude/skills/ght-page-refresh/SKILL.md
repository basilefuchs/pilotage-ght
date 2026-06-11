---
name: ght-page-refresh
description: Régénère l'index JSON de la GitHub Page (docs/data/index.json) à partir des fiches actuelles d'indicateurs_pmsi/ et des scripts scripts_r/. Affiche un diff lisible (nouvelles fiches, fiches retirées, scripts R ajoutés). Ne fait JAMAIS de commit ni de push — l'utilisateur garde le contrôle. À déclencher avec /ght-page-refresh, ou à proposer spontanément après /ght-dev (nouvelle fiche markdown créée) et /ght-r (nouveau script R créé) pour que la page reste à jour.
trigger: /ght-page-refresh
---

# /ght-page-refresh

Met à jour l'index de recherche de la GitHub Page `docs/data/index.json` à partir du contenu courant du repo. Indispensable après avoir ajouté/modifié/supprimé une fiche `indicateurs_pmsi/**/*.md` ou un script `scripts_r/**/*.R`, sinon la page web continue de servir l'ancien index.

**Important : cette skill ne commit pas, ne push pas, ne modifie rien d'autre que `docs/data/index.json` — et éventuellement `docs/index.html` si `build_docs.py` y rafraîchit les versions d'assets (`?v=<hash>`, cache-busting).** L'utilisateur décide quand publier.

## Usage

```
/ght-page-refresh
```

Pas d'arguments. À exécuter depuis la racine du repo `pilotage-ght`.

## Étapes

### 1. Sanity check du contexte

Vérifier qu'on est bien dans le repo attendu :

```bash
test -f build_docs.py && test -f docs/data/index.json && test -d indicateurs_pmsi
```

Si l'un manque, **arrêter** et expliquer à l'utilisateur ce qui manque (probablement mauvais cwd, ou page jamais initialisée).

### 2. Capturer l'état avant

Lire l'ancien index pour pouvoir diffuser un diff lisible :

```bash
python3 -c "import json; d=json.load(open('docs/data/index.json')); print(len(d['entries']), sum(1 for e in d['entries'] if e['path_r'])); [print(e['id']) for e in d['entries']]" > /tmp/ght_before.txt
```

### 3. Régénérer l'index

```bash
python3 build_docs.py
```

Si le script échoue (fiche au format cassé, encodage), **ne pas insister** : remonter l'erreur exacte à l'utilisateur, suggérer la fiche probablement fautive (la dernière modifiée — `git status` la révèlera), et s'arrêter.

Le build peut imprimer des avertissements `⚠ <fiche> modifiée le … après vérification du … — pastille retirée` : une fiche portant le flag `<!-- verifie: AAAA-MM-JJ nom -->` a été commitée après sa date de vérification, sa pastille « vérifié » est donc invalidée. Relayer ces avertissements tels quels à l'utilisateur dans le rapport (étape 4) — c'est à lui de re-relire la fiche et de mettre à jour la date du flag.

### 4. Calculer et présenter le diff

Comparer l'avant et l'après. Présenter à l'utilisateur, en français, dans ce format :

```
Index régénéré : N fiches (Δ +x / -y), M avec script R (Δ +a / -b), V vérifiées (Δ +c / -d)

Nouvelles fiches (+x) :
  - indicateurs_pmsi/<cat>/<nom>   [+R si script R associé]
  - ...

Fiches retirées (-y) :
  - indicateurs_pmsi/<cat>/<nom>
  - ...

Nouveaux scripts R (+a) :
  - scripts_r/<cat>/<nom>.R   (lié à <fiche>)
  - ...
```

Si rien n'a changé : `Aucun changement détecté. L'index était déjà à jour.` — dans ce cas, suggérer à l'utilisateur que `git diff docs/data/index.json` ne montrera probablement que `generated_at`, et qu'il peut annuler le rebuild avec `git checkout docs/data/index.json` s'il préfère ne pas committer un timestamp seul.

Pour le calcul du diff, utiliser Python plutôt que `diff` shell — c'est l'`id` qui compte, pas l'ordre d'apparition. Exemple :

```bash
python3 <<'PY'
import json, pathlib
prev_ids, prev_r = set(), set()
for line in pathlib.Path('/tmp/ght_before.txt').read_text().splitlines()[1:]:
    prev_ids.add(line)
d = json.load(open('docs/data/index.json'))
cur_ids = {e['id'] for e in d['entries']}
cur_r = {e['id'] for e in d['entries'] if e['path_r']}
# … calcul des deltas et impression formatée
PY
```

(Le snippet ci-dessus est indicatif — adapter au besoin pour produire la sortie exacte demandée à l'étape 4.)

### 5. Rappel final (texte à afficher à l'utilisateur)

Terminer la réponse par exactement ce rappel, sans variation :

```
Index régénéré localement. Pour publier sur la page :
  git add docs/data/index.json
  git commit -m "docs: rebuild index"
  git push
```

**Ne pas exécuter ces commandes.** L'utilisateur a explicitement demandé à garder le contrôle de la publication.

## À ne pas faire

- Ne pas modifier `build_docs.py` « pour faire mieux » au passage. Si le script semble bogué, le signaler, ne pas le réécrire silencieusement.
- Ne pas toucher aux fiches `indicateurs_pmsi/`, aux scripts `scripts_r/`, ni aux fichiers `docs/` autres que `docs/data/index.json` (et `docs/index.html`, modifié uniquement par `build_docs.py` lui-même pour les versions d'assets). Si `git status` montre `docs/index.html` modifié après le build, l'inclure dans le rappel de publication.
- Ne pas committer, ne pas pusher, ne pas créer de branche.
- Ne pas proposer d'ouvrir une PR.

## Quand la déclencher spontanément

À la fin de `/ght-dev` (nouvelle fiche écrite) et `/ght-r` (nouveau script R écrit), proposer en une phrase :

> Veux-tu que je régénère l'index de la page (`/ght-page-refresh`) pour que ta nouvelle fiche apparaisse dans la recherche ?

Ne pas le faire sans l'accord explicite de l'utilisateur.
