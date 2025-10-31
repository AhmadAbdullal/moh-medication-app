from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.api import deps
from app.models.drug import DrugLocalKuwait, DrugMaster
from app.models.user import User
from app.schemas.drug import DrugLocal

router = APIRouter(prefix="/drugs", tags=["drugs"])


@router.get("", response_model=List[DrugLocal])
def list_drugs(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> List[DrugLocal]:
    del current_user  # authentication side-effect only
    query = (
        db.query(DrugLocalKuwait)
        .outerjoin(DrugMaster, DrugMaster.id == DrugLocalKuwait.matched_drug_id)
        .options(joinedload(DrugLocalKuwait.matched_drug))
        .order_by(DrugLocalKuwait.trade_name_ar.asc(), DrugLocalKuwait.moh_code.asc())
    )
    query = query.filter(
        or_(
            DrugLocalKuwait.matched_drug_id.is_(None),
            DrugMaster.verified_status == "verified",
        )
    )
    drugs = query.all()
    return drugs


@router.get("/{drug_id}", response_model=DrugLocal)
def get_drug(
    drug_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> DrugLocal:
    del current_user
    drug = (
        db.query(DrugLocalKuwait)
        .options(joinedload(DrugLocalKuwait.matched_drug))
        .filter(DrugLocalKuwait.id == drug_id)
        .first()
    )
    if not drug:
        raise HTTPException(status_code=404, detail="Drug not found")
    if drug.matched_drug_id is not None and drug.verified_status != "verified":
        raise HTTPException(status_code=404, detail="Drug not verified")
    return drug
