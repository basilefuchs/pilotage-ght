# Entropie de Diffusion de l'Innovation dans le Parcours GHT

## Définition

En botanique, la **floraison** d'une espèce dans un jardin peut être centralisée (une seule serre) ou distribuée (tout le parc) — la distribution géographique de la floraison caractérise la maturité organisationnelle du jardin. Transposé au GHT, **l'entropie de diffusion de l'innovation dans le parcours** (EDIP) mesure dans quelle mesure les actes CCAM innovants sont distribués de manière équilibrée entre les établissements du groupement, ou au contraire concentrés sur un seul site. Un EDIP faible signale une innovation captive du site pivot ; un EDIP élevé indique une diffusion effective dans le réseau de soins.

L'indicateur combine deux composantes :

**1. Entropie géographique de Shannon** par acte innovant i :

Hᵢ = −Σⱼ p_{ij} × log₂(p_{ij})

où p_{ij} = proportion de l'acte i réalisée sur le site FINESS j dans le GHT, et j parcourt l'ensemble des établissements MCO du GHT. Hᵢ est maximale (log₂(nb_établissements)) quand l'acte est équitablement réparti entre tous les sites, et nulle quand il est exclusivement réalisé sur un seul site.

**2. Coefficient de Gini inter-sites** sur le volume global d'actes innovants :

G = (Σᵢ Σⱼ |Vᵢⱼ − Vᵢₖ|) / (2 × n² × V̄)

où Vᵢⱼ est le volume de l'acte i au site j, et V̄ le volume moyen par site.

**EDIP composite :**

EDIP = H̄ × (1 − G)

où H̄ est la moyenne des Hᵢ normalisés (divisés par log₂(nb_établissements) pour une valeur entre 0 et 1). EDIP ∈ [0, 1] : EDIP → 0 indique une innovation concentrée sur un site (G élevé et/ou H faible) ; EDIP → 1 indique une distribution homogène.

Cet indicateur est distinct du `taux_actes_innovants` existant, qui mesure la fréquence relative des actes innovants par établissement sans capturer la dynamique de diffusion inter-sites au sein du GHT. L'EDIP mesure une propriété du **réseau GHT** et non de chaque établissement isolément — il est nul si un seul établissement concentre toute l'innovation même s'il a un taux individuel élevé.

## Calcul

**Source :** PMSI MCO RSA — actes CCAM associés aux séjours, FINESS géographique, complété par le référentiel CCAM ATIH (date d'inscription) et la liste HAS des actes en forfait innovation.

```
Définition des actes innovants :
  Méthode A — CCAM datée : actes CCAM dont la date d'inscription en liste remboursable
    est dans les 36 mois précédant la période d'analyse
    Source : référentiel CCAM ATIH (fichier CCAM_LIB avec DATE_REMB)
    → Extraire les codes CCAM avec DATE_REMB ∈ [date_analyse − 36 mois ; date_analyse]
  Méthode B — Forfait Innovation HAS : actes figurant dans la liste des actes en
    évaluation/forfait innovation (article L.165-1-1 CSS)
    Source : HAS — liste mise à jour semestriellement
  Recommandation : utiliser l'union des deux sources, en documentant les effectifs issus
    de chaque source

Population d'analyse :
  Tous les séjours MCO des établissements FINESS appartenant au GHT
  sur la période annuelle (ou trimestrielle si volumes suffisants)
  Actes CCAM extraits de la table des actes des RSA (1 ligne par acte par séjour)

Étape 1 — Construction de la matrice actes × sites :
  Pour chaque acte innovant i :
    Pour chaque FINESS j du GHT :
      V_{ij} = volume (nb occurrences) de l'acte i au site j
  → Matrice M de dimensions (nb_actes_innovants × nb_FINESS_GHT)
  → Filtrer : exclure les actes avec volume total GHT < 10 sur la période
    (volume insuffisant pour calculer une distribution fiable)

Étape 2 — Entropie par acte :
  Pour chaque acte i :
    n_j = nb de sites avec V_{ij} > 0 (sites actifs pour cet acte)
    Si n_j < 2 : acte monopolistique, Hᵢ = 0 (et noté comme tel)
    Sinon :
      p_{ij} = V_{ij} / Σⱼ V_{ij}
      Hᵢ     = −Σⱼ p_{ij} × log₂(p_{ij})
      Hᵢ_norm = Hᵢ / log₂(nb_FINESS_GHT)   ∈ [0, 1]

Étape 3 — Gini inter-sites sur le volume global innovant :
  Vⱼ = Σᵢ V_{ij}  (volume total d'actes innovants au site j)
  Trier les Vⱼ par ordre croissant
  G = 1 − (2 / n) × Σⱼ (n − j + 0.5) × Vⱼ / Σⱼ Vⱼ   (formule de Brown)
  Plage : G = 0 (parfaite égalité) → G = 1 (concentration totale)

Étape 4 — EDIP composite :
  H̄   = moyenne pondérée des Hᵢ_norm, pondérée par le volume total de l'acte i
         (les actes fréquents comptent davantage que les actes rares)
  EDIP = H̄ × (1 − G)
  Plage : [0 ; 1]

Étape 5 — Indicateurs dérivés :
  EDIP_par_CMD : calculer séparément par CMD (CCAM innovante cardio, ortho, onco...)
    → identifier les spécialités où l'innovation diffuse vs celles où elle reste captive
  Part des actes monopolistiques : n_actes avec Hᵢ_norm = 0 / n_actes_innovants_total
    → % d'actes réservés à un seul site (structurellement ou par défaut d'organisation)
  Dérive annuelle : ΔEDIP = EDIP(année N) − EDIP(année N-1)
    → ΔEDIP > +0.05 : diffusion en cours, dynamique favorable
    → ΔEDIP < −0.05 : recentralisation, à investiguer
  Top 5 actes les plus concentrés (Hᵢ_norm les plus bas) :
    → listing des actes sur lesquels l'organisation du GHT pourrait engager une démarche
      de délégation ou de formation inter-sites
```

**Cas limites :**
- GHT à 2 établissements : log₂(2) = 1, H_max = 1 — l'entropie est interprétable mais peu discriminante ; l'EDIP est plus utile pour les GHT avec ≥ 4 établissements MCO
- Actes structurellement mono-sites (greffes, neurochirurgie lourde) : ne pas les interpréter comme un échec de diffusion ; filtrer ces actes par une liste d'exclusion médicale validée (référentiel d'autorisations ARS)
- Changement de périmètre du GHT (fusion, intégration d'un nouvel établissement) : recalculer l'EDIP sur le périmètre constant pour les comparaisons longitudinales

## Utilité

- **Piloter la stratégie d'innovation du GHT** : l'EDIP par CMD fournit au DIM et à la direction médicale une cartographie objective des innovations captives vs diffusées — base de discussion pour les projets médicaux partagés et les conventions de délégation d'activité entre sites
- **Objectiver les inégalités d'accès à l'innovation selon la localisation** : un EDIP faible signifie que les patients du bassin de vie d'un établissement périphérique n'ont pas accès aux actes innovants sans déplacement au site pivot — donnée opposable pour les négociations de CPOM avec l'ARS et les discussions de permanence médicale
- **Suivre la maturité organisationnelle du GHT dans le temps** : un EDIP croissant sur 3 ans traduit l'effet concret des projets médicaux partagés (montée en compétence des équipes périphériques, télémédecine, équipes mobiles) — indicateur de résultat organisationnel du GHT
- **Identifier les formations inter-sites prioritaires** : le top 5 des actes monopolistiques non justifiés par des contraintes réglementaires constitue une liste directement opérationnelle pour le plan de formation continu intra-GHT ou pour les programmes de compagnonnage
- **Nourrir la réflexion sur les autorisations d'activité** : un acte innovant avec EDIP faible et volume croissant sur le site pivot peut justifier une demande d'autorisation partagée (déconcentration sur un ou deux sites supplémentaires), soutenue par les données de volume et de qualité
- **Comparer les GHT entre eux sur leur capacité de diffusion** : dans une démarche régionale, l'ARS peut utiliser l'EDIP comme indicateur de maturité de l'intégration GHT et identifier les groupements dont la gouvernance médicale facilite la diffusion de l'innovation vs ceux qui restent en silo

## Sources de Données

- **PMSI MCO — Table des actes CCAM** : code acte CCAM, FINESS géographique, identifiant séjour RSA — extraction annuelle ATIH (ou ad hoc via le portail ATIH e-PMSI)
- **Référentiel CCAM ATIH** : code CCAM, libellé, date d'inscription en nomenclature (`DATE_REMB`), date de fin le cas échéant — mise à jour semestrielle
- **HAS — Liste des actes en forfait innovation** : codes CCAM concernés, dates de début et fin d'évaluation — mise à jour semestrielle sur le site HAS
- **Référentiel des FINESS GHT** : liste des FINESS géographiques appartenant au GHT, avec leur statut (établissement pivot, associé) — à construire et maintenir en interne à partir du site FINESS.esante.gouv.fr
- **Référentiel des autorisations ARS** : liste des actes soumis à autorisation d'activité exclusive (à construire pour filtrer les actes structurellement monopolistiques légitimes)

## Exemple de Valeurs

| Profil de GHT | EDIP attendu | Part actes monopolistiques | Interprétation |
|---|---|---|---|
| GHT immature (1 CHU + 3 CH, projets médicaux naissants) | 0.10 – 0.20 | 60 – 80 % | Innovation captive du CHU |
| GHT en structuration (filières cardio/onco engagées) | 0.25 – 0.40 | 40 – 60 % | Début de diffusion sur les filières prioritaires |
| GHT mature (délégations d'activité actives, télémédecine) | 0.45 – 0.65 | 20 – 40 % | Diffusion étendue, quelques actes lourds encore centralisés |
| GHT très intégré (recrutement territorial équilibré) | 0.65 – 0.80 | 10 – 20 % | Diffusion avancée, actes monopolistiques = contraintes réglementaires |
| EDIP_CMD cardiologie (stents innovants) | 0.20 – 0.40 | 40 – 60 % | Actes techniques concentrés en cardiologie interventionnelle |
| EDIP_CMD orthopédie (prothèses connectées) | 0.35 – 0.55 | 25 – 45 % | Diffusion plus rapide sur les actes de volume |

**Seuils d'alerte :**
- EDIP < 0.15 avec > 75 % d'actes monopolistiques → absence de politique de diffusion de l'innovation intra-GHT (à inscrire dans les axes de travail du projet médical partagé)
- ΔEDIP < −0.05 deux années consécutives → recentralisation en cours, à investiguer (départs de praticiens en périphérie, fermetures d'activité)

## Limites

- **Définition des actes innovants dépendante du référentiel** : la date d'inscription CCAM ne reflète pas toujours la réelle nouveauté clinique d'un acte (certaines innovations diffusent très rapidement après inscription, d'autres restent expérimentales) ; l'interprétation de l'EDIP doit s'appuyer sur l'expertise médicale locale pour valider la liste d'actes retenue
- **Sensibilité à la taille du GHT** : pour les GHT avec ≤ 3 établissements MCO, l'entropie de Shannon est bornée par log₂(3) ≈ 1.58 bits, réduisant la sensibilité de l'indicateur ; l'EDIP est préférablement interprété sur les GHT avec ≥ 4 établissements MCO actifs
- **Actes de spécialités lourdes structurellement monopolistiques** : les greffes, la neurochirurgie complexe, la cardiologie interventionnelle de recours ne doivent pas être traités comme un échec de diffusion ; leur exclusion de la liste d'actes innovants via un filtre par référentiel d'autorisations ARS est nécessaire pour éviter de pénaliser les GHT avec CHU pivot
- **Volume minimal par acte** : l'entropie d'un acte réalisé à 2 occurrences sur 3 sites est statistiquement instable — le filtre de 10 occurrences minimum par acte est un compromis entre stabilité statistique et couverture ; il peut exclure des innovations récentes à faible volume d'emblée
- **Non-couverture des actes hors PMSI MCO** : les actes innovants réalisés en structure de soins de suite (SSR) ou en consultation externe non codée dans le PMSI sont invisibles ; l'EDIP sous-estime la diffusion réelle pour les spécialités à fort recours ambulatoire

## Références

- [Shannon C.E. — A Mathematical Theory of Communication, Bell System Technical Journal 1948 : fondements de l'entropie de Shannon comme mesure de diversité/distribution](https://doi.org/10.1002/j.1538-7305.1948.tb01338.x)
- [Gini C. — Variabilità e mutabilità, Tipografia di Paolo Cuppini 1912 : coefficient de Gini comme mesure de concentration/inégalité de distribution]
- [Rogers E.M. — Diffusion of Innovations, 5th ed., Free Press 2003 : théorie de la diffusion de l'innovation — cadre conceptuel pour interpréter la dynamique de l'EDIP dans le temps]
- [Atkinson S. et al. — Hospital networks, innovation and health outcomes, Journal of Health Economics 2019 : lien entre intégration hospitalière en réseau et diffusion de l'innovation thérapeutique](https://doi.org/10.1016/j.jhealeco.2019.01.005)
- [HAS — Forfait Innovation : liste et conditions de prise en charge des actes en évaluation (article L.165-1-1 CSS)](https://www.has-sante.fr/jcms/c_2054764/fr/actes-et-prestations)
- [ATIH — Référentiel CCAM : classification commune des actes médicaux, version mise à jour semestriellement](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
- [DREES — Les groupements hospitaliers de territoire : état des lieux au 1er janvier 2023 — structure et dynamique des GHT français](https://www.drees.solidarites-sante.gouv.fr/)
