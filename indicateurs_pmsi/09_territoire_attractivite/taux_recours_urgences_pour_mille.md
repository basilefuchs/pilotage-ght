# Taux de Recours aux Urgences pour 1 000 Habitants (Standardisé)

## Définition

Le taux de recours aux urgences pour 1 000 habitants est le nombre de passages aux services d'accueil des urgences (SAU) rapporté à la population de la zone d'attraction de l'établissement, standardisé par âge et sexe sur la structure de la population nationale. Il constitue l'indicateur de référence de la DREES pour le suivi de la demande de soins non programmés à l'échelle territoriale.

TRU_std = (passages_SAU_observés / passages_SAU_attendus) × TRU_national_référence

où les passages attendus sont calculés par standardisation indirecte : application des taux nationaux de recours par tranche d'âge et sexe à la structure de la population locale. Le TRU national de référence est publié annuellement par la DREES (environ 320–360 passages pour 1 000 habitants, France entière).

Cet indicateur diffère du **taux de passage aux urgences suivi d'hospitalisation** (taux_passage_urgences_hospitalisation.md), qui mesure la proportion d'admissions depuis les urgences — information sur l'aval, non sur la demande populationnelle. Le TRU pour 1 000 mesure l'**intensité du recours** de la population à l'urgence, toutes issues confondues (retour à domicile, hospitalisation, fugue).

## Calcul

Sources : PMSI MCO UHCD/ATU (passages urgences) + SAE (capacités SAU) + INSEE (population) + zonage DREES (zones d'attraction).

```
Étape 1 — Dénombrement des passages urgences depuis le PMSI
  Population : tous les RSA MCO avec :
    - `modeentree` = 8 et `provenance` = 5 (entrée par les urgences)    OU
    - GHM en série 90Z* (consultations et passages non suivis d'hospitalisation) OU
    - UM de type UHCD (unité d'hospitalisation de courte durée) + durée = 0 ou 1 jour
  Exclure : transferts inter-établissements, accouchements, dialyses récurrentes
  Période : 1 an calendaire

Étape 2 — Attribution à la zone d'attraction
  Utiliser le code géographique de résidence du patient (CP résidence RSA)
  Croiser avec le zonage DREES "zones d'attraction des équipements de santé"
    (ou ZAE — zones d'accessibilité et d'équipement, INSEE)
  Agréger les passages par zone d'attraction de l'établissement

Étape 3 — Taux brut de recours
  TRU_brut = (nb_passages / pop_zone_attraction) × 1 000
  Source population : recensement INSEE, millésime N-1

Étape 4 — Standardisation indirecte par âge et sexe
  Pour chaque strate (tranche_age × sexe) :
    passages_attendus_strate = pop_locale_strate × TRU_national_strate
  Total attendu = Σ(passages_attendus_strate)
  ISR (Indice Standardisé de Recours) = nb_passages_observés / total_attendu
  TRU_std = ISR × TRU_national_tous_âges

  Tranches d'âge recommandées (DREES) :
    0-4, 5-14, 15-24, 25-44, 45-64, 65-74, 75-84, 85+

Étape 5 — Intervalle de confiance (méthode Byar)
  IC95% sur TRU_std pour tester l'écart à la moyenne nationale
  Seuil d'alerte : IC95% excluant le TRU national de référence
```

Indicateurs dérivés :

```
Ratio d'attractivité urgences :
  R_att = passages de patients hors zone_attraction / total_passages
  → Part de la demande externe captée (attractivité urgences vs concurrence)

Taux de recours nocturne (22h-8h) :
  TRU_nuit = passages entre 22h et 8h / total_passages
  → Proxy de la densité médicale nocturne en ville (médecine de garde)

Taux de recours urgences pediatriques :
  TRU_0-15 = passages enfants / pop_0-15_zone × 1 000
  → Indicateur DREES tableau de bord périnatalité et pédiatrie
```

## Utilité

- **Détecter les territoires en tension sur la demande non programmée** : un TRU_std > 420 pour 1 000 signale une surdemande urgentiste qu'un seul SAU peut difficilement absorber — argument pour des investissements en médecine de ville (CPTS, MSP) ou pour une révision de la permanence des soins ambulatoires (PDSA) en lien avec l'ARS.
- **Dimensionner les ressources du SAU** : projeter la croissance du TRU par tranche d'âge (vieillissement de la population de la zone d'attraction) permet d'anticiper les besoins en lits UHCD, en personnels soignants et en plateaux techniques à 5–10 ans dans le cadre du projet médical de GHT.
- **Évaluer l'impact des dispositifs alternatifs aux urgences** : comparer le TRU avant/après l'ouverture d'une Maison de Santé Pluriprofessionnelle ou d'un Service d'Accès aux Soins (SAS) mesure l'effet de délestage réel sur les urgences hospitalières.
- **Benchmark territorial pour le SROS/PRS** : le TRU standardisé permet de comparer les établissements du GHT en neutralisant les effets de structure d'âge, identifiant les SAU sous-dotés en ressources par rapport à leur charge populationnelle réelle.
- **Suivre les inégalités territoriales de recours** : l'écart du TRU entre communes rurales et urbaines de la zone d'attraction révèle les déserts médicaux où l'urgence joue le rôle de médecin de premier recours par défaut.

## Sources de Données

- **PMSI MCO RSA** : mode d'entrée (champ MODE_ENT), code résidence patient (CP résidence), UM type (UHCD), date et heure d'entrée
- **SAE (Statistique Annuelle des Établissements)** : nombre de passages urgences déclarés par le SAU — source de contrôle et de validation du dénombrement PMSI
- **INSEE — Recensement de la population** : population par commune, tranche d'âge, sexe (millésime annuel)
- **DREES — Zonage des zones d'attraction** : délimitation des bassins de recours hospitalier (publiée avec le tableau de bord des urgences DREES, mise à jour régulière)
- **DREES — Tableau de bord des urgences** : taux nationaux de référence par tranche d'âge et sexe pour la standardisation indirecte

## Exemple de Valeurs

- **France entière** : TRU ≈ 330–360 passages pour 1 000 habitants (2019, hors COVID)
- **Zone urbaine dense (Île-de-France)** : TRU brut ≈ 400–500 (accès facilité, offre ambulatoire parfois saturée)
- **Zone rurale isolée** : TRU brut ≈ 200–280 (barrière d'accès géographique ; recours moindre mais aussi moins d'offre)
- **ISR > 1,30** : surrecours significatif (zone sous-dotée en médecine ambulatoire de premier recours)
- **ISR < 0,70** : sous-recours (zone bien dotée en alternatives ou avec barrière d'accès physique)
- **TRU pédiatrique (0–15 ans)** : ≈ 450–550 pour 1 000 enfants en France (recours plus élevé chez les jeunes enfants)
- **Seuil minimal** : ≥ 20 000 habitants dans la zone d'attraction pour une estimation stable du TRU standardisé

## Limites

- **Doublon SAE/PMSI** : le nombre de passages enregistrés en PMSI (RSA) peut sous-estimer le flux SAE si certains passages courts ne génèrent pas de RSA (passages sans acte ni diagnostic facturables) ; la SAE reste la source de référence pour le volume total de passages.
- **Délimitation de la zone d'attraction** : la zone d'attraction DREES est définie à partir des flux de soins historiques et peut ne pas refléter les changements récents d'offre (ouverture d'un SAU concurrent, fermeture d'un SAU proche) — révision recommandée tous les 5 ans.
- **Hétérogénéité de codage entre établissements** : les pratiques de codage de l'entrée par les urgences (`modeentree` 8 + `provenance` 5) varient selon les établissements du GHT, pouvant créer des artefacts dans les comparaisons internes.
- **Non-couverture des urgences libérales** : les consultations non programmées chez les médecins généralistes et SOS Médecins ne sont pas incluses dans le TRU PMSI — le taux mesure la pression sur le système hospitalier, pas la demande totale de soins non programmés.
- **Effets COVID** : les TRU 2020–2021 sont non comparables aux autres années sans correction (baisse de 20–30% des passages en 2020).

## Références

- [DREES — Les urgences hospitalières, une fréquentation toujours croissante, Études et Résultats n°1074, 2019](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/etudes-et-resultats/241212_ER_passages-aux-urgences)
- [DREES — Tableau de bord des urgences hospitalières (éditions annuelles)](https://drees.solidarites-sante.gouv.fr/sources-outils-et-enquetes/enquete-urgences-2023)
- [Coldefy M., Nestrigue C. — L'activité des urgences hospitalières en 2013, DREES Études et Résultats n°910, 2015](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH — Guide méthodologique de production des données du PMSI MCO (version en vigueur)](https://www.atih.sante.fr/)
- [Mousquès J., Bourgueil Y. — Impact des maisons de santé pluriprofessionnelles sur le recours aux urgences, IRDES Questions d'économie de la santé, 2018](https://www.irdes.fr/)
