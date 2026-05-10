# Divergence de Kullback-Leibler du Profil de Complications

## Définition

La **divergence de Kullback-Leibler (KL)**, introduite par Kullback et Leibler (1951), mesure l'écart informationnel entre deux distributions de probabilité P et Q sur le même ensemble d'événements. Appliquée aux profils de complications hospitalières, elle compare la distribution observée des complications dans un établissement à la distribution de référence (benchmark national ou GHT, ajusté case-mix) :

```
D_KL(P‖Q) = Σ_i p_i · log(p_i / q_i)
```

où p_i est la fréquence observée de la complication i dans l'établissement, q_i la fréquence attendue (benchmark national ajusté case-mix).

**Positionnement vs indicateurs existants** : les fiches existantes du dépôt (`taux_complications_ghm.md`, `psi90_patient_safety_indicators.md`, `taux_evenements_indesirables.md`) résument la qualité par un **taux unique** (ou une somme pondérée). Cette agrégation occulte la **structure** des complications : deux établissements peuvent partager le même taux global tout en ayant des profils radicalement différents (l'un dominé par les ISO, l'autre par les sepsis post-procéduraux). La divergence KL capture cette structure multidimensionnelle en un scalaire interprétable comme « quantité d'information supplémentaire nécessaire pour décrire P à partir de Q ».

Variante symétrique recommandée : **divergence de Jensen-Shannon (JS)**, bornée dans [0, log 2] et symétrique, plus stable numériquement :

```
D_JS(P‖Q) = ½ · D_KL(P‖M) + ½ · D_KL(Q‖M),  M = ½(P + Q)
```

## Calcul

```
Étape 1 — Définir le vecteur de complications K :
  Liste fermée de K complications PMSI-codables, ex. (K = 12) :
    1. Embolie pulmonaire post-op (I26 + Z87.39)
    2. Sepsis post-procédural (T81.4)
    3. Pneumothorax iatrogène (J95.0)
    4. Hémorragie post-op (T81.0)
    5. ISO superficielle (T81.4 + Z48)
    6. ISO profonde (T81.4 + procédure orthopédique CCAM)
    7. Choc septique (R65.21 + R57.2)
    8. IRA post-op (N17 + Z48)
    9. Chute en service (W00-W19 + Y92.21)
   10. Escarre acquise (L89 + Z48)
   11. Réintervention non programmée (CCAM reprise <30j)
   12. Décès inattendu (mode_sort = 9 hors palliatif)

Étape 2 — Construction des distributions P (établissement) et Q (benchmark) :
  Sur fenêtre 12 mois glissants :
    Pour chaque GHM g (groupé en CMD ou racine GHM) :
      - n_obs(i, g) = nb de complications i dans GHM g (établissement)
      - n_exp(i, g) = nb attendu = taux_national(i, g) × N_séjours(g)_ES
    Agrégation case-mix :
      p_i = Σ_g n_obs(i, g) / Σ_g Σ_j n_obs(j, g)
      q_i = Σ_g n_exp(i, g) / Σ_g Σ_j n_exp(j, g)
  Lissage de Laplace pour éviter q_i = 0 :
    q_i ← (q_i · N + α) / (N + K · α),  α = 0,5 (Jeffreys)

Étape 3 — Calcul de D_KL et D_JS :
  D_KL = Σ_i p_i · log2(p_i / q_i)
  D_JS = ½·D_KL(P‖M) + ½·D_KL(Q‖M)

Étape 4 — Décomposition par contribution :
  Contribution_i = p_i · log2(p_i / q_i)
  → identifie les complications qui tirent la divergence vers le haut
  → permet de cibler le plan d'action

Étape 5 — Test de significativité :
  Bootstrap stratifié par GHM (1000 réplicats) → IC95 sur D_KL
```

## Utilité

- **Profilage qualité multidimensionnel** : un scalaire qui capture la déformation complète du profil de complications, sans masquer les compensations entre familles (ISO vs sepsis vs hémorragies)
- **Détection des spécificités structurelles** : un établissement avec D_JS élevé sur un benchmark ajusté case-mix présente des complications **atypiques** pour son recrutement — signal fort pour audit ciblé
- **Pilotage GHT** : matrice D_JS(ES_i ‖ ES_j) entre tous les établissements du GHT → identification des établissements « atypiques » à investiguer collégialement
- **Suivi longitudinal d'un plan qualité** : la décomposition par complication montre quelles familles d'EIG sont effectivement réduites par les actions menées (pas seulement le taux global)
- **Communication ARS / inspection** : un D_JS faible (< 0,05) atteste d'une qualité conforme au benchmark ; D_JS > 0,15 motive un échange spécifique
- **Recherche de pratiques de référence** : identifier les établissements avec D_JS faible **et** taux global faible → candidats au partage d'expérience GHT

## Sources de Données

- **PMSI MCO RSA** : DP, DAS (CIM-10) pour les complications, CCAM pour les actes et reprises chirurgicales, mode de sortie pour les décès, GHM/CMD pour la stratification case-mix
- **Liste de complications de référence** : PSI-90 AHRQ adaptée au codage français (cf. `psi90_patient_safety_indicators.md`) ou liste ATIH des complications surveillées
- **Distribution de référence Q** : taux nationaux par GHM disponibles via ScanSanté / PMSI national agrégé ATIH ; à défaut, agrégat GHT
- **Volume minimal recommandé** : 5 000 séjours sur la fenêtre 12 mois pour stabilité de l'estimation (sinon recourir au lissage de Jeffreys et reporter l'IC95 large)

## Exemple de Valeurs

- **D_JS = 0,02–0,05** → profil quasi-superposable au benchmark (établissement standard)
- **D_JS = 0,05–0,12** → spécificités modérées, généralement explicables par le recrutement (plus de chir. vasculaire = plus d'EP)
- **D_JS > 0,15** → profil atypique nécessitant analyse (sur-représentation d'une famille)
- **CH général sur PSI-90 vs national** :
  - taux global complications : 4,1 % (national 4,0 %, conforme)
  - mais D_JS = 0,18 → profil marqué par sur-représentation des chutes (Contribution = 0,11) et sous-représentation des EP (Contribution = -0,03 négligeable car déficit)
  - → cible identifiée : programme prévention chutes
- *Plages indicatives, ordre de grandeur expert ; calibrer sur cohorte ATIH avant interprétation opérationnelle.*

## Limites

- **Sensible aux complications rares** : si q_i ≈ 0 et p_i > 0, log(p_i/q_i) explose ; le lissage de Jeffreys est obligatoire mais introduit un biais conservateur
- **Hétérogénéité du codage** : un établissement qui code mieux les DAS aura mécaniquement un profil de complications plus riche, ce qui inflate D_KL — toute interprétation doit être confrontée à un audit du codage
- **Choix de la liste K** : la divergence dépend du périmètre des complications retenues ; standardiser via PSI-90 ou liste ATIH pour la comparabilité GHT
- **Asymétrie de KL** : D_KL(P‖Q) ≠ D_KL(Q‖P) — utiliser systématiquement la variante Jensen-Shannon pour les comparaisons inter-établissements
- **Stratification case-mix essentielle** : un calcul direct sans ajustement par GHM produit un D_KL qui reflète surtout la différence de recrutement, pas la différence de qualité
- **Volume minimal** : sous 5 000 séjours/an, l'IC95 du D_JS dépasse souvent 50 % de la valeur centrale → interprétation prudente
- **Pas de seuil d'alerte universel** : les plages doivent être calibrées localement (distribution des D_JS sur le GHT)

## Références

- [Kullback S., Leibler R.A. — On information and sufficiency, Ann. Math. Stat. 1951 : article fondateur](https://doi.org/10.1214/aoms/1177729694)
- [Lin J. — Divergence measures based on the Shannon entropy, IEEE Trans. Inf. Theory 1991 : Jensen-Shannon comme alternative symétrique et bornée](https://doi.org/10.1109/18.61115)
- [Spiegelhalter D.J. et al. — Statistical methods for healthcare regulation: rating, screening and surveillance, J. R. Stat. Soc. A 2012 : cadre statistique pour le profilage hospitalier](https://doi.org/10.1111/j.1467-985X.2011.01010.x)
- [AHRQ — Patient Safety Indicators v2024 : périmètre des complications hospitalières codables](https://qualityindicators.ahrq.gov/)
- [ATIH — Référentiel CIM-10 et guide méthodologique PMSI MCO en vigueur](https://www.atih.sante.fr/)
- [HAS — Indicateurs de qualité et de sécurité des soins (IQSS), HAS 2026](https://www.has-sante.fr/jcms/c_970481/fr/indicateurs-de-qualite-et-de-securite-des-soins-en-etablissements-de-sante)
