# Part des patients résidant en EHPAD

## Définition

La **part des patients résidant en EHPAD** (ou plus largement en établissement médico-social — EHPAD, USLD, FAM, MAS) mesure la fraction des séjours hospitaliers MCO dont le patient était hébergé en institution médico-sociale au moment de son admission ou y retournera à sa sortie. Elle constitue une **caractéristique officielle ATIH** de profil de patientèle d'un GHT, utilisée pour identifier les territoires confrontés à un fort vieillissement dépendant en amont du sanitaire.

Formellement :

```
PartEHPAD(GHT) = nb séjours avec provenance ou destination EHPAD/USLD / nb séjours totaux MCO du GHT
```

L'identification repose sur la conjonction du **mode d'entrée**, de la **provenance** (et symétriquement mode de sortie + destination) du PMSI MCO.

Positionnement :
- Non équivalent à `taux_patients_sans_medecin_traitant.md` (vulnérabilité d'accès aux soins de ville).
- Non équivalent à `indice_besoins_non_couverts.md` (offre territoriale).
- Complémentaire à un éventuel indice d'âge moyen / part 75+ : la dépendance institutionnelle est un facteur de complexité indépendant de l'âge brut (deux territoires de même âge moyen peuvent avoir une part EHPAD très différente).

## Calcul

**Source PMSI** : RSA MCO, format en vigueur de la campagne (cf. guide méthodologique ATIH).

**Variables PMSI mobilisées** :
- `modeentree` : code 6 = mutation, 7 = transfert, 8 = domicile (incluant médico-social selon convention historique — **à confirmer sur la campagne en cours**)
- `PROVENANCE` : code 6 = établissement médico-social (EHPAD, USLD, FAM, MAS, etc.) — variable conjointe au mode d'entrée
- `MODE_SORTIE` (symétrique) : 6 = mutation, 7 = transfert, 8 = domicile, 9 = décès
- `DESTINATION` : code 6 = médico-social
- `finessgeo` → mapping GHT

> ⚠️ Les conventions de codage de la provenance EHPAD ont évolué : sur certaines campagnes, la provenance médico-sociale est codée via le couple (mode_entrée = 8 ou 6, provenance = 6), sur d'autres elle utilise un code dédié. **Toujours se référer au guide méthodologique de la campagne PMSI en vigueur** pour la combinaison exacte.

**Pseudocode** :

```r
# 1. Identifier les séjours avec lien EHPAD/USLD à l'entrée OU à la sortie
sej_ms <- rsa %>%
  filter(annee == A) %>%
  mutate(
    entree_ms = (provenance == "6"),         # convention à confirmer
    sortie_ms = (destination == "6"),
    lien_ms   = entree_ms | sortie_ms
  )

# 2. Agréger par GHT
part_ehpad <- sej_ms %>%
  left_join(ght_map, by = c("num_finess_geo" = "finess")) %>%
  group_by(ght) %>%
  summarise(
    n_sejours_total   = n(),
    n_sejours_ms      = sum(lien_ms, na.rm = TRUE),
    n_entree_ms       = sum(entree_ms, na.rm = TRUE),
    n_sortie_ms       = sum(sortie_ms, na.rm = TRUE),
    part_lien_ms      = n_sejours_ms / n_sejours_total,
    part_provenance   = n_entree_ms / n_sejours_total,
    part_destination  = n_sortie_ms / n_sejours_total,
    .groups = "drop"
  )
```

**Conventions cas limites** :
- Provenance manquante : exclure du numérateur (ni compté EHPAD, ni compté domicile).
- Séjours nouveau-nés (CMD 14, 15) : exclure (pas de provenance EHPAD pertinente).
- Séjours en erreur (CMD 90) : exclure.
- Patient avec multiples séjours dans l'année : compter par séjour (l'indicateur est en flux, pas en file active).

## Utilité

1. **Caractérisation officielle ATIH** : positionnement d'un GHT sur la grille « patientèle » de ScanSanté, valeur attendue dans le diagnostic territorial.
2. **Pilotage filière gériatrique** : la part EHPAD à l'entrée signale le besoin de filières admissions directes gériatriques (court-séjour gériatrique, équipes mobiles gériatriques).
3. **Bed-blocking aval** : la part EHPAD à la sortie est un proxy des sorties complexes — corrélée à `taux_bed_blocking_mco_attente_ssr.md`.
4. **Anticipation demande SSR/HAD** : une part EHPAD élevée prédit des durées de séjour plus longues et des besoins post-MCO accrus.
5. **Conventionnement EHPAD–MCO** : objectivation du volume de flux pour justifier des conventions de coopération (lits dédiés, garde gériatrique, télémédecine en EHPAD).
6. **Prévention des hospitalisations évitables** : un fort flux entrant depuis EHPAD doit être croisé avec la pertinence des admissions (ACSC — Ambulatory Care Sensitive Conditions).
7. **Allocation ressources gériatriques** : argument quantitatif pour le dimensionnement des équipes mobiles gériatriques territoriales financées dans le cadre du Ségur.

## Sources de Données

- **PMSI MCO** : RSA ATIH, variables `modeentree`, `PROVENANCE`, `MODE_SORTIE`, `DESTINATION`. Guide méthodologique MCO en vigueur — codes et conventions susceptibles d'évoluer entre campagnes.
- **Référentiel GHT** : ATIH / DGOS — https://www.atih.sante.fr/organisation-territoriale-des-soins/groupements-hospitaliers-de-territoire
- **Référentiel FINESS** : extraction FINESS pour identification des établissements médico-sociaux d'origine (si analyse fine par établissement médico-social source).

Restitution publique équivalente : ScanSanté → « Caractériser et suivre un GHT » → caractéristique « part des patients résidant en EHPAD ».

## Exemple de Valeurs

Ordre de grandeur indicatif (à confirmer sur restitutions ScanSanté de la campagne en cours, non sourcé au chiffre près) :

| Profil de territoire | Part patients lien EHPAD (entrée ou sortie) |
|---|---|
| GHT urbain jeune | 3 – 6 % |
| GHT urbain équilibré | 6 – 10 % |
| GHT rural / vieillissant | 10 – 18 % |
| GHT spécialisé gériatrie / SSR fort | 15 – 25 % |

Seuils d'alerte :
- > 12 % : forte dépendance amont — vérifier maillage filière gériatrique territoriale.
- Croissance > 1 pt/an : signal de bascule démographique du territoire, à intégrer aux projections capacitaires.

Source des plages : ordre de grandeur expert, non sourcé.

## Limites

- **Convention de codage** : la combinaison exacte (mode_entrée, provenance) pour identifier l'EHPAD varie selon les versions du guide méthodologique. Documenter la convention retenue à chaque campagne.
- **Sous-codage fréquent** : la provenance médico-sociale est régulièrement codée comme « domicile » par défaut, notamment quand le patient transite par les urgences — sous-estimation systématique probable (de 20 à 50 % selon établissements).
- **EHPAD vs autres médico-sociaux** : la variable `provenance` regroupe EHPAD, USLD, FAM, MAS, foyers d'hébergement. Sans information complémentaire, impossible d'isoler les seuls EHPAD.
- **Trajectoire vs domiciliation** : un patient en hospitalisation longue peut être domicilié en EHPAD sans transit direct EHPAD→MCO (passage par urgences, autre hôpital). L'indicateur capte le flux direct, pas la file active EHPAD.
- **Patients en EHPAD non identifiés** : domiciliation administrative chez les enfants ou ancien domicile pour des résidents récents en EHPAD → fuite de la mesure.
- **Effet établissement** : un CHU avec activité de recours captera moins de flux EHPAD direct qu'un CH de proximité — comparer entre établissements de mission similaire.
- **Effet âge non neutralisé** : indicateur brut, fortement corrélé à la part 75+ du territoire — pour comparaison équitable, standardiser ou présenter en couple avec pyramide d'âge.

## Références

- ATIH, « Caractériser et suivre un GHT avec ScanSanté » — caractéristique officielle « part des patients résidant en établissement médico-social ». URL : https://www.scansante.fr/caracteriser-et-suivre-un-groupement-hospitalier-de-territoire-ght
- ATIH, Guide méthodologique de production des informations relatives à l'activité médicale et à sa facturation en MCO — section « modes d'entrée et provenances ». URL : https://www.atih.sante.fr
- DREES, panoramas annuels sur l'offre médico-sociale et les flux EHPAD–hôpital — référence pour valeurs nationales. URL : https://drees.solidarites-sante.gouv.fr
- Voir aussi `taux_bed_blocking_mco_attente_ssr.md` (catégorie 04) — corrélation aval.
