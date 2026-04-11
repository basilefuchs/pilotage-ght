# SHMI — Summary Hospital-level Mortality Indicator (NHS England)

## Définition
Le SHMI (Summary Hospital-level Mortality Indicator) est un indicateur de mortalité hospitalière développé par le NHS England et publié trimestriellement depuis 2011 pour l'ensemble des hôpitaux anglais. Il mesure le ratio entre le nombre de décès observés (en cours d'hospitalisation ou dans les 30 jours suivant la sortie) et le nombre de décès attendus compte tenu du casemix de l'établissement, sur 140 groupes de diagnostics représentant environ 80 % de l'activité hospitalière. Un SHMI > 1 indique une mortalité supérieure à celle attendue ; un SHMI < 1 indique une mortalité inférieure. Le SHMI se distingue du HSMR (Hospital Standardised Mortality Ratio, indicateur précédent) par l'inclusion des décès à 30 jours post-sortie — évitant ainsi le biais de transfert (un hôpital qui transfère rapidement ses patients mourants vers une autre structure affiche un HSMR artificiellement bas mais un SHMI correct). Il est considéré comme l'indicateur de mortalité hospitalière le plus robuste et le moins biaisé disponible à partir de données administratives.

## Calcul
Le SHMI est calculé comme suit :

```
SHMI = Nombre de décès observés (intra-hospitaliers + décès à 30j post-sortie) / Nombre de décès attendus

Décès attendus = Σ [P(décès_i) pour chaque séjour i]

P(décès_i) = f(groupe diagnostique, âge, sexe, comorbidités, admission programmée/urgente, mois d'admission)
           = probabilité estimée par régression logistique sur données nationales de référence
```

**Structure du modèle de prédiction :**
```
logit(P(décès)) = β0 + β1×groupe_diagnostic + β2×âge + β3×sexe
                + β4×comorbidités_Charlson + β5×mode_admission + β6×mois

  → 140 groupes diagnostiques (équivalents des CMD/racines GHM français)
  → Ajustement sur 5 classes d'âge (0-14, 15-59, 60-74, 75-84, ≥85 ans)
  → Comorbidités identifiées par codes CIM-10 dans les DA (liste Charlson adaptée)
  → Mode d'admission : programmé vs urgences
  → Mois d'admission : capte les variations saisonnières
```

**Interprétation du SHMI :**
```
SHMI < 0,87  → Mortalité significativement inférieure à l'attendu (bande verte NHS)
SHMI 0,87-1,15 → Dans la norme attendue (bande jaune NHS)
SHMI > 1,15  → Mortalité significativement supérieure à l'attendu (bande rouge NHS)

  → Intervalles de confiance à 95 % calculés par méthode de Poisson pour tenir compte du volume de décès
```

## Transposition PMSI France
La transposition du SHMI au PMSI français est **très favorable**, avec des adaptations bien documentées :

- **Décès intra-hospitaliers** : directement disponibles dans le PMSI via le mode de sortie (code 9 = décès).
- **Décès à 30 jours post-sortie** : nécessitent le chaînage du PMSI avec le Répertoire National d'Identification des Personnes Physiques (RNIPP) ou les données du SNDS (CépiDc) — techniquement faisable via une autorisation SNDS/CNIL.
- **Groupes diagnostiques** : les 140 groupes NHS sont définis par codes CIM-10 et transposables aux codes CIM-10 FR du PMSI ; une table de correspondance avec les CMD/racines de GHM françaises est nécessaire.
- **Variables d'ajustement** : âge, sexe, mode d'entrée (programmé/urgences), comorbidités Charlson et mois d'admission sont tous disponibles dans le PMSI MCO.
- **Expériences françaises** : la DREES et l'ATIH ont publié des adaptations du HSMR/SHMI sur données PMSI françaises, confirmant la faisabilité technique et la valeur ajoutée par rapport au simple taux de mortalité brut.

## Utilité
- **Indicateur de mortalité le plus robuste disponible sur données administratives** : le SHMI corrige les principaux biais du taux de mortalité brut (casemix, âge, mode d'admission, transferts) et est directement comparable entre établissements du GHT et avec les moyennes nationales.
- **Détection précoce des établissements à risque** : un SHMI élevé et persistant est un signal d'alerte justifiant un audit approfondi des pratiques cliniques et organisationnelles, indépendamment de tout événement indésirable déclaré.
- **Inclusion des décès post-sortie** : le SHMI évite le biais de transfert qui faussait le HSMR — un GHT transférant ses patients les plus graves vers le CHU n'affiche plus artificiellement une bonne mortalité.
- **Communication publique et gouvernance** : le NHS publie le SHMI de chaque hôpital anglais ; son adoption en France permettrait une transparence comparable sur la performance des GHT, dans le cadre du programme de transparence porté par la HAS.
- **Suivi longitudinal** : l'évolution du SHMI sur 3-5 ans mesure l'impact des politiques d'amélioration de la qualité et de sécurité des soins mises en place par le GHT.

## Sources de Données
- **PMSI MCO** : mode de sortie (décès = code 9), codes CIM-10 (DP, DR, DA), âge, sexe, mode d'entrée, dates de séjour — pour les décès intra-hospitaliers et les variables d'ajustement.
- **SNDS / CépiDc (Centre d'épidémiologie sur les causes de décès)** : chaînage avec les données d'état civil pour les décès à 30 jours post-sortie — accès soumis à autorisation CNIL/INDS.
- **ATIH - Base nationale PMSI** : données nationales de référence pour calibrer le modèle de prédiction (calcul des décès attendus).
- **Référence méthodologique NHS** : NHS Digital, *Summary Hospital-level Mortality Indicator (SHMI) Methodology*, mise à jour trimestrielle.
- **Référence française** : DREES, *Le taux de mortalité hospitalière standardisé*, Études et Résultats, série adaptations françaises.

## Exemple de Valeurs
- **SHMI national NHS (Angleterre)** : distribution centrée sur 1,0 par construction ; les établissements en bande rouge (>1,15) représentent environ 15-20 % des hôpitaux anglais.
- **Variation inter-établissements** : SHMI observés entre 0,60 et 1,60 selon les établissements anglais, avec une réduction progressive de la dispersion depuis 2011.
- **Pathologies les plus contributives** : pneumonie, insuffisance cardiaque, AVC, sepsis, et chirurgie colorectale contribuent le plus aux écarts de SHMI entre établissements.
- **Effet week-end** : le NHS a documenté un SHMI 10-15 % plus élevé pour les admissions du week-end vs les admissions en semaine — un signal organisationnel majeur, retrouvé dans les adaptations françaises.
- **Adaptations françaises** : les études DREES sur le HSMR France montrent une variation inter-établissements comparable à celle observée au Royaume-Uni, avec un effet casemix fort justifiant l'ajustement.

## Limites
- **Accès aux décès post-sortie** : le chaînage PMSI-CépiDc nécessaire pour les décès à 30 jours est soumis à des autorisations réglementaires complexes (SNDS, CNIL) ; sans ce chaînage, seule la mortalité intra-hospitalière est accessible, ce qui correspond davantage au HSMR qu'au SHMI complet.
- **Biais de sélection résiduel** : malgré l'ajustement sur le casemix, le SHMI ne corrige pas tous les facteurs confondants (précarité sociale, sévérité clinique non codée, qualité du codage) ; deux établissements avec le même SHMI peuvent avoir des pratiques très différentes.
- **Dépendance au codage** : un codage exhaustif des comorbidités (DA) est indispensable pour un bon ajustement ; un sous-codage des DA sous-estime les décès attendus et surestime le SHMI de l'établissement.
- **Interprétation prudente** : un SHMI élevé n'est pas nécessairement le signe d'une mauvaise qualité des soins ; il peut refléter une patientèle plus fragile non captée par l'ajustement, ou un recours plus fréquent aux soins palliatifs (décès intra-hospitalier souhaité).
- **Calibration nationale requise** : le modèle de prédiction doit être calibré sur des données françaises récentes (et non anglaises) pour produire des décès attendus pertinents — un modèle non recalibré produit des SHMI biaisés.

## Références
- [NHS Digital - SHMI Methodology and Technical Specification](https://digital.nhs.uk/data-and-information/publications/statistical/shmi)
- [DREES - Mortalité hospitalière standardisée en France](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH - Indicateurs de mortalité sur données PMSI](https://www.atih.sante.fr/)
- [CépiDc INSERM - Données de causes de décès](https://www.cepidc.inserm.fr/)
- [SNDS - Chaînage PMSI et données d'état civil](https://www.snds.gouv.fr/)
