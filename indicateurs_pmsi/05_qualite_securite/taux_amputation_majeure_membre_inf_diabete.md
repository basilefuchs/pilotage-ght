# Taux d'Amputation Majeure du Membre Inférieur chez le Patient Diabétique

## Définition
Le **taux d'amputation majeure du membre inférieur chez les patients diabétiques** mesure le nombre d'amputations majeures (proximales : transtibiale, transfémorale, désarticulation) réalisées chez des patients atteints de diabète, rapporté à la population adulte d'un territoire pour 100 000 habitants. C'est un **indicateur OCDE HCQO** classé dans les *long-term diabetes complications* et considéré comme un **traceur de la qualité du suivi en soins primaires** : prévention du pied diabétique, dépistage neuropathique et artériopathique, prise en charge précoce des plaies.

Formule :

```
Taux Amputation_Diabète = (RSA avec acte CCAM amputation majeure MI
                           ET DA/DR/DP diabète E10-E14, chez résidents ≥15 ans)
                          / population résidente ≥15 ans
                          × 100 000

Taux ajusté = standardisation directe sur structure d'âge × sexe
              de la population européenne standard (OCDE)
```

Positionnement vs indicateurs existants : différent du composite ACSC (`taux_hospit_potentiellement_evitables_acsc.md`) qui inclut les hospitalisations pour décompensation aiguë du diabète. Cet indicateur capture spécifiquement l'**aboutissement extrême** d'un mauvais suivi chronique du diabète, marqueur d'iceberg pour les défaillances en amont.

## Calcul

```
Étape 1 — Identification des amputations majeures
  RSA avec ≥1 acte CCAM dans la liste :
    NZFA002  Amputation transmétatarsienne (= mineure, EXCLUE pour version "majeure")
    NZFA003  Désarticulation tarso-métatarsienne (Lisfranc) (EXCLUE)
    NZFA004  Amputation transtibiale (jambe) - MAJEURE
    NZFA006  Désarticulation du genou - MAJEURE
    NZFA008  Amputation transfémorale (cuisse) - MAJEURE
    NZFA00A  Désarticulation de hanche - MAJEURE
  Définition OCDE : amputation au-dessus de la cheville = majeure

Étape 2 — Confirmation du contexte diabète
  Présence dans le RSA de :
    DP, DR ou DA dans E10–E14 (diabète sucré, tous types)
    OU
    Antériorité documentée de diabète dans les RSA des 24 derniers mois
    (chaînage SNDS recommandé)

Étape 3 — Périmètre populationnel
  Numérateur :
    Patients distincts (1 amputation par patient et par an) résidant
    sur le territoire (CODGEO) avec amputation majeure ET diabète
  Dénominateur :
    Population résidente ≥ 15 ans du territoire (INSEE)

Étape 4 — Calcul
  Taux brut = (N / D) × 100 000
  Taux ajusté = standardisation directe par âge × sexe sur population
                de référence européenne (OCDE 2013 standard) ou
                Esp2013 (Eurostat)

Étape 5 — Stratifications
  - Par classe d'âge (15-44, 45-64, 65-74, ≥75)
  - Par sexe (forte sur-incidence masculine connue)
  - Par territoire (CODGEO résidence)
  - Par niveau d'amputation (transtibiale vs transfémorale)
  - Évolution temporelle annuelle
```

Variables PMSI clés : `DP`, `DR`, `DA`, codes `CCAM` (table A — actes), `N°ANONYME` (chaînage), `CODGEO` (résidence), `AGE_ANNEES`, `SEXE`. Données INSEE pour population résidente.

## Utilité
- **Marqueur traceur OCDE** : indicateur officiel HCQO long-term diabetes complications, comparable internationalement.
- **Évaluation du parcours diabète** : un taux élevé signe une faillite cumulée (suivi médecin traitant + endocrino + podologie + chirurgie vasculaire).
- **Pilotage GHT diabète** : intégration au programme territorial diabète (DGOS, ARS), mesure de l'impact des consultations dédiées de pied diabétique.
- **Identification des inégalités** : taux fortement corrélé à la précarité socio-économique → cible des actions territoriales.
- **Plan ETP (éducation thérapeutique)** : outil d'évaluation des programmes ETP diabète.
- **Comparaison OCDE** : positionnement de la France versus pays comparables (Allemagne, UK).
- **Indicateur de qualité ville-hôpital** : argumentaire pour structuration de filières pied diabétique (centre de référence MPR, infirmier ETP, pédicure).
- **Suivi épidémiologique** : indicateur composite intégrable aux tableaux de bord ARS.

## Sources de Données
- **PMSI MCO** : RSA, codes CCAM amputation, DP/DR/DA E10-E14.
- **SNDS** (recommandé) : chaînage longitudinal pour identification du diabète antérieur (CMU/ALD diabète, codes ATC antidiabétiques A10).
- **Référentiel CCAM** (mise à jour annuelle ATIH) : actes d'amputation MI.
- **Référentiel CIM-10 FR** : codes E10-E14.
- **INSEE** : population résidente par sexe, âge, territoire.
- **OCDE — HCQO Definitions** : méthodologie de référence.
- **Santé publique France** : surveillance épidémiologique du diabète et complications.

## Exemple de Valeurs
*Sources : OCDE Health at a Glance 2023 et 2025, Santé publique France BEH diabète, études Fosse-Edorh et al.*

- **Taux France amputation majeure MI / diabétiques** : ~15-18 / 100 000 adultes (toute population).
- **Restreint aux personnes diabétiques (numérateur seul)** : ~250-300 / 100 000 diabétiques/an.
- **Moyenne OCDE** : ~6-15 / 100 000 adultes selon le périmètre méthodologique.
- **Pays nordiques** : 5-8 / 100 000 (très bonne performance).
- **Pays sud-OCDE / France** : 12-18 / 100 000.
- **Plage par département France** : 10 – 30 / 100 000, fort gradient territorial.
- **Hommes** : taux 2-3 fois supérieur aux femmes.
- **Cible OCDE implicite** : -30 % à 10 ans dans les pays engagés sur les programmes nationaux pied diabétique.
- **Coût moyen amputation transfémorale** : ~25 000 € en hospitalisation initiale + appareillage + rééducation (référentiel HAS).

## Limites
- **Identification du diabète sous-jacent** : DA E10-E14 dans le RSA d'amputation peut manquer ; chaînage SNDS (ALD, médicaments antidiabétiques) recommandé pour exhaustivité.
- **Distinction majeure/mineure** : la frontière (cheville) n'est pas toujours codée précisément ; certains actes intermédiaires (Syme) à classer.
- **Récidives** : un patient peut avoir 2 amputations consécutives (trans-tibiale puis trans-fémorale) ; règle « 1 patient / an » à appliquer.
- **Diabète vs autres causes** : l'amputation peut avoir une cause artériopathique sans diabète documenté ; risque de sur-attribution au diabète.
- **Codage CIM-10 lourdeur diabète** : E10/E11.5x (avec complications circulatoires) plus spécifique que E11.9 simple.
- **Population résidente** : code géographique de résidence du patient impératif.
- **Chirurgie réalisée hors région** : chaînage SNDS nécessaire pour suivi territorial fiable.
- **Standardisation** : sans standardisation âge/sexe, comparaisons biaisées par démographie.
- **Volume minimal** : pour territoires < 100 000 habitants, IC 95% large.

## Références
- [OCDE — Health at a Glance 2025 — Avoidable hospital admissions](https://www.oecd.org/en/publications/2025/11/health-at-a-glance-2025_a894f72e/full-report/avoidable-hospital-admissions_2a8e2482.html)
- [OCDE — HCQO Definitions méthodologie](https://www.oecd.org/content/dam/oecd/en/topics/policy-sub-issues/measuring-health-care-quality/definitions-of-health-care-quality-outcomes.pdf)
- [OCDE — Healthcare Quality and Outcomes Indicators](http://www.oecd.org/health/health-care-quality-outcomes-indicators.htm)
- Fosse-Edorh S, Mandereau-Bruno L, Hartemann-Heurtier A. Les hospitalisations pour complications podologiques chez les personnes diabétiques en France. *BEH* 2015. (Santé publique France).
- HAS — Prise en charge du pied diabétique infecté (recommandations).
- Eurostat — *European Standard Population (ESP2013)* pour standardisation.
