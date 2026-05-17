# Part des passages aux urgences CCMU 1-2 sans hospitalisation

## Définition

La **part des passages aux urgences classés CCMU 1 ou 2 repartant sans hospitalisation** mesure la fraction des passages dans les services d'urgences d'un territoire qui correspondent à des **états cliniques jugés stables**, sans acte diagnostique ou thérapeutique majeur, et qui ne donnent pas lieu à une hospitalisation. Elle constitue un **proxy officiel DREES** du recours potentiellement évitable aux urgences hospitalières — au cœur des stratégies SAS (Service d'Accès aux Soins) et de désengorgement des SU.

**Classification CCMU** (Classification Clinique des Malades aux Urgences, Fourestié et al., 1994) :
- CCMU 1 : état clinique stable, pas d'acte complémentaire (pas d'examen biologique, radiologique, ni geste technique).
- CCMU 2 : état clinique stable, actes complémentaires diagnostiques ou thérapeutiques pratiqués aux urgences.
- CCMU 3, 4, 5 : instabilité croissante (pronostic vital engagé en 4-5).

Formellement, pour un territoire *z* :

```
PartCCMU12_evitable(z) =
    nb passages SU avec CCMU ∈ {1, 2} ET mode_sortie = domicile
    ────────────────────────────────────────────────────────────
    nb passages SU totaux dans z
```

Positionnement vs indicateurs existants :
- `taux_recours_urgences_pour_mille.md` capte le **volume**.
- `taux_passage_urgences_hospitalisation.md` capte la **part hospitalisée** (complément approximatif).
- `ratio_surrecours_urgences_fdep_q5_q1.md` capte le **gradient social**.
- Le présent indicateur isole **le segment évitable** par construction CCMU 1-2 + retour domicile.

## Calcul

**Source de données** : ⚠️ **hors PMSI MCO direct**. Sources :
- **RPU** (Résumé de Passage aux Urgences) — extrait pour chaque passage SU vers le **système OSCOUR / SurSaUD** (Santé publique France) et vers les ARS.
- Données DREES via la SAE et les enquêtes nationales urgences.

**Variables RPU mobilisées** :
- `CCMU` : code 1 à 5 (+ P si psy, D si décès)
- `MODE_SORTIE` (RPU) : 1 = domicile, 2 = transfert, 3 = hospitalisation dans l'établissement, 4 = SMUR, 9 = décès
- `FINESS_SU` → mapping territoire / GHT
- `AGE`, `SEXE`, `CODE_POSTAL_RESIDENCE` (pour standardisation et analyse par lieu de résidence)
- `DATE_PASSAGE`

**Pseudocode** :

```r
# 1. Filtrer passages SU avec CCMU 1 ou 2 + retour domicile
passages <- rpu %>%
  filter(
    annee == A,
    !is.na(ccmu),
    !ccmu %in% c("P","D")    # exclure psy/décès si analyse standard
  ) %>%
  mutate(
    evitable = ccmu %in% c("1","2") & mode_sortie == "1"
  )

# 2. Agréger par territoire (FINESS_SU → GHT)
part_ccmu12 <- passages %>%
  left_join(ght_map, by = c("finess_su" = "finess")) %>%
  group_by(ght) %>%
  summarise(
    n_passages_total = n(),
    n_evitables      = sum(evitable, na.rm = TRUE),
    part_evitable    = n_evitables / n_passages_total,
    part_ccmu1_seul  = mean(ccmu == "1" & mode_sortie == "1"),
    part_ccmu2_seul  = mean(ccmu == "2" & mode_sortie == "1"),
    .groups = "drop"
  )
```

**Conventions cas limites** :
- CCMU **manquant** : taux d'exhaustivité du codage CCMU variable (75–98 % selon SU) — toujours rapporter le taux d'exhaustivité en parallèle.
- CCMU **P** (psychiatrie) : à analyser séparément (filière SU psy ≠ filière SU somatique).
- Passages **pédiatriques** (< 16 ans) : très forte part de CCMU 1-2 par construction — analyse stratifiée recommandée.
- Mode sortie « **partis sans attendre** » (PSA) : exclure du dénominateur ou analyser séparément (signal de saturation, pas de recours évitable).

## Utilité

1. **Pilotage SAS** : indicateur principal d'évaluation de l'efficacité du dispositif Service d'Accès aux Soins déployé en France depuis 2020.
2. **Déclinaison par tranche horaire** : une part CCMU 1-2 élevée le **soir/week-end** signale un déficit de permanence des soins ambulatoires ; en **journée semaine**, signale un déficit d'accessibilité aux médecins traitants.
3. **Audit de saturation SU** : un fort taux d'évitables masque le vrai problème (lits d'aval), un faible taux d'évitables avec saturation signale un problème d'engorgement par lourdeur.
4. **Communication grand public / éducation thérapeutique** : argument pour campagnes orientation 15/116-117 / médecin traitant.
5. **Argumentation économique** : coût moyen d'un passage CCMU 1-2 ~ 70-100 € vs consultation ville ~ 25-30 € — calcul du gain potentiel de réorientation.
6. **Suivi pluriannuel** : trajectoire CPOM / ARS, objectif baisse part évitables.
7. **Croisement morbidité** : décomposer par motif (CIM-10 OPCT en RPU) — identifier les motifs surreprésentés (pathologies bénignes ORL, dermato, traumatos simples).

## Sources de Données

- **RPU (Résumé de Passage aux Urgences)** — format OSCOUR/SurSaUD géré par Santé publique France. Variables `CCMU`, `MODE_SORTIE_RPU`, `FINESS_SU`, `AGE`, `SEXE`, `CODE_POSTAL`, `DATE_PASSAGE`, `MOTIF_RECOURS`, `DIAGNOSTIC_PRINCIPAL`.
- **DREES** : Panorama des établissements de santé, données urgences. URL : https://drees.solidarites-sante.gouv.fr
- **SAE** : Statistique Annuelle des Établissements — agrégats annuels SU.
- **Référentiel CCMU** : Fourestié et al., 1994. Mise à jour pédiatrique : CCMU-P pour < 16 ans (variante locale).

⚠️ Le RPU n'est pas inclus dans les exports PMSI standards. Accès via :
- Convention ARS (échelle régionale)
- Santé publique France (accès chercheurs)
- Datamart urgences interne aux GHT (si déployé)

## Exemple de Valeurs

Ordre de grandeur indicatif (à confirmer sur Panorama DREES en cours, non sourcé au chiffre près) :

| Niveau | Part CCMU 1-2 + retour domicile |
|---|---|
| Moyenne nationale | 50 – 60 % des passages SU |
| CCMU 1 retour domicile | 15 – 25 % |
| CCMU 2 retour domicile | 30 – 40 % |
| SU pédiatriques (< 16 ans) | 70 – 85 % |
| SU CHU adultes | 40 – 55 % |
| SU CH proximité ruraux | 55 – 70 % |

Seuils interprétatifs :
- > 65 % adultes : forte part évitable, action SAS prioritaire.
- < 40 % adultes : SU « lourd », à vérifier que les flux légers ne sont pas captés ailleurs (UHCD, soins non programmés territoriaux).
- Variation > 5 pts/an : signal d'un événement structurel (fermeture filière, déploiement MMG, etc.).

Source : ordre de grandeur expert et DREES Panorama. Non sourcé au chiffre près.

## Limites

- **CCMU codée en temps réel** par l'urgentiste — subjective, hétérogène inter-établissements, biais de codage en fin de garde.
- **Définition « évitable »** : un CCMU 1-2 peut être médicalement justifié (rassurance d'un patient anxieux, suspicion levée à l'examen). L'indicateur **ne préjuge pas du caractère médicalement justifié** au cas par cas.
- **Effet âge** : CCMU 1-2 dominent en pédiatrie (≠ évitable en pratique). Analyse stratifiée indispensable.
- **Hors PMSI** : nécessite RPU/OSCOUR, accès non systématique. Compatibilité avec les outils PMSI standards GHT à organiser.
- **Convention CCMU non universelle** : variantes pédiatriques (CCMU-P) et psychiatriques (CCMU-Psy) peu standardisées entre régions.
- **Mode_sortie ≠ pertinence** : un retour à domicile peut suivre une consultation médicale réelle (rassurance) — pas équivalent à « inutile ».
- **Effet réformes** : régulation préalable aux urgences (2022–2023) a modifié la composition CCMU des passages — comparaisons pluriannuelles à corriger.
- **Exhaustivité variable** : SU avec faible exhaustivité CCMU (< 80 %) → indicateur non comparable.
- **Saturation amont** : un faible recours évitable peut masquer une saturation par les passages lourds, pas une bonne pertinence amont.

## Références

- Fourestié, V., Roussignol, E., Elkharrat, D., et al. *Classification clinique des malades des urgences : définition et reproductibilité*. Réanimation Urgences, 1994 ; 3 : 573-578. — Référence fondatrice du CCMU.
- DREES, Panorama des établissements de santé, édition 2025 (données 2023). URL : https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025
- Santé publique France, dispositif OSCOUR/SurSaUD — RPU national. URL : https://www.santepubliquefrance.fr
- DREES, ER 1325 (janvier 2025) — recours SAMU et régulation. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-01/ER%201325%20SAMU_Embargo.pdf
- Voir aussi `taux_recours_urgences_pour_mille.md`, `taux_recours_samu_pour_mille_territoire.md`, `taux_passage_urgences_hospitalisation.md`.
