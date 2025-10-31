"""Seed script to insert sample Kuwait-specific drug data."""

from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.drug import DrugLocalKuwait

SAMPLE_DRUGS = [
    {
        "moh_code": "KUW-001",
        "trade_name_ar": "باراسيتامول 500 مجم",
        "generic_name": "Paracetamol",
        "strength": "500mg",
        "dosage_form": "Tablet",
        "source_file": "sample.csv",
    },
    {
        "moh_code": "KUW-002",
        "trade_name_ar": "أموكسيسيلين 250 مجم",
        "generic_name": "Amoxicillin",
        "strength": "250mg",
        "dosage_form": "Capsule",
        "source_file": "sample.csv",
    },
    {
        "moh_code": "KUW-003",
        "trade_name_ar": "سالبيوتامول بخاخ",
        "generic_name": "Salbutamol",
        "strength": "100mcg",
        "dosage_form": "Inhaler",
        "source_file": "sample.csv",
    },
]


def seed_drugs(session: Session) -> None:
    for drug in SAMPLE_DRUGS:
        exists = session.query(DrugLocalKuwait).filter(DrugLocalKuwait.moh_code == drug["moh_code"]).first()
        if exists:
            continue
        session.add(DrugLocalKuwait(**drug))
    session.commit()


if __name__ == "__main__":
    with SessionLocal() as session:
        seed_drugs(session)
        print(f"Seeded {len(SAMPLE_DRUGS)} Kuwait drugs")
