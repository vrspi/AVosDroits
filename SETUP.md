# A Vos Droits - Setup Guide

## Project Overview
A Vos Droits is a full-stack application consisting of:
1. Flutter Mobile App (Frontend)
2. ASP.NET Core API (Backend)

## System Requirements

### Development Environment
- Visual Studio Code or Android Studio
- Visual Studio 2022 (for backend development)
- Git for version control
- PowerShell (Windows) or Terminal (macOS/Linux)

### Backend Requirements (.NET API)
- .NET 8.0 SDK
- SQL Server Express or Developer Edition
- Required NuGet Packages:
  - Azure.AI.OpenAI (2.1.0)
  - BCrypt.Net-Next (4.0.3)
  - Microsoft.AspNetCore.Authentication.JwtBearer (8.0.0)
  - Microsoft.EntityFrameworkCore (8.0.0)
  - Microsoft.EntityFrameworkCore.Design (8.0.0)
  - Microsoft.EntityFrameworkCore.SqlServer (8.0.0)
  - Microsoft.EntityFrameworkCore.Tools (8.0.0)
  - Swashbuckle.AspNetCore (6.5.0)
  - System.IdentityModel.Tokens.Jwt (7.0.3)

### Frontend Requirements (Flutter)
- Flutter SDK (>=3.0.6 <4.0.0)
- Dart SDK
- Android Studio with Flutter/Dart plugins
- Required Flutter Dependencies:
  - cupertino_icons: ^1.0.2
  - google_fonts: ^6.1.0
  - http: ^1.1.0
  - provider: ^6.1.1
  - shared_preferences: ^2.2.2
  - flutter_markdown: ^0.6.18
  - file_picker: ^6.1.1
  - path_provider: ^2.1.2
  - dio: ^5.4.0
  - syncfusion_flutter_pdfviewer: ^28.1.41
  - photo_view: ^0.15.0
  - image_picker: ^1.0.7
  - google_maps_flutter: ^2.5.3
  - geolocator: ^10.1.0

### Mobile Development Requirements
- Android SDK
- Android Emulator or physical device
- For iOS development (macOS only):
  - Xcode
  - iOS Simulator or physical device
  - CocoaPods

## Installation Steps

### 1. Backend Setup

1. Install SQL Server:
```powershell
# Download and install SQL Server Express
# Configure SQL Server to accept TCP/IP connections
# Create a new database named 'AVosDroitsDb'
```

2. Configure the API:
```powershell
# Clone the repository
git clone [repository-url]
cd "A Vos Droit API"

# Restore NuGet packages
dotnet restore

# Update database with migrations
dotnet ef database update

# Run the API
dotnet run
```

The API will be available at:
- HTTPS: https://localhost:7076
- HTTP: http://localhost:5005

### 2. Frontend Setup

1. Install Flutter:
```powershell
# Download Flutter SDK
# Add Flutter to system PATH
flutter doctor -v  # Verify installation
```

2. Configure the app:
```powershell
# Navigate to Flutter project
cd avosdroits

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Required Permissions
The app requires the following permissions:
- Internet access
- Camera access (for document scanning)
- Location services (for nearby services)
- Storage access (for document management)

### 4. Development Certificates
For HTTPS development:
```powershell
# Generate development certificates
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

## Environment Configuration

### Backend (appsettings.json)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=AVosDroitsDb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "YOUR_SECRET_KEY",
    "Issuer": "https://avosdroits.com",
    "Audience": "https://avosdroits.com"
  }
}
```

### Frontend (api_config.dart)
```dart
static String _baseUrl = 'https://localhost:7076/api';
```

## Troubleshooting

### Common Issues
1. SQL Server Connection:
   - Verify SQL Server is running
   - Check connection string
   - Ensure TCP/IP is enabled

2. Flutter Issues:
   - Run `flutter doctor` to diagnose problems
   - Verify Android/iOS setup
   - Check all dependencies are properly installed

3. SSL Certificate Issues:
   - Trust development certificates
   - Configure app to accept self-signed certificates in development

### Development Tools
- Postman for API testing
- SQL Server Management Studio (SSMS)
- Flutter DevTools
- Android Studio Profiler

## Additional Resources
- [Flutter Documentation](https://docs.flutter.dev)
- [.NET Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)
- [SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) 