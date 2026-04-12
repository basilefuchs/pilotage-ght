# Fidélité de Transmission d'Information MCO→SSR

## Définition

Indicateur mesurant la cohérence diagnostique entre le diagnostic principal (DP) du séjour MCO émetteur et le diagnostic principal (ou groupe nosologique GN) du séjour SSR récepteur pour le même patient, identifié par chaînage NIR crypté. Inspiré du concept de **fidélité de transmission** en théorie de l'information — la proportion du message original correctement reçu après transmission à travers un canal — cet indicateur évalue si l'information clinique produite pendant le séjour MCO est fidèlement transmise et intégrée dans la prise en charge SSR.

Une incohérence diagnostique MCO→SSR (ex. DP MCO = I63.3 AVC ischémique → GN SSR = M79.3 myalgie diffuse) signale une rupture dans la chaîne d'information clinique : soit le médecin SSR n'a pas reçu le compte-rendu d'hospitalisation MCO, soit il a reformulé le diagnostic sans lien avec le motif initial d'hospitalisation, soit le codage est erroné dans l'un des deux champs. Dans tous les cas, cette incohérence est un proxy de la qualité de la **lettre de liaison MCO→SSR** et de la continuité informationnelle de la filière.

Cet indicateur est inédit dans les outils de pilotage PMSI : il exploite la puissance du chaînage SNDS pour détecter des ruptures qualitatives de coordination qui sont invisibles à l'analyse de chaque champ séparément.

## Calcul

Chaînage PMSI MCO RSA × PMSI SSR RHS par NIR crypté SNDS.

Population éligible :

```
Paires MCO→SSR appariées :
  → Séjour MCO avec mode_sort = 6 (transfert vers SSR)
  → Séjour SSR suivant identifié par NIR dans les 30j post-DATESOR MCO
  → Mode_entrée SSR = 6 (provenance MCO confirmée)
  → Les deux séjours disposent d'un DP CIM-10 renseigné (non Z-code générique)
```

Construction de la matrice de cohérence diagnostique :

```
Niveau 1 — Cohérence CMD (grossière) :
  CMD_MCO = les 2 premiers caractères du GHM MCO (ex. "01" = neurologie)
  CMD_SSR = la finalité principale FP du GME SSR (ex. "02" = neurologie)

  Correspondance attendue CMD_MCO → FP_SSR :
    CMD 01 (neurologie MCO)       → FP 02 (SSR neurologique)
    CMD 07/08 (orthopédie MCO)    → FP 01 (SSR locomoteur)
    CMD 05 (cardiovasculaire MCO) → FP 03 (SSR cardiovasculaire)
    CMD 14 (obstétrique MCO)      → FP 01 (locomoteur post-césarienne)
    CMD 23 (facteurs influençant) → FP 09 (gériatrie)
    etc. — table de correspondance complète à construire

  Incohérence CMD = CMD_MCO et FP_SSR non concordants selon table

Niveau 2 — Cohérence GN (fine) :
  Comparer le DP CIM-10 MCO avec le groupe nosologique GN du RHS SSR
  Exemple de cohérence : I63.3 (AVC MCO) → GN 01.1 (AVC SSR neurologique)
  Exemple d'incohérence : I63.3 (AVC MCO) → GN 12.1 (affection locomotrice SSR)
```

Formule principale :

```
Taux de cohérence diagnostique MCO→SSR (%) =
  (Paires MCO→SSR avec concordance CMD/FP selon table de correspondance
   / Total paires MCO→SSR appariées éligibles) × 100

Taux d'incohérence = 100 − Taux de cohérence
```

Sous-indicateurs :

```
Matrice d'incohérence CMD×FP :
  → Tableau croisé des CMD MCO vs FP SSR des paires incohérentes
  → Identifie les transitions les plus fréquemment mal codées
    (ex. cardiologie MCO → gériatrie SSR = incohérence fréquente et acceptable
     vs neurologie MCO → locomoteur SSR = incohérence possiblement problématique)

Score de gravité de l'incohérence :
  Niveau 0 : cohérence exacte (CMD et GN concordants)
  Niveau 1 : incohérence acceptée (ex. post-op cardiaque → gériatrie si ≥ 75 ans)
  Niveau 2 : incohérence diagnostique stricte (domaines sans lien clinique évident)
  Niveau 3 : incohérence critique (motif SSR incompatible avec pathologie MCO aiguë)

Taux d'incohérence par établissement MCO émetteur :
  → Identifier les services MCO avec des taux élevés d'incohérence
    → action corrective : amélioration des lettres de liaison ou des protocoles
      de codage du SSR récepteur
```

## Utilité

- **Indicateur proxy de la qualité des lettres de liaison MCO→SSR** : une lettre de liaison complète et transmise à temps permet au médecin SSR de coder le bon diagnostic dès l'admission — un taux élevé d'incohérence diagnostique signale des lettres de liaison absentes, incomplètes, ou transmises après le codage du 1er RHS SSR
- **Mesurer la continuité informationnelle de la filière** : au-delà de la continuité des soins (mesurée par les délais et les taux de réhospitalisation), cet indicateur mesure la continuité de l'**information clinique** — dimension invisible dans tous les outils de pilotage actuels
- **Identifier les paires établissements MCO-SSR avec une coordination dégradée** : dans un GHT multi-sites, certaines paires MCO-SSR peuvent avoir des taux d'incohérence structurellement élevés liés à un défaut de communication spécifique à cette filière (informatiques incompatibles, absence de partage du dossier patient)
- **Améliorer la qualité du codage PMSI SSR** : les incohérences de niveau 3 révèlent des erreurs de codage qui impactent directement le financement SSR (mauvais GME) et la valorisation T2A — l'indicateur est un outil d'audit du DIM SSR
- **Évaluation de l'impact du dossier patient partagé (DMP)** : mesurer l'évolution du taux de cohérence avant/après l'implémentation d'un DMP ou d'une messagerie sécurisée MCO-SSR — démonstration quantitative de la valeur ajoutée de l'interopérabilité

## Sources de Données

- **PMSI MCO RSA** : diagnostic principal (DP CIM-10), GHM (dont CMD), mode de sortie (= 6), NIR crypté, DATESOR
- **PMSI SSR RHS** : groupe nosologique (GN), finalité principale (FP), mode d'entrée (= 6), NIR crypté, date d'entrée
- **Table de correspondance CMD_MCO → FP_SSR** : à construire une fois en collaboration avec les DIM MCO et SSR du GHT, documentant les transitions attendues et les incohérences acceptables vs problématiques
- **Chaînage SNDS par NIR crypté** : appariement des séjours MCO et SSR du même patient y compris entre établissements différents

## Exemple de Valeurs

- **Taux de cohérence attendu dans une filière bien organisée** : > 85% au niveau CMD/FP
- **Taux d'incohérence niveau 3 (incohérences critiques)** : < 5% en situation normale ; > 10% = signal d'alerte sur la qualité de la coordination ou du codage
- **Incohérences fréquentes et acceptables** : cardiologie MCO → gériatrie SSR chez les patients âgés polypathologiques (~15-20% des paires cardiologie→SSR), orthopédie MCO → gériatrie SSR chez les patients ≥ 85 ans
- **Incohérences critiques exemples** : neurologie AVC → SSR locomoteur sans contexte orthopédique ; oncologie active → SSR gériatrique sans mention de soins de support
- **Impact de l'implémentation d'une lettre de liaison standardisée** : études de coordination de soins montrent une réduction de 20-30% des incohérences de codage après introduction d'un compte-rendu de sortie structuré

## Limites

- Le chaînage MCO→SSR par NIR peut manquer des transferts vers des SSR hors SNDS ou avec un délai > 30j — sous-population analysée légèrement plus étroite que la réalité
- La table de correspondance CMD_MCO → FP_SSR est une construction conventionnelle qui doit être validée par les équipes médicales du GHT ; certaines transitions peuvent être légitimes dans un contexte gériatrique (patient avec AVC + fracture → SSR locomoteur pour la fracture) sans être détectées comme acceptables sans cette nuance
- L'indicateur ne distingue pas l'incohérence liée à une erreur de codage SSR (médecin SSR qui ne connaît pas la pathologie initiale) d'une incohérence cliniquement justifiée (priorité thérapeutique SSR différente de la pathologie MCO aiguë) — l'interprétation des incohérences de niveau 2 nécessite une revue manuelle d'un sous-échantillon
- La complétude du DP SSR dans les premiers RHS peut être variable selon les établissements (certains SSR codent le DP définitif seulement au dernier RHS) — utiliser le DP du dernier RHS si celui du premier est manquant ou générique

## Références

- [Shannon C.E., Weaver W. — The Mathematical Theory of Communication, University of Illinois Press 1949 : concept de fidélité de transmission et bruit dans un canal de communication]
- [Kripalani S. et al. — Deficits in communication and information transfer between hospital-based and primary care physicians, JAMA 2007](https://doi.org/10.1001/jama.297.8.831)
- [HAS — Lettre de liaison à la sortie d'hospitalisation : recommandations de bonnes pratiques (2014)](https://www.has-sante.fr/)
- [ATIH — Guide méthodologique PMSI SSR : codage du groupe nosologique (GN) et de la finalité principale (FP)](https://www.atih.sante.fr/)
- [Jeffs L. et al. — Information loss at hospital discharge: a prospective observational study, J Hosp Med 2013](https://doi.org/10.1002/jhm.2023)
