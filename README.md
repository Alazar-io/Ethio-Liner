# EthioLiner

> Ethiopian Intercity Bus Booking & Transportation Platform

EthioLiner is a full-stack intercity bus transportation platform designed around the Ethiopian travel experience.

The project combines a Flutter mobile application with a FastAPI backend and PostgreSQL database to demonstrate modern mobile development, backend engineering, transactional booking, concurrent seat reservation, authentication, QR-based ticketing, offline access, localization, testing, security, and production-oriented software architecture.

The goal is not to build a collection of screens.

> **The goal is to build a realistic software system.**

---

## 📚 Technical Documentation Hub

- [System Architecture (ARCHITECTURE.md)](./ARCHITECTURE.md) — End-to-end system context, Flutter feature-first clean architecture, FastAPI layered service architecture, concurrency seat locking sequence, and HMAC-SHA256 QR security.
- [REST API Specification (API_SPEC.md)](./API_SPEC.md) — Comprehensive OpenAPI/REST documentation for all Auth, Trip, Reservation, and Operator endpoints with request/response schemas.
- [Database Schema (DATABASE_SCHEMA.md)](./DATABASE_SCHEMA.md) — Complete Entity-Relationship (ER) diagram, PostgreSQL tables, enums, indexes, and constraints.
- [Developer Setup & Operations Guide (DEVELOPMENT.md)](./DEVELOPMENT.md) — Complete setup instructions, test suite execution, backend startup, and release APK build steps.

---

# 1. Project Overview

EthioLiner connects passengers with intercity bus operators and provides an end-to-end transportation workflow.

The platform is designed around three roles:

* Passenger
* Operator
* Admin

The initial implementation uses realistic demo data and simulated payment functionality. Real external integrations will only be added when they are actually implemented and verified.

## Passenger Features

* Account registration and login
* Search intercity trips
* Select origin and destination
* Select travel date
* Select number of passengers
* Compare available trips
* Filter and sort search results
* View trip details
* View operator information
* View bus information
* View boarding information
* View amenities
* Select seats
* View server-controlled seat availability
* Enter passenger information
* Review booking summary
* Simulated payment
* Receive digital QR ticket
* View upcoming trips
* View completed trips
* View cancelled trips
* Access tickets offline
* Manage profile
* View booking history
* Receive booking and travel notifications

## Operator Features

* Operator dashboard
* Manage buses
* Configure bus seats
* Manage routes
* Create trips
* Schedule trips
* Set trip prices
* Update trip status
* View bookings
* View passenger manifests
* Search bookings
* Scan passenger QR tickets
* Validate tickets through the backend
* Mark passengers as boarded
* View basic operational and revenue information

---

# 2. Engineering Goals

EthioLiner is intended to demonstrate the ability to design and implement a complete software product.

The project focuses on:

* Flutter application architecture
* Feature-based software organization
* State management
* REST API design
* Backend service architecture
* PostgreSQL database design
* Authentication and authorization
* Transaction-safe booking
* Concurrent seat reservation
* Temporary resource locking
* QR ticket generation and validation
* Offline functionality
* Localization
* Ethiopian calendar support
* Automated testing
* Security
* Error handling
* Reliability
* Performance
* Production-oriented documentation

The project prioritizes correctness and maintainability over unnecessary complexity.

---

# 3. Technology Stack

## Frontend

* Flutter
* Dart
* Riverpod
* GoRouter
* Material 3
* REST/JSON
* Local persistence
* QR generation
* QR scanning
* Localization

## Backend

* Python
* FastAPI
* PostgreSQL
* SQLAlchemy
* Alembic
* Pydantic
* JWT authentication
* Password hashing

## Development

* Git
* GitHub
* Android Studio
* Android SDK
* Flutter SDK
* Antigravity

---

# 4. High-Level Architecture

```text
                         ┌────────────────────────┐
                         │     Flutter Mobile     │
                         │          App           │
                         │                        │
                         │ Passenger              │
                         │ Operator               │
                         └────────────┬───────────┘
                                      │
                                REST / JSON
                                      │
                                      ▼
                         ┌────────────────────────┐
                         │        FastAPI         │
                         │        Backend         │
                         │                        │
                         │ Authentication         │
                         │ Trips                  │
                         │ Bookings               │
                         │ Reservations           │
                         │ Payments               │
                         │ Tickets                │
                         │ Operators              │
                         └────────────┬───────────┘
                                      │
                                  SQLAlchemy
                                      │
                                      ▼
                         ┌────────────────────────┐
                         │      PostgreSQL        │
                         │       Database         │
                         └────────────────────────┘
```

The Flutter application is responsible for presentation, client-side state, navigation, local persistence, and user interaction.

The backend is responsible for all business-critical decisions.

The backend is the source of truth for:

* Seat availability
* Seat reservations
* Prices
* Booking status
* Payment status
* Ticket validity
* Operator permissions
* User authorization
* Reservation expiration

Critical business rules must never depend exclusively on Flutter-side validation.

---

# 5. Flutter Architecture

The Flutter application uses a feature-based architecture.

```text
lib/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   └── widgets/
│
├── config/
│   └── app_config.dart
│
├── routing/
│   └── app_router.dart
│
├── theme/
│   ├── app_theme.dart
│   ├── app_colors.dart
│   └── app_text_styles.dart
│
├── shared/
│   ├── models/
│   ├── widgets/
│   └── providers/
│
└── features/
    ├── auth/
    ├── home/
    ├── search/
    ├── trips/
    ├── booking/
    ├── tickets/
    ├── profile/
    └── operator/
```

Each feature should organize its related:

* UI
* State
* Models
* Providers
* Repositories
* Business logic
* Tests

The project should avoid placing application logic into a single global file or folder.

---

# 6. Backend Architecture

The backend follows a layered structure.

```text
backend/
│
├── app/
│   ├── api/
│   │   ├── routes/
│   │   └── dependencies.py
│   │
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   └── database.py
│   │
│   ├── models/
│   ├── schemas/
│   ├── services/
│   ├── repositories/
│   └── main.py
│
├── alembic/
├── tests/
├── .env.example
├── requirements.txt
└── README.md
```

The backend separates:

```text
API Routes
     ↓
Services / Business Logic
     ↓
Repositories / Database Operations
     ↓
PostgreSQL
```

API routes should remain thin.

Business-critical logic should be implemented in services and enforced by the backend.

---

# 7. Database Design

The initial database model includes:

```text
User
Operator
Bus
BusSeat
Route
Trip
Booking
BookingPassenger
Reservation
Payment
Ticket
```

Relationships:

```text
User
 └── Booking

Operator
 ├── Bus
 ├── Route
 └── Trip

Bus
 └── BusSeat

Route
 └── Trip

Trip
 ├── Bus
 ├── Route
 └── Booking

Booking
 ├── BookingPassenger
 ├── Reservation
 ├── Payment
 └── Ticket
```

The schema may evolve as implementation progresses.

Database structure changes must be managed through Alembic migrations rather than manual production database modifications.

---

# 8. Core Passenger Journey

The primary passenger experience is:

```text
Open App
    ↓
Search Trip
    ↓
Search Results
    ↓
Trip Details
    ↓
Select Seats
    ↓
Passenger Details
    ↓
Booking Summary
    ↓
Payment
    ↓
Booking Confirmation
    ↓
Digital QR Ticket
    ↓
My Trips
    ↓
Board Bus
```

The final system extends this flow with backend validation and operator boarding.

---

# 9. Transaction-Safe Seat Reservation

Seat reservation is one of the central engineering features of EthioLiner.

The system should not simply display a seat as available and assume that it remains available.

The backend must protect against concurrent booking attempts.

## Reservation Flow

```text
Passenger selects seat
        ↓
Flutter sends reservation request
        ↓
Backend validates request
        ↓
Database transaction
        ↓
Availability checked
        ↓
Seat temporarily reserved
        ↓
Reservation expiration time created
        ↓
Flutter displays countdown
        ↓
Passenger completes payment
        ↓
Booking confirmed
        ↓
Reservation converted to confirmed booking
```

If the reservation expires:

```text
Reservation expires
        ↓
Seat released
        ↓
Seat becomes available
```

The backend must prevent two users from successfully booking the same seat.

Concurrent booking scenarios should be covered by automated tests.

This feature is intentionally included as a demonstration of transactional consistency and concurrent resource management.

---

# 10. Authentication & Authorization

The authentication system uses:

* Registration
* Password hashing
* Login
* JWT access tokens
* Current-user endpoint
* Session handling
* Role-based authorization

Roles:

```text
PASSENGER
OPERATOR
ADMIN
```

Authorization is enforced by the backend.

Flutter route protection improves the user experience but is not considered a security boundary.

---

# 11. QR Ticket System

After successful booking, the passenger receives a digital ticket.

A ticket can display:

```text
Booking Reference
Passenger Name
Origin
Destination
Travel Date
Departure Time
Operator
Bus
Seat Number
Ticket Status
QR Code
```

The QR code should contain a secure ticket/reference identifier rather than unnecessary sensitive passenger information.

The operator scans the QR code and sends the ticket identifier to the backend.

The backend validates the ticket.

Possible ticket states:

```text
VALID
ALREADY_BOARDED
CANCELLED
EXPIRED
INVALID
```

The backend remains the source of truth.

---

# 12. Payment System

The first implementation uses a simulated payment system.

Payment states:

```text
PROCESSING
SUCCESS
FAILED
CANCELLED
```

The application must clearly distinguish simulated payment functionality from real payment infrastructure.

The project must not claim to integrate with a real Ethiopian payment provider unless that integration has actually been implemented and verified.

Future payment integrations may be added once their technical and business requirements are defined.

---

# 13. Ethiopian Context

EthioLiner is designed specifically around the Ethiopian transportation context.

## Languages

The application is intended to support:

* English
* Amharic
* Afaan Oromo

## Ethiopian Locations

Example demo locations include:

* Addis Ababa
* Adama
* Hawassa
* Bahir Dar
* Gondar
* Mekelle
* Dire Dawa
* Jimma
* Dessie
* Bishoftu

Demo data must be clearly identified as demo data unless supported by verified real-world information.

## Ethiopian Calendar

The application should support Ethiopian calendar functionality where appropriate, particularly for user-facing travel date selection.

The backend may continue to use Gregorian/ISO date representations internally where technically appropriate.

---

# 14. Offline Functionality

The application should preserve important information when connectivity is temporarily unavailable.

Priority offline functionality includes:

* Previously accessed tickets
* QR tickets
* Recent searches
* Basic booking information
* User preferences

Offline behavior must remain honest.

The application must never indicate that a booking, payment, cancellation, or reservation was successfully processed unless the backend has confirmed it.

---

# 15. Reliability & Error Handling

The application should explicitly handle:

* No internet connection
* API timeout
* Server errors
* Invalid credentials
* Expired authentication
* Invalid input
* Seat no longer available
* Reservation expiration
* Payment failure
* Booking failure
* Invalid QR ticket
* Cancelled ticket
* Empty search results

Important asynchronous operations should expose:

```text
Loading
Success
Error
Empty
```

The application should avoid silently failing or displaying misleading success states.

---

# 16. Development Roadmap

The project is divided into **8 major development phases**.

The number of phases is intentionally reduced without reducing the technical scope.

---

## Phase 1 — Foundation & Application Architecture

Establish the complete development foundation.

### Flutter

* Flutter/Dart setup
* Project creation
* Material 3
* Riverpod
* GoRouter
* Feature-based structure
* Core utilities
* Shared widgets
* Theme system
* Configuration
* Initial application shell
* Navigation
* Splash screen
* Onboarding

### Development

* Git repository
* `.gitignore`
* Development conventions
* Antigravity workflow
* Initial documentation

### Quality

```bash
flutter analyze
flutter test
flutter run
```

### Result

A clean, maintainable Flutter foundation ready for feature development.

---

# Phase 2 — Passenger Experience & Trip Discovery

Build the complete passenger trip-discovery experience.

### Home

* Origin selection
* Destination selection
* Travel date
* Passenger count
* Ethiopian city data
* Popular destinations
* Recent searches

### Search

* Search validation
* Mock trip data
* Search results
* Sorting
* Filtering
* Available seats
* Price
* Departure
* Arrival
* Duration

### Trip Details

* Operator information
* Bus information
* Boarding points
* Amenities
* Route information
* Trip status

### UI States

* Loading
* Empty
* Error
* Success

### Result

```text
Home
  ↓
Search
  ↓
Results
  ↓
Trip Details
```

The passenger can discover and evaluate trips using realistic data.

---

# Phase 3 — Booking Experience, Seats & Digital Tickets

Build the complete passenger booking experience.

## Seat Selection

* Data-driven seat map
* Bus layouts
* Available seats
* Selected seats
* Occupied seats
* Unavailable seats
* Seat legend
* Passenger-count restrictions
* Selected seat summary
* Price calculation

## Passenger Information

* Passenger names
* Ethiopian phone validation
* Email validation
* Multiple passengers
* Passenger details

## Booking Summary

Display:

* Route
* Date
* Operator
* Bus
* Seats
* Passengers
* Price

Allow users to return and edit previous steps.

## Payment

Implement simulated:

```text
PROCESSING
SUCCESS
FAILED
CANCELLED
```

## Tickets

Generate:

* Booking reference
* Digital ticket
* QR code
* Ticket information
* Ticket status

## My Trips

* Upcoming
* Completed
* Cancelled

## Local Storage

Persist:

* Tickets
* Recent searches
* Preferences

Support offline ticket viewing.

## Testing

Add tests for:

* Seat selection
* Passenger validation
* Price calculation
* Booking state
* Ticket generation

### Result

A complete passenger-side MVP exists before the backend is introduced.

```text
Search
  ↓
Trip
  ↓
Seats
  ↓
Passenger Details
  ↓
Summary
  ↓
Payment
  ↓
QR Ticket
  ↓
My Trips
```

---

# Phase 4 — FastAPI, PostgreSQL & Authentication

Introduce the production-oriented backend.

## Backend Foundation

Implement:

* FastAPI
* PostgreSQL
* SQLAlchemy
* Alembic
* Pydantic
* Configuration
* Environment variables
* Database connection
* Migration system
* Health endpoint
* API error handling

## Database

Implement the initial entities:

```text
User
Operator
Bus
BusSeat
Route
Trip
Booking
BookingPassenger
Reservation
Payment
Ticket
```

## Authentication

Implement:

* Registration
* Password hashing
* Login
* JWT
* Current-user endpoint
* Logout/session handling
* Role-based authorization

## Flutter Integration

Implement:

* API client
* Authentication state
* Secure token storage
* Protected routes
* Repository layer
* Network models
* Error mapping
* Timeout handling

### Result

```text
Flutter
   ↓
REST API
   ↓
FastAPI
   ↓
PostgreSQL
```

The application begins transitioning from mock/local behavior to real backend functionality.

---

# Phase 5 — Real Booking, Transactions & Concurrent Seat Locking

Replace the simulated booking logic with the real server-side booking system.

## Implement

* Real trip search
* Real trip details
* Real seat availability
* Temporary reservations
* Reservation expiration
* Countdown
* Transaction-safe seat locking
* Payment state management
* Booking confirmation
* Reservation release
* Booking history

## Concurrency

The system must handle scenarios such as:

```text
User A → attempts Seat 12
User B → attempts Seat 12
              ↓
           Backend
              ↓
      Database transaction
              ↓
      Only one reservation succeeds
```

## Expiration

```text
Reservation created
        ↓
Countdown
        ↓
Payment not completed
        ↓
Reservation expires
        ↓
Seat released
```

## Testing

Test:

* Double booking attempts
* Concurrent reservations
* Expired reservations
* Payment failures
* Booking failures
* Invalid reservation state
* Seat conflicts

### Result

EthioLiner becomes a transactional booking system rather than a UI simulation.

This phase is one of the core technical demonstrations of the project.

---

# Phase 6 — Operator Platform & QR Boarding

Build the operator side of the transportation platform.

## Operator Dashboard

Display:

* Scheduled trips
* Active bookings
* Passenger counts
* Basic revenue information
* Trip status

## Bus Management

* Create buses
* Edit buses
* Configure seats
* Seat layout management

## Route Management

* Create routes
* Origin
* Destination
* Boarding points
* Route information

## Trip Management

* Create trips
* Schedule departure
* Assign bus
* Assign route
* Set price
* Update status

## Booking Management

* View bookings
* Search bookings
* Passenger manifests
* Booking details

## QR Boarding

```text
Scan QR
   ↓
Extract ticket identifier
   ↓
Send to backend
   ↓
Validate ticket
   ↓
Display result
   ↓
Mark passenger as boarded
```

Handle:

```text
VALID
ALREADY_BOARDED
CANCELLED
EXPIRED
INVALID
```

## Security

Operator permissions must be enforced by the backend.

### Result

The project now supports both sides of the transportation workflow:

```text
Passenger
   ↓
Booking
   ↓
QR Ticket
   ↓
Operator
   ↓
QR Scan
   ↓
Backend Validation
   ↓
Boarding
```

---

# Phase 7 — Localization, Offline Reliability, Security & Quality

Add the features that make the application more production-oriented.

## Localization

Support:

* English
* Amharic
* Afaan Oromo

Avoid hardcoding user-facing strings throughout the application.

## Ethiopian Calendar

Add Ethiopian calendar support where appropriate for user-facing date selection and presentation.

## Offline

Improve:

* Offline tickets
* Cached booking information
* Recent searches
* Preferences
* Network recovery

## Reliability

Handle:

* Network loss
* API timeouts
* Session expiration
* Seat conflicts
* Reservation expiration
* Booking failures
* Payment failures
* Server errors

## Security Review

Review:

* Password storage
* JWT handling
* Token storage
* Authorization
* Input validation
* API permissions
* Secret management
* QR ticket security
* Payment state handling
* Sensitive information exposure

## Testing

### Flutter

* Unit tests
* Widget tests
* Repository tests
* State-management tests
* Seat selection tests
* Booking tests
* Ticket tests

### Backend

* Authentication tests
* Authorization tests
* API tests
* Booking tests
* Reservation tests
* Concurrent booking tests
* QR validation tests
* Operator tests

## Performance

Review:

* Widget rebuilds
* Network requests
* Large lists
* Image loading
* Memory usage
* API response performance
* Database query performance

---

# Phase 8 — Product Polish, Documentation & Release

Perform the final engineering and product pass.

## UI/UX

Review:

* Typography
* Spacing
* Alignment
* Navigation
* Touch targets
* Accessibility
* Loading states
* Error states
* Empty states
* Animations
* Responsive layouts
* Visual consistency

Animations should be purposeful rather than decorative.

## Documentation

Prepare:

```text
README.md
ARCHITECTURE.md
API_SPEC.md
DATABASE_SCHEMA.md
DEVELOPMENT.md
```

Documentation should explain:

* Product architecture
* Flutter architecture
* Backend architecture
* Database design
* API structure
* Authentication
* Booking flow
* Seat locking
* QR ticket validation
* Testing strategy
* Security decisions
* Offline strategy
* Setup instructions
* Demo instructions
* Known limitations
* Future improvements

## GitHub

Repository should contain:

* Clean source structure
* Meaningful commits
* Documentation
* Screenshots
* Architecture diagrams
* Setup instructions
* Testing instructions
* Demo information

Never commit:

* Passwords
* API keys
* JWT secrets
* Database credentials
* Private certificates
* Secret `.env` files

## Release

Build a release APK:

```bash
flutter build apk --release
```

The exact build and configuration process should be documented in the project.

---

# 17. Development Milestones

Although there are eight development phases, the project has three major milestones.

## Milestone 1 — Passenger MVP

Phases 1–3:

```text
Flutter Foundation
       ↓
Trip Search
       ↓
Trip Details
       ↓
Seat Selection
       ↓
Passenger Details
       ↓
Simulated Payment
       ↓
QR Ticket
       ↓
My Trips
```

This provides a complete passenger booking experience.

---

## Milestone 2 — Full-Stack Transportation System

Phases 4–6:

```text
Flutter
   +
FastAPI
   +
PostgreSQL
   +
Authentication
   +
Real API
   +
Transactional Booking
   +
Seat Locking
   +
Operator Dashboard
   +
QR Boarding
```

This is the core engineering version of EthioLiner.

---

## Milestone 3 — Professional Release

Phases 7–8:

```text
Localization
     +
Offline
     +
Reliability
     +
Security
     +
Testing
     +
Performance
     +
UI/UX Polish
     +
Documentation
     +
Release APK
```

---

# 18. Development Principles

## Build a Real System

Do not build isolated screens just to make the application look complete.

Features should connect to actual application flows.

## Backend Is the Source of Truth

Flutter must not make critical decisions about:

* Seat availability
* Booking validity
* Payment confirmation
* Ticket validity
* Operator authorization

## Keep Business Logic Separate

Bad:

```text
Flutter decides:

"Seat 12 is available."
```

Good:

```text
Flutter requests:

"Reserve Seat 12."

Backend decides:

"Seat 12 is available and has been reserved."
```

## Strong Typing

Prefer:

* Typed models
* Enums
* Immutable state where appropriate
* Explicit interfaces
* Repository contracts

Avoid unnecessary use of:

```dart
dynamic
Map<String, dynamic>
```

throughout the application.

## Important States

Important asynchronous operations should support:

```text
Loading
Success
Error
Empty
```

## Testing

Critical logic must be testable.

Especially:

* Seat selection
* Booking
* Reservation expiration
* Authentication
* Authorization
* QR validation
* Concurrent booking

## No Fake Integrations

Demo functionality must be explicitly treated as demo functionality.

Do not claim:

* Real payment integration
* Real operator integration
* Real-time bus tracking
* Real transportation infrastructure

unless it actually exists in the implementation.

## Protect Secrets

Secrets belong in environment/configuration systems and must never be committed to Git.

---

# 19. Antigravity Development Workflow

Antigravity is the primary development environment for the project.

The development process is:

```text
Understand requirement
        ↓
Inspect existing project
        ↓
Plan implementation
        ↓
Implement current phase
        ↓
Format code
        ↓
Run analyzer
        ↓
Run tests
        ↓
Run application
        ↓
Inspect result
        ↓
Fix problems
        ↓
Summarize changes
        ↓
Wait for next phase
```

The project should not jump ahead to future phases.

If a future feature requires a minimal abstraction, create only the necessary abstraction without implementing the future feature prematurely.

Major architectural changes should be explained before implementation.

---

# 20. Flutter Quality Checks

After meaningful Flutter changes:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Run the application:

```bash
flutter run
```

Check connected devices:

```bash
flutter devices
```

Check Flutter installation:

```bash
flutter doctor
```

Accept Android licenses when required:

```bash
flutter doctor --android-licenses
```

---

# 21. Backend Quality Checks

The backend should eventually include:

```bash
pytest
```

along with appropriate formatting and linting tools.

Database migrations should be tested before being considered complete.

---

# 22. Git Workflow

Use Git throughout development.

Recommended branches:

```text
main
 │
 ├── feature/trip-search
 ├── feature/seat-selection
 ├── feature/booking
 ├── feature/authentication
 ├── feature/operator-dashboard
 └── ...
```

Commits should describe actual changes.

Examples:

```text
feat: add trip search screen
feat: implement data-driven seat selection
feat: add JWT authentication
feat: connect trip search to API
feat: implement temporary seat reservations
test: add concurrent booking tests
fix: release expired reservations
docs: update architecture documentation
```

Do not create fake commits or manipulate commit dates to make the project appear older.

---

# 23. Environment Setup

Required:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git
* Antigravity

Optional:

* Physical Android device
* Android emulator
* Chrome for Flutter Web development

Verify the environment:

```bash
flutter doctor
```

Accept Android licenses:

```bash
flutter doctor --android-licenses
```

Check available devices:

```bash
flutter devices
```

---

# 24. Configuration & Secrets

Environment-specific values must not be hardcoded.

Examples:

```text
API_BASE_URL
DATABASE_URL
JWT_SECRET
JWT_EXPIRATION
```

Local development may use:

```text
.env
```

Provide:

```text
.env.example
```

with placeholder values.

Never commit a real `.env` file containing secrets.

---

# 25. Future Improvements

Potential future features include:

* Real Ethiopian payment integrations
* Real operator integrations
* Live bus tracking
* GPS-based boarding
* Multiple boarding points
* Dynamic pricing
* Seat preference recommendations
* Trip reminders
* Push notifications
* Refund management
* Advanced operator analytics
* Revenue dashboards
* Customer support
* Loyalty/rewards
* Promotional codes
* Corporate travel
* Advanced search
* Route maps
* Multi-city journeys

These features should only be implemented when their technical, operational, and business requirements are clearly defined.

---

# 26. Portfolio & Recruiter Focus

EthioLiner is intentionally designed to demonstrate more than Flutter UI development.

## Flutter Engineering

The project demonstrates:

* Feature-based architecture
* Riverpod state management
* GoRouter navigation
* Reusable components
* Strong typing
* Repository patterns
* Responsive UI
* Local persistence
* Offline functionality
* Localization
* Automated testing

## Backend Engineering

The project demonstrates:

* FastAPI
* REST API design
* PostgreSQL
* SQLAlchemy
* Alembic
* Pydantic
* JWT authentication
* Role-based authorization
* Layered architecture
* Database transactions

## Concurrency & Distributed Logic

The seat reservation system demonstrates:

* Temporary resource locking
* Transactional consistency
* Concurrent request handling
* Reservation expiration
* Conflict handling
* Server-side source-of-truth design

## Security

The project demonstrates:

* Secure password handling
* JWT authentication
* Authorization
* Input validation
* Secret management
* Backend business-rule enforcement
* Secure ticket validation
* Controlled exposure of passenger information

## Reliability

The project demonstrates:

* Network failure handling
* Offline tickets
* Reservation expiration
* Payment failure handling
* Seat conflicts
* API error handling
* Session expiration
* Explicit asynchronous states

## Software Engineering

The project demonstrates:

* Architecture
* Requirements-driven development
* Database design
* API design
* Testing
* Git workflows
* Documentation
* Maintainability
* Release preparation

---

# 27. Project Status

Development is incremental.

Current status:

```text
Current Phase: 1
Status: Foundation / Environment Setup
```

Completed:

* Project concept
* Product scope
* Passenger requirements
* Operator requirements
* Technical architecture
* Database entity definition
* Development roadmap

Next:

* Complete Flutter environment setup
* Create initial Flutter project
* Configure Riverpod
* Configure GoRouter
* Establish Material 3 theme
* Establish project architecture
* Build initial application shell
* Add initial tests
* Verify the development environment

This section should be updated as development progresses.

---

# 28. Final Product Vision

The final EthioLiner system connects the complete passenger and operator workflows.

```text
                         ETHIOLINER
                              │
            ┌─────────────────┴─────────────────┐
            │                                   │
        PASSENGER                           OPERATOR
            │                                   │
            ├── Search trips                   ├── Manage buses
            ├── Compare trips                  ├── Configure seats
            ├── Select seats                   ├── Manage routes
            ├── Enter details                  ├── Schedule trips
            ├── Reserve seats                  ├── Set prices
            ├── Pay                            ├── Manage bookings
            ├── Receive QR ticket              ├── View manifests
            ├── View trips                     ├── Scan QR tickets
            └── Board bus                      └── Validate boarding
                    │                           │
                    └────────────┬──────────────┘
                                 │
                                 ▼
                         FastAPI Backend
                                 │
                                 ▼
                            PostgreSQL
```

The backend coordinates the critical business operations between passengers and operators.

The final application should feel like a realistic transportation product while remaining:

* Technically understandable
* Maintainable
* Testable
* Secure
* Reliable
* Honest about simulated functionality
* Suitable for portfolio demonstration

---

# 29. License

Add the chosen project license before public release.

For example:

```text
MIT License
```

if the project is eventually released under MIT.

---

# 30. Project Principle

> **Build EthioLiner as a real software system, not just a collection of screens.**

Every major feature should answer three questions:

1. Does it provide real user value?
2. Is it implemented with a maintainable architecture?
3. Can its behavior be tested and explained?

The project should prioritize:

```text
Correctness
    +
Clarity
    +
Reliability
    +
Security
    +
Maintainability
    +
Realistic Engineering
```

over unnecessary complexity.

The goal is not to make EthioLiner artificially large.

The goal is to make it **technically credible, complete, and impressive enough that an engineer reviewing the repository can understand the decisions behind the system.**

## Git Commit Policy

Git commits must be organized around completed development phases or meaningful completed units of work.

Before creating a commit:

1. Inspect `git status`.
2. Inspect the relevant `git diff`.
3. Run the appropriate quality checks.
4. Confirm that the implementation belongs to the current phase.
5. Do not include unrelated changes.
6. Do not commit secrets, `.env` files, credentials, generated sensitive files, or private keys.
7. Create a meaningful commit message describing the actual work.
8. Never fabricate commit history or manipulate commit dates.

For a completed phase, use a phase-level commit when the phase represents one coherent deliverable.

Example:

```bash
git status
git diff
flutter analyze
flutter test
git add .
git commit -m "feat: establish Flutter application foundation"
```

Suggested phase commits:

Phase 1:

```text
feat: establish Flutter application foundation
```

Phase 2:

```text
feat: implement passenger trip discovery
```

Phase 3:

```text
feat: implement passenger booking and digital tickets
```

Phase 4:

```text
feat: integrate FastAPI PostgreSQL and authentication
```

Phase 5:

```text
feat: implement transactional seat reservations
```

Phase 6:

```text
feat: implement operator platform and QR boarding
```

Phase 7:

```text
feat: improve localization reliability security and quality
```

Phase 8:

```text
chore: prepare EthioLiner for release
```

Do not automatically commit unfinished work merely because the development agent has stopped working.

A phase should only be committed when its implementation and required quality checks are complete.

After committing, report:

* Commit hash
* Commit message
* Files/areas changed
* Tests run
* Analyzer result
* Whether the phase is complete
* Any remaining known issues

Do not push to a remote repository unless explicitly instructed by the user.
