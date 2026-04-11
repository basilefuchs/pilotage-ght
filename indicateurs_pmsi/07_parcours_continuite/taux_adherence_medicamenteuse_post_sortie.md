# Taux d'Adhérence Médicamenteuse Post-Hospitalisation (PDC)

## Définition
Le taux d'adhérence médicamenteuse post-hospitalisation mesure, pour les patients sortis d'une hospitalisation MCO, la proportion de jours effectivement couverts par leurs médicaments-clés dans les 90 jours suivant la sortie — métrique connue sous le nom de PDC (Proportion of Days Covered). Calculé depuis les dispensations pharmaceutiques du DCIR (Données de Consommation Inter-Régimes), il capture un phénomène paradoxal bien documenté dans la littérature internationale : l'hospitalisation est associée à une **réduction** de l'adhérence aux traitements chroniques, non à une amélioration. Pham Nguyen et al. (*Pharmacotherapy* 2020) ont démontré sur 22 429 patients porteurs de fibrillation atriale que le PDC aux anticoagulants oraux chutait significativement après toute hospitalisation, indépendamment du motif. Cette rupture thérapeutique post-hospitalière est un facteur de risque indépendant de réadmission à 30 jours, de mortalité cardiovasculaire et d'événements thromboemboliques — directement actionnable par des programmes de coordination pharmacien-médecin traitant lors de la transition de sortie. Le DCIR complet permet de calculer le PDC pour chaque classe médicamenteuse d'intérêt en croisant les dispensations pharmaceutiques (avec code CIP13 du médicament) et les dates de sortie PMSI.

## Calcul
Le PDC est calculé en croisant les données PMSI (date de sortie) et DCIR (dispensations pharmaceutiques) :

```
PDC (Proportion of Days Covered) sur 90 jours post-sortie :

PDC = Nombre de jours couverts par le médicament dans la fenêtre [J0+1 ; J0+90] / 90

Jour couvert = jour inclus dans une période de dispensation active
  → Dispensation active : une boîte délivrée couvre N jours selon la DDD (Defined Daily Dose)
    ou la durée de traitement inscrite sur l'ordonnance (non disponible en DCIR — utiliser DDD)

PDC ≥ 0,80 = adhérence satisfaisante (seuil international standard)
PDC < 0,80 = non-adhérence cliniquement significative

Taux d'adhérence satisfaisante (%) = (Patients avec PDC ≥ 0,80 / Total patients traités) × 100
```

**Classes médicamenteuses d'intérêt et codes CIP/ATC :**
```
Anticoagulants oraux (FA, MTEV) :
  → AVK : warfarine (ATC B01AA03), fluindione (B01AA12), acénocoumarol (B01AA07)
  → AOD : rivaroxaban (B01AF01), apixaban (B01AF02), dabigatran (B01AE07), édoxaban (B01AF03)

Statines (post-IDM, prévention cardiovasculaire) :
  → ATC C10AA* : simvastatine, atorvastatine, rosuvastatine, pravastatine

Antidiabétiques (diabète type 2) :
  → ATC A10B* : metformine, sulfamides, inhibiteurs SGLT2, analogues GLP-1

Antihypertenseurs (insuffisance cardiaque, HTA) :
  → IEC / ARA2 : ATC C09A*, C09C*
  → Bêtabloquants : ATC C07A*

Traitements de fond en pneumologie :
  → Bronchodilatateurs longue durée (LABA/LAMA) : ATC R03A*, R03B*
```

**Sous-indicateurs dérivés :**
```
Délai médian de première dispensation post-sortie (jours) :
  → J0 = date de sortie PMSI
  → Délai = date de première dispensation du médicament cible − J0
  → Un délai > 7 jours signale une rupture précoce dans la transition de soins

Taux de primo-dispensation à J+7 (%) :
  = (Patients ayant retiré le médicament dans les 7 jours / Total patients traités avant hospitalisation) × 100
  → Indicateur d'alerte rapide : un patient qui ne retire pas son traitement dans la semaine
    suivant sa sortie a un risque de non-adhérence à 3 mois × 2 à 3

PDC par classe médicamenteuse et par CMD :
  → Compare l'adhérence selon le motif d'hospitalisation et la pathologie de fond
  → Identifie les filières où la rupture thérapeutique est la plus fréquente

Taux de modification thérapeutique à la sortie :
  → Proportion de patients dont le traitement a été modifié (ajout, suppression, changement de molécule)
    à la sortie hospitalière vs traitement en cours avant l'hospitalisation (DCIR pré-entrée)
  → Les changements de molécule à la sortie sont associés à une réduction du PDC (Pham Nguyen 2020)
```

**Précisions méthodologiques :**
- La DDD (Defined Daily Dose) de l'OMS est utilisée pour estimer la durée de couverture d'une boîte dispensée, en l'absence de la durée de prescription dans le DCIR.
- La fenêtre de 90 jours est le standard international pour la mesure du PDC post-hospitalier ; une fenêtre de 30 jours peut être utilisée pour les indicateurs de transition de soins rapides.
- Le DCIR trace les dispensations en pharmacie de ville uniquement — les médicaments rétrocédés par la pharmacie hospitalière ou délivrés lors de consultations externes hospitalières ne sont pas dans le DCIR et peuvent conduire à sous-estimer le PDC réel.
- Le calcul nécessite de chaîner les séjours PMSI (date de sortie, diagnostic principal) avec les dispensations DCIR (date, CIP13) par NIR crypté.

## Utilité
- **Identification précoce des patients à risque de rupture thérapeutique** : le délai de première dispensation à J+7 est un signal d'alerte exploitable dès la première semaine post-sortie — il permet au pharmacien correspondant ou à l'infirmière de coordination de contacter le patient avant que la rupture ne se transforme en décompensation et réadmission.
- **Évaluation des programmes de réconciliation médicamenteuse** : mesurer l'évolution du PDC avant/après la mise en place d'un bilan de médication de sortie (BMO) ou d'un entretien pharmaceutique de transition pour quantifier l'impact de ces interventions sur l'adhérence réelle.
- **Dialogue avec la CNAM et les CPAM** : le taux d'adhérence post-hospitalière est un indicateur des Contrats d'Amélioration de la Qualité et de l'Efficience des Soins (CAQES) — les données DCIR permettent au GHT de produire ses propres indicateurs sans attendre les publications CNAM, et d'engager un dialogue factuel sur les leviers de coordination ville-hôpital.
- **Stratification du risque de réadmission** : intégrer le PDC à J+30 comme variable prédictive dans le score de réhospitalisation (`score_predictif_rehospitalisation.md`) — un PDC < 0,50 dans les 30 premiers jours post-sortie multiplie le risque de réadmission par 1,5 à 2,5 selon la pathologie.
- **Pilotage des filières chroniques** : comparer le PDC des patients insuffisants cardiaques, diabétiques, fibrillateurs auriculaires et BPCO pour identifier la filière où la rupture thérapeutique est la plus fréquente et y concentrer les ressources de coordination.
- **Évaluation du changement de molécule à la sortie** : les hospitalisations qui conduisent à un changement de classe médicamenteuse (ex. warfarine → AOD, clopidogrel → ticagrélor) sont associées à une réduction du PDC à 6 mois — l'indicateur guide les protocoles de switch thérapeutique et de suivi pharmacologique.

## Sources de Données
- **DCIR (SNDS)** : table ER_PRS_F (prestations remboursées) + table ER_PHA_F (dispensations pharmaceutiques avec code CIP13 et date de délivrance) — source principale pour le calcul du PDC.
- **PMSI MCO** : date de sortie (champ DATSOR du RSA), diagnostic principal (DP), GHM — pour identifier la fenêtre post-hospitalière et le motif de l'hospitalisation index.
- **Référentiel ATC/DDD (OMS)** : pour calculer la durée de couverture de chaque dispensation selon la Defined Daily Dose de chaque molécule.
- **Référentiel médicaments (BDPM — Base de Données sur les Médicaments)** : correspondance CIP13 → DCI → classe ATC — disponible en open data sur data.ansm.santé.fr.

## Exemple de Valeurs
- **PDC moyen anticoagulants oraux à 90 jours post-hospitalisation** : 72-78 % dans les études claims américaines (Pham Nguyen 2020) — en dessous du seuil de 80 % même pour les patients préalablement adhérents.
- **Réduction du PDC après hospitalisation** : baisse moyenne de 3-5 points de PDC dans les 90 jours post-sortie vs les 90 jours précédant l'hospitalisation, indépendamment du motif d'admission.
- **Impact du changement de molécule à la sortie** : le passage de warfarine à un AOD est associé à une réduction du PDC de 3,4 % supplémentaires (Pham Nguyen 2020) — paradoxe de la transition vers des molécules perçues comme plus simples.
- **Taux de primo-dispensation à J+7** : 60-70 % des patients retirent leur traitement dans les 7 premiers jours post-sortie en France selon les études CNAM — 30-40 % sont déjà en rupture précoce.
- **MPR (Medication Possession Ratio) anticoagulants post-SCA** : 76-88 % selon la molécule (Peasah 2022) — les nouveaux agents (ticagrélor) ont une meilleure adhérence que le clopidogrel.
- **Impact sur les réadmissions** : les patients avec PDC < 0,80 à 90 jours ont un taux de réadmission à 1 an de 2 à 3 fois supérieur aux patients adhérents pour les pathologies cardiovasculaires chroniques.

## Limites
- Le PDC calculé depuis le DCIR mesure la **dispensation**, pas la prise effective du médicament — un patient qui retire sa boîte à la pharmacie mais ne la prend pas aura un PDC élevé ; la dispensation est un proxy nécessaire mais imparfait de l'adhérence réelle.
- Les médicaments délivrés par la pharmacie à usage intérieur (PUI) hospitalière lors des consultations de suivi ou de la sortie (dotation de départ) ne figurent pas dans le DCIR — la durée de couverture de la première boîte fournie par l'hôpital est inconnue, créant un délai artificiel avant la première dispensation en pharmacie de ville.
- Le calcul de la durée de couverture par DDD est une approximation : la posologie réelle prescrite peut différer de la DDD de l'OMS, surtout pour les patients fragiles ou en titration.
- L'indicateur ne distingue pas la non-adhérence volontaire (refus ou arrêt délibéré) de la non-adhérence involontaire (oubli, coût, accès) — deux situations aux interventions très différentes.
- Pour les patients bénéficiant de dispensations à l'unité ou de piluliers automatisés, la granularité du DCIR peut être insuffisante pour calculer précisément le PDC.

## Références
- [Pham Nguyen T.P. et al. — Impact of hospitalization and medication switching on post-discharge adherence to oral anticoagulants in AF, Pharmacotherapy 2020](https://doi.org/10.1002/phar.2457)
- [Peasah S.K. et al. — Real-world use and outcomes of oral antiplatelets after ACS, Drugs Real World Outcomes 2022](https://doi.org/10.1007/s40801-021-00283-2)
- [CNAM — Indicateurs CAQES : adhérence médicamenteuse dans les pathologies chroniques](https://www.ameli.fr/)
- [SNDS — DCIR table ER_PHA_F : dispensations pharmaceutiques](https://www.snds.gouv.fr/)
- [ANSM — Base de Données sur les Médicaments (BDPM) : référentiel CIP13/ATC](https://base-donnees-publique.medicaments.gouv.fr/)
