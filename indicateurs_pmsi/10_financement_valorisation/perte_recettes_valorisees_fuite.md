# Perte de Recettes Valorisées de la Fuite

## Définition

La perte de recettes valorisées de la fuite traduit le taux de fuite en euros : elle valorise, aux tarifs GHS nationaux en vigueur, l'ensemble des séjours de résidents du territoire du GHT réalisés hors GHT. C'est le chiffre d'affaires T2A théorique que représenterait la patientèle perdue si elle était soignée dans le GHT.

Le concept est l'équivalent français du « patient leakage » financier piloté par les systèmes de santé intégrés américains (ACO, IDN), où la fuite hors réseau est un poste de pilotage économique de premier plan et où l'identification de ses canaux (urgences, adressage) guide les interventions (Carlson et al. 2021). En France, ni le PMSI standard ni ScanSanté ne restituent la fuite en valeur monétaire : les restitutions flux de patients comptent des séjours et des journées. Or 1 000 séjours de fuite en médecine gériatrique et 1 000 séjours de fuite en chirurgie cardiaque n'ont pas le même poids économique — la valorisation est l'étape qui transforme l'analyse territoriale en arbitrage d'investissement.

Formule symbolique :

```
PRF = Σ  T(ghs_i)            pour i ∈ séjours en fuite de l'année
      i

PRF_évitable = Σ T(ghs_i)    pour i ∈ fuite évitable (niveaux 1-2/J/T, racine ∈ casemix GHT)
```

où `T(ghs)` est le tarif GHS public national de la campagne tarifaire, appliqué de façon **théorique et homogène** (hors suppléments journaliers, coefficients géographiques et honoraires) pour garantir la comparabilité.

## Calcul

1. **Champ** : RSA MCO année N, base nationale, résidents du territoire GHT, séjours réalisés hors GHT. Exclure CMD 90 ; traiter les séances (CMD 28) séparément (forfaits par séance).
2. **Groupage et tarif** : associer à chaque séjour son GHS et le tarif national « secteur ex-DG » de la campagne en vigueur (fichier officiel des tarifs MCO publié par l'ATIH à chaque campagne). Convention : valoriser tous les séjours au tarif ex-DG, y compris ceux réalisés dans le privé lucratif — on mesure ce que ces séjours *auraient rapporté au GHT*, pas ce qu'ils ont coûté à l'Assurance maladie.
3. **Pseudocode** :

```
fuite = rsa_national[code_geo ∈ territoire_ght et finess ∉ finess_ght]
fuite = exclure(cmd == 90) ; séances traitées à part

PRF = somme( tarif_ghs_exdg(ghs(s), campagne_N) pour s ∈ fuite )

# décompositions
PRF_par_racine   = somme par racine de GHM
PRF_par_secteur  = somme par catégorie de destination (privé lucratif, CHU, autre public)
PRF_evitable     = somme sur fuite ∩ (niveau ∈ {1,2,J,T}) ∩ (racine ∈ casemix_ght)
```

4. **Conventions** : pas de suppléments (REA, SI, EXH…) ni de coefficients géographiques — valorisation « socle » documentée ; GHS sans correspondance tarifaire (nouveautés de campagne) valorisés au tarif de la racine la plus proche et marqués.
5. **Indicateurs dérivés** :
   - `PRF / recettes GHS annuelles du GHT × 100` : poids relatif de la fuite (en % du chiffre d'affaires) ;
   - `PRF_évitable` : sous-ensemble actionnable, à croiser avec `taux_fuite_evitable_severite_ajustee.md` ;
   - panier moyen de la fuite `PRF / n(fuite)` vs panier moyen du GHT : la fuite est-elle plus « riche » que l'activité retenue ?

## Utilité

- **Dimensionner les investissements de reconquête** : un projet de filière (équipe chirurgicale, équipement) se compare directement au `PRF_évitable` de la racine visée — base d'un business plan interne.
- **Hiérarchiser les filières en euros et non en séjours** : le top 10 des racines par PRF diffère souvent du top 10 en volume (poids des GHS chirurgicaux et interventionnels) ; c'est le bon classement pour le COPIL finances.
- **Objectiver le débat avec les fédérations et l'ARS** : le poids économique de la fuite vers le privé lucratif du territoire, en euros, cadre les discussions sur les autorisations d'activité.
- **Suivre l'érosion du panier moyen** : si le panier moyen de la fuite croît plus vite que celui de l'activité retenue, le GHT perd préférentiellement ses séjours les mieux valorisés (écrémage concurrentiel).
- **Compléter l'EPRD d'une vision territoriale** : la trajectoire de recettes du GHT s'interprète différemment selon que le territoire croît avec une fuite stable ou stagne avec une fuite croissante.
- **Mesurer le retour des actions** : après ouverture d'une consultation avancée, le PRF de la racine doit baisser — l'écart mesuré finance (ou non) la reconduction de l'action.

## Sources de Données

- **PMSI MCO national** (RSA) : GHM/GHS, code géographique de résidence, FINESS, CMD `[noms de champs exacts selon le format RSA de la campagne en vigueur, à confirmer]`.
- **Fichier officiel des tarifs MCO** de la campagne tarifaire en vigueur (tarifs GHS ex-DG), publié par l'ATIH — [atih.sante.fr](https://www.atih.sante.fr/) (campagne tarifaire et fichiers tarifs).
- **Référentiel ATIH** : table codes postaux → codes géographiques ; table GHM → GHS de la version de groupage.
- **FINESS** : périmètre GHT, catégorie juridique des établissements de destination.
- **Comptes du GHT** (recettes GHS annuelles) pour le ratio de poids relatif.

## Exemple de Valeurs

Ordres de grandeur expert, non sourcés (aucune restitution publique de la fuite valorisée) :

- **GHT de taille moyenne** (200 000 habitants, taux de fuite 20–25 %) : PRF brut de l'ordre de 40–80 M€/an ; `PRF_évitable` typiquement 30–50 % du PRF brut, soit 15–35 M€/an.
- **Poids relatif** : PRF brut représentant 15–35 % des recettes GHS du GHT ; un ratio > 40 % signale un territoire structurellement sous-capté.
- **Panier moyen** : panier moyen de la fuite souvent supérieur de 10–30 % au panier moyen du GHT (surreprésentation de la chirurgie programmée bien valorisée dans la fuite vers le privé).
- **Seuil d'action** : une racine avec `PRF_évitable > 1 M€/an` justifie une étude de filière dédiée.

## Limites

- **Valorisation théorique, pas un manque à gagner net** : récupérer la fuite suppose des capacités (lits, blocs, RH) et des coûts marginaux ; le PRF est un plafond brut, pas un résultat d'exploitation. Ne jamais le présenter comme des « pertes » comptables.
- **Hors suppléments et coefficients** : la convention socle sous-estime la valorisation réelle des séjours lourds (suppléments de réanimation) ; ce biais est volontaire (comparabilité) et doit être documenté.
- **Effets de campagne tarifaire** : les tarifs changent chaque année ; les évolutions de PRF mélangent effet volume et effet tarif — calculer aussi le PRF à tarifs constants (année de référence) pour les séries temporelles.
- **Tarifs ex-DG appliqués au privé** : les séjours fuis vers le privé lucratif sont facturés sur une autre grille (GHS ex-OQN + honoraires) ; le PRF ne reflète pas la dépense réelle d'Assurance maladie, uniquement le potentiel de recettes GHT.
- **Réformes du financement** : la part T2A diminue (financements populationnels, forfaits) ; le PRF reste pertinent comme métrique d'activité valorisée mais son interprétation budgétaire s'affaiblit à mesure que les recettes se déconnectent de l'activité.
- **Fuite ≠ demande captable** : une partie des séjours fuis suit des logiques (praticien historique, proximité réelle, choix éclairé) qu'aucune offre GHT ne ramènera ; croiser systématiquement avec `taux_bypass_site_competent_plus_proche.md`.

## Références

- Carlson LC, Tasi MC, Wasfy JH, et al. *An Analysis of Ambulance Transport and Out-of-Network Emergency Department Utilization in an Accountable Care Organization.* Popul Health Manag. 2021;24(5):576-580. [DOI](https://doi.org/10.1089/pop.2020.0315) — PMID:33656386 (la fuite hors réseau comme objet de pilotage économique et ses canaux)
- Mullens CL, et al. *Half Of Rural Patients Bypassed Their Local Hospital But Received Lower-Quality Surgical Care Elsewhere, 2016-20.* Health Aff (Millwood). 2026;45(3):313-321. [DOI](https://doi.org/10.1377/hlthaff.2025.00640) — PMID:41770994 (lien explicite entre rétention des patients et viabilité financière des hôpitaux)
- ATIH. *Campagne tarifaire et fichiers des tarifs MCO en vigueur* : [atih.sante.fr](https://www.atih.sante.fr/)
- ATIH — ScanSanté. *Restitutions flux de patients et taux de recours* : [scansante.fr](https://www.scansante.fr/)
- Fiches liées : `taux_fuite_attractivite.md`, `taux_fuite_evitable_severite_ajustee.md` (périmètre évitable), `../09_territoire_attractivite/parts_marche_territoire.md`.
