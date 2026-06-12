# Ratio Journées Alternatives à l'Hospitalisation Complète vs Hospitalisation Complète

## Définition
Le **ratio des alternatives à l'hospitalisation complète** mesure le poids relatif des modes de prise en charge **alternatifs à l'hospitalisation conventionnelle** (hospitalisation de jour MCO, hospitalisation à domicile, chirurgie ambulatoire, séances) rapporté aux journées d'hospitalisation complète. Cet indicateur agrégé est mis en avant par la DREES dans son *Études et Résultats* du **13 novembre 2025** (« Dans les établissements de santé en 2024, la baisse du nombre de lits ralentit et les alternatives à l'hospitalisation complète poursuivent leur progression ») comme **marqueur structurant du virage ambulatoire**.

Formule :

```
Ratio Alt/HC = (journées_HJ_MCO + journées_HAD + séjours_chir_ambu × 1)
               / journées_HC_MCO

Variantes :
  Indice global = (journées totales en alternatives, exprimées en équivalents-journées)
                  / (journées totales hospi complète)

  Part alternatives = numérateur / (numérateur + dénominateur)
```

Positionnement vs indicateurs existants : différent de `taux_ambulatoire.md` (chirurgie ambulatoire seule) et de `taux_recours_had.md` (HAD seul). Le ratio Alt/HC agrège l'ensemble des modes substitutifs et constitue le marqueur synthétique de la trajectoire DREES.

## Calcul

```
Étape 1 — Comptabilisation des journées d'alternatives
  a) Hospitalisation de jour MCO (HJ) :
     RSA avec GHM en niveau J (`duree` = 0, ambu)
     1 séjour = 1 journée HJ par convention
  b) Hospitalisation à domicile (HAD) :
     Source : RAPSS — somme des journées HAD (variable `nbjsej` de la table `fixe_sej`)
  c) Chirurgie ambulatoire (CA) :
     Sous-ensemble des HJ MCO avec acte CCAM chirurgical
     (peut faire double comptage avec HJ — préciser le périmètre)

Étape 2 — Comptabilisation des journées d'hospitalisation complète
  Journées HC MCO :
    Σ `duree` pour RSA en hospitalisation complète
    Exclusions : séances (CMD 28), GHM J (ambu)

Étape 3 — Choix de la formule
  Variante A — Ratio simple (préférée DREES) :
    Ratio = (journées HJ + journées HAD) / journées HC
  Variante B — Avec chirurgie ambulatoire pondérée :
    Ratio_pondéré = (journées HJ + journées HAD + 1 × nb séjours CA)
                    / journées HC

Étape 4 — Décompositions recommandées
  - Par secteur : MCO, SSR/SMR, Psy
  - Par établissement : trajectoire individuelle
  - Par CMD : disciplines les plus avancées dans le virage
  - Évolution annuelle : suivi de la pente
```

Variables PMSI clés : `ghm2`, `duree` (MCO), type d'hospitalisation selon le champ (niveau J du GHM en MCO, `fa` en psy), `nbjsej` (HAD, table `fixe_sej`), `CMD`, `finessgeo`. Sources hétérogènes : RSA (MCO), RAPSS (HAD), RHA (SSR), RPSA (Psy).

## Utilité
- **Pilotage stratégique GHT** : marqueur synthétique de la transformation capacitaire du GHT, alignement sur la trajectoire DREES nationale.
- **Justification des fermetures de lits** : un ratio Alt/HC en hausse rapide soutient la conversion lits HC → places HJ/HAD.
- **Comparaison inter-GHT** : positionnement de la dynamique de transformation versus territoires comparables.
- **Suivi des plans HAD** : composante essentielle du Plan national de développement HAD (cible doublement HAD).
- **Détection des inerties** : identification des établissements / disciplines en retard sur le virage.
- **Modélisation capacitaire** : prévision des besoins en lits HC à 5-10 ans selon la pente du ratio.
- **Indicateur GHT pour CPOM** : suivi de l'engagement de transformation capacitaire dans les contrats État–ARS 2024-2028.

## Sources de Données
- **PMSI MCO** : RSA, GHM, durée de séjour, mode d'hospitalisation.
- **PMSI HAD** : RAPSS, journées HAD.
- **PMSI SSR** : RHA pour suivi alternatif SSR (hospitalisation à temps partiel SSR).
- **DREES — ER 13/11/2025** : référence pour la lecture nationale de l'indicateur.
- **DREES Panorama Établissements de santé** : contexte volumétrique.
- **ATIH ScanSanté** : restitution publique des activités par mode.
- **SAE** : capacités installées (lits HC vs places HJ/HAD) pour mise en regard du ratio.

## Exemple de Valeurs
*Sources : DREES ER 13/11/2025, Panoramas DREES 2024 et 2025.*

- **Volumes nationaux 2022 (DREES Panorama 2024)** :
  - HC MCO : 10,5 M séjours (DMS 5,6 j ≈ 58,8 M journées)
  - HJ partielle MCO : 17,9 M journées
  - HAD : 6,8 M journées
- **Ratio (HJ + HAD) / HC France 2022** : ~(17,9 + 6,8) / 58,8 ≈ **0,42**.
- **Ratio (HJ + HAD) / HC France 2024** : tendanciellement en hausse (≈ 0,45-0,48 attendu selon ER 1344).
- **Plage par établissement** : 0,15 (établissement à dominante HC) à 0,80 (établissement très tourné HJ/HAD).
- **CHU** : ratio ~0,40-0,55 (mix programmée / non programmée).
- **CH spécialisé périphérique** : ratio ~0,20-0,35 (dominante HC traditionnelle).
- **Évolution attendue** : pente de ~+1 à +2 % par an dans les GHT engagés.

## Limites
- **Agrégation d'unités hétérogènes** : 1 journée HJ ≠ 1 journée HAD ≠ 1 journée HC en intensité de soins ; le ratio brut ne pondère pas par lourdeur.
- **Convention de comptage HJ** : une journée HJ peut couvrir plusieurs heures à plusieurs RSA, comptabilisation parfois discutable (chimio = 1 séance vs 1 HJ).
- **Double comptage potentiel** : les chirurgies ambulatoires sont à la fois en HJ et en chirurgie ambulatoire — préciser le périmètre.
- **Effet de structure** : un établissement spécialisé en chimiothérapie (séances HJ massives) a un ratio mécaniquement très haut sans transformation réelle.
- **Pas un indicateur de qualité** : un ratio élevé ne garantit pas la pertinence de chaque substitution.
- **Sécurité de l'ambulatoire** : à coupler obligatoirement avec REH3-CA (HAS) et indicateurs HAD.
- **HAD inégalement développée** : forte hétérogénéité territoriale du HAD en France (couverture ARS), biais inter-territoires.
- **Évolutions tarifaires** : modifications T2A peuvent inciter mécaniquement au virage sans modification réelle de la pratique.

## Références
- [DREES — Études et Résultats, 13 novembre 2025 : alternatives à l'hospitalisation complète](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/etudes-et-resultats/251113_ER_etablissements-de-sante)
- [DREES — Panorama Établissements de santé édition 2024 (données 2022)](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/panoramas-de-la-drees/240718_Panorama_EtablissementsSante2024)
- [DREES — Panorama Établissements de santé édition 2025](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- [DREES — ER n°1344, juillet 2025](https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-07/ER1344%20Etablissements%20de%20sante%CC%81_MEL.pdf)
- [ATIH — Guides méthodologiques PMSI MCO, HAD, SSR, Psy](https://www.atih.sante.fr/)
- CPOM État–ARS 2024–2028 — objectifs de transformation capacitaire.
