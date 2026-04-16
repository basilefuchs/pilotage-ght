# Taux de Croissance de l'Activité Trimestrielle par CMD

## Définition

Le taux de croissance de l'activité trimestrielle (TCAT) mesure la variation relative du nombre de séjours MCO entre deux trimestres calendaires identiques d'années consécutives, décomposée par CMD (Catégorie Majeure de Diagnostics). Il capture la **dynamique d'évolution de l'activité** par spécialité — information qualitativement différente du volume absolu fourni par les indicateurs `nombre_sejours` ou `activite_mco`, qui sont des stocks sans dimension temporelle.

TCAT(c, T, n) = [ N(c, T, n) − N(c, T, n−1) ] / N(c, T, n−1)

où :
- c : CMD (code sur 2 caractères, extrait des 2 premiers caractères du GHM)
- T ∈ {T1, T2, T3, T4} : trimestre calendaire (T1 = janv-mars, T2 = avr-juin, T3 = juil-sept, T4 = oct-déc)
- n : année courante, n−1 : année précédente
- N(c, T, n) : nombre de séjours MCO de la CMD c au trimestre T de l'année n

La comparaison à **trimestre identique** (n vs n−1, même trimestre) neutralise les effets saisonniers structurels inhérents à l'activité hospitalière (suractivité hivernale en médecine, suractivité estivale en orthopédie). La comparaison trimestrielle est plus sensible aux ruptures que le taux annuel : elle détecte des signaux faibles à l'échelle de quelques semaines.

Pour une vision stratégique pluriannuelle, le **Taux de Croissance Annuel Moyen** (TCAM) est dérivé sur K années :

TCAM(c, K) = [ N(c, T_ref, n) / N(c, T_ref, n−K) ]^(1/K) − 1

La valeur de référence nationale est disponible via les données PMSI agrégées ATIH (ScanSanté, module évolution d'activité), ce qui permet de calculer un **écart de dynamique** entre l'établissement et la tendance nationale, signal plus informatif que la croissance brute.

## Calcul

Source : PMSI MCO RSA — variables date d'entrée (pour extraction de l'année et du trimestre), GHM (6 caractères pour dériver la CMD), FINESS géographique.

```
Population : tous les séjours MCO sur N années consécutives (minimum N = 2 pour TCAT,
             N = 4 recommandé pour TCAM stable), hors séjours avec GHM erreur (code 90xxx)

Étape 1 — Extraction des dimensions temporelles et cliniques :
  annee    = year(date_entree)
  trimestre = case
                when month(date_entree) in (1,2,3)   then 'T1'
                when month(date_entree) in (4,5,6)   then 'T2'
                when month(date_entree) in (7,8,9)   then 'T3'
                when month(date_entree) in (10,11,12) then 'T4'
              end
  cmd      = substr(ghm, 1, 2)       -- 2 premiers caractères du GHM
  -- Exclure CMD 90 (séjours erreur) et CMD 28 (séances de dialyse/chimio si hors périmètre)

Étape 2 — Agrégation par cellule (FINESS, CMD, trimestre, année) :
  N(FINESS, cmd, trimestre, annee) = count(séjours)

Étape 3 — Calcul du TCAT (comparaison n vs n−1, même trimestre) :
  Pour chaque (FINESS, cmd, trimestre) :
    TCAT = (N_annee_n − N_annee_n-1) / N_annee_n-1
    Convention : si N_annee_n-1 = 0 → TCAT = NA (non calculable, croissance ex-nihilo)
    Convention : si N_annee_n-1 < 30 → TCAT = flag "volume insuffisant" (instabilité statistique)

Étape 4 — Calcul du TCAM sur K années (K = 3 recommandé) :
  TCAM(cmd, K) = (N_annee_n / N_annee_n-K)^(1/K) − 1
  -- Utiliser la même période calendaire (même trimestre de référence)
  -- pour neutraliser les effets saisonniers dans le TCAM

Étape 5 — Écart vs tendance nationale :
  TCAT_national(cmd, T, n) = taux de croissance national ATIH pour la même cellule
                              (source : ScanSanté ou publication ATIH)
  Ecart_benchmark = TCAT_etab − TCAT_national
  -- Ecart > 0 : croissance supérieure au national (attractivité croissante)
  -- Ecart < 0 : sous-dynamique relative (perte de parts de marché ou réorganisation)
```

Indicateurs dérivés :

```
Accélération (2ème dérivée) :
  Accel(cmd, T, n) = TCAT(cmd, T, n) − TCAT(cmd, T, n−1)
  Accel > 0 : croissance s'accélère
  Accel < 0 : croissance ralentit ou décroissance s'amplifie

Contribution CMD à la croissance globale :
  Contrib(cmd, T, n) = [N(cmd, T, n) − N(cmd, T, n−1)] / N_total_etab(T, n−1)
  -- Permet d'identifier quelle CMD tire ou plombe la croissance globale

Indice de croissance base 100 :
  IC(cmd, T, n) = N(cmd, T, n) / N(cmd, T, n_ref) × 100
  -- Suivre l'évolution depuis une année de référence (ex : 2019 pré-COVID)
```

## Utilité

- **Détecter en temps réel les ruptures d'activité** : un TCAT de −25 % sur la CMD 08 (orthopédie) au T3 d'une année signale immédiatement une anomalie (fermeture estivale non prévue, départ de chirurgien, problème capacitaire) — l'alerte est émise au trimestre T+1 sans attendre la clôture annuelle, ce que les indicateurs de volume annuels ne permettent pas
- **Piloter l'exécution du projet médico-soignant partagé (PMSP) du GHT** : chaque axe de développement du PMSP se traduit en cible de TCAM par CMD — le suivi trimestriel permet de vérifier l'adhérence à la trajectoire et de déclencher des actions correctives en cours d'année plutôt qu'au bilan annuel
- **Arbitrer les investissements capacitaires et RH** : une CMD avec TCAM > +5 %/an sur 3 ans est un signal de tension justifiant l'ouverture de lits supplémentaires ou le recrutement ; une CMD avec TCAM < −3 %/an sur 3 ans interroge sur le maintien d'une filière ou une réorientation vers l'ambulatoire
- **Comparer les dynamiques intra-GHT** : dans un GHT, deux établissements couvrant les mêmes CMDs avec des TCAT divergents peuvent signaler un transfert de flux inter-établissements non piloté — identifier ces redistributions de patientèle est structurant pour la gouvernance territoriale
- **Distinguer l'effet volume de l'effet casemix** : croisé avec l'évolution du CMI ou de l'`indice_lourdeur_cas`, le TCAT permet de décomposer la croissance de recettes entre croissance volumique (plus de séjours) et croissance en complexité (mêmes volumes mais cas plus lourds)
- **Neutraliser l'effet COVID dans les analyses pluriannuelles** : en excluant 2020-2021 du calcul du TCAM ou en utilisant 2019 comme base 100, le TCAT sur trimestres identiques fournit une tendance structurelle non contaminée par la perturbation pandémique

## Sources de Données

- **PMSI MCO RSA** : champ `GHM` (6 caractères), champ `date_entree` (ou `mois_entree` + `annee_entree` selon le format d'extraction), FINESS géographique — extraction par vague trimestrielle ou fichier annuel avec recodage des trimestres
- **Référentiel CMD ATIH** : table de correspondance GHM → CMD (2 premiers caractères du GHM) → libellé CMD — disponible dans le guide méthodologique MCO ATIH, version en vigueur
- **ScanSanté (ATIH)** : données nationales agrégées d'évolution d'activité par CMD et par trimestre, utilisées comme référence pour le calcul des écarts de benchmark — accessible sur le portail ScanSanté module "Évolution d'activité"
- **DREES — Panorama des établissements de santé** : données de cadrage annuel sur les évolutions nationales d'activité MCO, utiles pour valider la cohérence des tendances observées

## Exemple de Valeurs

Ordres de grandeur observés sur le PMSI MCO français hors période COVID :

| Contexte | TCAT ou TCAM typique |
|---|---|
| Croissance "normale" activité MCO nationale | +1 % à +3 %/an (tendance structurelle 2015-2019) |
| Rebond post-COVID (2022 vs 2021) | +8 % à +15 % selon CMD et type d'établissement |
| Déclin chirurgie conventionnelle (substitution ambulatoire) | −3 % à −8 %/an (CMD 08, CMD 04 sur HC) |
| Croissance CMD oncologie (28 — séances) | +4 % à +7 %/an (tendance structurelle longue) |
| Fermeture temporaire d'un service (chirurgie estivale) | −30 % à −60 % sur le trimestre concerné |
| Ouverture d'une nouvelle unité | +20 % à +100 % le trimestre d'ouverture (base faible) |

Seuils d'alerte opérationnels :
- **|TCAT| > 10 %** sur une CMD à fort volume (> 200 séjours/trimestre) : déclencher une analyse causale (codage, flux, fermeture, restructuration)
- **TCAM < −2 %/an sur 3 ans** pour une CMD non expliquée par une stratégie délibérée : signal d'érosion structurelle à inscrire à l'ordre du jour du directoire médical
- **Écart benchmark > +5 points vs national** sur une CMD : gain de parts de marché à analyser (attractivité, redirection de flux) et à défendre auprès de l'ARS
- Exclure du calcul du TCAM les années 2020 et 2021 si la fenêtre d'analyse englobe la période COVID (biais de −20 % à −30 % sur la plupart des CMDs en 2020)

## Limites

- **Sensibilité aux changements de codage** : une amélioration du taux de groupage ou une correction de pratiques de codage (ex : meilleur codage des DP) peut générer un TCAT positif sans activité réelle supplémentaire — croiser avec l'évolution du taux d'erreur de groupage (GHM 90xxx) pour détecter les artefacts
- **Effet des fermetures temporaires et des changements de capacités** : une fermeture de service pour travaux génère un TCAT négatif structurel suivi d'un rebond artificiel l'année suivante — ces événements doivent être annotés dans le tableau de bord pour éviter des interprétations erronées par les décideurs
- **Instabilité statistique sur petits volumes** : un TCAT calculé sur moins de 30 séjours par trimestre est soumis à une très haute variabilité stochastique (intervalle de confiance de ±50 % ou plus) — recommander un seuil minimal de 50 séjours/trimestre avant interprétation, 100 séjours pour les comparaisons inter-établissements
- **Non comparabilité inter-annuelle sur changements de version GHM** : un passage de classification (v11 → v12) peut reventiler des séjours entre CMDs, générant des ruptures de série — calculer le TCAT sur une version de classification stable ou sur des regroupements plus larges (grandes familles de CMDs) lors des années de transition
- **Trimestre T incomplet** : lors d'une extraction en cours de trimestre (ex : extraction en février sur T4 de l'année en cours), le TCAT sera mécaniquement négatif par sous-numération — s'assurer de la complétude des périodes comparées, ou travailler sur des trimestres clôturés avec remontées PMSI validées

## Références

- [INSEE — Taux de croissance et TCAM, guide méthodologique des indices économiques : fondements du taux de variation et du taux de croissance annuel moyen](https://www.insee.fr/fr/metadonnees/definition/c1729)
- [ATIH — Rapport annuel d'activité MCO : évolution des séjours par CMD, données de tendance nationales](https://www.atih.sante.fr/)
- [DREES — Panorama des établissements de santé 2023 : données de cadrage sur l'évolution nationale de l'activité hospitalière MCO](https://www.drees.solidarites-sante.gouv.fr/)
- [Cylus J., Anderson M., Nolte E. — A framework for thinking about hospital performance, Health Policy 2016 : positionnement des indicateurs dynamiques dans le pilotage de la performance hospitalière](https://doi.org/10.1016/j.healthpol.2016.04.006)
- [Veillard J. et al. — A performance assessment framework for hospitals: the WHO regional office for Europe PATH project, International Journal for Quality in Health Care 2005 : cadre de suivi de la dynamique d'activité hospitalière](https://doi.org/10.1093/intqhc/mzi072)
