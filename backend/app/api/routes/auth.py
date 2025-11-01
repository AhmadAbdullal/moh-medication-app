import json
from datetime import datetime, timedelta
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.core.config import get_settings
from app.core.security import create_access_token, get_password_hash, verify_password
from app.models.provenance import Provenance
from app.models.user import User
from app.schemas.token import EmailLogin, OTPChallenge, OTPVerify, PhoneLoginRequest, Token

router = APIRouter(prefix="/auth", tags=["auth"])
settings = get_settings()
OTP_EXPIRATION_MINUTES = 5


@router.post("/login-phone", response_model=OTPChallenge)
def login_phone(data: PhoneLoginRequest, db: Session = Depends(deps.get_db)) -> OTPChallenge:
    phone_number = data.phone_number
    if not phone_number:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Phone number required")

    user = db.query(User).filter(User.phone_number == phone_number).first()
    if not user:
        user = User(phone_number=phone_number, is_active=True)
        db.add(user)
        db.commit()
        db.refresh(user)

    code = f"{uuid4().int % 1000000:06d}"
    expires_at = datetime.utcnow() + timedelta(minutes=OTP_EXPIRATION_MINUTES)
    request_id = uuid4().hex

    provenance = Provenance(
        entity_type="otp",
        entity_id=user.id,
        source="auth.login_phone",
        notes=json.dumps(
            {
                "phone_number": phone_number,
                "code_hash": get_password_hash(code),
                "request_id": request_id,
                "expires_at": expires_at.isoformat(),
            }
        ),
    )
    db.add(provenance)
    db.commit()

    return OTPChallenge(
        phone_number=phone_number,
        message="OTP generated successfully",
        expires_at=expires_at,
        request_id=request_id,
        debug_code=code if settings.debug else None,
    )


@router.post("/verify-otp", response_model=Token)
def verify_otp(payload: OTPVerify, db: Session = Depends(deps.get_db)) -> Token:
    phone_number = payload.phone_number
    if not phone_number:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Phone number required")

    user = db.query(User).filter(User.phone_number == phone_number).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    query = (
        db.query(Provenance)
        .filter(
            Provenance.entity_id == user.id,
            Provenance.entity_type == "otp",
        )
        .order_by(Provenance.fetched_at.desc())
    )

    bind = db.get_bind()
    if bind is not None and bind.dialect.name != "sqlite":
        query = query.with_for_update()

    provenance_entries = query.all()

    provenance = None
    for entry in provenance_entries:
        if not entry.notes:
            continue
        try:
            metadata = json.loads(entry.notes)
        except json.JSONDecodeError:
            continue
        if metadata.get("request_id") == payload.request_id:
            provenance = (entry, metadata)
            break

    if not provenance:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid request")

    entry, metadata = provenance
    if metadata.get("used_at"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP already used")

    expires_at_str = metadata.get("expires_at")
    if not expires_at_str or datetime.fromisoformat(expires_at_str) < datetime.utcnow():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP expired")

    code_hash = metadata.get("code_hash")
    if not code_hash or not verify_password(payload.code, code_hash):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    access_token = create_access_token(subject=user.id, is_superuser=user.is_superuser)
    metadata["used_at"] = datetime.utcnow().isoformat()
    entry.notes = json.dumps(metadata)
    db.add(entry)
    db.commit()

    return Token(access_token=access_token)


@router.post("/login-email", response_model=Token)
def login_email(payload: EmailLogin, db: Session = Depends(deps.get_db)) -> Token:
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not user.hashed_password:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    if not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    access_token = create_access_token(subject=user.id, is_superuser=user.is_superuser)
    return Token(access_token=access_token)
