from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class OperatorResponse(BaseModel):
    id: int
    name: str
    phone: Optional[str] = None
    rating: float
    is_verified: bool

    class Config:
        from_attributes = True


class BusResponse(BaseModel):
    id: int
    plate_number: str
    bus_model: str
    total_seats: int
    amenities: str

    class Config:
        from_attributes = True


class RouteResponse(BaseModel):
    id: int
    origin_city: str
    destination_city: str
    departure_terminal: str
    arrival_terminal: str
    distance_km: Optional[float] = None
    estimated_duration_minutes: int

    class Config:
        from_attributes = True


class TripResponse(BaseModel):
    id: int
    route: RouteResponse
    bus: BusResponse
    operator: OperatorResponse
    departure_time: datetime
    arrival_time: datetime
    price_etb: float
    available_seats: int
    status: str

    class Config:
        from_attributes = True
