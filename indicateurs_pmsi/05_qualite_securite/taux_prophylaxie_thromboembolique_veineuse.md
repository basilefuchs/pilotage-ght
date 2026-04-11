# Taux de Prophylaxie Thromboembolique Veineuse en Chirurgie

## Définition

Cet indicateur mesure la proportion de patients hospitalisés pour chirurgie à risque thromboembolique modéré ou élevé ayant reçu une thromboprophylaxie appropriée — pharmacologique (HBPM, fondaparinux, ou anticoagulants oraux directs en indication PTH/PTG) et/ou mécanique (compression veineuse intermittente, bas de compression) — pendant leur séjour, conformément aux recommandations HAS (2011, actualisées en 2023). Il est calculé par croisement des actes chirurgicaux CCAM du PMSI MCO avec les dispensations pharmaceutiques du DCIR (codes CIP13 HBPM/fondaparinux) et/ou les actes PMSI de prophylaxie mécanique. La maladie thromboembolique veineuse (thrombose veineuse profonde, embolie pulmonaire) est l'une des complications hospitalières les plus évitables : 30 à 50 % des épisodes de TVP/EP survenant en établissement concernent des patients n'ayant pas reçu de prophylaxie conforme aux recommandations. Le PSI-90 composite inclut le TEV post-opératoire comme indicateur de résultat (outcome) ; cet indicateur le complète en mesurant l'acte préventif lui-même (process). La distinction est cliniquement fondamentale : un taux de prophylaxie élevé associé à un taux de TEV persistant oriente vers un échec de prophylaxie (molécule, durée inadaptée), tandis qu'un taux de prophylaxie bas oriente vers une omission de prescription, relevant d'une action corrective différente.

## Calcul

La population cible et les modalités de croisement des sources sont les suivantes :

```
Population cible :
  → Patients hospitalisés pour chirurgie élective ou urgente
  → PMSI RSA : CCAM chirurgical dans le séjour (actes familles 01-17)
  → Durée de séjour ≥ 2 jours (les chirurgies ambulatoires < 12h sont exclues
    car le risque TEV post-opératoire survient majoritairement après la sortie)
  → Stratification par risque TEV (score de Caprini adapté au PMSI) :
      Risque modéré : chirurgie générale, gynécologie, urologie ≥ 45 min
      Risque élevé  : prothèse totale hanche/genou (PTH/PTG), chirurgie du cancer,
                      polytraumatisme, chirurgie rachidienne majeure

Prophylaxie pharmacologique (DCIR ER_PHA_F) :
  → HBPM (héparines bas poids moléculaire) : ATC B01AB (énoxaparine, daltéparine, tinzaparine)
    codes CIP13 correspondants selon BDPM
  → Fondaparinux : ATC B01AX05
  → AOD en indication prophylaxie PTH/PTG : rivaroxaban (B01AF01 10mg), apixaban (B01AF02 2.5mg)

Prophylaxie mécanique (PMSI actes CCAM) :
  → YYYY001 : pose de bas de compression veineuse
  → Compression pneumatique intermittente (tracée en actes infirmiers NGAP si disponible)
```

Formule du taux de prophylaxie pharmacologique :

```
Taux de prophylaxie pharmacologique (%) :
  = (Patients chirurgie risque modéré/élevé ayant reçu ≥1 dispensation HBPM/fondaparinux/AOD
     dans les 48h post-opératoires / Total patients chirurgie risque modéré/élevé) × 100
```

Calcul de la conformité en durée (PMSI + DCIR) :

```
Taux de prophylaxie appropriée (PMSI + DCIR) :
  → Durée de prophylaxie conforme aux recommandations :
      Chirurgie générale : 7-14 jours
      PTH/PTG : 35 jours (recommandation HAS)
      Chirurgie cancer abdominopelvien : 28 jours
  → Indicateur de durée : proportion de patients avec prophylaxie ≥ durée recommandée
```

Sous-indicateurs calculables :

```
Sous-indicateurs :
  → Taux par spécialité chirurgicale (orthopédie, digestif, urologie, gynécologie)
  → Taux de prophylaxie ambulatoire (post-sortie) : dispensations DCIR après DATESOR
  → Corrélation avec taux TEV post-op (PSI-90) : calcul de l'efficacité de la prophylaxie
```

## Utilité

- **Indicateur de processus complémentaire au PSI-90** : le PSI-90 détecte les VTE post-opératoires (outcome), ce taux mesure si la prophylaxie a été prescrite et dispensée (process) — ensemble, ils permettent de distinguer entre non-prophylaxie (action corrective : protocole de prescription) et échec de prophylaxie (action corrective : type de molécule ou durée)
- **Détection des patients sortis sans prophylaxie ambulatoire** : le croisement PMSI (date sortie) × DCIR (dispensations HBPM post-sortie) identifie les patients qui n'ont pas retiré leur HBPM à la pharmacie de ville dans les 7 jours post-sortie — signal d'alerte pour la coordination pharmacien-chirurgien
- **Benchmark inter-services et inter-établissements** : comparer les taux de prophylaxie par spécialité chirurgicale entre les établissements membres du GHT pour identifier les services avec des pratiques sous-optimales et cibler les actions de formation
- **Évaluation des protocoles de thromboprophylaxie** : mesurer l'évolution du taux avant/après l'introduction d'un protocole de prescription systématique (CPOE avec alerte automatique) ou d'un changement de molécule de référence
- **Réduction du risque de contentieux médicaux** : la non-prescription de prophylaxie TEV est l'une des premières causes de mise en cause des établissements de santé pour complication post-opératoire — l'indicateur documente la conformité aux recommandations HAS
- **Dialogue CAQES et certification HAS** : la prophylaxie TEV est un critère de certification HAS (critère 8.8) et peut être incluse dans les CAQES — les données PMSI/DCIR permettent une auto-évaluation continue entre deux visites de certification

## Sources de Données

- **DCIR ER_PHA_F** : dispensations pharmaceutiques en pharmacie de ville — contient les codes CIP13 des HBPM, fondaparinux et AOD en prophylaxie, les dates de dispensation, et le NIR crypté permettant le chaînage avec le PMSI
- **PMSI MCO RSA** : actes CCAM chirurgicaux (familles 01-17), date d'opération, durée de séjour, date de sortie (DATESOR) — base de constitution de la population cible
- **BDPM ANSM** : base de données publique des médicaments — correspondance CIP13 → DCI → code ATC, indispensable pour identifier exhaustivement les spécialités HBPM/fondaparinux/AOD
- **HAS recommandations prophylaxie TEV 2011/2023** : définition des seuils de risque (modéré/élevé) et des durées de prophylaxie recommandées par type de chirurgie — référentiel pour le calcul de la conformité
- **NIR crypté SNDS** : identifiant bénéficiaire pseudonymisé permettant le chaînage longitudinal PMSI (séjour hospitalier) × DCIR (dispensations ville pré- et post-hospitalisation)

## Exemple de Valeurs

- **Conformité nationale à la prophylaxie pharmacologique en chirurgie à haut risque (France, audit HAS 2019)** : environ 75-80 % — marge d'amélioration significative identifiée
- **Prophylaxie complète PTH/PTG sur 35 jours** : seulement 50-60 % des patients complètent la durée recommandée dans les études françaises
- **Dispensation post-sortie dans les 7 jours** : 65-75 % des patients récupèrent leur HBPM en pharmacie de ville dans la semaine suivant la sortie
- **Allaudeen 2024 (Veterans Affairs)** : réduction de 85,2 % des événements TEV PSI-90 après amélioration du taux de prophylaxie pharmacologique (p=0,0091)
- **TEV attribuables à l'absence de prophylaxie** : environ 30-50 % des TVP/EP post-opératoires sont évitables par une prophylaxie conforme aux recommandations
- **Fondaparinux vs HBPM en chirurgie de hanche** : efficacité équivalente sur la prévention du TEV ; fondaparinux associé à un risque hémorragique légèrement supérieur

## Limites

- Le DCIR trace les dispensations en pharmacie de ville — les HBPM dispensées directement par la pharmacie hospitalière à usage intérieur (PUI) lors du séjour ou à la sortie ne figurent PAS dans le DCIR, entraînant une sous-estimation structurelle du taux de prophylaxie intra-hospitalière
- La dispensation à la sortie (pharmacie de ville) est traçable en DCIR mais ne garantit pas l'administration réelle par le patient — un patient qui retire son HBPM mais ne se l'injecte pas sera compté comme "prophylaxé"
- Le score de risque Caprini ne peut pas être calculé précisément depuis le PMSI seul (il intègre des facteurs cliniques — IMC, varices, antécédents — partiellement codés en CIM-10) ; une version simplifiée basée sur le type de chirurgie est utilisée comme proxy
- La prophylaxie mécanique (bas de compression, compression pneumatique) est peu ou pas codée dans le PMSI actuel — le taux calculé porte essentiellement sur la prophylaxie pharmacologique
- Les actes CCAM de chirurgie peuvent être enregistrés le lendemain de l'opération en PMSI — le calcul du délai entre opération et première dispensation HBPM peut comporter une imprécision de ±24h

## Références

- [Allaudeen N. et al. — Patient Safety Indicators at an Academic Veterans Affairs Hospital: Addressing Dual Goals of Clinical Care and Validity, Jt Comm J Qual Patient Saf 2024](https://doi.org/10.1016/j.jcjq.2024.04.010)
- [HAS — Prévention et traitement de la maladie thromboembolique veineuse en médecine (recommandations 2023)](https://www.has-sante.fr/)
- [SFAR — Recommandations sur la prophylaxie de la maladie thromboembolique périopératoire](https://www.sfar.org/)
- [SNDS — DCIR ER_PHA_F : dispensations HBPM et fondaparinux](https://www.snds.gouv.fr/)
- [ANSM — BDPM : base de données publique des médicaments](https://base-donnees-publique.medicaments.gouv.fr/)
