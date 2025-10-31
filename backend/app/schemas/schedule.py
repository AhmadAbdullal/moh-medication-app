from datetime import date, datetime, time
from typing import List, Optional

from pydantic import BaseModel, Field

from app.schemas.drug import DrugSimple


class DrugScheduleBase(BaseModel):
    dosage: str
    frequency: str
    start_date: date
    end_date: Optional[date] = None
    instructions: Optional[str] = None
    reminder_time: Optional[time] = None


class DrugScheduleCreate(DrugScheduleBase):
    patient_id: int
    drug_id: int


class DrugScheduleUpdate(BaseModel):
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    instructions: Optional[str] = None
    reminder_time: Optional[time] = None
    is_active: Optional[bool] = None


class DoseLogBase(BaseModel):
    taken_at: Optional[datetime] = None
    taken: bool = True
    notes: Optional[str] = None


class DoseLogCreate(DoseLogBase):
    schedule_id: int


class DoseLogInDBBase(DoseLogBase):
    id: int
    schedule_id: int
    recorded_at: datetime

    class Config:
        orm_mode = True


class DoseLog(DoseLogInDBBase):
    pass


class DrugScheduleInDBBase(DrugScheduleBase):
    id: int
    patient_id: int
    drug_id: int
    is_active: bool

    class Config:
        orm_mode = True


class DrugSchedule(DrugScheduleInDBBase):
    drug: DrugSimple
    dose_logs: List[DoseLog] = Field(default_factory=list)


class DrugScheduleSimple(DrugScheduleInDBBase):
    pass
