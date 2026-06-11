# Écart Prévalence ALD Hospitalisée vs Attendue (Indice de Recours Hospitalier des Patients Chroniques)

## Définition

L'écart de prévalence ALD hospitalisée est le rapport entre la proportion de séjours MCO concernant des patients en Affection de Longue Durée (ALD) et la prévalence des ALD attendue dans la population de la zone d'attraction, estimée à partir des données CNAM publiées annuellement. Il mesure si l'hôpital prend en charge ses patients chroniques proportionnellement à leur représentation dans le territoire, ou si un différentiel de recours hospitalier existe.

IPRA = (taux_séjours_ALD_établissement / prévalence_ALD_territoire) × 100

- **IPRA = 100** : recours hospitalier des ALD proportionnel à la prévalence territoriale
- **IPRA > 100** : surrecours (les patients chroniques viennent davantage qu'attendu → possible manque de coordination ville-hôpital ou d'alternatives ambulatoires)
- **IPRA < 100** : sous-recours (les patients chroniques sont sous-hospitalisés → possible barrière d'accès, recours à d'autres établissements, ou bonne prise en charge ambulatoire)

Cet indicateur se distingue du **taux d'ALD suivi minimal garanti** (taux_ald_suivi_minimal_garanti.md), qui mesure le suivi post-hospitalier des patients ALD déjà hospitalisés. L'IPRA mesure en amont si les patients ALD du territoire arrivent ou non à l'hôpital — information sur la **coordination ville-hôpital et l'accès aux soins hospitaliers des patients chroniques**.

## Calcul

Sources : PMSI MCO RSA + SNDS/DCIR (ALD flag) + données CNAM "Charges et produits" (prévalences ALD territoriales).

```
Étape 1 — Identification des séjours de patients ALD dans le PMSI
  Méthode A (couplage PMSI-SNDS — gold standard) :
    Coupler RSA (NIR pseudonymisé) avec table ALD DCIR
    Identifier les patients avec exonération ALD active (codeTT = 41, 43 dans DCIR)
    ALD_flag = 1 pour tout séjour d'un patient avec ALD active à la date d'entrée

  Méthode B (proxy algorithmique CIM-10 — sans couplage) :
    Appliquer la liste des codes CIM-10 traceurs des 30 ALD (HAS/CNAM)
    Exemples :
      ALD 1  (cardiopathies congenitales) : Q20.x, Q21.x
      ALD 3  (insuffisance cardiaque grave) : I50.x en DP ou DR
      ALD 8  (diabète) : E10.x, E11.x en DP
      ALD 14 (hépatite chronique) : K72.x, K73.x, K74.x
      ALD 23 (leucémies) : C91.x, C92.x
      ALD 30 (tuberculose) : A15.x à A19.x
    Tag ALD_proxy = 1 si au moins un code CIM-10 de la liste est présent (DP, DR, ou DA)

Étape 2 — Calcul du taux de séjours ALD de l'établissement
  Inclure tous les séjours MCO hors obstétrique et néonatologie
  taux_séjours_ALD = nb_RSA avec ALD_flag = 1 / nb_RSA_total × 100

Étape 3 — Prévalence ALD attendue dans la zone d'attraction
  Source : CNAM "Charges et produits" — statistiques régionales ALD
    Prévalence ALD = nb_patients_ALD_actifs / pop_totale × 100
    Disponible par département, tranche d'âge, type d'ALD
  Pondérer par la structure de la zone d'attraction de l'établissement (codes postaux résidence des patients)

Étape 4 — Calcul de l'IPRA
  IPRA = (taux_séjours_ALD / prévalence_ALD_territoire) × 100
  IC95% par bootstrap (10 000 réplications) sur le taux de séjours ALD

Étape 5 — Stratification par type d'ALD
  Calculer l'IPRA pour chaque ALD (ou groupe d'ALD) :
    IPRA_cardiovasculaire, IPRA_cancers, IPRA_diabète, IPRA_psychiatrique
  → Identifier les filières chroniques où le recours hospitalier local est atypique
```

Indicateurs dérivés :

```
IPRA ajusté par âge (standardisation indirecte) :
  Appliquer les taux de référence nationaux d'hospitalisation par tranche d'âge et type d'ALD
  → Neutraliser l'effet de vieillissement différentiel de la population

Indice de fidélisation ALD :
  patients_ALD_ayant_eu_≥2_séjours_dans_établissement / patients_ALD_total_hospitalisés
  → Mesure si les patients chroniques reviennent dans le même établissement (continuité)
```

## Utilité

- **Détecter les filières chroniques où l'hôpital est contourné** : un IPRA_diabète = 65 dans un CH général signale que les patients diabétiques du territoire hospitalisent préférentiellement ailleurs ou évitent l'hôpital — signal pour identifier si la filière endocrinologie est attractive et si les soins de ville sont bien structurés ou au contraire défaillants.
- **Identifier les poches de surrecours hospitalier des patients chroniques** : un IPRA > 140 pour les insuffisants cardiaques signale que les patients ALD cardiaques viennent davantage qu'attendu, possiblement faute d'alternatives ambulatoires (HDJ insuffisance cardiaque, infirmières coordinatrices) — argument pour le développement de programmes de soins intégrés (ex. programme PRADO insuffisance cardiaque).
- **Alimenter le diagnostic partagé du Projet Médical de GHT** : l'IPRA par type d'ALD cartographie les filières chroniques où le GHT est fort ou faible sur son territoire, informant les décisions d'organisation (développement d'une HDJ insuffisance rénale chronique, renforcement de la filière oncologique).
- **Suivre l'impact des dispositifs d'appui à la coordination (DAC)** : un programme de coordination ville-hôpital ciblant les patients ALD doit se traduire par une stabilisation ou une baisse de l'IPRA des ALD ciblées (moins d'hospitalisations non programmées) — indicateur de résultat pour l'évaluation des DAC.
- **Préparer les négociations CPOM ARS** : l'IPRA démontre à l'ARS le positionnement de l'établissement face aux besoins de santé chroniques du territoire, argument pour des dotations MIGAC liées à la coordination ou pour des autorisations d'activité en soins de suite spécialisés.

## Sources de Données

- **PMSI MCO RSA** : codes CIM-10 (DP, DR, DA), identifiant patient (NIR pseudonymisé ATIH), FINESS, code de résidence patient
- **SNDS/DCIR** : table des ALD actives (NUM_ENQ, codeTT, date début/fin ALD) — nécessaire pour la méthode A (couplage direct) ; accès via CASD ou portail SNDS
- **CNAM — Rapport "Charges et produits"** : prévalence des ALD par département, tranche d'âge et type d'ALD — publié annuellement (données N-1)
- **DREES — Cartographie des pathologies** : source alternative pour la prévalence chronique attendue si les données CNAM ne sont pas accessibles au niveau infra-départemental

## Exemple de Valeurs

- **IPRA moyen national** : 100 par construction (indicateur normalisé)
- **CH général en zone rurale** : IPRA ≈ 80–95 (une partie des patients ALD se soignent dans les CHU environnants)
- **CHU avec large zone d'attraction** : IPRA ≈ 105–120 (attractivité régionale pour les cas complexes)
- **Établissement spécialisé oncologie** : IPRA_cancers ≈ 150–200 (concentration des ALD oncologiques), IPRA_diabète ≈ 40–60
- **IPRA insuffisance cardiaque dans un territoire sans HDJ cardiaque** : ≈ 130–160 (surrecours aux urgences faute d'alternative ambulatoire)
- **Seuil d'alerte surrecours** : IPRA > 130 (IC95% excluant 100) → investigation de la filière
- **Seuil d'alerte sous-recours** : IPRA < 70 (IC95% excluant 100) → patients chroniques captés par la concurrence ou non hospitalisés
- **Seuil minimal** : ≥ 500 séjours ALD sur la période pour un IPRA stable

## Limites

- **Couplage PMSI-SNDS requis pour la méthode A** : l'accès aux données SNDS (NIR, table ALD DCIR) est soumis à autorisation CNIL et n'est pas disponible directement pour tous les établissements ; la méthode proxy (CIM-10) sous-estime les ALD dont les pathologies sont peu codées en PMSI (ex. ALD psychiatriques, HTA sans complication).
- **Prévalence ALD territoriale non disponible au niveau infra-départemental** : les données CNAM "Charges et produits" sont publiées au niveau départemental ; pour les GHTs dont la zone d'attraction recoupe plusieurs départements, une interpolation géographique est nécessaire, source d'imprécision.
- **Hétérogénéité de la définition de la zone d'attraction** : l'IPRA est très sensible à la délimitation de la zone d'attraction (codes postaux des patients) — une zone trop large inclut des patients qui ne seraient jamais hospitalisés localement, gonflant artificiellement l'IPRA.
- **Instabilité pour les ALD rares** : les ALD à faible prévalence (< 0,5% de la population) génèrent des IPRA très instables avec des IC95% larges — recommander une agrégation en groupes (ex. ALD cardiovasculaires) pour les établissements de taille moyenne.
- **Effet de codage des DA** : la méthode proxy sous-estime les ALD si les codeurs ne documentent pas systématiquement les pathologies chroniques en diagnostics associés — biais différentiel entre établissements selon leur culture de codage.

## Références

- [CNAM — Rapport "Charges et produits" (annuel) — Statistiques des affections de longue durée](https://www.assurance-maladie.ameli.fr/etudes-et-donnees)
- [DREES-CNAM — Cartographie des pathologies et des dépenses — Méthodes et résultats, 2019](https://www.assurance-maladie.ameli.fr/etudes-et-donnees/par-theme/pathologies/cartographie-assurance-maladie)
- [Nolte E., McKee M. — Caring for people with chronic conditions: a health system perspective, Open University Press / WHO 2008](https://eurohealthobservatory.who.int/publications/m/caring-for-people-with-chronic-conditions-a-health-system-perspective)
- [IRDES — Parcours de soins des patients en affection de longue durée, Questions d'économie de la santé, 2017](https://www.irdes.fr/)
- [HAS — Liste des ALD et critères médicaux d'admission (30 ALD + ALD hors liste)](https://www.has-sante.fr/jcms/c_1752130/fr/les-affections-de-longue-duree)
- [ATIH — Guide méthodologique de production des données du PMSI MCO (version en vigueur)](https://www.atih.sante.fr/)
