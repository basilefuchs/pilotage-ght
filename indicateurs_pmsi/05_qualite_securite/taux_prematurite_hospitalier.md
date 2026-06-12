# Taux de Prématurité Hospitalier (Tableau de Bord Périnatal DREES)

## Définition

Le taux de prématurité hospitalier est la proportion de naissances vivantes prématurées (terme gestationnel inférieur à 37 semaines d'aménorrhée) parmi l'ensemble des naissances vivantes enregistrées dans les séjours MCO d'une maternité sur une période donnée. Il constitue l'un des indicateurs du tableau de bord de la périnatalité de la DREES et un marqueur de résultat de la prise en charge obstétrico-pédiatrique.

TP = (naissances vivantes < 37 SA) / (naissances vivantes totales) × 100

Trois seuils de sévérité sont distingués, conformément à la classification internationale (OMS/DREES) :

| Catégorie | Terme | Code PMSI principal |
|-----------|-------|---------------------|
| Prématurité extrême | < 28 SA | P07.2x |
| Grande prématurité | 28–31 SA | P07.3x (sous-catégories) |
| Prématurité modérée/tardive | 32–36 SA | P07.3x + contexte O60.1 |

Cet indicateur se distingue du **taux de faible poids de naissance** (basé sur le poids en grammes, P07.0/P07.1), qui lui est corrélé mais non superposable : un nouveau-né peut être hypotrophe à terme ou eutrophe mais prématuré. Le taux de prématurité mesure spécifiquement la maturité organique à la naissance, prédictrice des complications néonatales (détresse respiratoire, hémorragie intraventriculaire, entérocolite nécrosante).

## Calcul

Source : PMSI MCO RSA — séjours du nouveau-né (type de séjour = NN) et séjours maternels (DP Z37.x ou O60.x).

```
Étape 1 — Identification des naissances vivantes dans le PMSI
  Méthode A (séjour nouveau-né) — recommandée :
    RSA avec type_sejour = 'NNE' (nouveau-né entrant)
    DP ∈ Z38.x (nouveau-né en bonne santé) ou P07.x (prématurité/faible poids)
    Exclure : mort-nés (P95, Z37.1, Z37.3, Z37.5, Z37.7)

  Méthode B (séjour maternel) — alternative si séjours NN non chaînables :
    DP ∈ {O80, O81, O82, O83, O84} avec DA Z37.0 (naissance vivante unique) ou Z37.2, Z37.4, Z37.6
    Déduire le terme du DA O60.1x (travail prématuré) ou P07.x du nouveau-né chaîné

Étape 2 — Identification des naissances prématurées
  Critère 1 (direct — code prématurité sur RSA nouveau-né) :
    P07.20 (< 24 SA), P07.21 (24-26 SA), P07.22 (27-28 SA) — extrême prématurité
    P07.30 (29-30 SA), P07.31 (31-32 SA), P07.32 (33-34 SA), P07.33 (35-36 SA) — grande et modérée

  Critère 2 (indirect — via séjour maternel) :
    DP ou DA O60.1x (travail prématuré avec accouchement) sur le RSA de la mère
    Chaîner avec RSA nouveau-né correspondant (même `date_entree` ± 1 jour, même FINESS)

  Critère 3 (faible poids comme proxy) :
    P07.0x (< 1000g — extrême prématurité probable) et P07.1x (1000–2499g)
    Utiliser uniquement si critères 1 et 2 sont insuffisamment renseignés

Étape 3 — Calcul du taux de prématurité
  TP_total = nb_naissances_prématurées / nb_naissances_vivantes × 100
  TP_extrême = naissances < 28 SA / total × 100
  TP_grande = naissances 28-31 SA / total × 100
  TP_modérée = naissances 32-36 SA / total × 100

Étape 4 — Comparaison au taux national
  Ratio observé/attendu (ROA) = TP_établissement / TP_national_référence
  Taux national de référence DREES (ENP 2021) : ≈ 7,2 % (toutes prématurités)
  Intervalle de confiance 95% (méthode exacte de Clopper-Pearson pour les petits effectifs)
```

Indicateurs dérivés :

```
Taux de transfert en réanimation néonatale pour prématurité :
  T_transfert_NN = transferts vers réa néonatale (prématurés) / total prématurés
  → Mesure la disponibilité des places de réanimation néonatale locale

Taux de corticothérapie anténatale documentée :
  rate(DA O26.7 ou acte CCAM corticoïde / RSA maternel avec travail prématuré)
  → Indicateur IPAQSS périnatalité HAS (corticothérapie anténatale)
```

## Utilité

- **Surveiller la qualité des soins obstétricaux et néonataux** : une hausse du taux de prématurité, particulièrement de la prématurité extrême (< 28 SA), peut signaler une modification du casemix ou un problème de prise en charge prénatale (suivi insuffisant des grossesses à risque) — information utile pour le réseau périnatal de la région.
- **Évaluer l'adéquation du niveau de la maternité** : les maternités de niveau 1 (sans unité de soins intensifs néonataux) ne devraient pas prendre en charge les grands prématurés (< 32 SA) ; un taux de grande prématurité > 1% dans une maternité de niveau 1 signale un problème d'orientation anténatale ou de transfert in utero.
- **Alimenter le tableau de bord périnatal régional** : les Réseaux de Santé en Périnatalité (RSP) utilisent le taux de prématurité pour le suivi des indicateurs régionaux et la coordination avec les maternités de niveau 2 et 3 du GHT.
- **Planifier les ressources en réanimation néonatale** : la fréquence des grandes prématurités (< 32 SA) détermine directement les besoins en lits de réanimation néonatale et de soins intensifs pédiatriques — données nécessaires pour les projets de service et les CPOM.
- **Suivi dans le temps pour détecter des clusters** : une augmentation brutale du taux de prématurité sur 1–2 trimestres peut signaler une épidémie infectieuse materno-fœtale (chorioamniotite, listériose) ou une modification de pratique (seuil de déclenchement) nécessitant une investigation immédiate.

## Sources de Données

- **PMSI MCO RSA** : type de séjour (NNE), codes CIM-10 nouveau-né (P07.x, Z38.x, P95) et maternel (O60.x, Z37.x), FINESS, dates d'entrée pour chaînage mère-enfant
- **DREES — Enquête Nationale Périnatale (ENP 2021)** : taux nationaux de référence par catégorie de prématurité et par niveau de maternité
- **HAS — Indicateurs IPAQSS périnatalité** : définitions et méthodes de calcul complémentaires (corticothérapie anténatale, transferts in utero)
- **Réseau EPICE / EPIPAGE-2** : taux de référence pour la grande prématurité (< 32 SA) avec données épidémiologiques de cohorte française (Ancel P.Y. et al.)

## Exemple de Valeurs

- **Taux de prématurité global (France 2021, DREES ENP)** : 7,2% (dont 5,8% modérée/tardive)
- **Grande prématurité (< 32 SA)** : ≈ 1,0–1,2% des naissances
- **Prématurité extrême (< 28 SA)** : ≈ 0,3–0,5% des naissances
- **Maternité de niveau 1** : TP attendu ≈ 4–6% (sélection a priori des grossesses à faible risque)
- **Maternité de niveau 3 (CHU)** : TP observé ≈ 10–15% (concentration des grossesses à haut risque par transferts in utero)
- **Seuil d'alerte (grande prématurité en maternité de niveau 1)** : > 0,5% (dépassement du taux attendu pour ce niveau)
- **Seuil minimal pour calcul fiable** : ≥ 500 naissances/an (pour la prématurité totale) ; ≥ 2 000 naissances/an pour une estimation stable de la grande prématurité

## Limites

- **Sous-codage du terme gestationnel** : le terme gestationnel en semaines d'aménorrhée n'est pas un champ structuré du PMSI MCO ; son estimation à partir des codes P07.x (qui codent principalement le poids de naissance en complément du terme) est imprécise. La concordance entre le terme PMSI reconstruit et le terme échographique réel est imparfaite, surtout dans la gamme 33–36 SA (prématurité tardive).
- **Chaînage mère-enfant non systématique** : le chaînage entre le RSA de la mère et celui du nouveau-né repose sur des algorithmes approchés (date, FINESS, numéro de séjour) ; les maternités multi-sites ou les transferts en urgence du nouveau-né peuvent conduire à des séjours non chaînés et à une sous-estimation.
- **Hétérogénéité de prise en charge** : les taux de prématurité sont fortement influencés par les politiques locales de prise en charge des grossesses à risque (accueil ou transfert in utero des grandes prématurités) — un taux élevé en maternité de niveau 3 peut refléter une excellente coordination de réseau plutôt qu'un problème de qualité.
- **Exclusion des mort-nés** : la définition inclut les naissances vivantes uniquement (Z38.x, P07.x sans P95) ; les prématurés nés sans vie ne sont pas comptabilisés, alors qu'ils constituent une part importante de la morbi-mortalité périnatale.

## Références

- [DREES — Enquête Nationale Périnatale 2021 — Rapport complet](https://www.santepubliquefrance.fr/etudes-et-enquetes/enquete-nationale-perinatale-2021)
- [Ancel P.Y. et al. — EPIPAGE-2: a preterm birth cohort in France in 2011, BMC Pediatrics 2014](https://doi.org/10.1186/1471-2431-14-97)
- [OMS — Born too soon: the global action report on preterm birth, 2012](https://www.who.int/publications/i/item/9789241503433)
- [HAS — Indicateurs IPAQSS Périnatalité — Corticothérapie anténatale, 2020](https://www.has-sante.fr/)
- [ATIH — Guide méthodologique de production des données du PMSI MCO — Périnatalité (version en vigueur)](https://www.atih.sante.fr/)
- [Blondel B. et al. — Trends in perinatal health in France from 1995 to 2010, Journal of Gynecology Obstetrics and Human Reproduction 2012](https://doi.org/10.1016/j.jgyn.2012.09.005)
