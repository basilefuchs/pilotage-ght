# Taux de Polypathologie Sévère

## Définition
Le taux de polypathologie sévère mesure la proportion de séjours pour lesquels le patient présente au moins trois pathologies chroniques actives et sévères, identifiées simultanément dans les diagnostics du PMSI (DP + DR + DA). La polypathologie sévère est associée à une consommation de soins disproportionnée, un risque élevé de réadmission, de complications iatrogènes et de perte d'autonomie. Ces patients — souvent qualifiés de « grands polypathologiques » ou de patients en situation de vulnérabilité médico-sociale — nécessitent une coordination renforcée et représentent un enjeu majeur de pilotage pour les GHT, tant en termes de ressources mobilisées que d'organisation de l'aval hospitalier.

## Calcul
Le taux de polypathologie sévère est calculé comme suit :

```
Taux de polypathologie sévère (%) = (Nombre de séjours avec ≥ 3 pathologies chroniques actives sévères / Nombre total de séjours MCO) × 100
```

**Précisions méthodologiques** :
- Les pathologies chroniques sont identifiées par une liste de codes CIM-10 validée, issue des référentiels HAS ou de l'adaptation française des listes de Barnett et al. (2012). Les principales pathologies retenues sont : insuffisance cardiaque (I50), BPCO (J44), diabète (E10-E14), insuffisance rénale chronique (N18), démence (F00-F03), cancer actif (C00-C97), hépatopathie chronique (K70-K77), AVC séquellaire (I69), dépression sévère (F32-F33), obésité morbide (E66).
- Le critère de « sévérité » peut être affiné par la présence de complications (ex. : diabète avec complications E10.1-E14.9 plutôt que E10.0-E14.0) ou par un score de Charlson ≥ 3 comme proxy.
- Un sous-indicateur pertinent est le **taux de séjours avec CCI ≥ 3 ET ≥ 3 DA chroniques**, combinant les deux approches pour cibler les profils les plus complexes.
- L'analyse est segmentée par tranche d'âge (notamment ≥ 75 ans), par service et par établissement du GHT.

## Utilité
- **Identification des patients à haute intensité de soins** : les polypathologiques sévères représentent une minorité des séjours (10-20 %) mais concentrent 30-50 % des journées d'hospitalisation et des coûts.
- **Pilotage de la coordination aval** : cibler les patients polypathologiques pour les programmes de gestion de cas, HAD, et coordination DAC (Dispositif d'Appui à la Coordination) dès la sortie MCO.
- **Anticipation des réadmissions** : la polypathologie sévère est le premier prédicteur de réadmission non programmée à 30 jours ; son suivi permet de prioriser les actions de prévention.
- **Dimensionnement gériatrique** : évaluer le besoin d'unités spécialisées (gériatrie, soins palliatifs, unités de soins complexes) en fonction de la charge en polypathologie sévère du GHT.
- **Dialogue avec le médico-social** : objectiver le flux de patients polypathologiques nécessitant une orientation vers des EHPAD, USLD ou SSIAD, pour anticiper les tensions sur les filières de sortie.

## Sources de Données
- **PMSI MCO** : ensemble des codes CIM-10 du RSS (DP, DR, DA) pour l'identification des pathologies chroniques actives par séjour.
- **ATIH / ScanSanté** : base nationale PMSI pour le calcul des taux à l'échelle d'un établissement ou d'un territoire.
- **SNDS** : pour une identification plus robuste de la polypathologie sur trajectoire longitudinale (ALD, médicaments traceurs, séjours antérieurs) plutôt que sur le seul séjour index.
- **Référence méthodologique** : Barnett K. et al., *Epidemiology of multimorbidity and implications for health care, research, and medical education: a cross-sectional study*, The Lancet, 2012.

## Exemple de Valeurs
- **Taux de polypathologie sévère (≥ 3 pathologies chroniques)** : 15-25 % des séjours MCO en France, selon la définition et le type d'établissement.
- **Services de gériatrie et médecine interne** : taux > 50 %, avec un CCI moyen > 4.
- **Patients ≥ 75 ans** : 40-60 % présentent une polypathologie sévère, contre 5-10 % chez les moins de 65 ans.
- **Consommation de ressources** : les séjours polypathologiques sévères ont une DMS 2 à 3 fois supérieure à la moyenne et un taux de réadmission à 30 jours de 20-30 %.
- **Concentration des coûts** : les 10 % de séjours les plus polypathologiques représentent 30-40 % des dépenses MCO totales d'un GHT.
- **Évolution projetée** : avec le vieillissement démographique, le taux de polypathologie sévère devrait augmenter de 15-20 % d'ici 2035 dans la majorité des territoires.

## Limites
- L'identification des pathologies chroniques dans le PMSI est conditionnée à leur codage en tant que DA : les comorbidités non codées sont invisibles, ce qui sous-estime le taux réel de polypathologie.
- La définition de « sévère » est arbitraire et non standardisée ; les comparaisons inter-établissements nécessitent une liste de pathologies commune et explicitée.
- Le taux calculé sur séjour (et non sur patient) peut comptabiliser plusieurs fois le même patient s'il est hospitalisé plusieurs fois dans l'année.
- La polypathologie est corrélée à l'âge et à la précarité sociale : les comparaisons inter-GHT sans standardisation sur ces variables sont biaisées.
- L'indicateur ne distingue pas les polypathologies stables (bien équilibrées, peu consommatrices) des polypathologies instables (décompensations fréquentes, forte consommation).

## Références
- [Barnett K. et al., Epidemiology of multimorbidity, The Lancet, 2012](https://doi.org/10.1016/S0140-6736(12)60240-2)
- [HAS - Guide parcours de soins des patients en situation complexe](https://www.has-sante.fr/)
- [ATIH - Diagnostics associés et comorbidités dans le PMSI](https://www.atih.sante.fr/)
- [SNDS - Données longitudinales et ALD](https://www.snds.gouv.fr/)
