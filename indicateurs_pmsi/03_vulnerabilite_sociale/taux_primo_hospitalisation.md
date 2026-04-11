# Taux de Primo-Hospitalisation

## Définition
Le taux de primo-hospitalisation mesure la proportion de patients hospitalisés dans le GHT pour la première fois sur une période de référence, par opposition aux patients déjà connus des établissements du groupement (hospitalisés au moins une fois dans les 3 ou 5 années précédentes). Cet indicateur évalue simultanément deux dimensions stratégiques : la capacité du GHT à **capter de nouveaux patients** sur son territoire (attractivité) et la **fidélisation** des patients existants (continuité de la relation de soins). Un taux de primo-hospitalisation élevé peut signaler une forte attractivité ou, à l'inverse, un fort renouvellement de patientèle lié à une faible fidélisation. Croisé avec le taux de fuite et les parts de marché, il complète le tableau de bord stratégique du GHT sur sa dynamique de patientèle.

## Calcul
Le taux de primo-hospitalisation est calculé par chaînage longitudinal des séjours PMSI :

```
Patient primo-hospitalisé = patient n'ayant aucun séjour antérieur dans un établissement du GHT
                            sur la fenêtre de référence (3 ou 5 ans précédant le séjour index)

Taux de primo-hospitalisation (%) = (Patients primo-hospitalisés sur l'année N / Total des patients hospitalisés sur l'année N) × 100
```

**Construction depuis le PMSI :**
```
Étape 1 — Constitution de l'historique des séjours par patient (NIR crypté) :
  → Agrégation des RSS sur 5 ans glissants par FINESS du GHT
  → Un patient est "connu" si au moins 1 séjour dans un établissement du GHT dans les 5 années précédentes

Étape 2 — Identification des primo-hospitalisés sur l'année N :
  → Premier séjour identifié dans les données du GHT sur la fenêtre d'observation de 5 ans

Étape 3 — Calcul du taux et des sous-indicateurs :
  Taux de primo-hospitalisation global (%)
  Taux de fidélisation (%) = 100 % − Taux de primo-hospitalisation
```

**Sous-indicateurs dérivés :**
```
Taux de primo-hospitalisation par CMD (%) → identifie les spécialités qui captent de nouveaux patients
                                             vs celles qui gèrent une patientèle chronique stable

Taux de primo-hospitalisation par zone géographique (code postal) → cartographie des zones
  d'où proviennent les nouveaux patients (expansion territoriale vs cœur de territoire)

Taux de retour à 1 an (%) = (Patients primo-hospitalisés en N revenus en N+1 / Primo-hospitalisés en N) × 100
  → Mesure la conversion des nouveaux patients en patients fidèles

Délai médian de retour (mois) → pour les patients revenus, temps entre la primo-hospitalisation
                                 et le séjour suivant
```

**Précisions méthodologiques** :
- La fenêtre de référence de 5 ans est recommandée pour limiter les faux positifs (patients hospitalisés avant la fenêtre d'observation mais connus du GHT) tout en restant réaliste.
- Le chaînage nécessite le NIR crypté disponible dans le PMSI — réalisable localement par le DIM sur les fichiers RSA du GHT sans nécessiter l'accès complet au SNDS.
- L'analyse doit distinguer les primo-hospitalisations vraies (nouveaux patients du territoire) des primo-hospitalisations liées à la fuite inversée (patients habituellement soignés ailleurs et revenant au GHT pour une pathologie spécifique).
- Pour les GHT disposant d'un DPI partagé avec identifiant patient commun, le chaînage peut être réalisé directement depuis le système d'information sans passer par le NIR crypté.

## Utilité
- **Pilotage stratégique de la patientèle** : distinguer la croissance d'activité liée à l'afflux de nouveaux patients (expansion territoriale) de celle liée à l'augmentation du recours des patients connus (vieillissement, aggravation des pathologies chroniques).
- **Évaluation de l'attractivité** : un taux de primo-hospitalisation en hausse sur une CMD ou une spécialité signale que le GHT gagne des parts de marché sur de nouveaux patients — signal positif d'attractivité à corréler avec les taux de fuite et les parts de marché.
- **Mesure de la fidélisation** : un fort taux de primo-hospitalisation associé à un faible taux de retour à 1 an révèle une incapacité à fidéliser les nouveaux patients — ils partent vers d'autres établissements après leur première expérience au GHT.
- **Segmentation marketing médical** : identifier les médecins adresseurs qui génèrent le plus de primo-hospitalisations pour cibler les actions de relations médecins (visites médicales, consultations avancées, formation continue).
- **Détection des opportunités de développement** : les zones géographiques générant peu de primo-hospitalisations au GHT malgré une population importante sont des zones de fuite potentielle à investiguer.

## Sources de Données
- **PMSI MCO local (DIM)** : fichiers RSA des 5 dernières années par FINESS du GHT, chaînés par NIR crypté pour reconstituer l'historique des séjours par patient.
- **SNDS** : pour étendre l'analyse aux hospitalisations dans tous les établissements (y compris hors GHT) et identifier les patients venant du secteur privé ou d'un autre territoire.
- **ScanSanté** : ne permet pas directement le calcul du taux de primo-hospitalisation (absence de dimension longitudinale patient) — le calcul doit être réalisé localement par le DIM.
- **DPI partagé du GHT** : si le GHT dispose d'un identifiant patient commun entre ses établissements, le calcul peut être réalisé directement depuis le système d'information sans recours au NIR crypté PMSI.

## Exemple de Valeurs
- **Taux de primo-hospitalisation global** : 20-35 % des patients hospitalisés chaque année sont de nouveaux patients (primo-hospitalisés sur 5 ans glissants) dans un GHT de taille moyenne.
- **Variation par CMD** : CMD 8 (orthopédie) et CMD 6 (digestif) ont des taux de primo-hospitalisation plus élevés (chirurgie élective ponctuelle, faible récurrence) ; CMD 5 (cardiologie) et CMD 1 (neurologie) ont des taux plus faibles (patientèle chronique fidèle).
- **Taux de retour à 1 an** : 40-60 % des primo-hospitalisés reviennent dans le GHT dans l'année suivante pour une pathologie chronique (cardiologie, oncologie) ; 15-25 % pour une pathologie aiguë (chirurgie élective non récurrente).
- **Variation par zone géographique** : les zones périphériques du territoire génèrent davantage de primo-hospitalisations (patients peu habitués au GHT, fuite historique vers d'autres établissements) que le cœur du territoire (patientèle fidèle et connue).
- **Impact d'une nouvelle autorisation** : l'ouverture d'une activité de chirurgie bariatrique ou de cardiologie interventionnelle génère typiquement une vague de primo-hospitalisations les 12-18 premiers mois avant stabilisation.

## Limites
- La définition de la fenêtre de référence (3 ou 5 ans) est arbitraire et influence significativement le taux : une fenêtre courte surestime les primo-hospitalisations, une fenêtre longue les sous-estime.
- Le chaînage par NIR crypté dans le PMSI local ne couvre que les séjours dans les établissements du GHT : un patient hospitalisé 4 fois dans une clinique privée concurrente et pour la première fois au GHT sera comptabilisé comme primo-hospitalisé alors qu'il est très connu du système de soins local.
- L'indicateur est sensible aux changements de périmètre du GHT (intégration d'un nouvel établissement) qui génèrent mécaniquement une vague de primo-hospitalisations artificielles.
- La notion de « patient connu » se limite aux séjours hospitaliers — un patient suivi depuis 10 ans en consultation externe sans hospitalisation sera comptabilisé comme primo-hospitalisé lors de son premier séjour.
- Les patients ayant changé de NIR (changement de situation administrative, erreurs d'identité) peuvent être comptabilisés comme primo-hospitalisés à tort — la qualité de l'identito-vigilance est un prérequis.

## Références
- [ATIH - Chaînage PMSI et identifiant patient (NIR crypté)](https://www.atih.sante.fr/)
- [ANAP - Analyse de la patientèle et pilotage stratégique hospitalier](https://www.anap.fr/)
- [ScanSanté - Analyse territoriale des flux de patients](https://www.scansante.fr/)
- [SNDS - Trajectoires longitudinales des patients](https://www.snds.gouv.fr/)
