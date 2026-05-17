# Part des décès en soins palliatifs sur le territoire

## Définition

La **part des décès en soins palliatifs** mesure, parmi les séjours MCO d'un GHT codés en soins palliatifs (diagnostic Z51.5 de la CIM-10), la fraction se terminant par un décès hospitalier. C'est une **caractéristique officielle ATIH** de la grille de positionnement stratégique d'un GHT, qui renseigne simultanément :
- la fin de vie hospitalière (proxy du parcours fin de vie sur le territoire),
- la pertinence du recours au codage palliatif (un Z51.5 systématiquement suivi de décès traduit une prise en charge palliative tardive ; un Z51.5 avec faible taux de décès peut signaler un repérage précoce).

Formellement :

```
PartDecesPalliatif(GHT) =
   nb séjours MCO avec DA = Z51.5 ET mode_sortie = 9 (décès)
   ────────────────────────────────────────────────────
   nb séjours MCO avec DA = Z51.5
```

Indicateurs dérivés utiles :
- **Taux de séjours palliatifs** : `nb séjours Z51.5 / nb séjours MCO totaux` (intensité de codage palliatif).
- **Délai médian Z51.5 → décès** : si codage daté disponible, mesure de la précocité du basculement palliatif.

Positionnement vs existants : aucun indicateur du projet ne croise actuellement Z51.5 et mode de sortie au niveau GHT. C'est la déclinaison territoriale de la fin de vie hospitalière dans le cadre officiel ATIH.

## Calcul

**Source PMSI** : RSA MCO (table principale + table des diagnostics associés).

**Variables PMSI mobilisées** :
- `DP` (diagnostic principal, CIM-10)
- `DA` ou `DAS` (diagnostics associés / significatifs — Z51.5 peut être codé en DP **ou** DA selon le motif principal du séjour)
- `MODE_SORTIE` : code 9 = décès
- `DUREE_SEJOUR` (pour analyse complémentaire de précocité)
- `NUM_FINESS_GEO` → mapping GHT

**Codage Z51.5** : « Soins palliatifs » — peut être :
- **DP** : séjour dont le motif principal est la prise en charge palliative,
- **DA significatif** : autre motif principal (ex : tumeur active) avec dimension palliative reconnue.

ATIH ouvre droit à majoration de valorisation (GHM 23Z02Z et niveaux de sévérité 3/4 sur certains GHM) sous conditions de présence et de précocité du Z51.5 (cf. guide méthodologique en vigueur).

**Pseudocode** :

```r
# 1. Repérer les séjours avec Z51.5 (en DP ou DAS)
sej_palliatif <- rsa %>%
  filter(annee == A) %>%
  mutate(
    z515_dp  = (dp == "Z515"),
    z515_das = sapply(das_list, function(x) "Z515" %in% x),
    z515     = z515_dp | z515_das
  ) %>%
  filter(z515)

# 2. Calculer la part de décès par GHT
part_deces <- sej_palliatif %>%
  left_join(ght_map, by = c("num_finess_geo" = "finess")) %>%
  group_by(ght) %>%
  summarise(
    n_z515            = n(),
    n_z515_deces      = sum(mode_sortie == "9", na.rm = TRUE),
    part_deces_pall   = n_z515_deces / n_z515,
    part_z515_dp      = mean(z515_dp),
    .groups = "drop"
  )

# 3. (Optionnel) dénominateur séjours totaux pour intensité de codage
intensite <- rsa %>%
  filter(annee == A) %>%
  count(ght) %>%
  rename(n_total = n)

result <- part_deces %>%
  left_join(intensite, by = "ght") %>%
  mutate(taux_z515 = n_z515 / n_total)
```

**Conventions cas limites** :
- Séjours nouveau-nés (CMD 14, 15) : exclure.
- Séjours en erreur (CMD 90) : exclure.
- Volume minimal recommandé : > 100 séjours Z51.5 / an / GHT pour stabilité de la part.
- Z51.5 en DP vs DAS : distinguer pour éviter d'agréger deux populations cliniquement distinctes.

## Utilité

1. **Caractérisation officielle GHT** : positionnement sur la grille ScanSanté « fin de vie hospitalière ».
2. **Évaluation maillage unités de soins palliatifs** : un GHT avec part de décès Z51.5 < 30 % peut indiquer une bonne prise en charge précoce ; > 75 % indique un recours quasi exclusivement terminal.
3. **Pilotage filière USP / EMSP** : objectiver le besoin en lits dédiés (USP), équipes mobiles (EMSP), lits identifiés (LISP).
4. **Audit interne pertinence** : pic de Z51.5 en DA non suivi de décès peut signaler un codage opportuniste pour valorisation — à investiguer.
5. **Anticipation HAD-fin de vie** : couplé à l'activité HAD du territoire (motif soins palliatifs), arbitrer la répartition fin de vie hospitalière vs domicile.
6. **Comparaison inter-GHT** : indicateur officiel permettant le benchmark entre territoires sur la stratégie fin de vie.
7. **Articulation avec démographie** : croisé avec `part_patients_residant_ehpad.md`, distinguer la fin de vie hospitalière de la fin de vie en EHPAD.

## Sources de Données

- **PMSI MCO** : RSA, variables `DP`, `DAS`, `MODE_SORTIE`, `NUM_FINESS_GEO`. Guide méthodologique MCO en vigueur, ATIH.
- **CIM-10** : code Z51.5 « Soins palliatifs ». Mise à jour annuelle du référentiel CIM-10 par l'ATIH.
- **Référentiel GHT** : ATIH / DGOS.
- **Restitution publique équivalente** : ScanSanté → « Caractériser et suivre un GHT » → caractéristique « part de décès en soins palliatifs ».

Pour analyse fine type d'unité, croiser avec :
- **Référentiel UM** (unités médicales) ATIH pour distinguer les séjours en USP, LISP, services classiques avec EMSP.

## Exemple de Valeurs

Ordre de grandeur indicatif (non sourcé au chiffre près — à consulter sur ScanSanté pour la campagne en cours) :

| Indicateur | Plage observée |
|---|---|
| Part de décès parmi séjours Z51.5 (GHT) | 35 – 70 % |
| Part de séjours Z51.5 / total MCO (GHT) | 1,5 – 4,5 % |
| Part Z51.5 en DP (vs DAS) | 25 – 50 % |

Lectures interprétatives :
- Part décès **élevée** (> 65 %) + intensité Z51.5 **faible** (< 2 %) : codage tardif et restrictif, parcours fin de vie peu organisé.
- Part décès **modérée** (40–55 %) + intensité **élevée** (> 3,5 %) : repérage palliatif précoce, USP/EMSP structurées.
- Part décès **très faible** (< 30 %) : à investiguer — possible codage opportuniste ou repérage très précoce.

Source des plages : ordre de grandeur expert, non sourcé.

## Limites

- **Codage hétérogène** : la mention Z51.5 en DA est variable selon politique de codage interne (services formés vs non formés à la cotation palliative) — comparaison inter-établissements à interpréter prudemment.
- **Z51.5 et valorisation** : la présence de Z51.5 peut faire basculer un séjour en niveau de sévérité supérieur (selon GHM et règles en vigueur), créant une incitation au codage — biais de sur-codage possible.
- **Décès hospitalier ≠ fin de vie territoriale** : les décès à domicile, en EHPAD ou en HAD ne sont pas captés. L'indicateur sous-estime la fin de vie territoriale.
- **Type d'unité non distingué** : USP, LISP, lit standard avec passage EMSP → confondus dans le calcul de base. Nécessite croisement UM pour finesse.
- **Évolution annuelle des règles** : les consignes ATIH de codage Z51.5 ont évolué (notice de campagne) — comparaisons pluri-annuelles à corriger.
- **Mortalité brute** : non standardisée sur sévérité, âge, comorbidités — un GHT recevant des patients très avancés affichera mécaniquement une part de décès plus élevée.
- **Effet recrutement** : un CHU avec activité de recours oncologique captera des Z51.5 décompensés, distorsion possible vs CH de proximité.
- **Soins palliatifs pédiatriques** : volumes faibles, peuvent rendre la part instable ou indésirable — à analyser séparément si pertinent.

## Références

- ATIH, « Caractériser et suivre un GHT avec ScanSanté » — caractéristique officielle « part de décès en soins palliatifs ». URL : https://www.scansante.fr/caracteriser-et-suivre-un-groupement-hospitalier-de-territoire-ght
- ATIH, Guide méthodologique MCO de la campagne en vigueur — règles de codage Z51.5 et impact sur la classification GHM / valorisation. URL : https://www.atih.sante.fr
- OMS / ATIH, Classification Internationale des Maladies CIM-10, code Z51.5 « Soins palliatifs ».
- Voir aussi `part_patients_residant_ehpad.md` (catégorie 09) pour articulation amont fin de vie.
