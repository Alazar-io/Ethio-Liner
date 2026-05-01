from datetime import datetime, timezone
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.entities import (
    Booking,
    BookingPassenger,
    BookingStatus,
    Bus,
    BusSeat,
    Operator,
    Route,
    Ticket,
    TicketStatus,
    Trip,
    User,
)
from app.schemas.operator import (
    BoardingValidationResponse,
    BusCreate,
    ManifestPassengerResponse,
    OperatorOverviewResponse,
    OperatorTripSummary,
    RouteCreate,
    TripCreate,
    TripManifestResponse,
)


class OperatorService:
    @staticmethod
    def get_operator_for_user(db: Session, user: User) -> Operator:
        """Resolves the operator entity associated with the user, defaulting to first operator if admin."""
        if user.operator_id:
            op = db.query(Operator).filter(Operator.id == user.operator_id).first()
            if op:
                return op
        first_op = db.query(Operator).first()
        if not first_op:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No operator found in system.")
        return first_op

    @staticmethod
    def get_dashboard_overview(db: Session, operator_id: int) -> OperatorOverviewResponse:
        """Calculates live operator metrics across fleet, routes, trips, bookings, and revenue."""
        operator = db.query(Operator).filter(Operator.id == operator_id).first()
        if not operator:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Operator not found.")

        buses = db.query(Bus).filter(Bus.operator_id == operator_id).all()
        routes = db.query(Route).filter(Route.operator_id == operator_id).all()
        bus_ids = [b.id for b in buses]

        trips = (
            db.query(Trip)
            .filter(Trip.bus_id.in_(bus_ids))
            .order_by(Trip.departure_time.asc())
            .all()
        )

        trip_summaries: List[OperatorTripSummary] = []
        total_booked_count = 0
        total_boarded_count = 0
        total_revenue = 0.0

        for t in trips:
            confirmed_tickets = (
                db.query(Ticket)
                .join(Booking)
                .filter(
                    Booking.trip_id == t.id,
                    Booking.status == BookingStatus.CONFIRMED,
                    Ticket.status.in_([TicketStatus.VALID, TicketStatus.ALREADY_BOARDED]),
                )
                .all()
            )
            booked_count = len(confirmed_tickets)
            boarded_count = len([tk for tk in confirmed_tickets if tk.status == TicketStatus.ALREADY_BOARDED])
            trip_revenue = booked_count * t.price_etb

            total_booked_count += booked_count
            total_boarded_count += boarded_count
            total_revenue += trip_revenue

            total_cap = t.bus.total_seats if t.bus else 48
            occ_rate = round((booked_count / total_cap * 100), 1) if total_cap > 0 else 0.0

            summary = OperatorTripSummary(
                trip_id=t.id,
                route=f"{t.route.origin_city} → {t.route.destination_city}",
                origin_city=t.route.origin_city,
                destination_city=t.route.destination_city,
                bus_model=t.bus.bus_model if t.bus else "Standard Bus",
                plate_number=t.bus.plate_number if t.bus else "ET-BUS",
                departure_time=t.departure_time,
                price_etb=t.price_etb,
                total_seats=total_cap,
                booked_seats=booked_count,
                boarded_passengers=boarded_count,
                occupancy_rate=occ_rate,
                status=t.status,
            )
            trip_summaries.append(summary)

        total_seats_capacity = sum(t.bus.total_seats for t in trips if t.bus)
        overall_occupancy = (
            round((total_booked_count / total_seats_capacity * 100), 1)
            if total_seats_capacity > 0
            else 0.0
        )

        return OperatorOverviewResponse(
            operator_name=operator.name,
            is_verified=operator.is_verified,
            total_buses=len(buses),
            total_routes=len(routes),
            total_trips=len(trips),
            active_trips_today=len(trips),
            total_passengers_booked=total_booked_count,
            total_passengers_boarded=total_boarded_count,
            occupancy_rate_percent=overall_occupancy,
            total_revenue_etb=total_revenue,
            trips=trip_summaries,
        )

    @staticmethod
    def get_trip_manifest(db: Session, trip_id: int) -> TripManifestResponse:
        """Retrieves verified passenger manifest for a specific trip."""
        trip = db.query(Trip).filter(Trip.id == trip_id).first()
        if not trip:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found.")

        tickets = (
            db.query(Ticket)
            .join(Booking)
            .filter(
                Booking.trip_id == trip_id,
                Booking.status == BookingStatus.CONFIRMED,
            )
            .order_by(Ticket.seat_number.asc())
            .all()
        )

        manifest_passengers: List[ManifestPassengerResponse] = []
        boarded_count = 0

        for tk in tickets:
            if tk.status == TicketStatus.ALREADY_BOARDED:
                boarded_count += 1

            # Find matching passenger phone
            passenger_rec = (
                db.query(BookingPassenger)
                .filter(
                    BookingPassenger.booking_id == tk.booking_id,
                    BookingPassenger.seat_number == tk.seat_number,
                )
                .first()
            )
            phone = passenger_rec.phone_number if passenger_rec else tk.booking.user.phone_number

            manifest_passengers.append(
                ManifestPassengerResponse(
                    ticket_id=tk.ticket_reference,
                    passenger_name=tk.passenger_name,
                    phone_number=phone,
                    seat_number=tk.seat_number,
                    booking_reference=tk.booking.booking_reference,
                    status=tk.status.value,
                    boarded_at=tk.boarded_at,
                )
            )

        return TripManifestResponse(
            trip_id=trip.id,
            route=f"{trip.route.origin_city} → {trip.route.destination_city}",
            origin_city=trip.route.origin_city,
            destination_city=trip.route.destination_city,
            departure_time=trip.departure_time,
            departure_terminal=trip.route.departure_terminal,
            arrival_terminal=trip.route.arrival_terminal,
            bus_model=trip.bus.bus_model if trip.bus else "Standard Bus",
            plate_number=trip.bus.plate_number if trip.bus else "ET-BUS",
            total_capacity=trip.bus.total_seats if trip.bus else 48,
            total_booked=len(tickets),
            total_boarded=boarded_count,
            passengers=manifest_passengers,
        )

    @staticmethod
    def validate_and_board_passenger(
        db: Session,
        qr_data_or_ref: str,
        expected_trip_id: Optional[int] = None,
    ) -> BoardingValidationResponse:
        """Parses QR code or ticket reference, validates boarding legitimacy, and marks passenger boarded."""
        cleaned = qr_data_or_ref.strip()

        # Handle full QR format ETHIOLINER:booking_ref:ticket_ref:trip_id:seat:name
        ticket_ref = cleaned
        if cleaned.startswith("ETHIOLINER:"):
            parts = cleaned.split(":")
            if len(parts) >= 3:
                ticket_ref = parts[2]

        ticket = (
            db.query(Ticket)
            .filter(
                (Ticket.ticket_reference == ticket_ref)
                | (Ticket.qr_code_data == cleaned)
            )
            .first()
        )

        if not ticket:
            return BoardingValidationResponse(
                status="INVALID",
                message="Ticket not found in system or invalid QR code.",
                can_board=False,
            )

        route_name = f"{ticket.booking.trip.route.origin_city} → {ticket.booking.trip.route.destination_city}"

        # Check trip match
        if expected_trip_id and ticket.booking.trip_id != expected_trip_id:
            return BoardingValidationResponse(
                status="INVALID",
                message=f"Ticket belongs to a different trip ({route_name}).",
                can_board=False,
                ticket_id=ticket.ticket_reference,
                passenger_name=ticket.passenger_name,
                seat_number=ticket.seat_number,
                route=route_name,
            )

        # Check cancelled
        if ticket.status == TicketStatus.CANCELLED or ticket.booking.status == BookingStatus.CANCELLED:
            return BoardingValidationResponse(
                status="CANCELLED",
                message="This booking or ticket has been CANCELLED.",
                can_board=False,
                ticket_id=ticket.ticket_reference,
                passenger_name=ticket.passenger_name,
                seat_number=ticket.seat_number,
                route=route_name,
            )

        # Check already boarded
        if ticket.status == TicketStatus.ALREADY_BOARDED:
            boarded_time_str = (
                ticket.boarded_at.strftime("%I:%M %p")
                if ticket.boarded_at
                else "earlier"
            )
            return BoardingValidationResponse(
                status="ALREADY_BOARDED",
                message=f"Passenger was already boarded at {boarded_time_str}. Duplicate boarding denied!",
                can_board=False,
                ticket_id=ticket.ticket_reference,
                passenger_name=ticket.passenger_name,
                seat_number=ticket.seat_number,
                route=route_name,
                boarded_at=ticket.boarded_at,
            )

        # Check expired
        if ticket.status == TicketStatus.EXPIRED:
            return BoardingValidationResponse(
                status="EXPIRED",
                message="This ticket has EXPIRED.",
                can_board=False,
                ticket_id=ticket.ticket_reference,
                passenger_name=ticket.passenger_name,
                seat_number=ticket.seat_number,
                route=route_name,
            )

        # Approved -> Mark Boarded
        now_utc = datetime.now(timezone.utc)
        ticket.status = TicketStatus.ALREADY_BOARDED
        ticket.boarded_at = now_utc
        db.commit()
        db.refresh(ticket)

        return BoardingValidationResponse(
            status="VALID",
            message="Boarding Approved! Welcome passenger aboard.",
            can_board=True,
            ticket_id=ticket.ticket_reference,
            passenger_name=ticket.passenger_name,
            seat_number=ticket.seat_number,
            route=route_name,
            boarded_at=ticket.boarded_at,
        )

    @staticmethod
    def toggle_passenger_boarded(db: Session, ticket_reference: str) -> ManifestPassengerResponse:
        """Allows operator to manually toggle boarding state from manifest."""
        ticket = db.query(Ticket).filter(Ticket.ticket_reference == ticket_reference).first()
        if not ticket:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ticket not found.")

        if ticket.status == TicketStatus.ALREADY_BOARDED:
            ticket.status = TicketStatus.VALID
            ticket.boarded_at = None
        elif ticket.status == TicketStatus.VALID:
            ticket.status = TicketStatus.ALREADY_BOARDED
            ticket.boarded_at = datetime.now(timezone.utc)
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Cannot toggle ticket with status {ticket.status}.")

        db.commit()
        db.refresh(ticket)

        passenger_rec = (
            db.query(BookingPassenger)
            .filter(
                BookingPassenger.booking_id == ticket.booking_id,
                BookingPassenger.seat_number == ticket.seat_number,
            )
            .first()
        )
        phone = passenger_rec.phone_number if passenger_rec else ticket.booking.user.phone_number

        return ManifestPassengerResponse(
            ticket_id=ticket.ticket_reference,
            passenger_name=ticket.passenger_name,
            phone_number=phone,
            seat_number=ticket.seat_number,
            booking_reference=ticket.booking.booking_reference,
            status=ticket.status.value,
            boarded_at=ticket.boarded_at,
        )

    @staticmethod
    def create_bus(db: Session, operator_id: int, bus_in: BusCreate) -> Bus:
        bus = Bus(
            operator_id=operator_id,
            plate_number=bus_in.plate_number,
            bus_model=bus_in.bus_model,
            total_seats=bus_in.total_seats,
            amenities=bus_in.amenities or "Standard",
        )
        db.add(bus)
        db.commit()
        db.refresh(bus)

        # Create standard seat layout
        rows = (bus_in.total_seats + 3) // 4
        for r in range(1, rows + 1):
            for col, letter in [(0, "A"), (1, "B"), (3, "C"), (4, "D")]:
                seat = BusSeat(bus_id=bus.id, seat_number=f"{r}{letter}", row=r, column=col)
                db.add(seat)
        db.commit()
        return bus

    @staticmethod
    def create_route(db: Session, operator_id: int, route_in: RouteCreate) -> Route:
        route = Route(
            operator_id=operator_id,
            origin_city=route_in.origin_city,
            destination_city=route_in.destination_city,
            departure_terminal=route_in.departure_terminal,
            arrival_terminal=route_in.arrival_terminal,
            distance_km=route_in.distance_km,
            estimated_duration_minutes=route_in.estimated_duration_minutes,
        )
        db.add(route)
        db.commit()
        db.refresh(route)
        return route

    @staticmethod
    def create_trip(db: Session, trip_in: TripCreate) -> Trip:
        bus = db.query(Bus).filter(Bus.id == trip_in.bus_id).first()
        if not bus:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bus not found.")
        trip = Trip(
            route_id=trip_in.route_id,
            bus_id=trip_in.bus_id,
            departure_time=trip_in.departure_time,
            arrival_time=trip_in.arrival_time,
            price_etb=trip_in.price_etb,
            available_seats=bus.total_seats,
            status=trip_in.status or "SCHEDULED",
        )
        db.add(trip)
        db.commit()
        db.refresh(trip)
        return trip
