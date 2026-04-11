# OCDE — Mortalité à 30 Jours après IDM et AVC

## Définition
Les indicateurs de mortalité à 30 jours après infarctus du myocarde (IDM) et accident vasculaire cérébral (AVC) font partie du programme de benchmarking international de l'OCDE (*Health at a Glance*), calculés dans plus de 40 pays sur des données administratives hospitalières standardisées. Ils mesurent la proportion de patients hospitalisés pour un IDM ou un AVC ischémique/hémorragique qui décèdent dans les 30 jours suivant l'admission, que le décès survienne en cours d'hospitalisation ou après la sortie. Ces indicateurs sont considérés comme des marqueurs de la qualité globale du système de soins pour ces deux pathologies temps-dépendantes — ils intègrent la rapidité de la prise en charge, la qualité des soins aigus, la disponibilité des plateaux techniques (coronarographie, thrombolyse/thrombectomie) et la qualité du suivi post-hospitalier immédiat. La France les calcule annuellement via la DREES et les transmet à l'OCDE.

## Calcul
**1. Mortalité à 30 jours après IDM (infarctus du myocarde aigu) :**
```
Taux de mortalité IDM à 30j (%) = (Décès dans les 30 jours suivant l'admission pour IDM / Admissions pour IDM) × 100

Admissions index IDM :
  → DP = I21 (IDM aigu), I22 (IDM récidivant)
  → Exclusions : transferts entrants (mode d'entrée = transfert sans séjour primaire IDM),
                 patients avec IDM dans les 90 jours précédents (exclusion des réadmissions),
                 patients <30 ans, séjours < 3 jours dans certaines définitions

Décès à 30j = décès intra-hospitaliers (mode de sortie = 9) + décès post-sortie dans les 30j (CépiDc/SNDS)
```

**2. Mortalité à 30 jours après AVC ischémique :**
```
Taux de mortalité AVC ischémique à 30j (%) = (Décès dans les 30j / Admissions pour AVC ischémique) × 100

Admissions index AVC ischémique :
  → DP = I63 (infarctus cérébral), I64 (AVC non précisé)
  → Exclusions : AIT (G45), AVC hémorragique (I60-I62) sauf dans la définition élargie,
                 transferts entrants sans séjour primaire AVC

Standardisation : taux standardisé sur l'âge et le sexe (population de référence OCDE 2010)
```

**3. Mortalité à 30 jours après AVC hémorragique :**
```
Taux de mortalité AVC hémorragique à 30j (%) = (Décès dans les 30j / Admissions pour AVC hémorragique) × 100

Admissions index :
  → DP = I60 (hémorragie sous-arachnoïdienne), I61 (hémorragie intracérébrale)
  → Exclusions : traumatismes crâniens (S06), tumeurs cérébrales (C71)
```

**Ajustement sur le risque (méthode OCDE) :**
```
Taux ajusté = Décès observés / Décès attendus × Taux de référence national

Décès attendus = Σ P(décès_i) estimée par régression logistique sur :
  → âge, sexe, comorbidités CIM-10 (Charlson ou Elixhauser)
  → type d'admission (urgences vs transfert)
  → année d'admission
```

## Transposition PMSI France
La France calcule déjà ces indicateurs — la transposition est **complète et officielle** :

- **Calcul DREES** : la DREES calcule annuellement les taux de mortalité à 30 jours IDM et AVC sur données PMSI, transmis à l'OCDE pour *Health at a Glance*. La méthodologie est publique et documentée.
- **Décès intra-hospitaliers** : directement disponibles via le mode de sortie PMSI (code 9 = décès).
- **Décès post-sortie à 30j** : nécessitent le chaînage PMSI-CépiDc via le SNDS — techniquement réalisé par la DREES mais non accessible à tous les GHT sans autorisation SNDS.
- **Variante GHT sans SNDS** : calculer le taux de mortalité intra-hospitalière seul (sous-ensemble de la mortalité à 30j) reste pertinent pour le benchmarking intra-GHT, même si moins complet.
- **Codes CIM-10 identiques** : I21, I22, I63, I60, I61 sont utilisés de manière identique en France et dans la définition OCDE.
- **Indicateur ScanSanté** : le taux de mortalité intra-hospitalière après IDM et AVC est disponible dans ScanSanté par établissement, permettant un calcul immédiat sans accès SNDS.

## Utilité
- **Positionnement international du GHT** : les taux de mortalité à 30 jours OCDE permettent de situer la performance du GHT dans un référentiel de 40 pays — au-delà du simple benchmarking national.
- **Évaluation des filières cardiologique et neurovasculaire** : la mortalité à 30 jours après IDM et AVC est le marqueur de résultat le plus robuste pour évaluer la performance globale des filières USIC (Unité de Soins Intensifs Cardiologiques) et UNV (Unité Neuro-Vasculaire) du GHT.
- **Impact des délais de prise en charge** : une réduction du délai de revascularisation (IDM) ou de thrombolyse/thrombectomie (AVC) se traduit directement par une baisse de la mortalité à 30 jours — cet indicateur mesure l'efficacité des protocoles temps-dépendants.
- **Suivi des investissements en plateau technique** : l'ouverture d'une salle de coronarographie ou le renforcement d'une UNV dans le GHT doit se traduire par une réduction mesurable de la mortalité à 30 jours dans les années suivantes.
- **Dialogue avec l'ARS** : un taux de mortalité après IDM ou AVC significativement supérieur à la moyenne nationale justifie un audit de la filière et peut orienter les décisions d'autorisation de soins critiques cardiologiques ou neurologiques.

## Sources de Données
- **PMSI MCO** : diagnostic principal (I21, I22, I63, I60, I61), mode de sortie (décès = 9), mode d'entrée, âge, sexe, diagnostics associés (Charlson/Elixhauser) — pour la mortalité intra-hospitalière et les variables d'ajustement.
- **SNDS / CépiDc** : chaînage avec les données d'état civil pour les décès post-sortie dans les 30 jours — accès soumis à autorisation CNIL/INDS, réalisé par la DREES pour les publications nationales.
- **ScanSanté** : mortalité intra-hospitalière après IDM et AVC disponible par établissement, sans nécessiter l'accès SNDS.
- **OCDE - Health at a Glance** : taux de référence internationaux par pays pour le positionnement du GHT dans un référentiel mondial.
- **DREES** : publication annuelle des taux français de mortalité à 30 jours IDM/AVC transmis à l'OCDE, avec méthodologie détaillée.

## Exemple de Valeurs
- **Mortalité à 30j après IDM — France** : 7,5 % (données OCDE 2022, taux standardisé), en amélioration constante depuis 2000 (était > 12 % en 2000). Meilleurs pays : Suède (4,2 %), Norvège (5,1 %).
- **Mortalité à 30j après AVC ischémique — France** : 10,2 % (OCDE 2022, standardisé). Meilleurs pays : Pays-Bas (7,8 %), Danemark (8,3 %).
- **Mortalité à 30j après AVC hémorragique — France** : 28-35 % (plus élevée, reflet de la gravité intrinsèque de cette pathologie).
- **Variation inter-établissements France** : mortalité intra-hospitalière après IDM de 3-15 % selon les établissements (données ScanSanté), avec un fort effet volume (établissements > 200 IDM/an = mortalité significativement plus faible).
- **Impact des UNV** : les établissements disposant d'une UNV labellisée affichent une mortalité à 30j après AVC ischémique 15-25 % inférieure aux établissements sans UNV (données DREES).
- **Effet week-end IDM** : mortalité 20-30 % supérieure pour les IDM admis le week-end vs semaine dans les établissements sans coronarographie H24 — signal fort pour la permanence des soins interventionnels.

## Limites
- Les décès post-sortie (nécessaires pour la définition complète OCDE) ne sont accessibles qu'au travers du SNDS — les GHT ne disposant pas de cet accès ne peuvent calculer qu'une approximation (mortalité intra-hospitalière seule).
- Le taux de mortalité à 30j est très sensible aux pratiques de transfert : un établissement qui transfère rapidement ses patients IDM/AVC les plus graves dans un CHU affiche artificiellement un faible taux, sans que cela reflète une meilleure qualité de soins.
- L'ajustement sur le risque (âge, comorbidités) est indispensable pour des comparaisons équitables ; le taux brut seul est très biaisé par la structure démographique et le casemix des établissements.
- La mortalité à 30j est un indicateur de résultat distal : elle intègre de nombreux facteurs hors du contrôle de l'établissement (délai de recours du patient, qualité des soins préhospitaliers SAMU, comorbidités).
- Les petits volumes d'IDM et d'AVC dans les établissements périphériques du GHT rendent les taux annuels instables (intervalles de confiance larges) — une agrégation sur 3-5 ans est recommandée.

## Références
- [OCDE - Health at a Glance : 30-day mortality for AMI and stroke](https://www.oecd.org/health/health-at-a-glance.htm)
- [DREES - Mortalité à 30 jours après IDM et AVC en France](https://www.drees.solidarites-sante.gouv.fr/)
- [ScanSanté - Mortalité hospitalière après IDM et AVC](https://www.scansante.fr/)
- [CépiDc INSERM - Données de mortalité post-hospitalière](https://www.cepidc.inserm.fr/)
- [Société Française de Cardiologie - Registre FAST-MI](https://www.sfcardio.fr/)
