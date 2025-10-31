from datetime import datetime
from typing import Optional

from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class DrugMaster(Base):
    __tablename__ = "drugs_master"

    id = Column(Integer, primary_key=True, index=True)
    rx_cui = Column(String, unique=True, index=True, nullable=True)
    trade_name_en = Column(String, nullable=True)
    trade_name_ar = Column(String, nullable=True)
    generic_name = Column(String, nullable=True)
    strength = Column(String, nullable=True)
    dosage_form = Column(String, nullable=True)
    source = Column(String, nullable=True)
    source_url = Column(String, nullable=True)
    source_version = Column(String, nullable=True)
    verified_status = Column(String, nullable=False, default="unverified")
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    local_variants = relationship("DrugLocalKuwait", back_populates="matched_drug")


class DrugLocalKuwait(Base):
    __tablename__ = "drugs_local_kuwait"

    id = Column(Integer, primary_key=True, index=True)
    moh_code = Column(String, unique=True, nullable=False)
    trade_name_ar = Column(String, nullable=True)
    generic_name = Column(String, nullable=True)
    strength = Column(String, nullable=True)
    dosage_form = Column(String, nullable=True)
    source_file = Column(String, nullable=True)
    extracted_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    matched_drug_id = Column(Integer, ForeignKey("drugs_master.id"), nullable=True)
    match_confidence = Column(Numeric(4, 3), nullable=True)

    matched_drug = relationship("DrugMaster", back_populates="local_variants")
    schedules = relationship("DrugSchedule", back_populates="drug")

    @property
    def verified_status(self) -> str:
        if self.matched_drug and self.matched_drug.verified_status:
            return self.matched_drug.verified_status
        return "unverified"

    @property
    def trade_name_display(self) -> Optional[str]:
        return self.trade_name_ar or (self.matched_drug.trade_name_en if self.matched_drug else None)

    @property
    def trade_name_en(self) -> Optional[str]:
        return self.matched_drug.trade_name_en if self.matched_drug else None
