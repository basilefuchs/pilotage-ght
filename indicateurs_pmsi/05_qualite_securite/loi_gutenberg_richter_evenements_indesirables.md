# Loi de Gutenberg-Richter des Événements Indésirables

## Définition

La loi de Gutenberg-Richter (Gutenberg & Richter, 1944) est une loi empirique fondamentale en sismologie : pour une région donnée, le logarithme du nombre de séismes de magnitude supérieure à M est une fonction linéaire décroissante de M :

**log₁₀(N) = a − b × M**

où N est le nombre de séismes de magnitude ≥ M sur une période donnée, a est une constante liée à la sismicité générale de la région, et **b est la pente** — le paramètre le plus informatif. Une valeur b élevée (~1,5) signifie que les petits séismes sont très nombreux par rapport aux grands : le système "se décharge" progressivement via de nombreux micro-événements. Une valeur b faible (~0,5) signifie une accumulation silencieuse d'énergie sans micro-événements préalables — le système est en régime de "séisme silencieux", qui précède souvent un séisme majeur catastrophique.

Transposée aux événements indésirables hospitaliers, la **Loi de Gutenberg-Richter des Événements Indésirables** (LGREI) applique cette logique à la distribution de gravité des incidents : si les événements mineurs (quasi-accidents, incidents sans conséquence) sont nombreux par rapport aux événements graves (complications sévères, décès évitables), la pente b est élevée — signe d'une culture de sécurité mature où les signaux faibles sont détectés et déclarés. Si les événements mineurs sont rares et les événements graves représentent une proportion anormale, b est faible — signe d'une sous-déclaration des incidents mineurs et d'un système en risque d'événement catastrophique.

La LGREI quantifie la **maturité de la culture de déclaration des événements indésirables** et détecte les systèmes à risque de "séisme hospitalier" (événement grave isolé non précédé de signaux faibles).

## Calcul

Construction de l'échelle de gravité des événements indésirables :

```
Échelle de magnitude hospitalière (M) — proxy depuis le PMSI :

  M = 1 : Incident sans conséquence (quasi-accident)
          → Non observable directement dans le PMSI
          → Source : système de déclaration interne (CREX, RMM, fiches EI)

  M = 2 : Complication mineure sans prolongation de séjour
          → DA de complication dans le RSA sans augmentation de DMS
          → Codes CIM-10 de complications (T80-T88 : complications des soins)

  M = 3 : Complication avec prolongation de séjour (+ 1-3 jours vs médiane GHM)
          → DA complication + DMS > médiane GHM + 1σ

  M = 4 : Complication grave avec prolongation significative (> P90 du GHM)
          ou ré-intervention non programmée
          → DA complication + DMS > P90 GHM, ou code CCAM de ré-intervention

  M = 5 : Réadmission en urgence à 7 jours (complication grave post-sortie)
          → Séjour de réadmission MCO < 7j après sortie, mode d'entrée urgences

  M = 6 : Décès inattendu intra-hospitalier (non attendu compte tenu du GHM)
          → MODE_SORTIE = 9 (décès) pour les GHM à mortalité attendue < 1%

Note : les niveaux M=1 à M=2 ne sont pas accessibles depuis le PMSI seul
  (nécessitent les données de déclaration interne) ; M=2 à M=6 sont calculables
  entièrement depuis le PMSI RSA.
```

Ajustement de la loi de Gutenberg-Richter :

```
Pour chaque niveau de magnitude M ∈ {2, 3, 4, 5, 6} :
  N(M) = nombre d'événements de gravité ≥ M sur la période d'analyse (12 mois)

  Calcul des N(M) depuis le PMSI :
    N(≥2) = Nombre de séjours avec au moins 1 DA complication (T80-T88, Y60-Y84)
    N(≥3) = N(≥2) ∩ {DMS > médiane GHM + 1σ}
    N(≥4) = Nombre de réinterventions non programmées (CCAM ré-op)
    N(≥5) = Nombre de réadmissions urgentes à 7j
    N(≥6) = Nombre de décès inattendus

Ajustement linéaire : log₁₀(N(M)) = a − b × M
  → Régression linéaire sur les paires (M, log₁₀(N(M)))
  → b_estimé = −pente de la droite de régression
  → a_estimé = ordonnée à l'origine

Interprétation de b :
  b > 1.2 : distribution saine — nombreux incidents mineurs, peu d'événements graves
             → Culture de sécurité active, les signaux faibles sont capturés et déclarés
  b 0.8-1.2 : distribution standard
  b < 0.8  : distribution préoccupante — manque d'incidents mineurs déclarés
             par rapport aux événements graves
             → Soit sous-déclaration massive des incidents mineurs
             → Soit système en accumulation silencieuse de risque
  b < 0.5  : alarme — la proportion d'événements graves est anormalement élevée
             → Investigation systémique recommandée
```

Indicateur de sous-déclaration (ISD) :

```
b_attendu ≈ 1.0 dans un système de sécurité mature (valeur empirique
  issue des études sur les systèmes à haute fiabilité : aviation, nucléaire)

ISD = (b_attendu − b_observé) / b_attendu × 100   (en %)
  ISD > 20% : sous-déclaration probable des incidents mineurs
  ISD > 40% : sous-déclaration sévère — les données PMSI ne capturent pas
               la base de la pyramide des incidents

Ratio N(M≥2) / N(M≥5) :
  → Dans un système bien déclarant : N(M≥2) / N(M≥5) ≈ 10-30
    (pour chaque réadmission urgente, 10-30 complications mineures sont tracées)
  → Ratio < 5 : base de pyramide trop étroite → sous-déclaration
  → Comparer ce ratio entre services/établissements du GHT
```

## Utilité

- **Évaluer la maturité de la culture de sécurité d'un service** : la pente b est un indicateur systémique de la capacité du service à détecter et déclarer ses signaux faibles — un b faible n'indique pas nécessairement une mauvaise qualité de soins, mais révèle une pyramide d'incidents tronquée en bas, signe d'une culture de déclaration immature ou d'une sous-codification des complications dans le PMSI
- **Détecter les services à risque de "séisme hospitalier"** : à l'instar de la sismologie où un b faible précède les grands séismes, un service avec peu d'incidents mineurs et des événements graves isolés est un système où l'énergie s'accumule sans décharge progressive — le prochain événement grave peut survenir sans signal précurseur ; les CREX et RMM de ces services doivent être renforcés
- **Benchmarking de la déclaration entre établissements du GHT** : comparer la pente b entre établissements pour le même type de service — un établissement avec b = 1,4 a une culture de déclaration nettement plus mature qu'un établissement avec b = 0,6, même si leurs taux d'événements graves sont comparables ; identifier les bonnes pratiques de l'établissement à b élevé pour les diffuser
- **Suivi de l'impact des programmes qualité** : après un programme de sensibilisation à la déclaration des quasi-accidents ou la mise en place d'un CREX pluridisciplinaire, mesurer l'évolution de b — un b croissant dans le temps est l'indicateur que la culture de sécurité progresse, indépendamment de l'évolution des événements graves
- **Outil de dialogue CME/CSIRMT sur la culture sécurité** : la représentation graphique de la droite de Gutenberg-Richter (courbe de fréquence-magnitude) est pédagogiquement accessible pour les instances qualité — elle visualise intuitivement si la pyramide des incidents est en bonne santé ou tronquée, sans nécessiter de statistiques complexes

## Sources de Données

- **PMSI MCO RSA** : codes CIM-10 en DA pour les complications (T80-T88 complications des soins, Y60-Y84 effets adverses des actes médicaux, Y40-Y59 effets adverses des médicaments), actes CCAM de ré-intervention, DMS pour les niveaux M=2 à M=4 — calcul entièrement automatisable depuis les extractions RSA standard
- **PMSI MCO RSA (chaînage)** : réadmissions à 7j (niveau M=5) via chaînage des séjours consécutifs d'un même patient (NIR crypté) ; décès intra-hospitaliers (MODE_SORTIE = 9) pour le niveau M=6
- **Système de déclaration interne** (e-Signalement, fiche EI papier, OSIRIS) : niveaux M=1 et M=2 (quasi-accidents, incidents sans trace PMSI) — complément indispensable pour construire la base de la pyramide ; sans accès au système de déclaration interne, la loi ne peut être ajustée que sur M=2 à M=6
- **Référentiel des PSI (Patient Safety Indicators)** AHRQ : codage standardisé des complications évitables depuis les données administratives — enrichit la définition des niveaux M=2 à M=4 avec une méthodologie validée internationalement

## Exemple de Valeurs

- **Service de chirurgie digestive (données 12 mois, N=420 séjours)** :
  N(≥2) = 52 complications mineures codées en DA
  N(≥3) = 21 séjours avec DMS allongée
  N(≥4) = 8 ré-interventions
  N(≥5) = 4 réadmissions urgentes à 7j
  N(≥6) = 1 décès inattendu
  Ajustement : a = 3,42, **b = 0,96** (p_fit = 0,02, R² = 0,97)
  → Distribution saine, pyramide cohérente

- **Service de médecine interne (même période, N=380 séjours)** :
  N(≥2) = 8 complications codées (très peu)
  N(≥3) = 5, N(≥4) = 3, N(≥5) = 3, N(≥6) = 2
  Ajustement : a = 2,1, **b = 0,37** — distribution anormalement plate
  ISD = (1,0 − 0,37) / 1,0 × 100 = **63% de sous-déclaration estimée**
  Ratio N(≥2)/N(≥5) = 8/3 = 2,7 (très faible, norme ≈ 10-30)
  → La base de la pyramide est quasi-absente — soit sous-codage PMSI massif
    des complications mineures, soit culture de déclaration à renforcer

- **Évolution temporelle après programme CREX** :
  Service cardiologie : b = 0,51 (2021) → b = 0,78 (2022) → b = 1,12 (2023)
  → Programme CREX + sensibilisation à la déclaration des quasi-accidents :
    la base de pyramide se reconstruit progressivement sur 2 ans

- **Comparaison entre établissements du GHT pour les services de gériatrie** :
  Établissement A : b = 1,18 (culture déclaration mature)
  Établissement B : b = 0,44 (sous-déclaration massive probable)
  → Audit croisé et transfert de bonnes pratiques justifiés

## Limites

- Le PMSI ne capture que les **événements ayant généré un acte ou un code diagnostique** — les quasi-accidents sans conséquence (M=1) et de nombreuses complications mineures (M=2) ne sont pas tracés dans les RSA si les codeurs ne les saisissent pas en DA ; la pente b calculée depuis le PMSI seul est structurellement sous-estimée, car la base de la pyramide est partiellement invisible
- La **qualité du codage des complications** en DA varie fortement entre établissements et entre codeurs : certains services codent systématiquement toutes les complications, d'autres ne codent que les complications qui ont modifié la prise en charge ; un b faible peut refléter un sous-codage PMSI plutôt qu'une sous-déclaration d'incidents réels — la distinction nécessite un audit de codage
- L'ajustement de la droite de Gutenberg-Richter sur seulement 5 niveaux de magnitude (M=2 à M=6) est peu robuste statistiquement — l'incertitude sur b peut être large, surtout pour les services à faible volume où N(M=5) et N(M=6) sont souvent inférieurs à 5 ; regrouper plusieurs services ou plusieurs années pour améliorer la puissance statistique
- La **valeur b_attendu = 1.0** utilisée comme référence est empruntée des systèmes industriels à haute fiabilité — sa transposabilité directe au milieu hospitalier n'est pas démontrée empiriquement ; des études de calibration sur de larges cohortes PMSI françaises seraient nécessaires pour établir un b_référence propre au contexte hospitalier français

## Références

- [Gutenberg B., Richter C.F. — Frequency of earthquakes in California, Bulletin of the Seismological Society of America 1944 : article fondateur de la loi fréquence-magnitude]
- [Bak P. — How Nature Works: The Science of Self-Organized Criticality, Copernicus 1996 : généralisation des lois de puissance aux systèmes complexes]
- [Heinrich H.W. — Industrial Accident Prevention, McGraw-Hill 1931 : pyramide de Heinrich (précurseur de la relation incidents mineurs / accidents graves)]
- [Reason J. — Managing the Risks of Organizational Accidents, Ashgate 1997 : modèle du "fromage suisse", culture de sécurité et signaux faibles]
- [Leveson N.G. — Engineering a Safer World: Systems Thinking Applied to Safety, MIT Press 2011 : approche systémique des accidents et accumulation silencieuse de risque]
- [HAS — Retour d'expérience sur les événements indésirables graves (CREX, RMM) : guide méthodologique (2021)](https://www.has-sante.fr/)
