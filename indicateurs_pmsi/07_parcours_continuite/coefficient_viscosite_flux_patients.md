# Coefficient de Viscosité des Flux Patients

## Définition
Le **coefficient de viscosité des flux patients** mesure la résistance au mouvement des patients entre les différents segments de soins — exactement comme la viscosité en physique des fluides quantifie la résistance d'un fluide à l'écoulement sous l'effet d'une contrainte. Un fluide visqueux s'écoule lentement et forme des bouchons ; un flux patient visqueux produit des délais de transition, des patients bloqués en MCO faute de place en SSR, des passages aux urgences qui ne débouchent pas sur une hospitalisation en temps utile, ou des sorties retardées faute d'aval. Le coefficient est calculé depuis le PMSI par l'analyse des délais et taux de blocage à chaque point de transition critique du parcours hospitalier (urgences → MCO, MCO → SSR, MCO → HAD, MCO → domicile, MCO → EHPAD). Un coefficient élevé signale un système à haute résistance interne où les patients « s'accumulent » aux interfaces — reflet d'un manque de coordination, d'une pénurie de capacités aval ou d'une organisation cloisonnée. À l'inverse, un coefficient faible indique des flux fluides, synonymes de parcours coordonnés et de capacités bien dimensionnées.

L'analogie physique est formalisée par la loi de Hagen-Poiseuille, qui relie le débit d'un fluide dans un tube à sa viscosité, à la pression motrice et au diamètre du conduit. Appliquée au flux patient, la pression motrice correspond à la demande de soins (entrées), le diamètre du conduit correspond à la capacité disponible à l'aval, et la viscosité correspond aux frictions organisationnelles et logistiques qui ralentissent les transitions.

## Calcul

### 1. Viscosité de transition (ν_t) pour chaque interface

```
ν_t = Délai médian de transition (jours) × Taux de blocage à l'interface (%)

  → Délai de transition = Date d'entrée dans le segment aval − Date de sortie du segment amont
     (ex : date d'entrée SSR − date de sortie MCO, calculé par chaînage PMSI)
  → Taux de blocage = proportion de patients n'ayant pas obtenu le segment aval
     dans le délai cible, parmi ceux pour lesquels ce segment était indiqué

  → ν_t = 0 : pas de friction, transition instantanée
  → ν_t élevé : forte résistance organisationnelle à cette interface
```

### 2. Coefficient de viscosité global (CVP)

```
CVP = Σ [w_i × ν_t(i)] / Σ w_i

  → i = interface considérée (urgences→MCO, MCO→SSR, MCO→HAD,
         MCO→domicile avec suivi, MCO→EHPAD, SSR→domicile)
  → w_i = poids de l'interface, défini par le volume de patients concernés
           (pondération par le nombre de séjours impliqués)
  → CVP en unités composites (jours × %)

Interfaces et délais cibles de référence :
  - Urgences → MCO       : délai cible ≤ 0,5 jour (< 12h)
  - MCO → SSR            : délai cible ≤ 3 jours
  - MCO → HAD            : délai cible ≤ 2 jours
  - MCO → EHPAD          : délai cible ≤ 7 jours
  - MCO → domicile + HAD : délai cible ≤ 2 jours
  - SSR → domicile        : délai cible ≤ 5 jours
```

### 3. Indice de viscosité standardisé (CVP-s)

```
CVP-s = CVP établissement / CVP médian national (ou régional)

  → CVP-s = 1,0 : viscosité dans la norme
  → CVP-s > 1,5 : viscosité critique, friction significative
  → CVP-s < 0,7 : flux très fluides (bon signal ou sous-recours à l'aval)
```

### 4. Profil de viscosité par interface

```
Profil vectoriel : V = [ν_urgences→MCO, ν_MCO→SSR, ν_MCO→HAD,
                        ν_MCO→EHPAD, ν_SSR→domicile]

  → Permet d'identifier les interfaces à haute résistance spécifique
    sans se limiter à un score agrégé
```

**Précisions méthodologiques** :
- Le chaînage des séjours pour le calcul des délais inter-segments est réalisé par le NIR crypté dans le SNDS (fragmentation hospitalière) ou par les identifiants patients dans le DPI pour le niveau local intra-GHT.
- Le taux de blocage est estimé par la proportion de séjours MCO avec une durée prolongée liée à l'attente d'aval (mode de sortie vers SSR/HAD/EHPAD avec DMS > moyenne GHM + écart-type).
- La pondération w_i est recalculée chaque année pour tenir compte de l'évolution du casemix.

## Utilité

- **Identification des goulots d'étranglement du parcours** : le profil vectoriel de viscosité localise précisément les interfaces problématiques — une viscosité élevée sur l'interface MCO→SSR indique un manque de capacités SSR ou une coordination insuffisante, indépendamment des autres interfaces.
- **Pilotage des conventions intra-GHT** : le CVP est un argument objectif pour réorganiser les filières de soins entre établissements du GHT — si la viscosité MCO→SSR est élevée, cela justifie la création d'une convention de transfert garantie ou l'augmentation des capacités SSR sur l'établissement partenaire.
- **Quantification de l'impact des "bed blockers"** : les patients en attente d'aval (EHPAD, HAD, SSR) occupent des lits MCO et créent une résistance systémique — le CVP mesure cet effet de manière agrégée et comparable entre établissements.
- **Évaluation des politiques d'amélioration** : mesurer le CVP avant et après le déploiement d'une cellule de gestion des lits, d'un outil de coordination ou d'une augmentation de la capacité SSR pour quantifier le gain réel de fluidité.
- **Benchmarking inter-GHT** : le CVP-s permet de comparer la fluidité des parcours entre GHT de taille et de casemix différents, en neutralisant l'effet volume.
- **Corrélation avec la performance financière** : une viscosité élevée sur l'interface MCO→aval allonge la DMS et génère des journées en dessous du seuil bas de la borne de la T2A — le CVP est donc corrélé au manque à gagner financier lié aux séjours prolongés.

## Sources de Données

- **PMSI MCO** : dates d'entrée et de sortie de chaque séjour, mode de sortie (vers SSR, HAD, domicile, décès, transfert), code GHM — pour le calcul des délais de transition MCO→aval et l'identification des prolongations de séjour liées à l'attente d'aval.
- **PMSI SSR** : dates d'entrée de chaque séjour SSR, mode d'entrée (depuis MCO), FINESS de provenance — pour le calcul des délais MCO→SSR par chaînage FINESS+dates.
- **PMSI HAD** : dates de début de prise en charge, mode d'entrée depuis MCO — pour le calcul des délais MCO→HAD.
- **SNDS (chaînage NIR)** : nécessaire pour les délais inter-établissements (patient transféré d'un MCO d'un établissement vers le SSR d'un autre établissement du GHT) ; la chaîne PMSI seule ne permet pas ce calcul si les établissements ont des FINESS distincts.
- **DPI (Dossier Patient Informatisé)** : pour le calcul intra-établissement des délais précis entre la décision médicale d'orientation et la réalisation effective de la transition — niveau de granularité supérieur au PMSI, mais non standardisé entre établissements.
- **SAE** : capacités en lits SSR/HAD par établissement, pour contextualiser la viscosité MCO→SSR par rapport aux capacités disponibles sur le territoire.

## Exemple de Valeurs

- **CVP médian national (estimation)** : 8-15 (unités composites jours×%), correspondant à un délai médian MCO→SSR de 3-5 jours avec un taux de blocage de 25-35 %.
- **CVP faible (< 6)** : GHT avec filières SSR intégrées, outils de gestion des lits partagés, conventions de transfert formalisées — délai MCO→SSR médian < 2 jours, taux de blocage < 20 %.
- **CVP élevé (> 20)** : GHT avec pénurie de capacités SSR ou HAD sur le territoire, délai MCO→SSR médian > 7 jours, taux de patients en attente d'aval > 50 %.
- **Viscosité MCO→EHPAD** : interface systématiquement la plus visqueuse (ν_t de 15-40), avec des délais médians de 10-21 jours et des taux de blocage de 40-60 % dans les territoires à faible densité de places EHPAD.
- **Viscosité urgences→MCO** : variable selon l'heure et la saison — ν_t de 2-5 en situation normale (< 6h d'attente, taux de blocage < 30 %), ν_t > 15 en période épidémique hivernale (> 12h d'attente, taux de blocage > 60 %).
- **Impact d'une cellule de gestion des lits** : réduction du CVP de 20-35 % observée dans les établissements ayant déployé une coordination active des sorties (bed management), selon les retours d'expérience ANAP.

## Limites

- **Délais PMSI vs délais réels** : le PMSI enregistre les dates de séjour, pas les dates de décision médicale d'orientation — le délai calculé inclut donc le temps nécessaire à la stabilisation médicale du patient, pas seulement la friction organisationnelle. La distinction entre délai médical légitime et délai organisationnelle évitable nécessite des données DPI non standardisées.
- **Chaînage inter-établissements** : le calcul des délais pour les transferts entre deux établissements distincts du GHT nécessite le SNDS (chaînage NIR) ou un accord de partage de données entre les DIM — non disponible en routine pour tous les GHT.
- **Biais de casemix** : les établissements accueillant des patients plus lourds (Charlson élevé, dépendance) ont structurellement des délais d'orientation vers l'aval plus longs — la standardisation par profil clinique est nécessaire pour les comparaisons inter-établissements.
- **Absence de référentiel national officiel** : contrairement à la DMS ou au IP-DMS, il n'existe pas de benchmark national publié pour les délais de transition inter-segments — les valeurs de référence proposées sont issues de la littérature et des retours d'expérience ANAP, non d'une base de données nationale exhaustive.
- **Interface domicile** : la viscosité de la transition vers le domicile simple (sans HAD ni SSR) est difficile à mesurer car le PMSI ne trace pas les conditions de retour à domicile (aide à domicile, matériel médical, coordination infirmière) — seule la prolongation de séjour au-delà de la DMS de référence est un proxy indirect.

## Références

- [Hagen-Poiseuille, loi fondamentale de l'écoulement visqueux — analogie avec les flux patients](https://fr.wikipedia.org/wiki/Loi_de_Hagen-Poiseuille)
- [ANAP — Gestion des lits et fluidité des parcours hospitaliers](https://www.anap.fr/s-informer/publications/detail/actualites/gestion-des-lits)
- [ATIH — PMSI MCO : modes de sortie et filières](https://www.atih.sante.fr/)
- [SNDS — Chaînage longitudinal des séjours PMSI](https://www.snds.gouv.fr/)
- [HAS — Parcours de soins : continuité et coordination](https://www.has-sante.fr/jcms/c_1742367/fr/parcours-de-soins)
- [Bittencourt R.J. et al., *Patient flow in emergency departments: a conceptual model*, 2013](https://doi.org/10.1097/PTS.0b013e318294b4ad)
- [Proudlove N.C. et al., *Bed management and patient flow*, Health Care Management Science, 2003](https://doi.org/10.1023/A:1023313212829)
