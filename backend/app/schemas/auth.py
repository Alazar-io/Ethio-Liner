from typing import Optional
from pydantic import BaseModel, EmailStr
from app.models.entities import UserRole


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in_minutes: int


class TokenPayload(BaseModel):
    sub: Optional[str] = None
    role: Optional[str] = None
    exp: Optional[int] = None


class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone_number: str
    role: UserRole = UserRole.PASSENGER


class UserLogin(BaseModel):
    email: EmailStr
    password: str
