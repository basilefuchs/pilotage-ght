# Indice de Complexité des Parcours Multi-RUM

## Définition
L'indice de complexité des parcours multi-RUM mesure la proportion de séjours MCO comportant plusieurs Résumés d'Unité Médicale (RUM), c'est-à-dire des séjours au cours desquels le patient a été muté entre plusieurs unités fonctionnelles (UF) au sein du même établissement. Chaque RUM correspond à un passage dans une UF distincte ; un RSS multi-RUM reflète donc une prise en charge complexe nécessitant l'intervention de plusieurs services (ex. : urgences → réanimation → médecine, ou chirurgie → soins intensifs → médecine). Cet indicateur, invisible dans le GHM final qui agrège l'ensemble du séjour, est un proxy robuste de la complexité organisationnelle et clinique intra-séjour non capturée par la seule classification GHM.

## Calcul
L'indice de complexité des parcours multi-RUM est calculé comme suit :

```
Taux de séjours multi-RUM (%) = (Nombre de RSS comportant ≥ 2 RUM / Nombre total de RSS) × 100

Indice de complexité multi-RUM = Nombre moyen de RUM par RSS = Σ(nombre de RUM par RSS) / Nombre total de RSS
```

**Sous-indicateurs dérivés :**
```
Taux de séjours ≥ 3 RUM (%) = (RSS avec ≥ 3 RUM / Total RSS) × 100   → proxy de complexité majeure

Durée moyenne par RUM (h) = DMS totale du séjour / Nombre de RUM       → détecte les mutations rapides (instabilité)

Taux de séjours avec passage en réanimation/soins intensifs (%) = RSS contenant un RUM d'UF réanimation / Total RSS
```

**Précisions méthodologiques** :
- Le nombre de RUM par RSS est directement disponible dans la structure du fichier PMSI MCO (fichier RSS/RSA).
- L'analyse est réalisée par CMD, par GHM et par unité fonctionnelle d'origine (première UF du séjour) pour identifier les services générateurs de parcours complexes.
- Le croisement avec la DMS et le GHM final permet de distinguer les séjours multi-RUM longs (complexité clinique lourde) des séjours multi-RUM courts (mutations organisationnelles rapides potentiellement optimisables).
- L'analyse peut être affinée par le type de mutation : mutation vers une UF de niveau supérieur (escalade des soins) vs mutation vers une UF de niveau inférieur (déclassement, préparation à la sortie).

## Utilité
- **Identification des séjours complexes invisibles dans le GHM** : deux séjours dans le même GHM peuvent avoir des trajectoires intra-hospitalières très différentes (1 RUM vs 5 RUM) ; l'indice multi-RUM révèle cette hétérogénéité cachée et justifie des ressources différenciées.
- **Analyse de l'organisation interne** : un taux élevé de mutations rapides (RUM courts) peut signaler des problèmes d'organisation (manque de lits dans l'UF d'admission, réorientation tardive) plutôt qu'une complexité clinique réelle.
- **Pilotage des unités de soins intensifs et de réanimation** : le taux de séjours avec passage en réanimation est un indicateur clé de la lourdeur du casemix et du dimensionnement nécessaire des lits critiques.
- **Benchmarking intra-GHT** : comparer les indices multi-RUM entre les établissements du GHT pour objectiver les différences de casemix clinique au-delà du CMI ou du GHM.
- **Aide à la tarification et à la négociation** : les séjours multi-RUM très complexes (≥ 4 RUM, passage réanimation) sont souvent sous-valorisés par le GHM terminal si les actes lourds réalisés dans les UF intermédiaires ne sont pas tous codés.

## Sources de Données
- **PMSI MCO - Fichier RSS/RSA** : structure native multi-RUM, disponible dans les exports PMSI de chaque établissement. Chaque RSS contient N RUM avec leurs UF, dates d'entrée/sortie et diagnostics respectifs.
- **ATIH - Logiciel GENRSA / VisualValoSej** : outils de traitement des fichiers PMSI permettant l'exploitation des données multi-RUM.
- **ScanSanté** : les indicateurs multi-RUM ne sont pas disponibles nativement ; le calcul requiert un traitement local des fichiers RSA bruts.
- **DIM des établissements** : les Départements d'Information Médicale disposent des fichiers RSA complets pour réaliser ce calcul en local.

## Exemple de Valeurs
- **Taux de séjours mono-RUM** : 70-80 % des séjours MCO, représentant les prises en charge simples dans une seule unité fonctionnelle.
- **Taux de séjours avec 2 RUM** : 10-15 % des séjours, souvent des passages en soins continus ou en UHCD avant retour en service.
- **Taux de séjours avec ≥ 3 RUM** : 5-10 % des séjours, concentrant une part disproportionnée des coûts et des journées.
- **Séjours ≥ 3 RUM et DMS** : DMS moyenne 2 à 4 fois supérieure aux séjours mono-RUM dans le même GHM, reflétant la lourdeur clinique réelle.
- **Taux de passage réanimation** : 2-5 % des séjours MCO selon le type d'établissement (CHU ~5 %, CHG ~2 %, clinique privée <1 %).
- **Durée moyenne par RUM** : 3-5 jours en médecine polyvalente, 1-2 jours en UHCD ou soins intensifs (mutations rapides).

## Limites
- La granularité des RUM dépend du découpage en unités fonctionnelles propre à chaque établissement : un établissement découpant finement ses UF génère mécaniquement plus de RUM par séjour qu'un établissement avec peu d'UF, sans que cela reflète nécessairement une complexité clinique supérieure.
- Certaines mutations entre UF sont purement administratives (réorganisation temporaire, changement de chef de service) et ne reflètent pas une transition clinique réelle.
- Le fichier RSA brut multi-RUM n'est pas facilement exploitable sans compétences techniques spécifiques (format PMSI, logiciels DIM) : ce calcul ne peut pas être réalisé directement depuis ScanSanté.
- L'indice ne distingue pas les mutations d'escalade (aggravation clinique) des mutations de déclassement (amélioration et préparation à la sortie), qui ont des implications organisationnelles très différentes.
- Les comparaisons inter-établissements sont difficiles sans standardisation préalable sur la structure des UF et les pratiques locales de découpage.

## Références
- [ATIH - Guide méthodologique PMSI MCO : structure RSS/RSA et RUM](https://www.atih.sante.fr/)
- [ATIH - Logiciel GENRSA et traitement des fichiers PMSI](https://www.atih.sante.fr/)
- [DGOS - Référentiel des unités fonctionnelles et organisation hospitalière](https://sante.gouv.fr/)
