# APR-DRG — Sévérité de la Maladie et Risque de Mortalité (Belgique / Pays-Bas)

## Définition
L'APR-DRG (All Patient Refined Diagnosis-Related Groups) est une classification médico-économique développée par 3M Health Information Systems, utilisée en Belgique, aux Pays-Bas, en Espagne et dans plusieurs États américains comme alternative ou complément aux DRG/GHM classiques. Sa caractéristique centrale est d'attribuer à chaque séjour, en plus du groupe diagnostique (équivalent du GHM français), deux niveaux de sous-classification indépendants : le **SOI (Severity of Illness — sévérité de la maladie)** sur une échelle de 1 à 4 (mineur, modéré, majeur, extrême) et le **ROM (Risk of Mortality — risque de mortalité)** sur la même échelle. Ces deux dimensions capturent la complexité clinique intra-groupe que les GHM/DRG classiques ne peuvent pas distinguer : deux séjours dans le même GHM peuvent avoir des SOI/ROM radicalement différents, justifiant des ressources et des résultats très différents. En Belgique, l'APR-DRG est le système officiel de financement hospitalier depuis 1995 et fournit le référentiel le plus granulaire disponible pour l'ajustement au risque en Europe.

## Calcul
L'APR-DRG est un algorithme propriétaire 3M basé sur les codes CIM-10 :

**Étape 1 — Attribution du groupe de base (équivalent GHM) :**
```
APR-DRG de base = f(DP, actes chirurgicaux principaux, âge, poids naissance)
  → 314 groupes de base APR-DRG (vs 2 800 GHM français)
  → Chaque groupe correspond à une catégorie clinique homogène (ex. : insuffisance cardiaque, pneumonie, arthroplastie de hanche)
```

**Étape 2 — Attribution du SOI (Severity of Illness) :**
```
SOI = f(diagnostics secondaires, interactions entre comorbidités, complications peropératoires)
  → Niveau 1 (Mineur) : comorbidités sans impact sur la complexité du séjour
  → Niveau 2 (Modéré) : comorbidités avec impact limité
  → Niveau 3 (Majeur) : comorbidités avec impact significatif sur la durée et les ressources
  → Niveau 4 (Extrême) : comorbidités avec impact majeur, patient très instable
```

**Étape 3 — Attribution du ROM (Risk of Mortality) :**
```
ROM = f(diagnostics secondaires, interactions, défaillances d'organes)
  → Évalué indépendamment du SOI (un patient peut avoir SOI=4 et ROM=1 si sa pathologie est grave mais non mortelle)
  → Niveau 1 (Mineur) : risque de décès < 1 %
  → Niveau 2 (Modéré) : risque de décès 1-5 %
  → Niveau 3 (Majeur) : risque de décès 5-15 %
  → Niveau 4 (Extrême) : risque de décès > 15 %
```

**Indicateurs dérivés du SOI/ROM :**
```
DMS ajustée SOI = DMS observée / DMS attendue pour le même APR-DRG et le même SOI
Taux de mortalité ajusté ROM = Décès observés / Décès attendus pour le même APR-DRG et le même ROM
Indice de sévérité moyen = Σ (SOI_i) / Nombre total de séjours   (équivalent du CMI pour la sévérité clinique)
```

## Transposition PMSI France
La transposition de l'APR-DRG SOI/ROM au PMSI français est **techniquement possible mais contrainte** :

- **Compatibilité CIM-10** : l'algorithme APR-DRG 3M intègre nativement la CIM-10 FR — les données PMSI françaises (DP, DR, DA en CIM-10, actes CCAM) sont directement compatibles avec l'algorithme d'attribution SOI/ROM.
- **Algorithme propriétaire** : l'APR-DRG est un logiciel commercial 3M (licence payante) — contrairement aux PSI ou PQI (open-source AHRQ), son déploiement nécessite un achat de licence ou un partenariat avec 3M France.
- **Expériences françaises** : des groupes hospitaliers français (AP-HP, HCL) ont utilisé l'APR-DRG pour des analyses internes de benchmarking, confirmant la faisabilité technique sur données PMSI.
- **Alternative open-source** : l'algorithme de Elixhauser (31 comorbidités) et l'indice de Charlson constituent des proxies du SOI partiellement substituables, utilisables sans licence commerciale.
- **Enrichissement par rapport au GHM** : le GHM français distingue déjà 4 niveaux de sévérité (J, T, Z, A) basés sur les CC/CMA — le SOI APR-DRG est plus granulaire car il intègre les interactions entre comorbidités (une comorbidité isolée peut être mineure, mais deux comorbidités combinées peuvent atteindre SOI=4).

## Utilité
- **Ajustement au risque intra-GHM** : le SOI permet de distinguer des patients dans le même GHM français qui ont pourtant des besoins en soins très différents — une DMS longue n'est plus simplement une inefficience si le SOI moyen du service est élevé.
- **Comparaison équitable entre établissements** : le benchmarking de la DMS ou de la mortalité ajusté sur le SOI/ROM est plus équitable que le benchmarking sur GHM seul pour des établissements de casemix différent (ex. : CHU vs CHG).
- **Identification du sous-financement T2A** : un établissement traitant beaucoup de patients SOI=3/4 dans un GHM finançant au niveau SOI=2 est sous-financé par la T2A — le SOI objectivise ce déséquilibre pour les négociations CPOM.
- **Pilotage de la qualité ajusté au risque** : le taux de mortalité ajusté sur le ROM est plus robuste que le taux brut ou même que le SHMI pour comparer des établissements dont la patientèle a des profils de risque très différents.
- **Adoption en Belgique** : l'expérience belge de 30 ans avec l'APR-DRG montre que son déploiement améliore la précision des comparaisons de performance hospitalière et la pertinence des politiques de financement.

## Sources de Données
- **PMSI MCO** : codes CIM-10 (DP, DR, DA) et codes CCAM — données d'entrée de l'algorithme APR-DRG 3M.
- **Logiciel APR-DRG 3M** : algorithme propriétaire, disponible sur licence commerciale auprès de 3M France ; traite les fichiers RSS/RSA PMSI pour attribuer le groupe APR-DRG, le SOI et le ROM à chaque séjour.
- **Référence belge** : SPF Santé Publique Belgique, *APR-DRG : Classification et financement des séjours hospitaliers*, documentation technique mise à jour annuellement.
- **Référence académique** : Averill R.F. et al., *All Patient Refined Diagnosis Related Groups (APR-DRGs): Methodology Overview*, 3M Health Information Systems, 1995.
- **ATIH** : pour la correspondance entre les groupes APR-DRG de base et les GHM français (table de mapping partielle).

## Exemple de Valeurs
- **Distribution SOI en MCO général** : SOI 1 (mineur) ~35 %, SOI 2 (modéré) ~35 %, SOI 3 (majeur) ~20 %, SOI 4 (extrême) ~10 % — proportions variant fortement selon le type d'établissement.
- **CHU vs CHG** : les CHU présentent 2 à 3 fois plus de séjours SOI 3-4 que les CHG, justifiant des DMS et des coûts structurellement plus élevés dans le même GHM.
- **DMS par SOI (pneumonie, APR-DRG 139)** : SOI 1 : 3,5 jours ; SOI 2 : 5,2 jours ; SOI 3 : 8,1 jours ; SOI 4 : 14,7 jours — illustration de l'hétérogénéité intra-GHM non capturée par la DMS moyenne.
- **ROM et mortalité** : ROM 1 : mortalité <0,5 % ; ROM 2 : 1-3 % ; ROM 3 : 5-12 % ; ROM 4 : 20-40 % — gradient très fort justifiant des ressources de soins intensifs différenciées.
- **Indice de sévérité moyen (ISM)** : CHU de référence ~2,8-3,2 ; CHG de grande taille ~2,0-2,4 ; CHG de proximité ~1,5-1,9 ; clinique privée spécialisée ~1,8-2,2.

## Limites
- **Licence commerciale** : contrairement aux indicateurs AHRQ open-source, l'APR-DRG nécessite une licence 3M dont le coût peut être prohibitif pour un GHT de taille modeste.
- **Boîte noire algorithmique** : l'algorithme APR-DRG n'est pas entièrement transparent (propriétaire) — les règles d'attribution SOI/ROM ne peuvent pas être auditées ou modifiées librement.
- **Dépendance au codage des DA** : comme tous les indicateurs basés sur les comorbidités CIM-10, le SOI est très sensible à la qualité et à l'exhaustivité du codage des diagnostics associés dans le PMSI.
- **Non standardisé en France** : l'APR-DRG n'est pas le système de référence officiel en France (contrairement à la Belgique) — son utilisation est donc limitée aux analyses internes et aux comparaisons avec des pays utilisateurs.
- **Interactions complexes** : l'attribution du SOI repose sur des règles d'interaction entre comorbidités qui peuvent produire des résultats contre-intuitifs dans certains cas cliniques, nécessitant une interprétation experte.

## Références
- [3M Health Information Systems - APR-DRG Documentation](https://www.3m.com/3M/en_US/health-information-systems-us/drive-value-based-care/patient-classification-methodologies/apr-drgs/)
- [SPF Santé Publique Belgique - Financement APR-DRG](https://www.health.belgium.be/)
- [Averill R.F. et al., APR-DRGs Methodology Overview, 3M HIS, 1995](https://www.hcup-us.ahrq.gov/db/nation/nis/APR-DRGsV20MethodologyOverviewandBibliography.pdf)
- [ATIH - Classification GHM et comparaison internationale](https://www.atih.sante.fr/)
- [IRDES - Comparaisons internationales des systèmes de classification hospitalière](https://www.irdes.fr/)
