# Énergie Potentielle de la Liste d'Attente

## Définition

Adapté du concept d'énergie potentielle en physique (E_p = m × g × h — l'énergie accumulée par un objet en hauteur, proportionnelle à sa masse et à sa position), l'énergie potentielle de la liste d'attente (EPLA) mesure le **risque systémique accumulé** dans la liste d'attente d'un service, définie comme la somme des produits (sévérité clinique du patient × durée d'attente écoulée) pour l'ensemble des patients en attente.

EPLA = Σᵢ Sᵢ × Dᵢ

où Sᵢ est le score de sévérité du patient i (proxy calculé depuis le PMSI) et Dᵢ est la durée d'attente en jours depuis la demande de soin. L'analogie physique est directe : comme un objet en hauteur qui accumule de l'énergie potentielle proportionnellement à sa masse et à sa hauteur, un patient sévère qui attend longtemps accumule un "potentiel de décompensation" croissant. Quand ce potentiel est libéré (hospitalisation urgente, complication, décès en attente), il génère une perturbation proportionnelle à l'énergie accumulée.

L'EPLA est fondamentalement différente des indicateurs de liste d'attente habituels (nombre de patients, délai médian) : une liste courte avec des patients très sévères peut être plus dangereuse qu'une liste longue avec des pathologies bénignes. L'EPLA capture cette dimension de **risque pondéré** que les métriques de volume et délai ignorent. Elle identifie également les moments où l'énergie potentielle totale dépasse un seuil critique, déclenchant une réorganisation préventive de la programmation.

## Calcul

Score de sévérité individuel Sᵢ (proxy PMSI) :

```
Sᵢ peut être construit selon trois approches selon les données disponibles :

Approche A — Score de comorbidité PMSI (données historiques du patient) :
  Sᵢ = Indice de Charlson adapté PMSI (calculé sur les 24 mois précédents la demande)
       via les DA/DP des séjours antérieurs MCO du patient (chaînage NIR)
  Plage : 0 (aucune comorbidité) à 30+ (comorbidités multiples sévères)

Approche B — Sévérité estimée par pathologie index (niveau de service) :
  Sᵢ = Poids relatif moyen du GHM le plus fréquent pour l'indication d'attente
       × facteur d'urgence (1.0 = électif, 1.5 = semi-urgent, 2.0 = urgent différé)
  Plage normalisée : 1 à 6

Approche C — Score clinique spécifique (si disponible dans le logiciel de gestion) :
  Sᵢ = Score de priorisation clinique utilisé par le service
       (ex. score NYHA pour cardiologie, score ASA pour chirurgie,
        score de Norton pour gériatrie, stade TNM pour oncologie)
  → À normaliser sur [1 ; 5] pour comparabilité inter-services
```

Calcul de l'EPLA :

```
Durée d'attente Dᵢ (en jours) :
  Dᵢ = Date_calcul − Date_inscription_liste_attente

EPLA brute = Σᵢ (Sᵢ × Dᵢ)
  Unité : "points-jours de risque"

EPLA normalisée par volume de file d'attente :
  EPLA_norm = EPLA / N_patients_en_attente
  → Énergie potentielle moyenne par patient (comparable entre services de tailles différentes)

EPLA par spécialité ou par salle opératoire :
  → Permet de comparer les profils de risque des différentes files d'attente du GHT
```

Seuils et alertes :

```
Seuil d'alerte EPLA :
  → Calculer l'EPLA_ref = percentile 80 de la distribution historique de l'EPLA
    sur les 12-24 mois précédents (approche analogue à la VaR-EIG)
  → Alerte niveau 1 : EPLA > EPLA_ref → révision de la programmation
  → Alerte niveau 2 : EPLA > percentile 95 → réunion de priorisation urgente
  → Alerte niveau 3 : EPLA > max historique → activation du plan de gestion
    des listes d'attente (décision de direction médicale)

Gradient d'EPLA (vitesse d'accumulation du risque) :
  dEPLA/dt = variation hebdomadaire de l'EPLA
  → Positif et croissant : accumulation de risque non maîtrisée
  → Négatif : résorption de la liste d'attente (déprogrammation d'urgences,
    ouverture de créneaux supplémentaires)
```

## Utilité

- **Priorisation des listes d'attente par le risque réel et non par le délai seul** : le premier arrivé n'est pas forcément le plus à risque — l'EPLA individuelle (Sᵢ × Dᵢ) permet de reordonner la liste d'attente en donnant la priorité aux patients qui ont accumulé le plus d'énergie potentielle (les plus sévères ET les plus anciens en attente)
- **Détection précoce des crises de liste d'attente** : l'EPLA totale croissante au-delà des seuils historiques est un signal d'alarme avant que les complications (patients qui se décompensent en attente) n'apparaissent — outil de gestion proactive plutôt que réactive
- **Optimisation de la programmation opératoire** : en chirurgie, la planification des blocs peut intégrer l'EPLA pour alterner des cas lourds (Sᵢ élevé) avec des cas légers plutôt que de traiter dans l'ordre d'inscription — réduction du risque global de la liste sans augmenter le volume opératoire
- **Justification de créneaux supplémentaires** : l'EPLA fournit un argument quantitatif pour demander des vacations opératoires supplémentaires ou des ouvertures de lits en hospitalisation — "notre EPLA a augmenté de 40% ce mois, représentant X patients-jours de risque supplémentaires"
- **Mesure de l'impact des événements perturbateurs** : quantifier l'augmentation d'EPLA générée par une fermeture de bloc (grève, pandémie, travaux) pour objectiver la dette de soins accumulée et planifier le retour à la normale
- **Comparaison inter-services** : l'EPLA normalisée permet de comparer le niveau de risque accumulé entre des services de tailles différentes et de prioriser les ressources supplémentaires vers les files d'attente les plus "chargées" en risque

## Sources de Données

- **Logiciel de gestion des listes d'attente** (Crossway, DxCare, BlueKanGo selon l'établissement) : date d'inscription sur liste, indication, score de priorisation clinique si disponible — source principale pour Dᵢ et éventuellement Sᵢ
- **PMSI MCO RSA** : historique des séjours du patient (24 mois précédents) pour le calcul du score de Charlson adapté (approche A) — via NIR crypté pour les patients déjà hospitalisés dans le GHT
- **DCIR IR_IMB_R** : ALD actives du patient — complément du Charlson pour les comorbidités chroniques ambulatoires non hospitalisées
- **GHM de référence par indication chirurgicale** : poids relatif GHM (ATIH) pour l'approche B — permet une approximation du score de sévérité sans données patient individuelles

## Exemple de Valeurs

- **Service de chirurgie cardiaque (liste d'attente de 45 patients)** :
  - 10 patients sévères (Sᵢ = 4-5) avec Dᵢ moyen = 45j → contribution = 2 025 pts-j
  - 35 patients modérés (Sᵢ = 2) avec Dᵢ moyen = 20j → contribution = 1 400 pts-j
  - EPLA totale = 3 425 pts-j ; EPLA_norm = 76 pts-j/patient
  - Seuil d'alerte (P80 historique) = 3 000 pts-j → EPLA > seuil → alerte niveau 1

- **Gradient hebdomadaire en période de tension** : +300-500 pts-j/semaine si les entrées sur liste dépassent les sorties (opérés) — signal de liste d'attente qui se dégrade

- **Impact d'une fermeture de bloc de 2 semaines** : augmentation d'EPLA estimée à ~1 500-2 000 pts-j selon le profil de sévérité des patients en attente — base pour calculer le nombre de vacations de rattrapage nécessaires

## Limites

- La qualité de l'EPLA dépend entièrement de la fiabilité des données de liste d'attente (dates d'inscription, scores de sévérité) — les logiciels de gestion hospitaliers sont souvent moins bien renseignés que le PMSI, ce qui peut biaiser le calcul
- La normalisation du score de sévérité sur [1;5] est une convention qui peut varier selon les spécialités — deux services utilisant des scorings différents (NYHA cardiologie vs ASA chirurgie) ne peuvent pas être directement comparés sans une étape de normalisation validée
- L'EPLA suppose une relation linéaire entre sévérité, délai et risque de décompensation — or cette relation est souvent non-linéaire (un patient qui attend 90 jours n'a pas nécessairement 3 fois plus de risque qu'un patient qui attend 30 jours ; le risque peut être non-linéaire avec un seuil de décompensation)
- Indicateur partiellement calculable depuis le PMSI seul (approche B pour Sᵢ, Dᵢ non disponible dans le PMSI) — requiert un couplage avec les systèmes de gestion des listes d'attente de l'établissement, qui ne sont pas standardisés ni toujours informatisés

## Références

- [Griffiths J.D. et al. — Modelling waiting times in a hospital emergency department, Health Care Management Science 2010 : modélisation du risque accumulé en liste d'attente]
- [Kreindler S.A. — Lifting the burden of waiting: strategies for reducing patient wait times, Journal of Health Services Research & Policy 2010](https://doi.org/10.1258/jhsrp.2009.009013)
- [Ramsay C.R. et al. — Impact of waiting time targets on waiting times for arthroplasty surgery, JAMA 2004]
- [HAS — Délais de prise en charge et gestion des listes d'attente en chirurgie programmée (2019)](https://www.has-sante.fr/)
- [DGOS — Répertoire opérationnel des ressources et gestion des listes d'attente en établissements de santé](https://solidarites-sante.gouv.fr/)
