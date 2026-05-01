import os
import sys
import threading
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException

# Ensure backend directory is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.database import SessionLocal
from app.core.seed import seed_database
from app.models.entities import Trip, User, UserRole, Reservation, ReservationStatus, Ticket, BookingPassenger, Booking
from app.schemas.reservation import BookingConfirmRequest, PassengerInput
from app.services.reservation_service import ReservationService


def cleanup_test_seats(db, trip_id, seats):
    """Ensures test seats are reset for idempotent repeated test execution."""
    db.query(Reservation).filter(Reservation.trip_id == trip_id, Reservation.seat_number.in_(seats)).delete(synchronize_session=False)
    tickets = db.query(Ticket).filter(Ticket.seat_number.in_(seats)).all()
    booking_ids = [t.booking_id for t in tickets if t.booking_id]
    for t in tickets:
        db.delete(t)
    if booking_ids:
        db.query(BookingPassenger).filter(BookingPassenger.booking_id.in_(booking_ids)).delete(synchronize_session=False)
        db.query(Booking).filter(Booking.id.in_(booking_ids)).delete(synchronize_session=False)
    db.commit()


def test_concurrent_seat_reservation_double_booking():
    """Simulates concurrent threads attempting to reserve the exact same seat simultaneously."""
    seed_database()
    db = SessionLocal()
    try:
        trip = db.query(Trip).first()
        assert trip is not None

        user1 = db.query(User).filter(User.email == "admin@ethioliner.com").first()
        user2 = db.query(User).filter(User.email == "passenger@ethioliner.com").first()

        target_seat = "10D"
        cleanup_test_seats(db, trip.id, [target_seat])
        results = {"success": [], "conflict": []}

        def attempt_reservation(user_id: int):
            worker_db = SessionLocal()
            try:
                res = ReservationService.lock_seats(
                    db=worker_db,
                    trip_id=trip.id,
                    user_id=user_id,
                    seat_numbers=[target_seat],
                )
                results["success"].append(user_id)
            except HTTPException as e:
                if e.status_code == 409:
                    results["conflict"].append(user_id)
                else:
                    raise
            finally:
                worker_db.close()

        # Launch concurrent threads trying to lock the exact same seat
        t1 = threading.Thread(target=attempt_reservation, args=(user1.id,))
        t2 = threading.Thread(target=attempt_reservation, args=(user2.id,))

        t1.start()
        t2.start()

        t1.join()
        t2.join()

        # Exactly ONE thread must succeed, and the second must be rejected with 409 Conflict
        assert len(results["success"]) == 1, f"Expected 1 success, got {len(results['success'])}"
        assert len(results["conflict"]) == 1, f"Expected 1 conflict, got {len(results['conflict'])}"

        winner_id = results["success"][0]
        loser_id = results["conflict"][0]
        assert winner_id != loser_id

        # Verify in DB that only winner holds the lock
        lock = (
            db.query(Reservation)
            .filter(
                Reservation.trip_id == trip.id,
                Reservation.seat_number == target_seat,
                Reservation.status == ReservationStatus.LOCKED,
            )
            .first()
        )
        assert lock is not None
        assert lock.user_id == winner_id

    finally:
        db.close()


def test_expired_reservation_automatic_release():
    """Verifies that an expired reservation is automatically released for new passengers."""
    seed_database()
    db = SessionLocal()
    try:
        trip = db.query(Trip).first()
        user1 = db.query(User).filter(User.email == "admin@ethioliner.com").first()
        user2 = db.query(User).filter(User.email == "passenger@ethioliner.com").first()

        target_seat = "11D"
        cleanup_test_seats(db, trip.id, [target_seat])

        # 1. Create an artificially expired lock for user 1 (expired 5 minutes ago)
        expired_lock = Reservation(
            trip_id=trip.id,
            seat_number=target_seat,
            user_id=user1.id,
            expires_at=datetime.now(timezone.utc) - timedelta(minutes=5),
            status=ReservationStatus.LOCKED,
        )
        db.add(expired_lock)
        db.commit()

        # 2. User 2 now attempts to reserve the expired seat
        res = ReservationService.lock_seats(
            db=db,
            trip_id=trip.id,
            user_id=user2.id,
            seat_numbers=[target_seat],
        )

        assert res is not None
        assert target_seat in res.seat_numbers

        # 3. Verify user 2 now holds the active lock and user 1's lock transitioned to EXPIRED
        db.refresh(expired_lock)
        assert expired_lock.status == ReservationStatus.EXPIRED

        active_lock = (
            db.query(Reservation)
            .filter(
                Reservation.trip_id == trip.id,
                Reservation.seat_number == target_seat,
                Reservation.user_id == user2.id,
                Reservation.status == ReservationStatus.LOCKED,
            )
            .first()
        )
        assert active_lock is not None

    finally:
        db.close()


def test_transactional_booking_confirmation():
    """Verifies confirming a booking creates tickets and prevents re-booking."""
    seed_database()
    db = SessionLocal()
    try:
        trip = db.query(Trip).first()
        user = db.query(User).filter(User.email == "passenger@ethioliner.com").first()
        seat = "12D"
        cleanup_test_seats(db, trip.id, [seat])

        # 1. Lock seat
        ReservationService.lock_seats(db, trip.id, user.id, [seat])

        # 2. Confirm booking
        req = BookingConfirmRequest(
            trip_id=trip.id,
            seat_numbers=[seat],
            payment_method="telebirr",
            passengers=[
                PassengerInput(
                    full_name="Abebe Bikila",
                    phone_number="+251911223344",
                    assigned_seat=seat,
                )
            ],
        )
        booking_res = ReservationService.confirm_booking(db, user.id, req)
        assert booking_res.status == "CONFIRMED"
        assert len(booking_res.tickets) == 1
        assert booking_res.tickets[0].seat_number == seat

        # 3. Attempting to lock the confirmed seat by any user must raise 409 Conflict
        try:
            ReservationService.lock_seats(db, trip.id, user.id, [seat])
            assert False, "Should have raised 409 Conflict"
        except HTTPException as e:
            assert e.status_code == 409
            assert "already booked" in e.detail.lower()

    finally:
        db.close()


if __name__ == "__main__":
    test_concurrent_seat_reservation_double_booking()
    test_expired_reservation_automatic_release()
    test_transactional_booking_confirmation()
    print("All concurrency, locking, and transaction tests passed successfully!")
