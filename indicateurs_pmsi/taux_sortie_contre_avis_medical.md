# Taux de Sortie Contre Avis Médical

## Définition
Le taux de sortie contre avis médical (SAM) mesure la proportion de séjours MCO se terminant par une sortie décidée par le patient contre l'avis de l'équipe soignante, avant que la prise en charge médicale ne soit considérée comme achevée. Dans le PMSI, ce mode de sortie est codé avec le code 7 (« sortie contre avis médical ») dans le champ « mode de sortie » du RSS. La sortie contre avis médical est un signal de rupture de soins majeur : elle est associée à des taux de réadmission 2 à 3 fois supérieurs à la moyenne, à une mortalité à 30 jours significativement plus élevée et à des coûts indirects importants (traitements incomplets, complications évitables). Elle constitue également un indicateur de la qualité de la relation thérapeutique, de l'accessibilité des soins et de la vulnérabilité médico-sociale des patients.

## Calcul
Le taux de sortie contre avis médical est calculé comme suit :

```
Taux de SAM (%) = (Séjours avec mode de sortie = 7 / Total des séjours MCO) × 100

  → Mode de sortie = 7 : sortie contre avis médical (champ obligatoire du RSS PMSI MCO)
  → Exclusions : décès (mode de sortie = 9), transferts (= 6), mutations (= 7 dans certaines versions)

Taux de SAM pour 1 000 séjours = (Séjours mode sortie = 7 / Total séjours) × 1 000
  → Préférable au taux en % pour les valeurs faibles
```

**Sous-indicateurs dérivés :**
```
Taux de SAM par CMD (%) → identifie les spécialités à risque (psychiatrie, addictologie, urgences)

Taux de SAM par profil démographique :
  → Âge (15-30 ans vs > 65 ans)
  → Sexe
  → Score de vulnérabilité sociale (croisement avec codes Z)

Taux de réadmission à 30j post-SAM (%) → mesure les conséquences cliniques des sorties non médicales

Délai médian de réadmission post-SAM (jours) → rapidité de la décompensation après rupture de soins

Taux de SAM répétés (%) = (Patients avec ≥ 2 SAM sur 12 mois / Total patients avec ≥ 1 SAM) × 100
  → Identifie les patients en rupture chronique de soins nécessitant une prise en charge spécifique
```

**Précisions méthodologiques** :
- Le code de mode de sortie 7 est obligatoire dans le PMSI MCO — il est en théorie systématiquement renseigné, mais des erreurs de codage (confusion avec transfert non prévu) peuvent fausser les comparaisons.
- L'analyse par CMD est essentielle : les SAM en psychiatrie (CMD 19-20) et en addictologie ont un profil et des déterminants très différents des SAM en médecine somatique (CMD 5, 6, 7).
- Le chaînage par NIR crypté (SNDS) permet d'identifier les patients avec SAM répétés et de calculer les taux de réadmission post-SAM dans tous les établissements du territoire.

## Utilité
- **Identification des populations à risque de rupture de soins** : les patients avec SAM sont statistiquement plus jeunes, plus souvent masculins, plus souvent précaires (codes Z) et moins souvent en ALD — cibler ces profils pour des interventions préventives (médiateurs de santé, éducation thérapeutique, consultation de rattrapage à J+3).
- **Signal qualité sur la relation thérapeutique** : un taux de SAM élevé dans un service peut refléter des problèmes d'information des patients, de communication soignant-patient ou de conditions d'hospitalisation inadaptées — il déclenche une analyse de cause dans les démarches qualité.
- **Évaluation des politiques de réduction des SAM** : mesurer l'impact des interventions (médiateurs en santé, travailleurs pairs, consultations de conciliation) sur la réduction du taux de SAM dans les services à fort taux.
- **Déclinaison par filière** : en psychiatrie, le taux de SAM est un indicateur réglementaire de suivi (arrêtés sur les soins sans consentement) ; en médecine somatique, il est un signal de vulnérabilité sociale et d'accessibilité des soins.
- **Pilotage médico-économique** : chaque SAM génère un coût indirect élevé (réadmission à J+15 en moyenne, traitement incomplet, complications) — quantifier ce coût justifie les investissements dans les programmes de réduction des SAM.

## Sources de Données
- **PMSI MCO** : champ « mode de sortie » (code 7 = SAM) du RSS — disponible directement dans ScanSanté et dans les fichiers RSA locaux, sans traitement supplémentaire.
- **ScanSanté** : filtrage des séjours par mode de sortie, accessible par établissement, par CMD et par GHM — calcul immédiat du taux de SAM sans accès aux fichiers bruts.
- **SNDS (PMSI + DCIR)** : pour le chaînage des réadmissions post-SAM dans tous les établissements du territoire et le calcul des taux de SAM répétés sur 12 mois glissants.
- **Données locales DIM** : analyse des SAM par service, par pathologie (DP) et par profil démographique pour les actions ciblées d'amélioration.

## Exemple de Valeurs
- **Taux de SAM moyen national MCO** : 0,5-1,5 % des séjours selon les établissements et les spécialités.
- **Psychiatrie (CMD 19-20)** : taux de SAM de 3-8 %, le plus élevé de toutes les spécialités — reflet des enjeux spécifiques de la relation thérapeutique en santé mentale.
- **Médecine interne / addictologie** : 2-5 % de SAM, souvent associés à des problèmes de dépendance, de précarité ou de comorbidités psychiatriques.
- **Chirurgie élective** : 0,1-0,3 % de SAM — très faible, les patients étant majoritairement acteurs de leur hospitalisation programmée.
- **Urgences (hospitalisations issues des urgences)** : 1-3 % de SAM parmi les séjours courts issus des urgences, souvent avant même la fin du bilan initial.
- **Taux de réadmission à 30j post-SAM** : 25-45 % selon les études françaises et américaines — 2 à 3 fois supérieur au taux de réadmission des sorties médicalement validées.
- **Mortalité à 30j post-SAM** : 5-10 % dans les études incluant les sorties de services de médecine lourde (cardiologie, pneumologie, neurologie) — signal fort justifiant une consultation de rattrapage systématique.
- **SAM répétés (≥ 2 sur 12 mois)** : 20-30 % des patients ayant eu un premier SAM récidivent dans l'année — population cible prioritaire pour les interventions de coordination.

## Limites
- Le code de mode de sortie 7 peut être sous-utilisé ou mal utilisé dans certains établissements (confusion avec d'autres modes de sortie non prévus, résistance des équipes à documenter un SAM) — un audit de codage est recommandé avant toute comparaison inter-établissements.
- La définition réglementaire du SAM varie légèrement selon les établissements et les pratiques locales : certains établissements codent en SAM des sorties anticipées négociées avec le patient, d'autres non.
- Le taux de SAM est corrélé à la vulnérabilité sociale de la patientèle — les établissements accueillant davantage de patients précaires auront structurellement un taux plus élevé, indépendamment de la qualité de leur relation thérapeutique.
- L'indicateur ne distingue pas les SAM pour lesquels une alternative de soins était disponible (téléphonie médicale, HAD, consultation rapide) des SAM pour lesquels aucune alternative n'existait.
- Le suivi post-SAM (consultation à J+3, appel téléphonique) n'est pas documenté dans le PMSI — l'évaluation de l'impact des interventions de rattrapage nécessite le croisement avec le DCIR (SNDS).

## Références
- [ATIH - Guide méthodologique PMSI MCO : modes de sortie](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des modes de sortie par établissement](https://www.scansante.fr/)
- [HAS - Bientraitance et droits des patients hospitalisés](https://www.has-sante.fr/)
- [SNDS - Chaînage post-SAM et réadmissions](https://www.snds.gouv.fr/)
- [DREES - Droits des patients et modes de sortie hospitaliers](https://www.drees.solidarites-sante.gouv.fr/)
