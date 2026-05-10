# Entropie de Permutation des Intervalles entre Événements Indésirables Graves

## Définition

L'**entropie de permutation** (Bandt & Pompe 2002) est une mesure de la complexité d'une série temporelle fondée sur les **motifs ordinaux** : on observe l'ordre relatif (ranks) de fenêtres glissantes de taille m, et on calcule l'entropie de Shannon sur la distribution des m! motifs possibles. Elle est conceptuellement simple, robuste au bruit et aux non-linéarités, et invariante par transformation monotone.

Appliquée à la **série des intervalles inter-événements** Δt entre EIG consécutifs d'un établissement (Δt_1 = t_2 − t_1, Δt_2 = t_3 − t_2, …), l'entropie de permutation quantifie la **régularité temporelle** des incidents :

- **PE proche du maximum (log m!)** → série désordonnée, événements indépendants dans le temps (Poisson homogène)
- **PE faible** → série très structurée : motifs récurrents, présence de **clusters** ou de **cycles** d'événements indésirables

Formule pour ordre m (typiquement m = 3 ou 4) :

```
PE(m) = − Σ_{π ∈ S_m} p(π) · log p(π)

PE_normalisée = PE(m) / log(m!)   ∈ [0, 1]
```

où S_m est l'ensemble des m! permutations possibles et p(π) la fréquence empirique du motif π.

**Positionnement vs indicateurs existants** : les fiches `value_at_risk_evenements_indesirables.md`, `loi_gutenberg_richter_evenements_indesirables.md`, `cusum_surveillance_complications.md` du dépôt traitent de la **fréquence** ou de l'**amplitude** des EIG. Aucune ne capture la **structure temporelle** : un établissement peut avoir un taux d'EIG conforme tout en présentant des **regroupements anormaux** (5 EIG en une semaine, puis 2 mois calmes), signature d'un mode de défaillance latent. PE détecte cette signature.

## Calcul

```
Étape 1 — Construction de la série inter-événements :
  Sur fenêtre 24-36 mois, lister tous les EIG codés au PMSI :
    EIG = décès inattendu (mode_sort=9 hors palliatif/oncologique)
        ∪ retour bloc <24h
        ∪ transfert non programmé en réa (changement UM)
        ∪ complications sévères PSI-90 (sepsis, EP, choc)
  Trier par date_sortie + heure (à défaut, séquence ordinale)
  Δt_i = (date_EIG_{i+1} − date_EIG_i) en heures ou jours
  → série Δ = (Δt_1, Δt_2, …, Δt_N)

Étape 2 — Extraction des motifs ordinaux d'ordre m :
  Choisir m = 3 (6 motifs) ou m = 4 (24 motifs)
  Pour i = 1 .. N − m + 1 :
    Fenêtre F_i = (Δt_i, Δt_{i+1}, …, Δt_{i+m−1})
    Calculer le motif ordinal π_i = arg-rank(F_i)
    (ex. m=3, F = (5, 2, 9) → motif (2, 1, 3) )
  Compter les occurrences de chaque motif π ∈ S_m

Étape 3 — Calcul de PE :
  Pour chaque motif π : p(π) = count(π) / (N − m + 1)
  PE = − Σ p(π) · log p(π)
  PE_norm = PE / log(m!)

Étape 4 — Test de significativité :
  H0 : indépendance temporelle (Poisson) → PE_norm attendue ≈ 1
  Bootstrap : permuter aléatoirement la série Δ (1000 fois), recalculer PE
  → distribution empirique sous H0
  → p-value = P(PE_perm < PE_obs)
  → si p < 0.05 : structure temporelle significative

Étape 5 — Indicateur dérivé : Complexité statistique (Lopez-Ruiz, Mancini, Calbet) :
  C = D(P, P_uniform) · PE   (produit divergence × entropie)
  → distingue les séries déterministes (C élevé) des séries aléatoires (C faible)
```

Implémentation R/Python via `pracma` (R), `pyentrp.entropy.permutation_entropy` (Python), ou `nolds` (Python).

## Utilité

- **Détection de clusters d'événements indésirables** : PE_norm < 0,80 signale des regroupements temporels anormaux (épidémie nosocomiale, défaillance équipe sur une période, problème équipement) que les comptes mensuels lissent
- **Signal précoce de mode de défaillance latent** : la baisse de PE précède souvent l'augmentation du taux brut — outil prédictif pour la cellule qualité
- **Discrimination « hasard » vs « structure » dans les pics d'EIG** : un pic isolé peut être aléatoire ; un pic dans une série à PE faible est structurellement à risque
- **Comparabilité robuste entre établissements** : PE est invariante par transformation monotone (ne dépend pas de la fréquence absolue) → comparaison équitable d'établissements de tailles différentes
- **Pilotage des RMM** : les RMM ciblées sur les périodes de PE basse (clusters identifiés) sont plus instructives que les RMM mensuelles systématiques
- **Évaluation post-intervention** : un plan d'action efficace doit ramener PE_norm vers 1 (déstructuration des clusters) — métrique complémentaire aux comptes
- **Surveillance du système qualité** : ratio PE_obs / PE_max sur fenêtre glissante 6 mois → carte de contrôle dédiée à la « régularité » du système

## Sources de Données

- **PMSI MCO RSA** : dates de sortie, mode de sortie (décès), DAS pour complications PSI-90, CCAM avec dates pour reprises chirurgicales, codes UM pour transferts internes
- **Données auxiliaires sub-journalières** : si disponible, l'heure d'événement (système de signalement EIG, dossier patient) améliore la précision pour les ordres élevés (m = 4) — sinon, agréger à la journée
- **Liste de référence des EIG** : adapter selon la maille (PSI-90, liste HAS never-events, EIG codés ATIH)
- **Volume minimal** : ≥ 100 EIG sur la fenêtre pour stabilité de l'estimation à m = 3 (≥ 24 motifs comptés en moyenne) ; ≥ 500 pour m = 4

## Exemple de Valeurs

- **CHU stable, ~600 EIG/24 mois** :
  - m = 3, PE_norm ≈ 0,96 → fonctionnement nominal proche de Poisson
  - p-value bootstrap ≈ 0,42 (non significatif)
- **CH général en période de crise (vacance PH chirurgie)** :
  - m = 3, PE_norm ≈ 0,78 → motifs ordinaux concentrés (clusters)
  - p-value < 0,01 → structure temporelle significative
  - décomposition : motif (3,1,2) sur-représenté = pattern « pic-creux-rebond »
- **Polyclinique post-réorganisation** :
  - PE_norm passe de 0,82 (avant) à 0,93 (après 12 mois) → effet positif de l'intervention
- **Seuils indicatifs** :
  - PE_norm > 0,90 → fonctionnement régulier
  - PE_norm ∈ [0,80 ; 0,90] → vigilance, regarder les motifs sur-représentés
  - PE_norm < 0,80 → audit qualité approfondi recommandé
- *Plages indicatives, ordre de grandeur expert ; calibrer sur cohorte GHT avant interprétation opérationnelle.*

## Limites

- **Volume minimal d'EIG** : avec < 50 événements sur la fenêtre, l'estimation de PE est dominée par le bruit d'échantillonnage — agréger plusieurs ES du GHT ou élargir le périmètre EIG
- **Sensibilité au paramètre m** : m = 3 capture la structure courte mais peut manquer des cycles plus longs ; m = 4 nécessite plus de données ; pratique : présenter PE pour m = 3 et m = 4
- **Codage exhaustif des EIG critique** : un sous-codage sous-évalue les clusters (les événements manqués créent des intervalles artificiellement longs) — audit du codage préalable indispensable
- **Égalités (ties) dans les Δt** : la définition standard de PE suppose des valeurs distinctes ; en cas d'événements simultanés, recourir à la variante de Cao (2004) avec rangs partiels
- **Pas de causalité** : PE détecte une structure temporelle mais n'identifie pas sa cause (épidémie, équipe, équipement) — exige enquête qualitative en aval
- **Indicateur abstrait** : nécessite une présentation pédagogique (visualisation des motifs, comparaison avec PE simulée Poisson) — déployer avec dashboard expliquant la métrique
- **Hypothèse de stationnarité** : PE classique suppose une distribution stable des Δt ; en cas de changement structurel (ex. fusion d'établissements), recalculer sur sous-périodes
- **Pas de standard international en santé** : peu d'utilisation pour la qualité hospitalière, ce qui freine la comparabilité externe et la diffusion réglementaire

## Références

- [Bandt C., Pompe B. — Permutation entropy: a natural complexity measure for time series, Phys. Rev. Lett. 2002 (PMID:11955168)](https://doi.org/10.1103/PhysRevLett.88.174102)
- [Cao Y. et al. — Detecting dynamical changes in time series using the permutation entropy, Phys. Rev. E 2004 : extension aux égalités](https://doi.org/10.1103/PhysRevE.70.046217)
- [Zanin M., Zunino L., Rosso O.A., Papo D. — Permutation entropy and its main biomedical and econophysics applications: a review, Entropy 2012](https://doi.org/10.3390/e14081553)
- [Riedl M., Müller A., Wessel N. — Practical considerations of permutation entropy: a tutorial review, Eur. Phys. J. Special Topics 2013](https://doi.org/10.1140/epjst/e2013-01862-7)
- [López-Ruiz R., Mancini H.L., Calbet X. — A statistical measure of complexity, Phys. Lett. A 1995 : complexité statistique LMC](https://doi.org/10.1016/0375-9601(95)00867-5)
- [Cover T.M., Thomas J.A. — Elements of Information Theory, Wiley 2006 : référence générale entropie de Shannon](https://doi.org/10.1002/047174882X)
- [HAS — Méthode d'analyse des événements indésirables graves en établissements de santé](https://www.has-sante.fr/)
- [ATIH — Manuel des GHM et guide méthodologique PMSI MCO en vigueur](https://www.atih.sante.fr/)
