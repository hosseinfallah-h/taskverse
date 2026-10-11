"""User endpoints — authenticated."""

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_admin, get_current_user
from app.modules.users import service
from app.modules.users.models import User
from app.modules.users.schemas import UserMe, UserTierUpdate, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])

MAX_AVATAR_BYTES = 5 * 1024 * 1024  # 5 MB
ALLOWED_AVATAR_MIME = {"image/jpeg", "image/png", "image/webp"}


@router.get("/me", response_model=UserMe)
def read_me(current_user: User = Depends(get_current_user)) -> UserMe:
    """Return the current user."""
    return UserMe.model_validate(current_user)


@router.patch("/me", response_model=UserMe)
def update_me(
    payload: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMe:
    """Update current user."""
    user = service.update_me(db, current_user, payload)
    return UserMe.model_validate(user)


@router.post("/me/avatar", response_model=UserMe)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMe:
    """Upload + optimize avatar."""
    if file.content_type not in ALLOWED_AVATAR_MIME:
        raise HTTPException(status_code=415, detail="unsupported image type")

    raw = await file.read()
    if len(raw) > MAX_AVATAR_BYTES:
        raise HTTPException(status_code=413, detail="avatar too large (max 5MB)")

    path = service.save_avatar(current_user.id, raw, file.filename or "avatar")
    current_user.avatar_path = path
    db.commit()
    db.refresh(current_user)
    return UserMe.model_validate(current_user)


@router.post("/{user_id}/tier", response_model=UserMe)
def set_tier(
    user_id: int,
    payload: UserTierUpdate,
    _: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
) -> UserMe:
    """Admin-only: change a user's tier."""
    user = service.get_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="user not found")
    user = service.set_tier(db, user, payload.tier)
    return UserMe.model_validate(user)