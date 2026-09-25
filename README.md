# EthioLiner

**A full-stack Flutter mobile application for Ethiopian intercity bus booking and transportation management.**

EthioLiner is a transportation platform designed around the intercity bus travel experience in Ethiopia. The application provides passengers with trip discovery, seat selection, booking, digital tickets, and trip management, while providing transport operators with tools for managing trips, buses, bookings, and passenger boarding.

The project is built with **Flutter**, **FastAPI**, and **PostgreSQL**, with a focus on clean architecture, secure backend business logic, transaction-safe booking workflows, and a practical mobile-first user experience.

---

## Features

### Passenger

- Account registration and login
- Ethiopian phone number and email validation
- Search intercity trips
- Select origin and destination
- Select travel date
- Passenger count
- Sort and filter trip results
- View trip details
- View bus operator information
- View route and boarding information
- View available amenities
- Interactive seat selection
- Enter passenger information
- Booking summary
- Simulated payment flow
- Digital tickets
- QR code tickets
- Upcoming trips
- Completed trips
- Cancelled trips
- Profile management
- Local ticket access

### Operator

- Operator dashboard
- Manage buses
- Configure bus seats
- Manage routes
- Schedule trips
- Configure trip pricing
- View trip bookings
- View passenger manifests
- Search bookings
- Scan passenger QR tickets
- Validate tickets
- Mark passengers as boarded

---

## Technology Stack

### Mobile Application

- Flutter
- Dart
- Riverpod
- GoRouter
- Material 3
- REST API
- JSON
- Local persistence
- QR code generation and scanning
- Localization-ready architecture

### Backend

- Python
- FastAPI
- PostgreSQL
- SQLAlchemy
- Alembic
- Pydantic
- JWT authentication
- Password hashing

### Development

- Git
- GitHub
- Android Studio
- Android SDK
- Flutter SDK
- Python
- REST/JSON

---

## Architecture

EthioLiner follows a client-server architecture:

```text
┌─────────────────────────────┐
│       Flutter Mobile App    │
│                             │
│ Passenger     Operator      │
└──────────────┬──────────────┘
               │
               │ REST / JSON
               ▼
┌─────────────────────────────┐
│          FastAPI            │
│                             │
│ API Routes                  │
│ Authentication              │
│ Business Logic              │
│ Authorization               │
│ Booking Services            │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         PostgreSQL          │
│                             │
│ Users                       │
│ Operators                   │
│ Buses                       │
│ Routes                      │
│ Trips                       │
│ Bookings                    │
│ Payments                    │
│ Tickets                     │
└─────────────────────────────┘
