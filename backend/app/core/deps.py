"""FastAPI dependencies: current user, admin guard."""

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_token
from app.modules.users.models import User

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_user(
    request: Request,
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    """Resolve the authenticated user from a Bearer JWT.

    Attaches user_id to request context for downstream logging.
    """
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="missing authorization",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        payload = decode_token(credentials.credentials)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e

    if payload.get("type") != "access":
        raise HTTPException(status_code=401, detail="wrong token type")

    try:
        user_id = int(payload.get("sub"))
    except (TypeError, ValueError) as e:
        raise HTTPException(status_code=401, detail="invalid subject") from e

    user = db.get(User, user_id)
    if not user or user.deleted_at is not None:
        raise HTTPException(status_code=401, detail="user not found")
    if user.tier == "banned":
        raise HTTPException(status_code=403, detail="account banned")

    # Attach to context for logging
    from app.core import request_context as ctx

    ctx.set_user_id(user.id)

    return user


def get_current_admin(
    user: User = Depends(get_current_user),
) -> User:
    """Only allow users with tier='admin'."""
    if user.tier != "admin":
        raise HTTPException(status_code=403, detail="admin only")
    return user
