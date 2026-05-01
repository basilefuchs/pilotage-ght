# Coefficient de Gini de Concentration des Événements Indésirables Graves

## Définition

Le **coefficient de Gini** (Gini 1912) est une mesure synthétique de l'inégalité d'une distribution, classiquement utilisée pour quantifier la concentration des revenus dans une population. Il se construit à partir de la **courbe de Lorenz** : on classe les unités par valeur croissante de la variable et on trace la part cumulée de la population contre la part cumulée de la variable. Un Gini de 0 correspond à l'égalité parfaite (chaque unité porte la même part) ; un Gini de 1 correspond à la concentration extrême (une seule unité porte tout).

Transposé à la qualité hospitalière (Nicholson 2005, Asada 2007), le Gini calculé sur la distribution des **événements indésirables graves (EIG) entre services** d'un établissement ou d'un GHT répond à une question de pilotage majeure : **les EIG sont-ils concentrés dans quelques services à problèmes ou diffus dans tout l'établissement ?** Cette information détermine le **type d'intervention qualité** : un Gini élevé suggère un problème **localisé** (quelques services à auditer en priorité), un Gini faible suggère un problème **systémique** (plan d'action global).

**Coefficient de Gini :**

**G = (Σᵢ Σⱼ |xᵢ − xⱼ|) / (2 n² μ) ∈ [0, 1]**

ou de manière équivalente, à partir de la courbe de Lorenz L(p) :

**G = 1 − 2 ∫₀¹ L(p) dp**

où xᵢ est le taux d'EIG du service i (rapporté à un dénominateur cohérent : nombre de séjours, journées d'hospitalisation, ou lits), n le nombre de services et μ la moyenne. Pour les comptes (nombre brut d'EIG par service), on utilise le **Gini pondéré** par la taille du service.

**Indicateurs dérivés :**

- **Part Top-20% (P20)** : part des EIG portée par les 20% des services les plus exposés
- **Ratio P80/P20** : ratio entre EIG des 20% des services au sommet vs 20% à la base (analogue Palma)
- **Atkinson(ε)** : indice avec aversion à l'inégalité paramétrable, complémentaire du Gini

## Positionnement vs indicateurs existants

Le projet contient déjà :
- `taux_evenements_indesirables.md` — **niveau** des EIG, pas leur concentration
- `loi_gutenberg_richter_evenements_indesirables.md` — **distribution en magnitude** (taille des EI)
- `value_at_risk_evenements_indesirables.md` — **quantile extrême** (queue de distribution)
- `psi90_patient_safety_indicators.md` — composite par établissement

Aucun ne mesure la **dispersion entre services** au sein d'un établissement. Le Gini est complémentaire :
- Le taux dit *combien* d'EIG il y a
- Gutenberg-Richter dit *quelle taille* ils ont
- Le Gini dit *où* ils sont (concentrés / diffus)

C'est l'angle organisationnel qui manque pour cibler l'audit qualité.

## Calcul

### 1. Identification des EIG

```
Définition de l'EIG (selon HAS/ANSM, codes CIM-10 et PSI ATIH) :
  - Décès évitable : décès intra-séjour pour GHM à mortalité attendue < 1%
  - Réintervention en urgence : acte CCAM de reprise dans les 7 jours post-acte index
  - IAS post-op : codes CIM-10 T81.4, T81.41, A04*, A41* en DAS, séjour chirurgical
  - Erreurs médicamenteuses : codes Y40-Y84 en DAS
  - Chutes avec fracture : codes W00-W19 + S codes en DAS pendant le séjour
  - Escarres acquises (stade 3-4) : codes L89.2-L89.4 en DAS si non présent à l'entrée

Restriction : utiliser la liste PSI ATIH 2024 pour cohérence inter-établissement.
```

### 2. Définition de l'unité de service et du dénominateur

```
Unité d'agrégation :
  - Service = numéro UM (variable num_um) — granularité fine
  - Type UM (variable type) — granularité fonctionnelle (méd/chir/réa/SSR)
  - Pôle clinique — agrégation supérieure

Dénominateur (au choix selon l'objectif) :
  - n_séjours_service : taux d'EIG par séjour (le plus courant)
  - n_journées : taux par journée — adapté pour les services à long séjour
  - n_lits × jours_an : taux par lit-jour — comparable inter-tailles

Filtres standards :
  - Exclure CMD 28 (séances) et CMD 14 (obstétrique normale) des dénominateurs
  - Exclure UM passage urgences (séjour < 24h) sauf surveillance dédiée
```

### 3. Calcul du Gini

```r
# Calcul du Gini pondéré (chaque service compte selon sa taille)
gini_pondere <- function(eig, poids) {
  ord  <- order(eig / poids)
  eig  <- eig[ord]
  poids <- poids[ord]
  cum_pop <- cumsum(poids) / sum(poids)
  cum_eig <- cumsum(eig)   / sum(eig)
  # Aire sous la Lorenz (méthode trapèzes)
  aire <- sum(diff(c(0, cum_pop)) * (cum_eig + lag(cum_eig, default = 0)) / 2)
  1 - 2 * aire
}

G <- gini_pondere(n_eig_par_service, n_sejours_par_service)

# Bootstrap pour IC95
G_boot <- replicate(1000, {
  idx <- sample(seq_along(eig), replace = TRUE)
  gini_pondere(eig[idx], poids[idx])
})
IC95 <- quantile(G_boot, c(0.025, 0.975))
```

### 4. Indicateurs complémentaires

```
Part Top-20% (P20) :
  Trier les services par taux décroissant
  P20 = part des EIG portée par les 20% des services au sommet

Ratio Palma-like :
  Palma = (% EIG du top 10%) / (% EIG du bottom 40%)
  Plus sensible aux extrêmes que le Gini

Atkinson(ε = 0.5) :
  A = 1 − [ (1/n) Σᵢ (xᵢ/μ)^(1−ε) ]^(1/(1−ε))
  Avec ε = 0.5 : sensible mais pas extrême
  Avec ε → ∞  : domine par le pire service
```

### 5. Décomposition GHT (within / between)

```
Décomposition Theil-like sur deux niveaux (établissement → service) :
  G_total = G_within + G_between + interaction

G_within  : moyenne pondérée des Gini intra-établissement
G_between : Gini calculé sur les taux moyens des établissements

Interprétation :
  - G_between dominant : hétérogénéité inter-établissements (problème territorial)
  - G_within dominant  : hétérogénéité intra-établissement (problème de service)
```

## Utilité

- **Cibler l'audit qualité** : avec un Gini = 0.55 et un Top-20% portant 65% des EIG, l'audit qualité doit prioritairement cibler ces 2-3 services — économie majeure de ressources qualité par rapport à un audit calendaire systématique
- **Distinguer problème localisé vs systémique** : un EIG élevé + Gini élevé = problème de service spécifique (changement de protocole local) ; EIG élevé + Gini faible = problème transversal (formation, organisation des soins, environnement) — leviers d'action très différents
- **Suivi de l'effet d'un plan d'action** : après audit ciblé sur le Top-20%, le Gini doit baisser (homogénéisation) tandis que le taux global baisse — découpler ces deux dimensions permet d'évaluer si l'amélioration est ciblée ou diffuse
- **Comparaison inter-établissements GHT** : deux CH avec le même taux global d'EIG mais l'un avec Gini = 0.30 (homogène) et l'autre avec Gini = 0.65 (concentré) ont des structures qualité radicalement différentes — informer la stratégie GHT
- **Identification de services-référence** : les services en bas de la courbe de Lorenz (faible part d'EIG malgré un volume d'activité élevé) sont des **best practices** internes — sources d'apprentissage organisationnel reproductibles
- **Argumentaire pour la concentration d'activité** : si un service avec Gini local élevé concentre les EIG sur quelques actes complexes, transférer ces actes vers un site mieux équipé est statistiquement justifié
- **Décomposition GHT** : isoler la part de l'inégalité due aux différences inter-établissements vs intra-établissement oriente la gouvernance qualité (commission territoriale vs CMG locale)

## Sources de Données

- **PMSI MCO RSA** : `ident`, `finess`, `finessgeodp` ; codes complications via `dp`, `dr` et DAS (variable `diag` table `diag`)
- **PMSI MCO um** : variable `num_um` et `type` pour la granularité service ; jointure sur `ident`
- **PMSI MCO acte** : variable `acte` pour identifier les actes index et de reprise (réinterventions)
- **Référentiel PSI ATIH** : codes CIM-10 et CCAM identifiant les EIG (PSI 03, 04, 09, 11, 12, 13, 14, 15) — disponible sur scansante.fr
- **Référentiel HAS Indicateurs Qualité Sécurité Soins (IQSS)** : définitions standardisées des EIG pour cohérence nationale
- **PMSI MCO chaîné (id_hospit_ipp)** : `ipp_c` pour identifier les réinterventions à séjours ultérieurs
- **(Optionnel) Logiciel de signalement local** : pour les EIG non codés au PMSI (chutes sans fracture, erreurs médicamenteuses sans conséquence) — complète l'analyse PMSI mais n'est pas comparable inter-établissement

## Exemple de Valeurs

- **CHU régional (1 200 lits, 25 services chirurgicaux)** :
  Taux EIG global = 4.2/100 séjours
  Gini = 0.48 [IC95 0.42 — 0.54]
  P20 = 58% (les 5 services au sommet portent 58% des EIG)
  Top services : neurochirurgie (8.5/100), chirurgie cardiaque (7.1/100)
  → Concentration modérée — audit ciblé pertinent sur neurochirurgie

- **CH périphérique (250 lits, 8 services)** :
  Taux EIG global = 3.1/100 séjours
  Gini = 0.62 [IC95 0.48 — 0.78]
  P20 = 70% (les 1-2 services au sommet portent l'essentiel)
  → Concentration forte — un seul audit dédié probablement suffisant

- **Clinique privée orthopédique spécialisée (5 services)** :
  Taux EIG global = 1.8/100 séjours
  Gini = 0.18 [IC95 0.10 — 0.28]
  → Distribution homogène — qualité globalement bonne et uniforme
  → Levier : maintenir, pas de service à problème particulier

- **Plage attendue par type d'établissement (sur GHM chirurgicaux)** :
  - CHU : Gini ∈ [0.40 — 0.55] (hétérogénéité naturelle des spécialités)
  - CH : Gini ∈ [0.30 — 0.65]
  - Cliniques spé. : Gini ∈ [0.10 — 0.30]
  - GHT (entre établissements) : G_between ∈ [0.10 — 0.25]

- **Effet d'un programme qualité ciblé** :
  Avant audit : Gini = 0.62, P20 = 70%
  Après 12 mois : Gini = 0.42, P20 = 50% (homogénéisation)
  Taux global : 4.2 → 3.5 (baisse simultanée) → effet ciblé efficace
  Si le taux baisse mais Gini augmente → amélioration partielle, pertes à un endroit

- **Décomposition GHT (8 établissements)** :
  G_total = 0.51, G_within = 0.38, G_between = 0.13
  → 75% de l'inégalité est intra-établissement — la priorité GHT est d'aider
    chaque établissement à homogénéiser ses services

## Limites

- **Sensibilité au choix du dénominateur** : un Gini calculé sur "EIG par séjour" et un autre sur "EIG par journée d'hospitalisation" peuvent donner des résultats très différents — un service de réa long-séjour aura peu d'EIG par journée mais beaucoup par séjour ; documenter le choix et le maintenir cohérent dans le temps
- **Effet de la taille des unités** : avec 4-5 services seulement, le Gini est instable et peu interprétable ; un IC95 par bootstrap est indispensable ; à moins de 8 unités, préférer simplement la part Top-20% comme indicateur descriptif
- **Hétérogénéité des services** : comparer un service de réanimation à un service de médecine ambulatoire produit mécaniquement un Gini élevé qui ne reflète pas un problème qualité — toujours interpréter dans des groupes homogènes (chir vs méd vs réa séparément)
- **Codage des EIG dépendant de la culture qualité** : les établissements qui codent rigoureusement leurs EIG apparaîtront *paradoxalement* moins bons que ceux qui sous-codent — biais majeur dans la comparaison brute, partiellement corrigeable par le rapport DAS / DP comme proxy de la qualité de codage
- **Pas de causalité** : un Gini élevé ne signifie pas qu'un service est "à blâmer" — il peut concentrer les patients à haut risque (réa, oncologie) ; l'ajustement casemix par modèle logistique préalable est nécessaire pour rendre les taux comparables
- **Granularité UM mal renseignée** : dans certains établissements, le numéro UM est pseudonymisé ou mal stable d'une année à l'autre, rendant le suivi temporel difficile — vérifier la stabilité des codes UM avant analyse longitudinale
- **Pas un indicateur HAS officiel** : à utiliser en interne pour le pilotage, pas pour comparaison publique inter-établissements (qui exigerait standardisation rigoureuse)

## Références

- [Gini C. — Variabilità e mutabilità, Studi Economico-Giuridici Università di Cagliari 1912] — article fondateur
- [Atkinson A.B. — On the measurement of inequality, J Economic Theory 1970](https://doi.org/10.1016/0022-0531(70)90039-6) — alternative paramétrable
- [Nicholson S., Pauly M.V. et al. — Measuring the effects of work overload on quality of patient care, Health Affairs 2005](https://doi.org/10.1377/hlthaff.24.5.1303) — application Gini en santé
- [Asada Y. — Health Inequality: Morality and Measurement, Univ. of Toronto Press 2007] — application aux indicateurs qualité
- [Cobham A., Sumner A. — Is It All About the Tails? The Palma Measure of Income Inequality, CGD Working Paper 2013] — ratio Palma
- [HAS — Indicateurs Qualité et Sécurité des Soins (IQSS), portail Scope Santé](https://www.scopesante.fr/)
- [ATIH — Indicateurs PSI ATIH, ScanSanté](https://scansante.fr/)
- [DREES — Méthodologie de l'analyse des inégalités en santé, Document de travail 2018]
