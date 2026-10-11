"""User endpoints."""

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.modules.users import service
from app.modules.users.schemas import UserMe, UserTierUpdate, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])

MAX_AVATAR_BYTES = 5 * 1024 * 1024  # 5 MB
ALLOWED_AVATAR_MIME = {"image/jpeg", "image/png", "image/webp"}


def _first_user_or_404(db: Session):
    """TEMP: during Sprint 1 bootstrap, act on the first user."""
    user = db.query(service.User).first()
    if not user:
        raise HTTPException(status_code=404, detail="no users yet")
    return user


@router.get("/me", response_model=UserMe)
def read_me(db: Session = Depends(get_db)) -> UserMe:
    """Return the current user. TEMP: first row."""
    return UserMe.model_validate(_first_user_or_404(db))


@router.patch("/me", response_model=UserMe)
def update_me(payload: UserUpdate, db: Session = Depends(get_db)) -> UserMe:
    """Update current user. TEMP: first row."""
    user = _first_user_or_404(db)
    user = service.update_me(db, user, payload)
    return UserMe.model_validate(user)


@router.post("/me/avatar", response_model=UserMe)
async def upload_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
) -> UserMe:
    """Upload + optimize avatar. TEMP: first row."""
    if file.content_type not in ALLOWED_AVATAR_MIME:
        raise HTTPException(status_code=415, detail="unsupported image type")

    raw = await file.read()
    if len(raw) > MAX_AVATAR_BYTES:
        raise HTTPException(status_code=413, detail="avatar too large (max 5MB)")

    user = _first_user_or_404(db)
    path = service.save_avatar(user.id, raw, file.filename or "avatar")
    user.avatar_path = path
    db.commit()
    db.refresh(user)
    return UserMe.model_validate(user)


@router.post("/{user_id}/tier", response_model=UserMe)
def set_tier(
    user_id: int,
    payload: UserTierUpdate,
    db: Session = Depends(get_db),
) -> UserMe:
    """Admin-only: change a user's tier. (Auth guard added in same sprint.)"""
    user = service.get_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="user not found")
    user = service.set_tier(db, user, payload.tier)
    return UserMe.model_validate(user)
