"""Auth business logic."""

import logging
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.core.security import (
    create_access_token,
    hash_otp,
    hash_password,
    hash_refresh_token,
    new_otp_code,
    new_refresh_token,
    verify_password,
)
from app.modules.auth.models import OtpCode, RefreshToken
from app.modules.users.models import User

logger = logging.getLogger("taskverse.auth")


def _now() -> datetime:
    return datetime.now(UTC)


# ---------- Registration / OTP ----------

def create_or_update_otp(db: Session, phone: str, purpose: str = "register") -> str:
    """Generate an OTP, store its hash, return the raw code (for SMS)."""
    code = new_otp_code()

    # Invalidate previous unused OTPs for this phone+purpose
    db.query(OtpCode).filter(
        OtpCode.phone == phone,
        OtpCode.purpose == purpose,
        OtpCode.used_at.is_(None),
    ).update({"used_at": _now()})

    otp = OtpCode(
        phone=phone,
        code_hash=hash_otp(phone, code),
        purpose=purpose,
        max_attempts=settings.sms_otp_max_attempts,
        expires_at=_now() + timedelta(seconds=settings.sms_otp_ttl_seconds),
    )
    db.add(otp)
    db.commit()

    logger.info(
        "otp created",
        extra={"context": {"phone": phone, "purpose": purpose}},
    )
    return code


def verify_otp(db: Session, phone: str, code: str, purpose: str = "register") -> None:
    """Raise AppError if the code is wrong/expired/used."""
    otp = db.scalar(
        select(OtpCode)
        .where(
            OtpCode.phone == phone,
            OtpCode.purpose == purpose,
            OtpCode.used_at.is_(None),
        )
        .order_by(OtpCode.created_at.desc())
    )
    if not otp:
        raise AppError("no active OTP for this phone", 400)

    if otp.expires_at < _now():
        raise AppError("OTP expired", 400)

    if otp.attempts >= otp.max_attempts:
        raise AppError("too many attempts", 429)

    otp.attempts += 1
    if hash_otp(phone, code) != otp.code_hash:
        db.commit()
        raise AppError("invalid code", 400)

    otp.used_at = _now()
    db.commit()


# ---------- Sessions ----------

def issue_tokens(db: Session, user: User, ip: str | None, user_agent: str | None) -> dict:
    """Create access + refresh tokens."""
    access = create_access_token(user.id, extra={"tier": user.tier})
    raw_refresh, refresh_hash = new_refresh_token()

    rt = RefreshToken(
        user_id=user.id,
        token_hash=refresh_hash,
        expires_at=_now() + timedelta(days=settings.refresh_token_expire_days),
        ip=ip,
        user_agent=(user_agent or "")[:500],
    )
    db.add(rt)
    db.commit()

    logger.info("tokens issued", extra={"user_id": user.id})

    return {
        "access_token": access,
        "refresh_token": raw_refresh,
        "token_type": "bearer",
        "expires_in": settings.access_token_expire_days * 86400,
    }


def rotate_refresh(db: Session, raw_refresh: str, ip: str | None, user_agent: str | None) -> dict:
    """Consume a refresh token, issue a new pair."""
    h = hash_refresh_token(raw_refresh)
    rt = db.scalar(select(RefreshToken).where(RefreshToken.token_hash == h))
    if not rt or rt.revoked_at is not None:
        raise AppError("invalid refresh token", 401)
    if rt.expires_at < _now():
        raise AppError("refresh expired", 401)

    user = db.get(User, rt.user_id)
    if not user or user.deleted_at is not None:
        raise AppError("user not found", 401)
    if user.tier == "banned":
        raise AppError("account banned", 403)

    rt.revoked_at = _now()
    db.commit()
    return issue_tokens(db, user, ip, user_agent)


# ---------- Login ----------

def login_with_password(db: Session, phone: str, password: str) -> User:
    user = db.scalar(select(User).where(User.phone == phone, User.deleted_at.is_(None)))
    if not user or not user.password_hash:
        raise AppError("invalid credentials", 401)
    if not verify_password(password, user.password_hash):
        raise AppError("invalid credentials", 401)
    if user.tier == "banned":
        raise AppError("account banned", 403)
    return user


def complete_registration(db: Session, phone: str, code: str, password: str, name: str) -> User:
    """Verify OTP, create user with hashed password."""
    verify_otp(db, phone, code, purpose="register")
    existing = db.scalar(select(User).where(User.phone == phone))
    if existing:
        existing.password_hash = hash_password(password)
        if not existing.name and name:
            existing.name = name
        existing.tier = existing.tier or "pending"
        db.commit()
        db.refresh(existing)
        return existing

    user = User(
        phone=phone,
        name=name,
        password_hash=hash_password(password),
        tier="pending",
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    logger.info("user registered", extra={"user_id": user.id})
    return user
