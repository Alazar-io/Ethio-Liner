import enum
from datetime import datetime, timezone
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.orm import relationship

from app.core.database import Base


class UserRole(str, enum.Enum):
    PASSENGER = "PASSENGER"
    OPERATOR = "OPERATOR"
    ADMIN = "ADMIN"


class BookingStatus(str, enum.Enum):
    PENDING = "PENDING"
    CONFIRMED = "CONFIRMED"
    CANCELLED = "CANCELLED"


class ReservationStatus(str, enum.Enum):
    LOCKED = "LOCKED"
    CONFIRMED = "CONFIRMED"
    RELEASED = "RELEASED"
    EXPIRED = "EXPIRED"


class PaymentStatus(str, enum.Enum):
    PENDING = "PENDING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"


class TicketStatus(str, enum.Enum):
    VALID = "VALID"
    ALREADY_BOARDED = "ALREADY_BOARDED"
    CANCELLED = "CANCELLED"
    EXPIRED = "EXPIRED"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    phone_number = Column(String(50), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.PASSENGER, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    bookings = relationship("Booking", back_populates="user")


class Operator(Base):
    __tablename__ = "operators"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), unique=True, index=True, nullable=False)
    license_number = Column(String(100), unique=True, nullable=False)
    phone = Column(String(50), nullable=True)
    rating = Column(Float, default=4.5, nullable=False)
    is_verified = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    buses = relationship("Bus", back_populates="operator")
    routes = relationship("Route", back_populates="operator")


class Bus(Base):
    __tablename__ = "buses"

    id = Column(Integer, primary_key=True, index=True)
    operator_id = Column(Integer, ForeignKey("operators.id"), nullable=False)
    plate_number = Column(String(50), unique=True, index=True, nullable=False)
    bus_model = Column(String(100), nullable=False)
    total_seats = Column(Integer, default=49, nullable=False)
    amenities = Column(String(255), default="WiFi, AC, USB Charger, Water")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    operator = relationship("Operator", back_populates="buses")
    seats = relationship("BusSeat", back_populates="bus")
    trips = relationship("Trip", back_populates="bus")


class BusSeat(Base):
    __tablename__ = "bus_seats"

    id = Column(Integer, primary_key=True, index=True)
    bus_id = Column(Integer, ForeignKey("buses.id"), nullable=False)
    seat_number = Column(String(10), nullable=False)
    row = Column(Integer, nullable=False)
    column = Column(Integer, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    bus = relationship("Bus", back_populates="seats")


class Route(Base):
    __tablename__ = "routes"

    id = Column(Integer, primary_key=True, index=True)
    operator_id = Column(Integer, ForeignKey("operators.id"), nullable=False)
    origin_city = Column(String(100), index=True, nullable=False)
    destination_city = Column(String(100), index=True, nullable=False)
    departure_terminal = Column(String(255), nullable=False)
    arrival_terminal = Column(String(255), nullable=False)
    distance_km = Column(Float, nullable=True)
    estimated_duration_minutes = Column(Integer, nullable=False)

    operator = relationship("Operator", back_populates="routes")
    trips = relationship("Trip", back_populates="route")


class Trip(Base):
    __tablename__ = "trips"

    id = Column(Integer, primary_key=True, index=True)
    route_id = Column(Integer, ForeignKey("routes.id"), nullable=False)
    bus_id = Column(Integer, ForeignKey("buses.id"), nullable=False)
    departure_time = Column(DateTime, nullable=False)
    arrival_time = Column(DateTime, nullable=False)
    price_etb = Column(Float, nullable=False)
    available_seats = Column(Integer, nullable=False)
    status = Column(String(50), default="SCHEDULED", nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    route = relationship("Route", back_populates="trips")
    bus = relationship("Bus", back_populates="trips")
    bookings = relationship("Booking", back_populates="trip")
    reservations = relationship("Reservation", back_populates="trip")


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    booking_reference = Column(String(50), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    trip_id = Column(Integer, ForeignKey("trips.id"), nullable=False)
    status = Column(Enum(BookingStatus), default=BookingStatus.PENDING, nullable=False)
    total_price_etb = Column(Float, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    user = relationship("User", back_populates="bookings")
    trip = relationship("Trip", back_populates="bookings")
    passengers = relationship("BookingPassenger", back_populates="booking")
    payment = relationship("Payment", back_populates="booking", uselist=False)
    tickets = relationship("Ticket", back_populates="booking")


class BookingPassenger(Base):
    __tablename__ = "booking_passengers"

    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    full_name = Column(String(255), nullable=False)
    phone_number = Column(String(50), nullable=False)
    seat_number = Column(String(10), nullable=False)

    booking = relationship("Booking", back_populates="passengers")


class Reservation(Base):
    __tablename__ = "reservations"

    id = Column(Integer, primary_key=True, index=True)
    trip_id = Column(Integer, ForeignKey("trips.id"), nullable=False)
    seat_number = Column(String(10), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    status = Column(Enum(ReservationStatus), default=ReservationStatus.LOCKED, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    trip = relationship("Trip", back_populates="reservations")


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    amount_etb = Column(Float, nullable=False)
    payment_method = Column(String(50), nullable=False)
    status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING, nullable=False)
    transaction_reference = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    booking = relationship("Booking", back_populates="payment")


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    ticket_reference = Column(String(100), unique=True, index=True, nullable=False)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    passenger_name = Column(String(255), nullable=False)
    seat_number = Column(String(10), nullable=False)
    status = Column(Enum(TicketStatus), default=TicketStatus.VALID, nullable=False)
    qr_code_data = Column(Text, nullable=False)
    issued_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    booking = relationship("Booking", back_populates="tickets")
