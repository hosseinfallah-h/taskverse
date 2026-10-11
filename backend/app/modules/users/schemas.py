"""Pydantic schemas for the users module."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


class UserPublic(BaseModel):
    """Safe-to-return user data."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    phone: str
    name: str
    email: str | None = None
    avatar_path: str | None = None
    timezone: str
    tier: str
    xp: int
    level: int
    brief_hour: int
    recap_hour: int
    created_at: datetime


class UserMe(UserPublic):
    """User data for the owner (self)."""

    bale_chat_id: int | None = None
    last_seen_at: datetime | None = None


class UserUpdate(BaseModel):
    """Fields a user may edit on their own profile."""

    name: str | None = Field(default=None, min_length=1, max_length=100)
    email: str | None = Field(default=None, max_length=255)
    timezone: str | None = Field(default=None, max_length=50)
    brief_hour: int | None = Field(default=None, ge=0, le=23)
    recap_hour: int | None = Field(default=None, ge=0, le=23)

    @field_validator("email")
    @classmethod
    def validate_email(cls, v: str | None) -> str | None:
        if v is None or v == "":
            return None
        if "@" not in v or "." not in v.split("@")[-1]:
            raise ValueError("invalid email")
        return v.strip().lower()


class UserTierUpdate(BaseModel):
    """Admin-only: change a user's tier."""

    tier: str = Field(pattern="^(pending|approved|admin|banned)$")
