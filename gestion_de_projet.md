## Plan détaillé pour la gestion de l’équipe de développement Python dans la réalisation de la calculatrice  

### 1. Constitution de l’équipe et attribution des rôles  

#### 1.1. Chef de projet / Product Owner  
- Définit les besoins fonctionnels et les objectifs métiers du projet.  
- Rédige le **backlog** et les **user stories**.  
- Priorise les tâches et définit les sprints (sur un cycle prédéfini 1 à 2 semaines).  
- Valide les livrables en s’assurant qu’ils répondent aux exigences des utilisateurs.  
- Replanifie un sprint cas d'évolution à faire sur les tickets précédents.

#### 1.2. Scrum Master / Responsable méthodologie  
- Implémente et veille au respect de la **méthodologie Agile (Scrum, Kanban, etc.)**.  
- Anime les **rituels Agiles** : stand-ups quotidiens, sprint planning, sprint review, rétrospective.  
- Favorise la communication et la collaboration entre les membres de l’équipe.  

#### 1.3. Tech Lead / Architecte  
- Définit l’**architecture technique** du projet :  
  - API Backend (FastAPI).  
  - Base de données (SQLite en l'occurence).  
  - Infrastructure et conteneurisation (Docker).  
- Détermine le contenu de la **stack technique**
- Valide les **PR (pull requests) critiques** et veille à la qualité du code sur les branches principales du projet.
  - Dev pour la dernière version à jour de développement
  - Main pour la production
- Fige les versions du produit/détermine le semver à utiliser
  
#### 1.4. Développeurs Python (Backend)  
- Implémentent la **logique métier de la calculatrice**.
- Développent l’**API REST** avec FastAPI pour traiter les requêtes du frontend.  
- Intègrent et gèrent la **base de données** (si historique des calculs requis).  
- Rédigent la pyramide de tests **tests unitaires/tests d'intégration/tests de bout en bout/tests de non regression** pour assurer la fiabilité du code et avoir un maximum de couverture de test sur la codebase.  
- Participent aux **revues de code** et rédigent la documentation technique.  

#### 1.5. Développeur Frontend (React)  
- Conçoit l’interface utilisateur avec **React** :  
- Connecte le frontend à l’**API REST** via des requêtes HTTP (Axios en l'occurence).  
- Implémente les **tests End-to-End** (ex. Cypress, Playwright) si nécessaire.  
- Participe à l’optimisation des performances et au design responsive.  

#### 1.6. DevOps / Ingénieur CI/CD  
- Met en place l’**infrastructure du projet** avec Docker et docker-compose.  
- Automatise le **déploiement** et la **livraison continue** (GitHub Actions, GitLab CI/CD).  
- Surveille et optimise les **environnements** (développement, recette, pré-production, production).  
- Assure la **maintenance** et la **sécurisation** des conteneurs.  

---

### 2. Déroulement du projet en méthodologie Agile  

#### 2.1. Phase de planification  
- Définition des **exigences fonctionnelles** et rédaction des user stories.  
- Élaboration d’un **POC** (Preuve de faisabilité) : une version fonctionnelle démontrant la capacité à répondre techniquement à un besoin métier.  
- Conception de l’**architecture** et des technologies à utiliser.  
- Découpage du projet en **sprints** de 1 à 2 semaines.  

#### 2.2. Phase de développement (sprints Agile)  
Chaque sprint inclut les étapes suivantes :  
1. **Sprint Planning** : sélection des tâches prioritaires à réaliser.  
2. **Développement** : implémentation des fonctionnalités par les développeurs.  
3. **Tests et validation** : vérification des fonctionnalités, correction des bugs.  
4. **Sprint Review** : démonstration des fonctionnalités livrées.
5. **Rétrospective** : analyse des points forts et axes d’amélioration (facultatif)

#### 2.3. Phase de tests et validation  
- Tests unitaires et d’intégration pour assurer la robustesse du backend.  
- Tests End-to-End pour valider l’expérience utilisateur.  
- Optimisation des performances et corrections finales avant mise en production.  

#### 2.4. Déploiement et maintenance  
- Mise en production avec CI/CD automatisé.  
- Surveillance des performances et corrections des éventuels bugs post-déploiement sur la prod.
- En cas de bug rencontré faire un hotfix sur la branche main ou relancer un sprint sur le sujet pour colmater la faiblesse du développement sur un sujet particulier  
- Évolutions et améliorations selon les retours utilisateurs.  

