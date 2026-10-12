"""People endpoints - authenticated."""

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.modules.people import service
from app.modules.people.schemas import (
    PersonCreate,
    PersonPublic,
    PersonUpdate,
    PersonWithTags,
    TagBrief,
    UpcomingBirthday,
)
from app.modules.users.models import User

router = APIRouter(prefix="/people", tags=["people"])

MAX_AVATAR_BYTES = 5 * 1024 * 1024
ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp"}


def _to_dict(db: Session, person, with_meta: bool = True) -> dict:
    base = PersonPublic.model_validate(person).model_dump()
    if with_meta:
        tags = service.tags_for(db, person.id)
        base["tags"] = [TagBrief.model_validate(t).model_dump() for t in tags]
        base["days_until_birthday"] = service.days_until_birthday(person.birthday)
    return base


@router.get("", response_model=list[PersonWithTags])
def list_people(
    relationship: str | None = Query(None, pattern="^(friend|family|colleague|client|other)$"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[PersonWithTags]:
    people = service.list_for_user(db, current_user.id, relationship=relationship)
    return [PersonWithTags(**(_to_dict(db, p))) for p in people]


@router.post("", response_model=PersonWithTags, status_code=status.HTTP_201_CREATED)
def create_person(
    payload: PersonCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PersonWithTags:
    person = service.create(db, current_user.id, payload)
    return PersonWithTags(**(_to_dict(db, person)))


@router.get("/birthdays", response_model=list[UpcomingBirthday])
def upcoming_birthdays(
    within_days: int = Query(30, ge=0, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[UpcomingBirthday]:
    items = service.upcoming_birthdays(db, current_user.id, within_days=within_days)
    return [
        UpcomingBirthday(
            person=PersonPublic.model_validate(item["person"]),
            days_until=item["days_until"],
            next_birthday=item["next_birthday"],
        )
        for item in items
    ]


@router.get("/{person_id}", response_model=PersonWithTags)
def get_person(
    person_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PersonWithTags:
    person = service.get(db, current_user.id, person_id)
    if not person:
        raise HTTPException(status_code=404, detail="person not found")
    return PersonWithTags(**(_to_dict(db, person)))


@router.patch("/{person_id}", response_model=PersonWithTags)
def update_person(
    person_id: int,
    payload: PersonUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PersonWithTags:
    person = service.get(db, current_user.id, person_id)
    if not person:
        raise HTTPException(status_code=404, detail="person not found")
    person = service.update(db, person, payload)
    return PersonWithTags(**(_to_dict(db, person)))


@router.delete("/{person_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_person(
    person_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    person = service.get(db, current_user.id, person_id)
    if not person:
        raise HTTPException(status_code=404, detail="person not found")
    service.soft_delete(db, person)


@router.post("/{person_id}/avatar", response_model=PersonWithTags)
async def upload_avatar(
    person_id: int,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PersonWithTags:
    if file.content_type not in ALLOWED_MIME:
        raise HTTPException(status_code=415, detail="unsupported image type")
    raw = await file.read()
    if len(raw) > MAX_AVATAR_BYTES:
        raise HTTPException(status_code=413, detail="avatar too large (max 5MB)")

    person = service.get(db, current_user.id, person_id)
    if not person:
        raise HTTPException(status_code=404, detail="person not found")

    path = service.save_avatar(person.id, raw)
    person.avatar_path = path
    db.commit()
    db.refresh(person)
    return PersonWithTags(**(_to_dict(db, person)))
