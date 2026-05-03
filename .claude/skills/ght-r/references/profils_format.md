# Format des fichiers profil de mapping

Les profils sont des fichiers markdown stockés dans `profils/` à la
racine du repo. Un profil = **une base × un champ PMSI**.

Convention de nommage : `<base>_<champ>.md`
- `portail_atih_mco.md`, `portail_atih_ssr.md`, `portail_atih_had.md`
- `datamart_chu_<nom>_<champ>.md` pour les datamarts locaux
- `snds_<champ>.md` pour le SNDS

Référence canonique : `profils/portail_atih_mco.md` du repo
`pilotage-ght`.

## Schéma obligatoire

```markdown
# Profil — <Libellé base> / <Champ>

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | <nom lisible>                               |
| SGBD              | <Teradata / PostgreSQL / Oracle / ...>      |
| Connexion         | `<expression R de connexion>`               |
| Schéma            | `<motif annuel ex: prd_vue_mco_AAAA, ou nom fixe>` |
| Années couvertes  | <plage, ou "n/a">                           |
| Clé universelle   | `<colonne, ex: ident>`                      |

Le champ `Schéma` peut être un motif annuel (`AAAA`) pour bases
partitionnées (portail ATIH) ou un nom fixe pour bases non partitionnées
(SNDS, datamarts). Si pas de partition annuelle, `Années couvertes : n/a`.

## `<nom_vue>` — <cardinalité par séjour>

| Concept                      | Colonne         |
|------------------------------|-----------------|
| <Libellé concept normalisé>  | `<col>`         |
| ...                          | ...             |

## Pièges

| Piège                    | Traitement                       |
|--------------------------|----------------------------------|
| ...                      | ...                              |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| ...                       | ...                             |
```

## Règles de cohérence pour les écritures successives

- **Une vue par section `## <nom_vue>`**, jamais deux sections pour la
  même vue. Lors d'une fusion, ajouter les nouvelles lignes au tableau
  existant, ne pas dupliquer la section.
- **Concepts normalisés** : utiliser des libellés stables et
  réutilisables — `Id séjour (clé)`, `GHM (6 car)`, `Racine GHM
  (5 car)`, `CMD (2 car)`, `DP`, `DR`, `Code CIM-10`, `Code CCAM
  (7 car)`, `FINESS juridique`, `FINESS géographique (portant le DP)`,
  `Date entrée`, `Date sortie`, `Durée (nuitées)`, `Sexe`, `Âge
  (années)`, `IPP chaîné inter-séjours`. Ces libellés doivent matcher
  exactement entre invocations pour permettre la détection de conflit.
- **Colonne expression** : si la donnée est dérivée, la colonne peut
  être une expression R (`substr(ghm2, 1, 5)`).
- **Pièges** et **Défauts recommandés** sont concaténés en cas de
  fusion (dédupliquer les lignes identiques).

## Détection de conflit

Conflit = même vue × même libellé concept × colonne différente.
Dans ce cas, la skill doit afficher un diff `ancien → nouveau` et
demander confirmation avant d'écraser.

Si une vue existe avec des lignes différentes mais aucune ligne en
conflit (concepts disjoints), c'est un **enrichissement silencieux**.
