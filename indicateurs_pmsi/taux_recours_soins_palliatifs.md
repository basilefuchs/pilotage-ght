# Taux de Recours aux Soins Palliatifs par Pathologie Causale

## Définition
Le taux de recours aux soins palliatifs par pathologie causale mesure la proportion de patients atteints d'une pathologie grave à pronostic limité (cancer, insuffisance d'organe terminale, maladie neurodégénérative) qui bénéficient d'une prise en charge palliative identifiée dans le PMSI, que ce soit en séjour dédié (GHM soins palliatifs), en séjour MCO avec codage Z51.5 (séance de soins palliatifs), ou en HAD avec mode de prise en charge principal « soins palliatifs ». Cet indicateur évalue la structuration de la filière palliative du GHT, l'adéquation entre les besoins de la population et l'offre de soins palliatifs disponible, et le respect des recommandations HAS sur l'accès précoce aux soins palliatifs pour les patients en phase avancée ou terminale.

## Calcul
Le taux de recours aux soins palliatifs est calculé comme suit :

```
Taux de recours SP par pathologie (%) = (Séjours avec codage SP pour la pathologie P / Total des séjours pour la pathologie P) × 100
```

**Identification des séjours palliatifs dans le PMSI :**

| Source PMSI | Critère d'identification |
|---|---|
| MCO - GHM soins palliatifs | GHM 23Z02Z (soins palliatifs sans acte) ou 23Z03Z (avec acte) |
| MCO - Codage Z51.5 en DP | Séjour dont le diagnostic principal est Z51.5 (soins palliatifs) |
| MCO - Codage Z51.5 en DA | Séjour avec Z51.5 en diagnostic associé (palliatif non dominant) |
| HAD | Mode de prise en charge principal (MPC) = 21 (soins palliatifs) |
| SSR | GME de soins palliatifs (actes cotés en soins de confort/accompagnement) |

**Pathologies causales analysées :**
- Cancers (C00-C97) : poumon, colorectal, sein, prostate, pancréas, hémopathies
- Insuffisance cardiaque terminale (I50 + stade IV NYHA proxy)
- BPCO terminale (J44 + insuffisance respiratoire chronique J96.1)
- Insuffisance rénale terminale sous dialyse (N18.5-N18.6)
- Maladies neurodégénératives (G20, G35, G12.2)

## Utilité
- **Évaluation de l'accès précoce aux soins palliatifs** : identifier les pathologies pour lesquelles les patients décèdent sans avoir bénéficié d'une prise en charge palliative formalisée, en contradiction avec les recommandations HAS et le plan national soins palliatifs.
- **Structuration de la filière palliative du GHT** : mesurer la capacité du GHT à assurer des soins palliatifs à domicile (HAD palliative), en unité dédiée (USP) et en équipe mobile (EMSP), et identifier les maillons manquants.
- **Réduction des hospitalisations non pertinentes en fin de vie** : un taux faible de recours aux soins palliatifs est souvent associé à des hospitalisations répétées et des actes invasifs en fin de vie, contraires aux souhaits des patients et coûteux.
- **Analyse géographique intra-GHT** : comparer les taux de recours aux soins palliatifs entre les établissements du GHT pour identifier les sites où l'accès est insuffisant et déployer des équipes mobiles ou des consultations avancées.
- **Dialogue avec l'ARS** : le taux de recours aux soins palliatifs est un indicateur clé des plans régionaux de santé (PRS) et des schémas régionaux d'offre de soins (SROS) pour les soins palliatifs.

## Sources de Données
- **PMSI MCO** : GHM 23Z02Z et 23Z03Z pour les séjours dédiés ; codes Z51.5 en DP ou DA pour les séjours palliatifs non dédiés ; diagnostic principal et diagnostics associés pour les pathologies causales.
- **PMSI HAD** : mode de prise en charge principal (MPC = 21) pour les prises en charge palliatives à domicile.
- **PMSI SSR** : identification des séjours de soins de confort et d'accompagnement par les actes codés et le GME.
- **ScanSanté** : module d'analyse des séjours par GHM, permettant d'isoler les GHM soins palliatifs et de les croiser avec les diagnostics causaux.
- **ATIH - Tableaux de bord soins palliatifs** : données agrégées par établissement sur l'activité palliative MCO et HAD.

## Exemple de Valeurs
- **Cancer du pancréas** : taux de recours aux soins palliatifs de 40-60 % des séjours (pathologie de pronostic très défavorable à court terme), parmi les plus élevés en oncologie.
- **Cancer du poumon au stade IV** : 30-50 % des séjours comportent un codage palliatif, mais ce taux est très variable selon les établissements (5-70 %).
- **Insuffisance cardiaque terminale** : taux de recours aux soins palliatifs très faible (5-15 %), malgré un pronostic comparable à de nombreux cancers — signalant un sous-accès structurel aux soins palliatifs en cardiologie.
- **BPCO terminale** : taux de recours palliatif encore plus faible (2-8 %), révélant un angle mort majeur de la filière palliative française.
- **Séjours HAD palliative** : représentent 25-35 % de l'activité HAD nationale, avec une forte hétérogénéité régionale.
- **Lits USP pour 1 million d'habitants** : objectif plan soins palliatifs 2021-2024 : 1 USP pour 200 000 habitants — objectif non atteint dans de nombreux territoires.

## Limites
- Le codage Z51.5 est sous-utilisé en France : de nombreux séjours palliatifs ne sont pas identifiés dans le PMSI faute de codage systématique par les équipes médicales et les DIM.
- Les soins palliatifs prodigués en dehors d'un séjour dédié (accompagnement informel en service, soutien psychologique, soins de confort non codés) sont invisibles dans le PMSI.
- Le GHM 23Z02Z/23Z03Z ne capture que les séjours dont l'objectif principal est palliatif : les patients bénéficiant de soins palliatifs en cours de traitement actif (palliatif précoce) sont comptabilisés dans leur GHM de pathologie.
- La comparaison inter-établissements est biaisée par les différences de pratiques de codage du Z51.5 et par les différences d'organisation des équipes mobiles de soins palliatifs (EMSP).
- L'indicateur ne mesure pas la qualité des soins palliatifs prodigués, uniquement leur traçabilité dans le PMSI.

## Références
- [HAS - Recommandations sur les soins palliatifs et l'accès précoce](https://www.has-sante.fr/)
- [ATIH - GHM soins palliatifs et activité HAD palliative](https://www.atih.sante.fr/)
- [SFAP - Société Française d'Accompagnement et de Soins Palliatifs](https://www.sfap.org/)
- [ScanSanté - Analyse des GHM soins palliatifs](https://www.scansante.fr/)
- [Plan national soins palliatifs et soins d'accompagnement 2021-2024](https://sante.gouv.fr/)
