# Indice de Concentration des Journées de Bed-Blocking par Profil Patient

## Définition

Une politique de fluidification de l'aval peut être **diffuse** (accroître globalement les capacités SSR) ou **ciblée** (un dispositif dédié à un profil précis : patients déments, isolés, dépendants…). Le choix dépend d'une question empirique : les journées de bed-blocking sont-elles réparties sur l'ensemble de la patientèle, ou **concentrées sur quelques profils étroits** ? Cet indicateur répond à cette question en appliquant aux journées bloquées les outils classiques de mesure de la concentration : la **courbe de Lorenz** et l'**indice de Gini**.

On définit des **profils patients** par croisement de variables PMSI discriminantes du risque d'aval (par exemple : Catégorie Majeure de Diagnostic × tranche d'âge × présence de démence/dépendance). Pour chaque profil `i`, on calcule le total de journées de bed-blocking `BB_i`. L'indice de Gini mesure ensuite à quel point ces journées sont inégalement réparties entre profils :

```
G = (Σ_i Σ_j |BB_i − BB_j|) / (2 · K · Σ_i BB_i)
```

où `K` est le nombre de profils. `G = 0` signifie que chaque profil porte la même charge de journées bloquées (blocage diffus, sans cible) ; `G → 1` signifie qu'une poignée de profils concentre la quasi-totalité des journées (blocage ciblable). La courbe de Lorenz associée permet une lecture opérationnelle directe : « X % des profils concentrent Y % des journées bloquées ».

**Pourquoi les indicateurs PMSI actuels ne le capturent pas** : le taux de bed-blocking donne un volume agrégé ; la fraction attribuable (`fraction_attribuable_demence_journees_bed_blocking`) teste *un* facteur posé a priori. Aucun ne répond à la question de *forme de distribution* — le blocage est-il un phénomène de masse ou de niche ? La réponse oriente la stratégie d'investissement avant même d'identifier *quel* profil est en cause. L'approche transpose au pilotage capacitaire la logique des indicateurs de concentration déjà présents dans le dépôt sur d'autres objets (`part_valorisation_top_decile_patients_mco`, `part_sejours_non_programmes_top_decile_consommateurs`).

## Calcul

Source : PMSI MCO (RSA) + bornes GHM ATIH.

**Étape 1 — Journées de bed-blocking par séjour** (cf. `taux_bed_blocking_mco_attente_ssr`) :

```
Population : séjours MCO avec mode_sort = 6 (ou 7, ou Z75.1 en DA)
BB_jours(séjour) = MAX(0 ; DMS_observée − DMS_haute_GHM)
Ne conserver que les séjours avec BB_jours > 0.
```

**Étape 2 — Construction des profils.** Définir une partition de la patientèle par croisement de variables disponibles dans le RSA :

```
Profil = CMD (Catégorie Majeure de Diagnostic, dérivée du GHM)
       × tranche d'âge {<75 ; 75–84 ; ≥85}
       × dépendance/cognition {démence F00-F03/G30 ; dépendance Z74 ; aucune}
```

Le grain est paramétrable : profils plus fins = plus discriminants mais effectifs plus faibles. Recommandation : viser des profils d'au moins 20-30 séjours bloqués.

**Étape 3 — Agrégation par profil.**

```
BB_i = Σ BB_jours sur les séjours du profil i      (i = 1..K)
```

**Étape 4 — Courbe de Lorenz.** Trier les profils par `BB_i` croissant, calculer les parts cumulées :

```
Trier les profils i tels que BB_(1) ≤ BB_(2) ≤ ... ≤ BB_(K)
Part cumulée des journées : L_k = (Σ_{i≤k} BB_(i)) / (Σ_i BB_i)
Abscisse : part cumulée des profils k/K
```

**Étape 5 — Indice de Gini.** Sur la distribution des `BB_i` (formule des écarts absolus ci-dessus, ou via l'aire sous la courbe de Lorenz `G = 1 − 2·∫L`).

**Étape 6 — Lecture opérationnelle.** Extraire les indicateurs décisionnels :

```
Top‑k profils : part des journées portée par les k profils les plus chargés
                (ex. « les 3 profils sur 20 concentrent 55 % des journées »)
Ratio inter-profils : BB_max / BB_médian
```

Conventions sur cas limites :
- Σ BB_jours = 0 (aucun blocage) → indice non défini, signaler `NA`.
- Profils à effectif nul → exclus de `K` (ne pas créer de profils vides artificiels qui gonfleraient `G`).
- Gini sensible au nombre et au grain des profils : **fixer une grille de profils stable** pour toute comparaison temporelle ou inter-établissement.
- Pondérer par séjour, pas par patient, sauf si un chaînage anti-doublon est appliqué.

Variante — **concentration patient (et non profil)** : appliquer Gini directement à la distribution des `BB_jours` par séjour individuel pour mesurer si quelques séjours très longs portent l'essentiel du blocage (lecture complémentaire, type « 80/20 »).

## Utilité

- **Choisir entre stratégie diffuse et ciblée** : un Gini élevé (> 0,5) signe un blocage concentré → un dispositif dédié au(x) profil(s) dominant(s) est plus rentable qu'un accroissement indifférencié des capacités SSR ; un Gini bas signe un problème de masse → action systémique sur les filières.
- **Désigner la cible prioritaire** : le top‑k profils nomme précisément le segment à traiter (« femmes ≥85 ans, CMD orthopédie, dépendance Z74 »), base d'un cahier des charges de filière.
- **Dimensionner un dispositif** : la part de journées du profil cible × perte tarifaire journalière borne le retour sur investissement d'une action focalisée.
- **Suivre le déplacement de la charge** : après ouverture d'une filière ciblée, vérifier que le Gini baisse et que le profil traité sort du top‑k (preuve d'efficacité), sans report sur un autre profil.
- **Comparer les sites du GHT** : à grille de profils identique, un établissement à Gini élevé est « ciblable », un autre à Gini bas relève d'un problème capacitaire global — deux plans d'action distincts.
- **Prioriser l'analyse fine** : réserver les analyses causales coûteuses (fraction attribuable, modèles ajustés) aux quelques profils que la concentration désigne.

## Sources de Données

- **PMSI MCO — RSA** : code GHM (et CMD dérivée), `mode_sort`, durée de séjour, âge, diagnostics associés (démence F00-F03/G30, dépendance Z74), FINESS, service/UM. Noms de champs à aligner sur le format RSA du guide méthodologique PMSI MCO en vigueur [à confirmer selon le millésime].
- **ATIH — Bornes GHM** : DMS haute par GHM (fichiers tarifaires T2A, millésime de l'année de sortie) pour le calcul des `BB_jours`.
- **ATIH — Table de correspondance GHM → CMD** : pour la construction de l'axe diagnostic des profils.
- **Outils statistiques** : packages R `ineq` (Gini, courbe de Lorenz), `DescTools` (`Gini`, intervalles de confiance par bootstrap).

## Exemple de Valeurs

Ordres de grandeur experts (non sourcés ; à calibrer localement) :

- **Gini des journées BB par profil** : 0,35-0,55 attendu sur une grille CMD × âge × cognition d'une vingtaine de profils. Un blocage typiquement « gériatrique » (concentré sur quelques CMD et le grand âge) tire le Gini vers 0,5-0,6.
- **Top‑3 profils** : concentrent souvent 45-60 % des journées bloquées en gériatrie / médecine.
- **Contexte de cadrage** : l'attente de transfert vers l'aval est la cause dominante du blocage et se concentre sur des profils identifiables (poids du DRG, perte d'autonomie, attente de destination), cf. Pellico-López et al. 2019 [DOI](https://doi.org/10.3390/ijerph16183304) ; 6 % des lits occupés par des patients en attente d'aval, blocage principalement lié à la coordination, cf. étude 2025 sur les transferts [DOI](https://doi.org/10.3390/healthcare13162038).
- **Seuil d'alerte décisionnel** : Gini > 0,5 **et** top‑3 > 50 % → privilégier un dispositif ciblé documenté par fiche de profil.

## Limites

- **Sensibilité au grain des profils** : l'indice de Gini dépend du nombre et de la définition des profils ; comparer deux mailles ou deux périodes exige une **grille de profils figée**. Une grille trop fine gonfle artificiellement le Gini (beaucoup de profils à faible effectif).
- **Indicateur de forme, non de cause** : un Gini élevé indique *où* regarder, pas *pourquoi* le blocage se concentre. Il doit être suivi d'une analyse causale (fraction attribuable, entretiens filière) sur les profils désignés.
- **Effectifs minimaux** : sous ~30 séjours bloqués par profil, les `BB_i` sont instables et le Gini bruité ; agréger à l'année et au GHT, accompagner d'un intervalle de confiance bootstrap.
- **Dépendance aux limites du numérateur** : les `BB_jours` héritent des biais de `taux_bed_blocking_mco_attente_ssr` (une DMS longue n'est pas toujours une attente d'aval).
- **Effet de version PMSI** : les bornes hautes GHM et les tables de groupage changent chaque campagne ; figer le référentiel pour les séries temporelles.
- **Interprétation politique** : un Gini bas ne signifie pas « pas de problème » mais « problème diffus » — il ne faut pas en conclure à l'absence d'enjeu, seulement à l'inadéquation d'une réponse ciblée.

## Références

- Lorenz MO. Methods of measuring the concentration of wealth. *Publications of the American Statistical Association* 1905;9(70):209-219. (fondement de la courbe de Lorenz ; sans DOI)
- Gini C. *Variabilità e mutabilità: contributo allo studio delle distribuzioni e delle relazioni statistiche*. Bologna: Tipografia di Paolo Cuppini, 1912. (définition originale de l'indice de Gini ; sans DOI)
- Pellico-López A, Cantarero D, Fernández-Feito A, et al. Factors Associated with Bed-Blocking at a University Hospital (Cantabria, Spain) between 2007 and 2015: A Retrospective Observational Study. *Int J Environ Res Public Health* 2019;16(18):3304. [DOI](https://doi.org/10.3390/ijerph16183304)
- Bed Blocking by Hospitalized Patients Awaiting Admission to Intramural Aftercare: A Case Study on Transfer Coordination. *Healthcare (Basel)* 2025;13(16):2038. [DOI](https://doi.org/10.3390/healthcare13162038)
- ATIH — Guide méthodologique PMSI MCO et tables de groupage GHM/CMD, mis à jour annuellement. [Portail ATIH](https://www.atih.sante.fr/)
