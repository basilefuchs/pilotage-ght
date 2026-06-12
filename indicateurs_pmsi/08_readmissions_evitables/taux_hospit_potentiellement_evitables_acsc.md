# Taux d'Hospitalisations Potentiellement Évitables (ACSC)

## Définition
Le concept de **Ambulatory Care Sensitive Conditions (ACSC)**, traduit en français par **hospitalisations potentiellement évitables (HPE)**, désigne les hospitalisations pour des pathologies pour lesquelles **une prise en charge ambulatoire de qualité** (médecin traitant, suivi structuré, vaccination, observance médicamenteuse) **devrait pouvoir prévenir le recours à l'hospitalisation**. Développé initialement par Billings et al. (1993, NYU) puis validé internationalement par l'AHRQ (Prevention Quality Indicators — PQI) et l'OCDE, ce concept a été décliné en France par l'IRDES et la DREES sur le PMSI.

Trois sous-catégories sont classiquement distinguées :
- **ACSC chroniques** : asthme, BPCO, insuffisance cardiaque, diabète déséquilibré, HTA → traduisent la qualité du suivi des maladies chroniques.
- **ACSC aiguës** : pneumonies bactériennes, infections urinaires hautes, déshydratation → traduisent l'accessibilité aux soins primaires en aigu.
- **ACSC évitables par vaccination** : grippe, infections invasives à pneumocoque chez l'âgé, coqueluche pédiatrique.

L'indicateur sert d'**indicateur indirect d'accès et de qualité des soins primaires** sur un territoire donné, et constitue un proxy de la **coordination ville-hôpital** au sens du programme PAERPA et des CPTS. Bien que non encore IQSS HAS officiel, il figure dans les tableaux de bord de l'IRDES et de la DREES, ainsi que dans les indicateurs OCDE.

Formule :

```
Taux ACSC = (séjours MCO d'adultes ≥ 18 ans avec DP dans la liste ACSC)
            / (population résidente du territoire, standardisée âge × sexe)
            × 100 000

Variantes :
  - Taux brut : N hospit ACSC / N hospit total (% de l'activité)
  - Taux pour 100 000 habitants standardisé (référence territoriale)
```

Positionnement vs indicateurs existants : différent du PSI (événements iatrogènes intra-séjour) ; différent du RH30 (réadmission post-séjour). L'ACSC mesure des hospitalisations qui n'auraient peut-être pas dû avoir lieu, indépendamment de la qualité des soins hospitaliers eux-mêmes.

## Calcul

```
Étape 1 — Liste de référence des codes CIM-10 ACSC (méthode IRDES 2014, adapté
          des PQI AHRQ + Sundmacher)

  CHRONIQUES (DP) :
    J45.x         Asthme
    J41.x, J42, J43.x, J44.x   BPCO
    I50.x          Insuffisance cardiaque
    E10–E14 + .x.x Diabète avec complications court terme (.0, .1, .8)
                   ou non équilibré (.6, .9 avec critères)
    I10–I15        HTA non compliquée nécessitant hospitalisation
    G40.x          Épilepsie

  AIGUËS (DP) :
    J13–J18        Pneumonies bactériennes
    N10–N12, N39.0 Pyélonéphrite, infection urinaire haute
    E86            Déshydratation
    K52.9          Gastroentérite et colites non infectieuses
    L03.x          Cellulite
    H66.x          Otite moyenne perforée (pédiatrie)

  VACCIN-PRÉVENTIBLES (DP) :
    J10–J11        Grippe
    A40, A49.1, G00.1, J13   Infections invasives pneumocoque
    A37            Coqueluche

Étape 2 — Identification des séjours
  RSA avec DP dans la liste, hospitalisation complète OU ambulatoire
  Adultes ≥ 18 ans (selon tradition IRDES)
  Exclusions :
    - Mortalité à l'entrée
    - Transferts entrants (mode entrée 7) → comptage unique
    - Séjours obstétricaux/néonatals

Étape 3 — Numérateur / Dénominateur
  Indicateur territorial :
    N = somme des séjours ACSC des résidents du territoire (code géographique
        de résidence du patient = département/code commune)
    D = population INSEE du territoire (résidents ≥ 18 ans)
    Taux = N / D × 100 000

  Indicateur établissement (alternative) :
    N = séjours ACSC pris en charge par l'établissement
    D = total des séjours MCO de l'établissement
    Taux = N / D × 100 (% de l'activité)

Étape 4 — Standardisation
  Standardisation directe ou indirecte âge × sexe sur population de référence
  (France entière ou population européenne standard).
```

Variables PMSI clés : `DP`, `age`, `SEXE`, `CODE_GEO` (résidence du patient — code commune ou département), `modeentree`, `MODE_SORTIE`. Données INSEE pour le dénominateur populationnel.

## Utilité
- **Pilotage GHT — coordination ville-hôpital** : taux ACSC élevé sur le territoire = signal d'insuffisance des soins primaires, à articuler avec la CPTS et le projet médical partagé.
- **Diagnostic territorial** : intégration au PRS (projet régional de santé) ARS, identification des zones sous-dotées.
- **Évaluation PAERPA** : suivi de l'efficacité des dispositifs de coordination personnes âgées.
- **Comparaison OCDE** : indicateur Health at a Glance pour comparaison France-OCDE.
- **Suivi des plans pathologie** : impact des plans BPCO, diabète, IC sur la baisse des hospitalisations évitables.
- **Justification budgétaire** : ~5 milliards d'euros/an d'admissions ACSC en France (Weeks et al. 2016) → potentiel d'économies par renforcement primaire.
- **Adaptation au GHT** : indicateur de bassin de population, particulièrement pertinent pour les GHT ruraux où la déprise médicale est forte.

## Sources de Données
- **PMSI MCO** : RSA, DP, code géographique de résidence, âge, sexe.
- **INSEE** : population résidente par département / EPCI / code commune, par classe d'âge et sexe (mise à jour annuelle).
- **Référentiel CIM-10 FR** : codes des pathologies ACSC (mise à jour annuelle OMS/ATIH).
- **Référentiel IRDES** : liste française des codes ACSC publiée par Mercier et al. 2015 et actualisée 2018.
- **OCDE PQI** : liste internationale de référence pour comparaison pays-à-pays.
- **ScanSanté** : restitutions territoriales (ATIH).

## Exemple de Valeurs
*Sources : Mercier et al. (PMID 25951924), IRDES, OCDE Health at a Glance 2023.*

- **Taux ACSC France** : ~1 200 – 1 500 hospitalisations pour 100 000 adultes/an (toutes ACSC confondues).
- **Plage départementale** : 800 – 2 200 / 100 000, fort gradient géographique.
- **ACSC chroniques (BPCO + IC + diabète)** : ~700 – 900 / 100 000.
- **ACSC aiguës (pneumonies + infections urinaires)** : ~300 – 500 / 100 000.
- **ACSC vaccinables** : ~30 – 80 / 100 000 (variable selon couverture vaccinale).
- **Comparaison OCDE** : France ~moyenne ; pays nordiques 30-40% inférieurs.
- **Coût France 2010** : 5 milliards d'euros, 8,7 millions de journées d'hospitalisation (Weeks et al.).
- **Plage % de l'activité MCO** : 8 – 14 % des hospitalisations adultes.

## Limites
- **Liste de codes non standardisée** : variations entre AHRQ, OCDE, IRDES, Sundmacher → comparaisons internationales délicates.
- **Définition « évitable » critiquable** : certaines hospitalisations ACSC sont médicalement justifiées (poussée d'IC sur cardiopathie sévère). L'indicateur surestime le « potentiellement évitable » brut.
- **Densité hospitalière** : un fort taux peut traduire une accessibilité hospitalière facile plutôt qu'une faiblesse du primaire (Mercier 2015).
- **Codage du DP** : choix DP vs DR varie entre établissements ; certaines hospitalisations ACSC peuvent être codées en DR.
- **Population résidente** : nécessité de coder correctement le code géographique de résidence (CODGEO), parfois absent ou erroné.
- **Pas un IQSS officiel HAS** : reste un indicateur de territoire et non un indicateur d'établissement validé pour IFAQ.
- **Effet âge** : la population âgée concentre 60 % des ACSC, standardisation impérative pour comparaisons.
- **Vaccination** : le sous-groupe vaccin-préventible est très sensible aux campagnes annuelles.

## Références
- Billings J, Zeitel L, Lukomnik J, et al. Impact of socioeconomic status on hospital use in New York City. *Health Aff*. 1993;12(1):162-173.
- Mercier G, Georgescu V, Bousquet J. Geographic variation in potentially avoidable hospitalizations in France. *Health Aff*. 2015;34(5):836-843. [PMID:25951924](https://pubmed.ncbi.nlm.nih.gov/25951924/)
- Weeks WB, Ventelou B, Paraponaris A. Rates of admission for ACSC in France 2009-2010. [PMID:25951924](https://pubmed.ncbi.nlm.nih.gov/25951924/)
- Bourret R, Mercier G, et al. Comparison of two methods to report potentially avoidable hospitalizations in France 2012. [PMC4316643](https://pmc.ncbi.nlm.nih.gov/articles/PMC4316643/)
- [IRDES — Hospitalisation pour ACSC en Île-de-France](https://shs.cairn.info/journal-revue-francaise-des-affaires-sociales-2013-3-page-108?lang=en)
- [OCDE — Health at a Glance, indicateurs de prévention](https://www.oecd.org/health/health-at-a-glance.htm)
- [AHRQ — Prevention Quality Indicators (PQI)](https://www.qualityindicators.ahrq.gov/Modules/PQI_TechSpec_ICD10_v2024.aspx)
