# Base de connaissances — Indicateurs PMSI/GHT

Base de référence de 185 indicateurs de pilotage hospitalier pour les GHT, calculables depuis le PMSI MCO/SSR/PSY et le SNDS.

## Structure

```
indicateurs_pmsi/
├── 01_activite_production/       (27 indicateurs)
├── 02_casemix_patientele/        (22 indicateurs)
├── 03_vulnerabilite_sociale/     (7 indicateurs)
├── 04_efficience_capacitaire/    (23 indicateurs)
├── 05_qualite_securite/          (24 indicateurs)
├── 06_pertinence_pratiques/      (17 indicateurs)
├── 07_parcours_continuite/       (26 indicateurs)
├── 08_readmissions_evitables/    (11 indicateurs)
├── 09_territoire_attractivite/   (20 indicateurs)
└── 10_financement_valorisation/  (8 indicateurs)
```

Chaque fiche documente : définition, formule de calcul, sources de données, exemple de valeurs, limites et références.

## Indicateurs innovants

Une trentaine d'indicateurs adaptent des cadres théoriques d'autres disciplines scientifiques à l'analyse hospitalière :

| Indicateur | Discipline d'origine | Répertoire |
|---|---|---|
| Capacité de charge organisationnelle (CCO) | Écologie des populations | 04 |
| Module d'Young organisationnel (MYO) | Science des matériaux | 04 |
| Courbe de Laffer des ressources soignantes | Économie fiscale | 04 |
| Indice de plasticité post-choc | Science des matériaux | 04 |
| Énergie potentielle de la liste d'attente | Physique | 04 |
| Loi de Little hospitalière | Théorie des files d'attente | 04 |
| Valeur d'option réelle capacitaire | Finance | 04 |
| Heijunka hospitalier | Lean manufacturing | 04 |
| Analyse spectrale FFT des flux d'admissions | Traitement du signal | 01 |
| Entropie de transfert inter-services | Théorie de l'information | 01 |
| Débit base/crue des admissions | Hydrologie | 01 |
| Indice d'allométrie volume-complexité | Biologie (loi de Kleiber) | 01 |
| Indice de phénologie des admissions | Écologie | 01 |
| Indice de résilience post-perturbation | Écologie (Holling/Pimm) | 01 |
| Score de succession du mix GHM | Écologie (Clements/Horn) | 01 |
| Taux de colonisation de nouveaux GHM | Biogéographie (MacArthur & Wilson) | 01 |
| Rapport signal/bruit des indicateurs qualité | Traitement du signal | 05 |
| Loi Gutenberg-Richter des événements indésirables | Sismologie | 05 |
| Rendement de Carnot de la filière de soins | Thermodynamique | 05 |
| Ratio de Sharpe de la performance qualité | Finance | 05 |
| Value at Risk des événements indésirables | Finance | 05 |
| First Pass Yield du parcours sans défaut | Lean manufacturing | 05 |
| Indice de Simpson de diversité d'équipe SSR | Écologie | 05 |
| Fonction de risque Weibull des réadmissions | Ingénierie de fiabilité | 08 |
| Distance de Levenshtein des séquences de soins | Informatique théorique | 07 |
| Compression algorithmique du parcours | Théorie de l'information | 07 |
| Exposant de Lyapunov du parcours chronique | Systèmes dynamiques | 07 |
| Constante cinétique MCO→SSR | Cinétique chimique | 07 |
| Diagramme Hertzsprung-Russell des services | Astrophysique | 02 |
| Distance de Mahalanobis du profil patient | Statistiques multivariées | 02 |
| Température statistique du casemix | Physique statistique | 02 |
| Entropie de Shannon du casemix | Théorie de l'information | 02 |
| Indice de rétention des soins primaires | Hydrologie | 03 |
| Coefficient de Gini de la consommation hospitalière | Économie | 03 |
| Centralité betweenness du réseau GHT | Théorie des graphes | 09 |
| Loi de Metcalfe du GHT numérique | Télécommunications | 09 |
| Indice Herfindahl des flux patients | Économie industrielle | 09 |
| Taux de churn patient | Marketing/Télécommunications | 09 |
| Taux de dérive des plans de soins (SPC) | Contrôle statistique des procédés | 06 |

## Sources de données

- **PMSI MCO RSA** — séjours, GHM, diagnostics, actes CCAM
- **PMSI SSR RHS / PMSI PSY** — activité SSR et psychiatrie
- **SNDS DCIR** — consommations ambulatoires, médicaments, biologie
- **Référentiels ATIH** — poids GHM, IP-DMS, DMS nationales
