# Taux d'hospitalisations non programmées des résidents d'EHPAD

## Définition

Le **taux d'hospitalisations non programmées (HNP) des résidents d'EHPAD** mesure le nombre de séjours MCO non programmés (entrée via les urgences ou transfert non préparé) chez les patients résidant en EHPAD du territoire, rapporté à la **file active EHPAD** (nombre de résidents). C'est un indicateur structurant **recommandé par la HAS** (rapport *« Comment réduire les hospitalisations non programmées des résidents des EHPAD »*, 2015 et mises à jour) pour piloter la qualité du parcours médico-social ↔ sanitaire d'un GHT.

Formellement :

```
TauxHNP_EHPAD(GHT) =
   nb séjours MCO de résidents EHPAD avec mode_entrée = urgences (8) OU non programmé
   ─────────────────────────────────────────────────────────────────────────────────
   file active EHPAD du territoire (nb résidents au 31/12 ou moyenne)
```

Habituellement exprimé en :
- nb HNP / 100 résidents EHPAD / an
- ou nb HNP / 1 000 journées EHPAD

Variantes selon dénominateur :
- **HNP brut** : sur l'ensemble des séjours MCO de résidents EHPAD.
- **HNP évitables** (sous-ensemble) : croisement avec liste ACSC (Ambulatory Care Sensitive Conditions) — chutes simples, infections urinaires, déshydratation, BPCO décompensée, IC légère, fécalome.

Positionnement vs existants :
- `part_patients_residant_ehpad.md` mesure la **part** dans le flux MCO global du territoire.
- `taux_hospit_potentiellement_evitables_acsc.md` mesure le taux ACSC en population générale.
- `taux_activite_non_programmee.md` mesure l'activité non programmée globale d'un établissement.
- Le présent indicateur **croise les trois axes** : EHPAD × non programmé × territorial — c'est l'indicateur officiel HAS du dispositif gériatrique territorial (équipes mobiles, IDEL nuit, télémédecine, hypodermoclyse).

## Calcul

**Source PMSI** : RSA MCO. **Source dénominateur** : externe (CNSA, ARS, EHPAD via SI médico-social).

**Variables PMSI mobilisées** :
- `MODE_ENTREE` : 8 = domicile (incluant EHPAD selon convention) + provenance EHPAD ; 5 = mutation depuis SSR ; 7 = transfert. **Non programmé** = entrée via urgences (`PASSAGE_UHCD` ou présence d'un séjour SU dans les 24 h).
- `PROVENANCE` : code 6 = établissement médico-social (EHPAD/USLD).
- `DUREE_SEJOUR`, `DP`, `MODE_SORTIE`
- `NUM_FINESS_GEO` → mapping GHT

**Variables externes (dénominateur file active EHPAD)** :
- **CNSA / ARS** : capacité installée et file active EHPAD par département/territoire.
- **SAE médico-sociale** : effectifs au 31/12.
- **SI EHPAD locaux** (résinfo, etc.) si datamart GHT existant.

**Pseudocode** :

```r
# 1. Identifier les séjours MCO de résidents EHPAD
sej_ehpad <- rsa %>%
  filter(annee == A) %>%
  mutate(
    res_ehpad = (provenance == "6") | (destination == "6")
  ) %>%
  filter(res_ehpad)

# 2. Identifier les HNP (mode entrée urgences ou passage urgences même séjour)
sej_ehpad_hnp <- sej_ehpad %>%
  mutate(
    hnp = (mode_entree == "8" & provenance == "6" &
           (passage_urgences_24h == TRUE | mode_entree_detail == "urgences"))
  )

# 3. Agréger par GHT
hnp_ght <- sej_ehpad_hnp %>%
  left_join(ght_map, by = c("num_finess_geo" = "finess")) %>%
  group_by(ght) %>%
  summarise(
    n_sejours_ehpad = n(),
    n_hnp           = sum(hnp, na.rm = TRUE),
    .groups = "drop"
  )

# 4. Joindre la file active EHPAD territoriale
result <- hnp_ght %>%
  left_join(file_active_ehpad, by = "ght") %>%
  mutate(
    taux_hnp_100res    = n_hnp / file_active_ehpad * 100,
    taux_hnp_1000jrs   = n_hnp / (file_active_ehpad * 365) * 1000
  )

# 5. Sous-ensemble ACSC (HNP évitables)
acsc_codes <- read_referentiel_acsc(version = "DREES_2023")
hnp_acsc <- sej_ehpad_hnp %>%
  filter(hnp, dp %in% acsc_codes) %>%
  count(ght, name = "n_hnp_acsc")
```

**Conventions cas limites** :
- Provenance EHPAD sous-codée (cf. `part_patients_residant_ehpad.md`) → numérateur sous-estimé de 20–50 %.
- File active EHPAD pas toujours alignée sur le territoire GHT (EHPAD privés non gérés par le GHT) — toujours documenter le périmètre.
- Patients en accueil de jour ou hébergement temporaire : à exclure ou compter séparément.
- Séjours pour soins palliatifs programmés en EHPAD-MCO : à exclure du numérateur (programmés par construction).
- Inclure les **transferts SMUR depuis EHPAD** dans le numérateur (mode_entrée = 7 + appel SAMU documenté).

## Utilité

1. **Suivi dispositif gériatrique territorial** : indicateur central du déploiement des équipes mobiles gériatriques externes, IDE de nuit en EHPAD, télémédecine gériatrique, conventions EHPAD-MCO.
2. **Cible CPOM / contrat tripartite EHPAD–ARS–GHT** : trajectoire annuelle, objectif de baisse de 10–20 % sur 3 ans dans les dispositifs ESMS-Sanitaire.
3. **Identification EHPAD à risque** : décomposition par EHPAD d'origine, repérer les établissements avec taux HNP > moyenne + 1 écart-type pour intervention ciblée.
4. **Évaluation IDE de nuit / hypodermoclyse** : avant/après déploiement, mesure de l'impact sur les HNP nocturnes.
5. **Argument médico-économique** : coût HNP EHPAD ~ 4 000–6 000 € / séjour vs séjour évité par téléconsultation gériatrique ~ 50–100 €.
6. **Détection écart codage** : un taux très bas peut révéler un sous-codage de la provenance EHPAD plutôt qu'une bonne pratique.
7. **Articulation HAD** : couplé à `taux_bascule_had_precoce_post_mco.md` et à la part HAD-EHPAD, arbitrer entre hospitalisation et HAD substitutive.

## Sources de Données

- **PMSI MCO** : RSA. Variables `MODE_ENTREE`, `PROVENANCE`, `DESTINATION`, `MODE_SORTIE`, `NUM_FINESS_GEO`, `DP`. Guide méthodologique ATIH.
- **RPU** (option) : pour confirmer l'entrée via urgences avec horodatage et CCMU.
- **CNSA** : files actives EHPAD par département. URL : https://www.cnsa.fr
- **SAE médico-sociale** : DREES, capacités et activités EHPAD.
- **HAS** : *Comment réduire les hospitalisations non programmées des résidents des EHPAD*, mise à jour la plus récente. URL : https://www.has-sante.fr/jcms/c_2049096/fr/comment-reduire-les-hospitalisations-non-programmees-des-residents-des-ehpad
- **Référentiel ACSC** : liste DREES/IRDES des codes CIM-10 hospitalisations potentiellement évitables — cf. `taux_hospit_potentiellement_evitables_acsc.md`.

## Exemple de Valeurs

Ordre de grandeur indicatif (HAS 2015, DREES ER 1262, à confirmer sur publications récentes — non sourcé au chiffre précis) :

| Indicateur | Valeur observée |
|---|---|
| Taux HNP / 100 résidents / an | 30 – 60 |
| Part HNP évitables (ACSC) / total HNP EHPAD | 25 – 40 % |
| Taux HNP nocturnes (20h–8h) / total HNP | 15 – 25 % |
| Pic saisonnier hiver (grippe, déshydratation) | +20 à +40 % vs été |

Seuils d'alerte :
- > 50 HNP/100 résidents/an : signal fort, plan EHPAD-GHT à activer.
- Part nocturne > 25 % : déficit IDE de nuit territorial.
- Part ACSC > 40 % : faible accessibilité au médecin traitant en EHPAD.

Source : ordre de grandeur expert + HAS 2015 + littérature gériatrique. Non sourcé au chiffre précis.

## Limites

- **Sous-codage provenance EHPAD** : limite principale — 20 à 50 % des résidents EHPAD codés « domicile ». Numérateur structurellement sous-estimé.
- **File active EHPAD non disponible** par GHT en routine : nécessite recouvrement CNSA / ARS / SI EHPAD. Périmètre parfois flou.
- **« Non programmé » vs « urgent »** : un séjour passant par les urgences peut être médicalement justifié (AVC, fracture). L'indicateur n'isole pas l'évitable sans croisement ACSC.
- **EHPAD adossé à GHT vs privés** : la sensibilité à l'action GHT diffère. Décomposer public/privé pour pertinence opérationnelle.
- **Effet saisonnier** : grippe, canicule font exploser l'indicateur en pic. Comparaisons annuelles à lisser ou stratifier saison.
- **Effet GMP / PMP** : EHPAD avec patientèle plus lourde (GIR 1-2 dominants, PMP > 250) auront un taux HNP plus élevé sans défaut de qualité.
- **Pas de standardisation native** : pour comparaison inter-GHT, standardiser sur GMP/PMP des EHPAD du territoire.
- **Convention HNP** : un transfert SMUR vs entrée directe par admission programmée même jour : à distinguer.
- **Sources hétérogènes** : croisement PMSI + médico-social rarement automatisé — risque de désalignement temporel (file active 31/12 vs séjours année N).

## Références

- HAS, *Comment réduire les hospitalisations non programmées des résidents des EHPAD*, 2015 et mises à jour. URL : https://www.has-sante.fr/jcms/c_2049096/fr/comment-reduire-les-hospitalisations-non-programmees-des-residents-des-ehpad
- DREES, *Études et Résultats n° 1262* (avril 2023) — Les hospitalisations potentiellement évitables touchent davantage les ouvriers et les agriculteurs. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2023-04/ER1262EMB.pdf
- CNSA, *Files actives et capacités EHPAD*, publication annuelle. URL : https://www.cnsa.fr
- IRDES, *Moins de soins de prévention, plus d'hospitalisations évitables chez les personnes suivies pour un trouble psychique sévère*, Questions d'économie de la santé n° 250. URL : https://www.irdes.fr/recherche/questions-d-economie-de-la-sante/250-moins-de-soins-de-prevention-plus-d-hospitalisations-evitables-chez-personnes-suivies-pour-trouble-psychique-severe.pdf
- Voir aussi `part_patients_residant_ehpad.md`, `taux_hospit_potentiellement_evitables_acsc.md`, `taux_bascule_had_precoce_post_mco.md`.
