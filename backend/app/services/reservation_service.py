import random
import threading
from datetime import datetime, timedelta, timezone
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.entities import (
    Booking,
    BookingPassenger,
    BookingStatus,
    BusSeat,
    Payment,
    PaymentStatus,
    Reservation,
    ReservationStatus,
    Ticket,
    TicketStatus,
    Trip,
)
from app.schemas.reservation import (
    BookingConfirmRequest,
    BookingConfirmResponse,
    PassengerInput,
    ReservationResponse,
    SeatStatusResponse,
    TicketItemResponse,
    TripSeatsResponse,
)


class ReservationService:
    _lock = threading.Lock()

    @staticmethod
    def clean_expired_reservations(db: Session, trip_id: Optional[int] = None) -> int:
        """Finds and releases any temporary seat reservations past their expiration."""
        now = datetime.now(timezone.utc)
        query = db.query(Reservation).filter(
            Reservation.status == ReservationStatus.LOCKED,
            Reservation.expires_at <= now,
        )
        if trip_id is not None:
            query = query.filter(Reservation.trip_id == trip_id)

        expired_records = query.all()
        for r in expired_records:
            r.status = ReservationStatus.EXPIRED

        if expired_records:
            db.commit()
        return len(expired_records)

    @staticmethod
    def get_trip_seat_map(db: Session, trip_id: int) -> TripSeatsResponse:
        """Returns the real-time availability of every seat on the bus."""
        ReservationService.clean_expired_reservations(db, trip_id)

        trip = db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

        # Get all bus seats
        bus_seats = db.query(BusSeat).filter(BusSeat.bus_id == trip.bus_id, BusSeat.is_active == True).all()

        # Get occupied seats from confirmed bookings
        booked_tickets = (
            db.query(Ticket.seat_number)
            .join(Booking)
            .filter(
                Booking.trip_id == trip_id,
                Booking.status == BookingStatus.CONFIRMED,
                Ticket.status.in_([TicketStatus.VALID, TicketStatus.ALREADY_BOARDED]),
            )
            .all()
        )
        occupied_seat_set = {t[0] for t in booked_tickets}

        # Get currently locked seats from active reservations
        now = datetime.now(timezone.utc)
        active_reservations = (
            db.query(Reservation)
            .filter(
                Reservation.trip_id == trip_id,
                Reservation.status == ReservationStatus.LOCKED,
                Reservation.expires_at > now,
            )
            .all()
        )
        locked_map = {r.seat_number: r.expires_at for r in active_reservations}

        seat_statuses: List[SeatStatusResponse] = []
        for s in bus_seats:
            if s.seat_number in occupied_seat_set:
                seat_statuses.append(SeatStatusResponse(seat_number=s.seat_number, status="occupied"))
            elif s.seat_number in locked_map:
                seat_statuses.append(
                    SeatStatusResponse(
                        seat_number=s.seat_number,
                        status="locked",
                        expires_at=locked_map[s.seat_number],
                    )
                )
            else:
                seat_statuses.append(SeatStatusResponse(seat_number=s.seat_number, status="available"))

        available_count = sum(1 for s in seat_statuses if s.status == "available")

        return TripSeatsResponse(
            trip_id=trip_id,
            total_seats=len(bus_seats),
            available_seats=available_count,
            seats=seat_statuses,
        )

    @staticmethod
    def lock_seats(
        db: Session,
        trip_id: int,
        user_id: int,
        seat_numbers: List[str],
        duration_minutes: int = 10,
    ) -> ReservationResponse:
        """Atomically locks seats for a passenger with expiration countdown."""
        with ReservationService._lock:
            now = datetime.now(timezone.utc)
            expires_at = now + timedelta(minutes=duration_minutes)

            # 1. Clean out expired locks first
            ReservationService.clean_expired_reservations(db, trip_id)

            # 2. Check each requested seat against occupied tickets and active locks
            for seat_num in seat_numbers:
                # Check occupied
                is_occupied = (
                    db.query(Ticket)
                    .join(Booking)
                    .filter(
                        Booking.trip_id == trip_id,
                        Booking.status == BookingStatus.CONFIRMED,
                        Ticket.seat_number == seat_num,
                        Ticket.status.in_([TicketStatus.VALID, TicketStatus.ALREADY_BOARDED]),
                    )
                    .first()
                )
                if is_occupied:
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail=f"Seat {seat_num} is already booked and occupied.",
                    )

                # Check locked by another user
                existing_lock = (
                    db.query(Reservation)
                    .filter(
                        Reservation.trip_id == trip_id,
                        Reservation.seat_number == seat_num,
                        Reservation.status == ReservationStatus.LOCKED,
                        Reservation.expires_at > now,
                    )
                    .first()
                )
                if existing_lock and existing_lock.user_id != user_id:
                    raise HTTPException(
                        status_code=status.HTTP_409_CONFLICT,
                        detail=f"Seat {seat_num} is currently locked by another passenger.",
                    )

            # 3. Create or update reservation records
            for seat_num in seat_numbers:
                # If user already holds this lock, refresh expiration
                existing_user_lock = (
                    db.query(Reservation)
                    .filter(
                        Reservation.trip_id == trip_id,
                        Reservation.seat_number == seat_num,
                        Reservation.user_id == user_id,
                        Reservation.status == ReservationStatus.LOCKED,
                    )
                    .first()
                )
                if existing_user_lock:
                    existing_user_lock.expires_at = expires_at
                else:
                    new_lock = Reservation(
                        trip_id=trip_id,
                        seat_number=seat_num,
                        user_id=user_id,
                        expires_at=expires_at,
                        status=ReservationStatus.LOCKED,
                    )
                    db.add(new_lock)

            db.commit()

            remaining_seconds = int((expires_at - datetime.now(timezone.utc)).total_seconds())

            return ReservationResponse(
                trip_id=trip_id,
                seat_numbers=seat_numbers,
                expires_at=expires_at,
                remaining_seconds=max(0, remaining_seconds),
            )

    @staticmethod
    def confirm_booking(
        db: Session,
        user_id: int,
        request: BookingConfirmRequest,
    ) -> BookingConfirmResponse:
        """Transitions locked seats into a permanent, confirmed booking with QR tickets."""
        now = datetime.now(timezone.utc)
        ReservationService.clean_expired_reservations(db, request.trip_id)

        trip = db.query(Trip).filter(Trip.id == request.trip_id).first()
        if not trip:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

        # Verify that all requested seats are either locked by this user or available
        for seat_num in request.seat_numbers:
            lock = (
                db.query(Reservation)
                .filter(
                    Reservation.trip_id == request.trip_id,
                    Reservation.seat_number == seat_num,
                    Reservation.status == ReservationStatus.LOCKED,
                    Reservation.expires_at > now,
                )
                .first()
            )
            if lock and lock.user_id != user_id:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Cannot confirm booking: Seat {seat_num} is locked by another passenger.",
                )

            is_booked = (
                db.query(Ticket)
                .join(Booking)
                .filter(
                    Booking.trip_id == request.trip_id,
                    Booking.status == BookingStatus.CONFIRMED,
                    Ticket.seat_number == seat_num,
                    Ticket.status == TicketStatus.VALID,
                )
                .first()
            )
            if is_booked:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Cannot confirm booking: Seat {seat_num} is already booked.",
                )

        # 1. Create Booking
        random_num = random.randint(10000, 99999)
        booking_ref = f"ETL-2026-{random_num}"
        total_fare = trip.price_etb * len(request.seat_numbers)

        booking = Booking(
            booking_reference=booking_ref,
            user_id=user_id,
            trip_id=request.trip_id,
            status=BookingStatus.CONFIRMED,
            total_price_etb=total_fare,
            created_at=now,
        )
        db.add(booking)
        db.flush()

        # 2. Add Passengers & Tickets
        ticket_items: List[TicketItemResponse] = []
        for idx, p in enumerate(request.passengers):
            passenger = BookingPassenger(
                booking_id=booking.id,
                full_name=p.full_name,
                phone_number=p.phone_number,
                seat_number=p.assigned_seat,
            )
            db.add(passenger)

            tck_ref = f"TCK-{random_num}-{idx + 1}"
            qr_data = f"ETHIOLINER:{booking_ref}:{tck_ref}:{trip.id}:{p.assigned_seat}:{p.full_name}"

            ticket = Ticket(
                ticket_reference=tck_ref,
                booking_id=booking.id,
                passenger_name=p.full_name,
                seat_number=p.assigned_seat,
                status=TicketStatus.VALID,
                qr_code_data=qr_data,
                issued_at=now,
            )
            db.add(ticket)

            ticket_items.append(
                TicketItemResponse(
                    ticket_reference=tck_ref,
                    passenger_name=p.full_name,
                    seat_number=p.assigned_seat,
                    status="VALID",
                    qr_code_data=qr_data,
                )
            )

        # 3. Create Payment record
        payment = Payment(
            booking_id=booking.id,
            amount_etb=total_fare,
            payment_method=request.payment_method,
            status=PaymentStatus.SUCCESS,
            transaction_reference=f"TXN-{random_num}-{random.randint(100, 999)}",
            created_at=now,
        )
        db.add(payment)

        # 4. Mark reservations as confirmed
        user_locks = (
            db.query(Reservation)
            .filter(
                Reservation.trip_id == request.trip_id,
                Reservation.user_id == user_id,
                Reservation.seat_number.in_(request.seat_numbers),
                Reservation.status == ReservationStatus.LOCKED,
            )
            .all()
        )
        for lock in user_locks:
            lock.status = ReservationStatus.CONFIRMED

        db.commit()

        return BookingConfirmResponse(
            booking_reference=booking_ref,
            trip_id=trip.id,
            status="CONFIRMED",
            total_price_etb=total_fare,
            tickets=ticket_items,
            created_at=now,
        )
