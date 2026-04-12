# Indice de Plasticité Post-Choc

## Définition

En science des matériaux, la **déformation plastique** est la partie irréversible de la déformation d'un matériau après suppression de la contrainte : si un métal est plié au-delà de sa limite élastique, il reprend partiellement sa forme initiale mais conserve une courbure résiduelle permanente. Contrairement à la déformation élastique (entièrement récupérée), la déformation plastique laisse une trace durable dans la microstructure du matériau.

L'**Indice de Résilience Opérationnelle** (IRO) mesure la vitesse à laquelle un indicateur de performance hospitalier revient à son baseline après un choc. Mais l'IRO ne pose pas la question suivante : **le retour est-il complet ?** Un service peut "récupérer" rapidement selon l'IRO (retour dans l'intervalle de normalité) tout en ayant subi une déformation permanente — son nouveau baseline post-choc est structurellement dégradé par rapport au baseline pré-choc.

L'**Indice de Plasticité Post-Choc** (IPPC) mesure précisément cette déformation résiduelle :

**IPPC = (Baseline_post − Baseline_pré) / |Amplitude_choc|**

- IPPC = 0 : retour parfait au baseline pré-choc (déformation entièrement élastique, résilience complète)
- IPPC > 0 : le baseline post-choc est dégradé par rapport au baseline pré-choc (dégradation permanente, déformation plastique positive — DMS plus longue, taux de complications plus élevé)
- IPPC < 0 : le baseline post-choc est meilleur que le baseline pré-choc (le choc a paradoxalement forcé une amélioration durable — "effet Phoenix")
- |IPPC| proche de 1 : la déformation permanente est égale à l'amplitude du choc (le système ne récupère pas du tout)

## Calcul

Définition des phases (extension de la méthodologie IRO) :

```
Phase 0 — Baseline pré-choc :
  Période de référence stable avant le choc (12-24 semaines)
  μ_pré = médiane(I_t) sur la période de référence pré-choc
  σ_pré = écart-type sur la même période
  Intervalle de normalité pré : [μ_pré − σ_pré ; μ_pré + σ_pré]

Phase 1 — Choc (S0 → S_retour) :
  Amplitude_choc = I_S0 − μ_pré   (dégradation maximale par rapport au baseline)
  Durée_choc = S_retour − S0      (en semaines, = 1/IRO)

Phase 2 — Stabilisation post-choc (S_retour → S_retour + W) :
  W = fenêtre de stabilisation (12-24 semaines après le retour dans l'intervalle)
  μ_post = médiane(I_t) sur la fenêtre de stabilisation post-choc
  σ_post = écart-type sur la même période

Calcul de l'IPPC :
  IPPC = (μ_post − μ_pré) / |Amplitude_choc|

Test de significativité de la déformation résiduelle :
  H₀ : μ_post = μ_pré (pas de déformation permanente)
  Test de Mann-Whitney sur les distributions pré et post
  ou IC95%(μ_post − μ_pré) via bootstrap
  → Ne conclure à une déformation plastique que si p < 0.05
```

Décomposition élastique/plastique de la déformation totale :

```
Déformation totale lors du choc :
  ε_total = Amplitude_choc / μ_pré   (déformation relative par rapport au baseline)

Déformation plastique (résiduelle permanente) :
  ε_plastique = (μ_post − μ_pré) / μ_pré

Déformation élastique (récupérée) :
  ε_élastique = ε_total − ε_plastique

Taux de récupération élastique :
  TRE = ε_élastique / ε_total = 1 − IPPC × (μ_pré / Amplitude_choc × μ_pré / μ_pré)
  → Simplifié : TRE = 1 − |ε_plastique / ε_total|
  → TRE = 1.0 : récupération totale (résilience élastique parfaite)
  → TRE = 0.5 : la moitié du choc est récupérée, l'autre est permanente
  → TRE = 0.0 : aucune récupération (déformation totalement plastique)
```

Suivi longitudinal multi-chocs :

```
Pour un établissement ayant subi K chocs successifs :
  IPPC_k = plasticité après le k-ième choc
  Baseline_k = μ_post après le k-ième choc

  Trajectoire du baseline dans le temps :
    Baseline_k = μ_pré × Π_{i=1}^{k} (1 + IPPC_i × |A_i| / μ_pré)

  Si IPPC > 0 à chaque choc : dérive progressive du baseline vers le haut (DMS qui
    s'allonge durablement après chaque crise)
  Si IPPC_moyen ≈ 0 : système plastiquement stable (chocs sans effet cumulatif)
  Si IPPC < 0 après certains chocs : "effet Phoenix" — le choc a forcé des
    réorganisations bénéfiques durables

IPPC_cumulé sur N chocs :
  IPPC_cum = (Baseline_N − Baseline_0) / Σ|Amplitude_k|
  → Dérive normalisée du baseline sur l'ensemble des chocs
```

## Utilité

- **Compléter l'IRO par la mesure de la récupération qualitative, pas seulement quantitative** : un service avec IRO = 0,25 (retour en 4 semaines) mais IPPC = 0,40 (baseline dégradé de 40% de l'amplitude du choc) n'a pas vraiment récupéré — il a retrouvé une apparence de normalité au sens de l'intervalle de contrôle, mais son niveau de performance s'est durablement dégradé ; l'IPPC révèle cette "récupération incomplète" invisible dans l'IRO seul
- **Identifier les chocs qui laissent des séquelles durables** : tous les chocs ne sont pas équivalents — une vague grippale peut avoir un IPPC proche de 0 (récupération totale) tandis qu'une restructuration forcée ou une fermeture de service concurrente peut avoir un IPPC élevé (déformation permanente) ; classer les chocs selon leur IPPC pour identifier les types d'événements qui modifient structurellement le système
- **Détecter l'effet Phoenix** (IPPC < 0) : certains chocs forcent des réorganisations bénéfiques que la routine n'aurait pas permises — la crise COVID a dans certains services amélioré le baseline de la DMS post-choc (digitalisation forcée, suppression d'actes non pertinents, protocoles RAAC adoptés en urgence) ; l'IPPC négatif quantifie ce gain paradoxal
- **Évaluer la soutenabilité à long terme d'un système soumis à des chocs répétés** : si IPPC_cumulé > 0 sur 5 ans de chocs successifs, le baseline se dégrade progressivement — le système est en dérive lente non visible dans les indicateurs ponctuels ; l'IPPC_cumulé est un indicateur de soutenabilité à moyen terme
- **Négociation post-crise avec les ARS et les financeurs** : quantifier la déformation plastique générée par une crise (COVID, grève longue) fournit un argument pour demander des ressources de "reconstitution" — "notre DMS baseline a été plastiquement dégradée de +1,2j (IPPC = 0,35) par la vague COVID, ce qui représente X journées excédentaires/an justifiant un financement de retour à la normale"

## Sources de Données

- **PMSI MCO RSA** (séries hebdomadaires sur 3-5 ans couvrant au moins un choc identifiable) : DMS hebdomadaire, taux de complications, taux de réadmissions — pour les variables I_t ; les chocs sont datés depuis des sources exogènes (Sentinelles/SPF pour les vagues épidémiques, données sociales pour les grèves) comme dans la méthodologie IRO
- **Même infrastructure de données que l'IRO** : l'IPPC et l'IRO sont calculés sur les mêmes séries temporelles et peuvent être produits simultanément — coût marginal de production quasi-nul si l'IRO est déjà calculé

## Exemple de Valeurs

- **Service MCO après vague COVID-19 (vague 1, mars-mai 2020)** :
  μ_pré (DMS) = 6,8j ; Amplitude_choc = +3,2j (pic à DMS = 10,0j)
  IRO = 0,07 (retour en 14 semaines) — récupération lente
  μ_post (DMS stable, S26-S38 2020) = 7,5j
  IPPC = (7,5 − 6,8) / 3,2 = **+0,22** — déformation plastique de 22% du choc
  TRE = 78% — le service a récupéré 78% du choc mais conserve une DMS
    durablement allongée de +0,7j par rapport au pré-COVID

- **Service gériatrique après réorganisation forcée (fermeture d'un service concurrent)** :
  μ_pré = 14,2j ; Amplitude_choc = +4,5j
  IRO = 0,05 (très lente récupération, 20 semaines)
  μ_post = 16,1j → IPPC = (16,1 − 14,2) / 4,5 = **+0,42**
  → Déformation plastique majeure — la DMS s'est structurellement allongée
    de presque 2 jours après la fermeture du service concurrent

- **"Effet Phoenix" après grève courte avec négociation productive** :
  μ_pré (taux de complications) = 4,2% ; Amplitude_choc = +2,1%
  μ_post = 3,6% → IPPC = (3,6 − 4,2) / 2,1 = **−0,29**
  → La grève a conduit à une révision des protocoles qui a réduit durablement
    le taux de complications de 0,6 points en dessous du niveau pré-grève

- **IPPC_cumulé sur 5 ans (3 chocs)** :
  Choc 1 (grippe 2019) : IPPC = +0,05
  Choc 2 (COVID 2020) : IPPC = +0,28
  Choc 3 (restructuration 2022) : IPPC = +0,18
  IPPC_cumulé = (DMS_2023 − DMS_2018) / Σ|amplitudes| = +0,17
  → Dérive progressive : le baseline s'est alourdi de +1,4j sur 5 ans

## Limites

- La définition du **baseline post-choc** requiert une période de stabilisation suffisante (12-24 semaines) sans nouveau choc superposé — dans les environnements hospitaliers modernes où les chocs se succèdent rapidement (grippe 2019, COVID vague 1, COVID vague 2…), il peut être impossible d'isoler un baseline post-choc propre ; le calcul de l'IPPC est instable en cas de chocs successifs rapprochés
- La distinction entre **déformation plastique** (baseline structurellement modifié) et **changement de casemix** (le service traite durablement un profil de patients différent post-choc) est délicate depuis le PMSI seul — une augmentation de la DMS post-choc peut refléter un basculement vers des patients plus lourds (casemix effect) plutôt qu'une vraie dégradation organisationnelle ; une standardisation du casemix est recommandée avant l'interprétation de l'IPPC

## Références

- [Callister W.D. — Materials Science and Engineering: An Introduction, Wiley 2007 : déformation élastique et plastique, module d'Young et limite élastique]
- [Holling C.S. — Resilience and stability of ecological systems, Annual Review of Ecology and Systematics 1973](https://doi.org/10.1146/annurev.es.04.110173.000245)
- [Woods D.D. — Four concepts for resilience and the implications for the future of resilience engineering, Reliability Engineering & System Safety 2015](https://doi.org/10.1016/j.ress.2015.03.018) — distinction entre résilience élastique et absorptive
- [Hollnagel E., Woods D.D., Leveson N. — Resilience Engineering: Concepts and Precepts, Ashgate 2006]
- [DGOS — Bilan post-COVID des établissements de santé : indicateurs de retour à la normale (2021)](https://solidarites-sante.gouv.fr/)
