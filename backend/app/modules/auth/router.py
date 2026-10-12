"""Auth endpoints.

Registration flow:
1. POST /auth/register   -> creates OTP. In dev, returns dev_otp.
2. POST /auth/verify-otp -> verifies OTP, sets password, returns tokens.
3. POST /auth/login      -> password login.
4. POST /auth/refresh    -> rotate refresh token.
5. GET  /auth/me         -> current user.
"""

import ipaddress
import logging

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.rate_limit import limiter
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
    """Return a valid IP string, or None if unavailable/invalid.

    Starlette's TestClient reports "testclient" as the host - reject it.
    """
    fwd = request.headers.get("x-forwarded-for")
    raw = (
        fwd.split(",")[0].strip()
        if fwd
        else (request.client.host if request.client else None)
    )
    if not raw:
        return None
    try:
        ipaddress.ip_address(raw)
        return raw
    except ValueError:
        return None


def _ua(request: Request) -> str | None:
    return request.headers.get("user-agent")


# ---------- Registration ----------

@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_200_OK,
    summary="Start registration — create OTP",
)
@limiter.limit(settings.rate_limit_auth)
async def register(
    request: Request,
    response: Response,
    payload: RegisterRequest,
    db: Session = Depends(get_db),
) -> RegisterResponse:
    """Create an OTP for the phone number.

    Dev (DEBUG=true, no SMS provider): returns `dev_otp`.
    Prod (SMS provider configured): sends SMS; does NOT return the code.
    """
    code = service.create_or_update_otp(db, payload.phone, purpose="register")
    result = await send_otp(payload.phone, code)

    if result.sent:
        return RegisterResponse(ok=True, message="OTP sent")

    if settings.debug and result.dev_code:
        return RegisterResponse(
            ok=True,
            message="SMS provider disabled - dev OTP returned",
            dev_otp=result.dev_code,
        )

    raise HTTPException(
        status_code=status.HTTP_502_BAD_GATEWAY,
        detail="SMS provider unavailable. Please try again shortly.",
    )


@router.post(
    "/verify-otp",
    response_model=TokenPair,
    summary="Verify OTP, set password, return tokens",
)
@limiter.limit(settings.rate_limit_auth)
def verify_otp(
    request: Request,
    response: Response,
    payload: VerifyOtpRequest,
    db: Session = Depends(get_db),
) -> TokenPair:
    user = service.complete_registration(
        db=db,
        phone=payload.phone,
        code=payload.code,
        password=payload.password,
        name=payload.name,
    )
    tokens = service.issue_tokens(db, user, _client_ip(request), _ua(request))
    return TokenPair(**tokens)


# ---------- Sessions ----------

@router.post("/login", response_model=TokenPair, summary="Password login")
@limiter.limit(settings.rate_limit_auth)
def login(
    request: Request,
    response: Response,
    payload: LoginRequest,
    db: Session = Depends(get_db),
) -> TokenPair:
    user = service.login_with_password(db, payload.phone, payload.password)
    tokens = service.issue_tokens(db, user, _client_ip(request), _ua(request))
    return TokenPair(**tokens)


@router.post("/refresh", response_model=TokenPair, summary="Rotate refresh token")
def refresh(
    request: Request,
    payload: RefreshRequest,
    db: Session = Depends(get_db),
) -> TokenPair:
    tokens = service.rotate_refresh(
        db, payload.refresh_token, _client_ip(request), _ua(request)
    )
    return TokenPair(**tokens)


# ---------- Current user ----------

@router.get("/me", response_model=UserMe, summary="Get the authenticated user")
def me(current_user: User = Depends(get_current_user)) -> UserMe:
    return UserMe.model_validate(current_user)
