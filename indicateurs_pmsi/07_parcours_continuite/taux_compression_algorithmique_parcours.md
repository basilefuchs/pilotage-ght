# Taux de Compression Algorithmique du Parcours

## Définition

La **complexité de Kolmogorov** (Andrei Kolmogorov, 1965) est la longueur du plus court programme informatique capable de générer exactement une séquence donnée — une mesure de la complexité intrinsèque et de la régularité d'une séquence, indépendante de toute référence externe. Une séquence régulière et répétitive (ABABABABAB…) est très compressible car un programme court suffit à la décrire ("répéter AB 5 fois") ; une séquence aléatoire (AKJZTQVMNP…) est incompressible car aucun programme court ne peut la résumer.

En pratique, la complexité de Kolmogorov n'est pas calculable directement (problème indécidable). Elle est **approchée par les algorithmes de compression de données** (LZ77, zlib, bzip2) : le taux de compression d'un texte par un algorithme standard est une borne supérieure de la compressibilité de la séquence, et donc une approximation de sa complexité algorithmique.

Appliqué aux parcours de soins, le **Taux de Compression Algorithmique du Parcours** (TCAP) encode la séquence ordonnée des actes d'un patient (codes CCAM, codes ATC, codes CIM-10) en une chaîne de caractères, puis mesure le ratio de compression obtenu par un algorithme standard :

**TCAP = 1 − (Taille_compressée / Taille_originale)**

- TCAP proche de 1 : parcours très compressible = **séquence régulière, répétitive, structurée** (actes récurrents, protocole suivi, comportement prédictible)
- TCAP proche de 0 : parcours peu compressible = **séquence complexe, non-répétitive, aléatoire** (actes diversifiés sans pattern, parcours anarchique)

Contrairement à la distance de Levenshtein (qui compare à un protocole de référence), le TCAP mesure la **complexité absolue du parcours sans référence** — il ne dit pas si le parcours est conforme, mais s'il est structuré ou non. Un parcours structuré peut être conforme (bon suivi d'un protocole) ou systématiquement non conforme (mauvais protocole appliqué régulièrement) ; un parcours peu compressible est soit très complexe cliniquement soit anarchique organisationnellement.

## Calcul

Encodage de la séquence d'actes en chaîne de caractères :

```
Pour chaque patient i (NIR) sur une fenêtre temporelle de 12 mois :

Séquence d'actes Si = concaténation ordonnée par date des actes réalisés :

  Depuis PMSI RSA (séjours MCO) :
    → Codes CCAM réalisés dans le séjour, dans l'ordre de réalisation
    → Code GHM du séjour (résumé de la nature du séjour)
    → DP (code CIM-10 du diagnostic principal, 3 premiers caractères)

  Depuis DCIR ER_PRS_F (consultations ambulatoires) :
    → Code spécialité du médecin consulté (2 caractères)
    → Code acte CCAM si consultation avec acte technique

  Depuis DCIR ER_PHA_F (dispensations médicamenteuses) :
    → Code ATC niveau 3 (3 caractères) pour chaque molécule dispensée

  Depuis DCIR ER_BIO_F (actes biologiques) :
    → Code BHN des 3 principaux actes biologiques réalisés

Format de la chaîne encodée :
  Si = "CCAM1|GHM1|DP1|SP1|ATC1|ATC2|BHN1|CCAM2|GHM2|DP2|..."
  → Séparateur "|" entre les éléments
  → Longueur de Si en caractères = L_originale

Note : version PMSI seul (sans DCIR) :
  Si_PMSI = concaténation des (GHM + DP) de tous les séjours MCO sur 12 mois
  → Moins riche mais entièrement calculable sans accès SNDS
```

Calcul du taux de compression :

```
Compression standard de Si par l'algorithme zlib (LZ77 + Huffman) :
  L_compressée = len(zlib.compress(Si.encode('utf-8'), level=9))
  TCAP_i = 1 − L_compressée / L_originale

  → Python : import zlib; ratio = 1 - len(zlib.compress(s.encode())) / len(s.encode())
  → Alternative : bzip2 (meilleure approximation de Kolmogorov), gzip

Note technique : la compression sur des chaînes très courtes (< 50 caractères)
est instable (overhead du header de compression) → utiliser un encodage
à longueur minimale ou concaténer plusieurs patients avant compression
et calculer la compression marginale individuelle
```

Analyse de la distribution des TCAP dans une cohorte :

```
TCAP_cohorte = distribution des TCAP_i pour l'ensemble des patients N

Indicateurs synthétiques :
  μ_TCAP = TCAP moyen de la cohorte
  σ_TCAP = écart-type (hétérogénéité de la compressibilité dans la cohorte)
  P10, P50, P90 : distribution des TCAP

Stratification :
  → Par profil de comorbidités (Charlson) : les patients polypathologiques
    ont-ils des parcours plus ou moins compressibles ?
  → Par présence d'un médecin traitant déclaré (IR_BEN_R DCIR) :
    les patients avec MT déclaré ont des parcours plus compressibles
    (consultations régulières = patterns répétitifs)
  → Par territoire (IRIS, commune) : cartographier la compression géographique

Corrélation TCAP avec les indicateurs de qualité :
  Calculer la corrélation entre TCAP_i et :
    → Nombre de réadmissions dans l'année
    → Score de synchronisation SSP (si disponible)
    → Indice de fragmentation IF
  → TCAP faible + IF élevé = parcours anarchique et fragmenté → double signal d'alerte
```

## Utilité

- **Détecter les parcours complexes sans protocole de référence** : dans les services ou pathologies sans protocole formalisé (polypathologies, patients "inclassables"), la distance de Levenshtein ne peut pas être calculée faute de séquence de référence ; le TCAP fournit une mesure de complexité/anarchie directement applicable sans référence, identifiant les patients dont le parcours est structurellement imprévisible
- **Score de priorisation pour la coordination** : les patients avec TCAP faible (parcours peu compressible = anarchique) ET un nombre élevé d'actes constituent les candidats prioritaires à une coordination renforcée — ils ont beaucoup d'actes mais sans pattern reproductible, signe d'une prise en charge non structurée
- **Évaluer l'impact de l'introduction d'un protocole** : avant l'introduction d'un protocole de suivi (SOPHIA diabète, télésuivi IC), les patients de la cohorte ont des TCAP variables ; après l'introduction, les TCAP devraient augmenter (les parcours deviennent plus réguliers et compressibles) — l'évolution de μ_TCAP est un indicateur de résultat du programme
- **Identifier les patterns de soins communs sans analyse supervisée** : trier les patients par TCAP décroissant et analyser les séquences des patients à TCAP élevé révèle les "protocoles empiriques" réellement appliqués dans un service, même non formalisés — outil de recherche sur les pratiques réelles vs pratiques prescrites
- **Corrélation avec les résultats cliniques** : tester si le TCAP individuel prédit la réadmission, le recours aux urgences ou la dégradation fonctionnelle — des études en analyse de séquences médicales (medical sequence analysis) suggèrent que la compressibilité des parcours est un prédicteur de résultats indépendant des covariables cliniques classiques

## Sources de Données

- **PMSI MCO RSA** : séquences CCAM + GHM + DP par séjour, ordonnées chronologiquement par `date_entree` — version "PMSI seul" du TCAP, calculable sans accès SNDS
- **DCIR ER_PRS_F + ER_PHA_F + ER_BIO_F** (SNDS) : enrichissement de la séquence avec les actes ambulatoires, les dispensations et la biologie — version "SNDS" du TCAP, plus riche et représentative du parcours total

## Exemple de Valeurs

- **Patient diabétique type 2 bien suivi (12 mois)** :
  Séquence Si = "E11|A10B|G01|BHN001|SP24|A10B|G01|BHN001|SP24|A10B|G01|BHN001"
  (3 cycles trimestriels identiques : consultation diabétologue + metformine + HbA1c)
  L_originale = 115 chars, L_compressée = 52 chars
  **TCAP = 1 − 52/115 = 0,55** (parcours régulier, bien compressible)

- **Patient polypathologique anarchique (12 mois, 8 séjours MCO)** :
  Séquence longue de 380 chars avec peu de répétitions (actes diversifiés)
  L_compressée = 320 chars
  **TCAP = 1 − 320/380 = 0,16** (parcours peu compressible, anarchique)

- **Distribution dans une cohorte ALD diabète (N=2500 patients)** :
  μ_TCAP = 0,38, σ = 0,15
  P10 = 0,12 (parcours très anarchiques), P90 = 0,58 (parcours très réguliers)
  Patients avec TCAP < P10 : corrélation avec réadmission urgente
    OR = 2,3 (IC95% 1,7-3,1) — les parcours peu compressibles sont à risque

- **Impact du programme SOPHIA (suivi 18 mois)** :
  μ_TCAP avant inclusion = 0,29 → après 18 mois dans SOPHIA = 0,43
  ΔμTCAP = +0,14 — les parcours sont devenus significativement plus réguliers

## Limites

- Les algorithmes de compression standards (zlib, bzip2) sont sensibles à la **longueur de la chaîne encodée** — les parcours courts (peu d'actes sur 12 mois) sont mal comprimés quel que soit leur niveau de régularité (overhead de compression), conduisant à des TCAP artificiellement bas ; recommander une longueur minimale de séquence avant le calcul (au moins 10-15 actes)
- Le TCAP est sensible au **niveau de granularité du codage** : utiliser les codes CCAM complets (7 caractères) vs les codes CCAM tronqués (3 caractères) donne des TCAP différents pour la même séquence ; standardiser la granularité de codage avant toute comparaison inter-cohortes ou inter-établissements
- Le TCAP mesure la **régularité**, non la **conformité** — un parcours très régulier mais systématiquement non conforme au protocole (patient qui ne voit jamais le spécialiste requis mais consulte régulièrement le médecin généraliste) aura un TCAP élevé malgré une prise en charge sous-optimale ; interpréter le TCAP conjointement avec la distance de Levenshtein quand un protocole de référence existe

## Références

- [Kolmogorov A.N. — Three approaches to the quantitative definition of information, Problems of Information Transmission 1965 : définition de la complexité algorithmique]
- [Ziv J., Lempel A. — A universal algorithm for sequential data compression (LZ77), IEEE Transactions on Information Theory 1977](https://doi.org/10.1109/TIT.1977.1055714) — algorithme de base de zlib
- [Cilibrasi R., Vitányi P. — Clustering by compression, IEEE Transactions on Information Theory 2005](https://doi.org/10.1109/TIT.2005.844059) — classification par compression et distance de Kolmogorov normalisée
- [Huang Z. et al. — Similarity measure between patient traces for clinical pathway analysis, IEEE J Biomed Health Inform 2014](https://doi.org/10.1109/JBHI.2013.2274281)
- [HAS — Programmes de coordination des soins pour les patients chroniques complexes (2021)](https://www.has-sante.fr/)
