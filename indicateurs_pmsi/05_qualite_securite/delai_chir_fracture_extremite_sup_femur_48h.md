# Délai de Chirurgie ≤ 48h après Fracture de l'Extrémité Supérieure du Fémur (≥ 65 ans)

## Définition
Le **délai d'initiation de la chirurgie après fracture de l'extrémité supérieure du fémur** chez les patients âgés mesure la part des patients de **65 ans et plus** admis en urgence pour fracture du col fémoral ou de la région trochantérienne, opérés dans les **2 jours calendaires (48 heures)** suivant l'admission. Il s'agit d'un **indicateur OCDE HCQO acute care** standardisé, recommandé pour la comparaison internationale et aligné sur les guidelines cliniques (NICE, AAOS, SOFCOT, BOAST) qui préconisent une chirurgie précoce pour réduire mortalité, complications et perte d'autonomie.

Formule :

```
Taux ChirHanche_48h = (RSA fracture haut fémur, ≥65 ans, urgent,
                       avec acte CCAM ostéosynthèse / arthroplastie
                       réalisé ≤ J+2 après admission)
                      / (RSA fracture haut fémur, ≥65 ans, urgent, opérés
                         dans le même hôpital)
                      × 100
```

Positionnement vs indicateurs existants : différent du `delai_porte_aiguille_avc.md` (AVC fibrinolyse). Cet indicateur cible la chirurgie orthopédique gériatrique en urgence, marqueur clé de la coordination filière urgences–ortho–anesthésie–gériatrie.

## Calcul

```
Étape 1 — Population cible (dénominateur)
  RSA avec :
    a) Âge à l'admission ≥ 65 ans
    b) DP CIM-10 dans l'ensemble :
         S72.0  Fracture du col du fémur
         S72.1  Fracture pertrochantérienne
         S72.2  Fracture sous-trochantérienne
         (S72.3, S72.4 — diaphyse, exclues car non « extrémité supérieure »)
    c) Mode d'entrée = 8 (urgences) OU 6/7 transfert pour cause urgente
       (exclusion des admissions programmées : refixation programmée, etc.)
    d) Acte CCAM chirurgical réalisé dans le séjour, dans la liste :
         NZCA001/002/003/004  Ostéosynthèse de l'extrémité supérieure du fémur
         NEKA00x              Arthroplastie totale ou partielle de hanche pour fracture
         NEMA00x              Prothèse fémorale
         NZMA00x              Vissage du col

Étape 2 — Détection du délai
  Pour chaque RSA cible :
    Délai = DATE_REALISATION_ACTE - DATE_ENTREE_SEJOUR (en jours)
    Inclus si Délai ≤ 2 (i.e. réalisé J0, J1 ou J2)

Étape 3 — Calcul
  N = RSA cibles avec chirurgie ≤ 48h
  D = RSA cibles total
  Taux = N / D × 100

Étape 4 — Stratifications
  - Par classe d'âge (65-74, 75-84, ≥85)
  - Par jour d'admission (lundi-jeudi vs vendredi-dimanche : effet weekend)
  - Par établissement / GHT
  - Par type de fracture (col vs trochantérienne)

Étape 5 — Exclusions OCDE recommandées
  - Patients sous anticoagulants nécessitant fenêtre de réversion (info parfois indisponible)
  - Décès avant chirurgie
  - Transferts sortants pour chirurgie ailleurs (méthodologie OCDE :
    « operated in the same hospital »)
  - Polytraumatisés (autres atteintes interférant avec la priorité chirurgicale)
```

Variables PMSI clés : `DP`, `AGE_ANNEES`, `MODE_ENTREE`, `DATE_ENTREE`, `DATE_REALISATION_ACTE` (date de réalisation de l'acte CCAM, présente dans les RSA récents), codes `CCAM`, `MODE_SORTIE`.

## Utilité
- **Pilotage filière urgences–ortho–gériatrie GHT** : indicateur synthétique de la coordination des trois disciplines pour le « parcours fracture du col » (filière thématique de référence).
- **Comparaison internationale** : positionnement direct sur les benchmarks OCDE (UE, OCDE, pays nordiques pionniers).
- **Levier mortalité gériatrique** : la chirurgie ≤ 48h réduit significativement la mortalité à 30 jours (méta-analyses : OR ~0,7-0,8) → couplage recommandé avec mortalité 30j post-fracture.
- **Suivi du Plan personnes âgées** : composante implicite des dispositifs de filière courte personnes âgées (UPOG, UCOG).
- **Détection effet weekend** : analyse stratifiée jour d'admission révèle souvent un creux fin de semaine, levier organisationnel (programme bloc samedi).
- **Justification de moyens** : argumentaire pour ouverture de plages bloc dédiées orthogériatrie.
- **Indicateur GHT mutualisation** : un GHT avec maillage ortho concentré sur l'établissement pivot doit garantir le délai pour les patients adressés par les CH périphériques.

## Sources de Données
- **PMSI MCO** : RSA, DP, âge, MODE_ENTREE, dates d'entrée et de réalisation des actes CCAM.
- **Référentiel CIM-10 FR** : codes S72.0, S72.1, S72.2.
- **Référentiel CCAM** (mise à jour annuelle ATIH) : actes d'ostéosynthèse et d'arthroplastie de hanche.
- **OCDE — HCQO Definitions** : spécifications standardisées (numérateur, dénominateur, exclusions).
- **OCDE Health at a Glance** : benchmark international annuel.
- **OECD.Stat** : restitutions par pays et par année.

## Exemple de Valeurs
*Sources : OCDE Health at a Glance 2023 et 2025, méthodologie HCQO 2022.*

- **Moyenne OCDE** : ~80 % des patients ≥65 ans opérés ≤ 48h.
- **France** : ~75-82 % selon les années (proche moyenne OCDE).
- **Pays-Bas, Suède, Danemark** : > 90 % (organisation filière forte).
- **Pays sud-européens** : 65-75 %.
- **Plage par établissement France** : 60 % – 95 %.
- **Cible OCDE / NICE** : > 90 % en chirurgie ≤ 48h, idéalement > 95 % en chirurgie ≤ 36h.
- **Effet weekend** : différentiel parfois 10-15 pts entre admissions semaine et fin de semaine.
- **Volume cible minimal** : ≥ 50 fractures haut fémur ≥65 ans/an pour stabilité (CHU > 200, CH périphériques 50-150).

## Limites
- **Datation des actes** : la date de réalisation de l'acte CCAM doit être renseignée dans le RSA ; les versions anciennes ou un sous-codage peuvent rendre le délai imprécis.
- **Définition « urgent »** : la distinction MODE_ENTREE = 8 vs admission programmée n'est pas toujours fiable, certains patients reclassés.
- **Exclusion des transferts** : la méthodologie OCDE exclut les patients transférés vers un autre établissement pour chirurgie, ce qui peut sous-estimer la performance des CH non-chirurgicaux qui adressent rapidement.
- **Anticoagulation** : info absente du PMSI ; certains délais > 48h sont médicalement justifiés (réversion AOD), non distinguables.
- **Bornes calendaires** : J0 = admission, J+2 = 48h calendaires ; un patient admis vendredi soir et opéré lundi matin est à 60h mais codé J+3 → faux négatif.
- **Polytraumatologie** : exclusions OCDE difficiles à appliquer sans variables cliniques détaillées.
- **Distinction col vs trochanterienne** : les recommandations chirurgicales différent (PIH vs ostéosynthèse) ; mix d'établissement à analyser séparément.
- **Volume minimal** : pour CH < 50 cas/an, IC 95% large ; pondération par lourdeur résiduelle non capturée.

## Références
- [OCDE — Health at a Glance 2025](https://www.oecd.org/en/publications/health-at-a-glance-2025_8f9e3f98-en.html)
- [OCDE — HCQO Definitions (méthodologie 2022)](https://www.oecd.org/content/dam/oecd/en/topics/policy-sub-issues/measuring-health-care-quality/definitions-of-health-care-quality-outcomes.pdf)
- [OCDE — Healthcare Quality and Outcomes Indicators](http://www.oecd.org/health/health-care-quality-outcomes-indicators.htm)
- [OCDE — Health at a Glance 2023](https://www.oecd.org/en/publications/2023/11/health-at-a-glance-2023_e04f8239/full-report.html)
- NICE Guideline CG124 — *Hip fracture: management*.
- SOFCOT — Recommandations de bonne pratique fracture extrémité supérieure du fémur du sujet âgé.
- Klestil T, et al. Impact of timing of surgery in elderly hip fracture patients: a systematic review and meta-analysis. *Sci Rep*. 2018;8:13933.
