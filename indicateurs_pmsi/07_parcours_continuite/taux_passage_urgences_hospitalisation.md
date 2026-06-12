# Taux de Passage aux Urgences Suivi d'Hospitalisation

## Définition
Le taux de passage aux urgences suivi d'hospitalisation mesure la proportion de passages aux urgences qui donnent lieu à une hospitalisation (en MCO, SSR, HAD ou psychiatrie), par opposition aux passages se soldant par un retour à domicile. Cet indicateur évalue à la fois la pertinence des admissions hospitalières via les urgences et le bon fonctionnement de la filière urgences-aval : un taux élevé peut traduire une sur-hospitalisation des patients des urgences, tandis qu'un taux faible combiné à un volume important peut signaler un engorgement des urgences faute d'aval disponible.

## Calcul
Le taux de passage aux urgences suivi d'hospitalisation est calculé comme suit :

```
Taux d'hospitalisation depuis les urgences (%) = (Nombre de passages aux urgences suivis d'une hospitalisation / Nombre total de passages aux urgences) × 100
```

**Précisions méthodologiques** :
- Les passages aux urgences sont issus du PMSI MCO via les Résumés de Passage aux Urgences (RPU), obligatoires pour tous les services d'urgence.
- Les champs `modeentree` + `provenance` du séjour MCO (urgences = 8 + provenance 5) permettent d'identifier les hospitalisations en provenance des urgences sans nécessiter le chaînage des RPU.
- L'analyse distingue les hospitalisations directes depuis les urgences (même établissement) des transferts vers un autre établissement après passage aux urgences.
- L'indicateur est segmenté par tranche d'âge, par pathologie (CIM-10 du RPU ou DP du séjour MCO), par plage horaire et par jour de semaine pour identifier les tensions spécifiques.
- Un indicateur complémentaire est le **taux d'hospitalisation non programmée** (mode d'entrée 8 dans le séjour MCO rapporté au total des séjours MCO).

## Utilité
- **Évaluation de la pertinence des admissions** : identifier les pathologies pour lesquelles l'hospitalisation après passage aux urgences pourrait être évitée par une orientation vers des soins de ville ou une hospitalisation programmée.
- **Pilotage de l'aval des urgences** : mesurer la disponibilité des lits d'aval MCO et SSR pour fluidifier les urgences et réduire les durées de passage.
- **Détection des tensions capacitaires** : une hausse du taux d'hospitalisation depuis les urgences peut signaler un engorgement lié à un manque de lits d'aval plutôt qu'une augmentation des besoins cliniques.
- **Analyse des modes d'admission** : comparer la proportion d'admissions programmées vs non programmées (urgences) pour évaluer le poids des urgences dans l'activité MCO du GHT.
- **Coordination ville-urgences** : identifier les pathologies chroniques fréquentes aux urgences (insuffisance cardiaque, diabète, BPCO) pour renforcer les filières d'évitement des urgences.

## Sources de Données
- **PMSI MCO - Résumés de Passage aux Urgences (RPU)** : données exhaustives des passages aux urgences des établissements autorisés, incluant le devenir du patient (retour domicile, hospitalisation, transfert, décès).
- **PMSI MCO - Mode d'entrée des séjours (code 8)** : pour identifier les hospitalisations issues des urgences sans accès aux RPU.
- **ScanSanté** : module d'analyse des urgences et des modes d'admission MCO.
- **ATIH - Résumé Standardisé de Passage aux Urgences (RSPU)** : fichier standardisé depuis 2013 pour tous les services d'urgence.
- **ORU (Observatoires Régionaux des Urgences)** : données complémentaires en temps réel pour le pilotage opérationnel.

## Exemple de Valeurs
- **Taux moyen d'hospitalisation depuis les urgences** : 20-25 % des passages aux urgences en France.
- **Variation par âge** : 10-15 % chez les moins de 15 ans, 40-60 % chez les plus de 75 ans.
- **Part des admissions MCO issues des urgences** : 40-55 % des séjours MCO en hospitalisation complète selon les établissements.
- **Pathologies les plus hospitalisées depuis les urgences** : insuffisance cardiaque, AVC, fractures, pneumonies, douleurs abdominales non spécifiques.
- **Taux de retour à domicile dans les 48 h après hospitalisation urgences** : 5-10 % des hospitalisations issues des urgences, potentiellement évitables.

## Limites
- Les RPU ne sont pas exhaustifs pour tous les établissements, en particulier les cliniques privées qui ne disposent pas toutes d'un service d'urgence autorisé.
- Le taux d'hospitalisation depuis les urgences dépend fortement du profil de la patientèle (âge, précarité) et n'est pas directement comparable entre établissements sans standardisation.
- Un taux élevé peut refléter une patientèle plus sévère plutôt qu'une pertinence insuffisante des admissions.
- L'indicateur ne mesure pas la qualité de la décision d'hospitalisation (sur- ou sous-hospitalisation) sans analyse clinique complémentaire.
- Les ré-orientations vers d'autres structures (HAD, SSR, médecine de ville) depuis les urgences sont mal tracées dans le PMSI.

## Références
- [ATIH - Résumés de Passage aux Urgences (RPU)](https://www.atih.sante.fr/)
- [DREES - Les urgences hospitalières en France](https://www.drees.solidarites-sante.gouv.fr/)
- [ScanSanté - Analyse des urgences et modes d'admission](https://www.scansante.fr/)
- [SAMU-Urgences de France - Observatoire des passages aux urgences](https://www.samu-urgences-de-france.fr)
