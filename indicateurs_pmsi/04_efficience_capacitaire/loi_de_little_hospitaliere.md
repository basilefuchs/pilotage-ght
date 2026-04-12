# Loi de Little Hospitalière

## Définition

La loi de Little (John D.C. Little, 1961) est un résultat fondamental de la théorie des files d'attente, démontré pour tout système stable quelle que soit la distribution des temps d'arrivée ou de service :

**L = λ × W**

où L est le nombre moyen d'éléments présents dans le système, λ le débit moyen d'entrée dans le système, et W le temps moyen passé dans le système. Cette loi est universelle : elle s'applique à n'importe quel "système" stable — une usine, un réseau informatique, une file de caisse — sans hypothèse sur la distribution des durées ni sur la forme du service.

Appliquée à une unité hospitalière, la loi de Little établit une relation invariante entre trois quantités mesurables depuis le PMSI :

**Lits_occupés_moyens = Taux_admissions_journalier × DMS**

En régime stable, si l'on connaît deux de ces trois quantités, la troisième est déterminée. La puissance de la loi de Little en milieu hospitalier réside dans sa capacité à **détecter les anomalies invisibles** : toute violation de cette relation triangulaire — c'est-à-dire tout écart significatif entre la valeur observée d'une des trois grandeurs et la valeur prédite par les deux autres — révèle une perturbation cachée que les indicateurs classiques ne détectent pas isolément.

Un service avec une DMS stable et un taux d'admission stable devrait avoir une occupation stable : si l'occupation réelle s'envole malgré des admissions constantes, il y a nécessairement un problème de flux de sorties (bed-blocking, manque d'aval, blocage administratif). La loi de Little rend ce problème visible et quantifiable, avant même d'en connaître la cause.

## Calcul

Mesure des trois composantes sur une fenêtre temporelle T (semaine, mois) :

```
λ (taux d'admissions) :
  λ = Nombre total d'admissions MCO sur la période T / T (en jours)
  → Unité : admissions/jour
  → Source : PMSI RSA, variable DATE_ENT, agrégé par unité (UM ou service)

W (durée moyenne de séjour) :
  W = Σᵢ (DATE_SOR_i − DATE_ENT_i) / N_séjours
  → DMS observée en jours sur la période T
  → Source : PMSI RSA, variables DATE_ENT et DATE_SOR

L_prédit (occupation théorique selon Little) :
  L_prédit = λ × W
  → Nombre moyen de lits occupés prédit par la loi de Little
  → Unité : lits (nombre moyen sur la période)

L_observé (occupation réelle) :
  L_observé = Σⱼ (Journées d'hospitalisation réalisées le jour j) / T
  → Calculé depuis le PMSI (journées valorisées) ou les données de gestion
```

Indice de violation de la loi de Little (IVLL) :

```
IVLL = (L_observé − L_prédit) / L_prédit × 100   (en %)

  IVLL ≈ 0 %   : système en régime stable, cohérence interne parfaite
  IVLL > +10 % : L_observé > L_prédit → lits occupés au-delà de ce que
                 justifient les admissions et la DMS déclarée
                 → Causes possibles : bed-blocking (sorties retardées),
                   DMS déclarée sous-estimée, séjours non clos administrativement,
                   patients "fantômes" (présents physiquement mais non saisis)
  IVLL < −10 % : L_observé < L_prédit → occupation moindre que prédit
                 → Causes possibles : lits fermés non déclarés, transferts
                   précoces non saisis, biais de codage des dates de sortie
```

Décomposition diagnostique par composante :

```
En cas de violation (IVLL significatif), identifier quelle composante dévie :

Test 1 — La DMS est-elle cohérente avec l'occupation et le flux ?
  W_implicite = L_observé / λ
  Si W_implicite ≫ W_déclarée : les patients restent en réalité plus longtemps
    que la DMS PMSI (sorties tardives, prolongations non codées)

Test 2 — Le flux d'entrée est-il cohérent avec l'occupation et la DMS ?
  λ_implicite = L_observé / W
  Si λ_implicite ≫ λ_observé : il y a des entrées non comptabilisées
    (mutations internes non tracées, patients admis sans RSA saisi)

Test 3 — L'occupation est-elle cohérente avec entrées et DMS ?
  L_prédit = λ × W — vérification directe par la formule

Suivi temporel de l'IVLL :
  → Calculer l'IVLL semaine par semaine sur 12 mois glissants
  → IVLL chroniquement positif = bed-blocking structurel
  → IVLL positif lors d'un choc puis retour à 0 = perturbation absorbée
  → IVLL progressivement croissant = dégradation progressive du flux de sortie
```

Taux d'utilisation de Little (TUL) :

```
TUL = L_observé / Capacité_installée (nombre de lits ouverts)
  → TUL = taux d'occupation exprimé via la loi de Little
  → En régime stable : TUL = λ × W / C
  → Permet de calculer la DMS maximale tolérable avant saturation :
    W_max = (TUL_cible × C) / λ
    → Ex. : avec C = 30 lits, λ = 3 admissions/jour, TUL_cible = 85% :
      W_max = (0.85 × 30) / 3 = 8.5 jours — toute DMS > 8.5j sature le service
```

## Utilité

- **Détecter le bed-blocking et les goulots d'étranglement aval** : un IVLL chroniquement positif signale que les patients restent dans les lits plus longtemps que la DMS déclarée ne le justifie — révèle un problème de flux de sorties (manque de places SSR, absence d'infirmière de liaison, sorties retardées le week-end) avant même que les soignants ne l'aient formalisé
- **Contrôle de cohérence des données PMSI** : la loi de Little est une contrainte mathématique que toute base de données hospitalière devrait satisfaire en régime stable — un IVLL élevé peut signaler des anomalies de codage (dates de sortie erronées, séjours non clos) avant la transmission à l'ATIH, réduisant le risque de valorisation incorrecte
- **Calcul de la DMS maximale tolérable avant saturation** : en inversant la formule (W_max = TUL_cible × C / λ), le gestionnaire dispose d'un objectif de DMS directement dérivé de la capacité installée et du flux entrant — objectif plus pertinent que la moyenne nationale car calculé sur le profil de flux réel du service
- **Pilotage de la capacité en temps quasi-réel** : mis à jour chaque semaine, l'IVLL est un signal précoce de déséquilibre avant que le taux d'occupation n'atteigne un niveau critique — permet une action préventive (ouverture de lits supplémentaires, négociation de places SSR, renforcement des sorties organisées) plutôt que réactive
- **Comparaison inter-unités du GHT** : deux unités avec la même DMS et le même taux d'occupation mais des IVLL différents n'ont pas le même profil de flux — l'unité avec IVLL > 0 a un problème de flux de sortie, l'unité avec IVLL < 0 a peut-être des lits fermés non déclarés ou une sous-activité cachée
- **Mesure de l'impact des actions d'amélioration du flux aval** : si l'ouverture de places SSR ou la création d'une équipe mobile de sortie réduit la DMS effective, l'IVLL doit se rapprocher de 0 — indicateur de résultat quantitatif des actions de gestion des lits

## Sources de Données

- **PMSI MCO RSA** : DATE_ENT et DATE_SOR pour le calcul de la DMS (W) et du flux d'admissions (λ), par unité médicale (UM) ou service — base principale
- **Données de gestion interne** : capacité installée (nombre de lits ouverts par période, C), journées réelles (pour L_observé indépendant du PMSI) — permet de vérifier la cohérence PMSI/gestion
- **PMSI SSR, HAD** : pour analyser la loi de Little sur les filières aval et comprendre si un IVLL MCO positif est causé par une saturation SSR (λ_SSR insuffisant pour absorber les sorties MCO)
- **Tableau de bord de gestion des lits** (ICOS, Orbis Bed Management, TrakCare) : si disponible, données en temps réel du nombre de patients présents — permet un IVLL calculé quotidiennement plutôt que sur données PMSI avec lag

## Exemple de Valeurs

- **Service de médecine interne en régime normal** :
  λ = 2,5 admissions/jour, W = 7 jours → L_prédit = 17,5 lits occupés
  L_observé = 18,2 lits → IVLL = +4 % (cohérence acceptable, légère sur-occupation résiduelle)

- **Service de chirurgie orthopédique en tension aval (manque de places SSR)** :
  λ = 1,8 admissions/jour, W_déclarée = 5,5 jours → L_prédit = 9,9 lits
  L_observé = 13,5 lits → IVLL = +36 % — les patients restent en réalité
  W_implicite = 13,5 / 1,8 = 7,5 jours au lieu des 5,5 jours déclarés
  → 2 jours de bed-blocking par séjour en moyenne, non visibles dans la DMS seule

- **DMS maximale tolérable** (exemple) :
  Service de 25 lits, λ = 3 entrées/jour, TUL cible = 85% :
  W_max = (0,85 × 25) / 3 = 7,1 jours — toute DMS > 7 jours mène à la saturation

- **IVLL lors d'une vague grippale** : pic à +25-40 % pendant 3-5 semaines, retour à 0-5 % en 4-8 semaines selon la résilience du service (cohérent avec l'IRO)

## Limites

- La loi de Little s'applique strictement aux **systèmes en régime stable** — elle est mise en défaut lors des transitions brutales (ouverture/fermeture de lits, pandémie, grève) où le système n'est pas encore à l'équilibre ; l'IVLL doit être interprété avec précaution pendant les phases transitoires
- Le calcul requiert une **granularité temporelle adaptée** : calculé sur une journée, l'IVLL fluctue naturellement (arrivées concentrées le matin, sorties le soir) ; la semaine est l'unité minimale recommandée, le mois donne une vision plus robuste mais moins réactive
- La définition de l'unité d'analyse (UM, service, pôle, établissement) modifie les résultats : une violation observée au niveau du service peut disparaître au niveau du pôle si les flux se compensent entre unités — l'analyse multi-échelle est recommandée
- Les **transferts intra-hospitaliers** (mutation d'une UM à une autre sans sortie administrative) créent des artefacts dans le calcul de λ et W au niveau de l'unité — les séjours fractionnés en plusieurs UM doivent être reconstitués en séjour unique pour un calcul correct de la DMS réelle

## Références

- [Little J.D.C. — A proof for the queuing formula L = λW, Operations Research 1961](https://doi.org/10.1287/opre.9.3.383) — démonstration originale, article de 3 pages
- [Hopp W.J., Spearman M.L. — Factory Physics, McGraw-Hill 2001 : application industrielle de la loi de Little aux systèmes de production]
- [Fieldston E.S. et al. — Application of Little's law to measure census variability in a pediatric hospital, Pediatrics 2010](https://doi.org/10.1542/peds.2009-2093) — première application hospitalière pédiatrique
- [Litvak E., Bisognano M. — More patients, less payment: increasing hospital efficiency in the aftermath of health reform, Health Affairs 2011](https://doi.org/10.1377/hlthaff.2011.0073)
- [ANAP — Gestion des lits et flux de patients : outils et méthodes (2013)](https://www.anap.fr/)
- [Erlang A.K. — The theory of probabilities and telephone conversations, Nyt Tidsskrift for Matematik 1909 : fondements de la théorie des files d'attente dont dérive la loi de Little]
