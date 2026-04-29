from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session

from app.core.database import Base, SessionLocal, engine
from app.core.security import hash_password
from app.models.entities import Bus, BusSeat, Operator, Route, Trip, User, UserRole


def seed_database():
    """Initializes schema and seeds realistic Ethiopian transportation demo data."""
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Check if already seeded
        if db.query(User).first():
            return

        # 1. Users
        admin_user = User(
            email="admin@ethioliner.com",
            hashed_password=hash_password("admin12345"),
            full_name="EthioLiner Admin",
            phone_number="+251911000000",
            role=UserRole.ADMIN,
            is_active=True,
        )
        demo_passenger = User(
            email="passenger@ethioliner.com",
            hashed_password=hash_password("passenger12345"),
            full_name="Abebe Bikila",
            phone_number="+251911223344",
            role=UserRole.PASSENGER,
            is_active=True,
        )
        db.add_all([admin_user, demo_passenger])
        db.commit()

        # 2. Operators
        selam_bus = Operator(
            name="Selam Bus Line",
            license_number="ET-TRA-00124",
            phone="+251115512345",
            rating=4.8,
            is_verified=True,
        )
        zemen_bus = Operator(
            name="Zemen Bus",
            license_number="ET-TRA-00358",
            phone="+251116624589",
            rating=4.9,
            is_verified=True,
        )
        abay_bus = Operator(
            name="Abay Bus",
            license_number="ET-TRA-00412",
            phone="+251118833112",
            rating=4.6,
            is_verified=True,
        )
        db.add_all([selam_bus, zemen_bus, abay_bus])
        db.commit()

        # 3. Buses
        bus_1 = Bus(
            operator_id=selam_bus.id,
            plate_number="3-A45124-ET",
            bus_model="Yutong Luxury 2024",
            total_seats=48,
            amenities="WiFi, Air Conditioning, USB Charger, Water",
        )
        bus_2 = Bus(
            operator_id=zemen_bus.id,
            plate_number="3-B98124-ET",
            bus_model="Scania Marcopolo VIP",
            total_seats=48,
            amenities="WiFi, AC, Reclining Seats, TV, Snacks",
        )
        db.add_all([bus_1, bus_2])
        db.commit()

        # Generate seats for bus 1 and 2
        for b in [bus_1, bus_2]:
            for r in range(1, 13):
                for col, letter in [(0, "A"), (1, "B"), (3, "C"), (4, "D")]:
                    seat = BusSeat(
                        bus_id=b.id,
                        seat_number=f"{r}{letter}",
                        row=r,
                        column=col,
                        is_active=True,
                    )
                    db.add(seat)
        db.commit()

        # 4. Routes
        route_hawassa = Route(
            operator_id=selam_bus.id,
            origin_city="Addis Ababa",
            destination_city="Hawassa",
            departure_terminal="Lamberet Bus Terminal",
            arrival_terminal="Hawassa Central Station",
            distance_km=275.0,
            estimated_duration_minutes=270,
        )
        route_bahir_dar = Route(
            operator_id=zemen_bus.id,
            origin_city="Addis Ababa",
            destination_city="Bahir Dar",
            departure_terminal="Asko Central Terminal",
            arrival_terminal="Bahir Dar Main Terminal",
            distance_km=565.0,
            estimated_duration_minutes=540,
        )
        db.add_all([route_hawassa, route_bahir_dar])
        db.commit()

        # 5. Trips
        now = datetime.now(timezone.utc)
        tomorrow = now + timedelta(days=1)
        trip_date = datetime(tomorrow.year, tomorrow.month, tomorrow.day, 6, 0, tzinfo=timezone.utc)

        trip_1 = Trip(
            route_id=route_hawassa.id,
            bus_id=bus_1.id,
            departure_time=trip_date,
            arrival_time=trip_date + timedelta(hours=4, minutes=30),
            price_etb=750.0,
            available_seats=48,
            status="SCHEDULED",
        )
        trip_2 = Trip(
            route_id=route_bahir_dar.id,
            bus_id=bus_2.id,
            departure_time=trip_date + timedelta(hours=1),
            arrival_time=trip_date + timedelta(hours=10),
            price_etb=1200.0,
            available_seats=48,
            status="SCHEDULED",
        )
        db.add_all([trip_1, trip_2])
        db.commit()

    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
