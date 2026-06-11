# Taux de Fuite d'Aval de Parcours

## Définition

Le taux de fuite d'aval de parcours mesure la proportion de patients dont la prise en charge **commence** dans le GHT (séjour index : diagnostic, bilan, premier épisode) mais dont le séjour de **traitement** ultérieur pour la même pathologie est réalisé hors GHT, dans une fenêtre de temps définie (180 jours par défaut). Il capture la rupture de captation *en cours de parcours* : le patient a fait confiance au GHT pour l'entrée dans le soin, puis lui a échappé au moment de l'étape la plus structurante (et souvent la mieux valorisée).

Le concept s'appuie sur la littérature de la « fragmentation des soins » (fragmented care) : recevoir les étapes d'un même traitement dans des hôpitaux différents est un phénomène fréquent — 32,5 % des patientes traitées pour cancer de l'endomètre de haut grade en Ontario (Nica et al. 2024), ~35 % des cancers du rectum localement avancés aux États-Unis (Freischlag et al. 2020) — et associé dans plusieurs contextes à une surmortalité (Freischlag et al. 2020 ; Han et Kim 2023). Ici, la mesure est orientée pilotage territorial : on ne mesure pas la fragmentation en général, mais le sens sortant GHT → extérieur, conditionnel à un premier contact GHT.

Cet indicateur diffère des indicateurs existants du projet : `taux_fuite_attractivite.md` est transversal (séjour par séjour, sans notion de parcours) ; `taux_churn_patient_fidelisation_ght.md` est longitudinal mais mesure la perte *totale* de contact en année N+1. La fuite d'aval est conditionnelle à un parcours intra-pathologie : elle isole les patients que le GHT a vus, diagnostiqués… et perdus avant le traitement.

Formule symbolique :

```
TFA = N_fuite_aval / N_parcours × 100

N_parcours   = patients avec séjour index dans le GHT (pathologie P) suivi d'un séjour
               de traitement (de la même pathologie) dans les 180 jours, où qu'il ait lieu
N_fuite_aval = sous-ensemble dont le séjour de traitement a lieu hors GHT
```

L'indicateur se calcule par couple {séjour index → séjour de traitement} défini par pathologie.

## Calcul

1. **Champ** : PMSI MCO national chaîné (numéro de chaînage anonyme inter-établissements), années N et N+1 (pour couvrir la fenêtre de 180 jours des index de fin d'année). Patients résidents du territoire GHT.
2. **Définition des couples index → traitement** (paramètre central, à figer par filière) ; exemples :
   - **Cancer colorectal** : index = premier séjour avec DP/DR de cancer du côlon-rectum (C18–C20) sans acte de résection ; traitement = séjour avec acte CCAM de colectomie/proctectomie ;
   - **Cancer du sein** : index = séjour de bilan/biopsie avec DP C50 ; traitement = séjour avec acte de mastectomie ou tumorectomie ;
   - **Pathologie valvulaire** : index = séjour de cardiologie avec DP valvulopathie ; traitement = séjour avec acte de remplacement valvulaire (chirurgical ou TAVI) ;
   - **Orthopédie programmée** : index = séjour/consultation hospitalière avec DP coxarthrose (M16) ; traitement = séjour avec acte de prothèse totale de hanche.
3. **Pseudocode** :

```
index      = premiers séjours GHT (par patient × pathologie) répondant à la définition index
traitement = pour chaque index, premier séjour (tous établissements) avec acte cible
             et délai 0 < t ≤ 180 jours

parcours   = index ayant trouvé un traitement       # les index sans traitement sont exclus
fuite_aval = parcours[finess_traitement ∉ finess_ght]

TFA = n(fuite_aval) / n(parcours) × 100             # non calculé si n(parcours) < 30
```

4. **Conventions** : si plusieurs séjours de traitement, retenir le premier ; patients décédés entre index et fin de fenêtre exclus du dénominateur ; séjour index et traitement le même jour (acte au cours de l'index) = parcours retenu non fui ; ne pas compter en fuite un traitement réalisé hors GHT sur une activité que le GHT ne produit pas (croiser avec le casemix GHT, comme pour la fuite évitable).
5. **Indicateurs dérivés** : délai médian index → traitement des parcours retenus vs fuis (un délai GHT long est un mécanisme de fuite testable) ; TFA par établissement d'index (quel site du GHT « perd » ses patients).

## Utilité

- **Sécuriser l'aval des filières de cancérologie** : un TFA élevé entre bilan diagnostique et chirurgie carcinologique signale une RCP qui adresse à l'extérieur, des délais opératoires dissuasifs ou un défaut de lisibilité de l'offre chirurgicale du GHT — perte sèche d'activité lourde et de file active.
- **Mesurer la conversion diagnostic → traitement** par site : repérer les établissements du GHT qui jouent malgré eux le rôle de « centre de tri » au profit d'opérateurs extérieurs.
- **Tester l'hypothèse délais** : si le délai médian index → traitement intra-GHT excède nettement celui des parcours fuis, la fuite d'aval est un problème de capacité (vacations de bloc), pas d'image.
- **Évaluer les filières inter-établissements** : après mise en place d'une filière formalisée (ex. orthopédie territoriale), le TFA de la filière doit converger vers le niveau plancher (fuite résiduelle de choix).
- **Protéger la pertinence des investissements diagnostiques** : un plateau d'imagerie ou d'endoscopie dont l'aval fuit systématiquement produit de la valeur pour les concurrents ; le TFA quantifie cette externalité.
- **Argument qualité auprès des patients et de la ville** : la littérature associe la fragmentation inter-hospitalière des traitements à de moins bons résultats dans plusieurs contextes (Freischlag et al. 2020 ; Han et Kim 2023) — maintenir le parcours complet dans le GHT est aussi un argument médical, à manier avec nuance (cf. Limites).

## Sources de Données

- **PMSI MCO national chaîné** : numéro de chaînage anonyme (clé de chaînage inter-établissements générée via MAGIC/ANO `[modalités exactes selon la documentation chaînage ATIH en vigueur, à confirmer]`), DP/DR (CIM-10), actes CCAM, dates d'entrée/sortie (ou délais), FINESS, code géographique de résidence.
- **SNDS** pour les extensions (consultations externes, actes de ville entre index et traitement) et le statut vital.
- **Référentiels** : CIM-10 et CCAM en vigueur pour les définitions de couples index → traitement ; FINESS pour le périmètre GHT.
- Le calcul nécessite la **base nationale** : le traitement réalisé hors GHT est invisible dans les bases locales.

## Exemple de Valeurs

Repères internationaux sourcés et ordres de grandeur expert pour la France :

- **Ontario, cancer endomètre haut grade** : 32,5 % de parcours fragmentés chirurgie/adjuvant (Nica et al. 2024).
- **États-Unis, cancer rectum stades II-III** : ~35 % de fragmentation radiothérapie/chirurgie (Freischlag et al. 2020).
- **GHT français, ordre de grandeur expert (non sourcé)** : TFA attendu de 10–25 % en cancérologie digestive et sénologie pour un GHT non-CHU disposant de l'offre chirurgicale ; 5–15 % en orthopédie programmée. Un TFA > 30 % sur une filière où le GHT produit le traitement constitue une alerte majeure.
- **Plancher incompressible** : 5–10 % (préférences patients, deuxième avis, regroupements familiaux).

## Limites

- **Qualité du chaînage** : ~1–2 % des RSA ont une clé de chaînage défaillante ; les taux d'échec varient selon les établissements et les années — vérifier la complétude avant interprétation.
- **Définition des couples index → traitement** : c'est le paramètre dominant ; une définition trop large (tout séjour ultérieur) dilue le signal, trop étroite le rend instable. Figer les algorithmes par filière, avec validation par les cliniciens.
- **La fuite d'aval peut être médicalement justifiée** : adressage conforme à la gradation des soins (chirurgie complexe, seuils d'activité réglementaires en cancérologie) — restreindre le numérateur aux traitements que le GHT produit, et garder une lecture filière par filière. Nica et al. (2024) montrent d'ailleurs qu'une fragmentation organisée autour d'un centre spécialisé n'est pas délétère.
- **Censure et délais** : la fenêtre de 180 jours manque les traitements tardifs (surveillance active, chimiothérapie néoadjuvante longue) ; adapter la fenêtre par pathologie.
- **Volume minimal** : ne pas interpréter sous 30 parcours/an par filière ; agréger plusieurs années pour les pathologies rares.
- **Pas de causalité individuelle** : l'indicateur identifie des filières qui fuient, pas les raisons (délais, adressage, choix) ; il appelle une analyse qualitative (entretiens adresseurs, délais de RDV) avant action.

## Références

- Nica A, Sutradhar R, Kupets R, et al. *Effect of fragmentation of surgery and adjuvant treatment in high-grade nonendometrioid endometrial cancer: a population-based cohort study.* Am J Obstet Gynecol. 2025;232(6):549.e1-549.e7. [DOI](https://doi.org/10.1016/j.ajog.2024.11.015) — PMID:39551459
- Freischlag K, Olivere L, Turner M, Adam M, Mantyh C, Migaly J. *Does Fragmentation of Care in Locally Advanced Rectal Cancer Increase Patient Mortality?* J Gastrointest Surg. 2021;25(5):1287-1296. [DOI](https://doi.org/10.1007/s11605-020-04760-x) — PMID:32754789
- Han KT, Kim S. *The effect of fragmented cancer care and change in nurse staffing grade on cancer patient mortality.* Worldviews Evid Based Nurs. 2023;20(6):610-620. [DOI](https://doi.org/10.1111/wvn.12676) — PMID:37691136
- ATIH. *Documentation du chaînage PMSI (MAGIC/ANO)* : [atih.sante.fr](https://www.atih.sante.fr/)
- Fiches liées : `taux_churn_patient_fidelisation_ght.md` (perte de contact totale), `taux_fuite_attractivite.md` (fuite transversale), `../07_parcours_continuite/` (indicateurs de continuité).
