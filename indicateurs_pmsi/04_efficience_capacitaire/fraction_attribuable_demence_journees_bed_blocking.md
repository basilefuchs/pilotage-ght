# Fraction Attribuable de la Démence dans les Journées de Bed-Blocking

## Définition

Le bed-blocking (séjour MCO prolongé au-delà de la durée médicalement justifiée dans l'attente d'une place d'aval) ne se répartit pas uniformément dans la patientèle : certains profils le concentrent. Parmi eux, la **démence** est documentée comme le plus fort prédicteur indépendant de sortie retardée. *D'après PubMed*, l'étude populationnelle de Aaltonen et al. 2020 (276 299 patients ≥70 ans, Colombie-Britannique) rapporte un odds ratio de **4,76** pour la sortie retardée chez les patients déments, et un taux de journées de délai majoré (la démence et l'attente de placement en long séjour prédisant le plus grand nombre de jours de délai) [DOI](https://doi.org/10.1016/j.jamda.2020.11.030).

Cet indicateur ne mesure pas *combien* de journées sont bloquées (c'est l'objet de la fiche `taux_bed_blocking_mco_attente_ssr`), mais **quelle part de ces journées serait évitée si les patients déments avaient le même risque de bed-blocking que les patients non déments**. Il s'agit d'une **fraction attribuable en population (FAP, Population Attributable Fraction)**, mesure d'épidémiologie causale qui combine la prévalence de l'exposition (la démence) et la force de son association avec l'issue (le bed-blocking).

Formellement, dans sa version de Levin la plus simple :

```
FAP = p·(RR − 1) / (1 + p·(RR − 1))
```

où `p` est la part de séjours « éligibles bed-blocking » avec démence codée et `RR` le risque relatif (ou ratio de journées) de bed-blocking des déments versus non déments. La formule de Levin n'ajuste pas sur les facteurs de confusion ; lorsqu'un ajustement est nécessaire (âge, comorbidités), on lui préfère l'estimateur de Miettinen reposant sur un RR ajusté, comme le rappellent Khosravi et al. 2021 dans leur revue des manuels d'épidémiologie [DOI](https://doi.org/10.1016/j.gloepi.2021.100062).

**Pourquoi les indicateurs PMSI actuels ne le capturent pas** : le taux de bed-blocking existant est un volume global. Il ne dit pas si l'investissement le plus rentable est une filière SSR « tout-venant » ou un dispositif ciblé démence (UCC, UHR, équipe mobile de gériatrie, anticipation du placement). La FAP transforme une corrélation connue (« les déments bloquent plus ») en une **cible quantifiée d'impact** : « X % des journées bloquées sont concentrées sur le profil démence ».

## Calcul

Source : PMSI MCO (RSA), chaînage possible avec PMSI SSR pour confirmer l'attente de place.

**Étape 1 — Population éligible.** Sélectionner les séjours MCO à risque de bed-blocking, c'est-à-dire ceux dont l'aval est un enjeu :

```
Population N : séjours MCO avec mode_sort = 6 (mutation/transfert vers SSR)
               OU mode_sort = 7 (transfert vers une autre structure)
               OU présence de Z75.1 dans les diagnostics associés (DA)
Restreindre aux patients âgés (≥ 70 ans) pour la cohérence avec la littérature gériatrique.
```

**Étape 2 — Définition de l'issue « bed-blocking ».** Pour chaque séjour, indicatrice de blocage :

```
BB = 1 si DMS_observée > DMS_haute_GHM (borne haute ATIH de l'année de sortie)
     OU Z75.1 présent dans les DA
BB_jours = MAX(0 ; DMS_observée − DMS_haute_GHM)
```

**Étape 3 — Exposition « démence ».** Indicatrice de démence à partir du DP, des DA et des DAS du RSA :

```
DEM = 1 si présence d'au moins un code parmi :
      F00 (démence Alzheimer), F01 (démence vasculaire),
      F02 (démence au cours d'autres maladies), F03 (démence sans précision),
      G30 (maladie d'Alzheimer)
```

**Étape 4 — Risque relatif.** Deux variantes selon que l'on raisonne en séjours bloqués ou en journées bloquées :

```
RR_séjours = [Σ BB(DEM=1)/N(DEM=1)] / [Σ BB(DEM=0)/N(DEM=0)]
RR_journées = [Σ BB_jours(DEM=1)/N(DEM=1)] / [Σ BB_jours(DEM=0)/N(DEM=0)]
```

**Étape 5 — Prévalence et FAP.**

```
p = N(DEM=1) / N
FAP_brute = p·(RR − 1) / (1 + p·(RR − 1))     (formule de Levin)
```

**Étape 6 (recommandée) — FAP ajustée.** Estimer un RR (ou OR si l'issue est rare) ajusté sur âge, sexe, indice de comorbidité de Charlson dérivé des DA, et mode d'entrée par un modèle log-binomial ou de Poisson robuste, puis appliquer l'estimateur de Miettinen :

```
FAP_ajustée = p_cas·(RR_ajusté − 1) / RR_ajusté
   où p_cas = part des séjours bloqués qui sont déments
```

Conventions sur cas limites :
- `N(DEM=0)` ou journées bloquées non déments = 0 → RR non défini : signaler `NA`, ne pas extrapoler (effectif insuffisant).
- Intervalle de confiance : bootstrap sur les séjours (≥ 1 000 rééchantillonnages) ou méthode delta sur le log(RR).
- Le sous-codage de la démence (étape 3) tire mécaniquement la FAP **vers le bas** : interpréter comme un plancher.

Indicateur dérivé — **journées attribuables** :

```
Journées_BB_attribuables_démence = FAP × Σ BB_jours (toute la population N)
```

directement convertible en coût (× perte tarifaire journalière) pour le dialogue de gestion.

## Utilité

- **Arbitrer entre filière SSR générique et dispositif gériatrique ciblé** : si la FAP atteint 40-55 %, la moitié des journées bloquées se joue sur le profil démence ; l'investissement le plus rentable n'est pas un lit SSR polyvalent mais une UCC, une équipe mobile de gériatrie intra-MCO ou l'anticipation systématique du placement EHPAD/USLD.
- **Chiffrer le gisement d'efficience d'un programme « démence »** : les journées attribuables × perte tarifaire journalière donnent l'enveloppe maximale théoriquement récupérable par une action ciblée, argument direct pour la CME et la direction.
- **Prioriser les services** : calculer la FAP par service MCO émetteur (médecine gériatrique, neurologie, médecine interne) révèle où la démence pèse le plus dans le blocage, plutôt qu'une action indifférenciée.
- **Suivre l'effet d'une convention USLD/EHPAD** : comparer la FAP avant/après mise en place d'un circuit d'admission prioritaire pour les patients déments en attente de placement.
- **Documenter une demande de places auprès de l'ARS** : objectiver que le déficit d'aval pèse spécifiquement sur la population démente, segment pour lequel le maintien en MCO est le plus délétère (déconditionnement, syndrome confusionnel surajouté).
- **Articuler avec les indicateurs de profil** : croiser avec `score_charge_sociale_barriere_sortie` et `indice_concentration_journees_bb_profil_patient` pour distinguer le blocage « médico-cognitif » du blocage « médico-social ».

## Sources de Données

- **PMSI MCO — RSA** : `mode_sort` (mode de sortie ; 6 = mutation/transfert SSR, 7 = transfert autre structure), durée de séjour (calculée des dates d'entrée/sortie), code GHM, diagnostic principal (DP) et diagnostics associés (DA/DAS), âge, sexe, FINESS, service/UM. Noms de champs à aligner sur le format RSA du guide méthodologique PMSI MCO en vigueur [à confirmer selon le millésime].
- **ATIH — Bornes GHM** : DMS basse et haute par GHM, publiées annuellement dans les fichiers tarifaires T2A sur le portail ATIH (utiliser le millésime de l'année de sortie du séjour).
- **CIM-10-FR à usage PMSI** : libellés des codes F00–F03, G30 (démences), Z75.1 (attente d'admission en structure adaptée) — référentiel ATIH en vigueur.
- **PMSI SSR — RHS** (optionnel) : par chaînage du numéro anonyme, date d'admission effective en SSR pour valider la réalité de l'attente de place.
- **Outils statistiques** : régression de Poisson robuste / log-binomiale pour le RR ajusté ; packages R `epitools` (FAP), `AF` ou estimation par bootstrap.

## Exemple de Valeurs

Ordres de grandeur experts (non sourcés sauf mention) à confronter aux données locales :

- **Prévalence de la démence codée** parmi les séjours gériatriques à risque d'aval : `p` ≈ 15-30 % (sous-estimé par le sous-codage MCO).
- **RR de bed-blocking déments / non déments** : 1,8-3,0 attendu en MCO français ; à rapprocher de l'OR de 4,76 mesuré sur registre populationnel par Aaltonen et al. 2020 [DOI](https://doi.org/10.1016/j.jamda.2020.11.030) (valeur plus élevée car issue effective et exposition mieux mesurées qu'en PMSI).
- **FAP attendue** : 20-45 % des journées bloquées en gériatrie / médecine interne ; plancher car codage incomplet.
- **Seuil d'alerte gestionnaire** : FAP > 40 % → bascule des priorités d'investissement vers un dispositif gériatrique ciblé plutôt qu'un accroissement indifférencié des capacités SSR.

## Limites

- **Sous-codage de la démence en MCO** : la démence est fréquemment non documentée dans les DA d'un séjour aigu motivé par une autre cause (sepsis, chute, décompensation). La FAP obtenue est un **plancher** ; un chaînage avec les ALD (ALD 15) ou la consommation d'anticholinestérasiques (DCIR) la rapprocherait de la valeur réelle.
- **Causalité non garantie** : la FAP suppose une relation causale entre exposition et issue. La formule de Levin brute est biaisée en présence de confusion ; il faut un RR ajusté (Miettinen) pour une interprétation contrefactuelle valide, comme le soulignent Khosravi et al. 2021 [DOI](https://doi.org/10.1016/j.gloepi.2021.100062). Même ajustée, la FAP reste observationnelle et ne prouve pas qu'une intervention supprimerait effectivement ces journées.
- **Définition du bed-blocking par la borne haute** : un dépassement de borne peut avoir des causes médicales légitimes indépendantes de l'attente d'aval, surtout chez les déments (complications, dénutrition). Le numérateur de journées bloquées est donc lui-même imparfait (cf. limites de `taux_bed_blocking_mco_attente_ssr`).
- **Effectifs minimaux** : en deçà de ~200 séjours éligibles par maille d'analyse, le RR et la FAP deviennent instables ; privilégier une agrégation annuelle et à l'échelle du GHT.
- **Effet de version PMSI** : les bornes hautes GHM changent chaque campagne tarifaire ; toute comparaison inter-annuelle exige le référentiel de chaque année.
- **Non-additivité** : les FAP de plusieurs facteurs (démence, isolement social, grand âge) ne s'additionnent pas — leur somme peut dépasser 100 %. Ne pas sommer mécaniquement avec d'autres indicateurs de profil.

## Références

- Aaltonen M, El Adam S, Martin-Matthews A, et al. Dementia and Poor Continuity of Primary Care Delay Hospital Discharge in Older Adults: A Population-Based Study From 2001 to 2016. *J Am Med Dir Assoc* 2021;22(7):1484-1492.e3. [DOI](https://doi.org/10.1016/j.jamda.2020.11.030)
- Khosravi A, Nazemipour M, Shinozaki T, Mansournia MA. Population attributable fraction in textbooks: Time to revise. *Glob Epidemiol* 2021;3:100062. [DOI](https://doi.org/10.1016/j.gloepi.2021.100062)
- Pellico-López A, Cantarero D, Fernández-Feito A, et al. Factors Associated with Bed-Blocking at a University Hospital (Cantabria, Spain) between 2007 and 2015: A Retrospective Observational Study. *Int J Environ Res Public Health* 2019;16(18):3304. [DOI](https://doi.org/10.3390/ijerph16183304)
- Ou L, Chen J, Young L, et al. Delayed discharge from hospital in older adults: a systematic review. *BMJ Open* 2021;11(4):e044193. [DOI](https://doi.org/10.1136/bmjopen-2020-044193)
- Landeiro F, Roberts K, Gray AM, Leal J. Delayed hospital discharges of older patients: a systematic review on prevalence and costs. *Age Ageing* 2017;46(3):341-343. [DOI](https://doi.org/10.1093/ageing/afx028)
- ATIH — Guide méthodologique de production des informations relatives à l'activité médicale (PMSI MCO) et fichiers de bornes GHM, mis à jour annuellement. [Portail ATIH](https://www.atih.sante.fr/)
