"""Auth schemas."""

from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    name: str = Field(min_length=1, max_length=100)


class RegisterResponse(BaseModel):
    ok: bool = True
    message: str = "OTP sent"
    dev_otp: str | None = None  # ONLY populated when DEBUG=true and SMS not delivered


class VerifyOtpRequest(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    code: str = Field(min_length=4, max_length=8)
    password: str = Field(min_length=8, max_length=128)
    name: str = Field(min_length=1, max_length=100)


class LoginRequest(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    password: str = Field(min_length=8, max_length=128)


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=20)


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class MeBrief(BaseModel):
    id: int
    phone: str
    name: str
    tier: str
