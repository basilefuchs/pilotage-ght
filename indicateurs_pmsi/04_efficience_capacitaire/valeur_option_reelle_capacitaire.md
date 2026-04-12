# Valeur d'Option Réelle Capacitaire

## Définition

La théorie des options réelles (Myers, 1977 ; Dixit & Pindyck, 1994) étend le cadre des options financières aux décisions d'investissement réel en présence d'incertitude. Une **option financière** est le droit (sans obligation) d'acheter ou vendre un actif à un prix fixé à une date future — sa valeur provient précisément de la flexibilité qu'elle confère. Une **option réelle** est la valeur de la flexibilité opérationnelle d'un actif physique : la possibilité de différer, d'abandonner, d'étendre ou de réorienter un investissement selon l'évolution de l'environnement.

Appliquée à la capacité hospitalière, la **Valeur d'Option Réelle Capacitaire** (VORC) mesure la **valeur économique de la flexibilité** d'une unité ou d'un lit : la capacité de basculer une ressource d'un usage à un autre (lit SSR → lit MCO lors d'une crise, bloc chirurgical → unité COVID, HAD → soins palliatives à domicile) en réponse à un choc imprevisible.

La VORC répond à une question que les outils d'efficience classiques ne posent pas : **combien vaut le fait de ne pas fermer ces lits "excédentaires" ?** Un hôpital optimisé au plus juste (zéro slack, zéro marge de manœuvre) est efficace en régime nominal mais vulnérable et coûteux en cas de choc. La VORC quantifie la valeur d'assurance de la capacité de réserve — et justifie économiquement son maintien face aux pressionsbudgétaires qui poussent à supprimer tout ce qui semble "non utilisé".

Formellement, la VORC d'une unité flexible est assimilée à une **option d'échange** (Margrabe, 1978) : le droit d'échanger l'usage actuel d'une ressource (valeur V_actuel) contre un usage alternatif (valeur V_alternatif), au coût de conversion C_switch.

**VORC = E[max(V_alternatif − V_actuel − C_switch, 0)]**

où l'espérance est calculée sur les scénarios de choc futurs possibles.

## Calcul

Modélisation des usages alternatifs :

```
Pour une unité capacitaire donnée (ex. 10 lits SSR neurologique) :

Usage actuel A :
  V_A = valorisation annuelle en régime nominal
       = Σ_séjours (GHS_SSR × taux_occupation)
  Ex. : 10 lits × 365j × 85% × tarif GHS_SSR moyen = V_A en €/an

Usage alternatif B (activé lors d'un choc) :
  Ex. B = conversion en lits MCO médecine lors d'une vague épidémique
  V_B = valorisation des séjours MCO qui seraient réalisés
       = Nseances_MCO × GHS_MCO_moyen
  Ex. : 10 lits × durée_choc_semaines × taux_occupation_crise × GHS_MCO

Coût de conversion C_switch :
  C_switch = coût one-shot de la réorientation de l'unité
  = équipements temporaires + formation/habilitation du personnel + logistique
  + coût d'opportunité (manque à gagner SSR pendant la conversion)
  → Estimé sur la base des conversions historiques (COVID 2020 : données disponibles)
```

Estimation de la VORC par la formule de Margrabe :

```
Assimiler la VORC à une option d'échange entre deux actifs risqués :
  S₁ = V_alternatif = valeur de l'usage alternatif (variable aléatoire)
  S₂ = V_actuel     = valeur de l'usage nominal (variable aléatoire)
  K  = C_switch      = coût de la conversion (strike de l'option)

Formule de Margrabe (1978) :
  VORC = S₁ × N(d₁) − S₂ × N(d₂) − K × e^(−rT) × N(d₂)

  avec :
    σ² = σ₁² + σ₂² − 2ρσ₁σ₂   (volatilité composite)
    d₁ = [ln(S₁/S₂) + (σ²/2)T] / (σ√T)
    d₂ = d₁ − σ√T
    N() = fonction de répartition de la loi normale standard
    T   = horizon de planification (ex. 1 an)
    r   = taux d'actualisation (taux sans risque, ex. 2%)
    ρ   = corrélation entre V_alternatif et V_actuel

  → σ₁ : volatilité de la demande MCO (estimée depuis les séries PMSI hebdomadaires)
  → σ₂ : volatilité de la demande SSR (estimée depuis les séries PMSI hebdomadaires)
```

Approche simplifiée par scénarios (plus accessible opérationnellement) :

```
Définir K scénarios de choc ωₖ avec probabilités pₖ et durées dₖ :

  ω₁ = vague grippale sévère (p₁ = 0.30, durée = 6 semaines)
  ω₂ = pandémie (p₂ = 0.05, durée = 12 semaines)
  ω₃ = canicule + saturation gériatrie (p₃ = 0.20, durée = 4 semaines)
  ω₄ = grève soignants (p₄ = 0.10, durée = 3 semaines)
  ω₅ = pas de choc (p₅ = 0.35, durée = 0)

Pour chaque scénario ωₖ :
  Gain_nette(ωₖ) = max(V_alternatif(ωₖ) − V_actuel(ωₖ) − C_switch, 0)

VORC_scénarios = Σₖ pₖ × Gain_nette(ωₖ) × dₖ / 52
  → En €/an (valeur attendue annualisée de la flexibilité)

Ratio VORC / Coût_maintien_capacité_réserve :
  → Si ratio > 1 : la flexibilité vaut plus que le coût de la maintenir
  → Si ratio < 1 : la suppression de la capacité est économiquement justifiée
    (la valeur d'option ne compense pas le coût de maintien)
```

## Utilité

- **Justifier économiquement le maintien de lits "sous-utilisés"** : face aux contrôleurs de gestion et aux ARS qui identifient des lits avec un taux d'occupation inférieur à 85% comme candidats à la fermeture, la VORC fournit un argument quantitatif : ces lits ont une valeur d'option (leur flexibilité en cas de crise) qui ne figure dans aucun tableau de bord de taux d'occupation — le coût réel de leur fermeture inclut la perte de cette option
- **Comparer les architectures capacitaires selon leur flexibilité** : entre deux projets de reconstruction hospitalière — l'un avec des unités spécialisées non convertibles, l'autre avec des unités flexibles — la VORC quantifie la prime de valeur de la flexibilité, qui doit être intégrée dans le bilan économique du projet immobilier
- **Prioriser les investissements de flexibilisation** : si l'installation de cloisons mobiles dans une unité polyvalente coûte C et augmente la VORC de ΔV, l'investissement est rentable si ΔV > C — cadre de décision rigoureux pour les dépenses d'agilité organisationnelle
- **Quantifier le "coût de la sur-optimisation"** : les établissements qui ont supprimé toute marge de manœuvre pour atteindre des taux d'occupation > 95% ont une VORC nulle — et ont payé un prix élevé lors de la crise COVID (déprogrammation totale des activités électives car pas de marge pour absorber les patients COVID) ; la VORC aurait pu quantifier ce risque ex-ante
- **Dialogue avec les ARS sur les CPOM et les financements** : dans les négociations de Contrat Pluriannuel d'Objectifs et de Moyens, la VORC est un outil pour défendre des financements de capacité de réserve au titre de la préparation aux crises sanitaires — argument pertinent dans le cadre des plans ORSAN et de la résilience du système de santé
- **Benchmark entre GHTs** : comparer le ratio VORC/coût entre établissements — les GHTs avec une VORC relative élevée ont une architecture organisationnelle plus flexible et constituent un modèle pour les GHTs qui cherchent à améliorer leur résilience sans augmenter leur capacité nominale

## Sources de Données

- **PMSI MCO et SSR RSA** (séries hebdomadaires sur 3-5 ans) : estimation de la volatilité σ₁ et σ₂ des demandes MCO et SSR, des durées et amplitudes des chocs historiques — base empirique pour calibrer les paramètres du modèle d'option
- **Données financières PMSI** : valorisation GHS par séjour pour estimer V_actuel et V_alternatif en euros — disponibles dans les extractions PMSI avec les tableaux de valorisation ATIH
- **Données de gestion interne** : coûts de conversion historiques (temps de personnel pour reconfiguration, achats d'équipements temporaires, formation) — pour estimer C_switch de façon empirique plutôt que théorique
- **Sources exogènes de probabilité des chocs** : données Sentinelles/SPF pour la fréquence des vagues épidémiques, données météorologiques INSEE pour les canicules — pour calibrer les probabilités pₖ des scénarios
- **Indice de Résilience Opérationnelle (IRO)** : complémentaire de la VORC — l'IRO mesure la vitesse de récupération après un choc (déjà exercé), la VORC mesure la valeur de la capacité à se réorienter avant le choc (prospectif)

## Exemple de Valeurs

- **VORC d'une unité de 10 lits SSR polyvalents (convertibles en MCO médecine)** :
  V_actuel = 10 lits × 80% × 365j × 250€/j = 730 000 €/an
  C_switch = 15 000 € (formation personnel + équipements temporaires)
  Scénario vague grippale (p=0.30, durée 6 semaines) :
    Gain MCO = 10 lits × 6 semaines × 7j × 90% × 500€/j GHS_MCO = 189 000 €
    Gain_nette = max(189 000 − 0 − 15 000, 0) = 174 000 € (SSR déjà "manqué")
  VORC_scénarios ≈ 0.30 × 174 000 × (6/52) + autres scénarios ≈ **35 000-65 000 €/an**

- **Ratio VORC / coût annuel de maintien** :
  Coût de maintien d'un lit "sous-utilisé" (taux occupation 60% au lieu de 85%) :
  Coût_maintien ≈ 25 lits × (85%-60%) × 365j × 200€ coût/j = 456 000 €/an
  Si VORC = 180 000 €/an → ratio = 0.39 → fermeture économiquement justifiée
  Si VORC = 520 000 €/an → ratio = 1.14 → maintien justifié par la valeur d'option

- **Impact COVID-19 mesuré ex-post** : les établissements qui avaient des lits de réserve identifiés (taux occupation pré-COVID 75-80%) ont réorienté 15-25% de leur capacité en moins de 72h ; les établissements à 95%+ ont subi une déprogrammation totale avec perte de recettes MCO estimée à 30-40% sur 8 semaines → valeur d'option réalisée de plusieurs millions d'euros pour les premiers

## Limites

- La **calibration des paramètres** (σ₁, σ₂, ρ, pₖ) est la principale difficulté pratique : les données PMSI hebdomadaires couvrent rarement plus de 5 ans, donnant peu d'observations de chocs majeurs pour estimer les probabilités avec précision ; les estimations sont sensibles aux hypothèses sur la distribution des chocs (normales vs loi de puissance pour les chocs extrêmes)
- La **formule de Margrabe** suppose des processus log-normaux pour V_actuel et V_alternatif — hypothèse discutable pour les activités hospitalières soumises à des régulations tarifaires et des contraintes réglementaires qui tronquent la distribution des valeurs ; l'approche par scénarios discrets est plus robuste mais moins précise
- La VORC ne capture que la **valeur de la flexibilité de réorientation** — elle n'intègre pas la valeur de la capacité à augmenter le volume total (option de croissance) ni la valeur de la réduction de volume (option d'abandon) ; une analyse complète des options réelles hospitalières intègrerait ces trois types d'options
- La VORC requiert un **accès aux données de coûts** (coût par journée, coût de conversion) qui ne sont pas dans le PMSI et varient fortement selon les établissements — une erreur de 30% sur C_switch ou sur le coût journalier modifie significativement le ratio VORC/coût et donc la décision de conserver ou supprimer la capacité

## Références

- [Myers S.C. — Determinants of corporate borrowing, Journal of Financial Economics 1977](https://doi.org/10.1016/0304-405X(77)90015-0) — premier article formalisant le concept d'options réelles
- [Dixit A.K., Pindyck R.S. — Investment under Uncertainty, Princeton University Press 1994 : référence fondamentale de la théorie des options réelles appliquée à l'investissement]
- [Margrabe W. — The value of an option to exchange one asset for another, Journal of Finance 1978](https://doi.org/10.1111/j.1540-6261.1978.tb03397.x) — formule de valorisation des options d'échange
- [Angelis T. — Real options in healthcare capital planning, Health Care Management Review 2000 : première application formelle au secteur hospitalier]
- [Rosenhead J. et al. — Robustness and optimality as criteria for strategic decisions, Operational Research Quarterly 1972 : valeur de la flexibilité dans les décisions de planification]
- [DGOS — Plan de gestion des tensions hospitalières et des situations sanitaires exceptionnelles : capacités de réserve et conversions de lits (2021)](https://solidarites-sante.gouv.fr/)
