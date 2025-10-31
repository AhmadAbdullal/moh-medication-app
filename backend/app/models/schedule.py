from datetime import datetime

from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Time
from sqlalchemy.orm import relationship

from app.db.base import Base


class DrugSchedule(Base):
    __tablename__ = "drug_schedules"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)
    drug_id = Column(Integer, ForeignKey("drugs_local_kuwait.id"), nullable=False)
    dosage = Column(String, nullable=False)
    frequency = Column(String, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    instructions = Column(String, nullable=True)
    reminder_time = Column(Time, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    patient = relationship("Patient", back_populates="schedules")
    drug = relationship("DrugLocalKuwait", back_populates="schedules")
    dose_logs = relationship("DoseLog", back_populates="schedule")


class DoseLog(Base):
    __tablename__ = "dose_logs"

    id = Column(Integer, primary_key=True, index=True)
    schedule_id = Column(Integer, ForeignKey("drug_schedules.id"), nullable=False)
    taken_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    taken = Column(Boolean, default=True, nullable=False)
    notes = Column(String, nullable=True)
    recorded_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    schedule = relationship("DrugSchedule", back_populates="dose_logs")
