# Taux de Séjours en Soins Palliatifs (Z51.5)

## Définition
Le **taux de séjours en soins palliatifs** mesure la part des séjours MCO comportant un **codage de soins palliatifs**, identifié principalement par le code CIM-10 **Z51.5** (« Soins palliatifs ») en diagnostic principal (DP), associé (DA) ou relié (DR), ou par appartenance au GHM **23M02** (« Soins palliatifs avec ou sans acte »). Le PMSI distingue trois niveaux de structuration de ces soins :

- **Niveau SP1** : soins palliatifs en lit identifié de soins palliatifs (LISP).
- **Niveau SP2** : soins palliatifs en unité de soins palliatifs (USP).
- **Niveau SP3** : soins palliatifs hors structure dédiée (lit ordinaire avec compétence palliative).

Cet indicateur est documenté par la DREES (Panorama des établissements de santé) et l'ATIH dans le cadre du suivi du **Plan national de développement des soins palliatifs**, et constitue un marqueur du **maillage de l'offre palliative GHT**.

Formule :

```
Taux SP = (séjours MCO avec Z51.5 en DP/DR/DA OU GHM 23M02) / (séjours MCO total)

Décomposition par niveau :
  Part_SP1 = séjours SP en LISP / séjours SP total
  Part_SP2 = séjours SP en USP / séjours SP total
  Part_SP3 = séjours SP hors structure / séjours SP total
```

Positionnement vs indicateurs existants : différent du taux de mortalité et du taux d'hospitalisations en fin de vie. Capture spécifiquement les séjours formellement identifiés comme palliatifs, marqueur de la **reconnaissance institutionnelle de la phase palliative** dans le parcours.

## Calcul

```
Étape 1 — Identification des séjours palliatifs
  RSA avec ≥1 critère :
    a) DP = Z51.5 (soins palliatifs en pathologie principale)
    b) DR = Z51.5 (relié à la pathologie principale)
    c) DA = Z51.5 (palliatif associé à la PEC)
    d) GHM = 23M02Z (soins palliatifs avec ou sans acte)

Étape 2 — Identification du niveau SP (LISP / USP / autre)
  Variables PMSI :
    - Type d'autorisation de l'UM (UM avec autorisation USP : code spécifique)
    - Présence de LISP : signalée par UM avec code « lit identifié SP »
  Calcul :
    SP2 = séjours dans UM USP autorisée
    SP1 = séjours dans UM avec LISP, hors USP
    SP3 = séjours SP avec Z51.5 hors UM USP/LISP

Étape 3 — Population de référence
  Dénominateur : ensemble des RSA MCO de l'année (hors séances CMD 28)
  Variantes :
    - Taux global : SP / total RSA
    - Taux décès : SP / RSA avec mode de sortie = 9 (décès)
    - Taux ≥75 ans : SP_age / RSA_age (intensité palliative chez personnes âgées)

Étape 4 — Indicateurs de qualité du parcours
  - Délai admission palliative → décès (idéalement > 7 jours)
  - Part des décès en USP/LISP / décès hospitaliers totaux
  - Part des séjours SP3 (hors structure) / total SP — marqueur du sous-équipement
```

Variables PMSI clés : `DP`, `DR`, `DA`, `GHM`, `MODE_SORTIE`, `UM` (unité médicale), table d'autorisations UM (USP/LISP), `age`.

## Utilité
- **Pilotage GHT du Plan soins palliatifs** : suivi de la cible nationale de développement des LISP et USP (au moins 1 USP / 200 000 hab. visée).
- **Diagnostic du maillage territorial** : identification des établissements sans LISP autorisé alors qu'ils accueillent des séjours SP3.
- **Justification de demandes d'autorisation** : argumentation auprès de l'ARS pour création/extension de LISP ou USP.
- **Qualité de fin de vie** : un taux SP très bas chez les patients décédés signe une absence de prise en charge palliative formalisée.
- **Valorisation tarifaire** : le GHM 23M02 et les suppléments SP1/SP2 augmentent significativement la valorisation T2A → impact financier direct.
- **Suivi temporel** : courbe de progression depuis l'introduction des LISP (2008) et l'extension des USP.
- **Comparaison inter-établissement** : positionnement vs CHU et CH de référence sur l'engagement palliatif.

## Sources de Données
- **PMSI MCO** : RSA, DP/DR/DA, GHM, autorisations UM (LISP/USP).
- **Référentiel CIM-10 FR** : code Z51.5.
- **Référentiel ATIH GHM** : groupe 23M02, suppléments tarifaires SP1/SP2.
- **DREES Panorama** : suivi national de l'activité palliative.
- **ARS — autorisations USP/LISP** : référentiel des structures palliatives par établissement.
- **Plan national soins palliatifs (PNSP)** : cibles nationales de développement.

## Exemple de Valeurs
*Sources : DREES Panorama Établissements de santé 2024-2025, ATIH ScanSanté, Plan national soins palliatifs.*

- **Taux SP global France MCO** : ~3-4 % des séjours MCO ont un codage palliatif.
- **Part SP1 (LISP)** : ~50-55 % des séjours SP.
- **Part SP2 (USP)** : ~15-20 % des séjours SP.
- **Part SP3 (hors structure)** : ~25-30 % — marqueur du sous-équipement structurel.
- **Décès hospitaliers en SP** : ~50 % des décès MCO sont précédés d'un codage SP.
- **CHU** : 5-7 % des séjours MCO en SP (concentration des USP).
- **CH périphériques** : 2-4 % en SP (souvent SP1 ou SP3 dominant).
- **Cliniques privées** : variable, 1-3 % (faible présence USP historique).
- **Cible PNSP** : couverture > 95 % des décès attendus par filière palliative formalisée.

## Limites
- **Variabilité du codage** : le Z51.5 est connu pour être inégalement codé (sous-codage en CH, sur-codage suspecté en SP1 lié à la valorisation tarifaire).
- **Effet « course aux LISP »** : risque d'inflation artificielle du codage SP1 sans modification de la pratique réelle.
- **Distinction SP1/SP2/SP3 imparfaite** : dépend de la qualité du référentiel d'autorisations UM, parfois mal renseigné dans le PMSI.
- **Pas de validation clinique** : Z51.5 ne garantit pas que la prise en charge respecte les standards palliatifs (médecin formé, projet personnalisé, anticipation).
- **Couverture restreinte** : ne capture pas les patients en soins palliatifs **à domicile** (HAD, équipes mobiles ville) ni les **soins palliatifs précoces** non encore formalisés.
- **Effet GHT vs établissement isolé** : un GHT avec 1 USP centrale a un taux global concentré sur 1 finess, masquant le sous-équipement périphérique.
- **Évolutions réglementaires** : critères d'autorisation USP/LISP régulièrement révisés, comparaisons longitudinales à interpréter avec prudence.

## Références
- [DREES — Panorama Établissements de santé édition 2025](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- [DREES — Panorama Établissements de santé édition 2024](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/panoramas-de-la-drees/240718_Panorama_EtablissementsSante2024)
- [ATIH — Guide méthodologique PMSI MCO et nomenclature des UM/USP-LISP](https://www.atih.sante.fr/)
- Plan national de développement des soins palliatifs et d'accompagnement de la fin de vie (Ministère de la Santé).
- Société française d'accompagnement et de soins palliatifs (SFAP) — référentiel de bonnes pratiques.
