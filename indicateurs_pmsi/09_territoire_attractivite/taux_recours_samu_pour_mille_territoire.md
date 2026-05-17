# Taux de recours SAMU-Centre 15 pour mille habitants (territoire)

## Définition

Le **taux de recours SAMU-Centre 15** mesure le nombre de **dossiers de régulation médicale** (DRM) traités par le SAMU-Centre 15 d'un territoire (département, GHT, zone SAS) rapporté à la population résidente, standardisé sur la structure âge × sexe nationale. Il est documenté par la **DREES (ER 1325, janvier 2025)** comme indicateur clé du recours non programmé en amont des urgences hospitalières et de la pression sur la régulation médicale post-crise sanitaire.

Formellement :

```
TR_samu(z) = Σ_k [ taux_obs(z, k) × pop_ref(k) ] / Σ_k pop_ref(k)
```

avec `taux_obs(z, k) = DRM(z, k) / pop(z, k) × 1000` pour chaque strate âge × sexe *k* dans le territoire *z*, et `pop_ref(k)` = population française dans la strate *k*.

Positionnement vs indicateurs existants :
- `taux_recours_urgences_pour_mille.md` mesure le **passage physique** aux urgences.
- Le présent indicateur capte la **demande en amont** des urgences, à un stade où l'orientation est encore possible (conseil médical, médecin de garde, transport ambulatoire, urgences).
- Couplé au taux de recours urgences, il permet d'estimer le **taux de filtration** par la régulation : `DRM non orientées vers SU / DRM totales`.

## Calcul

**Source de données** : ⚠️ **hors PMSI** — le SAMU ne produit pas de RSA. Sources :
- Bases de régulation **Centaure 15** (logiciels métiers SAMU) ou équivalent CRR (Centre de Réception et de Régulation des appels).
- Fichier **DRM** consolidé par l'ARS au niveau régional.
- Exports DREES / DGOS de la SAE (Statistique Annuelle des Établissements) pour comptages agrégés annuels.

**Variables mobilisées** :
- Identifiant SAMU (codé par CRRA, généralement 1 par département)
- Date/heure du DRM
- Caractéristiques patient : âge, sexe, code postal de résidence
- Décision de régulation : conseil médical, envoi médecin de garde, envoi ambulance, envoi SMUR, orientation urgences

**Pseudocode** :

```r
# 1. Compter les DRM par territoire × strate âge × sexe
drm_strate <- drm %>%
  filter(annee == A) %>%
  mutate(
    classe_age = cut(age, breaks = c(0,1,5,15,25,45,65,75,85,200)),
    zone = mapping_geo(code_postal)
  ) %>%
  count(zone, classe_age, sexe, name = "n_drm")

# 2. Joindre population
taux_strate <- drm_strate %>%
  left_join(pop_insee, by = c("zone","classe_age","sexe")) %>%
  mutate(taux_brut = n_drm / pop * 1000)

# 3. Standardisation directe
pop_ref_nat <- pop_insee %>%
  group_by(classe_age, sexe) %>%
  summarise(pop_ref = sum(pop), .groups = "drop")

tr_samu_std <- taux_strate %>%
  left_join(pop_ref_nat, by = c("classe_age","sexe")) %>%
  group_by(zone) %>%
  summarise(
    tr_samu_std = sum(taux_brut * pop_ref) / sum(pop_ref),
    n_drm_total = sum(n_drm),
    .groups = "drop"
  )
```

**Conventions cas limites** :
- **Doubles appels** pour un même événement : à dédupliquer par identifiant patient+événement quand disponible (sinon biais haussier de 5–10 %).
- **Régulation pour des résidents hors zone** : géocoder par lieu de résidence, pas de prise en charge — comme pour le taux de recours hospitalier.
- **DRM sans suite** (faux appels, raccrochés) : à exclure ou comptabiliser séparément.
- **Couverture territoriale du Centre 15** : un département peut être régulé par un Centre 15 voisin (mutualisation nuit, week-end) — vérifier la cohérence département de régulation ↔ département de résidence.

## Utilité

1. **Pression amont des urgences** : un sur-recours SAMU couplé à un sous-recours urgences signale une filtration efficace par la régulation ; couplé à un sur-recours urgences, signale une saturation à tous les étages.
2. **Évaluation SAS (Service d'Accès aux Soins)** : indicateur principal de suivi du déploiement SAS, qui mutualise régulation 15 et 116-117.
3. **Démographie médicale** : un taux SAMU élevé peut signaler une carence de médecine de premier recours (déserts médicaux) — corrélation à étudier avec densité médicale ville.
4. **Saisonnalité / pics épidémiques** : suivi infra-annuel pour ajuster les moyens de régulation (grippe, COVID, canicule).
5. **Comparaison inter-départements** : standardisation âge × sexe nécessaire car la pyramide des âges influe fortement (les < 5 ans et > 75 ans appellent plus).
6. **Allocation moyens de régulation** : argument quantitatif pour le dimensionnement des ARM (Assistants de Régulation Médicale) et médecins régulateurs.
7. **Évaluation impact réformes** : suivi du taux post-réforme régulation des urgences 2022–2023 (régulation préalable obligatoire).

## Sources de Données

- **Centaure 15 / CRRA** : logiciels de régulation SAMU, exports via ARS. **Hors PMSI**.
- **SAE** (Statistique Annuelle des Établissements) — DGOS/DREES : agrégats annuels DRM par SAMU. URL : https://drees.solidarites-sante.gouv.fr
- **DREES Études et Résultats n° 1325** (janvier 2025) — méthodologie de référence : *« Samu : un taux de recours en hausse à la suite de la crise sanitaire et des mesures de régulation des urgences »*. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-01/ER%201325%20SAMU_Embargo.pdf
- **INSEE** : populations municipales par âge × sexe.

## Exemple de Valeurs

Plages observées d'après DREES ER 1325 (à confirmer sur édition en cours, ordre de grandeur) :

| Année | Taux national DRM / 1 000 hab |
|---|---|
| 2014 | ~ 360 |
| 2019 | ~ 460 |
| 2020 (COVID) | ~ 550 |
| 2022 (post-régulation) | ~ 620 |

Disparités départementales :
- Plage observée 2022 : ~ 350 – 900 / 1 000 hab.
- Écart entre départements faiblement et fortement régulés peut dépasser un facteur 2,5 à structure démographique standardisée.

Source : DREES ER 1325 — ordres de grandeur lus dans le document, non sourcés au chiffre précis.

## Limites

- **Hors PMSI** : nécessite accès à des bases SAMU/CRRA non systématiquement disponibles aux GHT. Coupler avec une convention de partage ARS.
- **Hétérogénéité conventions de comptage** : un DRM peut être défini différemment selon CRRA (par appel, par patient, par événement). Vérifier les définitions avant comparaison.
- **Effet réformes** : la régulation préalable obligatoire (2022–2023) a structurellement augmenté le numérateur — comparaisons pluriannuelles pré/post à corriger.
- **Couverture nuit / week-end** : mutualisation entre départements peut décaler les DRM vers un CRRA voisin — biais inter-départemental.
- **Doublons potentiels** : un même événement peut générer plusieurs DRM (rappel famille, médecin de garde). Sans identifiant événement unique, sur-comptage de 5–10 %.
- **Standardisation âge/sexe seule** : ne neutralise pas la précarité, l'urbanité, l'éloignement des soins. Compléter par stratification rural/urbain ou ajustement FDep (cf. `taux_recours_ajuste_fdep.md`).
- **Lien causal avec accès aux soins** : un taux SAMU élevé n'implique pas mécaniquement un déficit de médecine de ville — il peut traduire une bonne accessibilité de la régulation et une bonne acculturation au 15.
- **Ne capte pas la qualité** : un DRM mal régulé envoyé en urgences alors qu'un conseil aurait suffi est compté comme un succès quantitatif. Croiser avec la part de DRM orientées vers les urgences pour qualifier.

## Références

- DREES, *Études et Résultats n° 1325*, janvier 2025 — « Samu : un taux de recours en hausse à la suite de la crise sanitaire et des mesures de régulation des urgences ». URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-01/ER%201325%20SAMU_Embargo.pdf
- DREES, *Études et Résultats n° 471* — *Les recours urgents ou non programmés en médecine générale*. URL : https://drees.solidarites-sante.gouv.fr/sites/default/files/er471.pdf
- DREES, Panorama des établissements de santé 2025 (données 2023). URL : https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025
- Voir aussi `taux_recours_urgences_pour_mille.md`, `part_passages_urgences_ccmu1_2_sans_hospi.md`.
