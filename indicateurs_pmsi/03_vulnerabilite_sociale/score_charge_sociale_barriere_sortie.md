# Score de Charge Sociale comme Barrière à la Sortie

## Définition

Tous les bed-blockers ne se ressemblent pas. Schématiquement, deux sous-types coexistent : le blocage **médico-filière** (le patient relève d'un SSR mais aucune place n'est disponible) et le blocage **médico-social** (le patient pourrait rentrer, mais l'absence de logement adapté, d'entourage ou d'aide à domicile l'en empêche). Distinguer les deux est décisif car les leviers diffèrent radicalement : créer des lits SSR pour le premier, mobiliser le service social et les dispositifs médico-sociaux pour le second.

*D'après PubMed*, la littérature confirme le poids des facteurs sociaux dans la sortie retardée : Aaltonen et al. 2020 identifient l'attente de placement en long séjour et la faible continuité du médecin traitant comme déterminants majeurs [DOI](https://doi.org/10.1016/j.jamda.2020.11.030) ; Pellico-López et al. 2019, qui indexent leur étude sur les « social determinants to health », montrent que l'attente d'une destination de sortie allonge la durée de séjour [DOI](https://doi.org/10.3390/ijerph16183304).

Cet indicateur construit un **score gradué de charge sociale** à partir des codes CIM-10 de difficulté sociale, **restreint aux séjours longs (au-delà de la borne haute du GHM)**, afin de mesurer l'**intensité des barrières non médicales à la sortie** chez les patients déjà bloqués. Contrairement à une simple indicatrice de présence, le score additionne plusieurs **familles** de barrières, pondérées selon leur force documentée d'obstacle à la sortie :

```
Score_social(séjour) = Σ_familles w_f · 1[famille f codée]
```

**Positionnement vs l'existant.** Le dépôt contient déjà `taux_hospi_isolement_social_geriatrique` (part des séjours 75+ avec ≥ 1 DAS d'isolement, sur **toute** la cohorte gériatrique) et `taux_codage_das_sociaux_z55_z65` (codage des Z55-Z65, généraliste). Le présent indicateur s'en distingue sur trois points : (1) il est **restreint aux séjours prolongés / bed-blocking**, pas à toute la patientèle ; (2) il est **gradué** (somme pondérée de familles distinctes), pas binaire, pour mesurer l'**intensité** de la barrière ; (3) il intègre la famille **logement/économique (Z59)** absente des listes d'isolement. Sa finalité n'est pas de dépister l'isolement mais de **typer le bed-blocker** (sous-type médico-social vs médico-filière).

## Calcul

Source : PMSI MCO (RSA), diagnostics associés (DA/DAS).

**Étape 1 — Population : séjours prolongés à risque d'aval.**

```
Population N : séjours MCO avec DMS_observée > DMS_haute_GHM
               ET (mode_sort = 6 OU 7 OU Z75.1 dans les DA)
```

**Étape 2 — Familles de barrières sociales** (codes CIM-10-FR à usage PMSI, en DA/DAS) :

```
F1 Logement / précarité économique : Z59 (Z59.0 sans-abri, Z59.1 logement
   inadéquat, Z59.x difficultés économiques)
F2 Isolement / vie seule           : Z60.2 (vie en isolement), Z60.4 (exclusion)
F3 Entourage défaillant            : Z63.4/Z63.5 (perte/rupture familiale),
                                     Z63.6 (proche dépendant seul au domicile)
F4 Dépendance vis-à-vis du soignant: Z74 (Z74.0 mobilité réduite, Z74.1 besoin
                                     d'assistance aux soins personnels, Z74.2/3)
F5 Attente de structure adaptée    : Z75.1 (marqueur explicite d'attente d'aval)
```

**Étape 3 — Score pondéré par séjour.** Pondérations `w_f` à fixer par consensus local (défaut : poids égaux à 1, soit un simple compte de familles ; ou pondération experte privilégiant F1 et F4, les plus directement bloquantes pour un retour à domicile) :

```
Score_social = w1·1[F1] + w2·1[F2] + w3·1[F3] + w4·1[F4] + w5·1[F5]
   (chaque famille comptée une fois, quel que soit le nombre de codes dedans)
```

**Étape 4 — Indicateurs agrégés.**

```
Score_moyen   = moyenne du Score_social sur N
Part_barrière = part des séjours prolongés avec Score_social ≥ 1   (au moins une
                barrière sociale codée → présomption de sous-type médico-social)
Part_intense  = part des séjours avec Score_social ≥ 2   (barrières multiples)
```

**Étape 5 — Typologie du bed-blocker.** Croiser avec un marqueur de sous-type médico-filière (séjour avec `mode_sort=6` mais **aucun** code social) :

```
Sous-type médico-social  : Score_social ≥ 1
Sous-type médico-filière : Score_social = 0 ET mode_sort = 6 (attente SSR pure)
Ratio social/filière = N(Score≥1) / N(Score=0 & mode_sort=6)
```

Conventions sur cas limites :
- Familles non exclusives : un séjour peut cumuler F1+F4 ; le score les additionne (c'est l'objectif).
- Sous-codage massif des Z sociaux (cf. Limites) → le score est un **plancher** ; `Part_barrière` sous-estime la composante sociale réelle.
- N < 30 séjours prolongés → ne pas publier (instabilité).
- Pondérations : documenter explicitement la grille `w_f` retenue ; toute comparaison exige la même grille.

## Utilité

- **Typer les bed-blockers pour cibler le levier** : un `Part_barrière` élevé désigne un blocage à dominante sociale → renforcer le service social hospitalier, les liens avec les dispositifs APA / aide à domicile / hébergement, plutôt que demander des lits SSR.
- **Dimensionner le service social hospitalier** : le volume de séjours prolongés avec barrières sociales objective la charge de travail d'évaluation et d'orientation sociale, argument pour des ETP d'assistants sociaux.
- **Orienter précocement** : un score élevé détecté tôt déclenche l'activation du circuit social (signalement, montage de dossier MDPH/aide-ménagère, recherche d'hébergement) avant que le séjour ne se prolonge.
- **Distinguer les responsabilités dans le dialogue territorial** : séparer ce qui relève du déficit d'offre SSR (médico-filière, négociation ARS) de ce qui relève de l'amont social (collectivités, conseil départemental, dispositifs domicile).
- **Évaluer un dispositif de coordination sociale** : suivre `Part_barrière` et le ratio social/filière avant/après mise en place d'une cellule de gestion des sorties complexes (PRADO, plateforme territoriale d'appui).
- **Articuler avec les autres indicateurs de profil** : combiner avec `fraction_attribuable_demence_journees_bed_blocking` (axe cognitif) et `indice_concentration_journees_bb_profil_patient` (axe distribution) pour une cartographie complète du bed-blocker.

## Sources de Données

- **PMSI MCO — RSA** : diagnostics associés (DA/DAS), `mode_sort`, durée de séjour, code GHM, âge, FINESS, service/UM. Noms de champs à aligner sur le format RSA du guide méthodologique PMSI MCO en vigueur [à confirmer selon le millésime].
- **ATIH — Bornes GHM** : DMS haute par GHM (fichiers tarifaires T2A, millésime de l'année de sortie).
- **CIM-10-FR à usage PMSI** : sous-catégories Z59, Z60.2/Z60.4, Z63.4/Z63.5/Z63.6, Z74.x, Z75.1 — référentiel ATIH en vigueur ; vérifier l'existence et le libellé exact des sous-codes Z59 dans le millésime utilisé.
- **Données du service social hospitalier** (hors PMSI, optionnel) : pour calibrer les pondérations `w_f` et valider la sensibilité du codage social vis-à-vis des situations réellement bloquantes.

## Exemple de Valeurs

Ordres de grandeur experts (non sourcés sauf mention) à calibrer localement :

- **Part de séjours prolongés avec ≥ 1 barrière sociale codée** : très variable selon la qualité du codage social, typiquement 5-25 % (plancher en raison du sous-codage).
- **Score moyen** : 0,1-0,6 famille par séjour prolongé en codage courant (faible du fait du sous-codage), pouvant monter si l'établissement code activement les Z sociaux.
- **Cadrage littérature** : l'attente d'une destination de sortie et les déterminants sociaux figurent parmi les facteurs allongeant la durée de séjour (Pellico-López 2019 [DOI](https://doi.org/10.3390/ijerph16183304)) ; le blocage est principalement lié à des délais de coordination plutôt qu'à la seule pénurie de lits (étude transferts 2025 [DOI](https://doi.org/10.3390/healthcare13162038)).
- **Seuil d'alerte** : `Part_barrière` > 20 % sur les séjours prolongés d'un service → renforcement du circuit social prioritaire sur la demande de lits SSR.

## Limites

- **Sous-codage des Z sociaux** : les diagnostics de difficulté sociale sont très peu codés en MCO français (ils n'apportent pas de valorisation T2A directe et reposent sur une évaluation sociale tracée). Le score est un **plancher** sévère ; un score nul ne prouve pas l'absence de barrière sociale, seulement son absence de codage. C'est la principale limite, partagée avec `taux_hospi_isolement_social_geriatrique` et `taux_codage_das_sociaux_z55_z65`.
- **Hétérogénéité inter-établissements** : les écarts de score reflètent autant les pratiques de codage social (présence d'assistants sociaux codeurs, sensibilisation DIM) que la réalité sociale des patients ; privilégier les évolutions temporelles intra-établissement aux comparaisons brutes.
- **Pondérations conventionnelles** : la grille `w_f` est un choix expert non standardisé ; documenter et figer la grille, et tester la sensibilité des résultats à des pondérations alternatives.
- **Chevauchement partiel** avec `taux_hospi_isolement_social_geriatrique` (codes Z60/Z63/Z74/Z75.1 communs) : les deux ne doivent pas être additionnés ; le présent score s'en distingue par sa population (séjours prolongés) et sa graduation.
- **Non-spécificité de Z75.1** : ce code marque l'attente de structure sans préjuger de la nature sociale ou filière du blocage ; il est ici compté comme une famille parmi d'autres, à ne pas surinterpréter isolément.
- **Effectifs et stabilité** : sous 30 séjours prolongés par maille, le score n'est pas interprétable ; agréger à l'année et au GHT.

## Références

- Aaltonen M, El Adam S, Martin-Matthews A, et al. Dementia and Poor Continuity of Primary Care Delay Hospital Discharge in Older Adults: A Population-Based Study From 2001 to 2016. *J Am Med Dir Assoc* 2021;22(7):1484-1492.e3. [DOI](https://doi.org/10.1016/j.jamda.2020.11.030)
- Pellico-López A, Cantarero D, Fernández-Feito A, et al. Factors Associated with Bed-Blocking at a University Hospital (Cantabria, Spain) between 2007 and 2015: A Retrospective Observational Study. *Int J Environ Res Public Health* 2019;16(18):3304. [DOI](https://doi.org/10.3390/ijerph16183304)
- Bed Blocking by Hospitalized Patients Awaiting Admission to Intramural Aftercare: A Case Study on Transfer Coordination. *Healthcare (Basel)* 2025;13(16):2038. [DOI](https://doi.org/10.3390/healthcare13162038)
- Ou L, Chen J, Young L, et al. Delayed discharge from hospital in older adults: a systematic review. *BMJ Open* 2021;11(4):e044193. [DOI](https://doi.org/10.1136/bmjopen-2020-044193)
- ATIH — Guide méthodologique PMSI MCO et CIM-10-FR à usage PMSI (codes Z55-Z65, Z74, Z75), mis à jour annuellement. [Portail ATIH](https://www.atih.sante.fr/)
