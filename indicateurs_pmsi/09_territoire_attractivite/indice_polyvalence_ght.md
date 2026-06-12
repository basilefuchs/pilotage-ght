# Indice de polyvalence d'un GHT

## Définition

L'**indice de polyvalence** mesure la diversité de l'activité d'un GHT à travers la dispersion de ses séjours sur les **catégories majeures de diagnostic** (CMD) — ou, en version plus fine, sur les **racines de GHM**. Un GHT qui distribue ses séjours uniformément sur l'ensemble des 28 CMD est dit « polyvalent » ; un GHT dont 70 % des séjours se concentrent sur 3 CMD est dit « spécialisé ».

L'indice utilisé est le **Gini-Simpson** (= 1 − indice de Simpson), équivalent à l'entropie d'ordre 2 de Hill et symétrique de l'indice de Herfindahl-Hirschman :

```
Polyvalence(GHT) = 1 − Σ_i p_i²
```

où `p_i` = part des séjours du GHT relevant de la CMD *i*. La valeur est bornée dans [0, 1 − 1/N] avec *N* le nombre de CMD :
- 0 = activité totalement concentrée sur une seule CMD
- ~0,964 (= 1 − 1/28) = répartition parfaitement uniforme sur 28 CMD

C'est la **caractéristique n°1** officielle de la grille ScanSanté pour positionner stratégiquement un GHT (polyvalent vs spécialisé).

Positionnement vs indicateurs existants :
- `entropie_shannon_casemix.md` (catégorie 02) utilise l'entropie de Shannon (ordre 1) au niveau **établissement** sur les **GHM**.
- `indice_herfindahl_concentration_flux_patients.md` (catégorie 09) mesure la concentration des **flux patients** (origine géographique), pas de l'activité par CMD.
- Le présent indicateur est défini au niveau **GHT**, sur la maille **CMD**, et utilise la métrique officielle ATIH — il est l'agrégat territorial de la polyvalence.

## Calcul

**Source PMSI** : table des RSA (PMSI MCO) consolidée au niveau GHT (somme sur tous les FINESS-GEO membres du GHT).

**Variables PMSI mobilisées** :
- `finessgeo` → mapping vers `CODE_GHT` (table ATIH des GHT à jour)
- `GHM` (6 caractères) → extraire les 2 premiers caractères = **CMD**
- `NUM_SEJ_ANO` (anonymisation séjour, comptage)

**Pseudocode** :

```r
# 1. Charger correspondance FINESS → GHT (référentiel ATIH)
ght_map <- read_referentiel_ght(annee = A)

# 2. Agréger les séjours par GHT × CMD
agg <- rsa %>%
  filter(annee == A) %>%
  mutate(
    cmd = substr(ghm, 1, 2),
    ght = ght_map$ght[match(num_finess_geo, ght_map$finess)]
  ) %>%
  filter(!is.na(ght), cmd != "90") %>%   # exclure séjours en erreur (CMD 90)
  count(ght, cmd, name = "n")

# 3. Calculer le Gini-Simpson par GHT
polyvalence <- agg %>%
  group_by(ght) %>%
  mutate(p = n / sum(n)) %>%
  summarise(
    polyvalence = 1 - sum(p^2),
    n_cmd_actives = n_distinct(cmd),
    n_sejours = sum(n),
    .groups = "drop"
  ) %>%
  mutate(
    polyvalence_normalisee = polyvalence / (1 - 1/28)
  )
```

**Conventions cas limites** :
- CMD 90 (séjours en erreur) : à exclure du calcul.
- CMD 28 (séjours de courte durée — usage ATIH variable selon campagne) : conserver, c'est une activité réelle.
- GHT avec < 5 000 séjours/an : indicateur instable, à reporter avec mention.
- Une variante plus fine remplace la CMD par la **racine de GHM** (4 premiers caractères du GHM) — `polyvalence_racine_ghm` ; la valeur maximale théorique passe alors à 1 − 1/~700, beaucoup plus exigeante.

## Utilité

1. **Positionnement stratégique GHT** : segmenter les GHT en 4 quadrants polyvalence × volume pour piloter la complémentarité au sein de la région.
2. **Identification de l'établissement support** : au sein d'un GHT, comparer la polyvalence du support vs périphérie pour ajuster la gradation des soins.
3. **Pilotage des projets médicaux partagés** : un GHT en sur-spécialisation sur 2-3 CMD peut signaler un déficit de couverture des besoins de proximité (chir digestif, gériatrie, obstétrique).
4. **Détection d'érosion** : suivi annuel de la polyvalence — une baisse régulière signale une perte progressive d'activités sur le territoire (souvent transférée vers privé ou CHU).
5. **Comparaison inter-GHT** : utilisable comme dénominateur pour relativiser d'autres indicateurs (par exemple, IP-DMS comparé entre GHT de polyvalence comparable).
6. **Dialogue de gestion ARS** : indicateur sentinelle pour identifier les GHT qui se spécialisent par défaut (fermeture de services) vs par choix stratégique (filières expertes).
7. **Lecture mémoire d'un GHT** : couplé à `entropie_shannon_casemix.md` au niveau établissement, comprendre si la diversité GHT vient de la diversité de chaque membre ou de la complémentarité entre membres.

## Sources de Données

- **PMSI MCO** : table RSA (ATIH), 1 ligne par séjour. Champs : `finessgeo`, `GHM`, `ANNEE`.
- **Référentiel GHT** : table de correspondance FINESS géographique → GHT, publiée annuellement par la DGOS / ATIH. URL : https://www.atih.sante.fr/organisation-territoriale-des-soins/groupements-hospitaliers-de-territoire
- **Référentiel CMD** : nomenclature des 28 CMD du PMSI MCO, guide méthodologique ATIH en vigueur.

Restitution publique équivalente : ScanSanté → « Caractériser et suivre un GHT » → caractéristique « polyvalence ».

## Exemple de Valeurs

Plages d'ordre de grandeur observées (Gini-Simpson sur 28 CMD, non sourcé au chiffre près) :

| Profil de GHT | Polyvalence | Polyvalence normalisée (/ 0,964) |
|---|---|---|
| GHT mono-CHU dominant + petites filières | 0,82 – 0,88 | 0,85 – 0,91 |
| GHT support polyvalent + 2-3 CH périphériques | 0,90 – 0,93 | 0,93 – 0,96 |
| GHT spécialisé (cancérologie, MCO réduit) | 0,65 – 0,78 | 0,67 – 0,81 |
| Établissement seul mono-CMD (ex : CLCC isolé) | 0,15 – 0,40 | 0,16 – 0,41 |

Seuils d'alerte :
- Polyvalence normalisée < 0,80 sur un GHT support : risque de sous-couverture territoriale, examen approfondi recommandé.
- Variation annuelle > 0,03 (à population stable) : signale un événement structurant (fermeture/ouverture de service).

Source des plages : ordre de grandeur expert, à valider sur les restitutions ScanSanté de la campagne en cours.

## Limites

- **Sensibilité à la granularité** : passer de 28 CMD à ~700 racines GHM peut inverser le classement de deux GHT. Toujours expliciter la maille.
- **Pondération en nb de séjours** : un séjour ambulatoire de chirurgie de la cataracte compte autant qu'un séjour de greffe — l'indice ne reflète pas la lourdeur. Variante pondérée par les points ISA / valorisation possible.
- **Effet taille** : les très petits GHT atteignent mécaniquement une polyvalence plus faible par défaut de remplissage de certaines CMD. Volume minimal recommandé : 5 000 séjours/an.
- **CMD 90** : si conservée par erreur, gonfle artificiellement la diversité. Exclusion obligatoire.
- **Effet version PMSI** : reclassements GHM entre versions peuvent déplacer des séjours entre CMD (rare mais existant). Comparaisons inter-annuelles à corriger.
- **Non interprétable seul** : un GHT polyvalent peut être polyvalent par dispersion non maîtrisée (sous-volume sur chaque CMD = perte de qualité). À toujours croiser avec des seuils d'activité par discipline.
- **CMD vs racine GHM** : la CMD masque les sur-spécialisations intra-CMD (ex : 100 % de chirurgie orthopédique sur une seule racine de prothèse).

## Références

- ATIH, « Caractériser et suivre un GHT avec ScanSanté » — caractéristique « polyvalence ». URL : https://www.scansante.fr/caracteriser-et-suivre-un-groupement-hospitalier-de-territoire-ght
- ATIH JDH 2018, Atelier 4 — « Groupement hospitalier de territoire (GHT) avec ScanSanté », diaporama méthodologique. URL : https://www.atih.sante.fr/sites/default/files/public/jdh/ATIH-JDH-2018-Atelier4-Diaporama.pdf
- ATIH, organisation territoriale des soins — référentiel GHT. URL : https://www.atih.sante.fr/organisation-territoriale-des-soins/groupements-hospitaliers-de-territoire
- Hill, M.O. (1973). « Diversity and Evenness : A Unifying Notation and Its Consequences », *Ecology* 54(2):427-432 — fondement de la famille d'indices d'ordre q dont le Gini-Simpson (q=2). DOI : 10.2307/1934352
- Voir aussi `entropie_shannon_casemix.md` (catégorie 02) pour la version Shannon (ordre 1) au niveau établissement.
