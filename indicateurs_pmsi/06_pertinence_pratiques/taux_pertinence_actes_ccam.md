# Taux de Pertinence des Actes CCAM

## Définition
Le taux de pertinence des actes CCAM mesure la proportion d'actes chirurgicaux ou techniques réalisés au sein du GHT qui sont conformes aux référentiels de bonnes pratiques (recommandations HAS, sociétés savantes, seuils d'Evidence-Based Medicine), par opposition aux actes réalisés hors indications validées (sur-traitement) ou aux actes non réalisés alors qu'ils seraient indiqués (sous-traitement). Cet indicateur s'appuie sur la détection de signaux de non-pertinence dans le PMSI : actes réalisés pour des diagnostics ne correspondant pas aux indications recommandées, volumes d'actes anormalement élevés ou faibles par rapport aux standards nationaux, ou actes effectués dans des contextes cliniques inadaptés (ex. : arthroscopie du genou pour arthrose avancée sans arthrite associée).

## Calcul
Le taux de pertinence des actes CCAM est calculé comme suit :

```
Taux de pertinence (%) = (Nombre d'actes CCAM réalisés dans les indications recommandées / Nombre total d'actes CCAM réalisés) × 100
```

**Signaux de non-pertinence détectables dans le PMSI :**

| Acte | Signal de non-pertinence | Code CIM-10 / CCAM |
|---|---|---|
| Arthroscopie du genou | DP = gonarthrose sans chondrocalcinose ni corps étranger | M17 sans M11, M23 |
| Hystérectomie | Absence de pathologie maligne ou de fibrome symptomatique | Sans C53-C55, D25 |
| Césarienne | Taux > 21 % dans un établissement sans facteur de risque documenté | QXGA |
| Appendicectomie | DMS > 5 jours (peut signaler une appendicite perforée non anticipée) | K35-K37 |
| Amygdalectomie enfant | Âge < 2 ans sans contexte d'apnée du sommeil | Sans G47.3 |
| Pose de stent coronaire | Sans IDM ou angor instable documenté | Sans I20-I21 |

**Précisions méthodologiques** :
- La pertinence est définie par croisement du code CCAM de l'acte avec le diagnostic principal (DP) et les diagnostics associés (DA) du séjour.
- Les seuils de volume (taux d'actes pour 100 000 habitants) sont comparés aux références nationales ScanSanté pour détecter les outliers positifs et négatifs.
- L'analyse s'appuie sur les listes de pertinence publiées par la HAS (programme PREMS/PROMS, indicateurs de pertinence des soins) et par les sociétés savantes.
- Les actes « à risque de non-pertinence » sont identifiés en priorité : arthroscopies, hystérectomies, chirurgie du rachis, endoscopies répétées, hospitalisations pour actes réalisables en ambulatoire.

## Utilité
- **Réduction du sur-traitement** : identifier les actes réalisés hors indications pour réduire le risque iatrogène et les dépenses non justifiées, en cohérence avec les objectifs de pertinence des soins de l'ARS.
- **Détection du sous-traitement** : repérer les actes indiqués mais non réalisés (ex. : faible taux de revascularisation en cardiologie, faible taux de chirurgie curative en cancérologie) pour améliorer l'accès aux soins efficaces.
- **Préparation aux audits HAS et ARS** : anticiper les évaluations de pertinence en identifiant les actes à risque avant les inspections ou les renouvellements d'autorisation.
- **Formation et accompagnement des équipes médicales** : les résultats du taux de pertinence servent de base aux revues de pratiques professionnelles (RMM, staff médico-chirurgicaux) et aux DPC.
- **Optimisation médico-économique** : la réduction des actes non pertinents diminue les coûts directs (actes, séjours) et indirects (complications, réadmissions) sans pénaliser la qualité des soins.

## Sources de Données
- **PMSI MCO** : codes CCAM des actes + codes CIM-10 des diagnostics (DP, DR, DA) pour le croisement indication/acte séjour par séjour.
- **ScanSanté** : taux de recours nationaux par acte CCAM pour la détection des outliers volumétriques.
- **HAS - Indicateurs de pertinence des soins** : listes d'actes traceurs avec leurs critères de pertinence, issues du programme national de pertinence des soins (DREES/HAS).
- **Sociétés savantes** : recommandations cliniques par spécialité (SFO, SFR, SFAR, SFC) servant de référence pour la définition des indications validées.
- **Référence méthodologique** : Programme national de pertinence des soins, DREES/HAS, 2019-2023.

## Exemple de Valeurs
- **Arthroscopie du genou** : 20-35 % des actes réalisés seraient hors recommandations HAS selon les études françaises (arthrose seule sans lésion méniscale ou ligamentaire identifiée).
- **Hystérectomie** : taux national 180-200 pour 100 000 femmes, avec une variation régionale de 1 à 2 — signalant des pratiques hétérogènes non entièrement explicables par l'épidémiologie.
- **Césarienne** : taux national ~21 %, avec des établissements dépassant 30-35 % sans profil de risque documenté supérieur.
- **Chirurgie du rachis** : 15-25 % d'actes potentiellement non pertinents selon les études de la DREES (hernies discales opérées sans échec des traitements conservateurs).
- **Amygdalectomie** : réduction de 30 % du volume entre 2010 et 2020 suite aux recommandations HAS restreignant les indications, illustrant l'impact des référentiels sur la pertinence.

## Limites
- La pertinence ne peut pas être déterminée avec certitude depuis le seul PMSI : l'absence d'un code de comorbidité ne signifie pas son absence clinique réelle (sous-codage fréquent).
- Les critères de pertinence évoluent avec les recommandations : un acte considéré non pertinent selon les référentiels de 2015 peut être validé par des recommandations de 2023.
- L'indicateur peut stigmatiser des pratiques légitimes pour des sous-populations spécifiques non identifiables dans le PMSI (ex. : arthroplastie chez un patient jeune actif).
- La mise en œuvre d'une analyse de pertinence systématique à partir du PMSI requiert un investissement significatif en data management et une expertise DIM renforcée.
- Les résultats doivent être présentés aux équipes médicales avec précaution pour éviter un effet désincitatif sur les actes pertinents ou une gestion défensive de la codification.

## Références
- [HAS - Programme national de pertinence des soins](https://www.has-sante.fr/jcms/p_3322944/fr/programme-national-de-pertinence-des-soins)
- [DREES - Études sur la pertinence des hospitalisations](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH - Actes CCAM et diagnostics associés dans le PMSI](https://www.atih.sante.fr/)
- [ScanSanté - Taux de recours aux actes chirurgicaux](https://www.scansante.fr/)
