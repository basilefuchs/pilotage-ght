# Taux de "Failure to Rescue" (Décès après Complication Évitable)

## Définition
Le taux de "Failure to Rescue" (FTR), ou taux de décès après complication évitable, mesure la proportion de patients décédés parmi ceux ayant développé au moins une complication majeure survenue pendant leur hospitalisation. Là où le SHMI ou le taux de mortalité ajustée mesurent la mortalité globale, le FTR isole une dimension spécifique et actionnable de la qualité des soins : la **capacité de l'établissement à détecter et traiter une complication grave avant qu'elle n'entraîne le décès**. Un taux de FTR élevé ne signale pas nécessairement que l'établissement a plus de complications que les autres — il signale que, lorsqu'une complication survient, l'organisation des soins (surveillance, réponse rapide, escalade) est insuffisante pour en empêcher la progression fatale. L'indicateur a été validé sur les données PMSI françaises dans la chirurgie thoracique (Bernard et al., BMJ Open 2023) et est directement calculable depuis les RSA en croisant le mode de sortie avec les diagnostics associés de complications.

## Calcul
Le taux de FTR est calculé en deux étapes depuis les données PMSI MCO :

**Étape 1 — Identification des séjours avec complication majeure :**
```
Complication majeure = présence d'au moins un des codes CIM-10 suivants en DA,
  non présent en DP (la complication est survenue pendant le séjour, pas à l'admission) :

  Défaillances organiques :
  → J96.* : insuffisance respiratoire aiguë
  → N17.* : insuffisance rénale aiguë
  → K72.* : insuffisance hépatique aiguë
  → I21.*, I22.* : infarctus aigu du myocarde (péri-opératoire)
  → I63.* : accident vasculaire cérébral ischémique
  → G93.1 : anoxie cérébrale

  Sepsis :
  → A40.*, A41.* : sepsis (septicémie)
  → R65.2 : sepsis sévère / choc septique

  Complications chirurgicales :
  → T81.0 : hémorragie et hématome post-opératoires
  → T81.1 : choc per-opératoire et post-opératoire
  → T81.3 : déhiscence de plaie opératoire
  → T81.4 : infection post-opératoire (autre que sepsis)

  Embolie :
  → I26.* : embolie pulmonaire

  Décompensation cardiaque :
  → I50.* : insuffisance cardiaque (en DA avec séjour chirurgical)
```

**Étape 2 — Calcul du FTR :**
```
Séjours avec complication majeure (N_comp) =
  séjours MCO ayant ≥1 code complication majeure en DA

Décès parmi les patients avec complication (N_FTR) =
  séjours avec complication majeure ET mode de sortie = 9 (décès)

Taux de FTR (%) = (N_FTR / N_comp) × 100
```

**Variantes et sous-indicateurs :**
```
FTR chirurgical (%) = décès / patients avec complication post-chirurgicale
  → Restreint aux séjours avec ≥1 acte CCAM chirurgical en position principale

FTR médical (%) = décès / patients avec complication médicale (sepsis, défaillance)
  → Restreint aux séjours sans acte chirurgical principal

FTR par CMD (%) → identifie les grandes catégories diagnostiques
  où la capacité de rescue est la plus faible

FTR par gravité GHM (niveaux 3-4) → contrôle partiel du biais de sélection des cas
  (comparer établissements sur les séjours de niveau 3-4 uniquement)

Évolution temporelle du FTR → mesure l'impact des interventions organisationnelles
  (équipe de réponse rapide, protocoles de détection précoce du sepsis)
```

**Note méthodologique sur le biais présent-à-l'admission** :
Le PMSI français ne dispose pas de flag "présent à l'admission" (POA) comme les bases américaines. Pour approximer les complications survenues pendant le séjour et non à l'admission, deux stratégies complémentaires sont utilisées :
- Exclure les séjours dont le DP est l'un des codes de complication listés (le patient était déjà en défaillance à l'entrée)
- Se concentrer sur les complications chirurgicales (T81.*) qui sont par définition post-procédurales
- Croiser avec le mode d'entrée (entrées directes depuis domicile vs. transferts) pour stratifier l'analyse

## Utilité
- **Signal de qualité organisationnelle non confondable avec la sévérité du casemix** : contrairement à la mortalité brute, le FTR mesure ce qui se passe *après* l'apparition d'une complication — deux établissements peuvent avoir la même prévalence de complications post-opératoires mais des FTR très différents selon l'efficacité de leur surveillance et de leur escalade thérapeutique.
- **Évaluation des équipes mobiles de réponse rapide (EMRR)** : les établissements ayant déployé une équipe de réponse rapide (Rapid Response Team) observent une réduction significative du FTR — l'indicateur quantifie l'impact de cette organisation et justifie son déploiement sur les unités à risque.
- **Benchmarking inter-établissements au sein du GHT** : comparer le FTR chirurgical entre les sites du GHT en ajustant sur la sévérité GHM pour identifier les établissements dont l'organisation post-opératoire mérite un audit de pratiques.
- **Différenciation des axes d'amélioration** : un établissement avec FTR élevé mais taux de complication dans la norme nationale a un problème de surveillance/réponse — il doit renforcer ses protocoles de détection et d'escalade plutôt que ses pratiques chirurgicales.
- **Validation française** : Bernard et al. (BMJ Open 2023) ont démontré sur 157 566 résections pulmonaires pour cancer en France (PMSI 2005-2020) que le FTR est passé de 12,2 % à 7,1 % en 15 ans, corrélé à la montée de la chirurgie mini-invasive et à l'augmentation des volumes par centre — résultats directement transposables comme valeurs de référence.
- **Complémentarité avec le PSI-90** : le PSI-90 cible la prévention des complications (ne pas les créer), le FTR cible le rescue (ne pas laisser mourir un patient qui a compliqué) — les deux indicateurs ensemble couvrent l'ensemble du cycle sécurité/qualité chirurgicale.

## Sources de Données
- **PMSI MCO** : fichiers RSA, croisement des diagnostics associés (DA) et du mode de sortie (décès = code 9) — calcul réalisable directement par le DIM sans accès au SNDS.
- **ScanSanté** : accès aux modes de sortie agrégés par GHM et établissement — base de calcul du numérateur (décès) et du dénominateur (séjours avec complications codées en DA).
- **Groupes de pairs ATIH** : comparaison inter-établissements de même catégorie (CHU, CHG, clinique MCO) pour un benchmarking équitable du FTR ajusté sur le casemix.

## Exemple de Valeurs
- **FTR chirurgical global** : 5-15 % dans les établissements de chirurgie générale, selon la complexité des cas et l'organisation post-opératoire.
- **Chirurgie thoracique pour cancer (France, PMSI)** : FTR de 7,1 % en 2020 vs 12,2 % en 2005 — baisse de 42 % en 15 ans liée à la vidéo-thoracoscopie et à la concentration des volumes (Bernard et al., BMJ Open 2023).
- **Chirurgie digestive majeure (œsophagectomie, pancréatectomie)** : FTR de 15-25 % dans les centres à faible volume, 5-10 % dans les centres à fort volume (relation volume-FTR bien établie).
- **Sepsis** : FTR sepsis (décès parmi les patients avec sepsis codé en DA hors DP) : 15-30 % selon la précocité du codage et la sévérité des cas.
- **Objectif cible** : un programme d'équipe de réponse rapide bien implémenté réduit le FTR de 20-40 % sur 2-3 ans dans les études de référence (NHS, Australie).

## Limites
- L'absence de flag "présent à l'admission" (POA) dans le PMSI français empêche de distinguer avec certitude les complications survenues pendant le séjour de celles préexistantes — le risque de surestimation du FTR existe pour les établissements qui reçoivent beaucoup de patients en défaillance à l'entrée (CHU de recours, SAMU-centre).
- Le FTR est sensible à la qualité du codage : un établissement qui code exhaustivement toutes les complications en DA paraîtra avoir un numérateur (complications) plus élevé, diluant mécaniquement le FTR — deux établissements avec des pratiques de codage différentes ne sont pas directement comparables.
- La liste des codes définissant une "complication majeure" n'est pas standardisée en France comme elle l'est dans le système AHRQ américain (PSI 04) — la définition de la liste de codes est un choix méthodologique qui doit être documenté et maintenu constant pour le suivi longitudinal.
- Le FTR ne mesure pas la qualité des soins palliatifs : un décès attendu et accompagné en soins palliatifs après une complication documentée sera comptabilisé comme FTR si le mode de sortie est le décès — il convient d'exclure les séjours avec codage de soins palliatifs (Z51.5) du dénominateur.

## Références
- [Bernard A. et al. — Mortality and failure-to-rescue after lung cancer surgery in France, PMSI 2005-2020, BMJ Open 2023](https://doi.org/10.1136/bmjopen-2023-075463)
- [Blike G.T. et al. — A pragmatic method for measuring inpatient complications and FTR, J Patient Safety 2022](https://doi.org/10.1097/PTS.0000000000000984)
- [Hickner B.T. et al. — Complication timing, FTR, and readmission after pediatric surgery, J Surg Res 2024](https://doi.org/10.1016/j.jss.2024.07.052)
- [ATIH - PMSI MCO : modes de sortie et diagnostics associés](https://www.atih.sante.fr/)
- [HAS - Indicateurs de qualité et sécurité des soins en chirurgie](https://www.has-sante.fr/)
