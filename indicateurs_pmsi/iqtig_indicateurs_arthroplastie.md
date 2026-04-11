# IQTIG — Indicateurs de Qualité en Arthroplastie (Allemagne)

## Définition
Dans le domaine de l'arthroplastie de hanche et de genou, l'IQTIG publie des indicateurs de qualité couvrant les révisions précoces de prothèse, les complications périopératoires (infections du site opératoire, embolie pulmonaire, luxation, fracture peropératoire), la durée de séjour et la mortalité postopératoire. L'Allemagne est l'un des pays au monde avec le plus fort taux d'arthroplastie (300 000 prothèses totales de hanche et 200 000 prothèses totales de genou par an) et dispose d'un registre national de suivi implantataire (EPRD — Endoprothesenregister Deutschland) couplé aux données G-DRG, fournissant le référentiel le plus riche au monde pour ces indicateurs. La transposition au PMSI français est directe grâce aux codes CIM-10 et CCAM couvrant les mêmes gestes, et au Registre National des Arthroplasties (RNA) en cours de déploiement en France.

## Calcul
Les principaux indicateurs IQTIG en arthroplastie et leur formule :

**1. Taux de révision précoce de prothèse (< 90 jours) :**
```
Taux de révision précoce (%) = (Séjours de révision de PTH/PTG dans les 90 jours suivant la pose / Total des poses de PTH/PTG) × 100

  → Pose de PTH : codes CCAM NBFA010, NBFA020 (arthroplastie totale de hanche)
  → Pose de PTG : codes CCAM NCFA010, NCFA020 (arthroplastie totale de genou)
  → Révision : codes CCAM NBFA030, NBFA040 (révision PTH), NCFA030 (révision PTG)
  → Chaînage PMSI par NIR crypté pour identifier les révisions dans les 90 jours post-pose
```

**2. Taux d'infection du site opératoire profonde (ISO profonde) :**
```
Taux d'ISO profonde (%) = (Séjours avec infection profonde de prothèse / Total des poses) × 100
  → Codes CIM-10 : T84.5 (infection de prothèse articulaire interne) en DP ou DA
  → T84.0, T84.1 (complications mécaniques de prothèse de hanche/genou)
  → Identifié sur le séjour de pose ou sur les séjours de suivi (chaînage 1 an)
```

**3. Taux de complications thromboemboliques postopératoires :**
```
Taux de MTEV postopératoire (%) = (Séjours avec EP ou TVP dans les 90 jours post-arthroplastie / Total poses) × 100
  → Codes CIM-10 : I26 (embolie pulmonaire), I82.4 (TVP des membres inférieurs)
  → Exclu si MTEV préexistante (I26, I82 en DA avec flag POA ou au cours d'un séjour antérieur)
```

**4. Taux de luxation de prothèse de hanche (< 90 jours) :**
```
Taux de luxation (‰) = (Séjours avec luxation de PTH dans les 90 jours / Total poses PTH) × 1 000
  → Code CIM-10 : T84.0 (luxation de prothèse articulaire interne)
  → Acte de réduction : NBPA009 (réduction de luxation de hanche sous anesthésie)
```

**5. Taux de fracture peropératoire :**
```
Taux de fracture peropératoire (‰) = (Séjours de pose avec fracture peropératoire documentée / Total poses) × 1 000
  → Codes CIM-10 : M96.6 (fracture après pose de prothèse articulaire) en DA
  → T84.0 (complication mécanique de prothèse de hanche)
```

**6. Mortalité à 90 jours post-arthroplastie :**
```
Taux de mortalité 90j (%) = (Décès dans les 90 jours suivant la pose / Total poses) × 100
  → Mode de sortie = décès (9) sur le séjour de pose ou sur les séjours suivants (chaînage + CépiDc)
  → Standardisé sur l'âge, le sexe et le score ASA/CCI
```

## Transposition PMSI France
La transposition est **très favorable**, avec des spécificités françaises à noter :

- **Codes CCAM bien définis** : les actes d'arthroplastie de hanche et de genou (pose et révision) disposent de codes CCAM précis et stables depuis 2005 — identification directe dans le PMSI.
- **Codes CIM-10 communs** : T84 (complications de prothèse articulaire), M16 (coxarthrose), M17 (gonarthrose), I26, I82 sont identiques en CIM-10 FR et CIM-10 allemande.
- **Chaînage PMSI** : les révisions et complications dans les 90 jours sont identifiables par chaînage du NIR crypté entre séjours — techniquement réalisable mais nécessitant l'accès SNDS.
- **Registre National des Arthroplasties (RNA)** : le RNA français, en déploiement progressif depuis 2015, est couplé aux données PMSI pour le suivi implantataire — il permettra à terme des indicateurs de révision à plus long terme (1, 5, 10 ans) comme dans le registre EPRD allemand.
- **Limite clé** : l'absence de score ASA dans le PMSI (disponible dans le bloc opératoire mais non transmis à l'ATIH) impose d'utiliser le CCI ou l'Elixhauser comme proxy de la sévérité préopératoire pour la standardisation.

## Utilité
- **Benchmarking des services d'orthopédie du GHT** : comparer les taux de révision précoce, d'ISO profonde et de MTEV entre les sites chirurgicaux du GHT avec des définitions standardisées et des seuils de référence validés.
- **Évaluation de la qualité technique chirurgicale** : le taux de luxation de PTH et de fracture peropératoire sont des indicateurs directs de la qualité du geste chirurgical, indépendants du casemix.
- **Surveillance des infections sur prothèse** : les ISO profondes de prothèse (T84.5) sont l'une des complications les plus graves et les plus coûteuses de l'arthroplastie — leur suivi systématique est un levier majeur d'amélioration de la sécurité.
- **Aide à la décision pour les renouvellements d'autorisation** : les indicateurs IQTIG sont utilisés en Allemagne pour les décisions de maintien des autorisations de chirurgie prothétique ; leur adoption dans le GHT prépare à d'éventuelles exigences réglementaires françaises similaires.
- **Intégration avec le RNA** : le couplage des indicateurs IQTIG avec le Registre National des Arthroplasties permet un suivi implantataire sur 5-10 ans, essentiel pour évaluer les prothèses à risque de révision tardive.

## Sources de Données
- **PMSI MCO** : codes CCAM d'arthroplastie (pose et révision), codes CIM-10 des complications (T84, I26, I82), mode de sortie (décès).
- **Chaînage PMSI (NIR crypté / SNDS)** : pour le suivi à 90 jours et 1 an des complications et révisions post-arthroplastie.
- **RNA (Registre National des Arthroplasties)** : couplé au PMSI, il fournit les données implantataires (référence de la prothèse, voie d'abord) non disponibles dans le PMSI seul.
- **ScanSanté** : volume d'arthroplasties par établissement, taux de révision et de complications disponibles dans le module chirurgie orthopédique.
- **Référence méthodologique** : IQTIG, *Bundesauswertung Hüftendoprothesenversorgung und Knieendoprothesenversorgung*, rapport annuel allemand.

## Exemple de Valeurs
- **Taux de révision à 90 jours PTH** : 0,5-1,5 % en France selon les établissements ; objectif IQTIG < 1 % ; les établissements > 2 % font l'objet d'un audit obligatoire en Allemagne.
- **Taux d'ISO profonde sur PTH/PTG** : 0,5-1,5 % selon les établissements français ; objectif <1 % (recommandations SPILF).
- **Taux de MTEV postopératoire (90j)** : 1-3 % en l'absence de prophylaxie optimale ; réduit à 0,3-0,8 % avec protocoles RAAC et anticoagulation adaptée.
- **Taux de luxation de PTH** : 1-3 % à 90 jours (voie postérieure) vs 0,5-1 % (voie antérieure) — différence de voie d'abord non documentée dans le PMSI mais identifiable via les codes CCAM.
- **Mortalité à 90 jours post-PTH** : 0,3-0,8 % pour la PTH élective, 3-8 % pour la fracture de hanche opérée chez le sujet âgé.
- **Volume minimal recommandé** : l'IQTIG et la HAS recommandent un minimum de 50 PTH/an par établissement pour maintenir une qualité chirurgicale suffisante ; les établissements en dessous de ce seuil présentent des taux de complications 30-50 % supérieurs.

## Limites
- Le chaînage à 90 jours pour les révisions et complications post-arthroplastie nécessite l'accès au NIR crypté (SNDS), soumis à des contraintes réglementaires.
- L'absence du score ASA dans le PMSI rend la standardisation sur la sévérité préopératoire moins précise qu'en Allemagne où ce score est systématiquement transmis.
- Les révisions réalisées dans un établissement différent de celui de la pose (hôpital de destination pour complication) ne sont identifiables que par chaînage inter-établissements — non disponible sans SNDS.
- Le taux de révision précoce est influencé par les pratiques de transfert : un établissement qui transfère ses complications dans un CHU affiche artificiellement un faible taux de révision.
- Le RNA n'est pas encore exhaustif sur l'ensemble du territoire français (déploiement progressif) — l'interopérabilité PMSI-RNA est partielle et variable selon les établissements.

## Références
- [IQTIG - Qualitätsindikatoren Hüft- und Knieendoprothetik](https://www.iqtig.org/)
- [RNA - Registre National des Arthroplasties (France)](https://www.rna.fr/)
- [ScanSanté - Arthroplastie de hanche et de genou](https://www.scansante.fr/)
- [HAS - Recommandations sur les arthroplasties de hanche et de genou](https://www.has-sante.fr/)
- [SPILF - Prévention des infections sur prothèse articulaire](https://www.infectiologie.com/)
