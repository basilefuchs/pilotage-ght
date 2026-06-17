# Taux de Syndromes Gériatriques Acquis en Séjour Prolongé

## Définition

Le patient « bed-blocker » n'est pas seulement un problème d'efficience capacitaire : le maintien prolongé en milieu de soins aigus, inadapté à une personne âgée stabilisée, **génère lui-même de la morbidité**. C'est la « cascade gériatrique » de l'hospitalisation prolongée : alitement, désorientation, dénutrition, perte d'autonomie. *D'après PubMed*, Covinsky et al. 2011 décrivent la **hospitalization-associated disability (HAD)**, déclin fonctionnel survenant chez environ un tiers des patients de plus de 70 ans, parfois indépendamment du succès du traitement de la pathologie aiguë [DOI](https://doi.org/10.1001/jama.2011.1556). Takahashi et al. 2024 mesurent une incidence de HAD de **37,1 %** chez les patients âgés hospitalisés pour insuffisance cardiaque [DOI](https://doi.org/10.1253/circj.CJ-23-0722). Sur le versant bed-blocking, une étude transversale 2025 en médecine interne rapporte, pendant les séjours retardés, **31,3 % de délire** et **35,4 % d'infections nosocomiales** [DOI](https://doi.org/10.3390/nursrep15030098).

Cet indicateur mesure la **proportion de séjours MCO prolongés (au-delà de la borne haute du GHM) au cours desquels apparaît au moins un syndrome gériatrique acquis** : syndrome confusionnel, escarre, dénutrition, chute, déshydratation, infection associée aux soins. Il caractérise ainsi le **profil iatrogène du bed-blocker** — le coût humain du blocage, et non plus seulement son coût tarifaire.

Formellement :

```
Taux = (nb séjours prolongés avec ≥ 1 syndrome gériatrique acquis codé)
       / (nb séjours prolongés éligibles) × 100
```

**Pourquoi les indicateurs PMSI actuels ne le capturent pas** : le taux de bed-blocking mesure des journées et des euros ; les indicateurs de sécurité PSI (cf. `psi90_patient_safety_indicators`) ciblent des événements indésirables transversaux non spécifiques du grand âge bloqué. Aucun n'isole la **morbidité gériatrique générée par l'attente d'aval**, qui est précisément l'argument clinique (et non seulement financier) pour accélérer la sortie. L'indicateur relie la dimension efficience (séjour prolongé) à la dimension qualité/sécurité (syndrome acquis).

## Calcul

Source : PMSI MCO (RSA), diagnostics associés (DA/DAS).

**Étape 1 — Population éligible : séjours prolongés à risque d'aval.**

```
Population N : séjours MCO avec patients ≥ 75 ans
               ET DMS_observée > DMS_haute_GHM (borne haute ATIH année de sortie)
               ET (mode_sort = 6 OU 7 OU Z75.1 dans les DA)
```

**Étape 2 — Repérage des syndromes gériatriques.** Indicatrice par grande famille, à partir des DA/DAS du RSA (codes CIM-10-FR à usage PMSI) :

```
SYND = 1 si présence d'au moins un code parmi :
  • Syndrome confusionnel / délire : F05 (et sous-codes)
  • Escarre de décubitus            : L89 (et sous-codes L89.0–L89.9)
  • Dénutrition                     : E40–E46 (notamment E43 sévère, E44, E46)
  • Déshydratation                  : E86
  • Chute / traumatisme de chute    : R29.6 (chutes à répétition),
                                      W00–W19 (codes cause externe de chute)
  • Infection associée aux soins    : selon repérage local (ex. A04.7
                                      C. difficile, N39.0 IU, J15.x pneumopathie),
                                      à manier avec prudence (cf. Limites)
```

**Étape 3 — Taux global et par famille.**

```
Taux_global   = Σ SYND / N × 100
Taux_délire   = Σ (F05) / N × 100
Taux_escarre  = Σ (L89) / N × 100
Taux_dénutr.  = Σ (E43–E46) / N × 100
...
```

**Étape 4 — Indice de charge (multi-syndromes).** Compter les familles distinctes par séjour pour distinguer mono- et poly-atteinte :

```
Charge_syndromique = nombre de familles de syndromes codées (0 à 6) par séjour
Part_polyatteinte  = part des séjours avec Charge ≥ 2
```

Conventions sur cas limites :
- DA absents / RSA incomplet → séjour exclu du dénominateur (qualité de codage insuffisante).
- N < 30 séjours sur la maille → ne pas publier le taux (instabilité, risque d'identification).
- Pas de variable « present-on-admission » en PMSI MCO français : l'« acquis » ne peut être strictement prouvé (cf. Limites) ; l'indicateur mesure la **présence** du syndrome dans un séjour prolongé, présomption forte mais non certaine d'acquisition.

Indicateur dérivé — **comparaison prolongé vs non prolongé** : calculer le même taux chez les séjours gériatriques **non** prolongés (DMS ≤ borne haute) et former le ratio. Un ratio > 1 quantifie le sur-risque syndromique associé à la prolongation, contrôlant partiellement le biais de patientèle.

## Utilité

- **Documenter le coût humain du bed-blocking** : au-delà des euros, fournir à la CME et à la CDU un indicateur de la morbidité gériatrique générée par l'attente d'aval — argument clinique pour prioriser la fluidification des filières.
- **Cibler la prévention en service** : un taux d'escarre élevé oriente vers les protocoles de mobilisation/supports ; un taux de délire élevé vers les protocoles de prévention de la confusion (réorientation, sommeil, limitation des contentions).
- **Justifier une équipe mobile de gériatrie intra-MCO** : le sur-risque syndromique des séjours prolongés (indicateur dérivé) chiffre le bénéfice attendu d'une intervention gériatrique précoce sur les patients en attente d'aval.
- **Prioriser entre services émetteurs** : ventiler par service MCO pour identifier où la cascade gériatrique est la plus active (médecine interne, orthopédie post-fracture, neurologie post-AVC).
- **Suivre l'effet d'un programme « hôpital ami des aînés »** : évaluer l'impact d'unités de soins aigus gériatriques (UGA) ou de bundles de prévention sur le taux de syndromes acquis chez les séjours prolongés.
- **Alimenter le dialogue qualité-efficience** : croiser avec `taux_bed_blocking_mco_attente_ssr` (journées) et `fraction_attribuable_demence_journees_bed_blocking` (profil) pour une lecture intégrée « volume × profil × conséquence ».

## Sources de Données

- **PMSI MCO — RSA** : diagnostics associés (DA/DAS), diagnostic principal (DP), code GHM, `mode_sort`, durée de séjour, âge, service/UM, FINESS. Noms de champs à aligner sur le format RSA du guide méthodologique PMSI MCO en vigueur [à confirmer selon le millésime].
- **ATIH — Bornes GHM** : DMS haute par GHM (fichiers tarifaires T2A, millésime de l'année de sortie).
- **CIM-10-FR à usage PMSI** : codes F05, L89.x, E40–E46, E86, R29.6, W00–W19, et codes d'infection retenus localement — référentiel ATIH en vigueur.
- **HAS** : repères pour la prévention des syndromes gériatriques et la démarche « hôpital ami des aînés » (à utiliser comme cadre d'interprétation, non comme source de calcul).
- **Recommandation de codage** : vérifier les consignes de codage des escarres et de la dénutrition (codes à coder en DA selon effort de prise en charge) dans la notice ATIH de la campagne concernée.

## Exemple de Valeurs

Ordres de grandeur experts et littérature (non transposables tels quels au PMSI) :

- **Incidence de HAD (déclin fonctionnel)** : ~33 % des ≥ 70 ans hospitalisés (Covinsky 2011 [DOI](https://doi.org/10.1001/jama.2011.1556)) ; 37,1 % chez les insuffisants cardiaques âgés (Takahashi 2024 [DOI](https://doi.org/10.1253/circj.CJ-23-0722)).
- **Pendant un séjour retardé** : délire ~31 %, infections nosocomiales ~35 % (médecine interne, MDPI 2025 [DOI](https://doi.org/10.3390/nursrep15030098)).
- **Taux PMSI attendu (présence codée, plancher)** : sensiblement inférieur aux taux cliniques ci-dessus du fait du sous-codage — ordre de grandeur expert 10-25 % de séjours prolongés avec ≥ 1 syndrome codé, à calibrer localement.
- **Seuil d'alerte** : taux global > 20 % ou part de poly-atteinte > 8 % sur un service → audit ciblé de la prévention gériatrique.

## Limites

- **Absence de marqueur present-on-admission (POA)** : le PMSI MCO français ne distingue pas un diagnostic présent à l'admission d'un diagnostic acquis pendant le séjour. L'indicateur mesure la **présence** du syndrome dans un séjour prolongé, non son acquisition certaine. L'indicateur dérivé (ratio prolongé/non prolongé) atténue ce biais mais ne l'élimine pas.
- **Sous-codage des syndromes gériatriques** : escarre, dénutrition et confusion sont notoirement sous-documentés en DA (ils ne sont codés que s'ils ont mobilisé une prise en charge tracée). Le taux est un plancher ; les variations inter-établissements peuvent refléter des différences de codage autant que de soins réels.
- **Infections associées aux soins** : leur repérage par codes CIM-10 est peu spécifique (une infection codée n'est pas forcément nosocomiale) ; à utiliser avec prudence, idéalement en lien avec la surveillance IAS de l'établissement plutôt qu'en lecture PMSI brute.
- **Confusion avec la pathologie d'amont** : certains syndromes (chute, confusion) peuvent être le motif d'hospitalisation et non une conséquence du séjour ; le filtre « DA et non DP » réduit mais n'annule pas ce risque.
- **Comparabilité** : les différences de pratiques de codage entre établissements du GHT limitent la comparaison directe ; privilégier les évolutions temporelles intra-établissement.
- **Effectifs et stabilité** : sous 30 séjours prolongés par maille, le taux n'est pas interprétable ; agréger à l'année et au niveau du GHT.

## Références

- Covinsky KE, Pierluissi E, Johnston CB. Hospitalization-associated disability: "She was probably able to ambulate, but I'm not sure". *JAMA* 2011;306(16):1782-1793. [DOI](https://doi.org/10.1001/jama.2011.1556)
- Takahashi T, Iwata K, Morisawa T, et al. Incidence of Hospitalization-Associated Disability in Older Patients With Heart Failure. *Circ J* 2024;88(5):672-679. [DOI](https://doi.org/10.1253/circj.CJ-23-0722)
- Prevalence of Delayed Discharge Among Patients Admitted to the Internal Medicine Wards: A Cross-Sectional Study. *Nurs Rep* 2025;15(3):98. [DOI](https://doi.org/10.3390/nursrep15030098)
- Ou L, Chen J, Young L, et al. Delayed discharge from hospital in older adults: a systematic review. *BMJ Open* 2021;11(4):e044193. [DOI](https://doi.org/10.1136/bmjopen-2020-044193)
- ATIH — Guide méthodologique de production des informations relatives à l'activité médicale (PMSI MCO) et consignes de codage CIM-10-FR (escarres, dénutrition), mis à jour annuellement. [Portail ATIH](https://www.atih.sante.fr/)
- HAS — Repères pour la prévention de la perte d'autonomie et la démarche « hôpital ami des aînés ». [HAS](https://www.has-sante.fr/)
