# PSI-90 — Indicateur Composite de Sécurité des Patients (AHRQ)

## Définition
Le PSI-90 (Patient Safety Indicator 90) est un indicateur composite développé par l'Agency for Healthcare Research and Quality (AHRQ, États-Unis) mesurant la fréquence d'événements indésirables évitables survenant au cours d'une hospitalisation, détectés algorithmiquement depuis les codes de diagnostic et de procédure des données administratives hospitalières. Il agrège 8 sous-indicateurs PSI, chacun ciblant un type d'événement indésirable grave : sepsis postopératoire, embolie pulmonaire ou thrombose veineuse profonde postopératoire, hémorragie ou hématome postopératoire, pneumothorax iatrogène, plaie opératoire accidentelle, insuffisance rénale postopératoire, défaillance respiratoire postopératoire, et chute ou traumatisme iatrogène. Initialement conçu pour les DRG américains et la CIM-9/10, le PSI-90 est directement transposable au PMSI français grâce à la compatibilité des codes CIM-10 et à la structure similaire des données administratives hospitalières.

## Calcul
Le PSI-90 composite est calculé comme suit :

```
PSI-90 = Σ (poids_i × taux_observé_PSI_i / taux_référence_PSI_i)

  → Taux de chaque PSI = (Séjours avec événement PSI_i / Séjours à risque pour PSI_i) × 1 000
  → Poids_i : pondération AHRQ basée sur la fréquence et la gravité de chaque événement
```

**Les 8 sous-indicateurs PSI composant le PSI-90 :**

| PSI | Événement indésirable | Codes CIM-10 (exemples) | Population à risque |
|---|---|---|---|
| PSI-03 | Escarres de pression acquises en hospitalisation | L89 en DA (absent en DP/DR) | Séjours MCO ≥ 5 jours |
| PSI-06 | Pneumothorax iatrogène | J95.811, J95.812 en DA | Séjours sans pneumothorax préexistant |
| PSI-08 | Fracture de hanche postopératoire | M96.6x en DA après acte chirurgical | Séjours chirurgicaux sans fracture à l'entrée |
| PSI-09 | Hémorragie / hématome postopératoire | T81.0, D68.4 en DA + reprise chirurgicale | Séjours chirurgicaux |
| PSI-11 | Défaillance respiratoire postopératoire | J95.1, J95.2, J95.3 en DA | Séjours chirurgicaux élaborés |
| PSI-12 | EP / TVP postopératoire | I26, I82 en DA après acte chirurgical | Séjours chirurgicaux sans MTEV préexistante |
| PSI-13 | Sepsis postopératoire | A40, A41 en DA + défaillance d'organe | Séjours chirurgicaux élaborés |
| PSI-15 | Plaie / ponction accidentelle peropératoire | T81.2, Y60-Y69 en DA | Tous séjours avec acte chirurgical |

**Précisions méthodologiques :**
- Chaque PSI distingue les événements présents à l'admission (POA — Present on Admission, codés en DA avec flag POA = « Y ») des événements survenus durant l'hospitalisation : seuls les seconds sont comptabilisés.
- La France ne dispose pas encore d'un codage POA systématique dans le PMSI (contrairement aux USA) : une adaptation consiste à considérer que tout code CIM-10 figurant uniquement en DA (et non en DP ni DR) est survenu en cours de séjour.
- Les séjours exclus (obstétrique, psychiatrie, néonatologie, cancers) sont définis par des listes de GHM ou de CMD spécifiques, transposables aux CMD françaises.

## Transposition PMSI France
La transposition du PSI-90 au PMSI français est directe sur le plan des codes CIM-10 (communs) et de la structure des données (DP, DR, DA, actes CCAM). Les adaptations nécessaires sont :

- **Absence de flag POA** : le PMSI français ne code pas systématiquement le caractère présent ou acquis de chaque diagnostic associé. La règle de substitution (DA uniquement = acquis en cours de séjour) est la plus couramment utilisée dans les adaptations européennes du PSI.
- **Codes CIM-10 version française** : la France utilise la CIM-10 FR (version française de l'OMS), dont certains codes diffèrent de la CIM-10 CM américaine ; une table de correspondance est nécessaire pour les codes spécifiques.
- **Remplacement des DRG par les GHM** : les critères d'exclusion basés sur les DRG américains sont transposés aux GHM français via les CMD et les racines de GHM correspondantes.
- **Validations publiées** : des équipes françaises (DREES, IRDES) et européennes (OCDE, Eurostat) ont validé la transposition des PSI en CIM-10 FR sur données PMSI, confirmant leur faisabilité et leur pertinence.

## Utilité
- **Détection algorithmique des événements indésirables graves** : le PSI-90 permet d'identifier de manière systématique et reproductible les EIG évitables sans audit manuel dossier par dossier, à l'échelle de l'ensemble des séjours MCO du GHT.
- **Benchmarking international** : le PSI-90 est utilisé dans plus de 30 pays (OCDE, programme EU4Health) ; son calcul sur données PMSI permet de positionner le GHT dans un référentiel international validé.
- **Suivi dans le temps** : la comparaison du PSI-90 sur 3-5 ans mesure l'impact des politiques de sécurité des soins mises en place par le GHT (check-lists, protocoles de prévention, culture sécurité).
- **Priorisation des actions de sécurité** : l'analyse des sous-indicateurs PSI les plus élevés guide les audits cliniques ciblés et les actions correctives (prévention des EP postopératoires, gestion des escarres, sécurité chirurgicale).
- **Complément aux déclarations d'EIG** : les PSI capturent des événements souvent non déclarés dans les systèmes de signalement volontaires (EIAS), offrant une vision exhaustive des événements documentés dans le PMSI.

## Sources de Données
- **PMSI MCO** : codes CIM-10 (DP, DR, DA) et codes CCAM pour la détection des événements PSI et la définition des populations à risque.
- **AHRQ - Logiciel SAS/R PSI** : algorithmes open-source publiés par l'AHRQ, adaptables aux données PMSI françaises après transposition des codes.
- **OCDE - Health at a Glance** : référentiel international des PSI avec taux de référence par pays pour le benchmarking.
- **IRDES / DREES** : travaux français de transposition et de validation des PSI sur données PMSI (publications disponibles).
- **Référence méthodologique** : AHRQ, *Patient Safety Indicators Technical Specifications*, version mise à jour annuellement.

## Exemple de Valeurs
- **PSI-12 (EP/TVP postopératoire)** : taux moyen OCDE de 5-10 pour 1 000 séjours chirurgicaux ; France estimée à 4-8 pour 1 000 selon les études de transposition.
- **PSI-13 (Sepsis postopératoire)** : taux moyen OCDE de 5-15 pour 1 000 séjours chirurgicaux élaborés ; très variable selon le type de chirurgie (colorectale, urologique).
- **PSI-03 (Escarres acquises)** : 2-6 pour 1 000 séjours MCO ≥ 5 jours ; fortement dépendant de la qualité du codage des DA.
- **PSI-90 composite** : score composite normalisé autour de 1,0 (moyenne nationale) ; les établissements avec PSI-90 > 1,3 sont considérés à risque élevé dans le système américain.
- **Réduction observée** : les hôpitaux ayant mis en place des programmes ciblés sur le PSI-90 ont réduit leurs événements indésirables de 17-25 % sur 3 ans (données CMS Partnership for Patients).

## Limites
- **Dépendance au codage** : les PSI sont entièrement fondés sur les codes CIM-10 renseignés dans le PMSI ; un sous-codage des complications et comorbidités en DA conduit à une sous-estimation systématique des événements indésirables.
- **Absence de flag POA en France** : sans codage du caractère présent à l'admission, la distinction entre complication préexistante et complication acquise en cours de séjour repose sur une règle approchée (DA seul = acquis), source de faux positifs.
- **Spécificité imparfaite** : certains codes CIM-10 utilisés dans les PSI peuvent correspondre à des situations cliniques non iatrogènes ; des taux élevés de faux positifs ont été documentés pour certains PSI (PSI-03, PSI-08) dans des études de validation par revue de dossiers.
- **Non-couverture des événements non codés** : les PSI ne détectent que les événements documentés dans le PMSI ; les erreurs médicamenteuses, les chutes non documentées et les infections sans diagnostic codé sont invisibles.
- **Comparaisons inter-établissements** : les différences de pratiques de codage entre établissements du GHT peuvent créer des artefacts dans les comparaisons internes, nécessitant une standardisation préalable du codage.

## Références
- [AHRQ - Patient Safety Indicators Documentation](https://www.qualityindicators.ahrq.gov/Modules/PSI_TechSpec_ICD10_v2024.aspx)
- [OCDE - Health at a Glance : Patient Safety Indicators](https://www.oecd.org/health/health-at-a-glance.htm)
- [IRDES - Transposition des PSI sur données PMSI françaises](https://www.irdes.fr/)
- [DREES - Sécurité des soins et événements indésirables en France](https://www.drees.solidarites-sante.gouv.fr/)
- [HAS - Programme national de sécurité des patients](https://www.has-sante.fr/)
