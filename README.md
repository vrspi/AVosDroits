# À Vos Droits

Une application mobile pour comprendre et faire valoir vos droits.

## Description

À Vos Droits est une application Flutter qui vise à rendre l'accès au droit plus simple et plus accessible pour tous. Elle propose plusieurs fonctionnalités :

- 📝 Questionnaire interactif pour découvrir vos droits
- 📚 Base de données des droits
- 📄 Générateur de courriers administratifs
- 🗺️ Localisation des services juridiques
- 💬 Consultation avec des experts
- 🗄️ Coffre-fort numérique pour vos documents

## Installation

1. Assurez-vous d'avoir Flutter installé sur votre machine
2. Clonez ce dépôt :
   ```bash
   git clone https://github.com/vrspi/AVosDroits.git
   ```
3. Naviguez vers le répertoire du projet :
   ```bash
   cd AVosDroits
   ```
4. Installez les dépendances :
   ```bash
   flutter pub get
   ```
5. Lancez l'application :
   ```bash
   flutter run
   ```

## Technologies Utilisées

- Flutter
- Dart
- Material Design

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

## License

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

# A Vos Droits - Docker Setup

## Prerequisites

- Docker Engine installed
- Docker Compose installed
- Git installed

## Quick Start

1. Clone the repository:
```bash
git clone [repository-url]
cd AVosDroits
```

2. Build and run the containers:
```bash
docker-compose up --build
```

The following services will be available:
- Frontend: http://localhost:8080
- Backend API: https://localhost:7076
- SQL Server: localhost,1433

## Services

### Database (SQL Server)
- Port: 1433
- Default credentials:
  - Username: sa
  - Password: YourStrong!Passw0rd
- Database name: AVosDroitsDb

### Backend API (.NET)
- HTTPS Port: 7076
- HTTP Port: 5005
- Swagger UI: https://localhost:7076/swagger
- Health check: https://localhost:7076/health

### Frontend (Flutter Web)
- Port: 8080
- Served using Nginx
- Automatically proxies API requests to the backend

## Development Workflow

### Viewing Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs api
docker-compose logs frontend
docker-compose logs db
```

### Rebuilding Services
```bash
# Rebuild all services
docker-compose up --build

# Rebuild specific service
docker-compose up --build api
```

### Database Management
```bash
# Connect to database using SQL Server Management Studio
Server: localhost,1433
Authentication: SQL Server Authentication
Username: sa
Password: YourStrong!Passw0rd
```

### Stopping Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (will delete database data)
docker-compose down -v
```

## Troubleshooting

### Common Issues

1. Port Conflicts
```bash
# Check if ports are already in use
netstat -ano | findstr "1433"
netstat -ano | findstr "7076"
netstat -ano | findstr "8080"
```

2. Database Connection Issues
```bash
# Check database logs
docker-compose logs db

# Check if database is healthy
docker-compose ps
```

3. SSL Certificate Issues
```bash
# Regenerate certificates
docker-compose exec api dotnet dev-certs https --clean
docker-compose exec api dotnet dev-certs https --trust
```

### Data Persistence

- Database data is persisted in the `sqlserver_data` volume
- Uploaded files are persisted in the `api_data` volume

To reset all data:
```bash
docker-compose down -v
docker-compose up --build
```

## Environment Variables

### Backend API
- `ASPNETCORE_ENVIRONMENT`: Development/Production
- `ConnectionStrings__DefaultConnection`: Database connection string

### Frontend
- `API_URL`: Backend API URL

### Database
- `ACCEPT_EULA`: Y
- `SA_PASSWORD`: Database password

## Security Notes

1. For production:
   - Change default database password
   - Configure proper SSL certificates
   - Review and adjust CORS policies
   - Implement proper secrets management

2. Development certificates:
   - Self-signed certificates are used for development
   - Accept the development certificate in your browser
   - For production, use proper SSL certificates 