from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class Provenance(Base):
    __tablename__ = "provenance"

    id = Column(Integer, primary_key=True, index=True)
    entity_type = Column(String, nullable=False)
    entity_id = Column(Integer, nullable=True)
    source = Column(String, nullable=False)
    fetched_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    verified_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    notes = Column(Text, nullable=True)

    verifier = relationship("User", back_populates="provenance_entries")
