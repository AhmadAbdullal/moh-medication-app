import json
from datetime import datetime, timedelta

import pytest

pytest.importorskip("sqlalchemy")
pytest.importorskip("fastapi")
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.api.routes.auth import verify_otp
from app.core.security import get_password_hash
from app.db.base import Base
from app.models.provenance import Provenance
from app.models.user import User
from app.schemas.token import OTPVerify


@pytest.fixture()
def session():
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    TestingSessionLocal = sessionmaker(bind=engine)
    Base.metadata.create_all(bind=engine)
    db_session = TestingSessionLocal()
    try:
        yield db_session
    finally:
        db_session.close()


def _create_user_with_otp(session, code: str = "123456"):
    user = User(phone_number="96555500001", is_active=True)
    session.add(user)
    session.commit()
    session.refresh(user)

    request_id = "req-123"
    metadata = {
        "phone_number": user.phone_number,
        "code_hash": get_password_hash(code),
        "request_id": request_id,
        "expires_at": (datetime.utcnow() + timedelta(minutes=5)).isoformat(),
    }
    provenance = Provenance(
        entity_type="otp",
        entity_id=user.id,
        source="test",
        notes=json.dumps(metadata),
    )
    session.add(provenance)
    session.commit()

    return user, request_id, code


def test_verify_otp_marks_code_as_used(session):
    user, request_id, code = _create_user_with_otp(session)

    payload = OTPVerify(phone_number=user.phone_number, request_id=request_id, code=code)
    verify_otp(payload, db=session)

    provenance_entry = session.query(Provenance).filter(Provenance.entity_id == user.id).first()
    metadata = json.loads(provenance_entry.notes)

    assert metadata.get("used_at") is not None


def test_verify_otp_rejects_reuse(session):
    user, request_id, code = _create_user_with_otp(session)
    payload = OTPVerify(phone_number=user.phone_number, request_id=request_id, code=code)

    verify_otp(payload, db=session)

    with pytest.raises(Exception) as excinfo:
        verify_otp(payload, db=session)

    assert getattr(excinfo.value, "status_code", None) == 400
    assert "used" in getattr(excinfo.value, "detail", "").lower()
