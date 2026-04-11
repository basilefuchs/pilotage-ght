# Taux d'Actes Diagnostiques Redondants

## Définition
Le taux d'actes diagnostiques redondants mesure la proportion de séjours MCO comportant au moins deux actes diagnostiques de même nature (imagerie, endoscopie, biopsie) réalisés dans un délai court au sein du même séjour ou entre deux séjours successifs du même patient, sans qu'une évolution clinique documentée ne le justifie. Ces actes redondants signalent des dysfonctionnements organisationnels : transfert inter-établissements sans transmission des résultats, absence d'accès au dossier patient partagé, réalisation d'un second acte par habitude ou méfiance envers l'acte antérieur, ou défaut de coordination entre les équipes médicales. La redondance diagnostique génère des surcoûts directs, une irradiation inutile pour le patient (imagerie) et un allongement de la durée de séjour.

## Calcul
Le taux d'actes diagnostiques redondants est calculé comme suit :

```
Taux d'actes redondants (%) = (Séjours avec ≥ 2 actes CCAM diagnostiques de même famille dans un délai ≤ D jours / Total des séjours) × 100
```

**Familles d'actes diagnostiques traceurs et délais de redondance :**

| Famille d'actes | Codes CCAM (exemples) | Délai de redondance retenu |
|---|---|---|
| Scanner thoracique | ZBQK002, ZZQN002 (TDM thorax) | ≤ 7 jours |
| Scanner abdomino-pelvien | ZZQK002 (TDM abdomen) | ≤ 7 jours |
| IRM cérébrale | BZQK002 (IRM encéphale) | ≤ 14 jours |
| Fibroscopie gastrique | HGED004, HGEH001 | ≤ 30 jours |
| Coloscopie | HHQE003, HHQE001 | ≤ 30 jours |
| Coronarographie diagnostique | DKJB001, DKJB002 | ≤ 30 jours |
| Bronchoscopie | GEJE001, GEJB001 | ≤ 14 jours |
| Ponction-biopsie hépatique | HHHB001 | ≤ 90 jours |

**Précisions méthodologiques** :
- La redondance intra-séjour est identifiée directement sur le RSS : deux codes CCAM identiques (ou de la même famille) dans le même séjour sans date différenciatrice justifiée.
- La redondance inter-séjours nécessite le chaînage PMSI par patient (NIR crypté) pour comparer les actes du séjour courant avec ceux des séjours précédents dans la fenêtre temporelle retenue.
- Certaines redondances sont cliniquement justifiées (évolution pathologique documentée, procédure diagnostique incomplète, contrôle post-thérapeutique) : leur exclusion nécessite une règle métier basée sur les diagnostics associés (ex. : nouveau DP entre les deux actes).
- L'analyse est réalisée par service, par établissement et par type d'acte pour identifier les foyers de redondance les plus fréquents.

## Utilité
- **Détection des défauts de coordination et de transmission** : les actes redondants liés à des transferts inter-établissements sans dossier patient révèlent les manques d'interopérabilité du système d'information partagé du GHT.
- **Réduction des coûts directs** : chaque acte diagnostique redondant est un coût évitable (scanner ~150-400 €, coloscopie ~250-450 €, coronarographie ~800-1500 €) qui pèse sur la dépense de santé et sur la valorisation T2A.
- **Amélioration de la sécurité des patients** : la réduction des scanners et des actes irradiants redondants diminue l'exposition aux rayonnements ionisants, particulièrement pour les patients fréquemment hospitalisés.
- **Évaluation du dossier patient partagé intra-GHT** : une réduction des actes redondants entre établissements du GHT après déploiement du DPI partagé est un indicateur objectif de son impact organisationnel.
- **Identification des pratiques non conformes** : un taux élevé de redondance dans une spécialité spécifique (ex. : endoscopies répétées en gastroentérologie) peut déclencher une revue de pratiques professionnelles ciblée.

## Sources de Données
- **PMSI MCO - Actes CCAM** : codes d'actes diagnostiques par séjour, pour la détection de la redondance intra-séjour (deux actes identiques dans le même RSS).
- **Chaînage PMSI (NIR crypté)** : historique des séjours du patient pour la détection de la redondance inter-séjours dans la fenêtre temporelle retenue.
- **ATIH - Référentiel CCAM** : classification des actes par famille et par sous-famille pour regrouper les actes diagnostiques équivalents (différents codes CCAM correspondant au même geste).
- **SNDS** : pour les redondances impliquant des actes réalisés en ville (radiologie de ville + imagerie hospitalière) — nécessite un appariement PMSI/DCIR.

## Exemple de Valeurs
- **Scanner abdomino-pelvien redondant (≤ 7 jours)** : 3-8 % des séjours comportant un scanner abdomino-pelvien, selon les établissements et les spécialités.
- **Coloscopie redondante (≤ 30 jours)** : 2-5 % des séjours avec coloscopie, principalement liés à des transferts inter-établissements sans transmission du compte-rendu endoscopique.
- **IRM cérébrale redondante** : 4-10 % des séjours neurologiques et neurochirurgicaux, souvent liés à des réalisations en urgence suivies d'une IRM de contrôle non planifiée.
- **Coronarographie redondante** : 1-3 % des séjours cardiologiques, principalement lors de transferts secondaires entre un établissement périphérique et un CHU ou un centre de cardiologie interventionnelle.
- **Coût total estimé des actes redondants** : 50-150 M€ par an à l'échelle nationale, selon les estimations disponibles dans la littérature internationale sur les redondances diagnostiques.
- **Réduction post-DPI partagé** : des études montrent une réduction de 20-35 % des actes d'imagerie redondants après déploiement d'un dossier patient partagé inter-établissements.

## Limites
- La distinction entre redondance injustifiée et contrôle cliniquement nécessaire ne peut pas être réalisée automatiquement depuis le seul PMSI sans analyse du contexte clinique (évolution du DP, nouveaux diagnostics intercurrents).
- Le chaînage inter-séjours pour la détection des redondances inter-établissements requiert l'accès au NIR crypté (SNDS), soumis à des contraintes réglementaires strictes.
- Les actes diagnostiques réalisés en ville (radiologie libérale, endoscopie ambulatoire) avant l'hospitalisation ne sont pas visibles dans le PMSI MCO seul, conduisant à une sous-estimation de la redondance réelle.
- Certains codes CCAM regroupent des actes diagnostiques et thérapeutiques : une sélection rigoureuse des codes purement diagnostiques est nécessaire pour éviter de comptabiliser des actes thérapeutiques répétés légitimes.
- L'indicateur peut déclencher des comportements défensifs (sous-codage des actes redondants) si les résultats sont utilisés à des fins punitives plutôt que comme outil d'amélioration des pratiques.

## Références
- [ATIH - Référentiel CCAM et actes diagnostiques](https://www.atih.sante.fr/)
- [HAS - Recommandations sur le bon usage de l'imagerie diagnostique](https://www.has-sante.fr/)
- [SNDS - Croisement PMSI et DCIR pour les redondances ville-hôpital](https://www.snds.gouv.fr/)
- [ScanSanté - Analyse des actes CCAM par établissement](https://www.scansante.fr/)
