from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class OperatorTripSummary(BaseModel):
    trip_id: int
    route: str
    origin_city: str
    destination_city: str
    bus_model: str
    plate_number: str
    departure_time: datetime
    price_etb: float
    total_seats: int
    booked_seats: int
    boarded_passengers: int
    occupancy_rate: float
    status: str

    class Config:
        from_attributes = True


class OperatorOverviewResponse(BaseModel):
    operator_name: str
    is_verified: bool
    total_buses: int
    total_routes: int
    total_trips: int
    active_trips_today: int
    total_passengers_booked: int
    total_passengers_boarded: int
    occupancy_rate_percent: float
    total_revenue_etb: float
    trips: List[OperatorTripSummary]


class ManifestPassengerResponse(BaseModel):
    ticket_id: str
    passenger_name: str
    phone_number: str
    seat_number: str
    booking_reference: str
    status: str
    boarded_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class TripManifestResponse(BaseModel):
    trip_id: int
    route: str
    origin_city: str
    destination_city: str
    departure_time: datetime
    departure_terminal: str
    arrival_terminal: str
    bus_model: str
    plate_number: str
    total_capacity: int
    total_booked: int
    total_boarded: int
    passengers: List[ManifestPassengerResponse]


class BoardingValidationRequest(BaseModel):
    qr_data: str = Field(..., description="QR payload string or raw ticket reference")
    expected_trip_id: Optional[int] = Field(None, description="Optional trip ID to verify ticket is for this trip")


class BoardingValidationResponse(BaseModel):
    status: str = Field(..., description="VALID, ALREADY_BOARDED, CANCELLED, EXPIRED, INVALID")
    message: str
    can_board: bool
    ticket_id: Optional[str] = None
    passenger_name: Optional[str] = None
    seat_number: Optional[str] = None
    route: Optional[str] = None
    boarded_at: Optional[datetime] = None


class BusCreate(BaseModel):
    plate_number: str
    bus_model: str
    total_seats: int = 48
    amenities: Optional[str] = "WiFi, AC, USB Charger, Water"


class BusResponse(BaseModel):
    id: int
    operator_id: int
    plate_number: str
    bus_model: str
    total_seats: int
    amenities: str

    class Config:
        from_attributes = True


class RouteCreate(BaseModel):
    origin_city: str
    destination_city: str
    departure_terminal: str
    arrival_terminal: str
    distance_km: float
    estimated_duration_minutes: int


class RouteResponse(BaseModel):
    id: int
    operator_id: int
    origin_city: str
    destination_city: str
    departure_terminal: str
    arrival_terminal: str
    distance_km: Optional[float]
    estimated_duration_minutes: int

    class Config:
        from_attributes = True


class TripCreate(BaseModel):
    route_id: int
    bus_id: int
    departure_time: datetime
    arrival_time: datetime
    price_etb: float
    status: Optional[str] = "SCHEDULED"


class TripResponse(BaseModel):
    id: int
    route_id: int
    bus_id: int
    departure_time: datetime
    arrival_time: datetime
    price_etb: float
    available_seats: int
    status: str

    class Config:
        from_attributes = True
