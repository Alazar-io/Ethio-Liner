# EthioLiner — REST API Specification

**Base URL**: `http://localhost:8000/api/v1`  
**Interactive Swagger UI**: `http://localhost:8000/docs`  
**ReDoc Documentation**: `http://localhost:8000/redoc`  
**Format**: JSON (`Content-Type: application/json`)  
**Authentication**: HTTP Bearer Token (`Authorization: Bearer <jwt_access_token>`)

---

## 1. Authentication Endpoints

### 1.1 Register Passenger / User
Create a new user account. Defaults to the `PASSENGER` role.

- **Method**: `POST`
- **Path**: `/auth/register`
- **Auth**: None

#### Request Body
```json
{
  "email": "alazar@example.com",
  "password": "Password123!",
  "full_name": "Alazar Tekle",
  "phone_number": "+251911223344",
  "role": "PASSENGER"
}
```

#### Response: `201 Created`
```json
{
  "id": 1,
  "email": "alazar@example.com",
  "full_name": "Alazar Tekle",
  "phone_number": "+251911223344",
  "role": "PASSENGER",
  "is_active": true
}
```

---

### 1.2 User Login
Authenticate user and obtain a cryptographically signed JWT access token.

- **Method**: `POST`
- **Path**: `/auth/login`
- **Auth**: None

#### Request Body
```json
{
  "email": "alazar@example.com",
  "password": "Password123!"
}
```

#### Response: `200 OK`
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "alazar@example.com",
    "full_name": "Alazar Tekle",
    "phone_number": "+251911223344",
    "role": "PASSENGER",
    "operator_id": null
  }
}
```

---

### 1.3 Get Current User Profile
Retrieve authenticated user profile and roles.

- **Method**: `GET`
- **Path**: `/auth/me`
- **Auth**: Bearer Token

#### Response: `200 OK`
```json
{
  "id": 1,
  "email": "alazar@example.com",
  "full_name": "Alazar Tekle",
  "phone_number": "+251911223344",
  "role": "PASSENGER",
  "operator_id": null
}
```

---

## 2. Trip Discovery Endpoints

### 2.1 Search Trips
Search scheduled intercity bus trips with filtering and pagination.

- **Method**: `GET`
- **Path**: `/trips`
- **Auth**: None
- **Query Parameters**:
  - `origin` *(optional, string)*: Origin city (e.g. `Addis Ababa`)
  - `destination` *(optional, string)*: Destination city (e.g. `Bahir Dar`)
  - `departure_date` *(optional, string)*: ISO Date `YYYY-MM-DD`
  - `page` *(optional, int, default: 1)*: Page number
  - `page_size` *(optional, int, default: 20)*: Items per page

#### Response: `200 OK`
```json
{
  "total": 1,
  "page": 1,
  "page_size": 20,
  "items": [
    {
      "id": 1,
      "route": {
        "id": 1,
        "origin_city": "Addis Ababa",
        "destination_city": "Bahir Dar",
        "departure_terminal": "Autobus Tera",
        "arrival_terminal": "Bahir Dar Central Station",
        "distance_km": 565.0,
        "estimated_duration_minutes": 570
      },
      "bus": {
        "id": 1,
        "operator_name": "Selam Bus",
        "plate_number": "ET-3-48102",
        "bus_model": "Scania Touring HD",
        "amenities": "WiFi, AC, USB Charger, Water",
        "total_seats": 49
      },
      "departure_time": "2026-10-15T06:00:00",
      "arrival_time": "2026-10-15T15:30:00",
      "price_etb": 1250.0,
      "available_seats": 45,
      "status": "SCHEDULED"
    }
  ]
}
```

---

### 2.2 Get Trip Details
Retrieve comprehensive information for a single trip.

- **Method**: `GET`
- **Path**: `/trips/{trip_id}`
- **Auth**: None

#### Response: `200 OK`
```json
{
  "id": 1,
  "route": {
    "origin_city": "Addis Ababa",
    "destination_city": "Bahir Dar",
    "departure_terminal": "Autobus Tera",
    "arrival_terminal": "Bahir Dar Central Station",
    "distance_km": 565.0,
    "estimated_duration_minutes": 570
  },
  "bus": {
    "operator_name": "Selam Bus",
    "plate_number": "ET-3-48102",
    "bus_model": "Scania Touring HD",
    "amenities": "WiFi, AC, USB Charger, Water"
  },
  "departure_time": "2026-10-15T06:00:00",
  "arrival_time": "2026-10-15T15:30:00",
  "price_etb": 1250.0,
  "available_seats": 45,
  "status": "SCHEDULED"
}
```

---

## 3. Seat Reservation & Booking Endpoints

### 3.1 Get Trip Seat Map
Fetches the complete seat matrix for a trip, including real-time seat lock and booking availability.

- **Method**: `GET`
- **Path**: `/trips/{trip_id}/seats`
- **Auth**: None

#### Response: `200 OK`
```json
{
  "trip_id": 1,
  "bus_model": "Scania Touring HD",
  "total_seats": 49,
  "seats": [
    {
      "seat_number": "1A",
      "row": 1,
      "column": 1,
      "status": "BOOKED",
      "is_mine": false
    },
    {
      "seat_number": "1B",
      "row": 1,
      "column": 2,
      "status": "LOCKED",
      "is_mine": false
    },
    {
      "seat_number": "2A",
      "row": 2,
      "column": 1,
      "status": "AVAILABLE",
      "is_mine": false
    }
  ]
}
```

---

### 3.2 Reserve Seats (Seat Lock)
Locks one or more seats for 10 minutes to allow the user to complete passenger details and checkout without race conditions.

- **Method**: `POST`
- **Path**: `/trips/{trip_id}/reserve`
- **Auth**: Bearer Token

#### Request Body
```json
{
  "seat_numbers": ["3A", "3B"]
}
```

#### Response: `200 OK`
```json
{
  "trip_id": 1,
  "user_id": 1,
  "locked_seats": ["3A", "3B"],
  "expires_at": "2026-10-15T06:10:00",
  "ttl_seconds": 600
}
```

#### Error Response: `409 Conflict` (Seat Already Reserved)
```json
{
  "detail": "Seat 3A is currently reserved by another passenger. Please select another seat."
}
```

---

### 3.3 Confirm Booking & Checkout
Atomically converts locked seats into a permanent confirmed booking, processes payment, and issues cryptographically signed digital QR tickets.

- **Method**: `POST`
- **Path**: `/bookings/confirm`
- **Auth**: Bearer Token

#### Request Body
```json
{
  "trip_id": 1,
  "payment_method": "TELEBIRR",
  "passengers": [
    {
      "full_name": "Alazar Tekle",
      "phone_number": "+251911223344",
      "seat_number": "3A"
    },
    {
      "full_name": "Selamawit Haile",
      "phone_number": "+251922334455",
      "seat_number": "3B"
    }
  ]
}
```

#### Response: `201 Created`
```json
{
  "booking_reference": "BK-719482",
  "status": "CONFIRMED",
  "total_price_etb": 2500.0,
  "created_at": "2026-10-15T06:05:00",
  "payment": {
    "transaction_reference": "TXN-829140",
    "payment_method": "TELEBIRR",
    "amount_etb": 2500.0,
    "status": "SUCCESS"
  },
  "tickets": [
    {
      "ticket_reference": "TCK-719482-1",
      "passenger_name": "Alazar Tekle",
      "seat_number": "3A",
      "status": "VALID",
      "qr_code_data": "{\"ticket_reference\":\"TCK-719482-1\",\"trip_id\":1,\"seat\":\"3A\",\"sig\":\"w72_m91X\"}"
    },
    {
      "ticket_reference": "TCK-719482-2",
      "passenger_name": "Selamawit Haile",
      "seat_number": "3B",
      "status": "VALID",
      "qr_code_data": "{\"ticket_reference\":\"TCK-719482-2\",\"trip_id\":1,\"seat\":\"3B\",\"sig\":\"k18_p45Z\"}"
    }
  ]
}
```

---

## 4. Operator Platform & QR Boarding Endpoints

### 4.1 Operator Trips List
Retrieves assigned fleet trips for an operator.

- **Method**: `GET`
- **Path**: `/operator/trips`
- **Auth**: Bearer Token (Role: `OPERATOR` or `ADMIN`)

#### Response: `200 OK`
```json
[
  {
    "id": 1,
    "bus_plate": "ET-3-48102",
    "route_name": "Addis Ababa → Bahir Dar",
    "departure_time": "2026-10-15T06:00:00",
    "total_seats": 49,
    "booked_seats": 42,
    "boarded_count": 35,
    "status": "BOARDING"
  }
]
```

---

### 4.2 Trip Passenger Manifest
Retrieve complete passenger manifest for boarding inspection.

- **Method**: `GET`
- **Path**: `/operator/trips/{trip_id}/manifest`
- **Auth**: Bearer Token (Role: `OPERATOR` or `ADMIN`)

#### Response: `200 OK`
```json
{
  "trip_id": 1,
  "route": "Addis Ababa → Bahir Dar",
  "bus_plate": "ET-3-48102",
  "departure_time": "2026-10-15T06:00:00",
  "total_passengers": 42,
  "boarded_passengers": 35,
  "manifest": [
    {
      "ticket_reference": "TCK-719482-1",
      "passenger_name": "Alazar Tekle",
      "phone_number": "+251911223344",
      "seat_number": "3A",
      "booking_reference": "BK-719482",
      "ticket_status": "VALID",
      "boarded_at": null
    }
  ]
}
```

---

### 4.3 Validate QR Boarding Ticket
Validates the cryptographic HMAC signature and marks the passenger as boarded.

- **Method**: `POST`
- **Path**: `/operator/tickets/validate-qr`
- **Auth**: Bearer Token (Role: `OPERATOR` or `ADMIN`)

#### Request Body
```json
{
  "ticket_reference": "TCK-719482-1",
  "trip_id": 1,
  "seat_number": "3A",
  "signature": "w72_m91X"
}
```

#### Response: `200 OK` (Boarding Successful)
```json
{
  "status": "VALID",
  "message": "Ticket verified successfully. Passenger permitted to board.",
  "ticket_reference": "TCK-719482-1",
  "passenger_name": "Alazar Tekle",
  "seat_number": "3A",
  "boarded_at": "2026-10-15T05:45:12"
}
```

#### Possible Validation Outcomes
| Status | HTTP Code | Meaning / Operator Action |
| :--- | :--- | :--- |
| `VALID` | `200 OK` | Authentic ticket; passenger marked as boarded. Allow entry. |
| `ALREADY_BOARDED`| `400 Bad Request` | Ticket was already scanned and boarded. Deny entry (duplicate attempt). |
| `CANCELLED` | `400 Bad Request` | Ticket has been cancelled or refunded. Deny entry. |
| `EXPIRED` | `400 Bad Request` | Trip departure has elapsed. Deny entry. |
| `INVALID` | `400 Bad Request` | HMAC signature mismatch or counterfeit ticket. Deny entry immediately. |

---

### 4.4 Operator Fleet Analytics
Retrieve fleet performance statistics and revenue overview.

- **Method**: `GET`
- **Path**: `/operator/analytics`
- **Auth**: Bearer Token (Role: `OPERATOR` or `ADMIN`)

#### Response: `200 OK`
```json
{
  "total_trips": 12,
  "active_trips": 3,
  "total_passengers_transported": 540,
  "fleet_occupancy_rate": 0.88,
  "total_revenue_etb": 675000.0
}
```

---

## 5. Health Check

### 5.1 System Health
Check backend service status and database connectivity.

- **Method**: `GET`
- **Path**: `/health`
- **Auth**: None

#### Response: `200 OK`
```json
{
  "status": "healthy",
  "app": "EthioLiner",
  "version": "1.0.0",
  "database": "connected"
}
```
