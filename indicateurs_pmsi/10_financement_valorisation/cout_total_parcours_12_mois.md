# Coût Total de Parcours sur 12 Mois

## Définition
Le coût total de parcours sur 12 mois est le coût cumulé de l'ensemble des dépenses de santé remboursées par l'Assurance Maladie pour un patient sur une fenêtre de 12 mois glissants, tous secteurs confondus : hospitalisations MCO, SSR, HAD, psychiatrie, consultations médicales de ville, actes paramédicaux, médicaments délivrés en officine, dispositifs médicaux, biologie et imagerie ambulatoire. Calculé depuis le SNDS par agrégation des données PMSI et du DCIR, il constitue la vision économique la plus complète du coût réel d'un patient ou d'une pathologie, intégrant les soins hospitaliers et ambulatoires dans une approche de parcours. Il se distingue fondamentalement du « coût par pathologie » intra-hospitalier (qui ne capture que le séjour) en révélant l'iceberg économique caché dans les soins de ville et le médico-social.

## Calcul
Le coût total de parcours est calculé par agrégation des remboursements Assurance Maladie sur 12 mois :

```
Coût total de parcours (€) = Coûts hospitaliers + Coûts ambulatoires + Coûts médicamenteux

Coûts hospitaliers (PMSI) :
  = Σ GHS (tarifs MCO) + Suppléments (réanimation, soins intensifs) + EXH + Forfaits HAD + GME SSR + ...

Coûts ambulatoires (DCIR) :
  = Σ Actes médicaux (NGAP + CCAM ville) + Actes paramédicaux (infirmiers, kiné, orthophonie)
  + Biologie (actes B) + Imagerie ambulatoire + Consultations spécialisées

Coûts médicamenteux (DCIR - TIERS PAYANT) :
  = Σ Médicaments remboursés en officine (délivrances DCIR)
  + Médicaments onéreux hospitaliers (rétrocessions, liste en sus)

Coûts dispositifs médicaux et autres :
  = DMI (dispositifs médicaux implantables, liste en sus PMSI)
  + Dispositifs médicaux de ville (DCIR - LPP)
  + Transports sanitaires (DCIR - VSL, ambulance)
```

**Indicateurs dérivés :**
```
Coût moyen de parcours par patient (€/patient/an) = Coût total / Nombre de patients

Distribution des coûts :
  → Part hospitalière (%) = Coûts PMSI / Coût total
  → Part ambulatoire (%) = Coûts DCIR hors médicaments / Coût total
  → Part médicamenteuse (%) = Coûts médicaments / Coût total

Concentration des coûts :
  → Part des 1 % de patients les plus coûteux dans le coût total
  → Part des 10 % de patients les plus coûteux dans le coût total

Coût marginal de la comorbidité :
  = Coût moyen parcours patients CCI ≥ 3 − Coût moyen parcours patients CCI = 0
```

**Précisions méthodologiques** :
- La fenêtre de 12 mois est centrée sur le séjour index (6 mois avant / 6 mois après) ou calculée sur l'année civile selon l'objectif de l'analyse.
- Les coûts sont exprimés en coûts remboursés (base de remboursement AMO) et non en coûts réels (qui incluent les restes à charge patient et la complémentaire) — une estimation du coût réel nécessite des données complémentaires.
- La standardisation sur l'âge, le sexe et les comorbidités (Elixhauser) est recommandée pour les comparaisons entre populations ou entre territoires.

## Utilité
- **Vision économique complète du patient** : le coût de parcours révèle que le coût hospitalier ne représente souvent que 40-60 % du coût total d'un patient chronique — les 40-60 % restants (médicaments, soins de ville, médico-social) sont invisibles dans le PMSI seul.
- **Identification des patients à très haute intensité économique** : les 1 % de patients les plus coûteux (« super-utilisateurs ») concentrent 20-30 % des dépenses totales — leur identification permet de cibler les programmes de case management à fort retour sur investissement.
- **Analyse médico-économique des pathologies** : comparer le coût total de parcours des patients atteints d'insuffisance cardiaque, de diabète ou de cancer selon leur filière de prise en charge pour identifier les organisations de soins les plus efficientes.
- **Évaluation des programmes d'intervention** : mesurer la réduction du coût de parcours 12 mois avant/après une intervention (programme ETP, déploiement d'une infirmière de coordination, HAD de transition) pour calculer son retour sur investissement.
- **Dialogue avec l'Assurance Maladie et l'ARS** : le coût total de parcours est l'indicateur de référence pour les négociations sur les nouveaux modes de financement (paiement au parcours, IPEP — Incitation à une Pratique tarifaire Efficiente et Pertinente).

## Sources de Données
- **SNDS (PMSI + DCIR)** : accès obligatoire — agrégation des remboursements AMO sur l'ensemble des postes de dépenses par NIR crypté sur 12 mois glissants.
- **PMSI MCO, SSR, HAD, PSY** : coûts hospitaliers (tarifs GHS, GME, HAD) issus des tableaux de valorisation ATIH.
- **DCIR (Données de Consommation Inter-Régimes)** : actes médicaux et paramédicaux, médicaments, biologie, imagerie, transports — remboursements AMO par poste de dépenses.
- **CNAM - Cartographie des pathologies** : outil national de stratification des patients par pathologie et par niveau de coût, construit sur le SNDS — référence méthodologique pour la segmentation des patients par profil économique.
- **Référence méthodologique** : CNAM, *Cartographie des pathologies et des dépenses*, mise à jour annuelle — segmentation de la population en 56 groupes de pathologies avec coûts moyens de parcours associés.

## Exemple de Valeurs
- **Coût moyen de parcours (population générale adulte hospitalisée)** : 8 000-15 000 €/patient/an selon le profil de comorbidité (données SNDS).
- **Insuffisance cardiaque** : 12 000-20 000 €/patient/an ; part hospitalière ~55 %, médicaments ~20 %, ambulatoire ~25 %.
- **Cancer (tous stades)** : 15 000-40 000 €/patient/an selon la localisation et le stade ; part des médicaments onéreux (liste en sus) pouvant atteindre 40-60 % du coût total.
- **Diabète de type 2 sans complications** : 3 000-5 000 €/patient/an ; part ambulatoire dominante (~60-70 %), hospitalisations rares.
- **Patients polypathologiques (CCI ≥ 4)** : coût moyen > 25 000 €/patient/an ; les 5 % de patients les plus coûteux concentrent 40-50 % des dépenses totales du territoire.
- **Concentration des coûts** : les 1 % de patients les plus coûteux représentent en moyenne 25 % du coût total de parcours d'une population (données CNAM, cartographie des pathologies).
- **Part du coût hospitalier dans le coût total** : 45-65 % selon la pathologie — les pathologies chroniques bien équilibrées (diabète, HTA) ont une part hospitalière plus faible (~30-40 %).

## Limites
- **Accès SNDS obligatoire** : cet indicateur est le plus exigeant techniquement et réglementairement — il nécessite un accès complet au SNDS (PMSI + DCIR) avec autorisation CNIL/INDS et une infrastructure d'analyse adaptée.
- Les coûts sont exprimés en remboursements AMO et non en coûts réels : le reste à charge patient et les dépenses non remboursées (médecines alternatives, dépassements d'honoraires) sont exclus.
- Le coût de parcours intègre des dépenses hors du contrôle de l'hôpital (médicaments de ville, soins infirmiers) — l'établissement ne peut agir que sur la composante hospitalière ; l'interprétation doit éviter d'imputer l'ensemble du coût à la qualité des soins hospitaliers.
- Les données DCIR sont disponibles avec un délai de 3 à 6 mois, rendant les analyses en temps quasi-réel impossibles depuis le SNDS standard.
- La comparaison du coût de parcours entre territoires est biaisée par les différences de démographie, d'épidémiologie et d'offre de soins — une standardisation rigoureuse est indispensable avant toute interprétation.

## Références
- [CNAM - Cartographie des pathologies et des dépenses](https://www.assurance-maladie.ameli.fr/etudes-et-donnees/par-theme/pathologies/cartographie-assurance-maladie)
- [SNDS - Système National des Données de Santé](https://www.snds.gouv.fr/)
- [Health Data Hub - Accès aux données de parcours](https://www.health-data-hub.fr/)
- [ATIH - Valorisation des séjours hospitaliers](https://www.atih.sante.fr/)
- [DREES - Dépenses de santé en France](https://www.drees.solidarites-sante.gouv.fr/)
