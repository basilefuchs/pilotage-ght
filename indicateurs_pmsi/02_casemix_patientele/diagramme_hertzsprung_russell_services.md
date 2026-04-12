# Diagramme de Hertzsprung-Russell des Services Hospitaliers

## Définition

Le **diagramme de Hertzsprung-Russell** (HR) est l'outil fondamental de classification stellaire en astrophysique : en portant les étoiles sur un graphe luminosité (axe Y) × température de surface (axe X), Ejnar Hertzsprung et Henry Norris Russell constatèrent en 1910 que les étoiles ne se distribuent pas aléatoirement mais se regroupent en familles naturelles — la **séquence principale** (la majorité des étoiles, dont le Soleil), les **géantes rouges** (lumineuses mais froides), les **naines blanches** (chaudes mais peu lumineuses), et les **supergéantes**. Chaque position sur ce diagramme révèle l'état évolutif de l'étoile.

Transposé aux services hospitaliers, le **Diagramme HR des Services Hospitaliers** (DHRSH) porte chaque service ou établissement sur un graphe bidimensionnel :
- **Axe Y (luminosité)** : volume d'activité — nombre de séjours, journées, ou valorisation totale
- **Axe X (température)** : complexité du casemix — poids GHM moyen, IP-DMS, Charlson médian, ou indice de complexité

Les "familles stellaires" hospitalières émergent naturellement :
- **Séquence principale** : relation volume/complexité attendue (services dans la norme)
- **Géantes rouges** : fort volume, faible complexité (usines à séjours simples)
- **Naines blanches** : faible volume, haute complexité (services ultra-spécialisés, rares)
- **Supergéantes** : fort volume ET forte complexité (CHU, services de recours)
- **Sous-naines** : faible volume ET faible complexité (services en difficulté structurelle)

Un service hors de la séquence principale est un outlier stratégique : soit une opportunité (niche de spécialisation), soit un signal d'alerte (inadéquation activité/ressources).

## Calcul

Construction des axes :

```
Axe Y — Luminosité (volume d'activité) :
  Option 1 : Nombre de séjours MCO sur 12 mois (N_séjours)
  Option 2 : Valorisation totale GHS (en M€) : Σ GHS_i × tarif_GHM_i
  Option 3 : Nombre de journées d'hospitalisation (PMSI RSA)
  → Normalisation recommandée : log₁₀(Y) pour compresser les grandes variations
    entre services (chirurgie cardiaque N=200 vs médecine interne N=3000)

Axe X — Température (complexité du casemix) :
  Option 1 : IP-DMS (Indice de Performance − Durée Moyenne de Séjour) :
    IP-DMS = DMS_service / DMS_nationale_casemix_mixé
    → IP-DMS < 1 : DMS plus courte que la référence nationale à casemix équivalent
    → IP-DMS > 1 : DMS plus longue

  Option 2 : Poids GHM moyen pondéré :
    W_moyen = Σ (N_GHM_i × Poids_GHM_i) / N_total
    → Mesure la sévérité économique du casemix (actes lourds = poids élevé)

  Option 3 : Indice de complexité composite :
    IC = 0.4 × Charlson_médian_normalisé
       + 0.3 × Fraction_GHM_niveau3-4
       + 0.3 × Poids_GHM_moyen_normalisé
    → Indicateur plus robuste, moins sensible aux biais de codage

  → Recommandation : utiliser W_moyen (poids GHM) en abscisse et log₁₀(N_séjours)
    en ordonnée pour la version de base entièrement calculable depuis le PMSI
```

Identification des familles et de la séquence principale :

```
Étape 1 — Calcul des coordonnées (X_i, Y_i) pour chaque service i

Étape 2 — Ajustement de la séquence principale :
  Régression linéaire (ou polynomiale d'ordre 2) de Y sur X :
  Y_attendu(X) = a + b × X   → "séquence principale" empirique du GHT ou du territoire

  Résidu de chaque service :
  ε_i = Y_i − Y_attendu(X_i)
  → ε_i > 0 : service "supra-lumineux" (plus actif que prévu pour sa complexité)
  → ε_i < 0 : service "sous-lumineux" (moins actif que prévu pour sa complexité)

Étape 3 — Classification en familles :
  Définir des zones par quadrant autour de (X_médian, Y_médian) :
    Quadrant I  (X > X_med, Y > Y_med) : "Supergéantes" — complexité ET volume élevés
    Quadrant II (X < X_med, Y > Y_med) : "Géantes rouges" — volume élevé, faible complexité
    Quadrant III (X < X_med, Y < Y_med) : "Sous-naines" — faible volume ET faible complexité
    Quadrant IV (X > X_med, Y < Y_med) : "Naines blanches" — haute complexité, faible volume

  Séquence principale : bande autour de la droite de régression (ε_i ∈ [−1σ ; +1σ])
  Outliers : services avec |ε_i| > 2σ
```

Évolution temporelle (diagramme HR dynamique) :

```
Calculer les coordonnées (X, Y) par année sur 3-5 ans :
  → Tracer les trajectoires de chaque service sur le diagramme
  → Trajectoire vers le quadrant I ("Supergéante") : montée en gamme stratégique
  → Trajectoire vers le quadrant III ("Sous-naine") : dévitalisation progressive
  → Oscillation autour de la séquence principale : service stable
  → Décrochage soudain vers le bas (Quadrant III) : signal de crise
```

## Utilité

- **Vision stratégique du positionnement de tous les services en un seul graphique** : le DHRSH remplace des dizaines de tableaux comparatifs par une représentation visuelle instantanément interprétable — la direction peut identifier d'un coup d'œil les services en pointe, les services en difficulté, et les outliers sans lire ligne par ligne des rapports d'activité
- **Identifier les services hors séquence principale comme sujets d'investigation prioritaire** : un service en quadrant IV ("naine blanche" — haute complexité, faible volume) est soit une référence de recours sous-reconnue (à valoriser et développer) soit un service sous-utilisé faute de visibilité (à promouvoir) ; un service en quadrant II ("géante rouge" — fort volume, faible complexité) produit beaucoup mais peu de valeur ajoutée — candidat à la reconversion ambulatoire
- **Benchmarking territorial** : positionner les établissements d'un territoire sur le DHRSH pour identifier les spécialisations complémentaires vs les recouvrements de niche (un GHT et une clinique privée en quadrant II sur le même GHM signalent une concurrence frontale directe)
- **Suivi des trajectoires stratégiques** : visualiser comment chaque service se déplace sur le diagramme au fil des années révèle les dérives progressives (montée ou chute de complexité, évolution du volume) avant qu'elles ne deviennent des crises — le mouvement sur le diagramme HR est l'indicateur de la dynamique stratégique
- **Support aux décisions de fusion/restructuration** : dans une démarche de restructuration du GHT, le DHRSH permet d'identifier les services complémentaires (à mutualiser ou spécialiser), les doublons (à fusionner), et les déserts de complexité (niches non couvertes sur le territoire)

## Sources de Données

- **PMSI MCO RSA** : nombre de séjours (Y), poids GHM moyen (X option 2), Charlson médian, fraction GHM niveau 3-4, IP-DMS — calculables directement depuis les extractions RSA standard par UM/service et par année civile
- **Base ATIH des poids GHM** : tarifs et poids relatifs par GHM — pour calculer la valorisation totale (axe Y option 2) et le poids moyen pondéré (axe X option 2) ; publiés annuellement et librement accessibles
- **IP-DMS national ATIH** : valeur de référence de la DMS nationale par GHM — pour calculer l'IP-DMS de chaque service (axe X option 1) dans un référentiel national commun

## Exemple de Valeurs

- **GHT semi-rural avec 8 services MCO** :

  Service chirurgie orthopédique : X = 2,1 (poids GHM), Y = 3,1 (log séjours) → Séquence principale
  Service chirurgie cardiaque : X = 4,8, Y = 2,3 → "Naine blanche" (haute complexité, faible volume)
  Service médecine interne : X = 1,2, Y = 3,5 → "Géante rouge" (fort volume, faible complexité)
  Service gastro-entérologie : X = 2,8, Y = 3,3 → Supergéante (quadrant I)
  Service dermatologie : X = 0,9, Y = 1,8 → "Sous-naine" (faible volume ET faible complexité)

  → Insights stratégiques :
    Chirurgie cardiaque ("naine blanche") : service de recours sous-dimensionné
      ou en déclin d'activité — investigation justifiée
    Médecine interne ("géante rouge") : fort volume de cas simples —
      potentiel de reconversion d'une partie de l'activité en ambulatoire
    Dermatologie ("sous-naine") : service en difficulté structurelle —
      fusion avec un service de médecine polyvalente à envisager

- **Trajectoire d'un service d'oncologie sur 5 ans** :
  2019 : X = 3,2, Y = 2,8 (séquence principale)
  2021 : X = 3,8, Y = 3,2 (montée vers supergéante — développement activité complexe)
  2023 : X = 4,2, Y = 3,5 → Supergéante confirmée
  → Dynamique de montée en gamme réussie, visible sur la trajectoire DHRSH

## Limites

- La position sur le diagramme HR dépend fortement du **niveau de granularité** de l'analyse (service vs pôle vs établissement) — un pôle chirurgical regroupant des activités très différentes (chirurgie cardiaque + orthopédie + viscéral) se retrouve en séquence principale alors que ses composantes sont aux antipodes du diagramme ; descendre au niveau des services individuels est nécessaire pour un diagnostic précis
- L'axe X (complexité) est sensible à la **qualité du codage PMSI** — un service qui code peu les diagnostics associés (DA) ou qui ne code pas les complications aura un poids GHM moyen artificiellement bas et apparaîtra "moins complexe" qu'il ne l'est réellement ; un audit de codage préalable est recommandé avant tout usage stratégique du DHRSH
- La "séquence principale" empirique est calculée depuis les données du GHT ou du territoire étudié — elle n'est pas une référence absolue mais une référence relative au groupe comparé ; un GHT où tous les services sont des "géantes rouges" n'a pas de séquence principale visible, car le groupe de référence est lui-même homogène ; utiliser la référence nationale ATIH comme baseline externe quand le groupe de comparaison local est insuffisamment diversifié

## Références

- [Hertzsprung E. — Zur Strahlung der Sterne, Zeitschrift für wissenschaftliche Photographie 1908 : première description de la classification HR]
- [Russell H.N. — Relations between the spectra and other characteristics of stars, Popular Astronomy 1914 : diagramme HR formalisé]
- [Carroll B.W., Ostlie D.A. — Introduction to Modern Astrophysics, Pearson 2006 : référence pédagogique complète sur le diagramme HR]
- [ATIH — Classification des séjours MCO : poids relatifs des GHM et IP-DMS (publication annuelle)](https://www.atih.sante.fr/)
- [DGOS — Analyse stratégique des GHT : outils de positionnement et de benchmarking (2020)](https://solidarites-sante.gouv.fr/)
