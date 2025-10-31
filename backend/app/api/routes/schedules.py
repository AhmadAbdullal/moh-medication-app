from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.api import deps
from app.models.drug import DrugLocalKuwait
from app.models.patient import Patient
from app.models.schedule import DoseLog, DrugSchedule
from app.models.user import User
from app.schemas.schedule import (
    DoseLogCreate,
    DoseLog as DoseLogSchema,
    DrugSchedule as DrugScheduleSchema,
    DrugScheduleCreate,
)

router = APIRouter(tags=["schedules"])


@router.get("/patients/{patient_id}/schedules", response_model=List[DrugScheduleSchema])
def list_patient_schedules(
    patient_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> List[DrugScheduleSchema]:
    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    if not current_user.is_superuser and patient.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    schedules = (
        db.query(DrugSchedule)
        .options(
            joinedload(DrugSchedule.dose_logs),
            joinedload(DrugSchedule.drug).joinedload(DrugLocalKuwait.matched_drug),
        )
        .filter(DrugSchedule.patient_id == patient_id)
        .all()
    )
    return schedules


@router.post("/patients/{patient_id}/schedules", response_model=DrugScheduleSchema, status_code=status.HTTP_201_CREATED)
def create_patient_schedule(
    patient_id: int,
    schedule_in: DrugScheduleCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> DrugScheduleSchema:
    if schedule_in.patient_id != patient_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Patient ID mismatch")

    patient = db.query(Patient).filter(Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")

    if not current_user.is_superuser and patient.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    drug = db.query(DrugLocalKuwait).filter(DrugLocalKuwait.id == schedule_in.drug_id).first()
    if not drug:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Drug not found")
    if drug.matched_drug_id is not None and drug.verified_status != "verified":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Drug not verified")

    schedule = DrugSchedule(**schedule_in.dict())
    db.add(schedule)
    db.commit()

    schedule = (
        db.query(DrugSchedule)
        .options(
            joinedload(DrugSchedule.drug).joinedload(DrugLocalKuwait.matched_drug),
            joinedload(DrugSchedule.dose_logs),
        )
        .filter(DrugSchedule.id == schedule.id)
        .first()
    )
    return schedule


@router.post("/schedules/{schedule_id}/log", response_model=DoseLogSchema, status_code=status.HTTP_201_CREATED)
def create_dose_log(
    schedule_id: int,
    payload: DoseLogCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> DoseLogSchema:
    if payload.schedule_id != schedule_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Schedule ID mismatch")

    schedule = (
        db.query(DrugSchedule)
        .options(joinedload(DrugSchedule.patient))
        .filter(DrugSchedule.id == schedule_id)
        .first()
    )
    if not schedule:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Schedule not found")

    if not current_user.is_superuser and schedule.patient.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")

    dose_log = DoseLog(
        schedule_id=schedule_id,
        taken_at=payload.taken_at or datetime.utcnow(),
        taken=payload.taken,
        notes=payload.notes,
    )
    db.add(dose_log)
    db.commit()
    db.refresh(dose_log)
    return dose_log
