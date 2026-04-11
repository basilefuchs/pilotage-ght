# PQI — Prevention Quality Indicators (AHRQ)

## Définition
Les Prevention Quality Indicators (PQI) sont un ensemble de 18 indicateurs développés par l'AHRQ (Agency for Healthcare Research and Quality, États-Unis) mesurant les hospitalisations pour des pathologies chroniques ou aiguës qui auraient pu être évitées par une prise en charge ambulatoire de qualité. Ils constituent la version américaine, standardisée et validée internationalement, de ce que la France appelle « hospitalisations potentiellement évitables » (HPE). Contrairement au taux d'HPE français (souvent calculé avec des définitions ad hoc et peu standardisées), les PQI proposent des définitions précises par codes CIM-10, des règles d'exclusion rigoureuses et des taux de référence nationaux publiés annuellement par l'AHRQ — permettant des comparaisons robustes dans le temps et entre établissements ou territoires. Ils sont utilisés dans plus de 30 pays (OCDE, programme EU4Health) comme indicateur de performance des soins primaires et de coordination ville-hôpital.

## Calcul
Chaque PQI est calculé comme suit :

```
Taux PQI (pour 100 000 hab.) = (Séjours MCO répondant aux critères du PQI / Population du territoire) × 100 000
```

**Les 18 PQI et leur transposition CIM-10 FR :**

| PQI | Pathologie | Codes CIM-10 (DP) | Exclusions principales |
|---|---|---|---|
| PQI-01 | Complications du diabète (court terme) | E10.0-E10.1, E11.0-E11.1, E12.0-E13.0 | Grossesse, diabète secondaire |
| PQI-03 | Complications du diabète (long terme) | E10.2-E10.9, E11.2-E11.9 | Grossesse |
| PQI-05 | BPCO ou asthme adulte | J40-J47, J96.0 | <40 ans, mucoviscidose |
| PQI-07 | Hypertension artérielle | I10-I13, I15 | Grossesse, insuffisance rénale terminale |
| PQI-08 | Insuffisance cardiaque | I50, I11.0 | Chirurgie cardiaque, transplantation |
| PQI-09 | Déshydratation | E86 | Gastroentérite infectieuse, <18 ans |
| PQI-10 | Bactériémie à bactéries sensibles aux antibiotiques | A41, A40 (sans sepsis sévère) | Immunodépression, tumeurs hématologiques |
| PQI-11 | Pneumonie bactérienne | J13-J18, J15 | Immunodépression, mucoviscidose, <18 ans |
| PQI-12 | Infections urinaires | N10, N30, N39.0 | Transplantation rénale, uro-néphropathies |
| PQI-13 | Angine de poitrine sans revascularisation | I20 | Séjours avec revascularisation coronaire |
| PQI-14 | Amputation du membre inférieur chez le diabétique | 28 codes amputation (CCAM) + diabète DA | Traumatisme vasculaire aigu |
| PQI-15 | Complications de l'asthme enfant | J45, J46 | <2 ans, >17 ans, mucoviscidose |
| PQI-16 | Diabète non contrôlé sans complication | E10.9, E11.9, E12.9, E13.9 | Grossesse, diabète secondaire |
| PQI-90 | Composite global PQI | Agrégation PQI pondérés | Exclusions combinées |
| PQI-91 | Composite maladies aiguës | PQI-08, 10, 11, 12 | — |
| PQI-92 | Composite maladies chroniques | PQI-01, 03, 05, 07, 13, 14, 15, 16 | — |

**Indicateurs composites :**
```
PQI-90 (composite global) = Σ (poids_i × taux_PQI_i standardisé)
  → Standardisé par âge et sexe sur la population de référence nationale
  → Poids basés sur la fréquence et l'évitabilité de chaque PQI
```

## Transposition PMSI France
La transposition des PQI au PMSI français est **directe et validée** :

- **Codes CIM-10 communs** : les PQI sont définis par des listes de codes CIM-10 précises, directement applicables à la CIM-10 FR du PMSI avec des adaptations mineures pour les quelques codes spécifiques à la version américaine (CIM-10 CM).
- **Algorithmes open-source** : l'AHRQ publie le code SAS et le code R de calcul des PQI, librement téléchargeables et adaptables aux exports PMSI.
- **Validations OCDE** : les PQI font partie des indicateurs de santé de l'OCDE (*Health at a Glance*) et sont calculés sur données françaises par la DREES depuis 2010 — leur faisabilité sur PMSI est officiellement documentée.
- **Règles d'exclusion** : les exclusions basées sur les DRG américains sont transposées aux CMD et GHM français ; l'ATIH et la DREES ont publié les tables de correspondance.
- **Différence notable** : les PQI américains sont calculés par zone géographique (territoire de résidence du patient), pas par établissement — comme en France pour les taux d'HPE. Le PMSI français (code postal de résidence) permet cette approche territoriale.

## Utilité
- **Mesure standardisée et internationalement comparable de la performance des soins primaires** : les PQI permettent de positionner le territoire du GHT dans une comparaison internationale (OCDE) avec des définitions rigoureuses, contrairement aux définitions françaises d'HPE qui varient selon les études.
- **Décomposition par pathologie et par composite** : les PQI-90, PQI-91 (maladies aiguës) et PQI-92 (maladies chroniques) offrent une vision stratifiée permettant d'identifier si les problèmes de coordination touchent plutôt les pathologies chroniques (suivi insuffisant) ou aiguës (accès aux soins primaires en urgence).
- **Outil de dialogue avec les acteurs de la ville** : un taux élevé de PQI-08 (insuffisance cardiaque) ou PQI-03 (complications tardives du diabète) sur un territoire fournit un argument objectif pour renforcer les équipes de soins primaires, les infirmières en pratique avancée (IPA) et les Maisons de Santé Pluriprofessionnelles (MSP).
- **Suivi longitudinal des politiques de santé** : les PQI sont sensibles aux interventions de santé publique (programmes ETP, déploiement de coordinateurs de soins, ouverture de centres de santé) et permettent d'en mesurer l'impact sur 3-5 ans.
- **Benchmarking territorial intra-GHT** : comparer les PQI par commune ou bassin de vie au sein du territoire du GHT pour identifier les zones géographiques à prioriser.

## Sources de Données
- **PMSI MCO** : diagnostic principal (DP) codé en CIM-10, code postal de résidence du patient et actes CCAM — pour l'identification des séjours PQI et des exclusions.
- **INSEE** : données de population par commune et tranche d'âge pour le calcul des taux pour 100 000 habitants et la standardisation démographique.
- **AHRQ - Logiciels PQI open-source** : code SAS et R disponibles sur le site AHRQ Quality Indicators, adaptables aux données PMSI françaises.
- **DREES** : calculs français des PQI publiés dans les rapports *L'état de santé de la population en France* et dans les comparaisons OCDE.
- **ScanSanté** : module de recherche par diagnostic principal, utilisable pour une estimation rapide des volumes de séjours PQI sans recalcul algorithmique complet.

## Exemple de Valeurs
- **PQI-08 (Insuffisance cardiaque) France** : environ 250-350 pour 100 000 habitants (données DREES/OCDE), dans la moyenne des pays européens mais 30-40 % supérieur aux Pays-Bas et aux pays scandinaves.
- **PQI-05 (BPCO/asthme adulte)** : 80-120 pour 100 000 habitants en France, avec une forte variation territoriale corrélée à la densité de pneumologues libéraux.
- **PQI-11 (Pneumonie bactérienne)** : 150-250 pour 100 000 habitants, pathologie très sensible à la qualité de la vaccination (grippe, pneumocoque) et au suivi des patients âgés.
- **PQI-14 (Amputation diabétique)** : 10-20 pour 100 000 habitants ; la France est dans la moyenne haute européenne, signalant un potentiel d'amélioration du suivi podologique des diabétiques.
- **Variation territoriale** : les taux de PQI sont 40-60 % plus élevés dans les déserts médicaux que dans les territoires bien dotés en soins primaires — gradient documenté par la DREES.
- **PQI-90 composite France vs OCDE** : la France se situe dans le tiers intermédiaire des pays OCDE, derrière les Pays-Bas, les pays nordiques et le Canada.

## Limites
- Les PQI mesurent des hospitalisations évitables au niveau territorial (population), pas au niveau de l'établissement — ils évaluent la performance des soins primaires du territoire, pas celle de l'hôpital.
- Certaines hospitalisations répondant aux critères PQI sont cliniquement inévitables (ex. : exacerbation de BPCO chez un patient très sévère bien suivi) ; les PQI surestiment systématiquement les hospitalisations réellement évitables.
- La sensibilité des PQI aux politiques de codage : une amélioration du codage du DP (codage plus précis des complications du diabète) peut augmenter artificiellement certains PQI sans refléter une dégradation réelle de la qualité des soins primaires.
- Les comparaisons internationales sont biaisées par les différences de systèmes de soins (couverture, accès, culture médicale) qui influencent les taux d'hospitalisation indépendamment de la qualité.
- Le calcul des PQI composites (PQI-90, 91, 92) nécessite des pondérations calibrées sur données françaises pour être pertinent — les pondérations AHRQ américaines ne sont pas directement transposables.

## Références
- [AHRQ - Prevention Quality Indicators Documentation and Software](https://www.qualityindicators.ahrq.gov/Modules/PQI_TechSpec_ICD10_v2024.aspx)
- [OCDE - Health at a Glance : Avoidable Admissions](https://www.oecd.org/health/health-at-a-glance.htm)
- [DREES - Hospitalisations potentiellement évitables en France](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH - Base nationale PMSI et diagnostics principaux](https://www.atih.sante.fr/)
- [ScanSanté - Analyse par diagnostic principal](https://www.scansante.fr/)
