"""Auth endpoints.

Registration flow:
1. POST /auth/register   -> creates OTP. In dev, returns dev_otp.
2. POST /auth/verify-otp -> verifies OTP, sets password, returns tokens.
3. POST /auth/login      -> password login.
4. POST /auth/refresh    -> rotate refresh token.
5. GET  /auth/me         -> current user (auth-guarded; wiring next).
"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.modules.auth import service
from app.modules.auth.schemas import (
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    RegisterResponse,
    TokenPair,
    VerifyOtpRequest,
)
from app.modules.auth.sms import send_otp
from app.modules.users.models import User
from app.modules.users.schemas import UserMe

logger = logging.getLogger("taskverse.auth")
router = APIRouter(prefix="/auth", tags=["auth"])


def _client_ip(request: Request) -> str | None:
    """Extract client IP for audit + token storage."""
    return request.client.host if request.client else None


def _ua(request: Request) -> str | None:
    """Extract user agent for audit + token storage."""
    return request.headers.get("user-agent")


# ---------- Registration ----------

@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_200_OK,
    summary="Start registration — create OTP",
)
async def register(
    payload: RegisterRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> RegisterResponse:
    """Create an OTP for the phone number.

    Dev behavior (DEBUG=true, no SMS provider):
      - Returns `dev_otp` in the response so you can test locally.

    Production behavior (SMS provider configured):
      - Sends SMS; does NOT return the code.
    """
    code = service.create_or_update_otp(db, payload.phone, purpose="register")
    result = await send_otp(payload.phone, code)

    if result.sent:
        return RegisterResponse(ok=True, message="OTP sent")

    if settings.debug and result.dev_code:
        return RegisterResponse(
            ok=True,
            message="SMS provider disabled — dev OTP returned",
            dev_otp=result.dev_code,
        )

    # Production + no SMS delivered
    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="SMS provider unavailable. Please try again shortly.",
    )


@router.post(
    "/verify-otp",
    response_model=TokenPair,
    summary="Verify OTP, set password, return tokens",
)
def verify_otp(
    payload: VerifyOtpRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> TokenPair:
    """Complete registration: verify OTP, hash password, issue tokens."""
    user = service.complete_registration(
        db=db,
        phone=payload.phone,
        code=payload.code,
        password=payload.password,
        name=payload.name,
    )
    tokens = service.issue_tokens(
        db=db,
        user=user,
        ip=_client_ip(request),
        user_agent=_ua(request),
    )
    return TokenPair(**tokens)


# ---------- Sessions ----------

@router.post("/login", response_model=TokenPair, summary="Password login")
def login(
    payload: LoginRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> TokenPair:
    """Authenticate with phone + password."""
    user = service.login_with_password(db, payload.phone, payload.password)
    tokens = service.issue_tokens(
        db=db,
        user=user,
        ip=_client_ip(request),
        user_agent=_ua(request),
    )
    return TokenPair(**tokens)


@router.post("/refresh", response_model=TokenPair, summary="Rotate refresh token")
def refresh(
    payload: RefreshRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> TokenPair:
    """Consume a refresh token and issue a new pair."""
    tokens = service.rotate_refresh(
        db=db,
        raw_refresh=payload.refresh_token,
        ip=_client_ip(request),
        user_agent=_ua(request),
    )
    return TokenPair(**tokens)


# ---------- Current user (TEMP until real JWT dependency) ----------

@router.get(
    "/me",
    response_model=UserMe,
    summary="Current user (TEMP: first user in DB)",
)
def me(db: Session = Depends(get_db)) -> UserMe:
    """TEMP: returns the first user in the DB.

    Replaced by real JWT dependency in the next step of Sprint 1.
    """
    user = db.query(User).first()
    if not user:
        raise HTTPException(status_code=404, detail="no users yet")
    return UserMe.model_validate(user)
