# Délai Porte-Aiguille et Porte-Ponction dans la Filière AVC

## Définition

Le délai porte-aiguille (door-to-needle time, DNT) mesure le temps écoulé entre l'arrivée du patient aux urgences et le début de la thrombolyse IV (injection d'alteplase ou de ténecteplase) pour un AVC ischémique. Le délai porte-ponction (door-to-puncture time, DPT) mesure le temps entre l'arrivée et le temps d'accès artériel pour la thrombectomie mécanique. Ces deux indicateurs sont des mesures directes de la rapidité et de l'efficience de la filière AVC — chaque réduction de 15 minutes du DNT est associée à une augmentation de 4 % de la probabilité de bon pronostic neurologique (Fonarow et al., JAMA 2014). En France, ces indicateurs sont suivis dans le cadre du Programme National AVC (PNA) et par le réseau des Unités Neurovasculaires (UNV). Les cibles sont : DNT ≤ 60 minutes (standard international) et DPT ≤ 90 minutes. Ces indicateurs sont traçables depuis le PMSI via les horodatages des actes et les codes CCAM de thrombolyse et de thrombectomie, complétés par les données du passage aux urgences (RPU — Résumé de Passage aux Urgences).

## Calcul

Les deux indicateurs principaux sont calculés à partir du couplage entre les données PMSI MCO (actes CCAM horodatés) et les données RPU (heure d'arrivée aux urgences).

```
Indicateur 1 — Délai porte-aiguille (DNT) :
  Numérateur   : heure d'injection du thrombolytique (acte CCAM : NLPP001 — thrombolyse IV AVC)
  Dénominateur : heure d'arrivée aux urgences (RPU : DIARR)
  DNT = heure injection − heure arrivée urgences (en minutes)

  Taux DNT ≤ 60 min (%) = (Patients AVC ischémique thrombolysés avec DNT ≤ 60 min /
                            Total patients AVC ischémique thrombolysés) × 100
  Objectif national : ≥ 80% des patients thrombolysés avec DNT ≤ 60 min

Indicateur 2 — Délai porte-ponction (DPT) :
  Numérateur   : heure de ponction artérielle fémorale (acte CCAM : thrombectomie mécanique intracrânienne)
  Dénominateur : heure d'arrivée aux urgences (RPU : DIARR)
  DPT = heure ponction − heure arrivée urgences (en minutes)

  Taux DPT ≤ 90 min (%) = (Patients AVC ischémique thrombectomisés avec DPT ≤ 90 min /
                             Total patients AVC ischémique thrombectomisés) × 100
  Objectif national : ≥ 50% des patients thrombectomisés avec DPT ≤ 90 min

Population cible :
  → AVC ischémique : CIM-10 I63 (infarctus cérébral) en DP
  → Thrombolyse IV : acte CCAM NLPP001 (ou équivalent selon version CCAM)
  → Thrombectomie mécanique : acte CCAM NZEP001/NZFP001 (thrombectomie intracrânienne)
  → Sélection : mode entrée = urgences (8), provenance = domicile/SMUR

Délai terrain-imagerie (onset-to-CT) — sous-indicateur complémentaire :
  → Délai entre heure de début des symptômes (DATEDEB dans RPU si renseigné)
    et heure de réalisation du scanner/IRM cérébral
  → Objectif : scanner < 25 min après arrivée, IRM < 35 min

Taux de thrombolyse des AVC ischémiques éligibles (%) :
  = (AVC ischémiques thrombolysés / AVC ischémiques avec fenêtre thérapeutique ≤ 4h30) × 100
  → Indicateur de sous-utilisation de la thrombolyse
```

## Utilité

- **Benchmark de la filière neurovasculaire du GHT** : comparer les DNT et DPT de l'UNV du GHT par rapport aux données nationales SFNV/RoPAS pour identifier les marges d'amélioration dans l'organisation interne (pré-notification SAMU, IRM dédiée, protocole 24h/24)
- **Identification des goulots d'étranglement organisationnels** : analyser la distribution des DNT (percentiles 25/50/75/90) pour distinguer les retards liés à l'imagerie, à la décision médicale, ou à la dispensation du médicament — chaque composante cible une action d'amélioration différente
- **Évaluation des programmes d'amélioration stroke** : mesurer l'évolution du DNT et du DPT après des interventions organisationnelles (pré-notification par le SAMU, protocole IRM en mode dégradé, garde neuroradiologie 24h/24)
- **Pilotage du réseau territorial AVC** : pour les établissements satellites du GHT sans UNV, mesurer le délai de transfert vers l'UNV référente — le délai porte-ponction inclut le temps de transport inter-hospitalier
- **Dialogue avec l'ARS et la SFNV** : les indicateurs DNT/DPT sont utilisés dans les accréditations UNV et les évaluations des centres de thrombectomie — le GHT peut produire ses propres données sans attendre les publications nationales
- **Corrélation avec les outcomes neurologiques** : croiser DNT avec la mortalité à 30j (SHMI) et le taux de déficit neurologique résiduel (handicap à la sortie, codé en PMSI) pour démontrer l'impact clinique des délais

## Sources de Données

- **PMSI MCO RSA** : diagnostic principal CIM-10 I63 (infarctus cérébral), actes CCAM thrombolyse (NLPP001) et thrombectomie (NZEP001/NZFP001), horodatages des actes si renseignés dans le dossier patient
- **RPU — Résumé de Passage aux Urgences** : heure d'arrivée aux urgences (champ DIARR), heure de début des symptômes (DATEDEB si renseigné), via le réseau SU/OSCOUR (SFMU)
- **SFNV/RoPAS** : registre national AVC, données de référence nationales pour le benchmarking des délais et des taux de traitement des UNV françaises
- **Données SAMU/SMUR** : délai appel-arrivée hôpital, informations de pré-notification permettant de caractériser le circuit pré-hospitalier

## Exemple de Valeurs

- **Médiane DNT nationale France (RoPAS 2022)** : environ 50-55 minutes ; 60-70 % des patients thrombolysés atteignent DNT ≤ 60 min
- **Benchmark international (centres les plus performants)** : médiane DNT de 20-30 minutes (protocole d'Helsinki)
- **Impact d'une réduction de 15 min du DNT** : +4 % d'augmentation absolue de bon pronostic neurologique à 3 mois (Rankin modifié ≤ 2)
- **Médiane DPT France (centres de thrombectomie)** : environ 90-110 minutes dans les centres de référence
- **Sous-utilisation de la thrombolyse en France** : environ 10-15 % des patients AVC ischémiques éligibles reçoivent la thrombolyse IV (contre 20-25 % dans les pays scandinaves)
- **Impact des protocoles organisationnels (pré-notification SAMU)** : réduction du DNT de 15-20 minutes dans les études d'amélioration de la qualité

## Limites

- Les horodatages précis (heure d'injection) ne sont pas systématiquement renseignés dans le PMSI RSA — leur disponibilité dépend de la complétude des champs d'horodatage PMSI, qui varie selon les établissements et les versions du logiciel DIM
- Le couplage RPU (heure d'arrivée urgences) × PMSI (acte CCAM) par identifiant patient nécessite un chaînage inter-bases — faisable via NIR crypté ou identifiant patient local, mais requiert un accès aux données RPU du réseau OSCOUR
- L'indicateur ne capture que les AVC ischémiques arrivant directement aux urgences — les AVC diagnostiqués en hospitalisation (évolution per-hospitalière) ou transférés d'un autre établissement ont un parcours différent, exclu du calcul standard du DNT
- La fenêtre thérapeutique de la thrombolyse (≤ 4h30 ou ≤ 9h avec IRM de perfusion) rend difficile la définition automatique des patients "éligibles" depuis le PMSI seul — un dénominateur approximatif basé sur I63 et le délai apparition-admission est nécessaire
- Les patients sous anticoagulants, avec chirurgie récente, ou avec contre-indication à la thrombolyse sont codés en PMSI mais les contre-indications ne sont pas facilement extractibles — le taux de thrombolyse des "éligibles" peut être sous-estimé si les contre-indications ne sont pas filtrées

## Références

- [Fonarow G.C. et al. — Door-to-needle times for tissue plasminogen activator administration and clinical outcomes in acute ischemic stroke before and after a quality improvement initiative, JAMA 2014](https://doi.org/10.1001/jama.2014.13985)
- [SFNV — Registre RoPAS : indicateurs qualité des UNV françaises](https://www.sfnv.net/)
- [HAS — Indicateurs IQSS AVC : taux de thrombolyse et délai porte-aiguille](https://www.has-sante.fr/)
- [ESO (European Stroke Organisation) — Guidelines for management of ischaemic stroke 2021](https://doi.org/10.1177/23969873211042948)
- [ATIH — PMSI MCO : actes CCAM thrombolyse et thrombectomie cérébrale](https://www.atih.sante.fr/)
