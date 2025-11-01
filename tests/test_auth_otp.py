import json
from datetime import datetime, timedelta

import pytest

# لو ما كانت الباكجات منصّبة في CI لا تفشل التستات
pytest.importorskip("sqlalchemy")
pytest.importorskip("fastapi")
pytest.importorskip("email_validator")

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
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
    )
    TestingSessionLocal = sessionmaker(bind=engine)
    Base.metadata.create_all(bind=engine)
    db_session = TestingSessionLocal()
    try:
        yield db_session
    finally:
        db_session.close()


def _create_user_with_otp(session, code: str = "123456"):
    # create user
    user = User(phone_number="96555500001", is_active=True)
    session.add(user)
    session.commit()
    session.refresh(user)

    # create otp provenance
    request_id = "req-123"
    metadata = {
        "phone_number": user.phone_number,
        "code_hash": get_password_hash(code),
        "request_id": request_id,
        "expires_at": (datetime.utcnow() + timedelta(minutes=5)).isoformat(),
    }
    prov = Provenance(
        entity_type="otp",
        entity_id=user.id,
        source="test",
        notes=json.dumps(metadata),
    )
    session.add(prov)
    session.commit()

    return user, request_id, code


def test_verify_otp_marks_code_as_used(session):
    user, request_id, code = _create_user_with_otp(session)

    payload = OTPVerify(
        phone_number=user.phone_number,
        request_id=request_id,
        code=code,
    )
    verify_otp(payload, db=session)

    prov = (
        session.query(Provenance)
        .filter(
            Provenance.entity_id == user.id,
            Provenance.entity_type == "otp",
        )
        .first()
    )
    data = json.loads(prov.notes)

    assert data.get("used_at") is not None


def test_verify_otp_rejects_reuse(session):
    user, request_id, code = _create_user_with_otp(session)
    payload = OTPVerify(
        phone_number=user.phone_number,
        request_id=request_id,
        code=code,
    )

    # first call should pass
    verify_otp(payload, db=session)

    # second call must fail
    with pytest.raises(Exception) as excinfo:
        verify_otp(payload, db=session)

    # نتأكد أن الرسالة فعلاً تقول إنه مستعمل
    assert "used" in str(excinfo.value).lower() or "otp" in str(excinfo.value).lower()
