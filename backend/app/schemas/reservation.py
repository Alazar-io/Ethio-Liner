from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class SeatLockRequest(BaseModel):
    seat_numbers: List[str]


class SeatStatusResponse(BaseModel):
    seat_number: str
    status: str  # available, locked, occupied
    expires_at: Optional[datetime] = None


class TripSeatsResponse(BaseModel):
    trip_id: int
    total_seats: int
    available_seats: int
    seats: List[SeatStatusResponse]


class ReservationResponse(BaseModel):
    trip_id: int
    seat_numbers: List[str]
    expires_at: datetime
    remaining_seconds: int


class PassengerInput(BaseModel):
    full_name: str
    phone_number: str
    assigned_seat: str


class BookingConfirmRequest(BaseModel):
    trip_id: int
    seat_numbers: List[str]
    payment_method: str = "telebirr"
    passengers: List[PassengerInput]


class TicketItemResponse(BaseModel):
    ticket_reference: str
    passenger_name: str
    seat_number: str
    status: str
    qr_code_data: str


class BookingConfirmResponse(BaseModel):
    booking_reference: str
    trip_id: int
    status: str
    total_price_etb: float
    tickets: List[TicketItemResponse]
    created_at: datetime
