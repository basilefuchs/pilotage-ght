# Taux de Morbidité Maternelle Sévère (SMM)

## Définition
Le taux de morbidité maternelle sévère (SMM — Severe Maternal Morbidity) mesure la proportion d'accouchements associés à au moins l'une des complications potentiellement mortelles survenant pendant ou jusqu'à 42 jours après l'hospitalisation pour accouchement. Développé par les Centers for Disease Control and Prevention (CDC) américains et adapté dans de nombreux pays, le SMM est un composite de 21 indicateurs ICD-10 couvrant les complications les plus graves de la périnatalité : hémorragie du post-partum nécessitant une transfusion, sepsis puerpéral, embolie amniotique, ventilation mécanique, hystérectomie d'hémostase, insuffisance rénale aiguë, arrêt cardiaque, coagulopathie sévère. En France, la mortalité maternelle est rare (moins de 100 décès par an) et sous-puissante pour le pilotage local — le SMM, 100 fois plus fréquent, constitue un indicateur sentinelle beaucoup plus sensible et actionnable des dysfonctionnements de la prise en charge obstétricale. Il est calculable depuis le PMSI MCO sur la CMD 14 (grossesse, accouchement, puerpéralité) en croisant les codes diagnostiques CIM-10 O00-O99 avec les codes d'actes CCAM obstétricaux. Hitti et al. (Am J Obstet Gynecol 2018) ont démontré que le SMM est fortement associé aux troubles hypertensifs de la grossesse, à la prématurité et aux inégalités sociales, trois dimensions directement explorables dans le PMSI.

## Calcul
Le SMM est calculé depuis les séjours PMSI MCO de la CMD 14 :

```
Séjour index = tout séjour MCO avec accouchement comme motif principal
  → GHM CMD 14 : 14Z02A à 14Z20Z (accouchements normaux, césariennes, pathologiques)
  → Actes CCAM d'accouchement : JQGD001 (accouchement par voie basse),
    JQGC001 (césarienne)

Séjour avec SMM = séjour index présentant ≥1 code CIM-10 parmi les 21 indicateurs SMM
  en DP ou DA (ou dans un séjour dans les 42 jours suivant le séjour index)

Taux de SMM (‰) = (Accouchements avec SMM / Total accouchements) × 1000
```

**Liste des 21 indicateurs SMM (codes CIM-10 FR) :**
```
Hémorragie et coagulopathie :
  → O67.* : hémorragie du travail avec coagulopathie
  → O72.* : hémorragie du post-partum
  → D65    : CIVD (coagulopathie intravasculaire disséminée)
  → Z51.3  : transfusion de sang total ou de concentrés érythrocytaires (CCAM : FELF004)

Sepsis et infection grave :
  → O85    : sepsis puerpéral (fièvre puerpérale)
  → A40.*, A41.* : sepsis bactérien (en DA sur séjour obstétrical)

Défaillances organiques :
  → J96.*  : insuffisance respiratoire aiguë / ventilation mécanique
  → N17.*  : insuffisance rénale aiguë
  → I46.*  : arrêt cardiaque
  → R57.*  : choc (hémorragique, septique, cardiogénique)

Embolie :
  → O88.*  : embolie obstétricale (amniotique, gazeuse, thromboembolique)
  → I26.*  : embolie pulmonaire

Procédures d'urgence :
  → O90.3  : déhiscence de cicatrice de césarienne
  → Hystérectomie totale ou partielle en urgence (CCAM : JLFC002, JLFC004)
  → Ligature des artères iliaques (CCAM : EBLA001, EBLA002)

Autres complications graves :
  → O26.6  : lésions hépatiques de la grossesse
  → O15.*  : éclampsie
  → O14.1  : pré-éclampsie sévère
  → G00-G09 : méningite / encéphalite (sur séjour obstétrical)
  → I60-I62 : hémorragie intracrânienne (sur séjour obstétrical)
```

**Sous-indicateurs dérivés :**
```
Taux de SMM par type de complication (‰) :
  → SMM hémorragique (hémorragie + transfusion + hystérectomie) : composante la plus fréquente
  → SMM infectieux (sepsis puerpéral + A40-A41) : deuxième composante en fréquence
  → SMM thromboembolique (O88, I26) : composante la plus grave

Taux de SMM par mode d'accouchement :
  → SMM voie basse vs SMM césarienne programmée vs SMM césarienne en urgence
  → La césarienne en urgence a un SMM 3-5× supérieur à la voie basse normale

Taux de SMM par profil de risque :
  → SMM chez les patientes avec trouble hypertensif (O10-O16) : risque × 5
  → SMM chez les patientes avec comorbidités (obésité, diabète) : stratification par CMD/DA
  → SMM chez les patientes de 40 ans et plus : risque × 2-3 vs 20-30 ans

Taux de SMM par établissement (‰) ajusté sur casemix obstétrical :
  → Ajustement sur : âge maternel, parité, comorbidités pré-existantes, mode d'accouchement prévu
  → Comparaison inter-maternités du GHT et avec la moyenne régionale / nationale
```

## Utilité
- **Indicateur sentinelle de la sécurité obstétricale, 100× plus sensible que la mortalité maternelle** : avec 100-150 décès maternels par an en France et plusieurs milliers de SMM, l'indicateur permet un pilotage local et un suivi temporel inaccessibles avec la seule mortalité maternelle — chaque maternité du GHT peut calculer son taux et le faire évoluer.
- **Évaluation des protocoles d'urgence obstétricale** : mesurer l'évolution du taux de SMM hémorragique avant/après la mise en place d'un protocole hémorragie du post-partum (HPP), d'un accès 24h/24 au bloc opératoire ou d'une simulation en équipe — l'indicateur quantifie l'impact organisationnel de ces interventions.
- **Identification des facteurs de risque locaux** : croiser le SMM avec les caractéristiques maternelles codées en PMSI (âge, comorbidités O10-O16, obésité Z68.*, précarité Z59-Z65) pour cibler les patientes à surveiller en prépartum et dimensionner les ressources en salle de naissance.
- **Benchmarking régional et dialogue ARS** : le SMM est calculable pour toutes les maternités françaises depuis ScanSanté (GHM CMD 14 + DA) — une maternité du GHT avec un SMM structurellement supérieur à la moyenne de son niveau (type I, II, III) déclenche un audit de pratiques et peut justifier un repositionnement dans la filière obstétricale du GHT.
- **Surveillance des inégalités sociales en obstétrique** : croiser le SMM avec le score de vulnérabilité sociale (`score_vulnerabilite_sociale.md`) ou le FDep par commune pour documenter le gradient social du risque obstétrical et cibler les interventions de prévention prénatale.

## Sources de Données
- **PMSI MCO local (DIM)** : CMD 14, GHM d'accouchement, codes CIM-10 en DP et DA — calcul réalisable par le DIM sur les données locales sans accès SNDS.
- **ScanSanté** : filtrage des GHM CMD 14 avec codes de complication en DA — permet une comparaison entre maternités sur les taux bruts de SMM par type de complication.
- **SNDS (chaînage sur 42 jours)** : pour inclure les complications survenant dans les 42 jours suivant la sortie (réadmissions pour complication post-partum) — la définition complète du SMM nécessite ce chaînage longitudinal.
- **ENQUÊTE NATIONALE PÉRINATALE (ENP — DREES/INSERM)** : fournit les prévalences de référence du SMM en France (tous les 3-4 ans) — référence pour valider la cohérence des valeurs calculées depuis le PMSI.

## Exemple de Valeurs
- **Taux de SMM global (France)** : 8-12 ‰ accouchements selon les études, dont 1-2 ‰ pour la transfusion seule (composante la plus fréquente).
- **SMM hémorragique** : 5-8 ‰ accouchements ; l'hémorragie du post-partum (O72.*) est la première cause de SMM en France.
- **SMM infectieux** : 1-2 ‰ accouchements ; en augmentation depuis la pandémie COVID-19.
- **Jairam et al. (JAMA Netw Open 2023)** — cohorte canadienne de 414 337 naissances : taux de SMM de 16,6-17,1 ‰ en population défavorisée — souligne l'impact de la précarité sur le risque obstétrical.
- **Hitti et al. (Am J Obstet Gynecol 2018)** — 7 025 accouchements, CHU de Washington : 4 % de SMM, risque × 5,4 pour la pré-éclampsie sévère.
- **Écart inter-maternités** : le SMM varie de 1 à 5 entre maternités françaises de même niveau selon les études d'audit clinique — signal fort d'un levier d'amélioration organisationnelle.

## Limites
- Le SMM calculé depuis le PMSI est un proxy des complications documentées et codées — la qualité du codage obstétrical varie fortement entre maternités (certains établissements codent systématiquement les transfusions en DA, d'autres non) et biaise les comparaisons inter-établissements.
- L'absence de flag "présent à l'admission" (POA) dans le PMSI empêche de distinguer les complications préexistantes à l'accouchement (pré-éclampsie connue dès l'admission) des complications survenues pendant le séjour — le SMM PMSI peut surestimer les événements évitables.
- La définition des 21 indicateurs CDC a été validée dans le système ICD-10-CM américain — certains codes n'ont pas d'équivalent exact en CIM-10 FR, nécessitant une adaptation et une validation locale avant utilisation.
- Le SMM mesure la survenue de complications graves mais pas leur gravité intrinsèque ni le processus de prise en charge — une transfusion prophylactique pour HPP mineure et une hystérectomie d'hémostase en urgence sont comptabilisées de la même façon dans le composite.
- Les maternités de niveau III (avec réanimation néonatale et maternelle) attirent les grossesses les plus à risque — le SMM brut d'une maternité de niveau III sera mécaniquement plus élevé que celui d'une maternité de niveau I ; un ajustement sur le niveau de maternité et les comorbidités préexistantes est indispensable pour toute comparaison.

## Références
- [Hitti J. et al. — Contribution of hypertension to severe maternal morbidity, Am J Obstet Gynecol 2018](https://doi.org/10.1016/j.ajog.2018.07.002)
- [Jairam J.A. et al. — Severe maternal morbidity among immigrant and Canadian-born women, JAMA Network Open 2023](https://doi.org/10.1001/jamanetworkopen.2022.56203)
- [CDC — Severe Maternal Morbidity Indicators and Corresponding ICD Codes](https://www.cdc.gov/maternal-infant-health/php/severe-maternal-morbidity/index.html)
- [DREES / INSERM — Enquête Nationale Périnatale : prévalence des complications obstétricales](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH — PMSI MCO CMD 14 : classification des séjours obstétricaux](https://www.atih.sante.fr/)
