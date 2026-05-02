# EthioLiner — Developer Setup & Operations Guide

## 1. System Requirements & Prerequisites

To develop, test, or build EthioLiner, ensure your environment meets the following specifications:

- **Flutter SDK**: `^3.19.0` or higher (Flutter 3.47+ recommended)
- **Dart SDK**: `^3.3.0` or higher
- **Python**: `3.10` to `3.12`
- **Database**: PostgreSQL 14+ (or embedded SQLite for local/offline unit testing)
- **Node/Git**: Git 2.40+
- **Platform Toolchains**:
  - Android Studio with Android SDK 34 (for Android builds)
  - Visual Studio 2022 / C++ Build Tools (for Windows desktop builds)
  - Google Chrome (for Flutter Web development)

---

## 2. Quickstart Workspace Setup

### 2.1 Clone Repository
```bash
git clone https://github.com/Alazar-io/Ethio-Liner.git
cd Ethio-Liner
```

### 2.2 Setup Flutter Client
```bash
flutter pub get
```

### 2.3 Setup Python Backend
Create a virtual environment and install backend dependencies:

```bash
# Windows PowerShell
python -m venv backend/venv
.\backend\venv\Scripts\Activate.ps1
pip install -r backend/requirements.txt

# Linux / macOS
python3 -m venv backend/venv
source backend/venv/bin/activate
pip install -r backend/requirements.txt
```

### 2.4 Configure Environment Variables
Copy the backend `.env.example` into `backend/.env`:

```bash
cp backend/.env.example backend/.env
```

Default variables in `backend/.env`:
```ini
APP_NAME=EthioLiner
ENVIRONMENT=development
DATABASE_URL=sqlite:///./ethioliner.db
SECRET_KEY=ethioliner-production-super-secret-key-change-in-prod-2026
ACCESS_TOKEN_EXPIRE_MINUTES=1440
SEAT_LOCK_TTL_SECONDS=600
API_V1_PREFIX=/api/v1
BACKEND_CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://127.0.0.1:8000","*"]
```

---

## 3. Running the Applications

### 3.1 Starting the FastAPI Backend
From the repository root (or within `backend/` directory):

```bash
# Run with automatic reload on port 8000
python -m uvicorn backend.app.main:app --reload --port 8000
```

- **Interactive API Documentation (Swagger)**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Alternative ReDoc UI**: [http://localhost:8000/redoc](http://localhost:8000/redoc)
- **Health Check**: [http://localhost:8000/api/v1/health](http://localhost:8000/api/v1/health)

*Note: Database tables and seed data (Addis Ababa, Hawassa, Bahir Dar, Gondar routes, buses, and operator test accounts) are automatically provisioned on server startup via the application lifespan hook.*

### 3.2 Seeding Test Accounts & Credentials
The default seed generates the following test users:

| Account Type | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Passenger** | `passenger@ethioliner.com` | `Password123!` | `PASSENGER` |
| **Operator** | `operator@selambus.et` | `Password123!` | `OPERATOR` |
| **Administrator** | `admin@ethioliner.com` | `Password123!` | `ADMIN` |

### 3.3 Running the Flutter App

Select your target development device:

```bash
# List available target devices
flutter devices

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows

# Run on connected Android Device or Emulator
flutter run -d android
```

#### Android Emulator Network Configuration
When running on an Android Virtual Device (AVD), `localhost` refers to the Android device itself. Point the API client to the host machine via:
```dart
// For Android Emulator:
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// For Web / Windows / iOS Simulator:
static const String baseUrl = 'http://localhost:8000/api/v1';
```

---

## 4. Verification & Testing Strategy

Before committing or deploying, run the full test suite across both frontend and backend.

### 4.1 Flutter Code Quality & Static Analysis
```bash
# Verify 0 linter issues and 0 warnings
flutter analyze
```

### 4.2 Flutter Unit & Widget Test Suite
```bash
# Run all unit, widget, and state tests
flutter test
```
The test suite covers:
- `test/phase2_test.dart`: Trip discovery, city pickers, sorting, and filter logic.
- `test/phase3_test.dart`: Seat layout generation, checkout simulation, and digital QR ticket emission.
- `test/phase5_test.dart`: Transactional seat locking, countdown timers, and conflict recovery.
- `test/phase6_test.dart`: Operator dashboard, passenger manifest, and QR boarding scanner.
- `test/phase7_test.dart`: Ethiopian calendar conversion, Pagume leap years, tri-lingual localizations (`en`, `am`, `om`), and offline persistence.

### 4.3 Backend Test Suite
```bash
# 1. Unit & cryptographic HMAC verification tests
python backend/tests/test_backend.py

# 2. High-concurrency seat locking & atomic transaction tests
python backend/tests/test_concurrency.py

# 3. Operator platform & QR boarding state machine tests
python backend/tests/test_operator.py
```

---

## 5. Production Release Build Guide

### 5.1 Android Release APK
To build a production release APK:

```bash
# Build standalone release APK
flutter build apk --release

# Build split-per-ABI APKs (smaller file size for arm64-v8a / armeabi-v7a)
flutter build apk --split-per-abi --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### 5.2 Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 5.3 Web Production Build
```bash
flutter build web --release --pwa-strategy offline-first
```
Output: `build/web/`

### 5.4 Windows Desktop Release
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/`

---

## 6. Security & Production Checklist

- [ ] **Secret Keys**: Replace default `SECRET_KEY` in `backend/.env` with a high-entropy string generated via `openssl rand -hex 32`.
- [ ] **Database Connection**: Set `DATABASE_URL` to a high-availability PostgreSQL cluster (`postgresql+psycopg2://user:pass@host:5432/dbname`).
- [ ] **CORS Restrictions**: Explicitly lock down `BACKEND_CORS_ORIGINS` to the exact deployed production domains.
- [ ] **TLS / HTTPS**: Ensure all client-server traffic is terminated via TLS 1.3 reverse proxies (Nginx / Cloudflare).
- [ ] **Android Keystore**: Sign the release APK with an official Android upload key and store keystore credentials securely outside the repository.
