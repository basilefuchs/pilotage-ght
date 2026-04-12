# Taux de Dérive des Plans de Soins

## Définition

Adapté du concept de **dérive de trajectoire** en contrôle de processus industriel (Statistical Process Control, Shewhart, 1931) — où une machine qui s'écarte progressivement de sa trajectoire de production idéale est détectée avant de produire des rebuts — le taux de dérive des plans de soins (TDPS) mesure l'**écart entre le plan de traitement théorique** (protocole de référence de l'établissement ou de la HAS) et la **séquence d'actes effectivement réalisée**, au niveau d'un patient ou d'une cohorte.

Un plan de soins est formalisé comme une séquence temporelle d'actes prédéfinis : en oncologie, un protocole de chimiothérapie spécifie les molécules, les doses, les cycles et les intervalles ; en SSR, un plan de rééducation spécifie le nombre de séances par semaine et leur nature. La dérive est la divergence observée entre cette séquence théorique et la séquence réellement tracée dans le PMSI (actes CCAM réalisés, durées de séjours, nombre de séances).

TDPS = 1 − (Actes_conformes / Actes_planifiés_totaux)

où TDPS = 0 signifie une exécution parfaite du plan (aucune dérive) et TDPS = 1 signifie une non-réalisation totale du plan. La dérive peut être positive (actes supplémentaires non planifiés, intensification) ou négative (actes omis, raccourcissement de cycle). Les deux types de dérive sont cliniquement significatifs mais nécessitent des interprétations différentes.

## Calcul

Définition du plan de référence :

```
Plan théorique P = {(a₁, t₁), (a₂, t₂), …, (aₙ, tₙ)}
  où aᵢ = acte attendu (code CCAM, GHM cible, nombre de séances)
  et tᵢ = fenêtre temporelle théorique (J±Δt de tolérance)

Sources du plan de référence :
  → Protocoles institutionnels (cancérologie : RCP, protocoles PHARE/INCa)
  → Protocoles HAS / INCA / SFAR (recommandations de niveau 1)
  → Plan de soins SSR individualisé (objectifs MIF, durée prévisionnelle)
  → GHM cible prévisionnelle en cas de chirurgie programmée

Plan observé Q = {(b₁, s₁), (b₂, s₂), …, (bₘ, sₘ)}
  → Extrait depuis le PMSI : actes CCAM avec dates (RSA), séquences de RHS (SSR),
    ou depuis DCIR pour les actes ambulatoires associés (chimiothérapie externe)
```

Calcul du TDPS par type de dérive :

```
Dérive par omission (actes manquants) :
  N_omis = |{aᵢ ∈ P : aucun bⱼ correspondant dans Q dans la fenêtre [tᵢ−Δt ; tᵢ+Δt]}|
  TDPS_omission = N_omis / |P|

Dérive par décalage temporel (actes réalisés hors fenêtre) :
  N_decales = |{aᵢ ∈ P : bⱼ correspondant existe mais |sⱼ − tᵢ| > Δt}|
  TDPS_decalage = N_decales / |P|

Dérive par intensification (actes supplémentaires non planifiés) :
  N_surplus = |{bⱼ ∈ Q : aucun aᵢ correspondant dans P}|
  TDPS_intensification = N_surplus / |P|   (peut être > 1 si nombreux surplus)

TDPS composite (dérive globale) :
  TDPS = (N_omis + N_decales) / |P|
  → Ne compte pas les surplus (car peuvent être cliniquement justifiés)
  → Range : [0 ; 1]
```

Score d'alignement protocole (SAP) — approche continue :

```
Pour chaque acte planifié aᵢ :
  dist_i = |sⱼ_le_plus_proche − tᵢ| / Δt_max
    → 0 si réalisé à la date exacte
    → 1 si réalisé à la limite de la fenêtre acceptable
    → > 1 si hors fenêtre (acte en dérive ou manquant, valeur tronquée à 2)

SAP = 1 − moyenne(dist_i)   ∈ [−1 ; 1], interprété sur [0 ; 1]
  SAP > 0.8 : plan bien suivi
  SAP 0.5-0.8 : dérive modérée (à surveiller)
  SAP < 0.5 : dérive significative (révision du plan recommandée)
```

Analyse de cohorte :

```
Pour une cohorte de K patients suivant le même protocole :
  TDPS_cohorte = moyenne(TDPSᵢ) sur tous les patients i ∈ {1..K}
  Distribution des TDPS : P25, P50, P75 pour identifier les patients outliers
  TDPS_outlier : patients avec TDPS > P75 + 1.5×IQR (carte de contrôle de Shewhart)
```

## Utilité

- **Contrôle qualité des protocoles oncologiques** : en chimiothérapie, le taux de dérive des cycles (omissions, reports, réductions de dose) est un prédicteur de la survie globale et de la réponse tumorale — le TDPS permet une surveillance en temps quasi-réel de la fidélité protocolaire au niveau du service ou de l'établissement, sans attendre l'audit clinique annuel
- **Évaluation de la qualité des plans de rééducation SSR** : comparer le nombre de séances réalisées au nombre prévu dans le plan individualisé (objectif MIF, durée prévisionnelle) — un TDPS élevé en SSR signale soit une sous-réalisation (manque de ressources) soit une sur-réalisation (prolongation injustifiée du séjour)
- **Détection précoce des ruptures de parcours** : un TDPS croissant sur une cohorte indique une dégradation de la capacité à exécuter les protocoles — signal organisationnel (manque de ressources, turn-over) distinct du signal clinique individuel
- **Benchmarking inter-établissements** : comparer le TDPS pour les mêmes protocoles entre établissements du GHT ou avec des établissements de référence — objectiver les écarts de pratiques et identifier les facteurs associés à une meilleure fidélité protocolaire
- **Mesure de l'impact des réorganisations** : évaluer si la création d'une infirmière de coordination, d'un navigateur de soins ou d'un logiciel de gestion des protocoles améliore le SAP des cohortes concernées — indicateur d'évaluation des innovations organisationnelles
- **Alerte sur les patients à risque de rupture** : à l'échelle individuelle, un TDPS individuel croissant (actes de plus en plus décalés ou omis) est un signal précoce de décrochage du parcours — outil de détection des patients nécessitant une intervention de coordination avant la rupture

## Sources de Données

- **PMSI MCO RSA** : actes CCAM horodatés (date d'entrée + rang dans le séjour), GHM réalisé vs GHM prévu, durée de séjour vs durée prévisionnelle — pour la dérive des séjours chirurgicaux et les hospitalisations de chimiothérapie (GHS 9617)
- **PMSI SSR RHS** : nombre de séances par type de rééducation (cotation des actes SSR), durée réelle vs durée prévisionnelle, objectifs MIF atteints — pour la dérive des plans de rééducation
- **DCIR ER_PRS_F** : actes de chimiothérapie ambulatoire (code CCAM), consultations d'oncologie (RPPS) — pour les protocoles réalisés partiellement en ambulatoire hors hospitalisation
- **Logiciels de prescription oncologique** (Chimio®, Dopasoins, Oncomip) : plan de traitement formalisé avec dates théoriques et doses prévues — source du plan de référence P ; couplage avec le PMSI via NIR pour calculer l'écart plan/réel
- **Référentiels de protocoles** : base INCa (protocoles validés par pathologie), RFCP (référentiel français de chimiothérapie pédiatrique), protocoles PHARE — pour définir formellement les séquences théoriques attendues

## Exemple de Valeurs

- **Cohorte cancer du sein (FEC-100, 6 cycles)** : TDPS_omission moyen = 0,08 (8% des cycles omis ou reportés > 7 jours), TDPS_decalage = 0,12 (12% des cycles réalisés avec un décalage de 3-7 jours) → TDPS composite = 0,20 ; SAP = 0,78 (dérive modérée)
- **Cohorte SSR neurologique post-AVC** : TDPS_omission = 0,15 (15% des séances de kinésithérapie non réalisées vs plan), TDPS_decalage négligeable → TDPS = 0,15 ; principales causes : indisponibilité du kinésithérapeute (TDPS corrélé au taux d'absentéisme)
- **Benchmark inter-établissements (même protocole FOLFOX)** : TDPS_cohorte entre 0,05 et 0,35 selon les centres — les centres avec TDPS < 0,10 ont des infirmières de coordination dédiées et un logiciel de suivi de protocole intégré
- **Seuil d'alerte qualité** : TDPS > 0,20 pour un protocole bien établi → déclenchement d'une revue de morbidité-mortalité du processus de soins (et non du patient)

## Limites

- La définition du plan de référence formalisé est le principal obstacle : les protocoles institutionnels ne sont souvent pas accessibles dans un format structuré et interrogeable automatiquement depuis le PMSI — le couplage avec les logiciels de prescription oncologique est nécessaire mais ces logiciels ne sont pas standardisés
- Le TDPS ne distingue pas les dérives médicalement justifiées (toxicité avérée, complication intercurrente conduisant à un report légitime) des dérives organisationnelles (indisponibilité de ressources, défaut de coordination) — l'analyse des causes de dérive nécessite un retour aux dossiers cliniques ou une annotation manuelle
- Les actes CCAM en PMSI ne capturent que les actes réalisés en hospitalisation ou consultation externe hospitalière — les actes de suivi réalisés exclusivement en ville (consultations du médecin généraliste entre les cycles) ne sont pas intégrés sans accès DCIR
- Le calcul du TDPS requiert un identifiant patient fiable pour le chaînage longitudinal des séjours (NIR crypté) — les établissements sans accès SNDS ne peuvent calculer le TDPS que pour les patients hospitalisés dans leur propre établissement sur l'ensemble du parcours

## Références

- [Shewhart W.A. — Economic Control of Quality of Manufactured Product, Van Nostrand 1931 : fondements du contrôle statistique de processus]
- [Deming W.E. — Out of the Crisis, MIT Press 1986 : application du SPC aux processus de service]
- [Bonadonna G. et al. — Dose-response effect of adjuvant chemotherapy for breast cancer, NEJM 1981](https://doi.org/10.1056/NEJM198102053040601) — première démonstration que la dérive protocolaire (dose intensity) impacte la survie
- [Lyman G.H. et al. — Relative dose intensity of chemotherapy and survival in patients with early-stage breast cancer, J Clin Oncol 2011](https://doi.org/10.1200/JCO.2010.32.3014)
- [INCa — Référentiel de chimiothérapie et protocoles validés par pathologie](https://www.e-cancer.fr/)
- [HAS — Évaluation des pratiques professionnelles en oncologie : indicateurs de suivi des protocoles (2020)](https://www.has-sante.fr/)
