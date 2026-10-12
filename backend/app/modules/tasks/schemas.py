"""Pydantic schemas for tasks."""

from datetime import date, datetime, time

from pydantic import BaseModel, ConfigDict, Field


# ---------- Tag (embedded, lightweight) ----------
class TagBrief(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    color: str | None


# ---------- Create ----------
class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    project_id: int | None = None
    parent_id: int | None = None
    priority: int = Field(default=2, ge=0, le=3)
    energy: str | None = Field(default=None, pattern="^(high|low|neutral)$")
    due_date: date | None = None
    due_time: time | None = None
    estimated_min: int | None = Field(default=None, ge=0, le=100000)
    rrule: str | None = Field(default=None, max_length=500)
    tag_ids: list[int] = Field(default_factory=list)


# ---------- Update ----------
class TaskUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = None
    project_id: int | None = None
    priority: int | None = Field(default=None, ge=0, le=3)
    energy: str | None = Field(default=None, pattern="^(high|low|neutral)$")
    due_date: date | None = None
    due_time: time | None = None
    estimated_min: int | None = Field(default=None, ge=0)
    actual_min: int | None = Field(default=None, ge=0)
    rrule: str | None = Field(default=None, max_length=500)
    sort_order: int | None = None
    tag_ids: list[int] | None = None


# ---------- Status actions ----------
class TaskStatusUpdate(BaseModel):
    status: str = Field(pattern="^(todo|doing|done|cancelled)$")


class TaskDefer(BaseModel):
    deferred_until: datetime | None = None


# ---------- Read ----------
class TaskPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str | None
    project_id: int | None
    parent_id: int | None
    status: str
    priority: int
    energy: str | None
    due_date: date | None
    due_time: time | None
    estimated_min: int | None
    actual_min: int
    rrule: str | None
    deferred_until: datetime | None
    completed_at: datetime | None
    sort_order: int
    created_at: datetime
    updated_at: datetime


class TaskWithTags(TaskPublic):
    tags: list[TagBrief] = Field(default_factory=list)
    subtasks_count: int = 0
    subtasks_done: int = 0
