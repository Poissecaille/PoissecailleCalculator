### Calculatrice NPI
---

### Technologies et outils choisis  

| Domaine          | Technologies / Outils                  |
| ---------------- | -------------------------------------- |
| Backend          | Python, FastAPI, SQLite                |
| Frontend         | React, TypeScript, lucide-react, Axios |
| API              | FastAPI                                |
| Tests            | Pytest (backend)                       |
| Conteneurisation | Docker, Docker Compose                 |

---

### Installation et configuration
## BACKEND

1. **Prérequis**
   - Python 3.12 ou supérieur
   - pip (gestionnaire de paquets Python)
   - virtualenv (optionnel mais recommandé)

2. **Création et activation de l'environnement virtuel**
   - powershell
```powershell
   python -m venv venv
   .\venv\Scripts\activate
   ```
   - bash
```bash
   python -m venv venv
   source venv/bin/activate
   ```
3. **Installation des dépendances**
```bash
   pip install -r requirements.txt
   ```
4. **Lancement du serveur FastAPI**
```bash
   fastapi dev main.py
   ```
5. **Tests unitaires**
- Configurer une variable d'env à True pour les tests
```bash
   $env:TESTING="true"; pytest tests/ -v
   ```
6. **Documentation de l'API**
**Swagger UI**
   - http://localhost:8000/docs

## FRONTEND
- **Prérequis**
   - Node.js
   - npm (gestionnaire de paquets Node.js)
- **Installation des dépendances**
```bash
   npm install
   ```
- **Lancement du serveur de développement**
```bash
   npm start
   ```
## DOCKER
- **Prérequis**
   - Docker
   - Docker Compose is located at the root of the project
- **Création des images et conteneurs**
- **Lancement des services**
```bash
   docker-compose up --build
   ```