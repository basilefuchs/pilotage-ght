# Demi-Vie Thérapeutique Post-Hospitalisation

## Définition
La **demi-vie thérapeutique post-hospitalisation** (T½) est le temps médian après lequel 50 % des patients d'un groupe homogène de malades (GHM) donné ont présenté un premier recours non programmé aux soins aigus — réhospitalisation non programmée, passage aux urgences ou consultation en urgence chez un spécialiste — après leur sortie. Le concept est emprunté à la physique nucléaire : dans la désintégration radioactive, la demi-vie est le temps au bout duquel la moitié des noyaux instables se sont désintégrés, selon une loi de décroissance exponentielle N(t) = N₀ × e^(−λt) où λ = ln(2)/T½. Appliquée à la médecine hospitalière, la "population" instable est celle des patients qui n'ont pas encore rechuté après leur sortie, λ est le taux instantané de recours non programmé (hazard rate de la survie sans événement aigu), et T½ est la médiane de survie sans événement calculée par l'estimateur de Kaplan-Meier. Plus T½ est court, plus le bénéfice thérapeutique de l'hospitalisation se dissipe rapidement — et plus le suivi ambulatoire post-sortie doit être précoce et intense pour intercepter la rechute avant qu'elle ne génère une nouvelle hospitalisation. Plus T½ est long, plus l'hospitalisation a produit un effet stabilisateur durable, signalant une prise en charge complète et un retour à un état d'équilibre robuste.

La demi-vie thérapeutique est fondamentalement différente du [[taux_readmission|taux de réadmission à 30 jours]] : ce dernier mesure un résultat binaire à un instant fixe arbitraire, là où T½ caractérise la cinétique complète de la décroissance du bénéfice — une information beaucoup plus riche pour calibrer l'intensité et le calendrier du suivi post-sortie.

## Calcul

### 1. Modèle de décroissance exponentielle

```
Loi de survie sans recours aigu :
  S(t) = exp(−λ × t)   avec λ = taux de hazard instantané (supposé constant)

Demi-vie thérapeutique :
  T½ = ln(2) / λ = 0,693 / λ

Estimation empirique (Kaplan-Meier) :
  T½_KM = temps t* tel que S_KM(t*) = 0,50
  → médiane de la courbe de survie sans événement aigu post-sortie

Événements comptabilisés comme "désintégration" :
  - Réhospitalisation MCO non programmée (mode d'entrée = 8 ou transfert urgent)
  - Passage aux urgences sans hospitalisation (RPU)
  - Consultation non programmée en médecine de ville dans les 48h suivant la sortie (DCIR)
```

### 2. Constante de désintégration par GHM (λ_GHM)

```
λ_GHM = − ln(1 − Taux_réadmission_30j_GHM) / 30

  → Estimation rapide à partir du taux de réadmission à 30 jours
    quand l'analyse de survie complète n'est pas disponible
  → Hypothèse d'un hazard constant (modèle exponentiel)
    valide pour les pathologies à risque de rechute homogène dans le temps

T½_estimé = 0,693 / λ_GHM = 30 × 0,693 / (−ln(1 − taux_réadmission_30j))

Exemple : taux de réadmission à 30j = 20 %
  λ = −ln(0,80) / 30 = 0,0074 j⁻¹
  T½ = 0,693 / 0,0074 ≈ 94 jours
```

### 3. Stratification par profil clinique

```
T½ ajusté = T½_GHM × Facteur_stabilité_clinique

  → Facteur_stabilité_clinique = f(Charlson, âge, score de fragilité)
  → Patients Charlson ≥ 3 : T½ réduit de 30-50 % par rapport à T½_GHM moyen
    (instabilité chronique résiduelle — "radioactivité de fond" des comorbidités)
  → Patients sans comorbidité majeure : T½ proche de la référence GHM

Segmentation opérationnelle :
  T½ < 30 j  → Suivi J+7 et J+14 indispensable (haute instabilité)
  T½ 30–90 j → Suivi J+30 recommandé
  T½ > 90 j  → Suivi J+60 à J+90 suffisant pour la majorité des patients
```

### 4. Indice de stabilité thérapeutique (IST)

```
IST = T½_observé / T½_référence_national_GHM

  → IST > 1,0 : établissement produit un effet thérapeutique plus durable
                que la référence nationale pour ce GHM
  → IST < 1,0 : bénéfice thérapeutique se dissipe plus vite que la norme
                → signal d'une sortie prématurée, d'une prise en charge incomplète
                   ou d'un défaut d'organisation du suivi ambulatoire
  → IST comparable au IP-DMS pour la durée de séjour — même logique
    de benchmarking appliquée à la durabilité du bénéfice post-sortie
```

**Précisions méthodologiques** :
- L'analyse de survie est menée sur les patients adultes (≥ 18 ans) ayant eu un séjour MCO index, chaînés par NIR crypté dans le SNDS sur une fenêtre de 90 jours post-sortie.
- Le modèle exponentiel (hazard constant) est une approximation valide pour la plupart des GHM médicaux ; pour les GHM chirurgicaux à risque de complication précoce, un [[fonction_risque_weibull_readmissions|modèle de Weibull]] (hazard décroissant dans le temps) est préférable.
- Les décès dans les 90 jours post-sortie sont traités comme des événements censurés (fin de suivi), sauf si l'analyse porte explicitement sur la mortalité.
- La granularité minimale recommandée est le GHM racine (4 caractères) pour garantir des effectifs suffisants (≥ 100 patients par strate).

## Utilité

- **Calibrage précis du calendrier de suivi post-sortie** : remplacer le suivi systématique à J+30 (arbitraire) par un suivi calé sur T½ du GHM du patient — les patients insuffisants cardiaques (T½ ~ 25 jours) voient leur cardiologue à J+7, les patients opérés d'une prothèse de hanche (T½ ~ 120 jours) à J+45, évitant à la fois le sous-suivi et les consultations prématurées inutiles.
- **Identification des GHM à bénéfice fragile** : les GHM avec T½ court et IST < 0,8 signalent une prise en charge dont le bénéfice se dissipe trop vite — l'analyse de la décomposition (sortie prématurée ? absence de suivi structuré ? comorbidités sous-traitées ?) guide les plans d'amélioration ciblés.
- **Dimensionnement des programmes de suivi post-hospitalier** : l'intégrale de la courbe de survie sans événement (aire sous S(t)) fournit la durée moyenne de stabilité thérapeutique par GHM, permettant de calculer le nombre de consultations de suivi nécessaires par patient et par an pour couvrir la fenêtre de vulnérabilité.
- **Évaluation de l'impact des programmes de transition de soins** : mesurer l'évolution de T½ avant et après le déploiement d'un programme de télésurveillance (insuffisance cardiaque, BPCO), d'une infirmière de transition ou d'une consultation de sortie dédiée — un programme efficace allonge T½ en réduisant λ (voir [[taux_suivi_ambulatoire_post_hospitalier]]).
- **Argument pour la coordination ville-hôpital** : les GHM avec T½ < 30 jours constituent le groupe prioritaire pour les conventions avec les médecins traitants, les CPTS et les structures d'hospitalisation à domicile — T½ fournit un critère cliniquement fondé pour trier les pathologies qui justifient une coordination renforcée.
- **Benchmarking inter-établissements dans le GHT** : l'IST permet de comparer la "durabilité" de la prise en charge entre les établissements du GHT pour un même GHM, indépendamment des volumes — un IST systématiquement bas dans un établissement suggère soit des sorties trop précoces, soit un défaut de prise en charge des comorbidités, soit une absence de lien avec la médecine de ville.

## Sources de Données

- **PMSI MCO** : dates de sortie du séjour index, GHM, mode de sortie, et dates d'entrée des séjours ultérieurs (identification des réhospitalisations non programmées par chaînage FINESS + dates) — pour le calcul de T½ intra-établissement ou intra-GHT sans accès SNDS.
- **SNDS (chaînage NIR)** : chaînage longitudinal des séjours MCO post-index sur 90 jours, passages aux urgences (RPU) et consultations de médecine de ville (DCIR) — indispensable pour une demi-vie thérapeutique complète incluant tous les types de recours non programmés, pas seulement les réhospitalisations.
- **RPU — Résumés de Passage aux Urgences** : passages aux urgences sans hospitalisation dans les 90 jours post-sortie — événements de "désintégration" de bas niveau mais très fréquents et précoces.
- **ScanSanté** : taux de réadmission à 30 jours par GHM au niveau national — pour le calcul de T½_estimé via λ_GHM sans analyse de survie complète, et pour construire les références nationales de l'IST.
- **Bases de données de survie de référence (HAS / ATIH)** : distributions de survie sans réadmission par GHM issues des publications de la HAS sur les indicateurs de qualité et de sécurité des soins hospitaliers — pour la calibration du modèle et la validation des valeurs de T½.

## Exemple de Valeurs

- **Insuffisance cardiaque (GHM 05M14)** : T½ ~ 20-30 jours — pathologie chronique instable, λ élevé, suivi J+7 indispensable ; T½ < 21 jours associé à un taux de réhospitalisation à 90 jours > 40 %.
- **BPCO exacerbée (GHM 04M07)** : T½ ~ 35-50 jours ; patients avec T½ < 30 jours représentent le groupe à cibler en priorité pour la télésurveillance et la réhabilitation respiratoire.
- **Prothèse totale de hanche (GHM 08C04)** : T½ ~ 150-200 jours pour les patients sans comorbidité ; T½ chute à 60-90 jours chez les patients [[indice_charlson_moyen|Charlson]] ≥ 2 (complications infectieuses et thrombo-emboliques).
- **AVC ischémique (GHM 01M19)** : T½ ~ 45-70 jours ; grande hétérogénéité selon la sévérité initiale (NIHSS) — les patients avec AVC sévère ont un T½ de 25-35 jours (instabilité neurologique résiduelle et complications de décubitus).
- **Appendicectomie simple (GHM 06C03)** : T½ > 300 jours — chirurgie curatrice à bénéfice très durable, λ quasi nul, suivi post-sortie allégé justifié.
- **IST moyen observé** : 20-30 % des établissements affichent un IST < 0,8 pour au moins un GHM "médical" à fort volume, révélant un défaut de durabilité thérapeutique systématique non visible dans les indicateurs de DMS ou de taux de réadmission à 30 jours seuls.

## Limites

- **Hypothèse de hazard constant (modèle exponentiel)** : valable pour les pathologies à risque de rechute distribué uniformément dans le temps, mais non pour les pathologies à risque bimodal (pic précoce de complications post-opératoires + risque tardif de récidive) — le [[fonction_risque_weibull_readmissions|modèle de Weibull]] ou les modèles de hasard par morceaux sont plus appropriés dans ces cas.
- **Confusion entre instabilité de la pathologie et défaut de prise en charge** : un T½ court peut refléter la sévérité intrinsèque de la maladie (insuffisance cardiaque terminale) plutôt qu'un problème organisationnel — la stratification par sévérité (Charlson, APR-DRG) est indispensable avant toute interprétation comparative.
- **Censure informative** : les patients décédés après leur sortie ou perdus de vue (absence de recours aux soins) créent une censure qui peut biaiser l'estimation de T½ si les patients les plus instables décèdent avant de se réhospitaliser — le T½ peut être surestimé dans les populations âgées avec [[taux_mortalite_30j_post_sortie|forte mortalité post-sortie]].
- **Dépendance au mode d'organisation du suivi local** : dans les territoires avec une médecine de ville très réactive, les patients instables seront vus en consultation avant de recourir aux urgences — λ sera plus bas et T½ plus long, non pas parce que l'hospitalisation a été meilleure, mais parce que l'aval est mieux organisé. L'IST compare donc autant la qualité de l'hospitalisation que celle du suivi ambulatoire territorial.
- **Accès SNDS requis pour la demi-vie complète** : le calcul de T½ incluant les passages aux urgences et les consultations de ville nécessite le chaînage SNDS (NIR crypté) — sans cet accès, seules les réhospitalisations MCO sont tracées, sous-estimant λ et surestimant T½.

## Références

- [Kaplan E.L., Meier P., *Nonparametric estimation from incomplete observations*, JASA, 1958](https://doi.org/10.1080/01621459.1958.10501452) — estimateur de référence pour l'analyse de survie
- [Rutherford E., Soddy F., *The Cause and Nature of Radioactivity*, 1902](https://doi.org/10.1080/14786440209462856) — article fondateur de la loi de décroissance radioactive
- [HAS — Taux de réadmission non programmée à 30 jours : indicateur de qualité](https://www.has-sante.fr/jcms/c_1249816/fr/indicateurs-de-qualite-et-de-securite-des-soins)
- [ATIH — Indicateurs de réadmission par GHM, ScanSanté](https://www.scansante.fr/)
- [Krumholz H.M. et al., *Patterns of hospital performance in acute myocardial infarction and heart failure 30-day mortality and readmission*, Circ Cardiovasc Qual Outcomes, 2009](https://doi.org/10.1161/CIRCOUTCOMES.109.883256)
- [SNDS — Chaînage longitudinal post-sortie](https://www.snds.gouv.fr/)
- [Kansagara D. et al., *Risk prediction models for hospital readmission: a systematic review*, JAMA, 2011](https://doi.org/10.1001/jama.2011.1515)
