"""Pydantic schemas for people."""

from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field


class TagBrief(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    color: str | None


class PersonCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    nickname: str | None = Field(default=None, max_length=100)
    phone: str | None = Field(default=None, max_length=20)
    email: str | None = Field(default=None, max_length=255)
    birthday: date | None = None
    notes: str | None = None
    relationship: str = Field(default="friend", pattern="^(friend|family|colleague|client|other)$")
    tag_ids: list[int] = Field(default_factory=list)


class PersonUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    nickname: str | None = Field(default=None, max_length=100)
    phone: str | None = Field(default=None, max_length=20)
    email: str | None = Field(default=None, max_length=255)
    birthday: date | None = None
    notes: str | None = None
    relationship: str | None = Field(default=None, pattern="^(friend|family|colleague|client|other)$")
    sort_order: int | None = None
    tag_ids: list[int] | None = None


class PersonPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    nickname: str | None
    phone: str | None
    email: str | None
    birthday: date | None
    avatar_path: str | None
    notes: str | None
    relationship: str
    sort_order: int
    created_at: datetime
    updated_at: datetime


class PersonWithTags(PersonPublic):
    tags: list[TagBrief] = Field(default_factory=list)
    days_until_birthday: int | None = None


class UpcomingBirthday(BaseModel):
    person: PersonPublic
    days_until: int
    next_birthday: date
