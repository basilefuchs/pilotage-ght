# Volume Annuel par Acte Chirurgical à Risque (Indicateur Volume-Seuil)

## Définition
L'indicateur volume-seuil mesure le nombre annuel d'actes chirurgicaux à risque réalisés par établissement et par chirurgien, et le positionne par rapport aux seuils réglementaires ou aux seuils d'efficience clinique établis par la littérature. La relation volume-résultats en chirurgie est l'une des associations les mieux documentées en épidémiologie hospitalière : pour les interventions complexes (pancréatectomie, œsophagectomie, chirurgie cardiaque, prothèse totale de hanche et de genou, chirurgie oncologique majeure), les établissements et les chirurgiens à fort volume produisent des résultats significativement meilleurs — mortalité post-opératoire plus basse, moins de complications, durée de séjour plus courte, moins de réopérations. En France, cette relation a conduit à la définition de **seuils d'activité minimaux réglementaires** (décrets MSAC — Mesures de Sécurité des Activités de Chirurgie) pour certaines chirurgies complexes, publiés au Journal Officiel et contrôlés par les ARS dans le cadre des autorisations d'activité. L'indicateur est calculable directement depuis le PMSI en comptant les actes CCAM par FINESS et par chirurgien (numéro RPPS), et constitue un outil de pilotage stratégique du GHT pour décider des concentrations d'activités entre sites.

## Calcul
L'indicateur volume-seuil est calculé depuis le PMSI MCO par comptage des actes CCAM :

```
Volume annuel par acte à risque (N) =
  Nombre de séjours MCO avec l'acte CCAM cible en position principale sur 12 mois glissants,
  par FINESS géographique

Positionnement par rapport au seuil :
  → Taux d'atteinte du seuil (%) = (Volume observé / Seuil réglementaire ou cible) × 100
  → Statut : SOUS-SEUIL (<80%), EN ZONE CRITIQUE (80-100%), CONFORME (>100%)
```

**Actes chirurgicaux à risque et seuils de référence (France) :**
```
Chirurgie oncologique digestive majeure :
  → Pancréatectomie (duodénopancréatectomie céphalique) : HMFA001, HMFC001
    Seuil MSAC : ≥20 résections pancréatiques par an par établissement
  → Œsophagectomie : HFGA003, HFGA004
    Seuil MSAC : ≥20 résections œsophagiennes par an
  → Gastrectomie totale pour cancer : HFCA001, HFCA002
    Seuil MSAC : ≥20 gastrectomies par an

Chirurgie cardiaque et vasculaire :
  → Pontage aorto-coronarien : DBSA002, DBSA003
    Seuil MSAC : ≥200 interventions cardiaques avec CEC par an
  → Remplacement valvulaire aortique (TAVI) : DBAF001, DBAF002
    Seuil cible (SFC) : ≥50 TAVI par an par centre

Orthopédie :
  → Prothèse totale de hanche (PTH) : NZLA002, NZLA003
    Seuil cible littérature : ≥50 PTH/an par chirurgien (volume opérateur)
  → Prothèse totale de genou (PTG) : NZLA009, NZLA010
    Seuil cible littérature : ≥50 PTG/an par chirurgien

Neurochirurgie :
  → Chirurgie des tumeurs cérébrales (gliomes, méningiomes) : CCLA001-CCLA010
    Seuil cible (SFNC) : ≥30 résections tumorales par an par centre

Chirurgie bariatrique :
  → Sleeve gastrectomie, bypass gastrique : HFCA011, HFCA012, HFCA013
    Seuil MSAC : ≥30 chirurgies bariatriques par an par établissement

Oncologie :
  → Mastectomie pour cancer du sein : QEMA002, QEMA003
    Seuil HAS/INCa : ≥30 chirurgies du sein par an par établissement
  → Prostatectomie radicale : JDEA001, JDEA002
    Seuil cible (AFU) : ≥30 prostatectomies par an par chirurgien
```

**Sous-indicateurs dérivés :**
```
Volume opérateur (chirurgien) vs volume établissement :
  → Compter les actes par numéro RPPS du chirurgien opérateur principal
  → Identifier les chirurgiens sous le seuil individuel de la littérature
  → Ratio volume opérateur / volume établissement : détecte la concentration sur 1 chirurgien

Évolution du volume sur 3 ans :
  → Tendance haussière ou baissière pour chaque acte à risque
  → Alerte si tendance baissière vers le seuil réglementaire

Positionnement dans la filière GHT :
  → Carte des volumes par acte et par site du GHT
  → Identification des doublons d'activité (deux sites sous le seuil pour le même acte)
    → levier de concentration stratégique intra-GHT

Corrélation volume — indicateurs de résultats :
  → Croiser le volume annuel avec le taux de FTR, le taux de réopération non programmée
    et l'IP-DMS pour quantifier localement la relation volume-résultats
```

**Précisions méthodologiques :**
- Les seuils réglementaires MSAC sont publiés par décret et révisés périodiquement — vérifier la version en vigueur sur le site de la DGOS ou Légifrance.
- Le PMSI comptabilise les actes par FINESS géographique (site de réalisation) et non par FINESS juridique (entité gestionnaire) — utiliser le FINESS géographique pour le calcul des volumes par site.
- Pour les GHT, les actes réalisés sur plusieurs sites peuvent être mutualisés dans certaines autorisations ARS — vérifier le périmètre de l'autorisation avant d'interpréter un volume sous-seuil sur un site isolé.

## Utilité
- **Outil stratégique de concentration des activités au sein du GHT** : identifier les activités chirurgicales à risque exercées sur plusieurs sites du GHT avec des volumes individuellement insuffisants — argument objectif pour décider d'une concentration sur le site le plus actif, en application de la logique de gradation des soins du projet médical partagé.
- **Anticipation des contrôles ARS et conformité réglementaire** : les ARS contrôlent le respect des seuils MSAC lors du renouvellement des autorisations d'activité — un tableau de bord des volumes par acte à risque permet au GHT d'anticiper les risques de non-renouvellement et d'engager les réorganisations nécessaires en amont.
- **Négociation des autorisations de chirurgie complexe** : un établissement du GHT souhaitant obtenir une autorisation pour une nouvelle activité (TAVI, chirurgie robotique, oncologie lourde) doit démontrer un volume suffisant et une trajectoire croissante — les données PMSI constituent le dossier factuel de la demande.
- **Évaluation de la relation volume-résultats en local** : croiser les volumes annuels par acte avec les indicateurs de résultats disponibles dans le PMSI (mortalité, FTR, IP-DMS, réopérations) pour quantifier localement la relation volume-qualité et adapter les seuils cibles aux spécificités du territoire.
- **Suivi des chirurgiens en formation** : dans les établissements universitaires du GHT, suivre l'évolution du volume opérateur par interne/assistant pour valider les compétences chirurgicales selon les référentiels de formation (nombre minimal d'actes requis pour la qualification).

## Sources de Données
- **PMSI MCO local (DIM)** : comptage des actes CCAM par FINESS géographique et par numéro RPPS sur 12 mois glissants — calcul réalisable directement par le DIM sans accès SNDS.
- **ScanSanté** : tableau "Actes CCAM par établissement" permettant le benchmarking régional et national des volumes par acte chirurgical — accessible sans traitement supplémentaire des données locales.
- **Répertoire FINESS / RPPS** : pour identifier les chirurgiens opérateurs et calculer les volumes par opérateur depuis le champ médecin responsable du RUM.
- **Journal Officiel / DGOS** : textes réglementaires définissant les seuils MSAC en vigueur pour chaque autorisation d'activité chirurgicale.
- **Référentiels des sociétés savantes** : SFC (cardio), AFU (urologie), SFNC (neurochirurgie), AFCA (bariatrique), HAS/INCa (oncologie) — seuils recommandés pouvant être plus exigeants que les seuils réglementaires minimaux.

## Exemple de Valeurs
- **Pancréatectomie** : médiane nationale ~25 résections/an/établissement autorisé ; les centres > 50 résections/an ont une mortalité opératoire 2-3× inférieure aux centres < 10 résections/an (relation volume-mortalité parmi les plus fortes de la littérature chirurgicale).
- **PTH/PTG** : volume opérateur < 50 prothèses/an associé à un taux de révision à 5 ans significativement supérieur dans les registres nationaux (NJR britannique, SwedeHip suédois).
- **Chirurgie bariatrique** : les centres réalisant > 200 procédures/an ont un taux de fistule anastomotique 40 % inférieur aux centres < 50 procédures/an.
- **TAVI** : centres < 50 TAVI/an ont une mortalité intra-hospitalière de 3-5 % vs 1-2 % pour les centres > 150 TAVI/an (données EuroCatheter et registre FRANCE-TAVI).
- **Suero Molina et al. (Acta Neurochir 2019)** — 3 760 patients neurochirurgicaux : le taux de réopération non programmée est inversement corrélé au volume du centre, confirmant la relation volume-qualité en neurochirurgie.
- **Schipmann et al. (Acta Neurochir 2019)** — CHU de Münster : le PCCL (Patient Clinical Complexity Level, équivalent du niveau de sévérité GHM) est le meilleur prédicteur des indicateurs de qualité en neurochirurgie sur données administratives.

## Limites
- La relation volume-résultats, si robuste soit-elle en population, n'est pas absolue au niveau individuel : un chirurgien à faible volume dans un petit établissement peut produire d'excellents résultats grâce à une sélection rigoureuse des patients, tandis qu'un centre à fort volume peut avoir des résultats médiocres sur certaines sous-populations.
- Les seuils réglementaires MSAC sont des minima politiquement négociés (compromis entre qualité et maintien d'une offre territoriale) et sont souvent inférieurs aux seuils d'efficience clinique recommandés par les sociétés savantes — le seuil réglementaire ne doit pas être confondu avec le seuil d'excellence.
- Le comptage des actes PMSI peut inclure des reprises et révisions (réopérations planifiées) qui gonflent artificiellement le volume — filtrer les séjours de révision programmée pour ne comptabiliser que les primo-interventions.
- Dans les GHT avec conventions d'activités partagées (chirurgien itinérant opérant sur plusieurs sites), le volume apparent par FINESS sous-estime le volume réel de l'opérateur — le calcul par numéro RPPS est plus pertinent que le calcul par FINESS dans ce cas.
- L'indicateur ne tient pas compte de la qualité du plateau technique (disponibilité d'une réanimation, d'une radiologie interventionnelle) qui conditionne autant les résultats que le volume chirurgical — la relation volume-résultats est partiellement médiée par les ressources associées au centre.

## Références
- [Suero Molina E. et al. — Unplanned reoperation rate in neurosurgery: quality indicator analysis, Acta Neurochir 2019](https://doi.org/10.1007/s00701-019-04146-2)
- [Schipmann S. et al. — Risk-adjusted quality indicators in neurosurgery from administrative data, Acta Neurochir 2019](https://doi.org/10.1007/s00701-018-03792-2)
- [DGOS — Décrets MSAC : seuils d'activité minimaux pour les chirurgies complexes](https://www.legifrance.gouv.fr/)
- [HAS / INCa — Seuils d'activité en cancérologie : critères d'autorisation](https://www.has-sante.fr/)
- [ScanSanté — Volume d'actes CCAM par établissement et comparaison nationale](https://www.scansante.fr/)
