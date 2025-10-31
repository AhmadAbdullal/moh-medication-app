from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.models.drug import DrugLocalKuwait, DrugMaster
from app.models.user import User
from app.schemas.drug import DrugImportRequest, DrugLocal

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/drugs/unmatched", response_model=List[DrugLocal])
def list_unmatched_drugs(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> List[DrugLocal]:
    del current_user
    drugs = (
        db.query(DrugLocalKuwait)
        .filter(DrugLocalKuwait.matched_drug_id.is_(None))
        .order_by(DrugLocalKuwait.trade_name_ar.asc(), DrugLocalKuwait.moh_code.asc())
        .all()
    )
    return drugs


@router.post("/drugs/import", response_model=List[DrugLocal], status_code=status.HTTP_201_CREATED)
def import_drugs(
    payload: DrugImportRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_superuser),
) -> List[DrugLocal]:
    del current_user
    imported: List[DrugLocalKuwait] = []

    for item in payload.items:
        local = db.query(DrugLocalKuwait).filter(DrugLocalKuwait.id == item.local_id).first()
        if not local:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Local drug {item.local_id} not found")

        master_data = item.master.dict()
        master: DrugMaster
        if master_data.get("rx_cui"):
            master = (
                db.query(DrugMaster)
                .filter(DrugMaster.rx_cui == master_data["rx_cui"])
                .first()
            )
            if master:
                for key, value in master_data.items():
                    if value is not None:
                        setattr(master, key, value)
            else:
                master = DrugMaster(**master_data)
                db.add(master)
                db.flush()
        else:
            master = DrugMaster(**master_data)
            db.add(master)
            db.flush()

        local.matched_drug_id = master.id
        local.match_confidence = item.match_confidence
        imported.append(local)

    db.commit()
    for local in imported:
        db.refresh(local)
    return imported
