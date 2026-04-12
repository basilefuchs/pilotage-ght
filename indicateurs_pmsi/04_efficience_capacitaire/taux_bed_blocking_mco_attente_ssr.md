# Taux de Bed-Blocking MCO (Patients en Attente de Place SSR)

## Définition

Le "bed-blocking" (ou blocage de lit) désigne la situation où un patient hospitalisé en MCO, cliniquement stabilisé et éligible à une prise en charge en SSR ou en établissement médico-social, ne peut pas être transféré faute de place disponible et occupe ainsi un lit de soins aigus au-delà de sa DMS médicalement justifiée. Cet indicateur mesure : (1) le nombre de journées d'hospitalisation MCO "excédentaires" liées à une attente de place SSR, et (2) la proportion de séjours MCO concernés.

En PMSI, il est approché par deux signaux complémentaires : (a) séjours MCO avec DMS observée supérieure à la borne haute du GHM ET mode de sortie = 6 (mutation vers SSR), signalant un séjour prolongé au-delà de la norme tarifaire dans l'attente d'un transfert SSR ; (b) présence du code CIM-10 Z75.1 (personne en attente d'admission dans un établissement de soins approprié) dans les diagnostics associés du RSA.

Le bed-blocking génère des surcoûts directs pour l'établissement MCO (journées facturées sous le tarif journalier T2A, au-delà de la borne haute GHM) et des coûts indirects (déconditionnement fonctionnel du patient maintenu en milieu de soins aigus inadapté à la rééducation, risque nosocomial accru). C'est un indicateur à la fois d'efficience (T2A sous-optimal), de qualité des soins (risque patient) et de coordination des filières (tension capacitaire SSR).

## Calcul

Méthode principale — approche par la durée de séjour et les bornes GHM :

```
Population : séjours MCO avec mode_sort = 6 (transfert vers SSR)

Journées de bed-blocking par séjour :
  BB_jours = MAX(0 ; DMS_observée − DMS_haute_GHM)

DMS_haute_GHM = borne haute du GHM (publiée par l'ATIH dans les fichiers
                de groupage tarifaires annuels — à utiliser pour l'année
                de sortie du séjour concerné)

Journées totales de bed-blocking (période) :
  BB_total = Σ BB_jours sur l'ensemble des séjours éligibles
```

Méthode complémentaire — approche par le codage CIM-10 :

```
Séjours MCO avec Z75.1 dans les diagnostics associés (DA) du RSA :
  → Proxy direct mais très sous-utilisé dans le codage MCO français
  → Sensibilité faible (~5-15% des bed-blockings réels), spécificité élevée
  → Utile pour identifier les séjours explicitement documentés en attente
  → Complémentaire, non substitutif, à la méthode principale
```

Indicateurs agrégés :

```
Taux de séjours avec bed-blocking (%) :
  = (Séjours MCO avec mode_sort=6 ET DMS_obs > DMS_haute_GHM
     / Total séjours MCO avec mode_sort=6) × 100

Intensité du bed-blocking (jours médians excédentaires) :
  = Médiane de BB_jours sur les séjours avec BB_jours > 0

Coût économique estimé :
  = BB_total (jours) × Perte tarifaire journalière moyenne
  Perte tarifaire = forfait journalier T2A sous-borne haute (ex: ~200-400€/j)
```

Sous-indicateurs par service et territoire :

```
Par service MCO émetteur :
  → Orthopédie, neurologie, gériatrie, médecine interne, cardiologie
    (services avec les plus forts volumes de transferts vers SSR)

Par établissement MCO du GHT :
  → Comparaison inter-sites pour identifier les établissements les plus impactés

Évolution temporelle :
  → Tendance trimestrielle (pic hivernal typique en gériatrie)
  → Avant/après création d'une convention MCO-SSR ou d'une cellule d'orientation

Croisement avec délai médian MCO→SSR (indicateur SSR-1) :
  → Corrélation attendue : bed-blocking élevé ↔ délai médian long
  → Dissociation possible : délai court mais bed-blocking élevé = flux rapide
    mais avec des séjours longs avant la place SSR disponible
```

## Utilité

- **Quantifier l'impact financier de la tension capacitaire SSR** : transformer les journées de bed-blocking en euros de perte tarifaire fournit un argument économique immédiatement compréhensible par la direction pour investir dans des capacités SSR supplémentaires ou des conventions avec des partenaires SSR
- **Identifier les services MCO les plus impactés** : la ventilation par service permet de prioriser les actions (conventions SSR spécifiques à l'orthopédie vs à la neurologie) plutôt que d'adopter une approche indifférenciée
- **Appuyer les demandes de lits SSR auprès de l'ARS** : le nombre de journées de bed-blocking est un argument objectif, calculé depuis les données PMSI, pour justifier une demande d'autorisation de lits SSR supplémentaires ou de révision des capacités autorisées
- **Mesurer l'impact des actions d'amélioration** : évaluer l'effet d'une convention SSR partenaire, du développement d'une filière HAD de rééducation, ou de la mise en place d'une cellule d'orientation dédiée sur la réduction des journées de bed-blocking
- **Vue filière intégrée avec l'IPS SSR** : un IPS élevé (séjours SSR longs) amplifie mécaniquement le bed-blocking MCO — la réduction de la DMS SSR excédentaire libère des capacités en aval MCO ; les deux indicateurs doivent être analysés conjointement

## Sources de Données

- **PMSI MCO RSA** : mode de sortie (mode_sort = 6), DMS observée, code GHM, diagnostics associés (Z75.1), service médical, FINESS établissement, NIR crypté
- **ATIH — Fichiers bornes GHM** : DMS basse et haute par GHM publiés annuellement dans les fichiers tarifaires T2A (disponibles sur le portail ATIH, format XLSX/CSV) — utiliser le fichier de l'année de séjour concernée
- **PMSI SSR RHS** : date d'entrée effective en SSR par chaînage NIR — permet de calculer le délai réel d'attente entre la sortie MCO et l'admission SSR, et de valider les séjours avec bed-blocking par la méthode indirecte
- **DCIR ER_PHA_F** (optionnel) : dispensations de médicaments pour les patients en bed-blocking — non indispensable mais utile pour documenter les risques iatrogènes pendant la période d'attente

## Exemple de Valeurs

- **Estimation française tous services MCO (DREES 2019)** : 5-15% des journées MCO en orthopédie et neurologie sont des journées excédentaires liées à l'attente SSR
- **Période de tension capacitaire hivernale** : taux pouvant atteindre 20-25% dans les services de médecine gériatrique en janvier-février
- **Coût moyen d'une journée de bed-blocking** : 200-400€ de perte tarifaire nette (journée sous-remboursée en T2A par rapport au tarif DRG complet)
- **Délai médian d'attente SSR** : 3-7 jours dans les GHTs avec filières organisées, 15-21 jours dans les territoires déficitaires
- **Impact de la mise en place d'une cellule d'orientation MCO-SSR** : réduction de 25-35% des journées de bed-blocking documentée dans les GHTs ayant formalisé ce dispositif (retours d'expérience FEHAP/FHF 2021)

## Limites

- Le code Z75.1 est très sous-utilisé dans le codage MCO français (estimé documenté dans < 15% des séjours réels de bed-blocking) — l'approche par la DMS > borne haute est plus sensible mais moins spécifique (une DMS longue peut avoir d'autres causes médicales légitimes que l'attente SSR)
- L'identification via DMS > borne haute GHM suppose que cette borne est la bonne référence de DMS médicalement justifiée pour le patient concerné — les patients complexes peuvent légitimement dépasser la borne haute pour des raisons cliniques documentées, sans attente SSR
- L'indicateur ne capture que le bed-blocking intra-MCO — il ne mesure pas la pression sur les urgences (patients en attente de lit MCO avant orientation vers SSR) ni le bed-blocking en aval (attente de place EHPAD depuis SSR)
- Les bornes hautes GHM varient chaque année avec les revalorifications tarifaires ATIH — les comparaisons inter-annuelles nécessitent d'utiliser le référentiel de chaque année concernée, faute de quoi les tendances temporelles sont biaisées

## Références

- [Ou L. et al. — Delayed discharge from hospital in older adults: a systematic review, BMJ Open 2021](https://doi.org/10.1136/bmjopen-2020-044193)
- [Landeiro F. et al. — Delayed hospital discharges of older patients: a systematic review on prevalence and costs, Age Ageing 2017](https://doi.org/10.1093/ageing/afx028)
- [DREES — Études et Résultats : les soins de suite et de réadaptation, panorama de l'offre (2019)](https://www.drees.solidarites-sante.gouv.fr/)
- [ATIH — Guide méthodologique tarifaire MCO : bornes basses et hautes GHM (mis à jour annuellement)](https://www.atih.sante.fr/)
- [HAS — Recommandations pour l'organisation des filières SSR et la réduction des délais d'attente MCO](https://www.has-sante.fr/)
