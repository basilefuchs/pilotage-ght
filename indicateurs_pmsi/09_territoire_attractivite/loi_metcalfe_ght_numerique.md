# Loi de Metcalfe du GHT Numérique

## Définition

La loi de Metcalfe (Robert Metcalfe, 1980, formalisée par Gilder, 1993) stipule que la **valeur d'un réseau de communication est proportionnelle au carré du nombre de ses membres connectés** : V ∝ n². Avec 2 nœuds, 1 connexion possible ; avec 10 nœuds, 45 connexions ; avec 100 nœuds, 4 950 connexions. La valeur croît donc beaucoup plus vite que le nombre de participants — c'est l'effet de réseau qui explique la domination des plateformes numériques (chaque utilisateur supplémentaire de Facebook augmente la valeur du réseau pour tous les autres).

Appliquée au GHT numérique, la **Loi de Metcalfe du GHT Numérique** (LMGN) mesure le **retour sur investissement des outils de coordination numérique** (DPI partagé, messagerie sécurisée MSSanté, téléexpertise, accès partagé aux résultats de biologie) en quantifiant la valeur des connexions effectives entre producteurs de soins — non pas le nombre d'acteurs nominalement raccordés à un outil, mais le nombre de **paires d'acteurs qui échangent réellement des informations patient**.

L'indicateur central est le **Taux de Connexions Actives** (TCA) : le rapport entre les connexions effectivement utilisées (échanges traçables depuis le PMSI/DCIR) et les connexions théoriquement possibles dans le réseau du GHT. La loi de Metcalfe prédit que chaque acteur supplémentaire effectivement connecté génère une valeur marginale croissante — ce qui justifie d'investir dans l'intégration des acteurs périphériques (médecins de ville, pharmacies, EHPAD) au-delà du périmètre hospitalier strict.

**V_réseau ∝ n_actifs² où n_actifs = nombre d'acteurs avec au moins 1 échange tracé sur 12 mois**

## Calcul

Construction du réseau de coordination numérique observable depuis le PMSI/DCIR :

```
Proxy des connexions actives (échanges traçables sans accès aux logs des outils) :

Connexion de type 1 — Adressage tracé (DCIR ER_PRS_F) :
  → Un médecin A adresse un patient chez le spécialiste B :
    arc A→B si un patient a consulté A puis B dans les 30 jours
    ET si B a réalisé un acte de consultation (non urgence)
  → Proxy d'une coordination organisée (lettre d'adressage probable)

Connexion de type 2 — Prescription-dispensation (DCIR ER_PRS_F + ER_PHA_F) :
  → Médecin A prescripteur, pharmacie B dispensatrice :
    arc A→B si ≥ 10 patients en commun sur 12 mois
  → Proxy d'une relation ville-pharmacie régulière

Connexion de type 3 — Filière MCO→SSR (PMSI MCO + PMSI SSR) :
  → Établissement MCO A transfère vers SSR B :
    arc A→B pondéré par le volume de transferts sur 12 mois
  → Proxy de la coordination institutionnelle inter-établissements

Connexion de type 4 — Co-suivi de patient chronique (DCIR) :
  → Médecin traitant A et spécialiste B partagent ≥ 5 patients ALD
    avec des consultations alternées (A puis B puis A…) sur 12 mois
  → Proxy de co-suivi coordonné (non urgence, récurrent)
```

Calcul du Taux de Connexions Actives (TCA) et de la valeur de réseau :

```
Réseau observé G = (N, E) :
  N = {producteurs de soins actifs sur le territoire} filtrés à ≥ 50 patients/an
  E = {arcs actifs} selon les 4 types de connexions ci-dessus

Connexions théoriques maximales (réseau complet) :
  C_max = n × (n−1) / 2   (pour n = |N| acteurs)

Connexions actives observées :
  C_actives = |E|   (nombre d'arcs distincts avec au moins 1 échange tracé)

Taux de Connexions Actives :
  TCA = C_actives / C_max   ∈ [0 ; 1]
  → TCA faible (<5%) : réseau très fragmenté, la plupart des acteurs
    n'ont pas de relation traçable entre eux
  → TCA moyen (5-15%) : réseau partiellement connecté
  → TCA élevé (>20%) : réseau dense, coordination intensive

Valeur de réseau (indice de Metcalfe normalisé) :
  V_M = C_actives² / C_max²   = TCA²   (normalisé entre 0 et 1)
  → Croît de façon non-linéaire avec n_actifs :
    si TCA passe de 5% à 10%, V_M quadruple (0.0025 → 0.01)

Croissance marginale de la valeur lors de l'intégration d'un acteur supplémentaire :
  ΔV_M = [(C_actives + n_existants) / C_max_nouveau]² − [C_actives / C_max]²
  → Quantifie le gain de valeur réseau lié à l'intégration d'un nouvel acteur
    (EHPAD, cabinet libéral, HAD) dans les outils de coordination du GHT
```

Analyse de la densité de coordination par zone géographique :

```
TCA par bassins de vie (IRIS ou commune) :
  → Calculer TCA localement pour les acteurs du même bassin de vie
  → Identifier les zones avec TCA faible = zones de fragmentation du réseau
    malgré la présence d'acteurs (ils ne se "parlent" pas)

Évolution temporelle :
  ΔV_M(t) = V_M(t) − V_M(t−1 an)
  → ΔV_M > 0 : réseau en expansion (nouveaux acteurs intégrés,
    nouvelles connexions activées)
  → ΔV_M ≈ 0 : stagnation — les outils numériques déployés n'ont pas
    généré de nouvelles connexions effectives
  → Indicateur de résultat du déploiement d'un DPI partagé ou d'une CPTS
```

## Utilité

- **Mesurer le retour réel des investissements numériques** : le déploiement d'un DPI partagé, d'une messagerie MSSanté ou d'un portail de téléexpertise est souvent évalué par le nombre d'utilisateurs enrôlés (métrique de volume) — la LMGN mesure si ces outils ont effectivement créé de nouvelles connexions actives entre acteurs, seul indicateur de valeur réelle ; un outil avec 200 utilisateurs mais aucune connexion nouvelle n'a pas créé de valeur réseau
- **Prioriser les acteurs à intégrer en premier** : la loi de Metcalfe implique que l'intégration d'un acteur bien connecté (hub du réseau — identifiable par sa centralité de betweenness) génère beaucoup plus de valeur marginale que l'intégration d'un acteur périphérique — la LMGN guide la stratégie d'onboarding des outils de coordination en ciblant en priorité les acteurs à fort potentiel de nouvelles connexions
- **Détecter les îlots de non-coordination** : les zones ou spécialités avec TCA très faible malgré la présence de nombreux acteurs sont des îlots où les professionnels agissent en parallèle sans coordination tracée — cibles prioritaires pour les CPTS, les DAC et les conventions de coopération ville-hôpital
- **Évaluer l'impact territorial d'une CPTS** : avant/après la création d'une Communauté Professionnelle Territoriale de Santé, mesurer l'évolution du TCA et de V_M sur le périmètre de la CPTS — la LMGN fournit un indicateur de résultat objectif pour les évaluations de la CNAM et des ARS sur l'efficacité des nouveaux modèles organisationnels
- **Argument pour les projets de territoire** : dans les dossiers de demande de financement (FIR, ONDAM médico-social, fonds numérique Ségur), démontrer que le territoire a un TCA actuellement faible et que le projet proposé vise à l'augmenter — la non-linéarité de la loi de Metcalfe signifie que même un faible gain en TCA génère un gain quadratique en valeur réseau, ce qui justifie économiquement l'investissement

## Sources de Données

- **DCIR ER_PRS_F** : actes médicaux libéraux avec code RPPS du prescripteur et de l'exécutant, NIR du patient, date — pour reconstituer les arcs d'adressage (type 1) et de co-suivi (type 4) entre médecins
- **DCIR ER_PHA_F** : dispensations avec FINESS de la pharmacie et code RPPS du prescripteur — pour les arcs prescription-dispensation (type 2)
- **PMSI MCO RSA + PMSI SSR RHS** : chaînés par NIR crypté — pour les flux de transfert MCO→SSR (type 3) et les co-hospitalisations successives entre établissements
- **IR_BEN_R** : médecin traitant déclaré (RPPS) — nœud structurant du réseau pour chaque patient, permet d'identifier les médecins traitants comme nœuds centraux du réseau de coordination
- **Algorithme de construction de réseau** : Python (networkx), R (igraph) — mêmes outils que pour la centralité de betweenness, les deux indicateurs partagent le même graphe de base et peuvent être calculés simultanément

## Exemple de Valeurs

- **GHT en territoire semi-rural (300 acteurs actifs, n=300)** :
  C_max = 300 × 299 / 2 = 44 850 connexions théoriques
  C_actives avant CPTS = 1 200 arcs actifs → TCA = 2,7% → V_M = 0,07%
  C_actives après CPTS (18 mois) = 2 800 arcs → TCA = 6,2% → V_M = 0,39%
  **ΔV_M = +0,32 points = valeur réseau multipliée par 5,5**

- **GHT urbain dense (800 acteurs actifs)** :
  TCA ≈ 3-6% (beaucoup d'acteurs mais relations fragmentées par spécialité)
  V_M ≈ 0,09-0,36% — paradoxalement moins connecté en valeur relative
  qu'un réseau rural plus petit mais mieux coordiné (effet de sur-densité)

- **Gain marginal d'intégration d'un EHPAD (50 résidents, flux vers 8 médecins traitants)** :
  Nouveaux arcs potentiels = 8 médecins × autres acteurs du réseau = ~80 arcs
  ΔV_M ≈ [(1 200 + 80) / 44 850]² − [1 200 / 44 850]² ≈ +0,025%
  Si 10 EHPAD intégrés simultanément : ΔV_M ≈ +0,28% — effet cumulatif non-linéaire

- **Benchmark national** : TCA moyen des territoires avec CPTS active depuis > 2 ans ≈ 7-12% (données CNAM 2023) vs TCA des territoires sans CPTS ≈ 2-4%

## Limites

- Le PMSI et le DCIR ne tracent que les **échanges médico-économiques** (actes facturés, séjours) — les échanges purement informationnels (message MSSanté sans acte associé, consultation téléphonique non cotée, réunion de concertation pluridisciplinaire) sont invisibles dans les données administratives ; le TCA sous-estime structurellement la connectivité réelle du réseau, surtout pour les soins peu codés
- La **fenêtre de 30 jours** pour définir un arc d'adressage est une convention — une fenêtre trop courte manque les adressages avec délai long (spécialités en tension), une fenêtre trop longue crée des faux positifs (deux consultations fortuitement proches ne reflètent pas une coordination) ; la sensibilité du TCA à ce paramètre doit être testée
- La loi de Metcalfe suppose que toutes les connexions ont la même valeur — hypothèse irréaliste en médecine : une connexion médecin traitant/cardiologue pour un patient insuffisant cardiaque a beaucoup plus de valeur clinique qu'une connexion kiné/ophtalmologue ; une version pondérée (V_M pondéré par la valeur clinique des connexions) est conceptuellement supérieure mais difficile à opérationnaliser sans jugement expert
- La **loi de Metcalfe elle-même est contestée** dans sa forme exacte (n² est peut-être un plafond plutôt qu'une règle) : des travaux récents suggèrent que la valeur croît comme n×log(n) plutôt que n² pour les grands réseaux ; dans le contexte des réseaux de soins territoriaux (n < 1000 acteurs), les deux formules donnent des résultats proches et la distinction est secondaire par rapport aux incertitudes de mesure

## Références

- [Metcalfe R. — Metcalfe's law after 40 years of ethernet, Computer 2013](https://doi.org/10.1109/MC.2013.374) — révision par l'auteur lui-même de sa loi originale
- [Gilder G. — Metcalfe's law and legacy, Forbes ASAP 1993 : première formalisation publique de la loi]
- [Briscoe B. et al. — Metcalfe's law is wrong, IEEE Spectrum 2006](https://doi.org/10.1109/MSPEC.2006.1653003) — critique et révision vers n×log(n)
- [Barnett M.L. et al. — Mapping physician networks with self-reported and administrative data, Health Services Research 2011](https://doi.org/10.1111/j.1475-6773.2011.01262.x)
- [CNAM — Évaluation des CPTS : indicateurs de coordination et de décloisonnement ville-hôpital (rapport 2023)](https://www.ameli.fr/)
- [ANS — Programme Ségur du numérique en santé : indicateurs de déploiement et d'usage des outils de coordination (2022)](https://esante.gouv.fr/)
