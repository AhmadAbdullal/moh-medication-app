from datetime import date
from typing import List, Optional

from pydantic import BaseModel, Field

from app.schemas.schedule import DrugScheduleSimple


class PatientBase(BaseModel):
    full_name: str
    date_of_birth: Optional[date] = None
    medical_record_number: Optional[str] = None


class PatientCreate(PatientBase):
    user_id: int


class PatientUpdate(BaseModel):
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    medical_record_number: Optional[str] = None


class PatientInDBBase(PatientBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True


class Patient(PatientInDBBase):
    schedules: List[DrugScheduleSimple] = Field(default_factory=list)
