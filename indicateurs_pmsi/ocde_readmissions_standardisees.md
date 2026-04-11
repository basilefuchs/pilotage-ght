# OCDE — Réadmissions Standardisées pour AMI, Insuffisance Cardiaque et Diabète

## Définition
Les indicateurs de réadmissions standardisées de l'OCDE mesurent le taux de réhospitalisation non programmée dans les 30 jours suivant un séjour index pour trois pathologies chroniques traceurs : l'infarctus du myocarde aigu (AMI — Acute Myocardial Infarction), l'insuffisance cardiaque congestive et le diabète avec complications. Ces pathologies ont été sélectionnées par l'OCDE car leurs réadmissions sont largement considérées comme évitables par une prise en charge post-hospitalière de qualité (suivi ambulatoire, éducation thérapeutique, coordination ville-hôpital, observance médicamenteuse). Ils constituent un complément indispensable aux indicateurs de mortalité à 30 jours : un établissement peut afficher une faible mortalité mais un fort taux de réadmission, révélant une sortie prématurée non accompagnée. Ces indicateurs sont calculés en France par la DREES et transmis à l'OCDE depuis 2015.

## Calcul
**Structure commune aux trois indicateurs :**
```
Taux de réadmission standardisé (%) = (Réadmissions non programmées à 30j pour toute cause / Séjours index éligibles) × 100

Séjour index = premier séjour MCO pour la pathologie traceur (IDM, IC, diabète)
  → Exclusions : décès durant le séjour index, transfert immédiat vers un autre MCO,
                 réadmission programmée connue à la sortie, absence d'au moins 1 jour entre sortie et réadmission

Réadmission = tout séjour MCO non programmé (mode d'entrée = urgences ou transfert non planifié)
              dans les 30 jours calendaires suivant la date de sortie du séjour index

Standardisation = ajustement indirect sur âge, sexe, comorbidités (Elixhauser ou Charlson)
```

**1. Réadmissions après IDM (AMI) :**
```
Séjour index IDM :
  → DP = I21 (IDM aigu), I22 (IDM récidivant)
  → Âge ≥ 18 ans
  → Exclusion : IDM survenu en cours de séjour pour une autre pathologie (IDM en DA uniquement)

Réadmission toutes causes (J1-J30) :
  → Tout séjour MCO non programmé, quelle que soit la pathologie de réadmission
  → Inclut les réadmissions pour IDM récidivant, insuffisance cardiaque, AVC, complications
```

**2. Réadmissions après insuffisance cardiaque :**
```
Séjour index IC :
  → DP = I50 (insuffisance cardiaque), I11.0 (cardiopathie hypertensive avec IC)
  → Exclusion : séjours de chirurgie cardiaque, transplantation cardiaque, IC secondaire à un IDM aigu

Réadmission toutes causes (J1-J30) :
  → Toute réhospitalisation non programmée, en priorité pour IC décompensée (I50 en DP)
  → Sous-indicateur : réadmission spécifique pour IC (J1-J30, DP = I50)
```

**3. Réadmissions après diabète avec complications :**
```
Séjour index diabète :
  → DP = E10.1-E10.9, E11.1-E11.9, E12-E14 (diabète avec complications)
  → Exclusion : diabète gestationnel (O24), diabète secondaire, séjours pour amputation programmée

Réadmission toutes causes (J1-J30) :
  → Toute réhospitalisation non programmée dans les 30 jours
  → Sous-indicateur : réadmission pour déséquilibre glycémique (E10-E14 en DP)
```

**Méthode d'ajustement OCDE :**
```
Taux attendu_i = f(âge, sexe, Elixhauser score, année, établissement de référence)
Ratio standardisé = Taux observé / Taux attendu
Taux ajusté = Ratio standardisé × Taux national de référence
```

## Transposition PMSI France
La France est l'un des pays ayant validé officiellement ces indicateurs sur PMSI — la transposition est **complète** :

- **Calcul DREES opérationnel** : la DREES calcule et publie annuellement ces trois indicateurs sur données PMSI françaises pour la transmission OCDE, avec méthodologie publique et reproductible.
- **ScanSanté** : le taux de réadmission à 30 jours après IDM et insuffisance cardiaque est disponible par établissement dans ScanSanté, sans nécessiter l'accès SNDS.
- **Chaînage PMSI** : les réadmissions sont identifiées par chaînage du NIR crypté entre séjours consécutifs — accès SNDS requis pour les réadmissions dans d'autres établissements que l'établissement index.
- **Limite intra-établissement** : sans SNDS, seules les réadmissions dans le même établissement sont détectables — les réadmissions dans un autre établissement du GHT ou hors GHT sont manquantes. Le SNDS est nécessaire pour l'indicateur complet toutes structures.
- **Codes CIM-10 identiques** : I21, I22, I50, E10-E14 sont communs à la définition OCDE et à la CIM-10 FR.

## Utilité
- **Évaluation de la qualité du suivi post-hospitalier** : les réadmissions après IDM, IC et diabète sont largement déterminées par la qualité de la transition hôpital-ville (consultation de suivi à J+7-15, délivrance des médicaments, éducation thérapeutique) — cet indicateur mesure donc autant la coordination que la qualité des soins hospitaliers.
- **Comparaison internationale** : le positionnement du GHT dans le référentiel OCDE (40 pays) permet d'identifier un potentiel d'amélioration par rapport aux meilleures pratiques mondiales, notamment scandinaves et néerlandaises.
- **Levier d'action sur la coordination ville-hôpital** : un taux élevé de réadmissions après IC ou diabète cible les actions à mettre en place (consultation post-hospitalisation J+7 systématique, programme ETP, infirmière de coordination cardiologique/diabétologique, HAD de transition).
- **Indicateur du programme CMS Hospital Readmissions Reduction Program** : aux États-Unis, les réadmissions après IDM, IC et pneumonie font l'objet d'une pénalité financière CMS depuis 2013 — la France pourrait adopter un mécanisme similaire ; le GHT qui anticipe cet indicateur se prépare à un éventuel enjeu financier futur.
- **Suivi des programmes de réhabilitation cardiaque** : une réduction du taux de réadmissions après IDM ou IC est un critère d'efficacité des programmes de réadaptation cardiaque (SSR cardiologique) du GHT.

## Sources de Données
- **PMSI MCO** : diagnostic principal (I21, I22, I50, E10-E14), mode d'entrée et de sortie, dates de séjour, NIR crypté pour le chaînage des réadmissions.
- **SNDS** : chaînage inter-établissements pour les réadmissions dans un autre établissement que l'établissement index — accès soumis à autorisation CNIL/INDS.
- **ScanSanté** : taux de réadmission à 30 jours après IDM et IC par établissement, disponible sans accès SNDS (limité aux réadmissions dans le même établissement dans certaines versions).
- **OCDE - Health at a Glance** : taux de référence internationaux pour les trois pathologies traceurs et méthodologie de standardisation.
- **DREES** : publication annuelle des taux français transmis à l'OCDE, avec décomposition par région et par type d'établissement.

## Exemple de Valeurs
- **Réadmissions à 30j après IDM — France** : 12,8 % (OCDE 2022, standardisé). Meilleurs pays : Suède (9,1 %), Pays-Bas (9,8 %). Moins bons : États-Unis (15,9 %).
- **Réadmissions à 30j après IC — France** : 17,5 % (OCDE 2022). Meilleurs pays : Suède (12,3 %), Danemark (14,1 %). Moins bons : Allemagne (21,2 %).
- **Réadmissions à 30j après diabète** : données moins stables, taux français estimés entre 10 et 15 % selon les définitions retenues.
- **Variation inter-établissements France** : taux de réadmission après IC de 10-30 % selon les établissements (données ScanSanté) — forte hétérogénéité signalant des marges d'amélioration importantes.
- **Impact d'une consultation de suivi à J+7** : des études françaises (CNAM, HAS) montrent une réduction de 20-30 % des réadmissions à 30j après IC lorsqu'une consultation médicale est réalisée dans les 7 jours suivant la sortie.
- **Impact du programme ETP diabète** : les programmes d'éducation thérapeutique validés réduisent les réadmissions pour déséquilibre glycémique de 25-40 % sur 12 mois.

## Limites
- Le taux de réadmission est très sensible aux pratiques de sortie : des sorties précoces non accompagnées augmentent mécaniquement les réadmissions, tandis que des durées de séjour longues les réduisent artificiellement — l'indicateur doit toujours être lu conjointement avec la DMS.
- L'identification des réadmissions non programmées nécessite de distinguer les réadmissions urgentes (non prévues) des hospitalisations planifiées (suivi programmé) — cette distinction repose sur le mode d'entrée PMSI (urgences vs programmé), qui n'est pas toujours codé avec précision.
- Sans accès SNDS, seules les réadmissions dans le même établissement sont détectables — les réadmissions dans un autre établissement (fréquentes pour les patients transférés en SSR puis réhospitalisés en MCO) sont manquantes.
- Les comparaisons internationales OCDE sont biaisées par les différences de définition des séjours programmés vs urgents et par les variations de pratiques de codage du mode d'entrée entre pays.
- L'indicateur toutes causes (toute réadmission quelle que soit la pathologie) est moins spécifique que l'indicateur cause-spécifique (réadmission pour la même pathologie) — les deux sont complémentaires et doivent être interprétés ensemble.

## Références
- [OCDE - Health at a Glance : Hospital readmissions for AMI, HF and diabetes](https://www.oecd.org/health/health-at-a-glance.htm)
- [DREES - Réadmissions hospitalières en France : comparaisons OCDE](https://www.drees.solidarites-sante.gouv.fr/)
- [ScanSanté - Taux de réadmission à 30 jours par établissement](https://www.scansante.fr/)
- [HAS - Consultation post-hospitalisation et réadmissions évitables](https://www.has-sante.fr/)
- [CMS - Hospital Readmissions Reduction Program (USA)](https://www.cms.gov/medicare/payment/prospective-payment-systems/acute-inpatient-pps/hospital-readmissions-reduction-program-hrrp)
