from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None


class UserCreate(UserBase):
    password: Optional[str] = None


class UserUpdate(UserBase):
    password: Optional[str] = None
    is_active: Optional[bool] = None
    is_superuser: Optional[bool] = None


class UserInDBBase(UserBase):
    id: int
    is_active: bool
    is_superuser: bool
    created_at: datetime

    class Config:
        orm_mode = True


class User(UserInDBBase):
    pass


class UserInDB(UserInDBBase):
    hashed_password: Optional[str] = None
