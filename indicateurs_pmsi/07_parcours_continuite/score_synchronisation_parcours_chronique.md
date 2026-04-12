# Score de Synchronisation du Parcours Chronique

## Définition

Pour un patient porteur de plusieurs affections de longue durée (ALD) simultanées, le score de synchronisation mesure dans quelle mesure ses différents actes de soins — consultations spécialisées, dispensations médicamenteuses, bilans biologiques — se déroulent de façon **régulière et temporellement cohérente**, ou au contraire de façon **désynchronisée et anarchique**.

Inspiré du concept de synchronisation en physique des systèmes couplés (Kuramoto, 1975) — où des oscillateurs indépendants finissent par se synchroniser lorsqu'ils sont couplés — le parcours idéal d'un patient chronique est une série d'actes régulièrement espacés et coordonnés (consultation cardiologie J0, bilan biologique J+7, ajustement traitement J+14, consultation médecin traitant J+30…). Un parcours désynchronisé est une série d'actes dispersés aléatoirement dans le temps, sans coordination apparente entre les différentes prises en charge.

Le score est calculé depuis le DCIR (ER_PRS_F, ER_PHA_F, ER_BIO_F) en analysant la régularité temporelle des intervalles entre actes consécutifs par type de soins. Un score proche de 1 indique un parcours régulier et synchronisé (coordination effective) ; un score proche de 0 indique une désynchronisation totale (soins chaotiques, probablement non coordonnés).

La désynchronisation chronique est associée à une augmentation du risque d'omissions de soins (intervalles trop longs entre prises en charge), de chevauchements iatrogènes (consultations multiples en peu de temps générant des prescriptions contradictoires), et de décompensation aiguë (rupture d'un acte régulier = rupture de suivi).

## Calcul

Construction de la séquence temporelle par type d'acte :

```
Pour chaque patient ALD (NIR) sur 12 mois, et pour chaque type d'acte :

Type 1 — Consultations spécialisées (ER_PRS_F) :
  Séquence C = {t₁, t₂, …, tₙ} dates des consultations par spécialité
  Intervalles IC = {t₂−t₁, t₃−t₂, …, tₙ−tₙ₋₁} en jours

Type 2 — Dispensations médicamenteuses (ER_PHA_F) :
  Séquence M = {t₁, t₂, …, tₘ} dates de dispensation par molécule ATC
  Intervalles IM = intervalles entre dispensations consécutives

Type 3 — Actes de biologie (ER_BIO_F) :
  Séquence B = {t₁, t₂, …, tₖ} dates des bilans biologiques clés
  Intervalles IB = intervalles entre bilans consécutifs
```

Score de régularité par type d'acte :

```
Coefficient de variation (CV) des intervalles :
  CV_C = σ(IC) / μ(IC)   (consultations)
  CV_M = σ(IM) / μ(IM)   (médicaments)
  CV_B = σ(IB) / μ(IB)   (biologie)

  CV proche de 0 = intervalles très réguliers (actes programmés à intervalles fixes)
  CV > 1 = intervalles très irréguliers (actes dispersés aléatoirement)

Score de synchronisation par type d'acte :
  S_C = 1 / (1 + CV_C)   ∈ [0 ; 1]
  S_M = 1 / (1 + CV_M)
  S_B = 1 / (1 + CV_B)
```

Score de synchronisation composite :

```
SSP (Score de Synchronisation du Parcours) =
  w_C × S_C + w_M × S_M + w_B × S_B

  Pondérations par défaut (adaptables par pathologie) :
    w_C = 0.4 (consultations = actes de coordination les plus importants)
    w_M = 0.4 (dispensations = proxy de l'observance thérapeutique continue)
    w_B = 0.2 (biologie = suivi périodique, moins fréquent)
    Σ wi = 1

  SSP ∈ [0 ; 1]
  SSP > 0.7 : parcours bien synchronisé (suivi régulier et coordonné)
  SSP 0.4-0.7 : synchronisation partielle (irrégularités modérées)
  SSP < 0.4 : parcours désynchronisé (soins chaotiques)
```

Indicateur de co-synchronisation multi-ALD :

```
Pour les patients avec ≥ 2 ALD actives, mesurer si les actes relatifs
à chaque ALD sont temporellement cohérents entre eux :

Délai moyen de co-occurrence : pour deux ALD A et B,
  d_AB = médiane |t_acte_A − t_acte_B_le_plus_proche|

Un d_AB faible (< 7j) indique que les soins des deux ALD sont
"regroupés" (coordination probable) ;
un d_AB élevé (> 60j) indique deux filières de soins entièrement séparées.
```

## Utilité

- **Identifier les patients ALD à parcours chaotique** nécessitant une intervention de coordination ciblée (case manager, infirmière de parcours) : les patients avec SSP < 0,4 ont des soins distribués de façon anarchique, indépendamment du nombre de professionnels consultés — ils ne sont pas mieux suivis par l'IFP seul qui ne capture pas la temporalité
- **Distinguer la désynchronisation médicamenteuse** (ruptures de renouvellement d'ordonnance, dispensations irrégulières) de la désynchronisation clinique (consultations imprévisibles) — les deux types nécessitent des interventions différentes (pharmacien coordinateur vs infirmière de liaison)
- **Mesurer l'impact des programmes de suivi structuré** : un protocole de suivi SOPHIA (programme CNAM pour les diabétiques) ou un télésuivi insuffisance cardiaque devrait augmenter le SSP des patients inclus — indicateur d'évaluation de ces programmes depuis les données SNDS
- **Corrélation avec le risque d'hospitalisation** : les études sur l'observance médicamenteuse montrent qu'un PDC < 80% (dispensations trop irrégulières = S_M faible) est un prédicteur fort de décompensation — le SSP généralise ce concept à l'ensemble du parcours
- **Outil de priorisation des interventions de coordination** : classer les patients ALD par SSP croissant pour identifier les patients qui bénéficieraient le plus d'une action de coordination, avant même qu'un événement de décompensation ne survienne

## Sources de Données

- **DCIR ER_PRS_F** : dates des consultations spécialisées par RPPS et spécialité, NIR — pour S_C
- **DCIR ER_PHA_F** : dates de dispensation des médicaments par code ATC et CIP13, NIR — pour S_M
- **DCIR ER_BIO_F** : dates des actes de biologie clés (HbA1c pour diabète, BNP pour IC, INR pour AVK, créatinine pour IRC) par code BHN, NIR — pour S_B
- **IR_IMB_R** : ALD actives par NIR — pour identifier les patients concernés et adapter les pondérations w_i selon le profil multi-ALD
- **Référentiels de rythme attendu par ALD** (HAS recommandations de suivi) : rythme théorique des consultations et bilans pour chaque ALD — permet de définir CV_attendu pour chaque type d'acte et de calculer un écart au référentiel (score ajusté aux recommandations plutôt qu'au seul rythme observé)

## Exemple de Valeurs

- **Patient diabétique type 2 bien suivi** : consultation diabétologue tous les 3 mois (CV_C = 0,15), dispensation metformine mensuelle (CV_M = 0,10), HbA1c semestrielle (CV_B = 0,20) → S_C = 0,87, S_M = 0,91, S_B = 0,83 → **SSP = 0,88** (excellent)
- **Patient insuffisance cardiaque mal suivi** : consultations cardiologue à J0, J+25, J+120, J+340 (CV_C = 0,85), dispensations furosémide irrégulières (CV_M = 0,60), BNP rarement contrôlé (CV_B = 1,20) → S_C = 0,54, S_M = 0,63, S_B = 0,45 → **SSP = 0,55** (synchronisation partielle, intervention recommandée)
- **Patient polypathologique désynchronisé** : soins multiples mais anarchiques, passage aux urgences × 3 dans l'année → SSP < 0,30 (désynchronisation sévère)
- **Distribution attendue du SSP dans une cohorte ALD** : P25 ≈ 0,40 ; P50 ≈ 0,58 ; P75 ≈ 0,72

## Limites

- Le score ne distingue pas une désynchronisation subie (patient qui n'a pas pu obtenir un rendez-vous) d'une désynchronisation choisie (patient qui ne souhaite pas de suivi régulier) — les deux génèrent le même SSP faible mais nécessitent des interventions différentes
- Le coefficient de variation est instable pour les patients avec peu d'actes (< 3 consultations par type sur 12 mois) — le SSP doit être calculé uniquement pour les patients avec au moins 3 observations par type d'acte ; en dessous, utiliser simplement l'existence ou l'absence d'acte
- Les recommandations de suivi des ALD (rythme théorique) ne sont pas intégrées dans la formule de base — un patient vu tous les 6 mois régulièrement aura un SSP élevé même si les recommandations préconisent un suivi trimestriel ; une version "SSP ajusté aux recommandations" nécessite de paramétrer le rythme attendu par ALD
- Le DCIR a un lag de 6-12 mois selon les flux — les analyses de synchronisation sur l'année N ne peuvent être réalisées qu'en milieu de l'année N+1 au plus tôt

## Références

- [Kuramoto Y. — Self-entrainment of a population of coupled non-linear oscillators, Lecture Notes in Physics 1975 : modèle mathématique de synchronisation dans les systèmes couplés]
- [Peasah S.K. et al. — Medicare Part D medication adherence, Am J Manag Care 2022 : PDC et risque d'hospitalisation](https://doi.org/10.37765/ajmc.2022.89116)
- [Pham Nguyen T.P. et al. — Effect of medication adherence on healthcare resource utilization, PLoS One 2020](https://doi.org/10.1371/journal.pone.0234543)
- [CNAM — Programme Sophia : évaluation de l'impact sur le suivi des patients diabétiques, rapport 2021](https://www.ameli.fr/)
- [HAS — Recommandations de suivi pour les principales ALD : rythme des consultations, bilans biologiques et traitements](https://www.has-sante.fr/)
