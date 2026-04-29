from datetime import date, datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.entities import Bus, Operator, Route, Trip
from app.schemas.trip import BusResponse, OperatorResponse, RouteResponse, TripResponse

router = APIRouter(prefix="/trips", tags=["Trips"])


@router.get("", response_model=List[TripResponse])
def search_trips(
    origin: Optional[str] = Query(None, description="Origin city"),
    destination: Optional[str] = Query(None, description="Destination city"),
    travel_date: Optional[date] = Query(None, description="Date of travel"),
    db: Session = Depends(get_db),
):
    """Searches available trips matching origin, destination, and travel date."""
    query = db.query(Trip).join(Route).join(Bus).join(Operator)

    if origin:
        query = query.filter(Route.origin_city.ilike(f"%{origin}%"))
    if destination:
        query = query.filter(Route.destination_city.ilike(f"%{destination}%"))
    if travel_date:
        start_datetime = datetime.combine(travel_date, datetime.min.time())
        end_datetime = datetime.combine(travel_date, datetime.max.time())
        query = query.filter(Trip.departure_time >= start_datetime, Trip.departure_time <= end_datetime)

    trips = query.all()

    # Format into response models
    results = []
    for t in trips:
        results.append(
            TripResponse(
                id=t.id,
                route=RouteResponse.model_validate(t.route),
                bus=BusResponse.model_validate(t.bus),
                operator=OperatorResponse.model_validate(t.bus.operator),
                departure_time=t.departure_time,
                arrival_time=t.arrival_time,
                price_etb=t.price_etb,
                available_seats=t.available_seats,
                status=t.status,
            )
        )

    return results


@router.get("/{trip_id}", response_model=TripResponse)
def get_trip_details(trip_id: int, db: Session = Depends(get_db)):
    """Fetches details for an individual trip."""
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Trip not found",
        )

    return TripResponse(
        id=trip.id,
        route=RouteResponse.model_validate(trip.route),
        bus=BusResponse.model_validate(trip.bus),
        operator=OperatorResponse.model_validate(trip.bus.operator),
        departure_time=trip.departure_time,
        arrival_time=trip.arrival_time,
        price_etb=trip.price_etb,
        available_seats=trip.available_seats,
        status=trip.status,
    )
