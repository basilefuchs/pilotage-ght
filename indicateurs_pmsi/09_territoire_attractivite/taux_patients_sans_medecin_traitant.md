# Taux de Patients sans Médecin Traitant Déclaré

## Définition
Le taux de patients sans médecin traitant déclaré mesure la proportion de la population du bassin de santé du GHT qui n'a pas de médecin traitant déclaré auprès de l'Assurance Maladie, par commune et par IRIS. En France, le dispositif du médecin traitant a été instauré par la réforme du parcours de soins de 2004 (loi du 13 août 2004) : tout assuré doit déclarer un médecin traitant auprès de la CNAM pour bénéficier du remboursement optimal de ses soins. L'absence de médecin traitant déclaré est le proxy le plus direct et le plus opérationnel du désert médical fonctionnel — il ne signale pas seulement une sous-densité médicale (nombre de médecins par habitant) mais l'incapacité concrète d'un patient à accéder à un médecin de premier recours acceptant de nouveaux patients et de s'y inscrire. Cet indicateur est calculable directement depuis le DCIR (champ "médecin traitant" de la table bénéficiaire CNAM) et constitue un outil de dialogue stratégique entre le GHT, les CPTS (Communautés Professionnelles Territoriales de Santé), les MSP (Maisons de Santé Pluriprofessionnelles) et l'ARS pour documenter et prioriser les zones de désert médical sur le territoire.

## Calcul
Le taux de patients sans médecin traitant est calculé depuis la table bénéficiaires du DCIR :

```
Population sans médecin traitant déclaré =
  Bénéficiaires de l'Assurance Maladie résidant dans le territoire du GHT
  n'ayant aucun médecin traitant déclaré actif au 31 décembre de l'année N

Taux sans médecin traitant (%) = (Population sans MT / Population totale assurée) × 100

Granularité géographique :
  → Par commune (code INSEE)
  → Par IRIS (maille infra-communale INSEE, ~2 000 habitants)
  → Par bassin de vie / zone d'attractivité du GHT
```

**Construction depuis le DCIR :**
```
Table bénéficiaires (IR_BEN_R ou ER_CAL_F) :
  → BEN_NIR_PSA : identifiant bénéficiaire (NIR crypté)
  → BEN_RES_COM : commune de résidence du bénéficiaire
  → MED_MTR_NUM : numéro RPPS du médecin traitant déclaré (NULL si aucun)
  → MED_MTR_DTE : date de déclaration du médecin traitant

Filtre : population résidant dans les communes du bassin GHT
  → Inclure : assurés tous régimes (RG, MSA, RSI...)
  → Exclure : bénéficiaires décédés, mineurs de moins de 16 ans (non soumis à l'obligation MT)

Taux par tranche d'âge :
  → 16-25 ans : taux structurellement plus élevé (mobilité, changement de résidence)
  → 65 ans et plus : taux plus faible mais impact clinique majeur si sans MT
  → Taux ≥ 65 ans sans MT = indicateur sentinelle de désert médical pour les personnes vulnérables
```

**Sous-indicateurs dérivés :**
```
Taux de patients sans médecin traitant par IRIS (%) → cartographie du désert médical
  → Représentation GIS (carte de chaleur) par commune/IRIS du territoire

Délai médian depuis la dernière déclaration d'un MT (mois) :
  → Pour les patients qui avaient un MT et ne l'ont plus (MT décédé, retraité, déménagement)
  → Signal de rupture récente du lien avec le premier recours

Taux de patients sans MT parmi les patients hospitalisés en urgence :
  → Croisement DCIR (statut MT) × PMSI (mode entrée urgences)
  → Corrélation directe avec le taux de non-recours ambulatoire pré-hospitalisation (#4)

Taux de patients sans MT parmi les patients ALD actifs :
  → Les patients chroniques sans MT sont en situation de particulière vulnérabilité
  → Indicateur de ciblage prioritaire pour les actions de médiation

Évolution annuelle du taux sans MT :
  → Tendance à la hausse = aggravation du désert médical
  → Permet d'anticiper les tensions futures et d'alerter l'ARS sur les zones critiques

Indice de tension sur l'offre de MT :
  = Taux sans MT × (1 / densité médecins généralistes pour 10 000 hab)
  → Combine la demande non couverte et la capacité d'absorption de l'offre locale
```

## Utilité
- **Cartographie du désert médical fonctionnel sur le territoire du GHT** : le taux sans MT par IRIS est l'indicateur le plus opérationnel pour identifier les zones prioritaires d'implantation de maisons de santé, de CPTS, de médecins salariés ou de consultations avancées — plus précis que la densité médicale brute car il mesure l'accès effectif et non l'offre théorique.
- **Corrélation avec le sur-recours aux urgences et les HPE** : les zones à fort taux de patients sans MT sont systématiquement les zones à fort taux d'hospitalisations potentiellement évitables et de passages aux urgences sans suite — l'indicateur fournit l'argument territorial pour justifier les investissements en soins primaires auprès de l'ARS et des collectivités.
- **Outil de dialogue avec les CPTS et les MSP** : le taux sans MT par commune quantifie précisément le "file active potentielle" non couverte, outil indispensable pour les CPTS qui doivent justifier leurs actions d'organisation du premier recours auprès de l'ARS et de la CNAM dans le cadre de leurs accords conventionnels.
- **Anticipation des crises capacitaires** : un taux sans MT en hausse dans une zone avec des médecins traitants âgés (départ en retraite imminent) préfigure une crise d'accès aux soins primaires dans 2-5 ans — l'indicateur permet une planification anticipée des ressources médicales du GHT (médecins salariés, consultations avancées dans les établissements membres).
- **Pilotage des dispositifs d'accès aux soins** : évaluer l'impact des actions du GHT (consultations avancées de médecine générale, téléconsultations, protocoles de coopération IPA-médecin) sur l'évolution du taux sans MT dans les zones ciblées — indicateur de résultat à 1-3 ans.
- **Ciblage des patients ALD vulnérables** : les patients ALD sans MT déclaré sont la population la plus à risque de décompensation non détectée — leur identification depuis le DCIR permet de lancer des actions de médiation proactives (contact par l'Assurance Maladie, orientation vers une MSP ou un médecin coordinateur du GHT).

## Sources de Données
- **DCIR (SNDS)** : table bénéficiaires (IR_BEN_R) — champ MED_MTR_NUM (numéro RPPS du médecin traitant) et BEN_RES_COM (commune de résidence) — source principale, actualisée annuellement.
- **CNAM** : données médecin traitant disponibles également en agrégé via les tableaux de bord CNAM par CPAM territoriale — accès sans SNDS pour les données de territoire à maille département.
- **RPPS (Répertoire Partagé des Professionnels de Santé)** : pour vérifier le statut actif/inactif du médecin traitant déclaré (médecin retraité, décédé, ou ayant cessé son activité sans que le patient ait fait une nouvelle déclaration).
- **INSEE — Géographie des communes et IRIS** : pour la représentation cartographique et le calcul des indicateurs à maille infra-communale.
- **DREES — Atlas de la démographie médicale** : données de densité médicale par département/zone pour croiser avec le taux sans MT et construire l'indice de tension sur l'offre.

## Exemple de Valeurs
- **Taux national de patients sans médecin traitant déclaré (France, 2023)** : environ 7-10 % de la population adulte selon les données CNAM — mais avec des disparités territoriales considérables (< 3 % dans certaines métropoles, > 25 % dans les zones rurales isolées).
- **Zones rurales en tension** : dans les déserts médicaux les plus touchés (certains territoires de Creuse, Nièvre, Ardennes), le taux sans MT dépasse 20-30 % de la population adulte.
- **Patients ALD sans MT** : 5-8 % des patients ALD actifs n'ont pas de médecin traitant déclaré — proportion plus faible que la population générale mais à impact clinique disproportionné.
- **Patients sans MT hospitalisés aux urgences** : 15-25 % des patients admis aux urgences n'ont pas de médecin traitant déclaré selon les études locales — fortement associé à la précarité sociale (Z59-Z65) et à l'isolement géographique.
- **Évolution 2015-2023** : le taux national de patients sans MT a augmenté de 3 à 4 points en 8 ans, reflétant la démographie médicale défavorable (départs en retraite > installations) — tendance structurellement haussière dans la plupart des territoires ruraux.

## Limites
- Le taux de patients sans médecin traitant déclaré mesure l'absence de déclaration administrative, pas nécessairement l'absence d'accès aux soins : certains patients sans MT déclaré consultent régulièrement des médecins en accès direct (spécialistes, SOS Médecins, centres de santé) sans s'être formellement déclarés auprès d'un médecin traitant.
- La déclaration du médecin traitant peut être obsolète sans que le patient l'ait mise à jour (médecin retraité, déménagement) — le taux calculé depuis le DCIR peut sous-estimer le taux réel de patients sans accès effectif à un MT si les déclarations périmées ne sont pas filtrées.
- L'indicateur ne capture pas les patients qui ont un MT déclaré mais ne peuvent pas obtenir de rendez-vous dans des délais raisonnables (médecin en sous-activité ou débordé) — la notion de "médecin traitant effectivement accessible" nécessiterait des données sur les délais de rendez-vous, non disponibles dans le DCIR.
- Les mineurs de moins de 16 ans sont exclus de l'obligation de déclaration d'un médecin traitant — le taux ne couvre pas la pédiatrie de premier recours, qui peut néanmoins être en tension dans certains territoires.
- Le périmètre DCIR couvre les assurés des régimes de base (RG, MSA, RSI) mais pas l'intégralité de la population (mutuelles non obligatoires, populations non assurées) — légère sous-représentation des populations les plus précaires.

## Références
- [CNAM — Tableau de bord médecin traitant : données territoriales annuelles](https://www.ameli.fr/)
- [DREES — Atlas de la démographie médicale : densité et déserts médicaux par territoire](https://www.drees.solidarites-sante.gouv.fr/)
- [SNDS — Table bénéficiaires IR_BEN_R : champ médecin traitant déclaré](https://www.snds.gouv.fr/)
- [Loi du 13 août 2004 — Réforme de l'Assurance Maladie : instauration du médecin traitant](https://www.legifrance.gouv.fr/)
- [INSEE — Géographie des IRIS et des communes pour la cartographie du désert médical](https://www.insee.fr/)
