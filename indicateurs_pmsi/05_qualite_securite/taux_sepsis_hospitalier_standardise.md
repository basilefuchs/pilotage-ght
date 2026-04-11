# Taux de Sepsis Hospitalier Standardisé

## Définition
Le taux de sepsis hospitalier standardisé mesure la proportion de séjours MCO dans lesquels un sepsis a été diagnostiqué et codé, rapportée à une valeur attendue calculée à partir du profil de risque de la patientèle (âge, comorbidités, type de séjour). Distinct du SHMI ou du taux de mortalité ajustée qui mesurent la mortalité globale toutes causes, cet indicateur est spécifique au sepsis — première cause de mortalité hospitalière dans les pays développés et pathologie pour laquelle la variabilité inter-établissements est particulièrement documentée. Il se décline en deux dimensions complémentaires : le **taux de sepsis documenté** (prévalence du codage, proxy de la vigilance diagnostique) et le **taux de mortalité par sepsis ajusté** (qualité de la prise en charge une fois le sepsis identifié). En France, les codes A40-A41 (sepsis à streptocoque, sepsis à d'autres germes) constituent le cœur du repérage, complétés par R65.2 (sepsis sévère) depuis la mise à jour CIM-10 FR. L'indicateur est calculable depuis le PMSI MCO sans accès au SNDS, et ses valeurs de référence sont accessibles via ScanSanté pour un benchmarking inter-établissements.

## Calcul
Le taux de sepsis hospitalier standardisé est calculé en deux niveaux depuis les données PMSI MCO :

**Niveau 1 — Taux de sepsis documenté (prévalence brute et ajustée) :**
```
Séjour avec sepsis = séjour MCO ayant au moins un code sepsis en DP ou DA :
  → A40.*  : sepsis à streptocoque
  → A41.*  : autres sepsis (A41.0 Staphylococcus aureus, A41.5 Gram négatif, etc.)
  → R65.2  : sepsis sévère (avec défaillance d'organe associée)
  → O85    : sepsis puerpéral (spécifique obstétrique, CMD 14)
  → A02.1  : salmonellose septicémique
  → B37.7  : sepsis à Candida

Taux brut de sepsis (‰) = (Séjours avec sepsis / Total séjours MCO) × 1000

Taux standardisé de sepsis = Taux observé / Taux attendu × 100
  → Taux attendu calculé par régression logistique sur :
     - Âge (tranches décennales)
     - Score de comorbidités (Charlson ou Elixhauser)
     - CMD (risque de sepsis variable selon la catégorie diagnostique)
     - Type d'établissement (CHU vs CHG vs clinique)
     - Présence d'un acte invasif (cathéter central, ventilation, chirurgie) — proxy via CCAM
```

**Niveau 2 — Mortalité par sepsis ajustée :**
```
Taux de mortalité par sepsis (%) = (Décès parmi séjours avec sepsis / Total séjours avec sepsis) × 100
  → Mode de sortie = 9 (décès) dans les séjours avec code A40-A41 en DP ou DA

Indice de mortalité par sepsis (IMS) = Taux observé de mortalité sepsis / Taux attendu × 100
  → IMS > 100 : mortalité sepsis supérieure à l'attendu → signal d'alerte
  → IMS < 100 : mortalité sepsis inférieure à l'attendu → performance favorable

Délai médian entre admission et codage du sepsis (jours) :
  → Proxy de la précocité du diagnostic : un délai long signale une reconnaissance tardive
  → Calculable depuis les dates d'entrée dans le RUM et le positionnement du code en DP vs DA
```

**Sous-indicateurs dérivés :**
```
Taux de sepsis communautaire (%) :
  → Sepsis en DP avec mode d'entrée depuis domicile (mode entrée = 8)
  → Mesure le sepsis à l'admission — reflet de la prévalence infectieuse communautaire

Taux de sepsis nosocomial (% des séjours) :
  → Sepsis en DA avec mode d'entrée domicile OU sepsis apparu >48h après l'admission
  → Proxy : sepsis en DA ET séjour > 3 jours ET pas de sepsis en DP
  → Indicateur de qualité de la prévention des infections associées aux soins (IAS)

Taux de sepsis post-opératoire (% des séjours chirurgicaux) :
  → Sepsis (A40-A41) en DA dans les séjours avec acte CCAM chirurgical en DP
  → Signal de qualité de la prévention des infections du site opératoire

Taux de sepsis avec bactériémie documentée (% des sepsis) :
  → Codage spécifique du germe (A40.0, A40.1, A41.0, A41.1, A41.2, A41.3, A41.5...)
  → Un fort taux de sepsis "sans précision" (A41.9) signale un sous-codage microbiologique
```

**Précisions méthodologiques :**
- La distinction sepsis communautaire vs nosocomial est une approximation dans le PMSI français, faute de flag POA. Le critère opérationnel "sepsis en DA + séjour long" est un proxy imparfait mais utilisé dans la littérature française.
- L'évolution des définitions internationales du sepsis (Sepsis-1 en 1992, Sepsis-3 en 2016 avec suppression du SIRS) a modifié les pratiques de codage — une rupture de tendance dans les séries temporelles peut refléter un changement de définition plutôt qu'une évolution clinique réelle.
- Le code R65.2 (sepsis sévère) a été introduit dans la CIM-10 FR plus tardivement qu'aux USA — vérifier sa disponibilité et son utilisation dans la version locale du dictionnaire CIM utilisée par l'établissement.

## Utilité
- **Surveillance de la performance de la prévention des infections associées aux soins (IAS)** : le taux de sepsis nosocomial est un proxy des IAS évitables — son évolution avant/après un programme de prévention (bundle central line, protocole d'hygiène des mains, antimicrobial stewardship) quantifie l'impact organisationnel de ces interventions.
- **Pilotage du programme d'antibiothérapie (antimicrobial stewardship)** : croiser le taux de sepsis avec les données de consommation d'antibiotiques (via SNDS/DCIR ou données pharmaceutiques locales) pour évaluer la cohérence entre la prévalence du sepsis et l'intensité du recours aux antibiotiques.
- **Détection des services à risque élevé** : stratifier le taux de sepsis par service/unité (réanimation, chirurgie lourde, hémato-oncologie, néonatologie) pour identifier les unités nécessitant un renforcement des mesures de prévention et une surveillance microbiologique renforcée.
- **Benchmark inter-établissements** : ScanSanté permet d'accéder aux taux de codage des codes A40-A41 par établissement — un taux structurellement inférieur à la moyenne peut signaler soit une meilleure prévention, soit un sous-codage du sepsis (même problème que pour la dénutrition).
- **Évaluation de la rapidité diagnostique** : dans les établissements ayant des données horaires (dossiers patients informatisés), le délai admission-diagnostic de sepsis est un indicateur de la qualité des protocoles de reconnaissance précoce (Sepsis-3, NEWS score) — le PMSI donne une approximation via le positionnement DP vs DA.
- **Dialogue avec les équipes d'hygiène et la cellule de gestion des risques** : les données PMSI sur le sepsis fournissent un argument objectif aux EOH (Équipes Opérationnelles d'Hygiène) pour prioriser les actions et négocier les ressources.

## Sources de Données
- **PMSI MCO local (DIM)** : codes A40-A41, R65.2 en DP et DA, croisés avec le mode de sortie et le mode d'entrée — calcul réalisable par le DIM sur les données locales.
- **ScanSanté** : accès aux taux de codage sepsis par établissement et comparaison inter-établissements — référence pour le benchmarking.
- **Données microbiologiques locales (laboratoire)** : non dans le PMSI, mais le croisement avec les hémocultures positives permet de valider la qualité du codage (un sepsis sans hémoculture positive peut légitimement exister, mais un fort taux de A41.9 "sans précision" sans bactériémie documentée signale un problème de rigueur diagnostique et de codage).
- **SNDS/DCIR** : pour analyser le devenir ambulatoire post-sepsis (consommation d'antibiotiques, consultations infectiologiques, réhospitalisations) dans les 6-12 mois suivant le séjour.

## Exemple de Valeurs
- **Taux brut de sepsis (A40-A41 en DP ou DA)** : 5-15 ‰ séjours MCO selon le type d'établissement — plus élevé dans les CHU et établissements avec réanimation (15-25 ‰) que dans les cliniques chirurgicales (2-5 ‰).
- **Mortalité hospitalière par sepsis** : 20-30 % dans les séjours avec sepsis en DP en France selon les études PMSI — jusqu'à 40-50 % pour le sepsis sévère (R65.2) avec défaillance multi-organes.
- **Ames et al. (Pediatr Crit Care Med 2018)** — pédiatrie, Pennsylvania : mortalité par sepsis 6,5 % (range 1,5-11,9 % selon l'hôpital) — illustration de la forte variabilité inter-établissements justifiant un benchmarking ajusté.
- **Évolution temporelle** : dans les établissements ayant déployé un programme "Surviving Sepsis" (bundle 1h-3h), réduction de la mortalité par sepsis de 15-25 % sur 3 ans dans les études randomisées.
- **Sepsis nosocomial (proxy)** : 1-3 ‰ séjours MCO — sous-estime probablement la réalité (prévalence estimée par les enquêtes de prévalence ECDC à 5-8 ‰ journées d'hospitalisation).

## Limites
- Le taux de sepsis PMSI est un indicateur de codage autant qu'un indicateur clinique : les établissements dont les DIM sont sensibilisés au codage du sepsis (enjeu T2A : sepsis sévère = CC ou CMA dans de nombreux GHM) coderont davantage, créant un biais de comparaison similaire à celui observé pour la dénutrition.
- La définition Sepsis-3 (2016) a supprimé les critères SIRS au profit de l'évaluation de la dysfonction d'organe (SOFA score) — cette évolution clinique n'est pas directement reflétée dans les codes CIM-10, qui n'ont pas été mis à jour en conséquence, créant une discordance entre pratique clinique et codage.
- L'indicateur ne distingue pas les sepsis liés aux dispositifs invasifs (cathéters, ventilation) des sepsis liés à une infection communautaire compliquée — distinction importante pour l'imputation de responsabilité entre prévention hospitalière et prise en charge communautaire.
- Dans les établissements sans réanimation, le sepsis sévère peut être orienté vers un CHU avant le décès, transférant le risque de mortalité et sous-estimant la performance de l'établissement initial — l'analyse doit tenir compte des transferts sortants.

## Références
- [Ames S.G. et al. — Hospital variation in risk-adjusted pediatric sepsis mortality, Pediatr Crit Care Med 2018](https://doi.org/10.1097/PCC.0000000000001502)
- [Singer M. et al. — The Third International Consensus Definitions for Sepsis (Sepsis-3), JAMA 2016](https://doi.org/10.1001/jama.2016.0287)
- [ATIH — Impact du codage des comorbidités infectieuses sur la classification GHM](https://www.atih.sante.fr/)
- [ScanSanté — Analyse des diagnostics A40-A41 par établissement](https://www.scansante.fr/)
- [ECDC — Point Prevalence Survey of Healthcare-Associated Infections in European hospitals](https://www.ecdc.europa.eu/)
