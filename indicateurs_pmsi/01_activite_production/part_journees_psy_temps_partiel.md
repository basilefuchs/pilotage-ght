# Part des Journées de Psychiatrie en Temps Partiel

## Définition
La **part des journées de psychiatrie en temps partiel** mesure la fraction des journées d'hospitalisation psychiatrique réalisées en **temps partiel** (hospitalisation de jour, hospitalisation de nuit, séances ambulatoires structurées) parmi l'ensemble des journées de prise en charge à temps plein ou partiel. Cet indicateur est suivi par la DREES dans son *Études et Résultats* n°1344 (juillet 2025) qui documente une **baisse de 1,1 % des journées totales** de psychiatrie en 2024 et une **conversion progressive temps plein → temps partiel** alignée sur la stratégie nationale de virage ambulatoire en santé mentale.

Formule :

```
Part_TP_psy = journées_temps_partiel_psy
              / (journées_temps_plein_psy + journées_temps_partiel_psy)
```

Positionnement vs indicateurs existants : complémentaire de `activite_psy.md` (volumétrie globale) et de `taux_ambulatoire.md` (MCO uniquement). Cet indicateur est spécifique au secteur psychiatrie où la distinction temps plein / temps partiel est structurante (et différente de l'ambulatoire MCO).

## Calcul

```
Étape 1 — Identification des journées de psychiatrie
  Source : RPSA (Résumé par Séquence d'Activité — PMSI Psy)
  Variables clés :
    MODE_PRISE_EN_CHARGE (MPEC) :
      01-04 = temps plein (hospitalisation complète, accueil familial thérapeutique,
              centre de post-cure, appartement thérapeutique...)
      20-26 = temps partiel (hospitalisation de jour, de nuit, atelier thérapeutique,
              CATTP — centre d'accueil thérapeutique à temps partiel)
      16-17 = ambulatoire (hors périmètre de cet indicateur)

Étape 2 — Comptage des journées de présence
  Pour chaque RPSA :
    journées_TPlein = nb journées avec MPEC ∈ {01..04}
    journées_TPartiel = nb journées avec MPEC ∈ {20..26}

Étape 3 — Calcul
  Part_TP_psy = Σ journées_TPartiel / (Σ journées_TPlein + Σ journées_TPartiel)

Étape 4 — Stratifications recommandées
  - Par établissement (FINESS) — comparaison inter-établissements GHT
  - Par classe d'âge (adulte / pédopsychiatrie / personnes âgées)
  - Par diagnostic principal (CIM-10 chapitre F : F2x psychoses, F3x troubles
    de l'humeur, F4x troubles anxieux, F1x addictions...)
  - Évolution annuelle (suivi de la trajectoire)
```

Variables PMSI clés : `MODE_PRISE_EN_CHARGE` (MPEC), `NB_JOURNEES`, `FINESS_ETAB`, `DP` (CIM-10), `AGE_ANNEES`. Format : RPSA (PMSI Psychiatrie) — guide ATIH en vigueur.

## Utilité
- **Pilotage virage ambulatoire psy GHT** : indicateur central de la conversion des capacités temps plein vers temps partiel, alignement sur la trajectoire DREES nationale.
- **Suivi du Plan psychiatrie et santé mentale** : indicateur de la feuille de route ministérielle (sortie d'hospitalisation longue durée, développement HDJ, CATTP).
- **Optimisation capacitaire** : la conversion 1 lit temps plein → 2 places temps partiel libère des capacités à coût équivalent.
- **Adaptation aux pathologies chroniques** : la psychiatrie chronique se prête particulièrement au temps partiel (suivi régulier sans hébergement complet).
- **Comparaison inter-établissements** : forte hétérogénéité historique entre établissements spécialisés psy (CHS) et services de psychiatrie générale.
- **Suivi pédopsychiatrie** : la pédopsychiatrie présente structurellement une part TP plus élevée (CATTP scolaire, HDJ enfant).
- **Articulation avec ambulatoire** : à coupler avec l'évolution de l'activité ambulatoire (MPEC 16-17) pour vue complète de la stratégie de désinstitutionalisation.

## Sources de Données
- **PMSI Psy (RPSA)** : variable MPEC, nombre de journées de présence par séquence.
- **DREES — Études et Résultats** : référence nationale (ER 1344 juillet 2025).
- **DREES Panorama Établissements de santé** : volumétrie globale du secteur psychiatrique.
- **ATIH — Guide méthodologique PMSI Psychiatrie** : nomenclature MPEC en vigueur, mise à jour annuelle.
- **SAE (Statistique Annuelle des Établissements)** : capacités installées par mode de prise en charge.

## Exemple de Valeurs
*Source : DREES ER n°1344 (juillet 2025), DREES Panoramas 2024-2025.*

- **Part temps partiel France** : ~28-32 % des journées hospitalières psy en 2023 (DREES Panorama 2025).
- **Évolution 2024** : journées psy totales −1,1 % en 2024, dont temps plein en baisse plus rapide → part TP en hausse mécanique.
- **Cible orientation PNSM** : > 35 % à horizon 2030 (orientation feuille de route santé mentale).
- **Plage par établissement** : 15 % – 50 % selon la culture d'établissement et l'offre territoriale.
- **Pédopsychiatrie** : ~50-60 % en temps partiel (HDJ enfant, CATTP scolaire structurellement majoritaires).
- **Adultes psy générale** : ~25-30 % en temps partiel.
- **Personnes âgées psy** : 15-25 % en temps partiel (recours plus fort au temps plein).

## Limites
- **Hétérogénéité du codage MPEC** : le périmètre temps partiel inclut des modalités très diverses (HDJ médicalisée, CATTP éducatif), comparabilité limitée si déséquilibre du mix.
- **Activité ambulatoire externe** : les actes ambulatoires (CMP, consultations) ne sont pas dans le numérateur ni au dénominateur, malgré leur rôle structurant en santé mentale.
- **Non-codage des journées TP** : avant 2014, certaines structures sous-codaient les journées TP, biais à la baisse en analyse rétrospective.
- **Capacité installée vs activité** : un fort taux de TP peut traduire une sur-capacité TP non saturée (utiliser conjointement le taux d'occupation TP).
- **Pas un indicateur de qualité** : ne mesure pas la pertinence du choix temps plein/partiel pour chaque patient.
- **Évolutions réglementaires** : la nomenclature MPEC peut évoluer (notice ATIH annuelle), impact sur la comparabilité longitudinale.
- **Effet de structure** : un établissement spécialisé pédopsychiatrie aura mécaniquement un taux TP supérieur indépendamment de sa pratique.

## Références
- [DREES — ER n°1344, juillet 2025 : activité hospitalière 2024](https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-07/ER1344%20Etablissements%20de%20sante%CC%81_MEL.pdf)
- [DREES — Panorama Établissements de santé édition 2025](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- [DREES — Panorama Établissements de santé édition 2024](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/panoramas-de-la-drees/240718_Panorama_EtablissementsSante2024)
- [ATIH — Guide méthodologique PMSI Psychiatrie](https://www.atih.sante.fr/)
- Feuille de route Santé mentale et psychiatrie — Ministère de la Santé.
