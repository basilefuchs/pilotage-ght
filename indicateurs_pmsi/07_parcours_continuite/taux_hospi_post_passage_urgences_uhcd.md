# Taux d'Hospitalisations Faisant Suite à un Passage aux Urgences / UHCD

## Définition
Le **taux d'hospitalisations faisant suite à un passage aux urgences ou en UHCD** (Unité d'Hospitalisation de Courte Durée) mesure la part des séjours MCO en hospitalisation complète qui ont été **précédés d'un passage aux urgences**, identifié par le **mode d'entrée 8** (« par les urgences ») dans le PMSI ou par une provenance UF/UM des urgences.

Cet indicateur est suivi par la DREES (Panorama des établissements de santé : 21,6 millions de passages aux urgences en 2022 dont une part conduit à hospitalisation) et constitue un marqueur de la **part de l'activité MCO en mode non programmé**, signal majeur pour le pilotage GHT (charge des urgences sur l'aval, lien avec le maillage médecine de ville, capacité d'absorption d'aval).

Formule :

```
Taux Hospi-Urgences = (RSA hospi complète avec `modeentree` = 8 OU
                       RUM précédent en UF urgences/UHCD)
                      / (RSA hospi complète total)

Décomposition :
  Part directe (MOD_ENT=8 → MCO) : urgences → hospitalisation immédiate
  Part via UHCD : passage UHCD ≥ 1 nuit puis transfert MCO
  Part programmée (MOD_ENT≠8) : pour comparaison
```

Positionnement vs indicateurs existants : complète `taux_recours_urgences_pour_mille.md` (volume des passages) et `taux_activite_non_programmee.md` (toute activité non programmée). Cet indicateur cible spécifiquement le **flux urgences → hospitalisation conventionnelle**, donc le sous-segment le plus consommateur de capacité d'aval.

## Calcul

```
Étape 1 — Identification des hospitalisations complètes MCO
  RSA en hospitalisation complète :
    `duree` ≥ 1 jour OU GHM hors niveau J (hors ambu)
  Exclusions :
    - CMD 28 (séances)
    - CMD 14 (obstétrique — flux distinct)
    - GHM ambulatoire (J)

Étape 2 — Détection de la provenance urgences
  Méthode 1 — `modeentree` :
    `modeentree` = 8 et `provenance` = 5 (« par les urgences » ; ou `passage_urg` = 1 depuis 2023)
  Méthode 2 — Analyse RUM (plus précis) :
    Existe-t-il un RUM antérieur dans le même séjour avec UF urgences/UHCD ?
    (UF de type 35 = UHCD, UF de type 24 = urgences générales selon nomenclature
     des unités fonctionnelles)
  Méthode 3 — Chaînage avec RPU (Résumé de Passage aux Urgences) :
    Si RPU disponible, chaîner par n°anonyme + dates pour confirmer le passage urgences
    immédiatement antérieur

Étape 3 — Calcul
  N = nb RSA hospi complète avec entrée urgences (méthode retenue)
  D = nb RSA hospi complète total
  Taux = N / D × 100

Étape 4 — Stratifications
  - Par CMD : indique les disciplines à fort flux urgences (CMD 04 pneumologie,
    CMD 05 cardio, CMD 08 ortho-trauma, CMD 23 facteurs influençant)
  - Par classe d'âge : forte concentration sur ≥75 ans
  - Par jour de la semaine / horaire : pic admissions weekend
  - Par établissement / GHT : positionnement
  - Par mode de sortie : retour domicile vs SSR (nécessité d'aval)
```

Variables PMSI clés : `modeentree`, `MODE_SORTIE`, `UF` (unité fonctionnelle), `TYPE_AUTORISATION_UM`, `duree`, `GHM`, `CMD`. Optionnellement, données RPU pour chaînage urgences.

## Utilité
- **Pilotage de l'aval des urgences** : un taux élevé d'hospitalisations post-urgences signale une dépendance à l'aval, levier de tension capacitaire.
- **Diagnostic GHT non programmé** : cartographie de la part de l'activité MCO captée via les urgences (typiquement 35-50 % en CH généraux).
- **Articulation avec médecine de ville** : un taux croissant peut indiquer une dégradation de l'accès aux soins primaires (basculement vers les urgences).
- **Suivi du Plan urgences** : impact des mesures de désengorgement (SAS, MMG, hospitalisations directes sans passage urgences).
- **Détection bed-blocking** : combinaison avec `taux_bed_blocking_mco_attente_ssr.md` pour identifier les engorgements.
- **Adaptation capacitaire** : prévision lits MCO d'aval nécessaires, modélisation files d'attente.
- **Évaluation des hospitalisations directes** : un taux qui décroît malgré une activité stable indique un développement réussi des hospitalisations programmées et des admissions directes (sans passage urgences).
- **Pilotage personnes âgées** : la part chez ≥75 ans est particulièrement élevée, marqueur de l'efficacité des dispositifs PAERPA et filières gériatriques directes.

## Sources de Données
- **PMSI MCO** : RSA + RUM, `modeentree`, UF, type d'autorisation UM.
- **RPU (Résumé de Passage aux Urgences)** : si disponible, pour chaînage robuste.
- **Référentiel ATIH des UF / unités fonctionnelles** : nomenclature des UF urgences (24) et UHCD (35) (mise à jour annuelle).
- **DREES Panorama** : volumétrie nationale des passages urgences (21,6 M en 2022).
- **DREES Études et Résultats** : analyses de la part non programmée.
- **SAE** : capacités urgences/UHCD installées par établissement.

## Exemple de Valeurs
*Sources : DREES Panorama Établissements de santé 2024 (données 2022), DREES ER 1344 (juillet 2025), ATIH ScanSanté.*

- **Taux national hospi post-urgences** : ~40-45 % des hospitalisations complètes MCO France.
- **CHU** : 35-40 % (équilibre programmé/urgences).
- **CH périphériques** : 50-65 % (forte dépendance urgences).
- **Cliniques privées** : 5-15 % (dominante programmée).
- **Plage par CMD** :
  - CMD 04 pneumologie : 70-80 % (BPCO, pneumopathies)
  - CMD 05 cardiologie : 50-60 % (SCA, IC décompensée)
  - CMD 08 ortho-trauma : 40-50 % (fractures)
  - CMD 02 ophtalmologie : < 5 % (programmée)
  - CMD 09 dermato : 10-20 %
- **Plage personnes âgées (≥75 ans)** : 60-75 % via urgences (forte dépendance).
- **Évolution récente** : tendance lente à la baisse via développement des admissions directes gériatriques (-1 à -2 pts/an dans les GHT structurés).

## Limites
- **Hétérogénéité du codage `modeentree`** : certains établissements sous-codent ou sur-codent le mode 8 ; valeur 8 vs UF urgences peut diverger de plusieurs points.
- **UHCD inégalement déclarée** : certains établissements n'ont pas d'UHCD formelle, les passages prolongés sont alors codés différemment.
- **Confusion avec mode entrée 7 (transfert)** : un patient admis aux urgences puis transféré dans un autre établissement compte différemment selon le périmètre.
- **Pas de chaînage RPU systématique** : sans RPU, on perd la durée du passage urgences (heure d'arrivée → admission MCO), indicateur clé.
- **Effet établissement de premier recours** : les CH de proximité ont structurellement un taux plus élevé que les centres tertiaires, comparaison directe biaisée.
- **Pondération case-mix manquante** : un patient à pathologie aiguë vs un patient programmé n'ont pas le même profil GHM, lourdeur résiduelle non capturée.
- **Saisonnalité** : forte variabilité été/hiver (épidémies grippales, COVID), nécessité d'analyse sur 12 mois glissants.
- **Volume cible minimal** : ≥ 500 hospi/an MCO pour stabilité statistique.

## Références
- [DREES — Panorama Établissements de santé édition 2024 (données 2022)](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse/panoramas-de-la-drees/240718_Panorama_EtablissementsSante2024)
- [DREES — Panorama Établissements de santé édition 2025](https://drees.solidarites-sante.gouv.fr/publications-communique-de-presse-documents-de-reference/panoramas-de-la-drees/250522_Panorama_etablissements-de-sante2025)
- [DREES — ER n°1344, juillet 2025](https://drees.solidarites-sante.gouv.fr/sites/default/files/2025-07/ER1344%20Etablissements%20de%20sante%CC%81_MEL.pdf)
- [ATIH — Guide méthodologique PMSI MCO, format RSA / RUM](https://www.atih.sante.fr/)
- DGOS — Pacte de refondation des urgences et SAS (Service d'Accès aux Soins).
