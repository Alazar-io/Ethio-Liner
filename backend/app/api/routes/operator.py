from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_role
from app.core.database import get_db
from app.models.entities import Operator, User, UserRole
from app.schemas.operator import (
    BoardingValidationRequest,
    BoardingValidationResponse,
    BusCreate,
    BusResponse,
    ManifestPassengerResponse,
    OperatorOverviewResponse,
    RouteCreate,
    RouteResponse,
    TripCreate,
    TripManifestResponse,
    TripResponse,
)
from app.services.operator_service import OperatorService

router = APIRouter(prefix="/operator", tags=["operator"])


@router.get("/overview", response_model=OperatorOverviewResponse)
def get_operator_overview(
    operator_id: Optional[int] = None,
    db: Session = Depends(get_db),
):
    """Returns analytics overview for the operator."""
    op = (
        db.query(Operator).filter(Operator.id == operator_id).first()
        if operator_id
        else db.query(Operator).first()
    )
    if not op:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No operator registered.",
        )
    return OperatorService.get_dashboard_overview(db, op.id)


@router.get("/manifest/{trip_id}", response_model=TripManifestResponse)
def get_trip_manifest(
    trip_id: int,
    db: Session = Depends(get_db),
):
    """Returns passenger manifest for a trip."""
    return OperatorService.get_trip_manifest(db, trip_id)


@router.post("/board", response_model=BoardingValidationResponse)
def validate_and_board_passenger(
    request: BoardingValidationRequest,
    db: Session = Depends(get_db),
):
    """Scans and validates a passenger digital QR boarding pass."""
    return OperatorService.validate_and_board_passenger(
        db=db,
        qr_data_or_ref=request.qr_data,
        expected_trip_id=request.expected_trip_id,
    )


@router.post("/toggle-board/{ticket_ref}", response_model=ManifestPassengerResponse)
def toggle_passenger_boarded(
    ticket_ref: str,
    db: Session = Depends(get_db),
):
    """Manually toggles passenger boarding state from the manifest."""
    return OperatorService.toggle_passenger_boarded(db, ticket_ref)


@router.post("/buses", response_model=BusResponse)
def create_bus(
    bus_in: BusCreate,
    operator_id: Optional[int] = None,
    db: Session = Depends(get_db),
):
    """Adds a new bus to the operator fleet."""
    op = (
        db.query(Operator).filter(Operator.id == operator_id).first()
        if operator_id
        else db.query(Operator).first()
    )
    if not op:
        raise HTTPException(status_code=404, detail="Operator not found.")
    return OperatorService.create_bus(db, op.id, bus_in)


@router.post("/routes", response_model=RouteResponse)
def create_route(
    route_in: RouteCreate,
    operator_id: Optional[int] = None,
    db: Session = Depends(get_db),
):
    """Creates a new intercity route."""
    op = (
        db.query(Operator).filter(Operator.id == operator_id).first()
        if operator_id
        else db.query(Operator).first()
    )
    if not op:
        raise HTTPException(status_code=404, detail="Operator not found.")
    return OperatorService.create_route(db, op.id, route_in)


@router.post("/trips", response_model=TripResponse)
def create_trip(
    trip_in: TripCreate,
    db: Session = Depends(get_db),
):
    """Schedules a new trip for a bus and route."""
    return OperatorService.create_trip(db, trip_in)
