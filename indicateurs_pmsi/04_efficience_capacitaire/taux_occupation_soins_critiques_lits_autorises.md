# Taux d'Occupation des Soins Critiques — Lits Autorisés DGOS

## Définition

Les soins critiques hospitaliers comprennent en France trois niveaux réglementaires définis par les décrets DGOS du 9 juin 2022 (n°2022-690 pour la réanimation et n°2022-691 pour les soins intensifs et la surveillance continue) :

| Niveau | Acronyme | Population cible | Ratio réglementaire IDE/lits |
|---|---|---|---|
| Réanimation | REA | Défaillances multiviscérales, état critique | 1 IDE pour 2 lits |
| Soins intensifs | SI | Surveillance rapprochée d'une défaillance d'organe | 1 IDE pour 3 lits |
| Surveillance continue | SC | Post-opératoire immédiat, instabilité modérée | 1 IDE pour 4 lits |

Le taux d'occupation des soins critiques par rapport aux lits **autorisés** (et non aux lits installés ou ouverts) mesure la tension sur la **capacité réglementaire théorique** :

```
Taux_occupation_SC = Σ journées_soins_critiques_PMSI / (nb_lits_SC_autorisés_SAE × 365) × 100
```

Cet indicateur se distingue du `taux_occupation` général (qui porte sur la capacité totale installée, toutes UM confondues) et de l'`indice_saisonnalite_tension_capacitaire` (qui mesure les pics de tension sur l'ensemble de l'établissement) en ciblant spécifiquement la **saturation de la capacité critique autorisée par la DGOS**. La distinction lits autorisés / lits installés / lits ouverts est fondamentale : des lits autorisés non ouverts (faute de personnel) créent un écart entre capacité théorique et capacité réelle — identifiable par un taux d'occupation > 90% des lits autorisés alors que des lits autorisés restent fermés.

## Calcul

Sources : PMSI MCO RSA + SAE DREES (lits autorisés) + décrets soins critiques DGOS 2022.

```
Population : tous séjours MCO comportant au moins une journée en unité de soins critiques

Étape 1 — Identification des journées de soins critiques dans le PMSI :
  Source principale : fichier RSS (Résumés de Sortie Standardisés) — pour les séjours multi-RUM
  Le RSA MCO est mono-RUM ; pour les séjours avec passage en soins critiques,
  le RSS est la source des RUM (Résumés d'Unité Médicale) constitutifs

  Identification des RUM de soins critiques :
    Méthode A (préférentielle) : TYPE_UM du RUM ∈ {REA, USI, SI, SC, USIC, USINEOS}
      → liste des codes TYPE_UM soins critiques selon nomenclature ATIH
    Méthode B (alternative) : UM référencée dans le fichier de structure FCS (Fichier Commun
      de Structure) comme unité de soins critiques (catégorie = réanimation, SI ou SC)

  Journées en soins critiques :
    Journées_RUM_SC = DATE_FIN_RUM − DATE_DEBUT_RUM + 1   pour chaque RUM de type SC
    Journées_SC_RSA = Σ Journées_RUM_SC sur les RUM de type SC du séjour

  Journées_SC_totales = Σ Journées_SC_RSA sur tous les séjours du FINESS/période

  Alternative simplifiée (si RSS non disponible) :
    Utiliser les séjours dont le GHM principal relève de la réanimation
    (CMD 28 réa ou CMC soins continus selon grille GHM) + ajuster par les journées REA
    → moins précis car un séjour de réa peut être groupé dans un GHM non-réa

Étape 2 — Lits autorisés soins critiques depuis la SAE :
  Source : questionnaire SAE, volet soins critiques (depuis 2023, volet rénové post-décrets 2022)
  Variables SAE :
    LIT_AUTO_REA = nb de lits autorisés en réanimation (adulte + pédiatrique)
    LIT_AUTO_SI  = nb de lits autorisés en soins intensifs (toutes spécialités)
    LIT_AUTO_SC  = nb de lits autorisés en surveillance continue
    LIT_AUTO_SC_TOT = LIT_AUTO_REA + LIT_AUTO_SI + LIT_AUTO_SC   [total soins critiques]

  Note : les lits autorisés sont les lits reconnus par l'ARS dans l'autorisation d'activité
    ≠ lits installés (capacité physique des locaux)
    ≠ lits ouverts (capacité effective compte tenu du personnel disponible)

Étape 3 — Calcul du taux d'occupation :
  Capacité_théorique_annuelle = LIT_AUTO_SC_TOT × 365   [journées-lits théoriques]

  Taux_occupation_SC = Journées_SC_totales / Capacité_théorique_annuelle × 100   [en %]

  Taux par niveau :
  Taux_occupation_REA = Journées_REA / (LIT_AUTO_REA × 365) × 100
  Taux_occupation_SI  = Journées_SI  / (LIT_AUTO_SI  × 365) × 100
  Taux_occupation_SC  = Journées_SC  / (LIT_AUTO_SC  × 365) × 100

  Interprétation des seuils :
    < 70% : sous-utilisation — capacité autorisée non exploitée (peut signifier des lits fermés)
    70–85% : utilisation optimale — capacité bien calibrée
    85–95% : tension — risque de saturation lors des pics
    > 95%  : saturation structurelle — demande d'extension de capacité ou de révision
             de l'autorisation justifiée

Étape 4 — Écart lits autorisés / lits ouverts (si données disponibles) :
  LIT_OUVERT_SC = lits effectivement ouverts en moyenne sur la période (SAE ou suivi interne)
  Taux_fermeture = (LIT_AUTO_SC_TOT − LIT_OUVERT_SC) / LIT_AUTO_SC_TOT × 100
  → Si Taux_occupation_SC > 85% ET Taux_fermeture > 10% :
    saturation organisationnelle (capacité autorisée non ouverte par manque de personnel)
    ≠ saturation structurelle (capacité autorisée insuffisante)

Cas limites :
  - RSS non disponible (établissement mono-RUM) : utiliser la méthode B (GHMs soins critiques)
    et documenter la limitation de précision
  - SAE non disponible en cours d'année : utiliser LIT_AUTO de la SAE N-1
  - Lits autorisés à 0 (établissement sans activité soins critiques réglementaires) :
    Taux = NA — pas de calcul
```

Indicateurs dérivés :

```
Ratio journées SC / journées totales MCO :
  = Journées_SC_totales / Journées_MCO_totales × 100   [% de l'activité MCO en soins critiques]
  → proxy de l'intensité des soins dans l'établissement

Taux d'occupation SC en période de pic (décembre–mars) :
  = Journées_SC_trim_hiver / (LIT_AUTO_SC_TOT × 91) × 100
  → mesure la tension saisonnière spécifique aux soins critiques

Tension quotidienne estimée :
  = Journées_SC_mois_max / (LIT_AUTO_SC_TOT × nb_jours_mois_max) × 100
  → taux d'occupation mensuel maximal — signal de saturation ponctuelle
```

## Utilité

- **Argument pour une demande d'extension d'autorisation auprès de l'ARS** : un Taux_occupation_SC > 90% sur trois années consécutives, documenté sur données PMSI/SAE officielles, est la pièce maîtresse d'un dossier de demande d'augmentation de lits autorisés de soins critiques — objectivant la saturation structurelle indépendamment des arguments qualitatifs
- **Distinction saturation structurelle vs organisationnelle** : si le Taux_occupation_SC > 90% est associé à un Taux_fermeture > 15% (lits autorisés non ouverts), le problème est d'abord un déficit de personnel soignant (IDE/AS), non un manque de lits autorisés — la réponse est un plan de recrutement, pas une demande d'autorisation supplémentaire
- **Planification des soins critiques au niveau GHT** : comparer les taux d'occupation REA/SI/SC entre établissements du GHT pour identifier les structures chroniquement saturées vs sous-utilisées — une convention de transfert planifiée entre un établissement à Taux_REA = 95% et un autre à 65% est à la fois médicalement justifiable et organisationnellement faisable
- **Conformité aux décrets DGOS 2022** : les décrets soins critiques fixent des conditions de fonctionnement (ratios infirmiers, équipements) — un Taux_occupation_REA > 100% (journées > lits autorisés × 365) signale une non-conformité structurelle réglementaire à notifier à l'ARS
- **Impact des restructurations sur la capacité critique** : mesurer le Taux_occupation avant et après une fusion de services, une réorganisation des soins critiques ou une fermeture d'un bloc opératoire pour vérifier que la restructuration n'a pas créé une saturation des soins critiques non anticipée
- **Calibration des plans de débordement ORSAN** : le Taux_occupation_SC historique en période de pic (hiver) est la donnée de référence pour calibrer les plans ORSAN (Organisation de la Réponse du Système de Soins) de l'établissement — combien de lits supplémentaires peuvent être ouverts en dépassant la capacité normale, et à partir de quel taux de base le plan doit être déclenché

## Sources de Données

- **PMSI MCO RSS** : fichier RSS (Résumés de Sortie Standardisés) — variable `TYPE_UM` du RUM, `DATE_DEBUT_RUM`, `DATE_FIN_RUM`, `NOFINESS` — permet d'identifier les journées passées en unités de soins critiques au sein de séjours multi-RUM
- **PMSI MCO RSA** : en l'absence de RSS, variable `GHM` (pour filtrer les GHMs de réanimation/soins continus), `DUREE`, `NOFINESS`
- **SAE DREES** : questionnaire annuel, volet soins critiques — variables `LIT_AUTO_REA`, `LIT_AUTO_SI`, `LIT_AUTO_SC` par FINESS géographique — accessible via l'espace SAE DREES ou le bilan d'activité validé par la direction
- **Fichier Commun de Structure (FCS)** : transmis à l'ATIH avec le PMSI — contient la liste des UM avec leur type (REA / USI / SI / SC) — permet de cartographier les unités de soins critiques de l'établissement

## Exemple de Valeurs

- **Réanimation CHU polyvalent (30 lits autorisés)** : Taux_occupation_REA = 82–92% (utilisation optimale à tension); pic décembre–mars : 94–102%
- **Soins intensifs coronariens (USIC, 12 lits)** : Taux_occupation_SI = 78–88%
- **Surveillance continue post-opératoire (20 lits)** : Taux_occupation_SC = 70–82% (moins tendu — usage plus programmable)
- **Taux_occupation_SC_TOT typique — CH 400 lits** : 74–85%
- **Seuil d'alerte saturation** : Taux_occupation_REA > 92% sur 3 trimestres consécutifs → dossier ARS pour révision d'autorisation
- **Signal de sous-utilisation** : Taux_occupation_SC < 65% sur toutes les UM de soins critiques → investiguer le nombre de lits effectivement ouverts vs autorisés (personnel disponible)

## Limites

- **RSS non disponible dans tous les établissements** : tous les établissements n'ont pas de séjours multi-RUM ou ne transmettent pas systématiquement le RSS à l'ATIH — l'estimation des journées SC depuis le RSA seul (méthode B) est moins précise et sous-estime les séjours complexes avec passage en réanimation
- **SAE annuelle** : les lits autorisés SAE ne sont disponibles qu'une fois par an — les révisions d'autorisation en cours d'année ne sont pas capturées ; utiliser les données de l'autorisation ARS en cas de modification infra-annuelle
- **Définition des TYPE_UM** : le codage du type d'unité médicale dans le FCS et le RSS n'est pas uniformément renseigné dans tous les établissements (certains codent REA, d'autres REAP, REAPED...) — une harmonisation des codes TYPE_UM est nécessaire avant le calcul
- **Lits autorisés ≠ lits ouverts** : le taux d'occupation calculé sur les lits autorisés peut dépasser 100% si certains lits autorisés sont fermés — ce dépassement est un signal important mais ne signifie pas que l'établissement fonctionne en dehors de sa capacité physique réelle
- **Réorganisations structurelles** : les fusions de services de soins critiques (ex : création d'une USC polyvalente regroupant SC et SI) peuvent brouiller la ventilation REA/SI/SC dans la SAE et le RSS sur les années de transition

## Références

- [Décret n°2022-690 du 26 avril 2022 relatif aux conditions techniques de fonctionnement applicables à l'activité de soins de réanimation (DGOS)](https://www.legifrance.gouv.fr/)
- [Décret n°2022-691 du 26 avril 2022 relatif aux conditions techniques de fonctionnement applicables aux activités de soins intensifs et de surveillance continue (DGOS)](https://www.legifrance.gouv.fr/)
- [DREES — Statistique Annuelle des Établissements de santé (SAE) : volet soins critiques, lits autorisés et installés](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH — Guide de production PMSI MCO, RSS et types d'unités médicales](https://www.atih.sante.fr/)
- [Rhodes A. et al. — Variability between countries in the definition and availability of ICU beds, Intensive Care Medicine 2012 : méthodologie internationale de mesure de la capacité de soins critiques](https://doi.org/10.1007/s00134-012-2627-8)
