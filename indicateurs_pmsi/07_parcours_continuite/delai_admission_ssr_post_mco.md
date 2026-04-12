# Délai d'Admission en SSR Post-MCO

## Définition

Durée médiane (en jours) entre la date de sortie d'un séjour MCO (DATESOR dans le RSA) et la date d'entrée dans un établissement de SSR (Soins de Suite et Réadaptation) pour le même patient, identifié par chaînage NIR crypté. Calculé sur les patients dont le mode de sortie MCO = 6 (mutation vers SSR) ou dont le séjour SSR suivant a un mode d'entrée = 6 (provenance MCO). Stratifié par pathologie et motif de SSR : neurologie (AVC, traumatismes crâniens — GME 02xx), orthopédie/locomoteur (PTH, PTG, fractures — GME 01xx), cardiologie/pneumologie (GME 04xx), oncologie (GME 07xx), gériatrie polyvalente (GME 09xx).

Un délai long signale un problème de disponibilité de lits SSR (bed-blocking), un défaut de coordination entre MCO et SSR, ou une orientation inadaptée vers un établissement SSR non disponible. Cet indicateur est le marqueur le plus direct de la fluidité de la filière MCO→SSR au sein d'un GHT. Il est à lire en parallèle avec le taux de bed-blocking MCO (journées excédentaires liées à l'attente SSR) et le délai médian de placement SSR par la cellule d'orientation.

## Calcul

Chaînage PMSI MCO RSA × PMSI SSR RHS par NIR crypté SNDS.

Population éligible :

```
Population d'index (séjour MCO émetteur) :
  → Séjours MCO avec mode_sort = 6 (transfert vers SSR)
  OU séjours SSR avec mode_entrée = 6 (provenance MCO identifiée par chaînage NIR
     dans les 90 jours suivant la DATESOR MCO)
  → Exclusions :
      - Décès pendant le séjour MCO (mode_sort = 9)
      - Séjours pédiatriques (âge < 18 ans)
      - Délai > 90 jours (rupture de parcours, non-attributable au séjour MCO index)
      - Délai < 0 (erreurs de chaînage à corriger)
```

Calcul du délai :

```
Délai (jours) = date_entrée_SSR (1er RHS du séjour SSR) − DATESOR_MCO

Indicateurs dérivés :
  → Délai médian (en jours) — préféré à la moyenne (distribution asymétrique)
  → Distribution par tranches :
      J0      : même jour (admission SSR le jour de la sortie MCO)
      J1–J3   : filière organisée (convention MCO-SSR formalisée)
      J4–J7   : délai acceptable
      J8–J14  : délai préoccupant (bed-blocking probable)
      > J14   : rupture de filière
  → Proportion de patients admis en SSR en J0-J3 (indicateur synthétique de fluidité)
```

Stratification recommandée :

```
Stratification par GME SSR :
  GME 01xx : Affections de l'appareil locomoteur (PTH, PTG, fractures)
             → Objectif : délai médian J1-J3
  GME 02xx : Affections neurologiques (AVC, TC)
             → Objectif SFNV : admission SSR neuro ≤ 72h post-stabilisation
  GME 04xx : Affections cardiovasculaires et pulmonaires
  GME 07xx : Affections oncologiques et hématologiques
  GME 09xx : Affections de la personne âgée polypathologique (gériatrie)
             → Délai structurellement plus long (offre SSR gériatrique tendue)

Stratification complémentaire :
  → Par établissement MCO d'origine (intra-GHT vs hors-GHT)
  → Par établissement SSR de destination (intra-GHT vs SSR partenaire)
  → Par saison (pic hivernal = tension capacitaire SSR gériatrique)
```

## Utilité

- **Identifier les tensions capacitaires SSR par spécialité et par territoire** : un délai médian > J7 dans un GME donné est un signal objectif de saturation de l'offre SSR correspondante, exploitable dans le dialogue avec l'ARS pour une demande d'autorisation de lits
- **Quantifier l'impact du bed-blocking sur les unités MCO** : le délai MCO→SSR est directement corrélé aux journées excédentaires en MCO (lits aigus occupés par des patients en attente de SSR), ce qui en fait un levier financier documentable
- **Évaluer les conventions de coopération MCO-SSR** : les GHTs ayant des conventions formalisées avec des délais de réponse garantis présentent des médianes J1-J3 ; l'indicateur permet de mesurer l'impact d'une convention avant/après sa signature
- **Comparer les délais entre établissements MCO du GHT** : un service d'orthopédie obtenant un délai médian J2 là où un autre obtient J8 pour un profil patient comparable oriente vers une investigation des pratiques de demande d'admission SSR
- **Cibler les spécialités SSR à développer en priorité** : les GME avec les délais les plus longs et les volumes les plus importants justifient en premier les créations de lits ou les négociations de réservation
- **Suivi des filières organisées** (AVC, fractures du col fémur) : des objectifs de délai spécifiques sont fixés par les sociétés savantes (SFNV ≤72h pour AVC) ; cet indicateur permet un suivi opérationnel de leur respect

## Sources de Données

- **PMSI MCO RSA** : DATESOR (date de sortie MCO), mode_sort (= 6 pour transfert SSR), GHM, service médical, NIR crypté
- **PMSI SSR RHS** : date d'entrée (issue du 1er RHS du séjour), mode_entrée (= 6 pour provenance MCO), GME, NIR crypté
- **Chaînage SNDS par NIR crypté** : identifiant pseudonymisé permettant d'apparier les séjours MCO et SSR d'un même patient, y compris entre établissements différents du territoire

## Exemple de Valeurs

- **Délai médian national France (tous GME, ATIH 2022)** : ~4-6 jours
- **Filières organisées (AVC, PTH/PTG avec convention MCO-SSR)** : J1-J2
- **Gériatrie polyvalente** : J7-J14 (tension chronique de l'offre SSR gériatrique)
- **Neurologie cérébro-lésée** : J3-J5 (objectif SFNV ≤ 72h souvent non atteint hors UNV centres experts)
- **Proportion admis J0-J3** : environ 40-55% dans les GHTs avec convention formalisée, 15-25% sans
- **GHTs avec cellule d'orientation SSR dédiée** : réduction de 30-40% du délai médian constatée dans les études de mise en œuvre (Reuben et al. Am J Geriatr 2017)

## Limites

- Le chaînage par NIR peut manquer les transferts vers des SSR hors périmètre du SNDS local ou vers des établissements privés non conventionnés — sous-estimation possible dans les territoires avec forte offre SSR privée
- Les séjours MCO avec mode_sort = 6 mais qui correspondent en réalité à des transferts temporaires (consultation externe, acte technique avec retour MCO) peuvent être mal codés et biaiser le numérateur
- Le délai J0 (même jour) peut correspondre à un transfert organisé en urgence (dégradation clinique en MCO) ou à une admission SSR pré-planifiée — la distinction n'est pas possible par le seul PMSI
- L'indicateur ne distingue pas les délais subis (indisponibilité de lits SSR) des délais choisis (délai médical pour stabilisation clinique avant transfert) — une analyse clinique complémentaire est nécessaire pour interpréter les délais courts (< J1) qui peuvent signaler une admission SSR prématurée

## Références

- [SFNV — Recommandations sur la filière AVC et les délais d'admission en SSR neurovasculaire (2022)](https://www.sfnv.net/)
- [Ou L. et al. — Delayed discharge from hospital: length of stay and cost implications, BMJ Open 2021](https://doi.org/10.1136/bmjopen-2020-044193)
- [HAS — Recommandations de bonne pratique : rééducation après AVC (2012)](https://www.has-sante.fr/)
- [ATIH — Statistiques et publications PMSI SSR : données nationales d'activité par GME](https://www.atih.sante.fr/)
- [DREES — Les soins de suite et de réadaptation en France : panorama de l'offre et des besoins (2021)](https://www.drees.solidarites-sante.gouv.fr/)
