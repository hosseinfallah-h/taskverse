"""Business logic for users."""

import io
import logging
from pathlib import Path

from PIL import Image
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.modules.users.models import User
from app.modules.users.schemas import UserUpdate

logger = logging.getLogger("taskverse.users")

AVATAR_SIZE = (512, 512)
AVATAR_QUALITY = 85


def get_by_id(db: Session, user_id: int) -> User | None:
    return db.scalar(select(User).where(User.id == user_id, User.deleted_at.is_(None)))


def get_by_phone(db: Session, phone: str) -> User | None:
    return db.scalar(select(User).where(User.phone == phone, User.deleted_at.is_(None)))


def get_by_bale_chat(db: Session, chat_id: int) -> User | None:
    return db.scalar(
        select(User).where(User.bale_chat_id == chat_id, User.deleted_at.is_(None))
    )


def update_me(db: Session, user: User, payload: UserUpdate) -> User:
    """Patch the given user with allowed fields."""
    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    logger.info("user updated profile", extra={"user_id": user.id})
    return user


def set_tier(db: Session, user: User, tier: str) -> User:
    if tier not in {"pending", "approved", "admin", "banned"}:
        raise AppError("invalid tier", 400)
    user.tier = tier
    db.commit()
    db.refresh(user)
    logger.info(
        "user tier changed",
        extra={"user_id": user.id, "context": {"tier": tier}},
    )
    return user


# ---------- Avatar handling ----------

def save_avatar(user_id: int, raw: bytes, filename: str) -> str:
    """Optimize and store an avatar. Returns relative path."""
    try:
        img = Image.open(io.BytesIO(raw))
    except Exception as e:
        raise AppError("invalid image", 400) from e

    img = img.convert("RGB")
    img.thumbnail(AVATAR_SIZE, Image.Resampling.LANCZOS)

    # Center-crop to square
    min_side = min(img.size)
    left = (img.width - min_side) // 2
    top = (img.height - min_side) // 2
    img = img.crop((left, top, left + min_side, top + min_side))
    img = img.resize(AVATAR_SIZE, Image.Resampling.LANCZOS)

    # Store as WebP
    rel_dir = Path(settings.attachments_dir) / "avatars" / str(user_id)
    rel_dir.mkdir(parents=True, exist_ok=True)
    rel_path = rel_dir / "avatar.webp"

    img.save(rel_path, "WEBP", quality=AVATAR_QUALITY, method=6)

    logger.info(
        "avatar saved",
        extra={
            "user_id": user_id,
            "context": {"path": str(rel_path), "bytes": rel_path.stat().st_size},
        },
    )
    return str(rel_path).replace("\\", "/")
