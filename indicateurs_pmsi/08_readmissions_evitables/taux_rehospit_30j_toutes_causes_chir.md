# Taux de Réhospitalisation à 30 Jours Toutes Causes après Séjour Chirurgical

## Définition
Le **taux de réhospitalisation à 30 jours toutes causes après chirurgie** mesure la proportion de patients réadmis en hospitalisation complète dans les 30 jours suivant la sortie d'un séjour chirurgical index, **toutes causes confondues**. Il s'inspire directement du *30-day all-cause readmission rate* (CMS, États-Unis), adapté au contexte français par la HAS et l'ATIH dans le cadre du programme de visualisation des taux nationaux de réhospitalisations après chirurgie (publié sur le site HAS depuis 2022 et étendu en 2024 avec données 2021–2024).

L'indicateur capture à la fois les complications postopératoires précoces, les défauts de coordination à la sortie (transitions hôpital-domicile) et les insuffisances d'éducation thérapeutique. Il est pressenti comme **indicateur de résultat** pour l'IFAQ, en complément des indicateurs dédiés à la chirurgie ambulatoire (REH3-CA) déjà en vigueur.

Formule :

```
Taux RH30_brut = (séjours d'index chirurgicaux avec ≥1 réhospitalisation
                  en MCO dans les 30 jours suivant la sortie)
                 / (séjours d'index chirurgicaux éligibles)

Taux RH30_ajusté = standardisation indirecte par racine de GHM
                    (méthode ATIH : application du taux national observé par racine
                     au case-mix de l'établissement)
```

Positionnement vs indicateurs existants : différent du REH3-CA (réhospitalisation 1-3 jours après chirurgie ambulatoire ciblée par geste) et du RH30 ATIH (toutes hospitalisations, pas seulement chirurgicales). Il complète ces deux indicateurs en couvrant l'hospitalisation complète chirurgicale avec une fenêtre standard internationale (30 jours).

## Calcul

```
Étape 1 — Cohorte index
  Séjours MCO sortis dans la période d'analyse (typiquement année N-1)
  AVEC au moins 1 acte CCAM classé "chirurgical" (table OAP / table de
  classification interventionnelle ATIH des racines de GHM en C)
  → Identification : GHM avec lettre "C" en position 3 (= chirurgical)
  Exclusions :
    - Décès durant le séjour index (mode de sortie = 9)
    - Transfert direct (mode de sortie = 6 ou 7) → continuité, pas réhospit
    - Séjours obstétricaux (CMD 14)
    - Séances (CMD 28)
    - Mineurs < 18 ans pour la version adulte (selon spécification)

Étape 2 — Détection de la réhospitalisation
  Pour chaque séjour index :
    Chercher dans le PMSI un séjour ultérieur :
      - même patient (chaînage par n°anonyme PMSI/SNDS)
      - DATE_ENTREE ≤ DATE_SORTIE_index + 30 jours
      - en MCO, hospitalisation complète (mode hosp = 0 → non, exclusion ambu pure)
    Première réadmission seulement (1 par séjour index)
    Exclusion des réadmissions programmées : mode d'entrée = 7 (transfert) ou
      séjour avec DP de chimiothérapie/radiothérapie programmée (Z51.x),
      ou GHM séance.

Étape 3 — Calcul
  N = nb séjours index avec réadmission ≤ 30j
  D = nb séjours index éligibles
  Taux brut = N / D × 100

Étape 4 — Ajustement (standardisation indirecte ATIH)
  Pour chaque racine de GHM r :
    cas_attendus_r = effectif_etab_r × taux_national_r
  Cas attendus établissement = Σ_r cas_attendus_r
  Ratio standardisé = N_observé / N_attendu
  Restitution : ratio + IC 95% (Byar)
```

Variables PMSI clés : `ident`, `N°ANONYME` (chaînage inter-séjours), `DATE_ENTREE`, `DATE_SORTIE`, `modeentree`, `MODE_SORTIE`, `GHM`, `RACINE_GHM`, codes `CCAM`.

## Utilité
- **Pilotage qualité chirurgie GHT** : indicateur transversal couvrant toutes les disciplines chirurgicales ; complète les indicateurs spécialisés (ISO-ORTHO, REH3-CA).
- **Coordination de la sortie** : taux élevé → audit des sorties (lettre de liaison, programmation post-op, lien médecin traitant).
- **Préparation IFAQ futur** : la HAS a annoncé le développement d'indicateurs IFAQ basés sur la réhospitalisation post-chirurgicale.
- **Comparaison internationale** : aligné sur le CMS HRRP (Hospital Readmissions Reduction Program) américain.
- **Analyse par racine GHM** : drill-down pour identifier les filières à fort taux (chirurgie colorectale, chirurgie cardiaque, etc.).
- **Évaluation des programmes ERAS / RAAC** : suivi de l'impact des protocoles de récupération améliorée après chirurgie sur les réadmissions précoces.

## Sources de Données
- **PMSI MCO** : séjours chirurgicaux index, chaînage par n°anonyme pour détecter les réadmissions, GHM/CCAM pour identifier la nature chirurgicale.
- **SNDS** (recommandé) : chaînage exhaustif inter-établissements évitant les pertes pour les patients réadmis dans un autre hôpital.
- **Référentiel ATIH — Racines de GHM et fonction groupage** : classification chirurgicale officielle.
- **ScanSanté — RH30** : restitution publique des taux nationaux par racine de GHM (2021-2024).
- **Outils ATIH** : table de classification des actes (chirurgie / non-chirurgie), format PMSI MCO en vigueur.

## Exemple de Valeurs
*Source : HAS — Visualisation dynamique des taux nationaux de réhospitalisations après chirurgie (PMSI 2021-2024) ; ScanSanté RH30 2018.*

- **Taux RH30 toutes causes après chirurgie (national)** : ~7-9 % selon la définition (toutes chirurgies adultes confondues).
- **Plage par racine de GHM** : 3 % (chirurgie ambulatoire ophtalmo/ORL bénigne) à 20 % (chirurgie cardiaque complexe, chirurgie oncologique digestive).
- **Chirurgie colorectale** : 12-15 % à 30j (référence CMS et données françaises).
- **Chirurgie orthopédique élective (PTH/PTG)** : 5-8 %.
- **Chirurgie cardiaque** : 15-18 %.
- **Plage inter-établissement (ratio standardisé)** : 0,7 – 1,4 ; alerte si > 1,2 avec IC 95% > 1,0.
- **Volume cible minimal** : ≥ 200 séjours chirurgicaux/an pour stabilité.

## Limites
- **Réadmissions programmées difficiles à exclure** : ablation de matériel, reprise prévue (par exemple deuxième temps chirurgical) doivent être soigneusement filtrées sinon biais à la hausse.
- **Chaînage inter-établissements** : sans SNDS, les réadmissions hors GHT échappent à la mesure (sous-estimation 10-25%).
- **Case-mix résiduel** : la standardisation par racine GHM ne capture pas totalement les comorbidités ; des modèles logistiques avec Charlson sont préférables.
- **« Toutes causes » vs « causes liées »** : les réadmissions pour pathologies sans rapport avec la chirurgie index (AVC, AVP) sont incluses ; certains préfèrent des versions « causes potentiellement liées ».
- **Effet hôpital de proximité** : les CHU recevant des patients de niveau de gravité supérieur ont des taux brut plus élevés ; l'ajustement est essentiel.
- **Volume minimal** : pour les CH de proximité avec faible volume chirurgical, la précision est insuffisante.
- **Chirurgie ambulatoire** : à analyser séparément avec le REH3-CA HAS, plus pertinent que RH30 pour ces séjours courts.

## Références
- [HAS — Visualisation dynamique des taux nationaux de réhospitalisations après chirurgie](https://www.has-sante.fr/jcms/p_3776008/fr/visualisation-dynamique-des-taux-nationaux-de-rehospitalisations-apres-chirurgie)
- [HAS — IQSS REH3-CA : 6 indicateurs de réhospitalisations après chirurgie ambulatoire](https://www.has-sante.fr/jcms/c_2891438/fr/iqss-2020-reh3-ca-indicateurs-de-resultats-en-chirurgie-ambulatoire)
- [HAS — Comment réduire le risque de réhospitalisations évitables (2013)](https://www.has-sante.fr/upload/docs/application/pdf/2013-06/fiche_parcours_rehospitalisations_evitables_vf.pdf)
- [ATIH — ScanSanté : Les réhospitalisations à 30 jours (RH30)](https://www.scansante.fr/sites/default/files/content/396/vf_-_rh30_-_2018_03_20.pdf)
- [ATIH — Nouveaux indicateurs de coordination des soins](https://www.atih.sante.fr/actualites/nouveaux-indicateurs-de-coordination-des-soins)
- CMS Hospital Readmissions Reduction Program (HRRP) — Méthodologie de référence internationale.
