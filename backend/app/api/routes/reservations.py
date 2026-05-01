from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.database import get_db
from app.models.entities import User
from app.schemas.reservation import (
    BookingConfirmRequest,
    BookingConfirmResponse,
    ReservationResponse,
    SeatLockRequest,
    TripSeatsResponse,
)
from app.services.reservation_service import ReservationService

router = APIRouter(tags=["Seat Reservations & Bookings"])


@router.get("/trips/{trip_id}/seats", response_model=TripSeatsResponse)
def get_trip_seats(trip_id: int, db: Session = Depends(get_db)):
    """Fetches real-time seat availability including currently locked and booked seats."""
    return ReservationService.get_trip_seat_map(db=db, trip_id=trip_id)


@router.post("/trips/{trip_id}/reserve", response_model=ReservationResponse)
def reserve_seats(
    trip_id: int,
    request: SeatLockRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Locks requested seats for 10 minutes. Returns 409 Conflict if seats are taken."""
    return ReservationService.lock_seats(
        db=db,
        trip_id=trip_id,
        user_id=current_user.id,
        seat_numbers=request.seat_numbers,
    )


@router.post("/bookings/confirm", response_model=BookingConfirmResponse, status_code=status.HTTP_201_CREATED)
def confirm_booking(
    request: BookingConfirmRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Atomically converts locked seats into a permanent confirmed booking with QR tickets."""
    return ReservationService.confirm_booking(
        db=db,
        user_id=current_user.id,
        request=request,
    )
