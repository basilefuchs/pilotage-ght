# Indice de Pareto α — Épaisseur de la Queue de Distribution des Séjours par Patient

## Définition

La distribution du nombre de séjours par patient sur une période donnée présente une **queue lourde** caractéristique : la majorité des patients ont 1 ou 2 séjours/an, mais une minorité en cumule 10, 20, voire 50. Cette structure ne se résume pas correctement par la moyenne ni la variance (qui sont peu robustes en présence de valeurs extrêmes).

La **loi de Pareto** (Pareto 1896, formalisée par Newman 2005) modélise ce type de distribution par :

P(N ≥ n) = (n / x_min)^{−α}    pour n ≥ x_min

où :
- α est l'**exposant de Pareto** (paramètre de queue) : plus α est faible, plus la queue est épaisse (présence de très gros consommateurs) ;
- x_min est le seuil à partir duquel la loi s'applique (typiquement 2 ou 3 séjours).

L'**indice de Pareto α** appliqué à la distribution du nombre de séjours MCO par patient sur 12 mois fournit un descripteur **scalaire et robuste** de la polyhospitalisation structurelle d'un GHT.

Positionnement vs existant :
- complète le `coefficient_gini_consommation_hospitaliere` (Gini) qui résume la distribution entière mais sans modèle paramétrique, donc moins comparable aux travaux de complexité statistique ;
- complète `part_valorisation_top_decile_patients_mco` (P10) qui mesure la queue en valeur monétaire mais ne donne pas la **forme** de la distribution ;
- introduit la possibilité d'une comparaison à une référence théorique (loi de Zipf, α = 1, ou seuil critique α = 2 sous lequel la variance diverge).

## Calcul

```
Périmètre :
  → Tous les patients ayant ≥ 1 séjour MCO sur la fenêtre annuelle (RSA chaîné par ANO)
  → N_i = nombre de séjours MCO du patient i sur 12 mois

Étapes :
  1. Construire la distribution empirique de N_i
  2. Choisir x_min (Clauset et al. 2009 — méthode KS) :
       x_min = argmin_{x} D_KS( P_empirique(N ≥ n | n ≥ x), P_Pareto(N ≥ n | α̂(x), x) )
     En pratique, tester x_min ∈ {2, 3, 4, 5}
  3. Estimer α par maximum de vraisemblance (Hill 1975) :
       α̂ = 1 + n_tail × [ Σ_{i : N_i ≥ x_min} ln(N_i / x_min) ]^{-1}
     où n_tail = nombre de patients avec N_i ≥ x_min
  4. Erreur standard :
       SE(α̂) = (α̂ − 1) / √n_tail
  5. Test d'adéquation : statistique KS entre distribution empirique et Pareto ajustée,
     p-value par bootstrap (≥ 1 000 réplications)
```

Interprétation des plages :

```
α < 2  : queue très lourde — variance théorique infinie ; risque de gros consommateurs extrêmes
2 ≤ α < 3 : queue lourde — moyenne définie mais variance forte
α ≥ 3 : queue modérée — moyenne et variance bien définies, peu de très gros consommateurs
```

Indicateurs dérivés :

```
α_GHT vs α_référence_nationale     : positionnement (α plus bas = polyhospitalisation > moyenne)
Δα = α(N) − α(N−1)                  : évolution temporelle (Δα < 0 → queue qui s'épaissit)
α par CMD                           : par exemple CMD 11 (rein), 17 (hémato), 28 (séances)
                                      ont structurellement α < 2
```

## Utilité

- **Caractériser la polyhospitalisation structurelle** d'un GHT par un paramètre unique, comparable inter-territoires et inter-périodes.
- **Détecter une dérive de la queue** : Δα < 0 sur 2-3 ans signale l'apparition de patients « ultra-polyhospitalisés » — déclenche une analyse fine (filière dialyse saturée ? cancer chronique mal coordonné ? défaut de soins primaires ?).
- **Comparer GHT entre eux** : pondérer le benchmark par α permet de neutraliser l'effet « grand établissement » (volume) et de comparer la **forme** de la patientèle.
- **Décomposer la queue par CMD** : identifier les CMD à α < 2 (séances, IRC, hémato) pour cibler les filières de coordination prioritaires.
- **Justifier des investissements en soins primaires / coordination** : un α qui s'écarte de la moyenne nationale vers le bas est un argument quantitatif fort en dialogue ARS sur la nécessité d'une CPTS, d'un DAC, ou d'un programme parcours complexe.
- **Suivre l'effet de programmes territoriaux** : un programme efficace de coordination doit faire **remonter α** (réduire l'épaisseur de la queue par stabilisation des patients chroniques en ambulatoire).

## Sources de Données

- **PMSI MCO — RSA** sur 12 mois glissants, chaîné par ANO patient.
- **Variables nécessaires** : ANO patient, n° séjour ; pas de variable monétaire requise (dénombrement pur).
- Optionnel : **PMSI SSR/HAD/PSY** pour calcul d'un α tous champs.
- Optionnel : **SNDS** pour élargissement à la consommation ambulatoire (consultations, biologie) — α tous-soins.

## Exemple de Valeurs

Ordres de grandeur — **expert, non sourcé sur PMSI français** ; à calibrer empiriquement sur les bases ATIH (loi de Pareto sur séjours hospitaliers documentée chez Newman 2005, pas de référence française dédiée à ce jour) :

- **α populationnel MCO toutes CMD confondues** : ordre attendu 2,2–2,8 (queue lourde mais variance définie).
- **CMD 28 (séances : dialyse, chimio, transfusion)** : α attendu ≈ 1,2–1,6 (queue très lourde — quelques patients à 50+ séances/an).
- **CMD 11 (rein-voies urinaires)** : α attendu ≈ 1,8–2,2 (dialyse chronique).
- **Chir programmée pure** : α attendu ≥ 3 (peu de récidives par patient).
- **CHU vs CH** : α systématiquement plus bas en CHU (recours sur patients chroniques sévères).

Seuils d'alerte indicatifs :
- α < 2 sur la population MCO totale → queue d'épaisseur préoccupante, à investiguer
- Δα < −0,2 entre deux années consécutives → dérive significative

## Limites

- **Sensibilité au choix de x_min** : un x_min mal choisi biaise α̂ ; toujours utiliser la procédure Clauset/KS et publier l'intervalle de confiance.
- **Effectif de queue minimal** : n_tail (patients avec N_i ≥ x_min) doit être ≥ 200 pour une estimation stable ; sous ce seuil, ne pas calculer α (préférer le P10).
- **Loi de Pareto vs autres queues lourdes** : la distribution empirique peut être mieux ajustée par une log-normale ou une Weibull ; **toujours tester l'adéquation** (p-value KS ≥ 0,1 acceptable).
- **Effet de censure annuelle** : un patient hospitalisé en décembre puis janvier voit ses séjours scindés sur 2 années — préférer fenêtre glissante 12 mois.
- **Comparabilité** : α dépend du périmètre (séances incluses ou non, SSR inclus ou non) — documenter strictement.
- **Mortalité** : les décès en cours d'année tronquent N_i vers le bas pour les patients en fin de vie — biais d'estimation pour la queue (mais effet généralement modeste).
- **Indicateur exploratoire** : aucune référence française publiée à ce jour ; l'établissement doit construire son propre étalonnage.

## Références

- Pareto V. — Cours d'économie politique, Lausanne 1896 (formulation originale)
- Newman M.E.J. — Power laws, Pareto distributions and Zipf's law. *Contemporary Physics* 2005 — [DOI](https://doi.org/10.1080/00107510500052444)
- Clauset A., Shalizi C.R., Newman M.E.J. — Power-law distributions in empirical data. *SIAM Review* 2009 — [DOI](https://doi.org/10.1137/070710111)
- Hill B.M. — A simple general approach to inference about the tail of a distribution. *Annals of Statistics* 1975 — [DOI](https://doi.org/10.1214/aos/1176343247)
- Amundsen O. et al. — High-cost patients (queue de distribution des coûts hospitaliers). *BMC Health Serv Res* 2024 — [DOI](https://doi.org/10.1186/s12913-024-12051-3) (PMID:39695620)
- ATIH — Guide méthodologique MCO en vigueur — [atih.sante.fr](https://www.atih.sante.fr/)
