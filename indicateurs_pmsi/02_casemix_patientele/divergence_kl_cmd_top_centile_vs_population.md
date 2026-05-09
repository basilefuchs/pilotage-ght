# Divergence de Kullback-Leibler des CMD du Top Centile vs Population MCO Totale

## Définition

La divergence de Kullback-Leibler (Kullback & Leibler 1951) mesure la dissemblance entre deux distributions de probabilité P et Q sur un même espace discret X :

D_KL(P ‖ Q) = Σ_{x ∈ X} P(x) × log( P(x) / Q(x) )

C'est une quantité non négative, non symétrique, exprimée en bits (log₂) ou nats (ln). D_KL = 0 ssi P = Q ; plus elle est grande, plus P diverge de la référence Q.

Appliquée au case-mix, la **divergence KL des CMD du top centile** compare la distribution des CMD parmi les séjours des **1 % patients les plus consommateurs** (P) à la distribution des CMD sur la **population MCO totale** (Q) :

D_KL(P_CMD|top1% ‖ P_CMD|total) = Σ_c p_c × log( p_c / q_c )

avec :
- p_c = part de la CMD c parmi les séjours des patients top 1 %
- q_c = part de la CMD c parmi les séjours de la population MCO totale

Cet indicateur **scalaire** quantifie à quel point la queue extrême de coût (top 1 %) est **cliniquement spécifique** par rapport au case-mix moyen. Une D_KL élevée signale que quelques CMD (typiquement cancérologie, hématologie, dialyse, brûlés, chir cardiaque lourde) sont massivement surreprésentées dans la queue.

Positionnement vs existant :
- complète `entropie_shannon_casemix` (entropie globale, sans référence) en introduisant une **comparaison à une distribution de référence** ;
- complète `divergence_kl_casemix_temporel` (KL N vs N−1) en pivotant la comparaison de l'axe temporel à l'axe **patientèle/queue** ;
- fournit une décomposition naturelle par CMD (chaque terme p_c × log(p_c/q_c) identifie les contributeurs principaux à la divergence).

## Calcul

```
Périmètre :
  → Population MCO totale sur fenêtre annuelle
  → Top 1 % patients en valorisation (cf. fiche P10 — convention identique)

Étapes :
  1. Calculer V_i pour chaque patient ; identifier top1% = patients V_i ≥ percentile_99
  2. Pour chaque CMD c (28 CMD du référentiel ATIH) :
       q_c = nb_séjours(CMD = c, population totale) / nb_séjours_totaux
       p_c = nb_séjours(CMD = c, top1%) / nb_séjours(top1%)
  3. Lissage de Laplace pour éviter log(0) :
       p_c ← (n_p_c + ε) / (N_top + 28 × ε)
       q_c ← (n_q_c + ε) / (N_total + 28 × ε)
       avec ε = 0.5 typiquement
  4. D_KL = Σ_c p_c × log₂( p_c / q_c )
  5. Décomposition : contribution(c) = p_c × log₂(p_c / q_c)
     (terme positif si surreprésentée dans le top 1 %, négatif si sous-représentée)
```

Indicateurs dérivés :

```
D_KL inversée   : Σ q_c log(q_c/p_c) — détecte les CMD sous-représentées dans la queue
                  (ex. obstétrique, chir orthopédique programmée légère)
Distance JS     : (D_KL(P‖M) + D_KL(Q‖M))/2 avec M = (P+Q)/2 — variante symétrique bornée
                  utilisée si l'on veut comparer plusieurs établissements entre eux
Top contributeurs : trier les contribution(c) par valeur absolue décroissante →
                    fournit la « signature clinique » de la queue
```

Stratifications complémentaires :
- KL sur les **GHM** (≈ 2 600 GHM, plus fin mais plus bruité — exiger N_top ≥ 1 000) ;
- KL sur le **niveau de sévérité** (1/2/3/4) — mesure la sur-sévérisation de la queue.

## Utilité

- **Caractériser la signature clinique de la queue de coût** : la D_KL et ses top contributeurs identifient les domaines cliniques dominants chez les gros consommateurs — orientation directe pour les filières à structurer.
- **Comparer GHT/établissements** : un GHT à D_KL faible a une queue cliniquement diffuse (gros consommateurs distribués sur plusieurs CMD — possiblement gériatrie polypathologique) ; un GHT à D_KL élevée a une queue concentrée sur quelques spécialités (cancero, hémato, dialyse).
- **Suivi temporel** : Δ D_KL entre 2 années révèle un changement de profil de la queue (montée en charge oncologie ? bascule HAD pour cancero affaibli D_KL ? émergence dialyse ?).
- **Décision d'investissement filière** : si la CMD c contribue à 40 % de D_KL, le programme parcours sur la filière c est mécaniquement à fort levier financier.
- **Argument quantitatif en projet médico-soignant** : « la moitié de la divergence du top 1 % vient de la CMD 17 (hémato) — il faut renforcer la coordination ville-hôpital sur cette filière ».
- **Distinguer queue programmée vs subie** : croiser la signature CMD avec le τ_NP_top1 (cf. fiche `part_sejours_non_programmes_top_decile_consommateurs`) pour orienter type d'intervention (case management chronique vs amélioration parcours programmé).

## Sources de Données

- **PMSI MCO — RSA** : variables ANO patient, GHM (dont la CMD est le 2 premiers caractères), valorisation GHS.
- **PMSI MCO — FICHCOMP** : pour le calcul de V_i (top 1 %).
- **Référentiel ATIH** : nomenclature des 28 CMD (Catégories Majeures de Diagnostics) en vigueur — guide méthodologique MCO.
- **Tarifs GHS / UCD / LPP** ATIH pour la valorisation.

## Exemple de Valeurs

Ordres de grandeur — **expert, à calibrer empiriquement** (pas de référence française publiée à ce jour pour cet indicateur appliqué au case-mix MCO ; fondement méthodologique : Kullback-Leibler 1951, Cover & Thomas 2006) :

- **D_KL CMD top1% vs total — CHU généraliste** : 0,5 à 1,2 bits (queue cliniquement structurée par cancero/hémato/réa).
- **D_KL CMD top1% vs total — CH généraliste avec gériatrie** : 0,2 à 0,6 bits (queue diffuse, gériatrie polypathologique).
- **D_KL CMD top1% vs total — clinique mono-spécialité chir** : 0,1 à 0,3 bits (queue ressemble au case-mix global, déjà spécialisé).
- **Top contributeurs typiques en CHU** : CMD 17 (hémato), CMD 28 (séances dialyse/chimio), CMD 11 (rein), CMD 05 (cardio chir), CMD 04 (respiratoire BPCO sévère).
- **Top contributeurs typiques en CH gériatrique** : CMD 04, CMD 05, CMD 08 (musculo-squelettique), CMD 11.

Seuils d'alerte indicatifs :
- |Δ D_KL| > 0,15 bits/an à effectifs comparables → déformation significative de la queue, à investiguer.
- Une CMD nouvelle entrant dans le top 3 contributeurs → émergence de filière à analyser.

## Limites

- **Sensibilité aux faibles effectifs** : pour les CMD rares dans le top 1 %, p_c est très bruité. Le lissage de Laplace atténue ce problème mais n'élimine pas le besoin d'effectif minimum (N_top ≥ 200 patients, soit ≥ 20 000 patients MCO totaux).
- **Non-symétrie** : D_KL(P ‖ Q) ≠ D_KL(Q ‖ P). Documenter le sens choisi (top → total) et privilégier la version symétrique JS pour les comparaisons inter-établissements.
- **Choix du seuil top 1 %** : arbitraire ; tester aussi top 5 % pour vérifier la robustesse de la signature.
- **Granularité CMD vs GHM** : la CMD agrège ; certains signaux cliniques importants (chir bariatrique, transplantations) ne ressortent qu'au niveau GHM. Calculer les deux niveaux quand l'effectif le permet.
- **D_KL non bornée** : difficile à interpréter en absolu (« 0,8 bit, c'est beaucoup ? »). Toujours fournir la décomposition par CMD et la comparer à des références (autres GHT du benchmark).
- **Effet composition** : une variation de la pyramide des âges du territoire modifie q_c et p_c — tout suivi temporel doit s'accompagner d'une vérification de la stabilité démographique.
- **Indicateur exploratoire** : pas de littérature française dédiée appliquant KL au case-mix de la queue HNHC ; à valider sur cohortes locales avant d'en faire un indicateur de pilotage.

## Références

- Kullback S., Leibler R.A. — On information and sufficiency. *Annals of Mathematical Statistics* 1951 — [DOI](https://doi.org/10.1214/aoms/1177729694)
- Cover T.M., Thomas J.A. — *Elements of Information Theory*, 2nd ed., Wiley 2006 — chapitre 2 (référence canonique)
- Lin J. — Divergence measures based on the Shannon entropy. *IEEE Transactions on Information Theory* 1991 — [DOI](https://doi.org/10.1109/18.61115) (Jensen-Shannon)
- Garcia J. et al. — Concentration of High-Cost Head and Neck Cancer Surgical Patients. *Laryngoscope* 2024 — [DOI](https://doi.org/10.1002/lary.31618) (PMID:38973626)
- Guo M. et al. — Cross-Provincial High-Cost Patients. *JMIR Public Health Surveill* 2025 — [DOI](https://doi.org/10.2196/54234) (PMID:40499037)
- ATIH — Manuel des GHM / nomenclature des CMD en vigueur — [atih.sante.fr](https://www.atih.sante.fr/)
