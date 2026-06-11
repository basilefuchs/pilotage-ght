# Taux de Fuite Évitable Ajusté sur la Sévérité

## Définition

Le taux de fuite évitable restreint le taux de fuite classique aux séjours que le GHT était **plausiblement en mesure de produire** : séjours de sévérité faible ou modérée (niveaux de GHM 1 et 2, ainsi que les GHM ambulatoires J et T) dont la racine de GHM appartient au casemix effectivement produit par le GHT. Il exclut ainsi mécaniquement le recours structurel de type CHU (niveaux 3-4, racines hors casemix GHT) qui gonfle le taux de fuite brut sans être actionnable.

La motivation vient d'une limite documentée dans la fiche `taux_fuite_attractivite.md` : « une fuite élevée vers le CHU pour des GHM complexes est structurelle et ne signale pas nécessairement une défaillance du GHT ». Le taux de fuite brut mélange deux phénomènes de nature différente — l'orientation légitime vers le recours et la perte de patientèle sur le cœur de métier. Cet indicateur isole le second.

Formule symbolique :

```
TFE = F_évitable / S_évitable × 100

S_évitable = séjours de résidents du territoire (tous établissements) tels que :
             niveau de GHM ∈ {1, 2, J, T}
             ET racine de GHM produite par le GHT (volume ≥ V_min sur l'année)
F_évitable = sous-ensemble de S_évitable réalisé hors GHT
```

L'écart `taux de fuite brut − taux de fuite évitable` mesure la part structurelle de la fuite ; son suivi dans le temps distingue une dégradation de captation (TFE ↑) d'une évolution du recours régional (écart ↑).

## Calcul

1. **Champ** : RSA MCO année N, base nationale (portail ATIH ou SNDS), résidents du territoire GHT identifiés par le code géographique de résidence.
2. **Niveau de sévérité** : 6ᵉ caractère du GHM — `1`, `2` (niveaux de sévérité), `J` (ambulatoire), `T` (très courte durée). Exclure niveaux `3`, `4` et les GHM d'erreur (CM 90).
3. **Casemix GHT** : liste des racines (GHM sur 5 caractères) avec volume GHT ≥ `V_min` (recommandé 30/an, tous sites confondus — la maille site relève de `taux_bypass_site_competent_plus_proche.md`).
4. **Pseudocode** :

```
rsa_residents = rsa_national[code_geo ∈ territoire_ght]
rsa_residents = exclure(cmd == 90, cmd == 28, mode_entrée == transfert)

niveau = dernier_caractère(ghm)
racine = ghm[1:5]
casemix_ght = racines telles que volume_ght(racine, N) >= V_min

eligible = rsa_residents[niveau ∈ {1,2,J,T} et racine ∈ casemix_ght]
fuite    = eligible[finess ∉ finess_ght]

TFE = n(fuite) / n(eligible) × 100        # si n(eligible) = 0 : indicateur non calculé
```

5. **Déclinaisons** : par racine (top 20 des racines contributrices en volume de fuite évitable), par activité M/C/O, par secteur de destination (privé lucratif / CHU / autre public), par tranche d'âge.
6. **Indicateur dérivé** : part structurelle = `(F_brute − F_évitable) / F_brute × 100`.

## Utilité

- **Prioriser le projet médical partagé** : le top des racines à forte fuite évitable en volume donne directement la liste des filières à renforcer (consultations avancées, délais opératoires, équipes territoriales).
- **Neutraliser l'alibi du recours** : en excluant niveaux 3-4 et racines hors casemix, l'indicateur retire l'argument « ce sont des cas lourds pour le CHU » du débat — ce qui reste est par construction du périmètre GHT.
- **Comparer les sites et les périodes à périmètre constant** : le taux brut varie avec la lourdeur du casemix territorial ; le taux évitable est plus stable et plus comparable dans le temps.
- **Dialoguer avec l'ARS** : la décomposition évitable/structurel objective la part de la fuite relevant du GHT (captation) et celle relevant du schéma régional (gradation des soins).
- **Suivre l'effet des actions de reconquête** : une consultation avancée de chirurgie orthopédique doit faire baisser le TFE de la racine concernée sous 2 ans ; le taux brut, pollué par le recours, peut masquer cet effet.
- **Alimenter la contractualisation interne** : objectif chiffré de TFE par filière dans les contrats de pôle inter-établissements.

## Sources de Données

- **PMSI MCO national** (RSA, tous établissements) : GHM (racine + niveau), code géographique de résidence, FINESS, CMD, mode d'entrée `[noms de champs exacts selon le format RSA de la campagne en vigueur, à confirmer]`.
- **Référentiel ATIH** : table codes postaux → codes géographiques ; manuel des GHM de la version de groupage en vigueur (structure racine/niveau) — [atih.sante.fr](https://www.atih.sante.fr/).
- **FINESS** : liste des entités du GHT.
- **ScanSanté** : restitutions consommation/production pour cadrage et contrôle de cohérence — [cartographie consommation/production](https://www.scansante.fr/analyse-de-loffre-de-soin/cartographie-de-loffre-de-soins).

## Exemple de Valeurs

Ordres de grandeur expert, non sourcés (pas de restitution publique nationale de la fuite ajustée sur la sévérité) :

- **Taux de fuite brut** d'un GHT de taille moyenne : 15–30 % (cf. `taux_fuite_attractivite.md`).
- **Taux de fuite évitable attendu** : 10–20 points sous le taux brut sur les territoires avec CHU extérieur ; typiquement 8–18 %.
- **Part structurelle de la fuite** : 25–50 % de la fuite brute pour un GHT non-CHU ; > 60 % doit faire vérifier le paramétrage (casemix GHT sous-estimé).
- **Signal d'alerte** : TFE > 25 % sur une racine de chirurgie courante (prothèses, canal carpien, cataracte si chirurgie produite) avec volume GHT confortable — perte de terrain sur le cœur de métier.

## Limites

- **Compétence ≠ capacité** : une racine produite par le GHT peut être saturée (délais d'attente invisibles dans le PMSI) ; une partie de la fuite « évitable » reste donc contrainte à court terme.
- **Sensibilité à `V_min`** : un seuil trop bas qualifie d'« évitables » des fuites sur des activités marginales du GHT ; un seuil trop haut bascule à tort des racines en « structurel ». Documenter et figer le paramètre.
- **Le niveau de GHM est un proxy imparfait de la complexité** : des prises en charge de niveau 1-2 peuvent légitimement relever du recours (chirurgie pédiatrique, cancers rares) — prévoir une liste d'exclusion de racines à dires d'experts.
- **Effets de version de groupage** : la refonte des niveaux ou des racines (changement de version GHM) casse les séries ; recalculer l'historique dans la version courante quand c'est possible.
- **Volume minimal d'interprétation** : ne pas interpréter le TFE d'une racine sous ~50 séjours éligibles/an (instabilité statistique).
- **Périmètre MCO** : la logique niveaux 1-2/J/T n'a pas d'équivalent direct en SSR/PSY ; l'extension hors MCO demande une autre définition de l'évitabilité.

## Références

- ATIH. *Manuel des GHM — classification en vigueur* (structure racines / niveaux de sévérité) : [atih.sante.fr](https://www.atih.sante.fr/)
- ATIH — ScanSanté. *Taux de recours par région ou territoire de santé* : [scansante.fr/applications/taux-de-recours](https://www.scansante.fr/applications/taux-de-recours)
- DREES. *Les établissements de santé en 2023 — édition 2025* (cadrage de l'offre et du recours) : [drees.solidarites-sante.gouv.fr](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- Sur la sensibilité des indicateurs de contournement à leur définition : Abid M, et al. *Clinical Consequences Associated With Bypassing Local Surgical Care for Urgent and Emergent Surgery.* J Surg Res. 2025;315:504-514. [DOI](https://doi.org/10.1016/j.jss.2025.09.034) — PMID:41092603
- Fiches liées : `taux_fuite_attractivite.md` (fuite brute), `taux_bypass_site_competent_plus_proche.md` (maille site + distance), `indice_dependance_chu.md` (recours structurel).
