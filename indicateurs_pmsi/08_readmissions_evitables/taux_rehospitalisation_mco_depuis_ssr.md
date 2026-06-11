# Taux de Réhospitalisation MCO Non Programmée depuis SSR

## Définition

Proportion de séjours SSR (Soins de Suite et Réadaptation) interrompus par un transfert non programmé vers un service de soins aigus MCO (Médecine-Chirurgie-Obstétrique), identifié par le mode de sortie SSR = 7 (transfert vers MCO) associé à un mode d'entrée MCO = 6 (provenance SSR) ou = 5 (urgences) dans les 24-48h, par chaînage NIR crypté.

Distingue les transferts programmés (intervention chirurgicale planifiée, consultation spécialisée avec retour SSR prévu) des transferts non programmés liés à une complication ou une dégradation clinique survenue pendant le séjour SSR. C'est un indicateur de sécurité des soins en SSR : il signale soit une instabilité clinique sous-estimée à l'admission SSR (patient transféré trop précocement depuis MCO), soit une complication nosocomiale acquise en SSR (chute avec fracture, infection, décompensation cardiaque, AVC récidivant), soit une inadéquation des ressources médicales SSR face à la complexité du patient.

Stratifié par GME SSR, motif de réhospitalisation MCO (diagnostic principal du séjour MCO de transfert en CIM-10), et délai depuis l'admission SSR (précoce < 7j = signal d'admission prématurée vs tardif ≥ 7j = complication acquise en SSR).

## Calcul

Chaînage PMSI SSR RHS × PMSI MCO RSA par NIR crypté SNDS.

Identification des transferts non programmés :

```
Méthode 1 — par le mode de sortie SSR :
  → Séjours SSR avec mode_sort = 7 (transfert vers MCO/clinique)
  → Séjour MCO suivant identifié dans les 48h par chaînage NIR
  → mode_entrée MCO = 6 (provenance SSR) ou = 5 (urgences)

Méthode 2 — par le mode d'entrée MCO (approche miroir) :
  → Séjours MCO avec mode_entrée = 6 (provenance SSR)
    OU mode_entrée = 5 (urgences) avec patient ayant un séjour SSR actif
    à la date d'entrée MCO (selon les dates de début/fin des RHS SSR)
  → Valider que le séjour SSR précédent était actif (non terminé définitivement)

Exclusions :
  → Transferts programmés documentés (retour MCO pour acte chirurgical planifié
    = mode_entrée MCO = 6 avec GHM chirurgical programmé et retour SSR dans les 72h)
  → Transferts pour consultation externe sans nuitée MCO (séjour MCO = 0 nuit)
```

Formule principale :

```
Taux de réhospitalisation MCO depuis SSR (%) =
  (Séjours SSR avec transfert MCO non programmé identifié
   / Total séjours SSR actifs dans la période) × 100
```

Sous-indicateurs :

```
Par délai post-admission SSR :
  < 7j  : transfert précoce → signal d'admission SSR prématurée
           (critères d'admission SSR à réviser)
  ≥ 7j  : transfert tardif → complication acquise en SSR
           (protocoles de prévention à renforcer)

Par motif de réhospitalisation MCO (DP du séjour MCO) :
  J00-J22, J40-J47 (infectieux respiratoire) : pneumopathie, IRA
  N10-N16, N30-N39 (infectieux urinaire)      : IU sur sonde
  W00-W19 (chutes) + S00-S99 (fractures)      : traumatismes en SSR
  I20-I25, I50 (cardiovasculaire)             : décompensation cardiaque
  I60-I69 (neurologique)                      : récidive AVC
  T36-T65 (intoxications, surdosages)         : iatrogénie médicamenteuse

Indicateur sentinelle de sécurité SSR :
  → Taux de chutes tracées en SSR (codes W00-W19 dans les DA des RHS SSR)
  → Taux d'escarres de stade ≥ 2 tracées (L89.1-L89.9 dans les DA RHS)
```

## Utilité

- **Identifier les admissions SSR prématurées** : un taux élevé de transferts précoces (< 7j post-admission) dans un service MCO donné signale que les critères de stabilité clinique appliqués avant transfert vers SSR sont insuffisants — action corrective : protocole de critères d'admission SSR co-élaboré entre MCO et SSR
- **Détecter les complications nosocomiales acquises en SSR** : les transferts tardifs (≥ 7j) avec motif infectieux ou traumatique sont des événements indésirables évitables — cibler les protocoles de prévention des infections urinaires sur sonde, des chutes, et des pneumopathies de déglutition
- **Évaluer la capacité des équipes SSR à gérer les complications** : un SSR avec un taux élevé de transferts MCO mais un taux de complications documentées dans les RHS faible peut signaler une tendance à sur-transférer par prudence — différencier l'inefficience organisationnelle du défaut de compétences médicales
- **Optimiser les critères d'admission SSR par spécialité** : réduire le bed-blocking MCO sans transférer des patients trop instables — l'indicateur fournit le feedback nécessaire pour calibrer ce compromis
- **Appuyer la démarche qualité SSR** : indicateur directement utilisable dans le cadre de la certification HAS (critère relatif à la sécurité des soins en SSR) et des revues de morbi-mortalité des services SSR
- **Pilotage GHT multi-sites** : comparer les taux entre établissements SSR du GHT pour identifier les bonnes pratiques transposables (protocoles anti-chute, surveillance INR, prévention pneumopathie)

## Sources de Données

- **PMSI SSR RHS** : mode_sort, GME, FP, dates d'entrée/sortie du séjour, diagnostics associés CIM-10 (dont W00-W19 chutes, L89 escarres), NIR crypté
- **PMSI MCO RSA** : mode_entrée, diagnostic principal (DP CIM-10), diagnostics associés, date d'entrée, durée de séjour, NIR crypté
- **Chaînage SNDS par NIR crypté** : appariement des séjours SSR et MCO du même patient, y compris entre établissements différents (SSR GHT → MCO hors GHT, ou inversement)

## Exemple de Valeurs

- **Taux national estimé tous GME SSR** : 5-10% (ATIH données SSR 2022)
- **Gériatrie polyvalente** : 10-15% (population fragile, polypathologie, risque infectieux et cardiovasculaire élevé)
- **Orthopédie élective (PTH/PTG)** : 3-5% (population sélectionnée, indication programmée, instabilité clinique rare)
- **Neurologie cérébro-lésée (AVC)** : 6-10% (risque de récidive AVC, pneumopathie de déglutition, embolie pulmonaire)
- **Part des transferts précoces (< 7j)** : environ 30-40% des réhospitalisations MCO depuis SSR — les plus évitables car liées à des critères d'admission inadaptés
- **Principaux motifs** : infectieux (pneumopathie, infection urinaire) ~35%, cardiovasculaire ~20%, chutes/fractures ~15%, neurologique (récidive) ~10%

## Limites

- La distinction programmé/non programmé repose sur le mode_sort SSR qui n'est pas toujours codé précisément — sous-estimation possible des transferts programmés classés à tort en mode_sort = 7, entraînant une surestimation du taux de réhospitalisation non programmée
- Les transferts vers les urgences (mode_entrée MCO = 5) sans identification explicite du séjour SSR d'origine dans le RSA MCO peuvent être manqués si le patient ou le SAMU ne signale pas le séjour SSR en cours lors de l'admission aux urgences
- Les établissements SSR intégrant un service MCO ou une unité de soins continus peuvent gérer des complications sans transfert formel (consultation médicale sur place, passage en unité d'hospitalisation courte interne) — taux artificiellement bas dans ces structures
- Le taux brut n'est pas ajusté sur la sévérité des patients admis en SSR (un SSR neurologiques lourds aura structurellement un taux plus élevé qu'un SSR locomoteur) ; la stratification par GME est indispensable pour tout benchmark équitable

## Références

- [Crotty M. et al. — Early discharge and home rehabilitation after hip fracture achieves functional improvements: a randomised controlled trial, Clin Rehabil 2002](https://doi.org/10.1191/0269215502cr518oa) — transition post-MCO et risque de réhospitalisation
- [Phruetthiphat O. et al. — Predictors for readmission following primary total hip and total knee arthroplasty, J Orthop Surg 2020](https://doi.org/10.1177/2309499020959160) — prédicteurs de réadmission après arthroplastie
- [ATIH — Guide méthodologique PMSI SSR : codage des modes de sortie/entrée et chaînage inter-champs](https://www.atih.sante.fr/)
- [HAS — Critères de certification V2020 relatifs à la sécurité des soins en SSR (critère 8.2, 8.3)](https://www.has-sante.fr/)
- [SFGG — Recommandations sur la prévention des complications en SSR gériatrique (2020)](https://www.sfgg.fr/)
