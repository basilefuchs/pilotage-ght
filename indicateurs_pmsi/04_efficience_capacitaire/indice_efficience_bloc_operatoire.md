# Indice d'Efficience du Bloc Opératoire

## Définition
L'indice d'efficience du bloc opératoire est un indicateur composite mesurant la performance organisationnelle et économique des salles d'opération d'un établissement du GHT. Il agrège plusieurs dimensions : le taux d'occupation des salles (temps opératoire réel vs temps ouvert), le ratio actes programmés/urgents, le taux d'annulation des interventions programmées et la durée moyenne de vacation utilisée. Le bloc opératoire représente généralement 40-60 % des charges d'un établissement chirurgical et conditionne directement la capacité du GHT à développer son activité chirurgicale, à réduire les délais d'attente et à améliorer sa rentabilité T2A.

## Calcul
L'indice d'efficience du bloc opératoire est calculé à partir de plusieurs sous-indicateurs :

**1. Taux d'occupation des salles (TOS) :**
```
TOS (%) = (Temps opératoire réel cumulé / Temps opératoire ouvert cumulé) × 100
  → Objectif cible : 75-85 %
```

**2. Taux d'annulation des interventions programmées :**
```
Taux d'annulation (%) = (Nombre d'interventions programmées annulées le jour J / Nombre total d'interventions programmées) × 100
  → Objectif cible : < 5 %
```

**3. Ratio programmé / urgences :**
```
Ratio P/U = Nombre d'actes chirurgicaux programmés / Nombre total d'actes chirurgicaux
  → Analyse la part de la chirurgie non programmée pesant sur l'organisation du bloc
```

**4. Estimation depuis le PMSI (proxy) :**
```
Proxy TOS PMSI = (Nombre de séjours avec actes CCAM réalisés / Capacité théorique annuelle de séjours chirurgicaux) × 100
```

**Précisions méthodologiques** :
- Les données précises du bloc (horodatages d'entrée/sortie de salle) sont issues des logiciels de gestion du bloc (DIANE, BOW, Axya) et non directement du PMSI.
- Le PMSI permet néanmoins des proxies robustes : nombre d'actes CCAM par jour et par établissement, répartition programmé/urgences via `modeentree` = 8 et `provenance` = 5 (urgences), distribution hebdomadaire et mensuelle des actes.
- L'analyse PMSI permet également d'identifier les « séjours sans acte » (séjours MCO sans code CCAM associé) pouvant signaler des dysfonctionnements de codage ou des annulations non tracées.
- L'indice composite peut être calculé en agrégeant les sous-indicateurs pondérés selon les priorités du GHT.

## Utilité
- **Optimisation de l'utilisation des salles** : identifier les salles ou les spécialités chirurgicales avec un TOS faible (<70 %) pour réorganiser les vacations et réduire les temps morts.
- **Réduction des annulations** : analyser les causes d'annulation (patient, organisationnel, matériel) pour mettre en place des actions correctives ciblées.
- **Développement de la chirurgie ambulatoire** : un bloc efficient avec un TOS élevé est un prérequis pour augmenter la part d'ambulatoire sans créer de tensions capacitaires.
- **Réduction des délais d'attente** : une meilleure efficience du bloc permet d'augmenter le nombre d'actes réalisés sans investissement capacitaire supplémentaire, réduisant ainsi les délais de prise en charge.
- **Benchmarking intra-GHT** : comparer l'efficience des blocs opératoires entre les différents sites du GHT pour identifier les bonnes pratiques à diffuser et les établissements nécessitant un accompagnement.

## Sources de Données
- **Logiciels de gestion du bloc opératoire** (DIANE, BOW, Axya, Opéra) : source primaire pour les horodatages précis (entrée en salle, incision, fermeture, sortie de salle) et les annulations.
- **PMSI MCO - Actes CCAM** : proxy pour estimer le volume d'activité chirurgicale, la répartition programmé/urgences et la distribution temporelle des actes.
- **SAE (Statistique Annuelle des Établissements)** : nombre de salles d'opération, vacations ouvertes, pour calculer la capacité théorique.
- **Tableaux de bord de bloc opératoire** : outils internes des établissements (souvent dans les DIM ou les directions des soins) compilant les indicateurs d'efficience en temps réel.
- **HAS - Manuel de certification** : indicateurs de bloc opératoire intégrés dans les critères de certification des établissements de santé.

## Exemple de Valeurs
- **Taux d'occupation des salles (TOS) moyen** : 65-75 % dans les établissements publics français, contre 75-85 % dans les établissements privés les plus efficients.
- **Taux d'annulation** : 8-15 % dans les établissements publics (objectif HAS < 5 %), avec des pics en période estivale et de grèves.
- **Ratio programmé/urgences** : 70-80 % de chirurgie programmée dans les CHG, contre 50-60 % dans les CHU (poids plus important de la chirurgie urgente et complexe).
- **Gain potentiel d'une optimisation** : une amélioration du TOS de 65 % à 80 % sur un bloc de 6 salles représente l'équivalent d'une salle supplémentaire, soit +15-20 % de capacité chirurgicale sans investissement.
- **Coût d'une salle de bloc par heure** : 500-1 500 €/heure selon les équipements ; une heure de salle non utilisée représente une perte économique directe significative.

## Limites
- Les données précises du bloc opératoire (horodatages) ne sont pas dans le PMSI et nécessitent l'accès aux logiciels métier du bloc, dont l'interopérabilité avec le SIH est variable selon les établissements.
- Le TOS seul n'est pas suffisant : un TOS élevé obtenu par des séjours très courts (chirurgie légère) n'est pas équivalent à un TOS élevé en chirurgie lourde.
- Les comparaisons inter-établissements sont complexes : la structure du casemix (proportion d'urgences, complexité des cas) influence fortement les indicateurs d'efficience indépendamment de l'organisation.
- Un taux d'annulation faible peut masquer des déprogrammations anticipées non tracées (annulations plusieurs jours avant l'intervention) ou des sélections abusives de patients.
- L'amélioration de l'efficience du bloc peut générer des tensions en aval (lits d'hospitalisation, SSR) si elle n'est pas accompagnée d'une organisation cohérente du parcours post-opératoire.

## Références
- [HAS - Manuel de certification des établissements de santé (critère bloc opératoire)](https://www.has-sante.fr/)
- [ATIH - Actes CCAM et activité chirurgicale dans le PMSI](https://www.atih.sante.fr/)
- [SAE - Statistique Annuelle des Établissements de santé](https://www.sae-diffusion.sante.gouv.fr/)
- [ANAP - Bloc opératoire : organisation et performance](https://www.anap.fr/)
