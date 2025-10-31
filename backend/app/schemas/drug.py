from datetime import datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import BaseModel, Field


class DrugMasterBase(BaseModel):
    rx_cui: Optional[str] = None
    trade_name_en: Optional[str] = None
    trade_name_ar: Optional[str] = None
    generic_name: Optional[str] = None
    strength: Optional[str] = None
    dosage_form: Optional[str] = None
    source: Optional[str] = None
    source_url: Optional[str] = None
    source_version: Optional[str] = None
    verified_status: str = Field(default="unverified")


class DrugMasterCreate(DrugMasterBase):
    pass


class DrugMaster(DrugMasterBase):
    id: int
    last_updated: datetime

    class Config:
        orm_mode = True


class DrugLocalBase(BaseModel):
    moh_code: str
    trade_name_ar: Optional[str] = None
    generic_name: Optional[str] = None
    strength: Optional[str] = None
    dosage_form: Optional[str] = None
    source_file: Optional[str] = None
    match_confidence: Optional[Decimal] = None


class DrugLocalCreate(DrugLocalBase):
    matched_drug_id: Optional[int] = None


class DrugLocal(DrugLocalBase):
    id: int
    extracted_at: datetime
    matched_drug_id: Optional[int] = None
    verified_status: str = Field(default="unverified")
    matched_drug: Optional[DrugMaster] = None

    class Config:
        orm_mode = True


class DrugSimple(BaseModel):
    id: int
    moh_code: str
    trade_name_ar: Optional[str] = None
    trade_name_en: Optional[str] = None
    generic_name: Optional[str] = None
    strength: Optional[str] = None
    dosage_form: Optional[str] = None
    verified_status: str = Field(default="unverified")

    class Config:
        orm_mode = True


class DrugImportPayload(BaseModel):
    local_id: int
    master: DrugMasterCreate
    match_confidence: Optional[Decimal] = None


class DrugImportRequest(BaseModel):
    items: List[DrugImportPayload]
