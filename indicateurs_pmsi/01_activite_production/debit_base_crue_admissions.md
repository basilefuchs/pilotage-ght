# Débit de Base et Débit de Crue des Admissions

## Définition

En hydrologie, le **débit total** d'une rivière se décompose en deux composantes de nature fondamentalement différente :
- Le **débit de base** (baseflow) : apport lent, régulier et prévisible provenant des nappes phréatiques et des eaux souterraines — il représente le fond permanent du débit, quasi-indépendant des précipitations immédiates.
- Le **débit de crue** (stormflow ou quickflow) : ruissellement rapide, variable et imprévisible déclenché par les épisodes pluvieux — il génère les pics de débit mais se résorbe vite.

Transposée aux admissions hospitalières, cette décomposition distingue :
- Le **débit de base hospitalier** (DBH) : admissions programmées, planifiées, attendues — chirurgie élective, hospitalisations conventionnelles de patients chroniques, chimiothérapies, actes diagnostiques — flux contrôlable, régulier, optimisable par le heijunka.
- Le **débit de crue hospitalier** (DCH) : admissions non programmées, imprévisibles — urgences directes, hospitalisations après passage aux urgences, transferts imprévus — flux subi, variable, partiellement incompressible.

**Indice de Base Hospitalier (IBH) = DBH / (DBH + DCH)**

Un IBH élevé (> 0,6) signifie que la majorité des admissions est programmée et donc maîtrisable. Un IBH faible (< 0,3) signifie que le service est dominé par le flux d'urgence — peu de marge pour le lissage, la gestion des capacités doit être réactive plutôt que planifiée. L'IBH est le premier paramètre à calculer avant toute démarche d'optimisation des flux : il détermine si les leviers d'action sont du côté de la programmation (IBH élevé) ou de l'aval urgentiste (IBH faible).

## Calcul

Identification du type d'admission depuis le PMSI MCO RSA :

```
Variables modeentree + provenance (RSA champ MCO — nomenclature ATIH) :
  modeentree 8 : entrée depuis le domicile
      → avec provenance 5 (passage par les urgences) : CRUE
      → sans provenance 5 : admission directe/programmée → BASE potentielle
  modeentree 7 : transfert depuis un autre établissement → ambigu
  modeentree 6 : mutation depuis une autre UM du même établissement → ambigu
              (peut être programmé ou non selon le contexte)

Règle de classification simplifiée (PMSI seul) :
  CRUE = entrée par les urgences :
         (modeentree = 8 ET provenance = 5)
         OU passage_urg = 1 (variable disponible à partir de 2023)
  BASE = séjours avec modeentree = 8 ET provenance ≠ 5
         ET modesortie ≠ 9 (décès)
         ET type_GHM ∈ {C (chirurgical), Z (acte technique), K (ambulatoire)}
  AMBIGU (exclus) = mutations/transferts (modeentree 6, 7) et autres cas
```

Calcul des indicateurs de décomposition :

```
Sur une fenêtre temporelle T (mois ou semaine) :

  N_BASE(T) = nombre de séjours classés BASE sur la période T
  N_CRUE(T) = nombre de séjours classés CRUE sur la période T
  N_TOTAL(T) = N_BASE(T) + N_CRUE(T)

  Indice de Base Hospitalier (IBH) :
    IBH = N_BASE / N_TOTAL   ∈ [0 ; 1]

  Variabilité relative des deux composantes :
    CV_BASE = σ(N_BASE mensuel) / μ(N_BASE mensuel)
    CV_CRUE = σ(N_CRUE mensuel) / μ(N_CRUE mensuel)
    → En général : CV_CRUE > CV_BASE (la crue est plus variable que la base)
    → Si CV_BASE > CV_CRUE : la programmation est moins stable que les urgences
      → dysfonctionnement organisationnel (déprogrammations fréquentes)

  Ratio de prévisibilité (RP) :
    RP = CV_CRUE / CV_BASE
    → RP > 2 : les urgences sont bien plus variables que le programmé (situation normale)
    → RP < 1.2 : les deux composantes ont une variabilité similaire
      → le programmé est géré aussi aléatoirement que les urgences → problème

  Saisonnalité différentielle :
    → Calculer IBH par mois calendaire pour identifier les déséquilibres saisonniers
    → IBH estival : souvent plus faible (programmé réduit, urgences maintenues)
    → Amplitude saisonnière d'IBH = IBH_max − IBH_min (sur 12 mois)
```

Décomposition par service et par type de GHM :

```
IBH par service (UM) :
  → Service chirurgical électif : IBH attendu 0,75-0,90
  → Service médecine interne : IBH attendu 0,30-0,50
  → Service gériatrie aiguë : IBH attendu 0,20-0,40
  → Réanimation : IBH attendu 0,05-0,15

IBH par complexité de casemix :
  → Calculer N_BASE et N_CRUE pour les GHM de niveau 1-2 (simples)
    vs GHM de niveau 3-4 (complexes, avec CC ou CMA)
  → Un service avec IBH global élevé mais IBH_complexe faible
    programme surtout les cas simples et subit les cas complexes
    → Potentiel de développement de filières programmées pour cas complexes
```

## Utilité

- **Calibrer les outils de gestion des capacités selon la structure réelle du flux** : un service avec IBH < 0.3 ne bénéficiera pas du heijunka (qui n'agit que sur le flux BASE) mais d'une gestion réactive des capacités (lits tampons, astreintes de planification, protocoles de débordement) — l'IBH détermine quel type d'outil est pertinent avant tout investissement organisationnel
- **Mesurer l'impact de la création de filières programmées** : quand un GHT crée une filière chirurgicale dédiée (chirurgie ambulatoire, filière orthopédique rapide), IBH doit augmenter — indicateur de résultat direct, calculable trimestriellement depuis le PMSI sans accès à d'autres systèmes
- **Identifier les services où la programmation est instable** : un CV_BASE élevé (variabilité du flux programmé comparable au flux urgence) révèle une désorganisation de la programmation — déprogrammations fréquentes, plages opératoires non remplies, patients annulés au dernier moment — signal d'action sur les processus de programmation avant même d'agir sur le flux d'urgence
- **Dimensionner les ressources en distinguant la part fixe et la part variable** : IBH × capacité nominale = capacité dédiable à la programmation (équipe stable, protocoles fixes) ; (1−IBH) × capacité = capacité à gérer en mode réactif (personnel flexible, astreintes, protocoles de crise) — base de dimensionnement des équipes RH
- **Benchmarking territorial** : un territoire avec un IBH global faible a un système de soins primaires peu développé (les patients arrivent directement aux urgences sans filtrage ambulatoire) — indicateur complémentaire de l'indice de rétention des soins primaires, entièrement calculable depuis le PMSI sans données de ville

## Sources de Données

- **PMSI MCO RSA** : variables `modeentree` + `provenance` (urgences = 8 + provenance 5), type de GHM (chirurgical C, médical M, technique Z, ambulatoire K), DA pour le calcul du Charlson — entièrement disponibles dans les extractions RSA standard ; agrégation par UM/service et par mois calendaire sur 24-36 mois

## Exemple de Valeurs

- **Établissement MCO de taille moyenne (200 lits, GHT semi-rural)** :
  IBH global = 0,52 (52% d'admissions programmées)
  CV_BASE = 0,11, CV_CRUE = 0,23, RP = 2,1 (situation normale)
  Amplitude saisonnière : IBH_juillet = 0,41, IBH_novembre = 0,58
  → Le mix entre programmé et urgence est modéré et saisonnier

- **Service de chirurgie viscérale** :
  IBH = 0,78, CV_BASE = 0,09 (programmation stable et dominante)
  → Candidat prioritaire pour le heijunka, potentiel de lissage élevé

- **Service de médecine polyvalente** :
  IBH = 0,28, CV_CRUE = 0,31, CV_BASE = 0,29, RP = 1,07
  → Le flux programmé est géré aussi irrégulièrement que les urgences
  → Signal de dysfonctionnement de la programmation médicale

- **Impact d'un programme d'hospitalisation directe (bypass urgences)** :
  Avant : IBH = 0,34 ; Après 18 mois de programme : IBH = 0,47
  → +13 points d'IBH = 1 patient sur 8 en moins via les urgences

## Limites

- La classification BASE/CRUE depuis `modeentree`/`provenance` est une **approximation** — certaines entrées directes du domicile adressées par le médecin traitant sont des hospitalisations de semi-urgence planifiées dans la journée, que l'on classe en BASE alors qu'elles partagent les caractéristiques de la CRUE ; une validation sur les données d'agenda (logiciel de programmation) améliore la classification mais n'est pas disponible dans le PMSI
- Le PMSI ne distingue pas la **programmation réellement anticipée** (rendez-vous planifié plusieurs semaines à l'avance) de la **programmation du jour même** (consultation du matin conduisant à une hospitalisation dans l'après-midi) — or ces deux types de BASE ont des implications très différentes pour la gestion des capacités
- L'IBH calculé depuis le PMSI inclut les **mutations internes** (UM → UM au sein du même établissement) qui n'ont pas de mode d'entrée standard : elles sont souvent classées en flux ambigu et peuvent biaiser l'IBH si elles sont nombreuses dans certains services à forte activité d'aval

## Références

- [Hewlett R.F., Bosch J.M. — Hydrograph separation, Water Resources Research 1982 : méthode de décomposition débit de base / crue]
- [Nathan R.J., McMahon T.A. — Evaluation of automated techniques for base flow and recession analyses, Water Resources Research 1990](https://doi.org/10.1029/WR026i007p01465)
- [Litvak E., Long M.C. — Cost and quality under managed care: irreconcilable differences?, Am J Manag Care 2000]
- [DGOS — Instruction relative à la mise en place du programme PACES (Parcours patients, Accès direct, Coordination) : flux programmés vs non programmés (2022)](https://solidarites-sante.gouv.fr/)
- [ATIH — Variables du RSA MCO : description des champs mode d'entrée et provenance](https://www.atih.sante.fr/)
