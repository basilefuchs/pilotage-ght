# Effet d'une Convention Inter-Établissements par Série Temporelle Interrompue

## Définition

Cet indicateur estime l'**impact causal** d'une convention de coopération entre deux établissements A et B sur leurs flux de patients, par **régression segmentée de série temporelle interrompue** (ITS) : la série mensuelle des flux chaînés de la dyade est modélisée avant et après la date de signature (ou de mise en œuvre effective), et l'effet de la convention se lit dans le saut de niveau et le changement de pente — par rapport à la trajectoire contrefactuelle qu'aurait suivie la dyade sans convention.

L'ITS est le design quasi-expérimental de référence pour évaluer une intervention organisationnelle implémentée à une date précise quand la randomisation est impossible (Bernal, Cummins & Gasparrini 2017). C'est exactement la situation d'une convention : un événement daté (signature, ouverture de consultations avancées, arrivée d'une équipe partagée) censé modifier un flux mesurable en continu dans le PMSI.

Modèle de régression segmentée :

```
Y_t = β₀ + β₁·t + β₂·post_t + β₃·(t − t₀)·post_t + ε_t

Y_t    = flux mensuel de la dyade (adressages A→B du périmètre, ou tout indicateur dyadique)
t      = mois ; t₀ = mois de mise en œuvre ; post_t = 1 si t ≥ t₀
β₂     = changement de niveau immédiat   (effet "marche")
β₃     = changement de pente             (effet "montée en charge")
```

Les quatre fiches dyadiques du projet (`taux_adressage_preferentiel_convention.md`, `indice_reciprocite_flux_dyade.md`, `densite_patientele_partagee_dyade.md`, `../07_parcours_continuite/taux_retrocession_aval_convention.md`) produisent des **constats** ; celle-ci répond à la question des instances : « la convention a-t-elle changé quelque chose, ou le flux aurait-il augmenté de toute façon ? ». Aucun indicateur PMSI standard n'embarque d'inférence causale ; la comparaison naïve avant/après (moyenne N vs N−1) qu'on trouve dans les bilans de convention confond tendance préexistante, saisonnalité et effet propre.

## Calcul

1. **Champ** : PMSI MCO chaîné de A et B (portail ATIH suffisant si l'issue est un flux interne à la dyade ; base nationale si l'issue est un taux avec dénominateur territorial), ≥ 24 mois avant t₀ et ≥ 12 mois après (Bernal et al. recommandent un nombre de points suffisant de part et d'autre ; 8 points par segment est un minimum d'usage).
2. **Choix de l'issue Y** : flux mensuel d'adressages conformes (cf. fiche adressage), en nombre de parcours. Spécifier **a priori** le modèle d'impact attendu (marche, pente, ou les deux) avant de regarder les données — étape clé du protocole ITS.
3. **Estimation** : régression de Poisson (ou quasi-Poisson si surdispersion) pour des comptages mensuels, avec :
   - **Saisonnalité** : termes harmoniques (sin/cos 12 mois) ou indicatrices mensuelles ;
   - **Autocorrélation** : erreurs Newey-West ou modèle ARMA sur résidus ; tester par Durbin-Watson/ACF ;
   - **Offset** éventuel : log de l'activité totale de A (pour neutraliser une variation globale d'activité).
4. **Pseudocode** :

```
serie  = flux mensuel dyade (périmètre conventionné), ≥ 24 mois pré / ≥ 12 mois post
modele = glm(Y ~ t + post + I((t - t0) * post) + harmoniques,
             family = quasipoisson, offset = log(sejours_A))
effet_niveau = exp(β₂) ; effet_pente = exp(β₃)        # rapports de taux
effet_cumule = Σ_post (Ŷ_t − Ŷ_t^contrefactuel)       # parcours attribuables
```

5. **Renforcement par dyade témoin (ITS contrôlée)** : modéliser en parallèle le flux de A vers un établissement comparable à B **non concerné** par la convention ; l'interaction série × groupe contrôle les chocs communs (épidémie, fermeture de lits régionale). C'est l'adaptation recommandée quand un contrôle plausible existe (Bernal et al. 2017).
6. **Conventions** : exclure le mois de t₀ (transition) ; si la mise en œuvre est progressive, modéliser une rampe plutôt qu'une marche ; pré-enregistrer t₀ sur la date de mise en œuvre effective (premières consultations avancées), pas sur la signature administrative.

## Utilité

- **Bilan objectivé pour les instances** : présenter β₂ et β₃ avec IC95 % au comité de suivi de convention et au comité stratégique de GHT — remplace le « +18 % vs l'an dernier » invérifiable des bilans actuels.
- **Chiffrer l'effet cumulé** : nombre de parcours (et valorisation GHS associée) attribuables à la convention depuis t₀ — l'argument économique de la reconduction.
- **Distinguer effet d'annonce et montée en charge** : β₂ sans β₃ = bascule immédiate des adresseurs déjà convaincus ; β₃ sans β₂ = diffusion progressive (typique des conventions reposant sur la confiance inter-équipes) ; ni l'un ni l'autre = convention sans effet.
- **Évaluer les avenants** : ITS à interruptions multiples (un terme par avenant) pour mesurer l'apport marginal de chaque extension du périmètre.
- **Arbitrer entre conventions concurrentes** : à moyens partagés équivalents, comparer les effets estimés de plusieurs conventions du GHT pour prioriser l'animation.
- **Se protéger des fausses attributions** : la dyade témoin évite d'attribuer à la convention un effet dû à un choc commun (départ d'un praticien concurrent, modification tarifaire) — erreur classique des bilans avant/après.

## Sources de Données

- **PMSI MCO chaîné** de A et B : numéro de chaînage anonyme (MAGIC/ANO `[modalités exactes selon documentation ATIH en vigueur, à confirmer]`), FINESS géographique, mois de sortie, GHM/actes du périmètre conventionné, valorisation GHS pour l'effet économique.
- **Convention** : date de signature et date de mise en œuvre effective (t₀), périmètre, avenants datés.
- **Dyade témoin** : flux de A vers un établissement tiers comparable, mêmes variables.
- ≥ 36 mois de série continue, sans changement de version de groupage majeur sur le périmètre (sinon ajouter une indicatrice de campagne).

## Exemple de Valeurs

Ordres de grandeur expert (non sourcés — les effets dépendent entièrement du contexte ; les valeurs servent à calibrer les attentes, pas à comparer) :

- **Convention de recours active** (consultations avancées + circuit d'adressage) : rapport de taux de niveau exp(β₂) = 1,3–2,0, atteint en 6–18 mois.
- **Convention « dormante »** (signature sans moyens) : exp(β₂) et exp(β₃) non distinguables de 1 — résultat fréquent et utile en soi.
- **Puissance** : avec un flux de base < 10 parcours/mois, seuls des effets > +50 % sont détectables ; en deçà, agréger en trimestres ou allonger la série.
- **Lecture des IC** : un IC95 % de exp(β₂) couvrant 1 n'est pas une preuve d'absence d'effet (puissance) — rapporter l'estimation et l'incertitude, pas un verdict binaire.

## Limites

- **Confusion résiduelle** : l'ITS contrôle la tendance et la saisonnalité, pas un événement concomitant à t₀ propre à la dyade (départ d'un PH de A, travaux chez un concurrent) — documenter l'historique local et utiliser la dyade témoin chaque fois que possible.
- **Choix de t₀** : une mise en œuvre étalée diluée dans une marche unique biaise β₂ vers 0 ; préférer le modèle en rampe et analyser en sensibilité (t₀ ± 3 mois).
- **Autocorrélation et surdispersion** : les ignorer produit des IC trop étroits (faux positifs) — corrections systématiques (quasi-Poisson, Newey-West), cf. le tutoriel de référence (Bernal et al. 2017).
- **Séries courtes** : < 8 points par segment, l'estimation de pente est fragile ; ne pas conclure sur une convention de moins d'un an.
- **Effets de version PMSI** : un changement de classification GHM au milieu de la série peut déplacer le périmètre conventionné — vérifier la stabilité des codes et ajouter une indicatrice de campagne tarifaire si besoin.
- **Généralisation** : l'effet estimé est local à la dyade et à sa période ; il ne prédit pas l'effet d'une convention similaire ailleurs.

## Références

- Bernal JL, Cummins S, Gasparrini A. *Interrupted time series regression for the evaluation of public health interventions: a tutorial.* Int J Epidemiol. 2017;46(1):348-355. [DOI](https://doi.org/10.1093/ije/dyw098) — PMID:27283160
- IGAS. *Bilan d'étape des groupements hospitaliers de territoire (GHT).* Mai 2024. [igas.gouv.fr](https://www.igas.gouv.fr/sites/igas/files/2024-05/Bilan%20d%E2%80%99%C3%A9tape%20des%20groupements%20hospitaliers%20de%20territoire%20%28GHT%29.pdf)
- Instruction n° DGOS/FIP3/DSS/SD1A/2025/145 du 9 octobre 2025 relative à l'efficience et à la performance des établissements de santé. [bulletins-officiels.social.gouv.fr](https://bulletins-officiels.social.gouv.fr/instruction-ndeg-dgosfip3dsssd1a2025145-du-9-octobre-2025-relative-la-mise-en-oeuvre-de-la-circulaire-du-premier-ministre-du-23-avril-2025-relative-lefficience-et-la-performance-des-etablissements-de-sante)
- Fiches liées (issues Y candidates) : `taux_adressage_preferentiel_convention.md`, `indice_reciprocite_flux_dyade.md`, `densite_patientele_partagee_dyade.md`, `../07_parcours_continuite/taux_retrocession_aval_convention.md` ; méthode apparentée : `../01_activite_production/indice_resilience_post_perturbation.md`.
