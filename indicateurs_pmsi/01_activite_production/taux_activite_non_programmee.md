# Taux d'Activité Non Programmée

## Définition
Le taux d'activité non programmée mesure la proportion des séjours MCO dont l'admission n'était pas planifiée à l'avance, c'est-à-dire issus d'un passage aux urgences, d'un transfert non anticipé ou d'une admission directe en urgence. Identifié dans le PMSI par les champs `modeentree` + `provenance` (urgences = 8 + provenance 5 ; mutation/transfert = 6/7), cet indicateur reflète la pression exercée par l'activité urgente et non planifiée sur l'organisation hospitalière du GHT. Un taux élevé contraint la capacité à programmer de l'activité chirurgicale et médicale élective, pèse sur les ressources humaines et matérielles, et est associé à une moindre efficience (DMS plus longue, taux d'ambulatoire plus faible, IP-DMS plus élevé). À l'inverse, un taux très faible peut signaler un établissement peu accessible pour les urgences de son territoire. Cet indicateur macro est déclinable par CMD, par GHM, par service ou par établissement du GHT.

## Calcul
Le taux d'activité non programmée est calculé comme suit :

```
Taux d'activité non programmée (%) = (Séjours MCO entrés par les urgences (`modeentree` = 8 et `provenance` = 5) ou par mutation/transfert (`modeentree` 6/7) / Total des séjours MCO) × 100
```

**Sous-indicateurs dérivés :**
```
Taux d'admissions directes urgences (%) = Séjours avec `modeentree` = 8 et `provenance` = 5 / Total séjours MCO × 100
  → Mesure strictement les admissions via le service des urgences de l'établissement

Taux de transferts entrants non programmés (%) = Séjours mode d'entrée = 6 sans programmation documentée / Total séjours MCO × 100
  → Identifié par l'absence d'une hospitalisation programmée dans les 30j précédents (chaînage PMSI)

Ratio programmé / non programmé = (1 - Taux non programmé) / Taux non programmé
  → > 1 : dominance de l'activité programmée (clinique spécialisée, chirurgie élective)
  → < 1 : dominance de l'activité urgente (établissement de médecine générale, CHU)

Taux de chirurgie non programmée (%) = Séjours chirurgicaux (CMD avec acte CCAM opératoire) avec mode d'entrée = 8 / Total séjours chirurgicaux × 100
  → Sous-indicateur clé pour évaluer la pression urgentiste sur le bloc opératoire
```

**Précisions méthodologiques** :
- Le mode d'entrée est codé dans le PMSI MCO par le RSS pour chaque séjour (champ obligatoire).
- La distinction entre transfert programmé et non programmé n'est pas directement disponible dans le PMSI : une approximation consiste à considérer comme non programmé tout transfert sans séjour planifié identifiable dans les 30 jours précédents (chaînage NIR crypté).
- L'analyse temporelle (jour de la semaine, heure d'admission) est possible via les dates et heures d'entrée du PMSI pour affiner la compréhension des flux urgents.
- L'indicateur exclut les séances (dialyse, chimiothérapie, séances de radiothérapie) pour ne porter que sur les séjours avec nuitée ou ambulatoire complet.

## Utilité
- **Pilotage de l'organisation hospitalière** : quantifier la part de l'activité subie vs choisie pour adapter l'organisation des blocs opératoires, des unités d'hospitalisation et des ressources humaines (gardes, astreintes).
- **Analyse de la tension capacitaire** : un taux d'activité non programmée élevé combiné à un fort taux d'occupation est le signe d'une tension capacitaire structurelle, justifiant des investissements en lits ou en aval SSR/HAD.
- **Benchmarking intra-GHT** : comparer les taux par établissement du GHT pour identifier ceux qui subissent une pression urgentiste disproportionnée et réfléchir à une meilleure répartition des flux.
- **Déclinaison par filière** : un taux de chirurgie non programmée élevé en orthopédie signale des traumatismes fréquents occupant les salles au détriment de la chirurgie élective ; en digestif, il peut révéler un sous-dimensionnement de l'offre de chirurgie ambulatoire élective.
- **Impact sur l'efficience** : l'activité non programmée est systématiquement associée à une DMS plus longue, un CMI plus élevé et un IP-DMS plus dégradé — quantifier sa part permet de contextualiser les indicateurs d'efficience.

## Sources de Données
- **PMSI MCO** : champs `modeentree` + `provenance` du RSA (urgences = 8 + provenance 5 ; mutation = 6 ; transfert = 7 ; domicile sans provenance 5 = programmé) — complétés par `passage_urg` depuis 2023 — disponible pour chaque séjour sans traitement supplémentaire.
- **ScanSanté** : module d'analyse des modes d'admission par établissement, disponible directement sans accès aux fichiers bruts.
- **ATIH - Tableaux de bord PMSI** : répartition des séjours par mode d'entrée agrégée par établissement et par CMD.
- **RPU (Résumés de Passage aux Urgences)** : complément pour l'analyse des passages aux urgences non suivis d'hospitalisation (activité urgentiste non capturée par le mode d'entrée MCO).

## Exemple de Valeurs
- **Taux d'activité non programmée moyen** : 40-55 % des séjours MCO en hospitalisation complète dans les établissements publics généraux.
- **CHU** : 50-65 % d'activité non programmée, reflet de l'afflux d'urgences complexes et des transferts secondaires.
- **CHG de proximité** : 45-60 % selon l'accessibilité géographique et la présence d'un service d'urgences.
- **Cliniques privées** : 15-30 % d'activité non programmée (forte prédominance de la chirurgie élective).
- **Chirurgie orthopédique** : taux de chirurgie non programmée de 30-45 % (traumatologie) vs 5-15 % pour la chirurgie élective prothétique.
- **Médecine interne / gériatrie** : 70-85 % d'activité non programmée, reflet de la nature urgente des décompensations de pathologies chroniques.
- **Variation hebdomadaire** : pic d'admissions non programmées le lundi (suite au week-end) et creux le vendredi (anticipation des week-ends).

## Limites
- Le mode d'entrée PMSI est renseigné par les services administratifs et peut être codé de façon hétérogène selon les établissements : certaines admissions directes en médecine sont codées comme urgences ou inversement.
- La distinction entre transfert programmé et non programmé est approximative dans le PMSI (absence de champ dédié) — le chaînage pour identifier les transferts planifiés nécessite le NIR crypté.
- Un taux d'activité non programmée élevé n'est pas nécessairement le signe d'un dysfonctionnement : pour un établissement de médecine générale de proximité, c'est une mission de service public normale.
- L'indicateur ne distingue pas les urgences vraies (pathologies menaçant le pronostic vital) des urgences relatives (patients se présentant aux urgences faute d'accès aux soins de ville) — cette distinction est cruciale mais non accessible depuis le seul mode d'entrée PMSI.
- La progression du virage ambulatoire peut faire baisser mécaniquement le taux si les séjours programmés (surtout chirurgicaux) migrent vers l'ambulatoire, augmentant la part relative des séjours urgents sans que la pression urgentiste ait réellement augmenté.

## Références
- [ATIH - Guide méthodologique PMSI MCO : modes d'entrée et de sortie](https://www.atih.sante.fr/)
- [ScanSanté - Analyse des modes d'admission par établissement](https://www.scansante.fr/)
- [DREES - Les urgences hospitalières en chiffres](https://www.drees.solidarites-sante.gouv.fr/)
- [ANAP - Gestion de l'activité programmée et non programmée](https://www.anap.fr/)
