# Indice de Résilience Opérationnelle

## Définition

Emprunté à l'ingénierie des systèmes complexes et à l'écologie (Holling, 1973), la résilience est la capacité d'un système à absorber une perturbation et à retrouver son état de fonctionnement normal. L'Indice de Résilience Opérationnelle (IRO) d'un GHT mesure la **vitesse de retour au baseline** des indicateurs de performance clés après un choc exogène identifiable (vague épidémique, pandémie, grève, sinistre, tension saisonnière extrême).

IRO = 1 / T_retour

où T_retour est le nombre de semaines nécessaires pour que l'indicateur de performance revienne dans la plage de son baseline pré-choc (défini comme la médiane ± 1 écart-type de la période de référence). Un IRO élevé = retour rapide = système résilient ; un IRO faible = récupération lente = système fragile face aux perturbations.

L'IRO est calculé sur des séries temporelles PMSI (extractions hebdomadaires ou mensuelles) et peut être appliqué à tout indicateur de flux ou de qualité : DMS, taux d'occupation, délai MCO→SSR, taux de réhospitalisation, taux de déprogrammation chirurgicale. Il permet de comparer la résilience de différents établissements d'un GHT face au même choc, ou de mesurer l'amélioration de la résilience dans le temps après des investissements organisationnels.

Contrairement aux indicateurs statiques (qui mesurent la performance à un instant T), l'IRO capture une propriété **dynamique** du système — sa capacité à retrouver son régime nominal — qui est invisible dans tous les tableaux de bord hospitaliers actuels.

## Calcul

Identification du choc et des phases :

```
Définition des phases (sur la série temporelle hebdomadaire de l'indicateur I_t) :

Phase 0 — Baseline pré-choc :
  → Période de référence stable avant le choc (12-24 semaines)
  → Baseline = médiane(I_t) sur la période de référence
  → Intervalle de normalité = [Baseline − 1σ ; Baseline + 1σ]

Phase 1 — Détection du choc :
  → Semaine S0 = première semaine où I_t sort de l'intervalle de normalité
    dans le sens de la dégradation (ex. DMS augmente, taux d'occupation chute)
  → Amplitude du choc = |I_S0 − Baseline| / σ (en nombre de σ)

Phase 2 — Récupération :
  → Semaine S_retour = première semaine où I_t revient dans l'intervalle
    de normalité [Baseline − 1σ ; Baseline + 1σ] et y reste pendant 3 semaines
    consécutives (critère de stabilisation)

T_retour = S_retour − S0 (en semaines)
```

Calcul de l'IRO et sous-indicateurs :

```
IRO = 1 / T_retour  (en semaines⁻¹)
  → IRO = 1    : retour au baseline en 1 semaine  (résilience maximale)
  → IRO = 0.1  : retour au baseline en 10 semaines (résilience modérée)
  → IRO = 0.05 : retour au baseline en 20 semaines (résilience faible)

IRO_norm = IRO / IRO_ref × 100
  IRO_ref = IRO médian observé dans les GHTs de référence pour le même type de choc

Profil de récupération (shape) :
  → Récupération linéaire : dégradation graduelle, retour graduel
  → Récupération en V : dégradation brutale, retour rapide (choc court)
  → Récupération en L : dégradation durable sans retour au baseline
    → Cas de non-résilience : le système a été modifié structurellement par le choc
    → Nécessite un nouveau calcul du baseline post-choc

Perte cumulée pendant le choc :
  Aire = Σ(S0 → S_retour) [|I_t − Baseline|]
  → Mesure le "coût total" du choc en journées-indicateur dégradées
  → Ex. en DMS : Σ jours de DMS excédentaires pendant la phase de choc
```

Chocs types applicables (avec indicateurs cibles) :

```
Type de choc              | Indicateur cible recommandé
--------------------------|--------------------------------------------
Vague grippale saisonnière| Taux d'occupation MCO, DMS gériatrie
Pandémie COVID (vague 1-5)| Déprogrammation chirurgicale, DMS MCO
Grève soignants           | Taux de lits fermés, taux d'occupation SSR
Canicule                  | Admissions urgentes CMD 04 (cardio-pneumo)
Fermeture d'un service    | Délai MCO→SSR, taux de bed-blocking
Pic saisonnier hivernal   | Délai MCO→SSR, taux d'occupation gériatrie
```

## Utilité

- **Comparer la résilience entre établissements du GHT** face aux mêmes chocs : si l'établissement A retrouve son DMS baseline en 4 semaines après une vague grippale et l'établissement B en 12 semaines, l'établissement A est 3 fois plus résilient — l'IRO fournit un benchmarking dynamique inédit entre sites d'un GHT
- **Identifier les facteurs organisationnels de résilience** : par corrélation entre l'IRO des établissements et leurs caractéristiques organisationnelles (existence d'un plan de gestion de crise, de lits de débordement pré-identifiés, de protocoles de déprogrammation, de stocks tampons de personnel) — outil de recherche opérationnelle et de benchmarking des bonnes pratiques
- **Mesurer l'amélioration de la résilience dans le temps** : évaluer si les investissements post-COVID (création de lits supplémentaires, recrutement de personnels mobiles, dématérialisation des processus) ont amélioré l'IRO lors des chocs suivants — démonstration de la valeur ajoutée des plans de résilience
- **Anticiper les besoins de soutien inter-établissements** : un établissement avec un IRO historiquement faible est prévisiblement lent à récupérer lors du prochain choc — prévoir en avance les mécanismes de soutien du GHT (transferts de patients, personnel mutualisé) plutôt que de les décider en réaction
- **Dialogue avec les ARS et le niveau national** : l'IRO est un indicateur de préparation aux crises sanitaires, directement pertinent dans le contexte du Plan Blanc, des plans ORSAN et des contrats de retour à l'équilibre post-crise

## Sources de Données

- **PMSI MCO RSA** (extractions hebdomadaires ou mensuelles) : DMS observée, taux d'occupation (journées / capacités), nombre d'actes CCAM réalisés, nombre de séjours — séries temporelles sur 2-4 ans couvrant les chocs identifiables
- **PMSI SSR RHS** : délai MCO→SSR, taux d'occupation SSR — indicateurs de résilience de la filière aval
- **Données de gestion interne** : taux de lits fermés, taux de déprogrammation chirurgicale, effectifs soignants présents — indicateurs opérationnels plus fins que le PMSI pour certains chocs
- **Sources exogènes de datation des chocs** : données Sentinelles / Géodes SANTÉ PUBLIQUE FRANCE (début/fin vagues grippales, COVID), données météorologiques INSEE (canicules), données sociales (préavis de grève)

## Exemple de Valeurs

- **IRO d'un GHT face à une vague grippale saisonnière (DMS comme indicateur cible)** :
  - Établissement résilient : T_retour = 3-4 semaines → IRO ≈ 0,25-0,33
  - Établissement peu résilient : T_retour = 10-14 semaines → IRO ≈ 0,07-0,10
- **IRO face à la vague COVID-19 (vague 1, mars-mai 2020)** :
  - Choc exceptionnel : T_retour pour la chirurgie programmée : 8-16 semaines selon les établissements
  - Certains établissements n'ont jamais retrouvé leur baseline pré-COVID → IRO = 0 (non-résilience structurelle)
- **Objectif de résilience** : IRO > 0,20 (retour en moins de 5 semaines) pour les chocs saisonniers standards
- **Perte cumulée estimée d'une vague grippale sévère** : 500-2000 journées-DMS excédentaires selon la taille de l'établissement et son IRO

## Limites

- L'IRO dépend de la précision de l'identification du choc et de la définition du baseline — des erreurs de datation du choc (début, fin) modifient significativement T_retour et donc l'IRO ; utiliser des sources externes validées pour dater les chocs
- La définition du "retour au baseline" (3 semaines consécutives dans l'intervalle de normalité) est une convention — d'autres définitions (1 semaine, 5 semaines) donnent des IRO différents ; la définition choisie doit être documentée et constante pour permettre les comparaisons temporelles
- L'IRO suppose qu'un retour rapide au baseline est toujours souhaitable — or si le baseline lui-même était défavorable (DMS élevée pré-choc), un retour rapide à ce baseline n'est pas un succès ; l'IRO doit être lu conjointement avec le niveau absolu du baseline
- Certains chocs modifient structurellement le système (fermeture permanente d'un service, départ d'un médecin-clé, réforme tarifaire) — dans ces cas le système n'a pas vocation à retourner au baseline mais à atteindre un nouveau régime ; l'IRO doit être recalculé sur un nouveau baseline post-restructuration

## Références

- [Holling C.S. — Resilience and stability of ecological systems, Annual Review of Ecology and Systematics 1973](https://doi.org/10.1146/annurev.es.04.110173.000245)
- [Woods D.D. — Four concepts for resilience and the implications for the future of resilience engineering, Reliability Engineering & System Safety 2015](https://doi.org/10.1016/j.ress.2015.03.018)
- [Righi A.W. et al. — A systematic literature review of resilience engineering: research areas and a research agenda proposal, Reliability Engineering & System Safety 2015](https://doi.org/10.1016/j.ress.2014.11.016)
- [Hick J.L. et al. — Health care facility and community strategies for patient care surge capacity, Ann Emerg Med 2004](https://doi.org/10.1016/j.annemergmed.2004.07.428)
- [DGOS — Plan de gestion des tensions hospitalières et des situations sanitaires exceptionnelles (2021)](https://solidarites-sante.gouv.fr/)
