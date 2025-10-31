from sqlalchemy import Column, Date, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    full_name = Column(String, nullable=False)
    date_of_birth = Column(Date, nullable=True)
    medical_record_number = Column(String, nullable=True, unique=True)

    user = relationship("User", back_populates="patients")
    schedules = relationship("DrugSchedule", back_populates="patient")
