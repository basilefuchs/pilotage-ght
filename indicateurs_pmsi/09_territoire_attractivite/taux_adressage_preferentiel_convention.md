# Taux d'Adressage Préférentiel d'une Convention Inter-Établissements

## Définition

Le taux d'adressage préférentiel mesure, pour une convention de coopération signée entre deux établissements A (adresseur) et B (recours), la part des séjours du **périmètre conventionné** (liste de GHM, actes CCAM ou DP définis par la convention) que les patients pris en charge initialement à A réalisent effectivement chez le partenaire B, plutôt que dans tout autre établissement. C'est l'indicateur d'**effectivité** d'une convention : une convention signée mais non suivie d'adressage est une convention morte.

Le cadre conceptuel est celui des parts de marché conditionnelles (modèles gravitaires de recours aux soins) : au lieu de mesurer la part de marché de B sur un territoire entier, on conditionne sur le sous-ensemble précis des parcours que la convention est censée organiser. Le bilan IGAS 2024 des GHT souligne que les coopérations inter-établissements restent faiblement objectivées ; l'instruction DGOS/FIP3/2025/145 fait de l'organisation inter-établissements un levier contractualisable de performance — ce qui suppose des indicateurs de suivi calculables. Aucun indicateur PMSI standard (ScanSanté) ne mesure aujourd'hui l'adressage dyadique conditionnel à un périmètre conventionnel.

Cet indicateur diffère des indicateurs existants du projet : `taux_transferts_intra_ght.md` mesure un volume global de transferts sans périmètre ni dyade ; `parts_marche_territoire.md` est populationnel (zone géographique), pas conditionnel à un premier contact chez A ; `taux_fuite_aval_parcours.md` mesure la fuite hors GHT, pas la conformité d'un adressage bilatéral.

Formule symbolique :

```
TAP = N_sejours(A → B, périmètre, fenêtre) / N_sejours(A → tout étab. ≠ A, périmètre, fenêtre) × 100
```

## Calcul

1. **Champ** : PMSI MCO national chaîné (numéro de chaînage anonyme inter-établissements), années N et N+1 pour couvrir la fenêtre. Le calcul nécessite la base nationale : un adressage vers un concurrent de B est invisible dans les bases locales.
2. **Périmètre conventionné** : traduire l'annexe de la convention en codes — liste de racines de GHM, d'actes CCAM (7 caractères) ou de DP CIM-10. C'est le paramètre central, à figer avec les signataires.
3. **Détection des adressages** — deux composantes à sommer :
   - **Transferts directs** : séjour à A clos par un mode de sortie mutation/transfert `[valeurs exactes du mode de sortie selon le guide ATIH en vigueur, à confirmer]` suivi d'un séjour du périmètre dans un autre établissement à ≤ 1 jour ;
   - **Adressages différés** : séjour ou venue à A (bilan, diagnostic), puis séjour du périmètre dans un autre établissement dans une fenêtre de 90 jours (chaînage anonyme), sans séjour intermédiaire dans un troisième établissement.
4. **Pseudocode** :

```
candidats  = patients avec contact index à A (séjour ou venue) puis séjour
             du périmètre conventionné dans un étab. ≠ A, délai ≤ 90 j
vers_B     = candidats[finess_sejour_perimetre ∈ finess_B]

TAP = n(vers_B) / n(candidats) × 100      # non calculé si n(candidats) < 30
```

5. **Conventions** : si plusieurs séjours du périmètre, retenir le premier ; exclure les patients décédés avant la fin de fenêtre ; un séjour du périmètre réalisé à A lui-même n'entre pas dans le dénominateur (la convention porte sur ce que A n'opère pas).
6. **Indicateurs dérivés** : TAP avant/après signature (cf. `effet_convention_serie_interrompue.md`) ; répartition des adressages non conformes par établissement destinataire (qui capte ce que B devait recevoir) ; délai médian index → séjour du périmètre selon la destination.

## Utilité

- **Suivi contractuel de la convention** : produire le TAP annuel au comité de suivi prévu par les trames de convention types (DGOS) — objectivation que les deux directions partagent.
- **Détecter l'évaporation** : un TAP à 40 % signifie que 60 % des parcours conventionnés partent ailleurs — identifier les destinataires réels et les mécanismes (délais de B, habitudes d'adressage des praticiens, refus).
- **Dimensionner les moyens partagés** : vacations de bloc, consultations avancées, postes partagés se calibrent sur le flux réel adressé, pas sur le flux théorique de la convention.
- **Arbitrer la reconduction** : une convention dont le TAP stagne sous 30 % après deux ans malgré les moyens engagés doit être renégociée ou dénoncée.
- **Préparer une convention** : calculé avant signature, le TAP « spontané » donne la ligne de base et rend la cible contractuelle réaliste (passer de 25 % à 60 %, pas à 100 %).
- **Argumentaire ARS** : démontrer l'effectivité de la gradation des soins inscrite au projet médical partagé, au-delà de la déclaration d'intention.

## Sources de Données

- **PMSI MCO national chaîné** : numéro de chaînage anonyme (clé générée via MAGIC/ANO `[modalités exactes selon la documentation chaînage ATIH en vigueur, à confirmer]`), GHM, actes CCAM, DP/DR, modes d'entrée et de sortie, dates ou délais inter-séjours, FINESS géographique.
- **Convention** : annexe listant le périmètre (spécialités, gestes) — à traduire en codes avec les équipes médicales.
- **Référentiels** : CCAM et CIM-10 en vigueur ; FINESS pour les entités géographiques de A et B.
- Extension possible aux champs SMR et HAD si la convention porte sur l'aval.

## Exemple de Valeurs

Ordres de grandeur expert (non sourcés — aucune restitution nationale n'existe sur cet objet) :

- **TAP spontané avant convention** : 15–40 % selon la proximité et l'historique des deux établissements.
- **Convention fonctionnelle** : 50–75 % à deux ans ; le plancher de non-conformité (libre choix du patient, deuxième avis, urgences survenues ailleurs) est de l'ordre de 15–25 %.
- **Alerte** : TAP < 30 % deux ans après signature, ou TAP en baisse alors que le volume du dénominateur croît (le besoin existe, l'adressage se détourne).
- Un TAP proche de 100 % est suspect : périmètre défini trop étroitement (tautologique) ou dénominateur trop petit.

## Limites

- **Périmètre = paramètre dominant** : un périmètre flou rend l'indicateur non reproductible ; le figer par avenant et le versionner avec la fiche de calcul.
- **Le TAP ne mesure pas la pertinence** : un adressage conforme à la convention peut être médicalement discutable ; croiser avec les indicateurs qualité de B.
- **Demandes refusées invisibles** : le PMSI ne trace que les séjours réalisés — un refus d'admission par B (saturation) se lit comme une non-conformité de A. La littérature sur les transferts montre que l'acceptation chute avec la saturation du receveur (Greenwood-Ericksen et al. 2025) ; interpréter avec les données de saturation de B.
- **Qualité du chaînage** : ~1–2 % de clés défaillantes, hétérogènes selon établissements et années ; vérifier la complétude avant interprétation.
- **Volume minimal** : ne pas interpréter sous 30 parcours/an ; agréger plusieurs années pour les périmètres étroits.
- **Fenêtre de 90 jours** : adaptée aux parcours programmés ; à élargir pour les filières à temporisation longue (néoadjuvant).

## Références

- Greenwood-Ericksen M, Kamdar N, Swenson K, et al. *Emergency Department Boarding, Inpatient Census, and Interhospital Transfer Acceptances.* JAMA Netw Open. 2025;8(5):e2512299. [DOI](https://doi.org/10.1001/jamanetworkopen.2025.12299) — PMID:40434774
- Ranasinghe I, Barzi F, Brieger D, Gallagher M. *Long-term mortality following interhospital transfer for acute myocardial infarction.* Heart. 2015;101(13):1032-1040. [DOI](https://doi.org/10.1136/heartjnl-2014-306966) — PMID:25736049
- IGAS. *Bilan d'étape des groupements hospitaliers de territoire (GHT).* Mai 2024. [igas.gouv.fr](https://www.igas.gouv.fr/sites/igas/files/2024-05/Bilan%20d%E2%80%99%C3%A9tape%20des%20groupements%20hospitaliers%20de%20territoire%20%28GHT%29.pdf)
- Ministère de la Santé. *Les coopérations territoriales : modalités d'accompagnement* (fiches-repères et trames de convention types). [sante.gouv.fr](https://sante.gouv.fr/professionnels/gerer-un-etablissement-de-sante-medico-social/cooperations/cooperations-territoriales/article/les-cooperations-territoriales-modalites-d-accompagnement)
- Instruction n° DGOS/FIP3/DSS/SD1A/2025/145 du 9 octobre 2025 relative à l'efficience et à la performance des établissements de santé. [bulletins-officiels.social.gouv.fr](https://bulletins-officiels.social.gouv.fr/instruction-ndeg-dgosfip3dsssd1a2025145-du-9-octobre-2025-relative-la-mise-en-oeuvre-de-la-circulaire-du-premier-ministre-du-23-avril-2025-relative-lefficience-et-la-performance-des-etablissements-de-sante)
- Fiches liées : `indice_reciprocite_flux_dyade.md` (équilibre des flux), `effet_convention_serie_interrompue.md` (impact causal), `../07_parcours_continuite/taux_retrocession_aval_convention.md` (clause de retour), `taux_fuite_aval_parcours.md` (fuite hors GHT).
