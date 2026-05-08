# Taux de Chirurgie Ambulatoire sur les 55 Gestes Marqueurs

## Définition
Le **taux de chirurgie ambulatoire sur les 55 gestes marqueurs (GM)** est l'indicateur de référence national pour suivre le développement et la pertinence de la chirurgie ambulatoire en France. La liste des **55 gestes marqueurs** (MSAP — *mises sous accord préalable*) a été co-construite par la CNAM et les sociétés savantes à partir de 2008, étendue progressivement de 17 (2009) à 38 (2012), 43 (2013) puis **55 gestes en 2015**. Ces actes sont considérés par la HAS, l'ATIH et l'Assurance Maladie comme **substituables en ambulatoire** dans la grande majorité des cas, c'est-à-dire qu'ils peuvent être réalisés en hospitalisation de jour (séjour ≤ 0 nuit) sans perte de qualité ni de sécurité.

L'indicateur est suivi par l'application **Visuchir** (CNAM) et **ScanSanté** (ATIH), et figure dans les CPOM État–ARS 2024–2028 avec une **cible nationale de 75 % en 2028** (cible long terme : 80 %). Il est utilisé pour piloter l'objectif national de virage ambulatoire et pour la modulation tarifaire.

Formule :

```
Taux chir-ambu GM = (séjours en mode ambulatoire avec un acte CCAM
                     dans la liste des 55 gestes marqueurs)
                    / (séjours total avec un acte CCAM
                       dans la liste des 55 gestes marqueurs)
                    × 100
```

Positionnement vs indicateurs existants : indicateur de **pertinence des modalités de prise en charge**, complémentaire des indicateurs de qualité (REH3-CA pour la sécurité de l'ambulatoire, indicateurs de processus IPAQSS-CA pour l'organisation).

## Calcul

```
Étape 1 — Identifier les séjours avec geste marqueur
  RSA avec ≥ 1 acte CCAM appartenant à la liste des 55 GM
  (table de référence ATIH, mise à jour annuelle, intégrée à la fonction
   groupage et restituée par Visuchir)

Étape 2 — Distinguer ambulatoire vs hospitalisation complète
  Mode ambulatoire (numérateur) :
    GHM en J (ex : 02C05J, 06C04J, ...) OU
    DUREE_SEJOUR = 0 (entrée et sortie le même jour) avec mode hospitalisation 0
    (séjour de jour MCO)

  Hospitalisation complète (au dénominateur) :
    GHM en niveau 1, 2, 3, 4 (T) ou DUREE_SEJOUR ≥ 1

Étape 3 — Calcul
  Taux global = (Σ séjours GM ambu) / (Σ séjours GM total) × 100

  Décomposition recommandée :
    - Par geste marqueur (GM_id, 55 lignes)
    - Par CMD (par grand domaine : ophtalmo, ORL, digestif, ortho, ...)
    - Par établissement / GHT
```

**Précisions méthodologiques :**
- La liste des 55 GM est définie par actes CCAM, susceptibles de mises à jour mineures annuelles (ATIH publie la table de correspondance officielle).
- L'indicateur HAS IQSS-CA (processus en chirurgie ambulatoire) est distinct : il évalue l'organisation et la qualité du parcours en ambulatoire, pas le taux.
- Visuchir produit également un **taux substitutif théorique** (potentiel d'ambulatorisation supplémentaire) à partir d'un benchmark des 10 % d'établissements les plus performants.

Variables PMSI clés : `NUM_RSA`, `GHM`, `DUREE_SEJOUR`, `MODE_HOSPITALISATION`, codes `CCAM` (table A), table de référence GM ATIH.

## Utilité
- **Pilotage stratégique GHT** : suivi de la trajectoire vers la cible 75 % (CPOM 2024–2028) et 80 % long terme.
- **Allocation capacitaire** : un taux faible identifie un sous-développement des UCA (unités de chirurgie ambulatoire) — leviers : organisation, brancardage, programmation.
- **Comparaison inter-établissement** : Visuchir permet le benchmark national par geste, mettant en évidence les marges de progression.
- **Justification CPOM et MIG** : composante de la négociation contractuelle ARS.
- **Pertinence économique** : la chirurgie ambulatoire est associée à une réduction des coûts de séjour de 20-40 % à activité équivalente (DREES).
- **Suivi de la qualité conjoint** : à coupler obligatoirement avec REH3-CA (HAS) pour vérifier que la croissance ambulatoire ne s'accompagne pas d'une dégradation de la sécurité.
- **Indicateur GHT de pertinence territoriale** : disparité forte entre établissement pivot et CH périphériques, levier de mutualisation.

## Sources de Données
- **PMSI MCO** : RSA, GHM, durée de séjour, mode d'hospitalisation, actes CCAM.
- **Table ATIH des 55 gestes marqueurs** : table officielle de correspondance CCAM ↔ geste marqueur (mise à jour annuelle, intégrée à la fonction groupage).
- **Visuchir (CNAM)** : data-visualisation officielle des taux par établissement et geste.
- **ScanSanté (ATIH)** : restitution publique des taux de chirurgie ambulatoire par établissement.
- **Référentiel CCAM** (mise à jour annuelle ATIH) pour le suivi des évolutions.

## Exemple de Valeurs
*Sources : Visuchir CNAM 2024 ; ATIH ScanSanté ; HAS IQSS-CA.*

- **Taux national GM tous secteurs** : ~70-72 % en 2023-2024 (cible CPOM : 75 % en 2028).
- **Cliniques privées** : ~74 % en 2024 (Visuchir).
- **Public CH/CHU** : ~65-68 % en 2024 (rattrapage en cours).
- **Plage par geste marqueur** :
  - Cataracte (BFGA004) : > 98 % (référence quasi-systématique en ambulatoire)
  - Adénoïdectomie / amygdalectomie : 60-80 %
  - Cure de hernie inguinale : 70-85 %
  - Chirurgie du canal carpien : > 95 %
  - Cholécystectomie laparoscopique : 30-50 % (encore bas, fort potentiel)
- **Plage inter-établissement** : 35 % – 90 % selon mix de gestes et culture organisationnelle.
- **Cible long terme HAS / CNAM** : 80 % moyenne nationale, certaines spécialités > 95 %.

## Limites
- **Pas d'ajustement case-mix patient** : taux brut ne tient pas compte des comorbidités (ASA, âge), ce qui peut désavantager les CHU à patientèle plus à risque.
- **Évolution de la liste** : la liste des GM peut évoluer (ajout / retrait), nécessitant des recalculs rétrospectifs pour comparaisons longitudinales.
- **Effet plafond par geste** : certains gestes (cataracte) sont à 98+ %, peu de marge ; la cible globale n'est atteignable que par augmentation des gestes à fort potentiel résiduel (digestif, urologie).
- **Pertinence vs sécurité** : un taux élevé sans suivi REH3-CA peut masquer une dégradation de la qualité ; suivi conjoint impératif.
- **Programmation et structures** : le taux dépend en partie de l'offre capacitaire UCA, pas seulement des décisions cliniques.
- **Volume cible minimal** : ≥ 100 séjours GM/an par geste pour stabilité statistique.
- **Comparaison internationale** : la liste des 55 GM est française, comparaison directe avec OCDE limitée à un sous-ensemble (cataracte, hernie, cholécystectomie).

## Références
- [HAS — IQSS Indicateurs de processus en chirurgie ambulatoire (IPAQSS-CA)](https://www.has-sante.fr/jcms/c_2807207/fr/iqss-2024-ca-indicateurs-de-processus-en-chirurgie-ambulatoire-campagne-de-recueil-des-indicateurs-de-qualite-et-de-securite-des-soins)
- [HAS — Recommandations organisationnelles : guide diagnostic externe chirurgie ambulatoire](https://www.has-sante.fr/jcms/c_1604615/fr/recommandations-organisationnelles-guide-de-diagnostic-externe-chirurgie-ambulatoire)
- [ATIH — ScanSanté Indicateurs globaux GDR Chirurgie ambulatoire](https://www.scansante.fr/applications/action-gdr-chirurgie-ambulatoire)
- [CNAM — Visuchir guide utilisateur](https://www.scansante.fr/sites/default/files/content/450/visuchir_guide_utilisateur.pdf)
- [Sécurité Sociale — Évaluation de la chirurgie ambulatoire (PLFSS 2024)](https://evaluation.securite-sociale.fr/home/maladie/2114-chirurgie-ambulatoire.html)
- Assemblée Nationale — Rapport sur la chirurgie ambulatoire (2020).
