"""Tag endpoints - authenticated."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.modules.tags import service
from app.modules.tags.schemas import TagCreate, TagPublic, TagUpdate
from app.modules.users.models import User

router = APIRouter(prefix="/tags", tags=["tags"])


@router.get("", response_model=list[TagPublic])
def list_tags(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TagPublic]:
    tags = service.list_for_user(db, current_user.id)
    return [TagPublic.model_validate(t) for t in tags]


@router.post("", response_model=TagPublic, status_code=status.HTTP_201_CREATED)
def create_tag(
    payload: TagCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TagPublic:
    tag = service.create(db, current_user.id, payload)
    return TagPublic.model_validate(tag)


@router.patch("/{tag_id}", response_model=TagPublic)
def update_tag(
    tag_id: int,
    payload: TagUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TagPublic:
    tag = service.get(db, current_user.id, tag_id)
    if not tag:
        raise HTTPException(status_code=404, detail="tag not found")
    tag = service.update(db, tag, payload)
    return TagPublic.model_validate(tag)


@router.delete("/{tag_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tag(
    tag_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    tag = service.get(db, current_user.id, tag_id)
    if not tag:
        raise HTTPException(status_code=404, detail="tag not found")
    service.soft_delete(db, tag)
