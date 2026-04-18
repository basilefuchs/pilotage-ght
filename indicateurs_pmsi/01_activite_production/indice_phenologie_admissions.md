# Indice de Phénologie des Admissions

## Définition

La phénologie est la branche de l'écologie qui étudie les dates de survenue des événements biologiques périodiques (floraison, migration, dormance) et leur relation avec le climat. Transposée aux flux hospitaliers, elle permet de décomposer la saisonnalité des admissions en **phases distinctes** — dormance, activation, pic, déclin — pour chaque famille GHM, plutôt que de la résumer à une amplitude sinusoïdale globale.

L'analyse spectrale (FFT) capte les fréquences présentes dans un signal mais ne fournit pas de dates de transition entre états ; l'indice de saisonnalité de tension capacitaire mesure l'intensité des écarts à la moyenne, non leur structure temporelle. L'indice de phénologie des admissions comble ce vide en produisant, pour chaque famille GHM et chaque établissement, un **calendrier phénologique opérationnel** : semaine de début de montée en charge, semaine de pic, durée du plateau, semaine de déclin.

Formellement, pour une série mensuelle d'admissions X_t sur une famille GHM f :

```
Phase(t) ∈ {Dormance, Activation, Pic, Déclin}
```

La phase est assignée par double seuillage sur la valeur et sa dérivée :

```
Dormance  : X_t < μ_f − 0,5·σ_f
Activation: X_t < μ_f + 0,5·σ_f  ET  ΔX_t > 0
Pic       : X_t ≥ μ_f + 0,5·σ_f
Déclin    : X_t ≥ μ_f − 0,5·σ_f  ET  ΔX_t < 0
```

Un indicateur de synthèse est le **Pheno-Score** : corrélation de Pearson entre la série observée et le calendrier phénologique de référence national (issu de la moyenne nationale PMSI sur 5 ans). Un Pheno-Score ≈ 1 signale un comportement saisonnier conforme au national ; un score faible ou négatif révèle une désynchronisation (pathologie à saisonnalité inverse, recrutement territorial atypique).

## Calcul

Source : PMSI MCO RSA — variables `GHM` (8 caractères), `date_entree` (mois/année), `FINESS_GEO`.

```
Population : tous séjours MCO d'un établissement sur une période ≥ 3 ans

Étape 1 — Agrégation mensuelle par famille GHM (5 premiers caractères du GHM) :
  X_f_m = count(RSA | GHM_racine = f, mois = m)

Étape 2 — Lissage (optionnel, pour réduire bruit semaine COVID) :
  X_f_m_lissé = moyenne mobile 3 mois centrée sur m

Étape 3 — Paramètres de distribution annuelle :
  μ_f  = moyenne mensuelle sur période de référence (36 mois minimum)
  σ_f  = écart-type mensuel sur même période

Étape 4 — Attribution de phase mensuelle :
  Pour chaque mois m :
    ΔX = X_f_m − X_f_{m-1}
    Si X_f_m < μ_f − 0,5·σ_f                           → Dormance
    Si X_f_m < μ_f + 0,5·σ_f  ET  ΔX > 0               → Activation
    Si X_f_m ≥ μ_f + 0,5·σ_f                            → Pic
    Si X_f_m ≥ μ_f − 0,5·σ_f  ET  ΔX ≤ 0               → Déclin

  Cas limite (ambiguïté ΔX = 0) : maintien de la phase précédente

Étape 5 — Extraction du calendrier phénologique (par année glissante) :
  semaine_debut_activation = première semaine de phase Activation (conversion mois → semaine S)
  semaine_debut_pic        = première semaine de phase Pic
  duree_pic_semaines       = nb de semaines consécutives en phase Pic
  amplitude_pic            = (X_pic_max − μ_f) / σ_f  [en écarts-types]

Étape 6 — Pheno-Score de conformité nationale :
  X_ref_f = série mensuelle de référence nationale (agrégat PMSI 5 ans)
  Pheno-Score_f = corr(Pearson)(X_f_lissé, X_ref_f)
  Plage : [−1 ; 1]
  > 0,80 : phénologie conforme au national
  0,40–0,80 : légère désynchronisation
  < 0,40 : phénologie atypique — analyser les causes
```

Indicateurs dérivés :

```
Décalage phénologique (Δ_semaines) :
  = semaine_debut_pic_établissement − semaine_debut_pic_nationale
  Δ > 0 : pic tardif (demande différée, capacité réduite en période habituelle)
  Δ < 0 : pic précoce (afflux anticipé, possiblement organisationnel)

Amplitude relative de pic :
  A_rel = (X_pic_max − X_dormance_min) / μ_f
  Valeur > 2 : forte tension saisonnière → planification capacitaire critique

Indice de désynchronisation GHT :
  = max(|semaine_pic_Etab_A − semaine_pic_Etab_B|) pour une même famille GHM
  Permet d'identifier des fenêtres de coopération inter-établissements GHT
```

## Utilité

- **Anticipation des pics de tension par famille GHM** : connaître la semaine habituelle de début de montée en charge pour les GHMs respiratoires (CMD 04) ou traumatologiques (CMD 08) permet de déclencher des plans capacitaires avant le pic plutôt qu'en réaction, avec une précision à la semaine inaccessible par les méthodes de saisonnalité classiques
- **Détection des désynchronisations pathologiques** : un Pheno-Score < 0,40 sur une famille GHM signale soit un recrutement territorial différent du national (bassin de population vieillissant, épidémie locale), soit un artefact organisationnel (fermeture estivale de lits, migration de patients vers un autre établissement du GHT en période de pic)
- **Planification des rotations et remplacements de personnel** : aligner les périodes de congés du personnel soignant sur les phases de Dormance identifiées pour chaque service, en évitant les chevauchements avec les phases d'Activation et de Pic — information plus fine que le simple «été/hiver»
- **Coordination GHT par complémentarité phénologique** : deux établissements du GHT dont les pics sont décalés de 4 à 6 semaines peuvent organiser des transferts planifiés de personnel ou de lits — l'indice de désynchronisation GHT quantifie cette fenêtre de coopération
- **Suivi de l'impact des réorganisations** : mesurer le décalage phénologique avant/après une réorganisation (fermeture d'un service, ouverture d'une nouvelle unité d'hospitalisation de semaine) pour évaluer si le comportement saisonnier a été modifié
- **Benchmark régional** : comparer les calendriers phénologiques entre établissements de même type (CH de même taille) dans la région révèle si l'établissement absorbe une part disproportionnée de l'activité saisonnière sur certaines familles GHM

## Sources de Données

- **PMSI MCO RSA** : variable `GHM` (8 caractères — racine GHM = 5 premiers), `DATE_ENTREE` (AAAAMM ou AAAAMMJJ selon format ATIH), `FINESS_GEO` — extraction trimestrielle ou mensuelle
- **Référentiel ATIH des GHMs** : correspondance GHM racine → CMD → libellé, pour l'agrégation par famille nosologique cohérente
- **Série nationale de référence** : construite depuis la base nationale PMSI MCO ATIH (5 ans glissants) — agrégation mensuelle par racine GHM, normalisée par nombre d'établissements actifs sur la famille

## Exemple de Valeurs

- **CMD 04 (Affections respiratoires) — CH 400 lits** : semaine_debut_pic = S43 (fin octobre), duree_pic = 14 semaines, amplitude_relative = 1,8σ, Pheno-Score = 0,87 (conforme national)
- **CMD 08 (Affections musculo-squelettiques) — CHU** : pic estival (prothèses programmées) S24–S32, amplitude = 1,3σ, Pheno-Score = 0,72 ; pic hivernal traumatologique S48–S08, amplitude = 1,5σ, Pheno-Score = 0,81
- **CMD 15 (Nouveau-nés) — Maternité niveau III** : Pheno-Score = 0,45 (désynchronisé — recrutement régional modifie la saisonnalité locale)
- **Décalage phénologique d'alerte** : Δ > 3 semaines entre deux établissements GHT pour une même CMD → investiguer les flux de patients inter-établissements
- **Amplitude critique de planification** : A_rel > 2,5 sur CMD 04 → déclencher protocole anticipé de gestion capacitaire hivernale

## Limites

- **Historique minimal requis** : 36 mois consécutifs sont nécessaires pour stabiliser μ_f et σ_f ; sur des familles GHM à faible volume (< 100 séjours/an), les phases sont instables — recommander un seuil minimal de 50 séjours par mois de pic pour une interprétation fiable
- **Sensibilité aux ruptures exogènes** : les périodes COVID (2020–2021) ou les grèves longues créent des artefacts phénologiques majeurs ; il est impératif d'exclure ces périodes du calcul de la série de référence ou de leur appliquer une imputation
- **Granularité mensuelle vs hebdomadaire** : le PMSI MCO est transmis trimestriellement à l'ATIH ; une granularité mensuelle est accessible en interne mais la granularité hebdomadaire nécessite un système d'information local — la semaine de début de pic n'est qu'une approximation à ±2 semaines en données mensuelles
- **Changements de classification GHM** : les versions successives de la classification ATIH (v11, v12) modifient les regroupements de racines GHM, rendant les comparaisons pluriannuelles difficiles sans recodage ; utiliser les CMDs (2 caractères, stables) comme niveau de repli
- **Non-applicabilité directe au SSR et à la psychiatrie** : le modèle de phases est calibré sur le MCO ; le SSR (modes de prise en charge) et la psychiatrie (journées) ont des dynamiques différentes nécessitant un recalibrage des seuils

## Références

- [Fitter A.H., Fitter R.S.R. — Rapid changes in flowering time in British plants, Science 2002 : fondements de l'analyse phénologique des dates de transition entre phases biologiques](https://doi.org/10.1126/science.1071617)
- [Menzel A. et al. — European phenological response to climate change matches the warming pattern, Global Change Biology 2006](https://doi.org/10.1111/j.1365-2486.2006.01193.x)
- [Bhaskaran K. et al. — Time series regression studies in environmental epidemiology, International Journal of Epidemiology 2013 : méthodes de détection de phases dans des séries temporelles de santé](https://doi.org/10.1093/ije/dyt092)
- [ATIH — Statistiques et publications PMSI MCO : base nationale, accès données agrégées mensuelles](https://www.atih.sante.fr/)
- [Page C.M. et al. — Detecting seasonal patterns in time series of counts, Statistics in Medicine 2004 : méthodes de seuillage phénologique appliquées aux données de santé publique]
