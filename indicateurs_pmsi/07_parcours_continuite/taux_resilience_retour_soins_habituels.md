# Taux de Résilience — Retour aux Soins Habituels

## Définition

La **résilience écologique** (Holling, 1973) désigne la capacité d'un écosystème à retrouver son état d'équilibre après une perturbation — en opposant résilience (vitesse de retour) à résistance (amplitude du déplacement). Appliqué au parcours de soins, le **taux de résilience — retour aux soins habituels** (TRRSH) mesure la proportion de patients qui retrouvent leur intensité de soins ambulatoires pré-hospitalisation dans les 90 jours suivant leur sortie, l'hospitalisation étant la perturbation et le retour au régime de soins habituel la mesure de résilience du parcours.

Pour chaque patient hospitalisé :

- **Intensité pré-hospitalisation** (I₀) = nombre d'actes SNDS dans les 180 jours précédant l'admission / 180 (en actes/jour)
- **Intensité post-sortie** (I₉₀) = nombre d'actes SNDS dans les 90 jours suivant la sortie / 90 (en actes/jour)
- **Patient résilient** = |I₉₀ − I₀| / I₀ ≤ 20 % (retour à ± 20 % de son régime habituel)

TRRSH = n(patients résilients) / n_total_hospitalisés × 100

La valeur de référence d'un patient est individualisée (son propre régime pré-hospitalisation) et non populationnelle, ce qui distingue fondamentalement cet indicateur du taux de suivi ambulatoire post-hospitalier (qui mesure la présence d'un contact, sans référence à l'intensité habituelle du patient) et du score d'intensité de consommation ambulatoire (qui mesure un niveau absolu, non relatif à la baseline individuelle).

## Calcul

**Sources :** SNDS chaîné (DCIR `ER_PRS_F`) + PMSI MCO RSA, horizon de suivi 9 mois par patient (6 mois pré + 3 mois post).

```
Population : séjours MCO index avec SOR_DAT dans la période d'analyse
             Exclusions :
               - Décès pendant l'hospitalisation (MODE_SORTIE = 9)
               - Décès dans les 90 jours post-sortie (date décès < J0+90 dans IR_BEN_R)
               - Patients avec < 2 actes SNDS dans la fenêtre pré-hospitalisation
                 (pas de baseline calculable)
               - Nouveau-nés (CMD 15), séances (NAT_ASS = 1), obstétrique (CMD 14)

Étape 1 — Fenêtres d'observation :
  J_admission = ENT_DAT du séjour index
  J_sortie    = SOR_DAT du séjour index (= J0)
  Fenêtre pré  : [J_admission − 180j ; J_admission − 1j]  → 180 jours avant entrée
  Fenêtre post : [J0 + 1j ; J0 + 90j]                   → 90 jours après sortie

Étape 2 — Calcul des intensités individuelles (SNDS ER_PRS_F) :
  Actes comptabilisés : consultations (C, CS, V, VS), actes médicaux (K, Z, D...),
    actes paramédicaux (AMK, AMI, DE, DI), biologie (B), imagerie (P, Z...)
    Exclure : actes hospitaliers (établissements MCO/SSR), médicaments (PHA),
              transport (VL, VSL), dispositifs médicaux
  n_actes_pré  = count(actes) sur fenêtre pré, pour le NIR_PSA du patient
  n_actes_post = count(actes) sur fenêtre post
  I₀   = n_actes_pré  / 180  (actes/jour)
  I₉₀  = n_actes_post / 90   (actes/jour)

Étape 3 — Classification individuelle :
  Δ_relatif = |I₉₀ − I₀| / I₀
  Patient résilient         : Δ_relatif ≤ 0.20  (retour à ± 20 % de la baseline)
  Patient en sous-recours   : (I₉₀ − I₀) / I₀ < −0.20  (intensité post inférieure)
  Patient en sur-recours    : (I₉₀ − I₀) / I₀ > +0.20  (intensité post supérieure)
  Cas limite : I₀ = 0 (patient sans actes pré documentés) → exclure du numérateur
               et du dénominateur, reporter dans le taux d'exclusion

Étape 4 — Agrégation :
  TRRSH_global   = n_résilients / n_total_éligibles × 100
  TRRSH_par_GHM  = TRRSH calculé par racine GHM (5 car.) — identifier les GHMs
                   pour lesquels le retour au régime habituel est structurellement improbable
  TRRSH_par_âge  = stratification < 60, 60-74, 75-84, ≥ 85 ans
  TRRSH_par_FINESS = comparaison intra-GHT
  Taux de sur-recours post-hospitalier : n_sur-recours / n_total × 100
    → signal d'une transition hôpital-ville mal coordonnée (doublement des consultations)

Étape 5 — Indicateurs dérivés :
  TRRSH_MT (médecin traitant seul) : appliquer la même formule uniquement aux actes
    des médecins généralistes (EXE_PRO_SPE = 01) — indicateur de continuité ville
  TRRSH_spe (spécialistes ambulatoires) : idem pour spécialistes
  Délai médian de retour à I₀ ± 20 % : nombre de jours médian pour retrouver la baseline
    (calculé sur les patients résilients — mesure de la vitesse de résilience)
```

**Cas limites :**
- Hospitalisation longue (> 30j) : la fenêtre pré peut chevaucher une précédente hospitalisation — exclure les actes des jours d'hospitalisation de la fenêtre pré
- Changement d'ALD ou nouveau diagnostic pendant l'hospitalisation : le régime habituel post-sortie peut légitimement être supérieur à I₀ ; pour ces patients, le sur-recours est approprié — l'analyse différenciée par GHM permet de les identifier (les GHMs de primo-décompensation auront structurellement un TRRSH faible)
- Patients hors SNDS ou régimes spéciaux incomplets : exclure et documenter la proportion d'exclus

## Utilité

- **Évaluer l'efficacité globale de la transition hôpital-ville** : un TRRSH < 50 % pour un GHM donné signale que la moitié des patients n'a pas retrouvé son régime de soins habituel — que ce soit par défaut de suivi (sous-recours) ou par surcharge de soins non coordonnée (sur-recours) — ce qui justifie une analyse de cause et la révision du protocole de sortie
- **Différencier sous-recours et sur-recours par GHM** : le taux de sur-recours élevé post-infarctus (patients multipliés en spécialistes) et le taux de sous-recours élevé post-fracture chez les personnes âgées révèlent des problématiques de coordination opposées, nécessitant des interventions différentes
- **Benchmarker les protocoles de sortie intra-GHT** : comparer le TRRSH par GHM entre établissements du GHT révèle les pratiques de sortie les plus efficaces — les établissements avec TRRSH élevé peuvent partager leurs protocoles de préparation de sortie
- **Cibler les patients à inclure dans les programmes de coordination post-hospitalière** : les patients avec un TRRSH prévisiblement faible (âge ≥ 80 ans, polypathologie, absence de médecin traitant déclaré) peuvent être identifiés à J0 de la sortie et bénéficier d'une intervention proactive (appel de coordination à J7, PRADO, DAC)
- **Mesurer l'impact de dispositifs de transition** : évaluer l'efficacité d'un infirmier de liaison de sortie, d'une hospitalisation post-urgences, ou d'un programme de télésurveillance par comparaison du TRRSH avant/après, sur les mêmes groupes de patients
- **Alerter sur les déserts médicaux du territoire** : le TRRSH ambulatoire bas dans certaines zones géographiques du GHT, non expliqué par le casemix, peut révéler des insuffisances d'offre de soins de ville — indicateur territorial au croisement de la santé publique et de la démographie médicale

## Sources de Données

- **SNDS — `ER_PRS_F`** : `EXE_SOI_DTD` (date de soin), `PRS_NAT_REF` (nature de la prestation), `BEN_NIR_PSA` (identifiant pseudonymisé), `EXE_PRO_SPE` (spécialité du prestataire) — extraction sur 9 mois par patient (J−180 à J+90)
- **SNDS — `IR_BEN_R`** : date de décès (`BEN_DCD_DTE`) pour exclure les patients décédés dans les 90j post-sortie
- **PMSI MCO — RSA** : `ENT_DAT`, `SOR_DAT`, `MODE_SORTIE`, racine GHM, CMD, `FINESS_GEO`, NIR pseudonymisé
- **SNDS — `IR_ALD_R`** : ALD actives pour stratification pathologique et pour identifier les changements d'ALD pendant l'hospitalisation (signalant une modification du régime habituel attendu)

## Exemple de Valeurs

| Contexte clinique | TRRSH attendu | Sous-recours (%) | Sur-recours (%) |
|---|---|---|---|
| Chirurgie programmée simple (< 60 ans) | 75 – 85 % | 5 – 10 % | 10 – 20 % |
| Décompensation cardiaque (ALD 5, 60-74 ans) | 45 – 60 % | 20 – 30 % | 15 – 25 % |
| AVC avec déficit (GHM 01C) | 30 – 50 % | 15 – 30 % | 20 – 35 % |
| Fracture du col du fémur (PA ≥ 80 ans) | 25 – 45 % | 30 – 45 % | 10 – 20 % |
| Exacerbation BPCO | 50 – 65 % | 20 – 30 % | 10 – 20 % |
| Cancer (primo-traitement) | 15 – 30 % | 5 – 10 % | 60 – 80 % (sur-recours attendu) |

**Seuils d'alerte GHT :**
- TRRSH_global < 50 % pour un GHM avec volume ≥ 100 séjours/an → revue du protocole de sortie requise
- Taux de sur-recours > 40 % → probable fragmentation de la coordination ambulatoire post-sortie

## Limites

- **Le TRRSH bas n'est pas toujours un signal négatif** : pour les primo-décompensations et les cancers incidents, l'intensité de soins post-hospitalisation est légitimement et nécessairement supérieure à la baseline — le sur-recours est ici un indicateur d'accès aux soins, non de désorganisation ; l'interprétation est toujours conditionnelle au contexte clinique du GHM
- **Seuil de 20 % de tolérance arbitraire** : ce seuil n'est pas validé par une étude clinique spécifique ; sa pertinence dépend de la variabilité naturelle intra-individuelle des soins, elle-même dépendante de la pathologie — une étude de calibration locale est recommandée à la mise en place
- **Dépendance aux 9 mois de données SNDS chaînées** : le calcul nécessite un historique SNDS de qualité sur 9 mois par patient ; les nouveaux arrivants sur le territoire, les patients ayant changé de régime d'assurance maladie, ou les patients avec des gaps de données sont exclus, créant un biais de sélection potentiel
- **Exclusion des patients décédés dans les 90j** : ces patients sont parmi les plus fragiles ; leur exclusion du dénominateur améliore artificiellement le TRRSH en retirant les cas les plus sévères — le taux de décès dans les 90j doit être présenté systématiquement en parallèle du TRRSH
- **Non-couverture des actes non remboursés** : les soins hors nomenclature (consultations privées hors SNDS, médecines complémentaires) ne sont pas visibles, sous-estimant le recours réel pour certaines populations et biaisant l'interprétation du sous-recours apparent

## Références

- [Holling C.S. — Resilience and stability of ecological systems, Annual Review of Ecology and Systematics 1973 : fondements théoriques de la résilience comme capacité de retour à l'équilibre après perturbation](https://doi.org/10.1146/annurev.es.04.110173.000245)
- [Bähler C. et al. — Multimorbidity, health care utilization and costs in an elderly community-dwelling population: a claims-based study, BMC Health Services Research 2015 : patterns de recours des populations multimorbides en ambulatoire](https://doi.org/10.1186/s12913-015-0698-2)
- [van Walraven C. et al. — Continuity of care and patient outcomes after hospital discharge, Journal of General Internal Medicine 2004 : lien entre continuité du suivi post-hospitalier et réhospitalisations](https://doi.org/10.1111/j.1525-1497.2004.30082.x)
- [Kripalani S. et al. — Deficits in communication and information transfer between hospital-based and primary care physicians, JAMA 2007 : déficits de coordination à la sortie d'hôpital et leurs conséquences](https://doi.org/10.1001/jama.297.8.831)
- [Tuppin P. et al. — Value of a national administrative database to guide public decisions: From the SNIIRAM to the SNDS in France, Revue d'Épidémiologie et de Santé Publique 2017](https://doi.org/10.1016/j.respe.2017.05.004)
- [HAS — Outils pour la sortie du patient hospitalisé (guide méthodologique PRADO, protocoles de liaison)](https://www.has-sante.fr/)
