import os
import sys
from datetime import datetime, timedelta, timezone

# Ensure backend directory is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.database import SessionLocal
from app.core.seed import seed_database
from app.models.entities import (
    Booking,
    BookingPassenger,
    BookingStatus,
    Operator,
    Payment,
    PaymentStatus,
    Ticket,
    TicketStatus,
    Trip,
    User,
)
from app.schemas.operator import BusCreate, RouteCreate, TripCreate
from app.services.operator_service import OperatorService


def test_operator_overview():
    seed_database()
    db = SessionLocal()
    try:
        operator = db.query(Operator).first()
        assert operator is not None

        overview = OperatorService.get_dashboard_overview(db, operator.id)
        assert overview.operator_name == operator.name
        assert overview.total_buses >= 1
        assert overview.total_routes >= 1
        assert overview.total_trips >= 1
        assert isinstance(overview.total_revenue_etb, float)
    finally:
        db.close()


def test_qr_boarding_lifecycle():
    seed_database()
    db = SessionLocal()
    try:
        trip = db.query(Trip).first()
        user = db.query(User).filter(User.email == "passenger@ethioliner.com").first()

        # 1. Create a test booking and ticket
        ref_id = "ETL-TEST-QR-99"
        ticket_ref = "TCK-TEST-QR-99"
        qr_code_str = f"ETHIOLINER:{ref_id}:{ticket_ref}:{trip.id}:4A:Test Passenger"

        # Cleanup if exists
        old_ticket = db.query(Ticket).filter(Ticket.ticket_reference == ticket_ref).first()
        if old_ticket:
            db.delete(old_ticket)
            db.commit()

        booking = Booking(
            booking_reference=ref_id,
            user_id=user.id,
            trip_id=trip.id,
            status=BookingStatus.CONFIRMED,
            total_price_etb=750.0,
        )
        db.add(booking)
        db.commit()
        db.refresh(booking)

        passenger = BookingPassenger(
            booking_id=booking.id,
            full_name="Test Passenger",
            phone_number="+251911999999",
            seat_number="4A",
        )
        db.add(passenger)

        ticket = Ticket(
            ticket_reference=ticket_ref,
            booking_id=booking.id,
            passenger_name="Test Passenger",
            seat_number="4A",
            status=TicketStatus.VALID,
            qr_code_data=qr_code_str,
        )
        db.add(ticket)
        db.commit()

        # 2. First scan -> Should be approved
        res1 = OperatorService.validate_and_board_passenger(db, qr_code_str, expected_trip_id=trip.id)
        assert res1.status == "VALID"
        assert res1.can_board is True
        assert res1.passenger_name == "Test Passenger"
        assert res1.seat_number == "4A"

        # Verify DB updated
        db.refresh(ticket)
        assert ticket.status == TicketStatus.ALREADY_BOARDED
        assert ticket.boarded_at is not None

        # 3. Second scan of the same QR -> Must be rejected as ALREADY_BOARDED
        res2 = OperatorService.validate_and_board_passenger(db, qr_code_str, expected_trip_id=trip.id)
        assert res2.status == "ALREADY_BOARDED"
        assert res2.can_board is False
        assert "already boarded" in res2.message.lower()

        # 4. Scan a cancelled ticket -> Must be rejected
        ticket.status = TicketStatus.CANCELLED
        db.commit()
        res3 = OperatorService.validate_and_board_passenger(db, qr_code_str, expected_trip_id=trip.id)
        assert res3.status == "CANCELLED"
        assert res3.can_board is False

        # 5. Scan a completely invalid/fake QR -> Must be rejected as INVALID
        fake_qr = "ETHIOLINER:FAKE-REF:TCK-DOES-NOT-EXIST:999:1Z:Fake"
        res4 = OperatorService.validate_and_board_passenger(db, fake_qr)
        assert res4.status == "INVALID"
        assert res4.can_board is False

        # 6. Verify manifest includes this passenger
        manifest = OperatorService.get_trip_manifest(db, trip.id)
        assert any(p.ticket_id == ticket_ref for p in manifest.passengers)

        # Cleanup test records
        db.delete(ticket)
        db.delete(passenger)
        db.delete(booking)
        db.commit()

    finally:
        db.close()


def test_bus_route_trip_creation():
    seed_database()
    db = SessionLocal()
    try:
        operator = db.query(Operator).first()

        # Test bus creation
        plate = f"3-TEST-{datetime.now().microsecond}"
        bus_in = BusCreate(
            plate_number=plate,
            bus_model="Volvo 9700 Grand Cruiser",
            total_seats=48,
        )
        new_bus = OperatorService.create_bus(db, operator.id, bus_in)
        assert new_bus.id is not None
        assert new_bus.plate_number == plate
        assert len(new_bus.seats) == 48

        # Test route creation
        route_in = RouteCreate(
            origin_city="Addis Ababa",
            destination_city="Gondar",
            departure_terminal="Autobus Tera",
            arrival_terminal="Gondar Main Gate",
            distance_km=730.0,
            estimated_duration_minutes=720,
        )
        new_route = OperatorService.create_route(db, operator.id, route_in)
        assert new_route.id is not None
        assert new_route.destination_city == "Gondar"

        # Test trip creation
        dep = datetime.now(timezone.utc) + timedelta(days=2)
        trip_in = TripCreate(
            route_id=new_route.id,
            bus_id=new_bus.id,
            departure_time=dep,
            arrival_time=dep + timedelta(hours=12),
            price_etb=1500.0,
        )
        new_trip = OperatorService.create_trip(db, trip_in)
        assert new_trip.id is not None
        assert new_trip.available_seats == 48

        # Cleanup
        db.delete(new_trip)
        db.delete(new_route)
        for s in new_bus.seats:
            db.delete(s)
        db.delete(new_bus)
        db.commit()

    finally:
        db.close()


if __name__ == "__main__":
    test_operator_overview()
    test_qr_boarding_lifecycle()
    test_bus_route_trip_creation()
    print("All Operator & QR Boarding backend tests passed successfully!")
