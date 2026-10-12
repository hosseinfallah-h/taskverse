"""Business logic for tags."""

import logging
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.tags.models import Tag
from app.modules.tags.schemas import TagCreate, TagUpdate

logger = logging.getLogger("taskverse.tags")


def list_for_user(db: Session, user_id: int) -> list[Tag]:
    stmt = (
        select(Tag)
        .where(Tag.user_id == user_id, Tag.deleted_at.is_(None))
        .order_by(Tag.name)
    )
    return list(db.scalars(stmt).all())


def get(db: Session, user_id: int, tag_id: int) -> Tag | None:
    return db.scalar(
        select(Tag).where(
            Tag.id == tag_id,
            Tag.user_id == user_id,
            Tag.deleted_at.is_(None),
        )
    )


def get_by_name(db: Session, user_id: int, name: str) -> Tag | None:
    return db.scalar(
        select(Tag).where(
            Tag.user_id == user_id,
            Tag.name == name,
            Tag.deleted_at.is_(None),
        )
    )


def create(db: Session, user_id: int, payload: TagCreate) -> Tag:
    name = payload.name.strip().lstrip("@")
    if not name:
        raise AppError("tag name required", 400)
    if get_by_name(db, user_id, name):
        raise AppError("tag already exists", 409)

    tag = Tag(user_id=user_id, name=name, color=payload.color)
    db.add(tag)
    db.commit()
    db.refresh(tag)
    logger.info("tag created", extra={"user_id": user_id, "context": {"id": tag.id, "name": name}})
    return tag


def update(db: Session, tag: Tag, payload: TagUpdate) -> Tag:
    data = payload.model_dump(exclude_unset=True)
    if "name" in data and data["name"]:
        data["name"] = data["name"].strip().lstrip("@")
    for field, value in data.items():
        setattr(tag, field, value)
    db.commit()
    db.refresh(tag)
    return tag


def soft_delete(db: Session, tag: Tag) -> None:
    tag.deleted_at = datetime.now(UTC)
    db.commit()
    logger.info("tag deleted", extra={"user_id": tag.user_id, "context": {"id": tag.id}})
