# Indice de performance ambulatoire ATIH (gestes marqueurs)

## Définition

L'**indice de performance ambulatoire** mesure l'écart relatif entre le taux observé de chirurgie ambulatoire d'un GHT (ou d'un établissement) et un **taux cible national**, sur une liste de **gestes marqueurs** (GM) chirurgicaux historiquement retenus par la CNAM, l'AFCA et l'ATIH pour le suivi du virage ambulatoire.

Deux listes de référence coexistent :
- **18 GM historiques** (co-construits CNAM/AFCA, 2000) — base de l'indicateur **P13** d'Hospi-Diag.
- **55 GM MSAP** (co-construits CNAM / sociétés savantes, 2008+) — base de la Mise Sous Accord Préalable (MSAP) de l'hospitalisation complète et du restitut ScanSanté « Action GDR chirurgie ambulatoire ».

L'indice s'écrit :

```
IPA(GHT) = ( taux_ambu_obs(GHT) − taux_ambu_attendu(GHT) ) / taux_ambu_attendu(GHT)
```

avec :
- `taux_ambu_obs(GHT)` = Σ séjours ambulatoires sur la liste GM / Σ séjours totaux (ambu + hospi complète) sur la même liste
- `taux_ambu_attendu(GHT)` = taux national observé sur la liste GM, **éventuellement ajusté case-mix** (pondération par la part de chaque GM dans l'activité du GHT)

Une valeur positive = GHT en avance sur la cible nationale ; négative = en retard.

C'est la **caractéristique « croissance des modes de prise en charge »** dans la grille officielle ATIH de positionnement GHT.

## Calcul

**Source PMSI** : RSA MCO, table des actes CCAM associés.

**Variables PMSI mobilisées** :
- `GHM` (pour filtrer chirurgie : 1ère lettre = C)
- `DUREE_SEJOUR` (= 0 ou hospitalisation de jour : combiné au mode entrée/sortie 8 = ambu)
- `MODE_ENTREE` / `MODE_SORTIE` : codes 6 (mutation) ou 8 (domicile, dont jour)
- `CODE_ACTE_CCAM` : un séjour est classé sur un GM si l'un de ses actes CCAM appartient à la liste de référence
- `NUM_FINESS_GEO` → mapping GHT

**Liste des GM** : référentiels à charger annuellement :
- **18 GM** : liste CNAM/AFCA, intégrée à Hospi-Diag (P13).
- **55 GM MSAP** : liste CNAM/sociétés savantes, intégrée à ScanSanté (action GDR chirurgie ambulatoire).

> ⚠️ La composition exacte des listes (codes CCAM) est susceptible d'évoluer par convention CNAM/sociétés savantes. **Toujours utiliser la liste de la campagne en vigueur**, téléchargeable sur le portail ATIH ou Visuchir.

**Pseudocode** :

```r
# 0. Charger la liste des codes CCAM constituant les GM (55 MSAP ou 18 historiques)
liste_gm <- read_referentiel_gm(version = "55_MSAP", annee = A)

# 1. Identifier les séjours sur GM (au moins un acte de la liste)
sej_gm <- rsa %>%
  filter(annee == A, substr(ghm, 1, 1) == "C") %>%
  mutate(
    sur_gm = sapply(actes_ccam_list, function(x) any(x %in% liste_gm$ccam)),
    gm_id  = sapply(actes_ccam_list, function(x) {
      idx <- match(x, liste_gm$ccam)
      liste_gm$gm[idx[!is.na(idx)][1]]   # 1er GM rencontré
    }),
    ambu   = (duree_sejour == 0 & mode_entree == "8" & mode_sortie == "8")
  ) %>%
  filter(sur_gm)

# 2. Taux observé par GHT
taux_obs <- sej_gm %>%
  left_join(ght_map, by = c("num_finess_geo" = "finess")) %>%
  group_by(ght) %>%
  summarise(
    n_gm     = n(),
    n_ambu   = sum(ambu),
    taux_obs = n_ambu / n_gm,
    .groups  = "drop"
  )

# 3. Taux national par GM (référence)
taux_nat_gm <- sej_gm %>%
  group_by(gm_id) %>%
  summarise(taux_nat_gm = mean(ambu), .groups = "drop")

# 4. Taux attendu ajusté case-mix (mix de GM du GHT × taux nat par GM)
attendu <- sej_gm %>%
  left_join(ght_map, by = c("num_finess_geo" = "finess")) %>%
  left_join(taux_nat_gm, by = "gm_id") %>%
  group_by(ght) %>%
  summarise(taux_attendu = mean(taux_nat_gm, na.rm = TRUE), .groups = "drop")

# 5. Indice
ipa <- taux_obs %>%
  left_join(attendu, by = "ght") %>%
  mutate(ipa = (taux_obs - taux_attendu) / taux_attendu)
```

**Conventions cas limites** :
- Séjour avec plusieurs actes GM différents : compter une fois, sur le GM principal (par convention, le premier ou celui à plus forte valorisation).
- Séjour ambulatoire sans acte CCAM identifiable : exclure.
- GHT avec < 200 séjours GM/an : indice instable, à reporter avec mention.
- Hospitalisation de jour (DS=0 mais mode entrée/sortie ≠ 8) : à statuer selon le guide méthodologique en vigueur — historiquement comptée en ambu.

## Utilité

1. **Indicateur CPOM** : objectif d'évolution annuelle du taux de chirurgie ambulatoire négocié avec l'ARS sur la base de l'écart à la cible nationale.
2. **Pilotage virage ambulatoire** : décomposer l'IPA par GM pour identifier les actes où le GHT est très en retard (cataracte, hernie inguinale, cholécystectomie, etc.).
3. **Caractérisation GHT (ScanSanté)** : occupe la caractéristique officielle « croissance des modes de prise en charge ».
4. **Comparaison équitable inter-GHT** : la pondération case-mix neutralise les différences de recrutement chirurgical entre GHT (ortho lourd vs ophtalmologie dominante).
5. **Argument capacitaire** : un IPA positif justifie une réduction des lits d'hospitalisation complète au profit d'UCA ; un IPA négatif chronique alerte sur sous-investissement organisationnel.
6. **Évaluation MSAP** : suivi des GM ciblés par la procédure CNAM — l'IPA décliné sur les 55 GM MSAP est l'indicateur opérationnel de l'efficacité de la MSAP.
7. **Benchmark territorial public/privé** : comparer le GHT à la moyenne nationale et à la part de marché privée locale — orienter les coopérations.

## Sources de Données

- **PMSI MCO** : RSA, table des actes CCAM. Variables `GHM`, `DUREE_SEJOUR`, `MODE_ENTREE`, `MODE_SORTIE`, `CODE_ACTE_CCAM`, `NUM_FINESS_GEO`. Guide méthodologique MCO ATIH.
- **CCAM descriptive à usage PMSI** — version annuelle ATIH. URL : https://www.atih.sante.fr (rubrique CCAM).
- **Liste des gestes marqueurs** :
  - 18 GM Hospi-Diag (P13) : https://hospidiag.atih.sante.fr (indicateur P13)
  - 55 GM MSAP / GDR chirurgie ambulatoire : https://www.scansante.fr/applications/action-gdr-chirurgie-ambulatoire
- **Visuchir** (outil de data-visualisation Assurance Maladie × ATIH) — restitutions complémentaires sur ambulatoire. URL : https://www.scansante.fr/sites/default/files/content/450/visuchir_guide_utilisateur.pdf
- **Référentiel GHT** : ATIH / DGOS.

## Exemple de Valeurs

Ordre de grandeur indicatif (à confirmer sur ScanSanté / Hospi-Diag pour la campagne en cours, non sourcé au chiffre près) :

| Liste | Taux ambu national observé | Cible souvent évoquée |
|---|---|---|
| 18 GM (Hospi-Diag P13) | ~ 85 – 90 % | 90 %+ |
| 55 GM MSAP | ~ 70 – 78 % | seuil MSAP variable par GM |

Plages d'IPA observées :
- IPA > +5 % : GHT en avance significative.
- IPA dans [−5 %, +5 %] : aligné sur référence nationale.
- IPA < −10 % : retard structurel, plan d'action prioritaire.

Source des plages : ordre de grandeur expert et indicateur Hospi-Diag P13. Non sourcé au chiffre près.

## Limites

- **Liste de GM restreinte** : 18 ou 55 actes — ne couvre pas la chirurgie ambulatoire hors liste (gros volume potentiel). Indice non représentatif de la totalité de l'activité ambulatoire.
- **Évolution annuelle des listes** : la composition CCAM des GM évolue (ajouts, retraits, regroupements de codes). Comparaisons pluri-annuelles à corriger via une liste stabilisée.
- **Évolution des taux cibles** : la cible nationale glisse à la hausse chaque année — un IPA stable peut masquer un retard relatif croissant.
- **Cas-mix interne au GM** : un GM peut regrouper des actes de complexité variable ; le mix interne (proportion d'actes lourds dans un GM mixte) n'est pas ajusté par défaut.
- **Effet de seuil** : pour des GM à très haut taux national (cataracte > 95 %), l'IPA en relatif est très sensible à 1-2 points d'écart absolu.
- **Comportement de codage** : un séjour borné en hospitalisation complète mais cliniquement équivalent à de l'ambu peut traduire des contraintes de recrutement (vulnérabilité sociale, isolement) plutôt qu'un défaut d'organisation. Ne pas conclure mécaniquement.
- **Volume minimum** : < 200 séjours GM/an rend l'indice très instable. Préférer une moyenne mobile triennale pour les petits GHT.
- **Effet patientèle** : un GHT en territoire vieillissant/précaire peut avoir un IPA structurellement plus bas pour des raisons médicales légitimes (contre-indications relatives à l'ambu). Indicateur à interpréter en couple avec le profil patientèle.

## Références

- ATIH / CNAM, « Action GDR chirurgie ambulatoire » — 55 gestes MSAP, méthodologie de suivi. URL : https://www.scansante.fr/applications/action-gdr-chirurgie-ambulatoire
- ATIH Hospi-Diag, indicateur **P13** « Taux des 18 gestes marqueurs en chirurgie ambulatoire ». URL : https://hospidiag.atih.sante.fr
- ATIH / Assurance Maladie, outil **Visuchir** — guide utilisateur. URL : https://www.scansante.fr/sites/default/files/content/450/visuchir_guide_utilisateur.pdf
- ATIH, « Caractériser et suivre un GHT avec ScanSanté » — caractéristique officielle « croissance des modes de prise en charge ». URL : https://www.scansante.fr/caracteriser-et-suivre-un-groupement-hospitalier-de-territoire-ght
- HAS, IQSS chirurgie ambulatoire — indicateurs de processus. URL : https://www.has-sante.fr/jcms/c_2807207
- ATIH, CCAM descriptive à usage PMSI (version annuelle). URL : https://www.atih.sante.fr
