# Indice de Convergence Ambulatoire vers la Cible DREES/ANAP (ICA)

## Définition

L'ICA mesure la progression d'un établissement vers les **taux de chirurgie ambulatoire cibles** définis par GHM marqueur dans le référentiel national DREES/ANAP (Programme National de développement de la Chirurgie Ambulatoire — PNCA). À la différence du taux d'ambulatoire global (`taux_ambulatoire.md`), qui rapporte les séjours ambulatoires à l'ensemble des séjours MCO sans distinction de nature ou de cible, l'ICA :

1. Restreint l'analyse aux **GHM marqueurs** — les ~57 racines GHM pour lesquelles l'ANAP a fixé une cible explicite de taux ambulatoire (de 60% à 95% selon la complexité de l'acte)
2. Compare le taux observé au taux **cible propre à chaque GHM**, pas à une norme unique
3. Agrège ces rapports en un indice composite **pondéré par le volume** de chaque GHM marqueur

**Convergence par GHM marqueur :**

**C_(g) = τ_obs_(g) / τ_cible_(g)**

où :
- **τ_obs_(g)** = RSA_ambu_(g) / RSA_total_(g) — taux ambulatoire observé sur le GHM marqueur g
- **τ_cible_(g)** = taux cible ANAP pour la racine GHM g (référentiel annuel CPOM)
- RSA_ambu_(g) = RSA avec GHM finissant par « J » (niveau de sévérité J = ambulatoire) sur la racine g
- C_(g) ∈ [0 ; +∞[ ; C_(g) ≥ 1 signifie que l'établissement atteint ou dépasse la cible sur ce GHM

**Indice composite pondéré (ICA) :**

**ICA = Σ_(g ∈ G_marqueurs) [ C_(g) × w_(g) ]**

où **w_(g) = RSA_total_(g) / Σ_(g') RSA_total_(g')** (pondération volumique — les GHM à fort volume pèsent davantage)

**Interprétation :**
- ICA = 1,00 → établissement exactement à la cible nationale en moyenne pondérée
- ICA < 1,00 → sous-convergence ; l'écart ICA = 0,85 signifie que l'établissement est à 85% de sa cible pondérée
- ICA > 1,00 → sur-convergence ; dépasse en moyenne les cibles (possible sur les GHM simples, compensant un retard sur des GHM complexes)

L'ICA est structurellement distinct du taux d'ambulatoire brut : deux établissements à 62% de taux ambulatoire global peuvent avoir des ICA très différents (0,70 vs 1,05) selon leur mix de GHM marqueurs et les cibles associées. C'est l'écart normalisé à la **cible spécifique** qui importe pour le pilotage et les CPOM, pas le taux absolu.

## Calcul

Sources : PMSI MCO RSA (ATIH) + Référentiel GHM marqueurs et taux cibles ANAP (mis à jour annuellement).

```
Étape 1 — Chargement du référentiel GHM marqueurs ANAP :
  G_marqueurs = liste des racines GHM éligibles à la chirurgie ambulatoire
                selon le référentiel ANAP/CPOM de l'exercice analysé
  Exemple (non exhaustif, version 2024) :
    05C041 (Revascularisation coronarienne percutanée) → cible 70%
    07C051 (Cholécystectomie)                          → cible 85%
    08C191 (Prothèse totale de genou)                  → cible 15% (complexe)
    02C111 (Chirurgie du cristallin)                   → cible 98%
    06C081 (Hernies inguinales)                        → cible 92%
    ...
  Source : fichier Excel ANAP « GHM marqueurs et taux cibles »
           ou annexe CPOM ARS pour l'exercice concerné

  Variables de la table référentiel :
    GHM_racine    (5 caractères)
    Libellé_GHM
    τ_cible       (valeur décimale, ex. 0.85 pour 85%)
    Année_cible   (millésime du référentiel)

Étape 2 — Extraction des RSA par racine GHM marqueur :
  Pour chaque g ∈ G_marqueurs :
    RSA_total_{(g)}  = COUNT(RSA)
      WHERE `finessgeo` = etab
        AND GHM_racine = g
        AND SUBSTR(GHM, 6, 1) NOT IN ('T','Z')  -- exclure décès et séjours indéterminés

    RSA_ambu_{(g)}   = COUNT(RSA)
      WHERE `finessgeo` = etab
        AND GHM_racine = g
        AND SUBSTR(GHM, 6, 1) = 'J'             -- suffixe J = niveau ambulatoire

  Variables PMSI utilisées :
    `finessgeo` : identifiant établissement géographique
    GHM        : code GHM complet 8 caractères (ex. 07C051J)
                 → GHM_racine = SUBSTR(GHM, 1, 5) = '07C05'
                 → Suffixe     = SUBSTR(GHM, 6, 1) ∈ {1,2,3,4,J,T,Z,E,A,B,C,D}

Étape 3 — Calcul des taux observés et des convergences par GHM :
  τ_obs_{(g)}  = RSA_ambu_{(g)} / RSA_total_{(g)}
  C_{(g)}      = τ_obs_{(g)} / τ_cible_{(g)}
  Gap_{(g)}    = τ_cible_{(g)} − τ_obs_{(g)}        -- négatif si au-dessus de la cible

  Conventions cas limites :
    Si RSA_total_{(g)} = 0        → C_{(g)} = NA (GHM absent, exclure de l'agrégation)
    Si RSA_total_{(g)} < 30       → C_{(g)} calculé mais marqué « instable » (IC large)
    Si τ_cible_{(g)} = 0          → cas impossible par construction (cible toujours > 0)

Étape 4 — Calcul de l'ICA composite pondéré :
  G_actifs = { g ∈ G_marqueurs | RSA_total_{(g)} ≥ 1 }  -- GHM effectivement pratiqués
  Σ_poids  = Σ_{g ∈ G_actifs} RSA_total_{(g)}

  w_{(g)}  = RSA_total_{(g)} / Σ_poids
  ICA      = Σ_{g ∈ G_actifs} [ C_{(g)} × w_{(g)} ]

Étape 5 — Quantification du potentiel de conversion (séjours à basculer) :
  Séjours_à_convertir_{(g)} = MAX(0, Gap_{(g)}) × RSA_total_{(g)}
  Séjours_à_convertir_total  = Σ_{g} Séjours_à_convertir_{(g)}
  → Nombre absolu de séjours conventionnels qui passeraient en ambulatoire
    si l'établissement atteignait la cible sur chaque GHM marqueur déficitaire
```

Indicateurs dérivés :

```
ICA non pondéré (simple mean) :
  ICA_NP = MOYENNE_{g ∈ G_actifs}( C_{(g)} )
  → Utile pour comparer l'ICA d'établissements à volumes très différents
    sans que les GHM à fort volume écrasent les GHM rares

Taux de GHM marqueurs à cible atteinte :
  Taux_GHM_cible = COUNT(g | C_{(g)} ≥ 1) / COUNT(G_actifs) × 100
  → Proportion de GHM où l'établissement est déjà conforme

Indice de convergence par CMD chirurgicale :
  ICA_CMD_{(c)} = Σ_{g ∈ G_actifs ∩ CMD_c} [ C_{(g)} × w_{(g,c)} ]
  → Permet d'identifier la CMD chirurgicale la plus en retard

Évolution annuelle de l'ICA :
  ΔICA = ICA_{(N)} − ICA_{(N-1)}
  ΔICA > +0,05 par an = progression significative vers les cibles ANAP
```

## Utilité

- **Objectiver la position CPOM sur l'ambulatoire par GHM** : le CPOM fixe des objectifs de taux ambulatoire sur les GHM marqueurs ; l'ICA donne, en un indicateur composite unique, la position de l'établissement par rapport à ses engagements contractuels — plus précis que le taux global car normalisé par les cibles spécifiques à chaque GHM.
- **Prioriser les GHM à levier pour le plan d'action ambulatoire** : le classement des GHM marqueurs par `Séjours_à_convertir_(g)` décroissant identifie les 5 à 10 GHM où la conversion de séjours conventionnels en ambulatoire produirait le plus grand impact sur l'ICA et sur la libération de lits — base directe d'un plan d'action chirurgical trimestriel.
- **Mesurer l'impact réel d'une réorganisation de circuit ambulatoire** : si une unité de chirurgie ambulatoire (UCA) est restructurée en N, l'évolution de l'ICA et des `C_(g)` sur les GHM de la spécialité concernée en N+1/N+2 constitue le critère de résultat objectif — distinct des seuls taux bruts qui dépendent du volume total d'activité.
- **Comparer les établissements du GHT sur une base équitable** : un CH rural avec peu de GHM marqueurs actifs et un CHU au casemix chirurgical complexe ont des ICA comparables car chacun est mesuré sur ses propres GHM et cibles — la pondération volumique neutralise l'effet taille.
- **Anticiper les pénalités tarifaires liées aux GHM marqueurs** : depuis la réforme du financement, certains actes réalisés en hospitalisation conventionnelle alors qu'ils sont sur la liste des GHM marqueurs font l'objet de minorations tarifaires (politique DREES/DGOS de valorisation différenciée) ; les GHM avec C_(g) < 0,6 sont les candidats prioritaires à une alerte préventive.
- **Alimenter le dialogue médico-économique avec les chirurgiens** : présenter les C_(g) par spécialité en CSME ou en réunion de pôle permet de positionner chaque praticien sur ses GHM marqueurs propres, en référence à une norme nationale objectivée (la cible ANAP), sans comparaison interindividuelle directe.

## Sources de Données

- **PMSI MCO RSA** (ATIH) : variable `ghm2` (6 caractères) — le 6e caractère détermine le niveau de sévérité : `J` = ambulatoire. Extraction annuelle ou trimestrielle selon la granularité souhaitée.
- **Référentiel GHM marqueurs ANAP** : liste des racines GHM éligibles et taux cibles associés, mise à jour annuellement. Disponible :
  - Sur le portail ANAP (www.anap.fr) dans le programme « Développement de la chirurgie ambulatoire »
  - En annexe des CPOM ARS (déclinaison régionale des objectifs nationaux)
  - Dans le rapport DREES-ANAP « Tableau de bord de la chirurgie ambulatoire » (publication annuelle)
- **Référentiel GHM ATIH** : table de correspondance GHM complet → racine → CMD → libellé chirurgical/médical. Nécessaire pour vérifier qu'un GHM est bien de nature chirurgicale et non médicale avant inclusion dans G_marqueurs.
- **ScanSanté (ATIH)** : module chirurgie ambulatoire — permet d'accéder aux taux nationaux et régionaux par GHM marqueur pour validation du calcul local et benchmarking immédiat.

## Exemple de Valeurs

| Contexte | ICA | Taux_GHM_cible | Séjours à convertir |
|---|---|---|---|
| Clinique MCO chirurgicale bien organisée | 1,05–1,15 | 85–95% des GHM marqueurs actifs | < 50 séjours/an |
| CH polyvalent, UCA récente (< 3 ans) | 0,72–0,85 | 40–60% des GHM à cible | 150–400 séjours/an |
| CH rural, faible volume chirurgical | 0,60–0,75 | 30–50% des GHM à cible | 80–200 séjours/an |
| CHU (casemix complexe dominant) | 0,80–0,95 | 60–75% des GHM à cible | 300–800 séjours/an |
| CH après restructuration UCA complète | 0,95–1,05 | 75–90% des GHM à cible | < 100 séjours/an |

**Valeurs C_(g) par GHM type :**
- Chirurgie du cristallin (cible 98%) : C = 0,85–1,02 selon établissement
- Cholécystectomie (cible 85%) : C = 0,50–0,95 selon équipement et organisation
- Hernie inguinale (cible 92%) : C = 0,60–1,05
- Prothèse totale de hanche (cible ANAP ~15%) : C = 0,80–1,20 (petite chirurgie ambulatoire orthopédique avancée)

**Seuils d'alerte :**
- ICA < 0,70 → retard critique, GHM à convertir en priorité — plan d'action formalisé recommandé
- ICA 0,70–0,85 → en progression, suivi trimestriel
- ICA 0,85–1,00 → dans la cible ou proche — maintenir le cap
- ICA > 1,00 → au-delà de la cible sur la moyenne pondérée — vérifier les GHM avec C_(g) très faible qui seraient masqués par des sur-performances ailleurs

**Volume minimal par GHM :** RSA_total_(g) ≥ 30 sur la période pour une interprétation fiable de C_(g).

## Limites

- **Référentiel ANAP révisé annuellement** : la liste des GHM marqueurs et les taux cibles évoluent chaque année. Un ICA calculé avec le référentiel 2022 n'est pas directement comparable à un ICA calculé avec le référentiel 2024 — documenter systématiquement le millésime du référentiel utilisé et recalculer sur une base stable pour les analyses de tendance.
- **GHM non pratiqués ≠ sous-performance** : si un GHM marqueur est absent de l'établissement (RSA_total = 0), il est exclu de l'ICA. Cela peut masquer une activité entièrement externalisée (patient opéré en clinique du GHT) — l'ICA ne capture que l'activité réalisée, pas les fuites. Croiser avec `taux_fuite_attractivite.md`.
- **Suffixe J vs durée nulle** : dans certaines versions de la classification GHM (antérieures à v11a), les séjours ambulatoires ne sont pas systématiquement en GHM « J » — la durée de séjour = 0 nuit était le critère principal. En cas d'analyse rétrospective multi-annuelle, vérifier la règle de codage applicable à chaque exercice.
- **Hétérogénéité des cibles régionales** : certaines ARS fixent des cibles régionales différentes des cibles nationales ANAP dans les CPOM (objectifs plus ambitieux ou adaptés au tissu local). L'ICA calculé sur les cibles nationales peut diverger de l'indicateur utilisé dans le dialogue ARS — s'assurer de la cohérence du référentiel de cible utilisé.
- **GHM marqueurs à faible volume et ICA instable** : pour les établissements avec moins de 5 GHM marqueurs actifs (petites structures rurales), l'ICA est très sensible à la performance sur 1 ou 2 GHM — interpréter avec précaution et présenter les C_(g) individuels plutôt que l'ICA seul.
- **Non-capture des refus d'ambulatoire documentés** : certains séjours ambulatoires éligibles sont réalisés en hospitalisation conventionnelle pour motif médicalement justifié (comorbidités, isolement social, contre-indication anesthésique). Le PMSI ne documente pas ces refus ; l'ICA peut sous-estimer la performance réelle de l'établissement sur les GHM concernés.

## Références

- [ANAP — Programme national de développement de la chirurgie ambulatoire : référentiel GHM marqueurs et taux cibles (mise à jour annuelle)](https://www.anap.fr/)
- [DREES-ANAP — Tableau de bord de la chirurgie ambulatoire en France (rapport annuel)](https://www.drees.solidarites-sante.gouv.fr/)
- [HAS — Recommandations organisationnelles : développement de la chirurgie ambulatoire](https://www.has-sante.fr/jcms/c_1754590/fr/la-chirurgie-ambulatoire)
- [Toftgaard C. — Day surgery activities 2009 : international survey on ambulatory surgery conducted 2011, Ambulatory Surgery 2012 — benchmark international des taux de chirurgie ambulatoire par procédure](https://www.iaas-med.com/)
- [Castoro C. et al. — Day surgery: making it happen, WHO Regional Office for Europe, Observatory Studies Series 2007](https://apps.who.int/iris/handle/10665/107869)
- [Joël M.E. et al. — La chirurgie ambulatoire en France : bilan, perspectives et conditions du développement, Rapport IGAS 2012, n°RM2012-024P](https://igas.gouv.fr/sites/igas/files/files-spip/pdf/TOME_1_RM2012-024P.pdf)
- [ATIH — Classification des GHMs v12 : guide de lecture et règles de groupage (suffixe J)](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
