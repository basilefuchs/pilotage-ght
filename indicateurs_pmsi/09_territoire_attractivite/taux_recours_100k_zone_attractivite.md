# Taux de Recours Hospitalier pour 100 000 Habitants de la Zone d'Attraction (TR100k)

## Définition

Le TR100k est un indicateur de **débit de recours territorial** : il exprime le volume annuel de séjours MCO produits par un établissement (ou un GHT) pour 100 000 habitants de sa zone d'attraction, indépendamment de la taille de la zone. C'est l'indicateur fondateur de l'analyse des variations géographiques de soins (Wennberg & Gittelsohn, 1973 ; OCDE Health at a Glance), utilisé en France par la DREES dans l'atlas des établissements de santé pour comparer la densité d'utilisation hospitalière entre territoires.

**TR100k = ( RSA_etab / Pop_zone ) × 100 000**

où :
- **RSA_etab** = nombre de séjours MCO produits par l'établissement pour les patients domiciliés dans sa zone d'attraction sur la période
- **Pop_zone** = population résidente de la zone d'attraction (source INSEE RP)

**Déclinaison par CMD :**

**TR100k_(c) = ( RSA_etab_(c) / Pop_zone ) × 100 000**

Le TR100k se distingue structurellement de trois indicateurs voisins présents dans la base :

| Indicateur | Ce qu'il mesure | Portée |
|---|---|---|
| `parts_marche_territoire.md` | Fraction relative : RSA_etab / RSA_tous_etab_zone | Positionnement concurrentiel |
| `couverture_territoriale.md` | Offre : lits ou spécialistes pour 1 000 hab. | Ressources disponibles |
| `taux_recours_hospitalier_standardise_age_sexe.md` | RSA_obs / RSA_attendus (neutralise l'âge/sexe) | Sur/sous-recours net de la démographie |
| **TR100k** | **Débit absolu : RSA produits / 100 000 hab.** | **Intensité brute de consommation observée** |

Le TR100k est brut et non standardisé : il capture à la fois l'effet de la structure démographique locale, de la morbidité, de l'offre hospitalière induite et du comportement de recours — ce que le TRHS décompose mais que le TR100k, lui, mesure dans sa totalité. C'est l'indicateur de premier niveau pour la description territoriale avant toute analyse causale.

## Calcul

Sources : PMSI MCO RSA (ATIH) + Référentiel Zones d'attraction ATIH + INSEE Recensement de la Population.

```
Étape 1 — Définition et délimitation de la zone d'attraction :
  Méthode ATIH (standard) : zone d'attraction d'un établissement =
    ensemble des communes pour lesquelles l'établissement capte la majorité des séjours
    (méthode de la pluralité : commune rattachée à l'établissement qui reçoit le plus
    de ses résidents en MCO, tous établissements nationaux confondus)

  Alternative : zone de santé ARS ou bassin de vie INSEE
    → Documenter la méthode retenue ; l'écart entre méthodes peut atteindre ±15% sur Pop_zone

  Résultat : liste de codes INSEE communes ∈ zone d'attraction de l'établissement
             Mise à jour : la zone ATIH est recalculée chaque année — utiliser
             le référentiel millésimé correspondant à l'exercice PMSI analysé

Étape 2 — Extraction des RSA de l'établissement pour les patients de la zone :
  RSA_etab = COUNT(RSA)
    WHERE `finessgeo` = etab
      AND CODE_INSEE_COMMUNE_PATIENT ∈ zone_attraction   -- ou CODE_POSTAL si INSEE indisponible
      AND MODE_SORTIE NOT IN ('9')                       -- exclure les transferts sans sortie
    Optionnel : AND NBSEANCES = 0                        -- exclure les séjours de séances
                                                          -- selon l'objectif d'analyse

  Variables PMSI utilisées :
    `finessgeo`              : identifiant établissement géographique (9 chiffres)
    CODE_INSEE_COMMUNE_PAT  : commune de résidence du patient (disponible en RSA depuis 2012)
    CODE_POSTAL             : alternative si commune INSEE non fiable (rural fragmenté)
    NBSEANCES               : nombre de séances (0 pour les séjours avec nuitée ou ambulatoire)
    MODE_SORTIE             : mode de sortie (9 = décès avec transfert, à traiter selon cas)

Étape 3 — Population de la zone d'attraction :
  Pop_zone = Σ_{commune ∈ zone} Population_légale_INSEE_{commune}
  Source   : INSEE RP millésime N-2 ou N-3 (dernier disponible publié)
             Fichier « Populations légales » par commune, code COG en vigueur

  Précaution : concordance entre le référentiel communal PMSI (CODE_INSEE) et le COG INSEE
               — les fusions de communes (loi NOTRe) peuvent créer des discordances
               → appliquer la table de correspondance COG INSEE de l'année de référence

Étape 4 — Calcul du TR100k global et par CMD :
  TR100k           = ( RSA_etab / Pop_zone ) × 100 000
  TR100k_(c)       = ( RSA_etab_(c) / Pop_zone ) × 100 000  pour chaque CMD c

  Convention : si Pop_zone < 10 000 hab. → TR100k calculé mais marqué « instable »
               (variabilité inter-annuelle forte sur petit dénominateur)

Étape 5 — Calcul sur le périmètre GHT (agrégation multi-établissements) :
  RSA_GHT          = Σ_{etab ∈ GHT} RSA_etab_zone_etab
  Pop_zone_GHT     = Pop_zone_union (union des zones d'attraction, sans double comptage)
  TR100k_GHT       = ( RSA_GHT / Pop_zone_GHT ) × 100 000
  → Permet de positionner le GHT comme un acteur unique face à son bassin de population
```

Indicateurs dérivés :

```
Coefficient de variation intra-GHT (Wennberg-style) :
  Pour chaque sous-territoire t du GHT (zones d'attraction des établissements membres) :
    CV = σ( TR100k_t ) / μ( TR100k_t ) × 100
  CV > 30% → variabilité territoriale significative au sein du GHT
              (suggère des inégalités de recours ou des différences d'offre intra-GHT)

Ratio de recours au CHU de référence :
  TR100k_etab / TR100k_CHU_zone_ref
  > 1 → l'établissement attire plus de séjours/hab que le CHU depuis sa zone
  < 1 → le CHU capte proportionnellement plus de recours de sa zone

Évolution temporelle (TCAM sur 3 ans) :
  TCAM_TR100k = ( TR100k_{(N)} / TR100k_{(N-3)} )^(1/3) − 1
  TCAM > +2%/an → croissance du recours supérieure à la démographie
  TCAM < −2%/an → érosion de l'intensité d'utilisation (ambulatoire, HAD, prévention)

Écart au taux national de référence :
  ΔTR100k = TR100k_etab − TR100k_national_CMD_{(c)}
  Source taux national : DREES "Les établissements de santé" ou PMSI national ATIH
```

## Utilité

- **Mesurer la densité d'utilisation hospitalière du territoire sans biais de taille** : un GHT rural de 80 000 habitants et un GHT urbain de 400 000 habitants ne peuvent pas être comparés en volume brut ; le TR100k ramène les deux sur une base per capita commune, permettant une comparaison directe de l'intensité d'utilisation et l'identification d'écarts territoriaux structurels.
- **Analyser les variations géographiques de soins intra-GHT** : calculé par sous-territoire (commune, bassin de vie, zone d'attraction d'établissement membre), le TR100k par CMD révèle les poches de sur-recours (traumatologie en zone industrielle, CMD 5 en zone âgée) et de sous-recours (CMD 11 Rein, CMD 13 Femme dans les zones éloignées) — base de diagnostic pour le Projet Médical de Territoire.
- **Alimenter le dialogue avec l'ARS sur les besoins non couverts** : un TR100k CMD 14 (obstétrique) de 1 200 pour 100 000 femmes 15-49 ans dans une zone sans maternité de proximité est l'argument épidémiologique brut pour une demande d'autorisation ou de renforcement de capacité, à soumettre dans le cadre du SROS-PRS.
- **Détecter l'impact de l'ouverture ou de la fermeture d'un service** : si un service de cardiologie ferme dans un établissement du GHT, le TR100k CMD 5 de l'établissement voisin doit croître en N+1/N+2 (report de flux) — l'absence de croissance signale que les patients se dirigent vers un établissement hors GHT (fuite externe).
- **Benchmarker le GHT contre des territoires comparables** : comparer le TR100k global avec des GHT de profil démographique et géographique similaires (DREES cartographie des territoires, zonage rural/urbain INSEE) identifie si le bassin de population est sur- ou sous-hospitalisé par rapport à des pairs nationaux.
- **Calibrer les projections capacitaires à 5-10 ans** : en combinant le TR100k observé avec les projections démographiques INSEE (Omphale), le nombre de séjours attendus futurs est directement calculable : RSA_prévu = TR100k × Pop_zone_projetée / 100 000 — sans nécessiter de modèle épidémiologique complexe.

## Sources de Données

- **PMSI MCO RSA** (ATIH) : variables `finessgeo`, `CODE_INSEE_COMMUNE_PAT` (ou `CODE_POSTAL`), `NBSEANCES`, `MODE_SORTIE`, `CMD` — extraction annuelle sur exercice complet.
- **Référentiel Zones d'attraction des établissements** (ATIH) : fichier de correspondance commune → établissement principal, mis à jour annuellement et publié sur le portail ATIH. Disponible également sur ScanSanté (onglet Territoire).
- **INSEE Recensement de la Population (RP)** : fichier « Populations légales » par commune — millésime N-2 (dernier disponible au moment du calcul). Téléchargeable sur insee.fr. Utiliser la table de correspondance COG pour les communes fusionnées.
- **INSEE Omphale** (pour les dérivés prospectifs) : projections de population par commune à l'horizon 2030-2050, nécessaires pour le calcul des RSA prévisionnels.
- **DREES — Les établissements de santé** : taux nationaux de référence par CMD pour le calcul de l'écart ΔTR100k. Publication annuelle avec données territoriales agrégées.
- **ScanSanté (ATIH)** : module Territoire — accès direct aux TR100k pré-calculés par zone de santé et par CMD pour validation et benchmarking immédiat sans recalcul.

## Exemple de Valeurs

| Contexte | TR100k global MCO | Lecture |
|---|---|---|
| Zone rurale vieillissante (Creuse, Corrèze type) | 18 000–22 000 | Forte utilisation, démographie âgée, peu de substitution ambulatoire |
| Zone urbaine mixte, offre ambulatoire dense | 12 000–16 000 | Utilisation modérée, substitution médicale ville efficace |
| Zone péri-urbaine jeune (nouvelle agglomération) | 8 000–11 000 | Recours bas, population jeune, peu de pathologies chroniques |
| Zone littorale touristique | Variable, instable | Résidents saisonniers non capturés par le dénominateur INSEE |
| GHT CHU — zone d'attraction élargie | 14 000–18 000 | Recours capté par le CHU sur une zone géographiquement étendue |

**TR100k par CMD (valeurs nationales indicatives) :**
- CMD 5 (Appareil circulatoire) : 1 800–2 500 pour 100 000 hab.
- CMD 8 (Orthopédie-traumatologie) : 2 200–3 000 pour 100 000 hab.
- CMD 14 (Grossesse-accouchement) : 1 500–2 000 pour 100 000 femmes 15-49 ans
- CMD 1 (SNC) : 600–900 pour 100 000 hab.
- CMD 11 (Rein-voies urinaires) : 500–800 pour 100 000 hab.

**Coefficient de variation intra-GHT :**
- CV < 20% : homogénéité du recours dans le GHT — territoire équilibré
- CV 20-35% : disparités modérées, à analyser par CMD
- CV > 35% : hétérogénéité forte — inégalités territoriales ou desserte insuffisante

**Volume minimal recommandé :** zone d'attraction de plus de 20 000 habitants pour un TR100k global stable ; par CMD, au moins 200 séjours observés.

## Limites

- **Indicateur brut non standardisé** : le TR100k inclut l'effet de la structure démographique locale. Une zone âgée aura mécaniquement un TR100k plus élevé qu'une zone jeune, même si le recours per capita dans chaque tranche d'âge est identique. Pour neutraliser cet effet, utiliser le TRHS (`taux_recours_hospitalier_standardise_age_sexe.md`). Le TR100k et le TRHS sont complémentaires : le premier décrit l'utilisation brute, le second isole le sur/sous-recours net de la démographie.
- **Sensibilité à la définition de la zone d'attraction** : la zone ATIH (pluralité des séjours), la zone de santé ARS et le bassin de vie INSEE ne coïncident pas. Un même établissement peut afficher des TR100k différents selon la source de zone, avec des écarts de ±15-25% sur le dénominateur. Toujours documenter et figer la méthode pour les analyses longitudinales.
- **Fuites hors zone non capturées au dénominateur** : le TR100k de l'établissement ne comptabilise que les séjours que l'établissement a lui-même produits pour les résidents de sa zone. Les séjours que ces résidents ont réalisés dans d'autres établissements (fuites) ne figurent pas au numérateur — le TR100k sous-estime l'intensité de recours réelle du territoire. Pour la mesure complète du recours territorial, il faut agréger tous les établissements fréquentés par les résidents de la zone (nécessite le PMSI national, pas seulement le PMSI local).
- **Instabilité sur les petites zones** : pour des zones d'attraction de moins de 20 000 habitants, un événement épidémique ponctuel (grippe, canicule) ou l'arrivée d'un médecin spécialiste peut faire varier le TR100k de ±20% d'une année à l'autre — lisser sur 3 ans ou travailler sur 2 exercices consécutifs pour atténuer la variabilité.
- **Populations saisonnières et résidents secondaires** : dans les zones littorales ou de montagne, la population INSEE (résidents principaux) sous-estime la population réellement présente sur l'année, gonflant le TR100k apparent. Envisager une correction par le ratio résidents/visiteurs-nuit (source INSEE Tourisme) pour les zones concernées.
- **Concordance COG-PMSI après fusions communales** : depuis les fusions massives de communes (loi NOTRe, 2016–), des codes INSEE ont disparu ou ont été remplacés. Les RSA anciens (antérieurs à 2016) peuvent utiliser des codes communes périmés, créant des incohérences dans l'agrégation des populations si la table de concordance COG n'est pas appliquée systématiquement.

## Références

- [Wennberg J., Gittelsohn A. — Small area variations in health care delivery, Science 1973](https://doi.org/10.1126/science.182.4117.1102)
- [DREES — Les établissements de santé : édition annuelle — cartographie des taux de recours par zone de santé](https://drees.solidarites-sante.gouv.fr/etablissements-de-sante)
- [OCDE — Geographic Variations in Health Care: What Do We Know and What Can Be Done, OECD Health Policy Studies 2014](https://doi.org/10.1787/9789264216594-en)
- [Bras P.L., Duhamel G. — Améliorer la prise en charge des maladies chroniques : les enseignements des expériences étrangères de disease management, Rapport IGAS 2006](https://www.igas.gouv.fr/)
- [Comité des sages — Rapport sur le financement du système de santé, La Documentation Française 2023 — indicateurs de recours per capita pour la planification territoriale]
- [ATIH — Guide méthodologique PMSI MCO et ScanSanté Territoire : calcul des indicateurs de recours par zone de santé](https://www.atih.sante.fr/presentation-des-modalites-de-financement-mco-0)
- [INSEE — Omphale 2022 : projections de population 2021-2070 par département et zone d'emploi](https://www.insee.fr/fr/information/3683517)
- [Dartmouth Atlas of Health Care — méthode de construction des zones d'attraction et des taux de recours per capita (référence méthodologique internationale)](https://www.dartmouthatlas.org/)
