from datetime import datetime

from pydantic import BaseModel


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: int
    exp: datetime
    is_superuser: bool = False


class PhoneLoginRequest(BaseModel):
    phone_number: str


class OTPChallenge(BaseModel):
    phone_number: str
    message: str
    expires_at: datetime
    request_id: str
    debug_code: str | None = None


class OTPVerify(BaseModel):
    phone_number: str
    code: str
    request_id: str


class EmailLogin(BaseModel):
    email: str
    password: str
