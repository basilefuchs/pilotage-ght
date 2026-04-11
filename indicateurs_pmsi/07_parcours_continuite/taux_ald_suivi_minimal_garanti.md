# Taux de Patients ALD avec Suivi Minimal Garanti

## Définition

Mesure la proportion de patients porteurs d'une Affection de Longue Durée (ALD) active sur le territoire du GHT ayant bénéficié d'une surveillance ambulatoire minimale recommandée au cours des 12 derniers mois : au moins une consultation auprès de leur médecin traitant déclaré (généraliste) ET au moins une consultation auprès du spécialiste approprié à leur pathologie ALD. L'indicateur est calculé exclusivement à partir du DCIR (table ER_PRS_F pour les consultations, table IR_IMB_R pour le statut ALD). Ce « suivi minimal garanti » constitue un proxy de la réalisation effective de la coordination des soins ambulatoires mandatée par le protocole du parcours de soins ALD. Les patients porteurs d'une ALD ne bénéficiant pas de cette surveillance minimale présentent un risque élevé de décompensation non détectée pouvant conduire à des hospitalisations évitables. L'indicateur est stratifié par type d'ALD (ALD1=tumeurs, ALD5=diabète, ALD13=insuffisance cardiaque, ALD23=BPCO, etc.) et par score de défavorisation sociale.

## Calcul

La population ALD active est extraite de la table IR_IMB_R en sélectionnant les patients dont la date de fin d'ALD (IMB_ALD_DTF) est postérieure au 31/12/N ou nulle, et dont la commune de résidence (BEN_RES_COM) appartient aux communes du GHT. Le suivi minimal garanti requiert la satisfaction simultanée de deux conditions vérifiées dans ER_PRS_F sur l'année N.

```
Population ALD active = patients IR_IMB_R avec IMB_ALD_DTF > 31/12/N (ou NULL)
  et BEN_RES_COM dans les communes du GHT

Suivi minimal garanti :
  Condition 1 : ≥1 consultation médecin traitant en année N
    → ER_PRS_F : PRS_NAT_REF IN ('C', 'CS', 'V', 'VS') et PSP_SPE_COD = 01 (MG)
    → chaîné par NIR crypté avec statut MT dans IR_BEN_R

  Condition 2 : ≥1 consultation spécialiste pertinent pour l'ALD en année N
    → PSP_SPE_COD selon l'ALD :
       ALD1  (tumeurs)     → oncologue (spe=28) ou chirurgien (spe=02/15)
       ALD5  (diabète)     → endocrinologue (spe=23)
       ALD13 (IC)          → cardiologue (spe=04)
       ALD14 (EP)          → pneumologue (spe=11)
       ALD23 (BPCO)        → pneumologue (spe=11)
       ALD12 (HTA sévère)  → cardiologue (spe=04)

Taux suivi minimal (%) = (Patients ALD avec condition 1 ET condition 2)
                         / (Total ALD actifs) × 100
```

Sous-indicateurs calculés en parallèle :

```
Taux suivi MG seul (%)
  = (Patients ALD avec condition 1 uniquement, sans condition 2)
    / (Total ALD actifs) × 100

Taux rupture totale (%)
  = (Patients ALD sans aucun contact ambulatoire MG ni spécialiste)
    / (Total ALD actifs) × 100

Taux suivi minimal par ALD (n° 1 à 30)
  = calcul décliné pour chaque IMB_ALD_NUM

Gradient social
  = taux suivi minimal stratifié par quintile IDH-2
    (jointure BEN_RES_COM → code commune INSEE → indice IDH-2/FDEP)
```

## Utilité

- **Identification des patients ALD à risque de décompensation** : les patients sans suivi minimal sont une population prioritaire pour les programmes de gestion de cas proactive (case management GHT).
- **Corrélation avec les taux d'hospitalisation** : les patients sans suivi minimal présentent des taux d'HPE et de réadmission significativement plus élevés, permettant d'objectiver l'impact de la rupture de suivi.
- **Évaluation des programmes de coordination GHT** : mesure l'efficacité des dispositifs PRADO, HAD et consultations avancées sur l'amélioration de la surveillance des patients ALD.
- **Dialogue avec la CPAM** : les indicateurs CAQES intègrent la qualité du suivi ALD ; disposer de données calculées par le GHT renforce le positionnement dans les négociations contractuelles.
- **Identification des déserts de spécialistes** : détecte les communes rurales où le déficit d'accès au spécialiste explique le non-suivi (barrière d'accès vs non-observance).
- **Ciblage des programmes de médiation en santé** : oriente les actions vers les types d'ALD et les zones de défavorisation sociale présentant les taux de rupture de suivi les plus élevés.

## Sources de Données

- **DCIR IR_IMB_R** : registre ALD — variables clés : BEN_NIR_PSA (identifiant patient), IMB_ALD_NUM (numéro ALD 1-30), IMB_ALD_DTF (date de fin d'ALD), IMB_ETM_NAT (nature de l'exonération).
- **DCIR ER_PRS_F** : table des prestations — variables clés : PSE_ACT_QSN (quantité d'actes), PRS_NAT_REF (nature de l'acte), PSP_SPE_COD (spécialité du prescriptant), ETE_CAT_COD (catégorie de l'établissement).
- **DCIR IR_BEN_R** : référentiel bénéficiaires — statut médecin traitant déclaré, chaînage avec ER_PRS_F par NIR crypté.
- **INSEE données communes** : indice de défavorisation sociale IDH-2/FDEP par commune, jointure sur BEN_RES_COM pour la stratification sociale.
- **HAS protocoles de soins ALD** : référentiel des consultations recommandées par type d'ALD, servant de base à la définition du suivi minimal garanti.

## Exemple de Valeurs

- **Défaut de suivi MG national** : environ 15 à 20 % des patients ALD actifs n'ont aucune consultation avec leur médecin traitant déclaré sur une année civile.
- **Rupture totale de suivi ambulatoire** : 8 à 12 % des patients ALD actifs sans aucun contact ni avec un MG ni avec un spécialiste sur l'année.
- **Meilleur suivi par ALD** : ALD1 (cancer) affiche le taux de suivi minimal garanti le plus élevé (~90 %), en lien avec les protocoles oncologiques très structurés.
- **Plus faible suivi par ALD** : ALD23 (BPCO) et ALD14 (épilepsie) présentent les taux les plus bas (~65-70 %), révélant un déficit de suivi spécialisé.
- **Gradient social** : les patients du quintile de défavorisation le plus élevé ont une probabilité d'atteindre le suivi minimal 40 à 60 % inférieure à celle des patients les moins défavorisés.
- **Déficit rural** : les communes sans spécialiste local affichent des taux de consultation spécialisée parmi les patients ALD inférieurs de 20 à 30 points par rapport à la moyenne nationale.

## Limites

- Le DCIR ne capture que les consultations remboursées — les consultations gratuites en centres de santé communautaires ou en vacation associative peuvent ne pas apparaître, conduisant à une sous-estimation du suivi réel.
- Les codes de spécialité (PSP_SPE_COD) reflètent parfois la spécialité principale déclarée du professionnel et non son rôle effectif lors de la consultation, pouvant introduire un biais de classification.
- La définition « 1 consultation MG + 1 consultation spécialiste » constitue une simplification du suivi minimal ; les protocoles HAS par ALD prévoient des exigences plus détaillées (fréquence, bilan biologique, etc.) non capturées ici.
- Les patients ayant déménagé hors du territoire du GHT en cours d'année peuvent apparaître comme non suivis même s'ils ont reçu des soins dans un autre territoire.
- Le registre ALD (IR_IMB_R) présente des délais de mise à jour des dates de fin d'ALD : certains patients « ALD actifs » selon le registre peuvent avoir achevé leur traitement sans que la date de clôture ait été enregistrée.

## Références

- [HAS — Protocoles nationaux de diagnostic et de soins (PNDS) par ALD](https://www.has-sante.fr/)
- [CNAM — CAQES indicateurs de suivi ALD](https://www.ameli.fr/)
- [SNDS IR_IMB_R — Table ALD du DCIR](https://www.snds.gouv.fr/)
- [DREES — Rapport sur les ALD en France](https://www.drees.solidarites-sante.gouv.fr/)
- [Bonnet F. et al. — Suivi des patients diabétiques (ALD5) et hospitalisations évitables, Rev Med Interne 2019](https://www.revmed.ch/)
