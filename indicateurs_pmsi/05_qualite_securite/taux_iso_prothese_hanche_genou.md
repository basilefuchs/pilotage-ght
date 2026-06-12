# Taux d'Infection du Site Opératoire après Pose de Prothèse Totale de Hanche ou de Genou (ISO-ORTHO)

## Définition
L'indicateur **ISO-ORTHO** mesure la proportion de patients développant une infection du site opératoire (ISO) dans les **90 jours** (3 mois) suivant la pose d'une prothèse totale de hanche (PTH) ou de genou (PTG). Développé par la HAS à partir des données médico-administratives du PMSI MCO en 2017 et validé séparément pour PTH et PTG en 2020, il s'agit d'un **indicateur de résultat** entièrement calculable à partir du PMSI (puis SNDS depuis 2024-2026 pour le suivi extra-hospitalier des réadmissions). Il est intégré au dispositif IFAQ (incitation financière à l'amélioration de la qualité), diffusé publiquement dans QualHAS, et calculé séparément pour PTH (hors fracture) et PTG.

Formule générale :

```
Taux ISO-ORTHO_brut = (séjours index PTH ou PTG suivis d'une réadmission pour ISO ≤ 90j)
                      / (séjours index PTH ou PTG dans la population cible)

Taux ISO-ORTHO_ajusté = standardisation indirecte par âge, sexe, comorbidités (Charlson),
                         mode d'admission, type d'établissement
```

Positionnement vs indicateurs existants : contrairement au PSI (AHRQ) qui détecte des complications intra-séjour, ISO-ORTHO repose sur un **chaînage inter-séjours** (PTH/PTG index → réadmission ≤ 90j) et capture donc les infections diagnostiquées après la sortie initiale, ce qui est essentiel pour les ISO sur prothèse dont le délai médian de diagnostic dépasse souvent la durée du séjour index.

## Calcul

```
Étape 1 — Identification du séjour index (population cible)
  PTH : RSA avec acte CCAM NEKA01x (arthroplastie totale de hanche, hors fracture)
        Exclusions : DP fracture col fémoral (S72.0x), patient à très haut risque
                     (immunodépression sévère, infection préexistante)
  PTG : RSA avec acte CCAM NFKA006/007/008 (arthroplastie totale de genou)
        Exclusions : reprise de prothèse, infection préexistante

Étape 2 — Détection ISO ≤ 90 jours
  Recherche d'un séjour ultérieur du même patient (chaînage par n°anonyme PMSI/SNDS)
  dans les 90 jours suivant la sortie du séjour index, présentant :
    - DP/DR/DA : T84.5 (infection prothèse articulaire interne)
                 OU T81.4 (infection après acte non classée ailleurs avec contexte ortho)
                 OU M00.x (arthrite pyogène) avec acte CCAM de reprise
    - OU acte CCAM de reprise pour sepsis (NEKA / NFKA codes de reprise septique)

Étape 3 — Numérateur / Dénominateur
  N = patients de la cohorte index avec ISO détectée ≤ 90j
  D = effectif de la cohorte index
  Taux brut = N / D

Étape 4 — Ajustement
  Standardisation indirecte (modèle logistique HAS) sur :
    - Âge (classes 5 ans), sexe
    - Score de Charlson (à partir des DA du séjour index + antériorité 1 an)
    - Mode d'entrée, durée de séjour index, IMC si disponible
  Restitution : ratio standardisé (observé / attendu) avec IC 95%
```

Variables PMSI clés : `ident`, `N°ANONYME` (chaînage), `DATE_SORTIE`, `DATE_ENTREE`, `DP`, `DR`, `DA`, codes `CCAM` (table A), `age`, `SEXE`.

## Utilité
- **Pilotage qualité chirurgie orthopédique GHT** : positionnement comparatif des établissements pratiquant la PTH/PTG, identification des centres en alerte (IC 95% au-dessus de la moyenne nationale).
- **Justification IFAQ** : composante du score IFAQ depuis 2024 ; impact financier direct sur la dotation qualité.
- **Suivi du programme bloc** : mise en évidence de l'effet de la check-list HAS, de l'antibioprophylaxie, du flux laminaire, de la décolonisation préopératoire.
- **Décision de mutualisation GHT** : seuils minimaux d'activité (>50 PTH/an préconisés) parfois atteints uniquement par concentration sur l'établissement pivot.
- **Information patient** : diffusion publique sur QualHAS / Scope Santé influence le recours.
- **Comparaison internationale** : l'ISO-PTH/PTG est suivi par l'OCDE (Health at a Glance), et la méthodologie HAS s'aligne sur les standards internationaux (3 mois post-op).

## Sources de Données
- **PMSI MCO** (RSA + chaînage) : actes CCAM pour identifier la population cible, DP/DR/DA pour la détection ISO, dates pour la fenêtre de 90 jours.
- **SNDS** (depuis 2024) : permet le suivi des réadmissions hors établissement initial, indispensable pour ne pas sous-estimer les ISO traitées dans un autre établissement.
- **Outil HAS QualHAS** : restitution des résultats individuels par finess géographique avec ajustement.
- **Référentiel CCAM** (mise à jour annuelle ATIH) : codes des arthroplasties et des reprises septiques.
- **Référentiel CIM-10 FR** (OMS, mise à jour annuelle) : codes T84.5, T81.4, M00.x.

## Exemple de Valeurs
*Source : HAS, restitutions IQSS ISO-ORTHO 2020-2024, diffusion publique QualHAS.*

- **Taux national brut PTH (hors fracture)** : ~0,8 % à 90 jours (8 ISO pour 1 000 PTH).
- **Taux national brut PTG** : ~0,7 % à 90 jours (7 ISO pour 1 000 PTG).
- **Plage inter-établissement** : 0,2 % – 2,5 % pour PTH ; 0,2 % – 2,0 % pour PTG.
- **Seuil d'alerte HAS** : ratio standardisé > 1,5 avec IC 95% > 1,0 → établissement en alerte (vigilance ARS).
- **Volume cible minimal** : ≥ 50 PTH/an et ≥ 50 PTG/an pour stabilité statistique de l'indicateur HAS.
- **Comparaison OCDE** : France dans la moyenne (0,5 – 1,2 %), Pays-Bas et Pays nordiques 0,3 – 0,7 %.

## Limites
- **Codage des ISO en DA** : sous-codage chronique des infections sur prothèse (parfois codées « complication mécanique » T84.0 plutôt que T84.5).
- **Chaînage incomplet** : avant SNDS, les patients réadmis dans un établissement hors GHT échappaient au numérateur ; biais désormais corrigé via chaînage SNDS.
- **Volume minimal** : pour les CH périphériques avec < 50 PTH/an, la stabilité statistique est faible, l'IC 95% reste très large.
- **Case-mix résiduel** : les patients à très haut risque (polyarthrite rhumatoïde sévère, immunodépression) sont exclus de la cible mais l'ajustement résiduel sur Charlson reste imparfait.
- **Définition stricte « hors fracture »** pour PTH : les PTH sur fracture du col (qui ont un risque ISO supérieur) ne sont pas dans la cible, ce qui exclut une partie significative de l'activité gériatrique.
- **Délai de 90 jours** : ne capture pas les ISO chroniques tardives (pseudarthrose septique à 6-12 mois) qui représentent une part non négligeable des reprises septiques.

## Références
- [HAS — IQSS ISO-PTH (page indicateur)](https://www.has-sante.fr/jcms/p_3294825/fr/iqss-2022-infections-du-site-operatoire-apres-pose-de-prothese-totale-de-hanche-iso-pth)
- [HAS — IQSS ISO-PTG (page indicateur)](https://www.has-sante.fr/jcms/p_3294826/fr/iqss-2021-infections-du-site-operatoire-apres-pose-de-prothese-totale-de-genou-iso-ptg)
- [HAS — Indicateurs pour la mesure nationale des complications en chirurgie orthopédique](https://www.has-sante.fr/jcms/p_3216705/fr/indicateurs-pour-la-mesure-nationale-des-complications-en-chirurgie-orthopedique)
- [HAS — Cadre réglementaire IQSS (arrêté du 5 août 2025)](https://www.has-sante.fr/jcms/r_1456735/fr/cadre-reglementaire-des-indicateurs-de-qualite-et-de-securite-des-soins-iqss)
- [HAS — Visualisation dynamique des IQSS validés](https://www.has-sante.fr/jcms/p_3800298/fr/visualisation-dynamique-des-indicateurs-de-qualite-et-de-securite-des-soins-iqss-valides-par-secteur-et-par-domaine)
