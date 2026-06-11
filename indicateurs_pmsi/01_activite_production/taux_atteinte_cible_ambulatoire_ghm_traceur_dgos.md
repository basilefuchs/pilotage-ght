# Taux d'Atteinte des Cibles Ambulatoires DGOS par GHM Traçeur

## Définition

La DGOS a défini, dans le cadre de son programme national de développement de la chirurgie ambulatoire, une liste de **GHMs traçeurs** — une trentaine de groupes homogènes de malades pour lesquels la réalisation en mode ambulatoire (hospitalisation de moins d'un jour, sans nuitée) est techniquement maîtrisée et pour lesquels des **cibles nationales de taux ambulatoire** ont été publiées. Ces cibles, exprimées en pourcentage, constituent le standard de référence de la politique ambulatoire DGOS.

Pour chaque GHM traçeur f, l'indicateur mesure :

```
Taux_atteinte_f = taux_ambu_obs_f / cible_DGOS_f × 100
```

où `taux_ambu_obs_f = nb_RSA_ambulatoire_f / nb_RSA_total_f` pour la période considérée, et `cible_DGOS_f` est la cible nationale publiée par la DGOS pour ce GHM.

Un score composite est calculé sur l'ensemble des GHMs traçeurs actifs dans l'établissement :

```
Score_ambulatoire_DGOS = Σ(taux_ambu_obs_f × vol_f) / Σ(cible_DGOS_f × vol_f)
```

pondéré par le volume de séjours `vol_f` pour chaque GHM traçeur.

Cet indicateur se distingue fondamentalement de deux indicateurs existants : le `taux_ambulatoire` mesure le taux global d'ambulatoire de l'établissement (toutes chirurgies confondues) sans référence aux cibles DGOS par GHM ; l'`indice_convergence_ambulatoire_cible_drees` compare le taux global établissement à une cible DREES nationale globale. Le présent indicateur opère à la **granularité GHM** avec les **cibles officielles DGOS** GHM par GHM — ce qui permet d'identifier, parmi les GHMs traçeurs, lesquels tirent l'établissement sous la cible et lesquels sont déjà conformes.

## Calcul

Sources : PMSI MCO RSA + liste officielle des GHMs traçeurs DGOS + cibles nationales DGOS.

```
Population : tous RSA MCO pour un FINESS/période annuelle ou semestrielle

Étape 1 — Chargement de la liste des GHMs traçeurs DGOS :
  Référence : Instruction DGOS/R3/2022 relative au développement de la chirurgie ambulatoire
              (ou instruction annuelle mise à jour)
  Format : table de référence avec colonnes GHM_8car, LIBELLE, CIBLE_DGOS (%)
  Exemples de GHMs traçeurs et cibles indicatives (valeurs 2022-2024) :
    - Cataracte (racine 02C05)            : cible ≥ 97%
    - Hernie inguinale adulte (07C07)     : cible ≥ 80%
    - Cholécystectomie (06C09)            : cible ≥ 70%
    - Arthroscopie genou (08C47)          : cible ≥ 85%
    - Amygdalectomie (24C01)              : cible ≥ 70%
    - Appendicectomie (06C02)             : cible ≥ 50%
    - Ligature varices (05C09)            : cible ≥ 85%
    - Chirurgie du sein (09C04)           : cible ≥ 75%
    - Canal carpien (01C07)               : cible ≥ 90%
    [→ liste complète dans l'instruction DGOS en vigueur]

  Note : les cibles sont exprimées sur la racine GHM (5 caractères) ou le GHM complet (8 car.)
  selon la version de l'instruction — vérifier le niveau de granularité retenu par la DGOS

Étape 2 — Identification des séjours ambulatoires :
  RSA_ambulatoire : DUREE = 0 (entrée et sortie le même jour) ET MODE_ENTREE normal
    OU
  RSA_ambulatoire : GHM de niveau J (4e caractère = 'J' dans le GHM à 8 caractères)

  Convention ATIH : les GHMs de niveau J (hospitalisation de moins d'une journée)
  sont les GHMs ambulatoires officiels — utiliser le niveau 'J' plutôt que DUREE = 0
  pour éviter les ambiguïtés sur les séjours à cheval sur minuit

Étape 3 — Calcul du taux observé par GHM traçeur :
  Pour chaque GHM traçeur f (identifié par sa racine 5 caractères) :
    RSA_f_total    = count(RSA | racine_GHM = f)
    RSA_f_ambu     = count(RSA | racine_GHM = f AND niveau_GHM = 'J')
    taux_ambu_obs_f = RSA_f_ambu / RSA_f_total × 100   [en %]

  Seuil minimal d'interprétation : RSA_f_total ≥ 30 sur la période
  Si RSA_f_total < 30 : GHM traçeur f → exclure du score composite (volume insuffisant)

Étape 4 — Taux d'atteinte par GHM traçeur :
  Taux_atteinte_f = taux_ambu_obs_f / CIBLE_DGOS_f × 100
  Plage : [0 ; ∞] — valeur > 100% = cible dépassée

  Catégorisation :
    ≥ 100% : conforme ou au-delà de la cible DGOS
    80–99%  : proche de la cible — effort modéré requis
    60–79%  : sous la cible — plan d'action structuré requis
    < 60%   : très en retard — audit organisationnel urgent

Étape 5 — Score composite pondéré par volume :
  GHMs_actifs = {f : RSA_f_total ≥ 30 ET f ∈ liste_traçeurs_DGOS}
  Score_composite = Σ(taux_ambu_obs_f × RSA_f_total) / Σ(CIBLE_DGOS_f × RSA_f_total)
                    pour f ∈ GHMs_actifs
  Plage : [0 ; ∞] — Score > 1,00 = l'établissement dépasse en moyenne les cibles DGOS

Étape 6 — Écart en séjours (gap d'ambulatoire) :
  Pour chaque GHM f sous la cible :
  Gap_séjours_f = (CIBLE_DGOS_f − taux_ambu_obs_f) / 100 × RSA_f_total
  → nombre de séjours à basculer en ambulatoire pour atteindre la cible
  Gap_total = Σ Gap_séjours_f   [total séjours à ambulatoriser]
```

Indicateurs dérivés :

```
Classement des GHMs traçeurs par effort requis :
  = trier les GHMs traçeurs par (CIBLE − taux_obs) × RSA_total décroissant
  → prioriser les GHMs où le gain absolu en séjours ambulatoires est le plus élevé

Trajectoire d'atteinte des cibles (sur 4 trimestres) :
  = évolution du Taux_atteinte_f par trimestre
  → mesurer si l'établissement progresse, stagne ou régresse sur chaque GHM traçeur

Matrice priorisation effort/impact :
  Axe X = Gap_séjours_f (impact en nb de séjours)
  Axe Y = (CIBLE − taux_obs) (effort organisationnel)
  → quadrant prioritaire : fort impact ET effort modéré (< 20 points d'écart)
```

## Utilité

- **Dialogue de gestion DGOS/ARS sur la politique ambulatoire** : le Score_composite et le tableau GHM par GHM sont le format attendu par l'ARS dans les CPOM et les bilans de la politique ambulatoire — présenter les taux d'atteinte par GHM traçeur est plus opérationnel que le taux global et s'aligne sur le référentiel officiel DGOS
- **Priorisation des GHMs à ambulatoriser dans le projet médical** : le classement des GHMs par Gap_séjours × effort identifie les «fruits à portée de main» — les GHMs où le passage en ambulatoire est à la fois faisable organisationnellement (écart < 20 points) et quantitativement significatif (> 50 séjours/an)
- **Benchmark intra-GHT par spécialité** : comparer les Taux_atteinte_f entre établissements du GHT sur les mêmes GHMs traçeurs révèle les sites les plus avancés — le site qui a déjà atteint la cible DGOS sur la hernie inguinale peut partager son organisation avec les sites en retard
- **Argument pour les demandes de ressources** : un Gap_total élevé (ex : 200 séjours à basculer sur les GHMs traçeurs) est l'argument quantitatif pour solliciter auprès de la direction une ouverture de créneaux de bloc dédiés à l'ambulatoire ou une augmentation des places en UPAS (unité de chirurgie ambulatoire)
- **Pilotage des conventions GHT en chirurgie ambulatoire** : si un établissement du GHT est en retard sur la cataracte mais avancé sur l'arthroscopie, les conventions inter-établissements peuvent organiser des transferts de patients ciblés pour optimiser l'atteinte des cibles DGOS au niveau consolidé du GHT
- **Suivi de l'impact des investissements en UPAS** : mesurer le Taux_atteinte avant et après l'ouverture ou l'extension d'une unité de chirurgie ambulatoire pour objectiver le retour sur investissement organisationnel

## Sources de Données

- **PMSI MCO RSA** : variable `GHM` (8 caractères — racine = 5 premiers, niveau = 4e caractère : 'J' pour ambulatoire), `DUREE`, `NOFINESS`, `DATE_SORTIE` — extraction annuelle ou trimestrielle
- **Instruction DGOS relative au développement de la chirurgie ambulatoire** : liste des GHMs traçeurs et cibles nationales, publiée annuellement par la DGOS — téléchargeable sur le site du Ministère de la Santé ou transmise par l'ARS dans le cadre des CPOM
- **Référentiel ATIH des GHMs** : correspondance GHM racine → libellé, niveau (J/T/U/E/A/Z), CMD — nécessaire pour identifier les niveaux ambulatoires et les libellés des GHMs traçeurs

## Exemple de Valeurs

- **CHU polyvalent — Score composite DGOS** : 0,92 (92% des cibles atteintes en moyenne pondérée) — cataracte conforme (99%), hernie à 72% (cible 80%), cholécystectomie à 58% (cible 70%)
- **CH chirurgical orienté ambulatoire** : Score composite = 1,05 — cibles DGOS dépassées sur 18 des 24 GHMs traçeurs actifs
- **CH généraliste** : Score composite = 0,78 — 8 GHMs traçeurs sous 60% de leur cible, dont appendicectomie (35% vs cible 50%) et cholécystectomie (41% vs cible 70%)
- **Gap_total d'alerte** : > 150 séjours à basculer sur l'ensemble des GHMs traçeurs → plan d'action ambulatoire formalisé recommandé avec échéancier CPOM
- **GHM traçeur prioritaire typique** : cholécystectomie — fort volume (>200 séjours/an dans un CH 500 lits) + écart souvent > 20 points → premier GHM à cibler dans un plan ambulatoire

## Limites

- **Cibles DGOS non ajustées au casemix local** : les cibles nationales sont calculées sur l'ensemble des établissements français ; un établissement avec un recrutement plus lourd sur un GHM (sévérités 2-3 dominantes) sera structurellement sous la cible sans défaillance organisationnelle — croiser avec le taux de niveau J vs niveaux T/U dans le GHM
- **Liste des GHMs traçeurs et cibles révisées** : la DGOS met à jour périodiquement la liste et les cibles ; comparer les taux d'atteinte entre deux années nécessite de vérifier si le référentiel a changé
- **Niveau de groupage** : certains GHMs traçeurs ont des niveaux de sévérité multiples (J, T, U) — l'indicateur doit clairement définir si la cible s'applique sur la racine (tous niveaux) ou sur le GHM complet (niveau J uniquement au numérateur, tous niveaux au dénominateur)
- **Séjours à cheval sur minuit** : quelques séjours comptabilisés avec DUREE = 1 sont de facto ambulatoires (patient admis et sorti le même jour en calendrier mais avec 1 nuit administrative) — la convention niveau 'J' du GHM est plus robuste que DUREE = 0 pour ce cas
- **Volume minimal par GHM** : les GHMs traçeurs à faible volume local (< 30 séjours/an) produisent des taux instables — les exclure du score composite est impératif pour éviter les distorsions

## Références

- [DGOS — Instruction relative au développement de la chirurgie et médecine ambulatoire (dernière version en vigueur) : liste des GHMs traçeurs et cibles nationales](https://sante.gouv.fr/ministere/organisation/organisation-des-directions-et-services/article/dgos-direction-generale-de-l-offre-de-soins)
- [ATIH — Indicateurs de suivi du développement de la chirurgie ambulatoire, tableaux de bord ScanSanté](https://www.atih.sante.fr/)
- [HAS — Recommandations pour l'organisation et le développement de la chirurgie ambulatoire](https://www.has-sante.fr/)
- [Castoro C. et al. — Day surgery: making it happen, WHO Europe 2007 : méthodologie internationale du suivi des cibles ambulatoires par GHM](https://www.euro.who.int/)
- [ANAP — Développement de la chirurgie ambulatoire : guide pratique et indicateurs de pilotage](https://www.anap.fr/)
