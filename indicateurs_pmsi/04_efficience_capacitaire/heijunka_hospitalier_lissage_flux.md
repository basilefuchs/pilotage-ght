# Heijunka Hospitalier — Indice de Lissage des Flux d'Admission

## Définition

Heijunka (平準化) est un concept fondamental du Toyota Production System (TPS), formalisé par Taiichi Ohno dans les années 1950, qui désigne le **lissage de la production** : plutôt que de produire par lots irréguliers qui surchargent le système par pics puis le laissent oisif, une production heijunka maintient un flux constant et prévisible. Transposé à l'hôpital, l'**Indice de Heijunka Hospitalier** (IHH) mesure le degré de lissage des flux d'entrées (admissions) sur différentes granularités temporelles : jour de la semaine, semaine du mois, mois de l'année.

Un hôpital sans lissage présente une forte variabilité des admissions : peu de chirurgie le lundi matin (préparation des blocs), pic d'admissions le mercredi-jeudi, quasi-arrêt le week-end. Cette irrégularité génère des surcharges et des sous-utilisations alternées des ressources — infirmiers sous-occupés le week-end, débordement des salles de réveil en fin de semaine. Le heijunka hospitalier mesure cette régularité et identifie les leviers organisationnels pour lisser les flux sans augmenter la capacité globale.

IHH = 1 − (σ_admissions / μ_admissions)

où σ est l'écart-type et μ la moyenne des admissions sur la période considérée. IHH → 1 signifie un flux parfaitement lissé (même nombre d'admissions chaque jour) ; IHH → 0 ou négatif signifie un flux très irrégulier.

Équivalent normalisé : IHH = max(0 ; 1 − CV_admissions) où CV = σ/μ

## Calcul

Granularités d'analyse du flux :

```
Données d'entrée : dates et heures d'admission MCO (RSA)
  → Date d'entrée effective (non la date de programmation)
  → Agrégée par jour calendaire sur 12 mois glissants

Granularité 1 — Jour de la semaine (variabilité intra-hebdomadaire) :
  Pour chaque jour j ∈ {Lun, Mar, Mer, Jeu, Ven, Sam, Dim} :
    μⱼ = moyenne du nombre d'admissions les jours j sur 12 mois
    σⱼ = écart-type
  CV_hebdo = σ(μⱼ) / μ(μⱼ)   (variabilité entre jours de la semaine)
  IHH_hebdo = max(0 ; 1 − CV_hebdo)

Granularité 2 — Semaine de l'année (variabilité saisonnière) :
  Pour chaque semaine s ∈ {S1..S52} :
    μₛ = nombre d'admissions en semaine s
  CV_annuel = σ(μₛ) / μ(μₛ)
  IHH_annuel = max(0 ; 1 − CV_annuel)

Granularité 3 — Heure d'admission (variabilité intra-journalière) :
  Pour chaque tranche horaire h ∈ {H00-H23} :
    μₕ = moyenne des admissions par heure
  CV_intraday = σ(μₕ) / μ(μₕ)
  IHH_intraday = max(0 ; 1 − CV_intraday)

IHH composite :
  IHH = w₁ × IHH_hebdo + w₂ × IHH_annuel + w₃ × IHH_intraday
  Pondérations suggérées : w₁ = 0.5, w₂ = 0.3, w₃ = 0.2
  (la variabilité hebdomadaire est la plus actionnable organisationnellement)
```

Décomposition du flux par type d'admission :

```
Distinguer les types d'admissions pour l'analyse de lissage :
  → Chirurgie programmée (entrées J-0 ou J-1 avant acte) : flux pilotable
  → Hospitalisations médicales programmées : flux semi-pilotable
  → Urgences directes : flux non pilotable (subi)
  → Transferts entrants (MCO→SSR, urgences→MCO) : flux partiellement pilotable

IHH_programmé = IHH calculé sur les seules entrées programmées
  → Indicateur de maîtrise organisationnelle (le non-programmé est exclu)
  → Plus pertinent pour évaluer l'efficacité des actions de lissage

Ratio flux subi / flux total (RSF) :
  RSF = Admissions_urgences / Total_admissions
  → RSF élevé = peu de marge de manœuvre pour le lissage
  → RSF faible = fort potentiel de lissage en agissant sur le programmé
```

Écart au profil de lissage optimal :

```
Profil optimal théorique : même nombre d'entrées chaque jour de la semaine
  Optimal_jour = Total_admissions_semaine / 7

Indice de déviation Pareto (IDP) :
  IDP = Σⱼ |μⱼ − Optimal_jour| / (2 × Total_admissions_semaine)
  → IDP = 0 : flux parfaitement lissé
  → IDP = 1 : tout le flux concentré en un seul jour

Carte de chaleur hebdomadaire-annuelle :
  Représentation graphique du ratio (admissions réelles / moyenne attendue)
  par jour de la semaine × semaine de l'année
  → Identifier les "hot spots" de suractivité et les "cold spots" de sous-activité
```

## Utilité

- **Réduire les pics de charge infirmiers sans augmenter les effectifs** : la variabilité des admissions est la principale cause d'inadéquation entre charge de travail et dotation en personnel — un IHH hebdomadaire faible indique qu'une répartition différente des admissions programmées (décaler certaines chirurgies du jeudi au mardi, ouvrir des admissions le samedi matin) pourrait réduire les pics sans ressources supplémentaires
- **Optimiser l'utilisation des blocs opératoires** : le heijunka appliqué à la programmation chirurgicale permet de lisser l'occupation des blocs sur la semaine, réduisant les salles de réveil surchargées le jeudi-vendredi et les blocs vides le lundi matin — l'IHH_programmé est l'indicateur de suivi de ces optimisations
- **Prévention du "syndrome du lundi"** : la sur-concentration des sorties le vendredi et des admissions le mercredi-jeudi génère un "bed-blocking" chronique le week-end (lits bloqués par des patients médicalement prêts à sortir mais sans aval) — le heijunka identifie ce phénomène et guide les actions pour le réduire (astreinte de planification aval le week-end, sorties programmées le samedi)
- **Réduction des heures supplémentaires soignantes** : la variabilité des admissions est corrélée au recours aux heures supplémentaires et à l'intérim — un IHH amélioré de 0,10 points est associé à une réduction estimée de 5-8% des heures supplémentaires dans les retours d'expérience lean hospitaliers
- **Benchmark entre établissements du GHT** : comparer les profils d'IHH hebdomadaire entre les établissements du GHT pour identifier celui qui a le flux le mieux lissé et analyser ses pratiques organisationnelles (répartition des plages opératoires, programmation des consultations, astreinte de planification aval)
- **Pilotage des démarches lean hospitalières** : l'IHH est l'indicateur de résultat naturel d'un chantier heijunka hospitalier — il permet de mesurer l'impact des actions d'amélioration (répartition des vacations, modification des cycles de programmation, création d'équipes mobiles de semaine)

## Sources de Données

- **PMSI MCO RSA** : date et heure d'entrée effective pour chaque séjour (variable DATE_ENT + HEURE_ENT du RSA) — principale source pour calculer les flux quotidiens et intra-journaliers d'admissions sur les 12 mois glissants
- **Données de gestion interne** (logiciel de planification : DxCare, SilverSurfer, Crossway) : distinctions programmé/non programmé, type de chirurgie, spécialité — pour la décomposition du flux par type d'admission et le calcul de l'IHH_programmé
- **Planning des blocs opératoires** (logiciel de gestion des blocs : Opusline, Uranos, BO Management) : vacations ouvertes par jour et par spécialité — pour analyser l'offre programmée et la comparer au flux réel (taux de remplissage vs lissage)
- **Données RH** (logiciel de planification des soignants) : effectifs présents par jour et par unité — pour mettre en regard l'IHH des admissions avec la dotation en personnel et calculer l'écart charge/capacité journalier

## Exemple de Valeurs

- **IHH_hebdo d'un service de chirurgie orthopédique** : 0,30-0,45 typique (forte concentration mercredi-jeudi, quasi-arrêt samedi-dimanche) — un objectif de lissage vise IHH_hebdo > 0,65 en 18 mois
- **IHH_hebdo d'un service de médecine gériatrique** : 0,50-0,65 (admissions plus réparties car urgences et programmé mêlés) — mais IHH_programmé = 0,35 (le peu de programmé reste concentré en début de semaine)
- **IHH_annuel** : 0,60-0,75 pour la plupart des services (hors creux estival) ; chute marquée en S30-S35 (été) et S52-S02 (Noël) — le CV annuel reflète principalement la saisonnalité, pas l'organisation
- **Impact d'un chantier heijunka** : gain IHH_hebdo de +0,15-0,25 points en 12 mois dans les établissements ayant appliqué la méthode (répartition des vacations, extension de la programmation au samedi matin) — réduction corrélée de 10-15% des heures supplémentaires infirmiers
- **Ratio flux subi / flux total (RSF)** : RSF = 0,25-0,40 en chirurgie, 0,60-0,80 en médecine interne — les services médicaux ont peu de levier sur le heijunka vs les services chirurgicaux

## Limites

- L'IHH mesure la régularité des admissions, non leur niveau absolu — un service admettant 5 patients par jour exactement aurait IHH = 1 mais serait sous-utilisé ; l'IHH doit toujours être lu conjointement avec le taux d'occupation pour distinguer lissage efficace et sous-activité régulière
- Le lissage du flux d'admissions peut créer une pression sur le flux aval (sorties) si les durées de séjour ne sont pas simultanément maîtrisées — heijunka sans action sur la DMS peut accroître le bed-blocking de façon contre-intuitive ; l'IHH doit s'accompagner d'un suivi de la DMS et du taux d'occupation
- Certaines contraintes médicales (chirurgie réalisée uniquement certains jours par des chirurgiens visiteurs, urgences pédiatriques concentrées le week-end, chimiothérapies uniquement en semaine) rendent le lissage objectivement impossible — l'IHH_programmé, qui exclut le flux subi, est plus pertinent que l'IHH total pour évaluer la marge de manœuvre réelle
- La granularité intra-journalière (IHH_intraday) est difficile à améliorer sans modifier fondamentalement les horaires d'ouverture du bloc ou des urgences — son utilité est surtout diagnostique (identifier les pics de 10h-14h) plutôt que prescriptive à court terme

## Références

- [Ohno T. — Toyota Production System: Beyond Large-Scale Production, Productivity Press 1988 : fondements du heijunka et du TPS]
- [Womack J.P., Jones D.T. — Lean Thinking: Banish Waste and Create Wealth in Your Corporation, Free Press 1996 : application du lean aux processus de service]
- [Litvak E., Long M.C. — Cost and quality under managed care: irreconcilable differences?, Am J Manag Care 2000 : premiers travaux sur le lissage des admissions hospitalières]
- [Litvak E. et al. — Managing unnecessary variability in patient demand to reduce nursing stress and improve patient safety, Jt Comm J Qual Patient Saf 2005](https://doi.org/10.1016/S1553-7250(05)31044-0)
- [ANAP — Lean management en établissements de santé : retours d'expérience (2014)](https://www.anap.fr/)
- [HAS — Amélioration de la gestion des lits et des flux de patients : guide pratique (2019)](https://www.has-sante.fr/)
