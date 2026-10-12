"""Business logic for people."""

import io
import logging
from datetime import UTC, date, datetime
from pathlib import Path

from PIL import Image
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError
from app.modules.people.models import Person, person_tags
from app.modules.people.schemas import PersonCreate, PersonUpdate
from app.modules.tags.models import Tag

logger = logging.getLogger("taskverse.people")

AVATAR_SIZE = (512, 512)
AVATAR_QUALITY = 85


# ---------- Helpers ----------

def _now() -> datetime:
    return datetime.now(UTC)


def _attach_tags(db: Session, person: Person, tag_ids: list[int], user_id: int) -> None:
    if not tag_ids:
        db.execute(person_tags.delete().where(person_tags.c.person_id == person.id))
        return
    rows = db.scalars(
        select(Tag.id).where(
            Tag.id.in_(tag_ids),
            Tag.user_id == user_id,
            Tag.deleted_at.is_(None),
        )
    ).all()
    valid_ids = set(rows)
    db.execute(person_tags.delete().where(person_tags.c.person_id == person.id))
    if valid_ids:
        db.execute(
            person_tags.insert(),
            [{"person_id": person.id, "tag_id": tid} for tid in valid_ids],
        )


def tags_for(db: Session, person_id: int) -> list[Tag]:
    stmt = (
        select(Tag)
        .join(person_tags, person_tags.c.tag_id == Tag.id)
        .where(person_tags.c.person_id == person_id, Tag.deleted_at.is_(None))
    )
    return list(db.scalars(stmt).all())


def days_until_birthday(birthday: date | None) -> int | None:
    """Days until next occurrence of the birthday, or None."""
    if birthday is None:
        return None
    today = date.today()
    try:
        this_year = birthday.replace(year=today.year)
    except ValueError:
        # Feb 29 in a non-leap year
        this_year = date(today.year, 3, 1)
    if this_year < today:
        try:
            next_year = birthday.replace(year=today.year + 1)
        except ValueError:
            next_year = date(today.year + 1, 3, 1)
        return (next_year - today).days
    return (this_year - today).days


# ---------- CRUD ----------

def list_for_user(db: Session, user_id: int, relationship: str | None = None) -> list[Person]:
    stmt = select(Person).where(
        Person.user_id == user_id, Person.deleted_at.is_(None)
    )
    if relationship:
        stmt = stmt.where(Person.relationship == relationship)
    stmt = stmt.order_by(Person.sort_order, Person.name)
    return list(db.scalars(stmt).all())


def get(db: Session, user_id: int, person_id: int) -> Person | None:
    return db.scalar(
        select(Person).where(
            Person.id == person_id,
            Person.user_id == user_id,
            Person.deleted_at.is_(None),
        )
    )


def create(db: Session, user_id: int, payload: PersonCreate) -> Person:
    person = Person(
        user_id=user_id,
        name=payload.name,
        nickname=payload.nickname,
        phone=payload.phone,
        email=payload.email,
        birthday=payload.birthday,
        notes=payload.notes,
        relationship=payload.relationship,
    )
    db.add(person)
    db.flush()
    _attach_tags(db, person, payload.tag_ids, user_id)
    db.commit()
    db.refresh(person)
    logger.info("person created", extra={"user_id": user_id, "context": {"id": person.id}})
    return person


def update(db: Session, person: Person, payload: PersonUpdate) -> Person:
    data = payload.model_dump(exclude_unset=True)
    tag_ids = data.pop("tag_ids", None)
    for field, value in data.items():
        setattr(person, field, value)
    if tag_ids is not None:
        _attach_tags(db, person, tag_ids, person.user_id)
    db.commit()
    db.refresh(person)
    logger.info("person updated", extra={"user_id": person.user_id, "context": {"id": person.id}})
    return person


def soft_delete(db: Session, person: Person) -> None:
    person.deleted_at = _now()
    db.commit()
    logger.info("person deleted", extra={"user_id": person.user_id, "context": {"id": person.id}})


def save_avatar(person_id: int, raw: bytes) -> str:
    try:
        img = Image.open(io.BytesIO(raw))
    except Exception as e:
        raise AppError("invalid image", 400) from e

    img = img.convert("RGB")
    img.thumbnail(AVATAR_SIZE, Image.Resampling.LANCZOS)
    min_side = min(img.size)
    left = (img.width - min_side) // 2
    top = (img.height - min_side) // 2
    img = img.crop((left, top, left + min_side, top + min_side))
    img = img.resize(AVATAR_SIZE, Image.Resampling.LANCZOS)

    rel_dir = Path(settings.attachments_dir) / "people" / str(person_id)
    rel_dir.mkdir(parents=True, exist_ok=True)
    rel_path = rel_dir / "avatar.webp"
    img.save(rel_path, "WEBP", quality=AVATAR_QUALITY, method=6)
    return str(rel_path).replace("\\", "/")


# ---------- Birthdays ----------

def upcoming_birthdays(db: Session, user_id: int, within_days: int = 30) -> list[dict]:
    people = list_for_user(db, user_id)
    upcoming: list[dict] = []
    for p in people:
        d = days_until_birthday(p.birthday)
        if d is not None and 0 <= d <= within_days:
            today = date.today()
            try:
                nb = p.birthday.replace(year=today.year)
            except ValueError:
                nb = date(today.year, 3, 1)
            if nb < today:
                try:
                    nb = p.birthday.replace(year=today.year + 1)
                except ValueError:
                    nb = date(today.year + 1, 3, 1)
            upcoming.append({"person": p, "days_until": d, "next_birthday": nb})
    upcoming.sort(key=lambda x: x["days_until"])
    return upcoming
