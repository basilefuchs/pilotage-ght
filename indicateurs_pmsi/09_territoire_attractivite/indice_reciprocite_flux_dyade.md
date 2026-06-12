# Indice de Réciprocité des Flux d'une Dyade d'Établissements

## Définition

L'indice de réciprocité mesure l'équilibre des flux de patients chaînés entre deux établissements A et B liés par une convention de coopération, sur 12 mois glissants. Il transpose au niveau dyadique la **réciprocité des graphes orientés pondérés** : dans un réseau de patient-sharing, un lien parfaitement réciproque (A envoie autant qu'il reçoit de B) a une valeur 1, un lien totalement unidirectionnel une valeur 0. La réciprocité fait partie des indicateurs de structure utilisés pour analyser les réseaux de partage de patients construits sur bases de remboursement (Ishikawa et al. 2024 ; Barnett et al. 2012).

Formule symbolique :

```
R = 2 × min(F_AB, F_BA) / (F_AB + F_BA)            ∈ [0 ; 1]

F_AB = patients chaînés avec séjour à A puis séjour à B à ≤ 30 jours (transferts + adressages)
F_BA = idem en sens inverse

Solde directionnel : S = (F_AB − F_BA) / (F_AB + F_BA)   ∈ [−1 ; +1]
```

R répond à une question que les indicateurs existants ne posent pas : la convention est-elle un **partenariat ou une captation** ? `indice_herfindahl_concentration_flux_patients.md` mesure la concentration des destinations d'un seul établissement ; `centralite_betweenness_ght_reseau_soins.md` positionne le GHT dans le réseau régional ; aucun ne caractérise la symétrie d'un lien bilatéral. Or c'est la première inquiétude d'un conseil de surveillance d'un CH signant avec un CHU : « allons-nous devenir un simple bassin de drainage ? ». La littérature récente sur les centres receveurs montre que les flux entrants se concentrent fortement (prévalence de patients transférés entrants de 0 à 47 % selon les hôpitaux américains — Mesfin et al. 2026), justifiant un suivi explicite de l'asymétrie.

## Calcul

1. **Champ** : PMSI MCO national chaîné (extensible SMR/HAD si la convention couvre l'aval), 12 mois glissants ou année civile.
2. **Définition d'un flux A→B** : couple de séjours chaînés du même patient, séjour 1 à A puis séjour 2 à B, avec délai inter-séjours ≤ 30 jours. Inclut les transferts directs (modes de sortie/entrée mutation ou transfert `[valeurs exactes selon guide ATIH en vigueur, à confirmer]`) et les réhospitalisations rapprochées. Compter en patients ou en couples de séjours (préciser la convention retenue ; les deux versions sont utiles).
3. **Pseudocode** :

```
flux(X, Y) = n(couples chaînés : séjour à X puis séjour à Y, délai ≤ 30 j)

F_AB = flux(A, B) ; F_BA = flux(B, A)
R = 2 * min(F_AB, F_BA) / (F_AB + F_BA)    # non calculé si F_AB + F_BA < 60
S = (F_AB - F_BA) / (F_AB + F_BA)
```

4. **Conventions** : si F_AB + F_BA = 0, R non défini (pas de lien) ; un même patient peut contribuer aux deux sens (parcours aller-retour : il alimente alors la réciprocité, ce qui est le comportement voulu — l'aller-retour est la coopération idéale).
5. **Indicateurs dérivés** :
   - **Réciprocité valorisée** R€ : remplacer les effectifs par les valorisations GHS des séjours receveurs — détecte le cas où B reçoit les séjours lourds et renvoie les séjours légers (R volumique équilibré, R€ asymétrique) ;
   - **R par filière** (découpage du périmètre conventionné) ;
   - **Décomposition de S par CMD** : où se fabrique l'asymétrie.

## Utilité

- **Négociation et renégociation de convention** : objectiver l'équilibre du partenariat devant les instances des deux établissements ; une cible de R peut figurer dans la convention.
- **Vigie « aspirateur d'activité »** : un R qui se dégrade année après année au profit du même sens (S → ±1) documente une captation progressive — argument factuel pour le comité stratégique de GHT.
- **Distinguer asymétrie voulue et subie** : une convention de recours pur (proximité → plateau technique) a un S structurellement positif ; la combinaison avec `../07_parcours_continuite/taux_retrocession_aval_convention.md` distingue le recours avec retour (asymétrie de R mais rétrocession élevée) de la captation sèche.
- **Croiser volume et valorisation** : R volumique stable avec R€ qui chute = le partenaire renvoie l'activité non rentable et garde la lourde — signal précoce invisible dans les volumes.
- **Cartographier les dyades du GHT** : matrice R/S de tous les couples d'établissements membres ; les liens à fort volume et faible réciprocité sont les zones de tension du projet médical partagé.
- **Suivi des équipes médicales partagées** : une équipe de territoire fonctionnelle doit faire monter R (les patients circulent dans les deux sens selon le plateau requis), pas seulement le volume.

## Sources de Données

- **PMSI MCO national chaîné** : numéro de chaînage anonyme (MAGIC/ANO `[modalités exactes selon documentation ATIH en vigueur, à confirmer]`), FINESS géographique des deux établissements, dates/délais inter-séjours, modes d'entrée et de sortie, GHM et valorisation GHS (pour R€).
- **Référentiels** : FINESS (entités géographiques de la dyade) ; tarifs GHS de campagne pour la version valorisée.
- Les deux sens du flux étant par construction dans les bases des deux signataires, l'indicateur est calculable sur le portail ATIH sans base nationale si l'on se restreint aux séjours de A et B.

## Exemple de Valeurs

Ordres de grandeur expert (non sourcés — pas de restitution nationale équivalente) :

- **Dyade CH ↔ CH de taille comparable** (conventions de spécialités croisées) : R = 0,5–0,9.
- **Dyade CH ↔ CHU** (convention de recours) : R = 0,1–0,4 en volume ; la lecture se fait alors surtout sur la tendance de R et sur la rétrocession d'aval.
- **Alerte** : baisse de R > 0,15 sur deux ans à volume total stable ou croissant ; ou divergence R volumique / R€ > 0,2.
- **Seuil de calcul** : ne pas interpréter sous 60 couples chaînés/an sur la dyade.

## Limites

- **Une asymétrie peut être conforme à la convention** : R n'est pas une note — il se lit contre la cible du document contractuel (recours pur, spécialités croisées, filière d'aval) ; publier R avec S et la rétrocession, jamais seul.
- **Sensibilité à la fenêtre** : 30 jours capte transferts et suites immédiates ; une fenêtre longue (90 j) mélange coopération et nomadisme spontané. Tester la robustesse sur 15/30/90 jours.
- **Comptage patients vs séjours** : les patients à séjours répétés (séances exclues recommandé : CMD 28) peuvent dominer le flux ; exclure les séances et présenter les deux comptages.
- **Petits volumes** : R est instable sur les dyades à faible flux ; agréger 2–3 ans ou ne suivre que les dyades dépassant le seuil.
- **Chaînage** : ~1–2 % de clés défaillantes ; un différentiel de qualité de chaînage entre A et B biaise S.
- **Pas d'information sur la pertinence clinique** : R décrit la circulation, pas le bénéfice patient (la littérature montre que le transfert peut améliorer le pronostic — Ranasinghe et al. 2015) ; le pilotage par R doit rester organisationnel.

## Références

- Ishikawa T, Kako A, Yoshimoto H, Hattori J, Goda K, Mitsutake N. *Analyzing Patient-Sharing Network Using an Administrative Claim Database in Japan.* Stud Health Technol Inform. 2024;310:1126-1130. [DOI](https://doi.org/10.3233/SHTI231140) — PMID:38269990
- Barnett ML, Christakis NA, O'Malley J, Onnela JP, Keating NL, Landon BE. *Physician patient-sharing networks and the cost and intensity of care in US hospitals.* Med Care. 2012;50(2):152-160. [DOI](https://doi.org/10.1097/MLR.0b013e31822dcef7) — PMID:22249922
- Mesfin N, Ingraham NE, Langworthy B, Dudley RA, Pendleton KM. *National Retrospective Cohort Study Assessing Association of Hospital Transfer-In Prevalence With Hospital Outcomes.* Chest. 2026. [DOI](https://doi.org/10.1016/j.chest.2026.03.043) — PMID:42036067
- Ranasinghe I, Barzi F, Brieger D, Gallagher M. *Long-term mortality following interhospital transfer for acute myocardial infarction.* Heart. 2015;101(13):1032-1040. [DOI](https://doi.org/10.1136/heartjnl-2014-306966) — PMID:25736049
- Fiches liées : `taux_adressage_preferentiel_convention.md` (effectivité), `densite_patientele_partagee_dyade.md` (partage de files actives), `../07_parcours_continuite/taux_retrocession_aval_convention.md` (clause de retour), `indice_herfindahl_concentration_flux_patients.md`, `centralite_betweenness_ght_reseau_soins.md`.
