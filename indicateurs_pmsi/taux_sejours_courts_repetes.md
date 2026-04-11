# Taux de Séjours Courts Répétés (Revolving Door)

## Définition
Le taux de séjours courts répétés, ou phénomène de « porte tournante » (revolving door), mesure la proportion de patients présentant au moins 3 hospitalisations courtes (durée ≤ 3 jours) pour un même motif pathologique (même groupe de GHM ou même code diagnostique principal) dans une fenêtre de 12 mois glissants. Cet indicateur signale une prise en charge chronique insuffisante, une rupture répétée du continuum de soins ou une grande vulnérabilité médico-sociale empêchant la stabilisation ambulatoire. Il se distingue du simple taux de réadmission (qui mesure le retour après un séjour index unique) en ciblant spécifiquement les patients en situation de recours itératif non planifié aux soins hospitaliers. Calculé par chaînage PMSI sur le NIR crypté, il identifie des patients que l'hôpital « voit souvent mais ne soigne pas durablement », révélant des défaillances dans l'organisation de la prise en charge ambulatoire ou médico-sociale post-hospitalière.

## Calcul
Le taux de séjours courts répétés est calculé par chaînage longitudinal des séjours PMSI :

```
Séjour court = séjour MCO avec durée ≤ 3 jours (date sortie − date entrée ≤ 3)
  → Exclusions : chirurgie ambulatoire programmée (DP chirurgical + mode entrée domicile programmé)
  → Exclusions : séances (dialyse, chimiothérapie, radiothérapie — GHM de séances)

Patient "revolving door" = patient avec ≥ 3 séjours courts sur le même motif dans les 12 mois glissants
  → Même motif = même racine de GHM (8 premiers caractères) OU même code DP à 3 caractères CIM-10

Taux de séjours courts répétés (%) = (Patients revolving door / Total patients hospitalisés) × 100

Taux par motif (%) = (Patients revolving door sur motif M / Total patients hospitalisés pour motif M) × 100
```

**Construction depuis le PMSI :**
```
Étape 1 — Chaînage des séjours par patient (NIR crypté) sur 12 mois glissants :
  → Agrégation des RSS par patient sur les FINESS du GHT
  → Calcul de la durée de chaque séjour (date_sortie − date_entrée)

Étape 2 — Identification des séjours courts non programmés :
  → Filtre : durée ≤ 3 jours ET GHM non classé en séance ET mode entrée ≠ mutation interne
  → Annotation du DP à 3 caractères et de la racine GHM pour chaque séjour court

Étape 3 — Détection des clusters de répétition :
  → Pour chaque patient, comptage des séjours courts par racine GHM sur la fenêtre de 12 mois
  → Patient revolving door si ≥ 3 séjours courts sur la même racine GHM

Étape 4 — Calcul des indicateurs :
  Taux global de patients revolving door (%)
  Nombre moyen de séjours courts par patient revolving door
  Délai médian entre séjours courts consécutifs (jours)
```

**Sous-indicateurs dérivés :**
```
Taux de séjours courts répétés par CMD (%) → identifie les grandes catégories diagnostiques
  à fort taux de porte tournante (psychiatrie, insuffisance cardiaque, BPCO, addictologie)

Taux de séjours courts répétés par profil social (codes Z) → corrèle la répétition
  avec la vulnérabilité médico-sociale documentée

Nombre moyen de jours entre deux séjours courts consécutifs → un délai < 7 jours signale
  une décompensation rapide liée à une insuffisance de prise en charge ambulatoire

Taux de conversion ambulatoire post-revolving door (%) = (Patients revolving door ayant
  bénéficié d'une prise en charge HAD ou d'un suivi SSIAD à 3 mois / Total revolving door) × 100
  → Mesure la capacité du GHT à proposer une alternative à l'hospitalisation répétée
```

**Précisions méthodologiques** :
- Le seuil de 3 jours pour définir un séjour court est le seuil standard dans la littérature internationale sur le revolving door hospitalier ; il peut être adapté à 2 jours pour les pathologies psychiatriques ou à 5 jours pour les pathologies complexes.
- L'exclusion de la chirurgie ambulatoire programmée est critique : les séjours de moins de 24 heures pour acte chirurgical planifié ne relèvent pas du revolving door mais d'une stratégie de soin.
- Le chaînage nécessite le NIR crypté disponible dans le PMSI — réalisable par le DIM sur les fichiers RSA du GHT sans nécessiter l'accès complet au SNDS pour la composante intra-GHT.
- Pour une vision complète incluant les hospitalisations dans d'autres établissements du territoire, l'accès au SNDS est nécessaire.

## Utilité
- **Identification des patients nécessitant une prise en charge intensive de coordination** : les patients revolving door sont les candidats prioritaires aux dispositifs de case management (DAC, infirmière de coordination, programme d'éducation thérapeutique) — leur identification précoce par le DIM permet de les orienter avant la troisième hospitalisation.
- **Signal de défaillance ambulatoire par pathologie** : un taux de revolving door élevé sur une racine GHM spécifique (insuffisance cardiaque, BPCO, décompensation diabétique) révèle une rupture dans la filière ambulatoire post-hospitalière pour cette pathologie — il déclenche une analyse de la coordination médecin traitant / spécialiste / infirmier libéral.
- **Détection de la précarité cachée** : le revolving door est fortement associé à la vulnérabilité médico-sociale (isolement, absence de soins ambulatoires, absence de médecin traitant) — les patients sans codes Z mais avec un pattern revolving door doivent bénéficier d'un bilan social systématique.
- **Évaluation des programmes de réduction des hospitalisations évitables** : mesurer l'évolution du taux de séjours courts répétés avant/après la mise en place d'une HAD de transition, d'un programme de télésurveillance ou d'une consultation de suivi à J+7 pour quantifier l'impact médico-économique de ces interventions.
- **Pilotage des capacités** : les séjours courts répétés mobilisent des lits de médecine sur de courtes durées de façon imprévisible, contribuant à la désorganisation des unités — leur quantification permet d'anticiper et de dimensionner les ressources en lits de médecine non programmée.
- **Dialogue avec l'Assurance Maladie** : les séjours courts répétés sur des pathologies comme l'insuffisance cardiaque ou le diabète sont explicitement ciblés dans les indicateurs de pertinence des soins de la CNAM — l'indicateur sert d'argument pour les négociations sur les nouveaux modes de financement (paiement au parcours).

## Sources de Données
- **PMSI MCO local (DIM)** : fichiers RSA chaînés par NIR crypté sur 12 mois glissants, pour les séjours intra-GHT — calcul réalisable par le DIM sans accès au SNDS.
- **SNDS (PMSI national)** : pour inclure les séjours courts répétés dans d'autres établissements du territoire (cliniques privées, CHU de recours) et calculer le taux de revolving door tous-établissements.
- **ScanSanté** : ne permet pas directement le calcul du taux de séjours courts répétés (absence de dimension longitudinale patient) — le calcul doit être réalisé localement par le DIM ou via le SNDS.
- **DCIR (SNDS)** : pour corréler le pattern revolving door avec l'absence de consommation de soins ambulatoires entre les séjours (absence de consultations, d'ordonnances) et identifier les ruptures de prise en charge ambulatoire.

## Exemple de Valeurs
- **Taux global de patients revolving door (≥ 3 séjours courts sur même motif en 12 mois)** : 2-5 % de la patientèle MCO dans les établissements de court séjour, avec des variations importantes selon la spécialité.
- **Psychiatrie et addictologie (CMD 19-20)** : taux de revolving door de 10-20 % — la plus forte prévalence de tous les secteurs, reflet des difficultés de stabilisation en ambulatoire et des ruptures de traitement.
- **Insuffisance cardiaque (CMD 5)** : 8-15 % de patients avec ≥ 3 hospitalisations courtes sur 12 mois — premier motif somatique de revolving door dans les établissements de médecine interne.
- **BPCO et insuffisance respiratoire (CMD 4)** : 6-12 % de revolving door, fortement associé au tabagisme actif et à la précarité sociale.
- **Décompensation diabétique (CMD 10)** : 5-10 % de revolving door, signal d'une absence de suivi ambulatoire structuré.
- **Délai médian entre deux séjours courts consécutifs** : 12-25 jours pour les pathologies chroniques décompensées (insuffisance cardiaque, BPCO) ; 5-10 jours pour les pathologies psychiatriques en phase de crise.
- **Nombre moyen de séjours courts par patient revolving door sur 12 mois** : 4-6 séjours chez les patients identifiés, pouvant dépasser 10 séjours chez les patients avec grande précarité sociale.
- **Réduction après intervention de coordination** : les programmes de télésurveillance pour l'insuffisance cardiaque réduisent le taux de revolving door de 30-50 % dans les études randomisées françaises et européennes.

## Limites
- La définition du seuil de 3 jours pour un séjour court est arbitraire et doit être adaptée selon la pathologie et les pratiques locales d'organisation des soins — une comparaison inter-établissements nécessite une harmonisation du seuil.
- Le chaînage intra-GHT sous-estime le revolving door réel : un patient qui alterne entre le GHT et une clinique privée ne sera pas identifié par le PMSI local — seul le SNDS permet une vision complète.
- L'indicateur ne distingue pas les séjours courts répétés inévitables (chimiothérapie fractionnée, transfusions répétées pour maladie chronique grave) des revolving doors évitables — le filtrage des séances et de la chirurgie ambulatoire est indispensable mais ne suffit pas.
- Le phénomène revolving door peut être partiellement une conséquence de la politique de l'établissement (sortie précoce pour libérer des lits) plutôt que d'une défaillance ambulatoire — l'interprétation nécessite de croiser avec la DMS et le taux d'occupation des lits.
- La mesure sur 12 mois glissants peut masquer des phénomènes saisonniers importants (hiver avec pic de décompensations cardiaques et respiratoires) — une analyse mensuelle ou trimestrielle est recommandée pour le pilotage opérationnel.

## Références
- [ATIH - Chaînage PMSI et identifiant patient (NIR crypté)](https://www.atih.sante.fr/)
- [CNAM - Pertinence des soins et réadmissions hospitalières : rapport Charges et Produits](https://www.ameli.fr/)
- [HAS - Insuffisance cardiaque : programme de réhabilitation et suivi post-hospitalier](https://www.has-sante.fr/)
- [DREES - Réadmissions et revolving door en MCO : analyse nationale PMSI](https://www.drees.solidarites-sante.gouv.fr/)
- [SNDS - Trajectoires longitudinales et hospitalisations répétées](https://www.snds.gouv.fr/)
