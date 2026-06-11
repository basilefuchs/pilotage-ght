# IQTIG — Indicateurs de Qualité Obstétricaux (Allemagne)

## Définition
L'IQTIG (Institut für Qualitätssicherung und Transparenz im Gesundheitswesen) est l'institut fédéral allemand de mesure de la qualité hospitalière, équivalent de la HAS française pour les indicateurs de performance. Dans le domaine de l'obstétrique, l'IQTIG publie annuellement un ensemble d'indicateurs calculés sur les données administratives et cliniques des maternités allemandes (système G-DRG, équivalent du PMSI), couvrant : le taux de césariennes, les lésions périnéales sévères, la mortalité périnatale, les scores d'Apgar bas, les transferts néonatals non programmés en soins intensifs, et les hémorragies du post-partum. Ces indicateurs sont obligatoires pour toutes les maternités allemandes depuis 2001 et servent de base au benchmarking national et aux décisions de maintien ou de fermeture des autorisations. Leur transposition au PMSI français est directe grâce à la compatibilité CIM-10 et aux codes d'actes CCAM couvrant les mêmes gestes obstétricaux.

## Calcul
Les principaux indicateurs IQTIG obstétricaux et leur formule :

**1. Taux de césarienne (primaire et totale) :**
```
Taux de césarienne totale (%) = (Accouchements par césarienne / Total des accouchements) × 100
  → Codes CCAM : QXGA010 (césarienne segmentaire), QXGA015 (césarienne corporéale)
  → Codes CIM-10 DP : O82 (accouchement par césarienne)

Taux de césarienne primaire (%) = (Césariennes sans travail préalable / Total accouchements) × 100
  → Exclusion : O82 avec antécédent de césarienne (O34.2 en DA)
```

**2. Taux de lésions périnéales sévères (déchirures de grade 3-4) :**
```
Taux de lésions périnéales sévères (%) = (Accouchements voie basse avec déchirure grade 3-4 / Accouchements voie basse) × 100
  → Codes CIM-10 : O70.2 (déchirure du périnée grade 3), O70.3 (grade 4)
  → Exclusion : présentation par le siège, accouchement instrumental uniquement si indiqué
```

**3. Taux d'hémorragie du post-partum sévère :**
```
Taux d'HPP sévère (%) = (Accouchements avec HPP ≥ 500 mL ou transfusion / Total accouchements) × 100
  → Codes CIM-10 : O72 (hémorragie du post-partum) en DP ou DA
  → Proxy PMSI : O72 + acte de transfusion CCAM (FELF001, FELB001)
```

**4. Score d'Apgar bas à 5 minutes :**
```
Taux d'Apgar < 7 à 5 min (‰ naissances vivantes) = (Nouveau-nés avec Apgar < 7 à 5 min / Total naissances vivantes) × 1 000
  → Code CIM-10 : Z37 (résultat de l'accouchement) + P01-P04 (facteurs maternels)
  → Proxy PMSI : P21.0 (asphyxie sévère à la naissance), P21.1 (asphyxie modérée)
```

**5. Taux de transfert néonatal non programmé en soins intensifs :**
```
Taux de transfert néonatal (‰) = (Nouveau-nés transférés en USIN de façon non programmée / Total naissances vivantes à terme) × 1 000
  → Identifié par le couplage séjour maternel (DP = O80-O84) et séjour néonatal (DP = P00-P39, Z38)
  → Mode d'entrée du séjour néonatal = transfert (code 6) depuis la maternité
```

**6. Taux de mortalité périnatale :**
```
Taux de mortalité périnatale (‰) = ((Mortinatalité + Décès néonatals précoces à J7) / Total naissances) × 1 000
  → Codes CIM-10 : P95 (mort fœtale), P96.0, Z37.1, Z37.3, Z37.4 (accouchement d'enfant mort-né)
  → Décès néonatals précoces : mode de sortie = décès dans les séjours néonatals P00-P39
```

## Transposition PMSI France
La transposition des indicateurs IQTIG obstétricaux au PMSI français est **excellente** :

- **PMSI obstétrique (champ MCO)** : tous les accouchements sont codés en DP avec les codes O60-O84 (CIM-10 FR), avec les actes CCAM correspondants — base parfaite pour tous les indicateurs IQTIG.
- **Chaînage mère-enfant PMSI** : le PMSI MCO permet de chaîner le séjour maternel et le séjour néonatal via le numéro de RSS jumeau ou le NIR crypté — indispensable pour les indicateurs néonatals.
- **Codes CIM-10 communs** : O70.2-O70.3 (déchirures), O72 (HPP), O82 (césarienne), P21 (asphyxie) sont identiques en CIM-10 FR et CIM-10 allemande.
- **Indicateurs déjà partiellement calculés en France** : le taux de césarienne est publié par la DREES et calculé par ScanSanté ; les lésions périnéales et l'HPP sont des indicateurs IQSS de la HAS, mais avec des définitions moins précises que l'IQTIG.
- **Amélioration IQTIG vs HAS** : l'IQTIG publie des taux ajustés sur le risque (casemix obstétrical : parité, présentation, terme, poids de naissance) — cette standardisation, absente des indicateurs HAS actuels, est calculable sur PMSI avec les variables disponibles.

## Utilité
- **Benchmarking des maternités du GHT** : comparer les taux de césarienne, de lésions périnéales et d'HPP entre les maternités du GHT avec des définitions standardisées et des taux ajustés sur le risque obstétrical.
- **Détection des outliers de pratiques** : un taux de césarienne > 25 % dans une maternité de niveau 1 (sans facteur de risque documenté supérieur) ou un taux de lésions périnéales sévères > 3 % sont des signaux d'alerte justifiant un audit de pratiques.
- **Amélioration continue de la qualité** : les indicateurs IQTIG sont utilisés en Allemagne pour des revues de morbi-mortalité obstétricale structurées (équivalent RMM) — leur adoption dans le GHT structure les démarches d'amélioration.
- **Dialogue avec l'ARS et les réseaux périnatals** : les indicateurs IQTIG fournissent une base commune pour les échanges avec le réseau périnatal régional et pour la justification des autorisations de maternité.
- **Réduction des événements indésirables obstétricaux** : les lésions périnéales sévères et l'HPP sont deux des principales causes de morbidité maternelle sévère évitable — leur suivi systématique est un levier de réduction des EIG obstétricaux.

## Sources de Données
- **PMSI MCO - Séjours obstétricaux** : diagnostics CIM-10 (DP = O60-O84, DA), actes CCAM (accouchements, césariennes, épisiotomies), mode de sortie.
- **PMSI MCO - Séjours néonatals** : DP = P00-P39 ou Z38, mode d'entrée (transfert ou naissance sur place), mode de sortie (décès = 9).
- **Chaînage mère-enfant PMSI** : numéro RSS jumeau ou NIR crypté pour relier le séjour maternel et le séjour néonatal.
- **ScanSanté - Module obstétrique** : taux de césarienne et indicateurs obstétricaux de base, calculés par établissement et comparables à la moyenne nationale.
- **HAS - Indicateurs IQSS obstétrique** : taux de césarienne, HPP, lésions périnéales — avec définitions françaises comparables aux IQTIG.
- **Référence méthodologique** : IQTIG, *Bundesauswertung zum Erfassungsjahr Geburtshilfe*, rapport annuel allemand de qualité obstétricale.

## Exemple de Valeurs
- **Taux de césarienne France (2022)** : 21,4 % (DREES), contre 32 % en Allemagne et 16 % en Suède — forte variation inter-établissements en France (10-45 %).
- **Taux de lésions périnéales sévères (grade 3-4) France** : 0,8-1,5 % des accouchements voie basse selon les maternités ; objectif IQTIG < 2,5 % pour les maternités à bas risque.
- **Taux d'HPP sévère France** : 3-6 % des accouchements selon les études, avec une augmentation documentée depuis 2000 (meilleure codification et traçabilité).
- **Taux d'Apgar < 7 à 5 min** : 5-15 ‰ naissances vivantes selon le niveau de maternité (I, II, III) — indicateur très sensible à la qualité de la surveillance fœtale et de la réanimation néonatale.
- **Taux de transfert néonatal non programmé** : 15-30 ‰ en maternité de niveau I, 50-80 ‰ en niveau III (maternités accueillant les grossesses à haut risque).
- **Mortalité périnatale France** : 10,5 ‰ (mortinatalité + mortalité néonatale précoce, données CépiDc 2022), dans la moyenne haute des pays d'Europe de l'Ouest.

## Limites
- Le taux de césarienne brut n'est pas interprétable sans ajustement sur le casemix obstétrical (parité, présentation, terme, pathologies maternelles) — la classification de Robson (10 groupes) est recommandée pour les comparaisons inter-maternités.
- Le codage des lésions périnéales (O70.2-O70.3) est très hétérogène entre établissements en France, rendant les comparaisons directes peu fiables sans audit préalable de la qualité du codage.
- La mortalité périnatale est un indicateur rare (faibles effectifs) pour lequel les intervalles de confiance sont larges dans les petites maternités du GHT — les comparaisons annuelles sont instables ; une agrégation sur 3-5 ans est recommandée.
- Le chaînage mère-enfant n'est pas systématiquement documenté dans tous les SIH des établissements du GHT, rendant les indicateurs néonatals partiellement non calculables sans effort spécifique de réconciliation des données.
- Les indicateurs IQTIG allemands incluent des variables cliniques non disponibles dans le PMSI français (poids de naissance précis, terme exact en semaines, score d'Apgar documenté) — des proxies CIM-10 sont utilisés en substitution avec une précision moindre.

## Références
- [IQTIG - Bundesauswertung Geburtshilfe (rapport annuel qualité obstétricale)](https://www.iqtig.org/)
- [DREES - Les naissances en France : statistiques annuelles](https://www.drees.solidarites-sante.gouv.fr/)
- [HAS - Indicateurs IQSS obstétrique (césarienne, HPP, lésions périnéales)](https://www.has-sante.fr/)
- [ScanSanté - Taux de césarienne par établissement](https://www.scansante.fr/)
- [Classification de Robson - OMS, 2015](https://www.who.int/publications/i/item/9789241511216)
