from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr
from app.models.entities import UserRole


class UserResponse(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    phone_number: str
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
