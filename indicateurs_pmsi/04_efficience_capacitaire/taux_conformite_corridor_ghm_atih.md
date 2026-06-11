# Taux de Conformité au Corridor de Durée GHM ATIH

## Définition

Pour chaque GHM (Groupe Homogène de Malades), l'ATIH définit dans sa grille tarifaire deux **bornes de durée** :

- **Borne basse** (B_inf) : durée minimale en dessous de laquelle le séjour est considéré «très court» et fait l'objet d'une minoration tarifaire (ticket modérateur inversé, ou facturation au prorata pour les GHMs sans niveau ambulatoire)
- **Borne haute** (B_sup) : durée maximale au-delà de laquelle le séjour est considéré «très long» et fait l'objet d'un supplément tarifaire journalier («J» en sus du GHS)

Le **corridor de durée** est l'intervalle [B_inf, B_sup] dans lequel la majorité des séjours d'un GHM est attendue selon les données nationales ATIH. Le taux de conformité au corridor mesure :

```
Taux_corridor = nb_RSA | B_inf ≤ DMS_RSA ≤ B_sup / nb_RSA_eligible × 100
```

Cet indicateur apporte une information structurellement différente des indicateurs DMS existants :
- L'`ip_dms_indice_performance_dms` compare la **DMS moyenne** à la référence nationale — un établissement peut avoir une DMS moyenne conforme (IP-DMS ≈ 1) tout en ayant une forte **dispersion bimodale** (nombreux séjours très courts + nombreux séjours très longs se compensant dans la moyenne)
- Le `taux_journees_borne_haute` ne mesure que le dépassement supérieur
- Le taux de conformité au corridor capture les **deux queues de distribution simultanément**, révélant la dispersion autour de la norme ATIH

Un faible taux de conformité est le signal d'une **hétérogénéité des pratiques** au sein d'un même GHM — certains patients sortent trop tôt (risque de réadmission précoce), d'autres restent trop longtemps (inefficience ou complexité non capturée par le groupage).

## Calcul

Sources : PMSI MCO RSA + fichier des bornes GHM ATIH (grille tarifaire).

```
Population : tous RSA MCO pour un FINESS/période, hors GHMs sans bornes définies

Étape 1 — Chargement des bornes GHM ATIH :
  Fichier ATIH : grille tarifaire annuelle (ex : "tarifs_GHS_MCO_AAAA.csv")
    Variables : GHM (8 caractères), BORNE_BASSE (jours), BORNE_HAUTE (jours)

  GHMs sans bornes à exclure du dénominateur :
    - GHMs en mode ambulatoire pur (DUREE = 0 autorisée, pas de borne significative)
    - GHMs de séances (CMD 28) — durée = 0 par définition
    - GHMs sans borne définie dans la grille (BORNE_BASSE = NA ou BORNE_HAUTE = NA)

Étape 2 — Calcul de la durée de chaque RSA :
  DUREE_RSA = DATE_SORTIE − DATE_ENTREE   [en jours entiers]
  Convention PMSI : séjour de 0 jour (entrée et sortie le même jour) = DUREE = 0
  Source variable PMSI : champ DUREE directement disponible dans le RSA MCO

Étape 3 — Jointure RSA × bornes GHM :
  Pour chaque RSA :
    B_inf = BORNE_BASSE du GHM_RSA (grille ATIH de l'année de sortie)
    B_sup = BORNE_HAUTE du GHM_RSA

  Catégorisation :
    Infra-borne  : DUREE_RSA < B_inf
    Dans corridor: B_inf ≤ DUREE_RSA ≤ B_sup    ← conformes
    Supra-borne  : DUREE_RSA > B_sup

Étape 4 — Calcul du taux de conformité :
  nb_RSA_eligible = count(RSA | GHM avec bornes définies)
  nb_RSA_corridor = count(RSA | B_inf ≤ DUREE_RSA ≤ B_sup)
  nb_RSA_infra    = count(RSA | DUREE_RSA < B_inf)
  nb_RSA_supra    = count(RSA | DUREE_RSA > B_sup)

  Taux_corridor  = nb_RSA_corridor / nb_RSA_eligible × 100
  Taux_infra     = nb_RSA_infra    / nb_RSA_eligible × 100
  Taux_supra     = nb_RSA_supra    / nb_RSA_eligible × 100

  Contrôle : Taux_corridor + Taux_infra + Taux_supra = 100%

Étape 5 — Ventilation par GHM (top 20 GHMs par volume) :
  Taux_corridor_GHM = nb_RSA_corridor_GHM / nb_RSA_eligible_GHM × 100
  → identifier les GHMs à faible conformité (Taux_corridor < 50%)
    qui concentrent les pratiques les plus hétérogènes

Étape 6 — Score d'efficience corridor :
  Score_efficience = Taux_corridor − Taux_supra
  > 0 : plus de séjours dans le corridor que hors borne haute
  Interprétation : pénalise davantage les séjours trop longs que les séjours trop courts

Cas limites :
  - DUREE = 0 avec B_inf = 0 : séjour dans le corridor (ambulatoire conforme)
  - DUREE = 0 avec B_inf > 0 : séjour infra-borne
    → vérifier si le GHM est effectivement en mode ambulatoire dans la grille
  - GHM avec B_inf = B_sup = 0 : exclure du dénominateur
  - Grille tarifaire annuelle : utiliser la grille de l'année de sortie du séjour
    (les bornes peuvent être révisées chaque année)
```

Indicateurs dérivés :

```
Indice de dispersion des durées par GHM :
  IDD_GHM = (nb_RSA_infra + nb_RSA_supra) / nb_RSA_eligible × 100
  = 100 − Taux_corridor
  → mesure directe de l'hétérogénéité des pratiques sur ce GHM

Déséquilibre infra/supra :
  Ratio_déséquilibre = nb_RSA_infra / nb_RSA_supra
  > 1 : dominance de sorties précoces (risque qualité : sortie avant stabilisation)
  < 1 : dominance de séjours longs (risque efficience : prolongation non justifiée)

Taux de conformité au corridor par UM (unité médicale) :
  → localise les pratiques hétérogènes à l'intérieur de l'établissement
  → permet le benchmarking entre praticiens sur un même GHM (non nominatif,
    agrégé par UM)

Recette marginale des séjours supra-borne :
  = Σ(nb_jours_supra_borne × tarif_journalier_J_ATIH) par GHM
  → quantification financière des prolongations (recette supplémentaire perçue)
    à mettre en regard du coût réel de la journée
```

## Utilité

- **Détection de la bimodalité invisible dans la DMS moyenne** : un GHM de chirurgie programmée avec IP-DMS = 1,00 et Taux_corridor = 55% révèle que 45% des séjours sont hors norme (20% très courts + 25% très longs) — signal d'hétérogénéité des pratiques entre chirurgiens ou entre créneaux d'hospitalisation (semaine vs vendredi)
- **Ciblage des GHMs prioritaires pour les protocoles de sortie** : les GHMs avec Taux_corridor < 60% ET Ratio_déséquilibre > 2 (dominance de sorties précoces) sont les candidats prioritaires à un programme «sortie à J+1» structuré (appel infirmier, consultation J+7) pour éviter les réadmissions précoces
- **Benchmarking ATIH équitable inter-établissements** : le Taux_corridor est indépendant du volume de séjours et neutralise les effets de casemix au sein d'un même GHM — deux établissements peuvent être comparés directement sur leur «discipline de durée» pour chaque GHM commun
- **Pilotage des médecins coordinateurs de sortie** : le Taux_corridor par UM est la métrique opérationnelle la plus concrète pour les médecins coordinateurs — «sur ce GHM, 30% de nos patients restent plus longtemps que la borne haute ATIH» est un message actionnable là où l'IP-DMS reste abstrait pour les cliniciens
- **Anticipation des révisions tarifaires ATIH** : quand ATIH révise les bornes d'un GHM (modification de la borne haute vers le bas), les établissements dont le Taux_supra sur ce GHM est élevé subiront une minoration tarifaire — mesurer le Taux_supra par GHM avant la publication des grilles permet d'anticiper l'impact financier
- **Argument qualité dans les CPOM** : un Taux_corridor > 85% sur les GHMs de chirurgie ambulatoire ciblés par l'Agence est un indicateur de maturité de la filière ambulatoire — documentable dans les annexes qualité des CPOM

## Sources de Données

- **PMSI MCO RSA** : variable `GHM` (8 caractères), `DUREE` (durée de séjour en jours, directement disponible dans le RSA MCO), `NOFINESS`, `DATE_SORTIE` — extraction trimestrielle ou annuelle
- **Grilles tarifaires ATIH** : fichiers CSV/XLS publiés annuellement (ex : «tarifs_MCO_exDGF_AAAA.xlsx») — variables `GHM`, `BORNE_BASSE`, `BORNE_HAUTE`, `TARIF_JOURNALIER_EXH` — téléchargeables sur le site ATIH, rubriques «tarification MCO» — les bornes sont définies pour chaque GHM à 8 caractères

## Exemple de Valeurs

- **Chirurgie ambulatoire (GHMs ambulatoires) — CHU** : Taux_corridor = 82–92% (B_inf = B_sup = 0 pour les GHMs ambulatoires purs — taux de conformité = taux de réalisation en ambulatoire)
- **Orthopédie programmée (PTH, PTG) — CH** : Taux_corridor = 65–80% ; Taux_supra typique = 15–25% (prolongations post-opératoires)
- **Médecine interne (GHMs polyvalents) — CHU** : Taux_corridor = 55–70% (forte hétérogénéité des pathologies dans un même GHM)
- **Obstétrique (accouchements) — Maternité** : Taux_corridor = 75–88% (protocoles standardisés → conformité élevée)
- **Seuil d'alerte** : Taux_corridor < 50% sur un GHM représentant > 200 séjours/an → audit des pratiques sur ce GHM prioritaire
- **Taux_supra d'alerte** : > 30% sur un GHM chirurgical → investiguer les causes de prolongation (complications, sorties difficiles, aval saturé)

## Limites

- **Bornes révisées annuellement** : les bornes ATIH sont mises à jour chaque année — une amélioration du Taux_corridor peut masquer un assouplissement des bornes plutôt qu'une amélioration réelle des pratiques ; toujours vérifier si les bornes ont changé avant d'interpréter une tendance
- **Bornes non définies pour tous les GHMs** : les GHMs de séances (CMD 28), d'ambulatoire pur et certains GHMs de surveillance courte n'ont pas de bornes significatives — leur exclusion du dénominateur est impérative mais réduit le périmètre de l'indicateur pour les établissements très ambulatoires
- **Hétérogénéité intra-GHM non capturée** : les bornes ATIH sont définies sur la moyenne nationale ; pour les GHMs à forte variabilité de casemix (ex : certains GHMs de médecine interne qui regroupent des pathologies très différentes), la borne est peu informative et le Taux_corridor peu interprétable
- **Confondant de l'aval** : un Taux_supra élevé peut refléter une saturation de l'aval (places SSR insuffisantes, retour à domicile impossible) plutôt qu'une inefficience de l'hospitalisation — l'indicateur doit toujours être croisé avec le `taux_bed_blocking_mco_attente_ssr` pour distinguer les deux causes
- **Non-applicable aux GHMs mono-journée** : les GHMs d'hôpital de jour avec B_inf = B_sup = 0 ont un Taux_corridor = 100% par construction dès lors que DUREE = 0 — ils ne discriminent pas la qualité des pratiques

## Références

- [ATIH — Grilles tarifaires MCO ex-DGF et ex-OQN, publiées annuellement : définition des bornes basse et haute par GHM](https://www.atih.sante.fr/)
- [ATIH — Manuel des GHMs : méthodologie de calcul des bornes de durée de séjour à partir des données nationales](https://www.atih.sante.fr/)
- [Ministère de la Santé — Arrêtés tarifaires annuels (Journal Officiel) : grilles tarifaires GHS avec bornes haute et basse]
- [DREES — Études sur la durée de séjour hospitalier et ses déterminants : variabilité inter-établissements et impact des organisations de sortie]
- [Busse R. et al. — Diagnosis-related groups in Europe: moving towards transparency, efficiency and quality in hospitals, WHO 2011 : comparaison internationale des systèmes de corridor de durée dans les DRG](https://eurohealthobservatory.who.int/publications/m/diagnosis-related-groups-in-europe)
