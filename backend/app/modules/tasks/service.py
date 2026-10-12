"""Business logic for tasks."""

import logging
from datetime import UTC, date, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.tags.models import Tag
from app.modules.tasks.models import Task, task_tags
from app.modules.tasks.schemas import TaskCreate, TaskUpdate

logger = logging.getLogger("taskverse.tasks")

MAX_SUBTASK_DEPTH = 2  # task -> subtask -> sub-subtask


# ---------- Helpers ----------

def _now() -> datetime:
    return datetime.now(UTC)


def _validate_depth(db: Session, parent_id: int | None) -> None:
    """Ensure we don't exceed 2 levels of nesting."""
    if parent_id is None:
        return
    parent = db.get(Task, parent_id)
    if not parent:
        raise AppError("parent task not found", 404)
    if parent.parent_id is not None:
        # parent already a subtask -> its children would be depth 3
        grand = db.get(Task, parent.parent_id)
        if grand and grand.parent_id is not None:
            raise AppError("max subtask depth reached", 400)


def _attach_tags(db: Session, task: Task, tag_ids: list[int], user_id: int) -> None:
    """Replace task's tags with the given set (validated per user)."""
    if not tag_ids:
        db.execute(task_tags.delete().where(task_tags.c.task_id == task.id))
        return
    rows = db.scalars(
        select(Tag.id).where(
            Tag.id.in_(tag_ids),
            Tag.user_id == user_id,
            Tag.deleted_at.is_(None),
        )
    ).all()
    valid_ids = set(rows)
    db.execute(task_tags.delete().where(task_tags.c.task_id == task.id))
    if valid_ids:
        db.execute(
            task_tags.insert(),
            [{"task_id": task.id, "tag_id": tid} for tid in valid_ids],
        )


def _tags_for(db: Session, task_id: int) -> list[Tag]:
    stmt = (
        select(Tag)
        .join(task_tags, task_tags.c.tag_id == Tag.id)
        .where(task_tags.c.task_id == task_id, Tag.deleted_at.is_(None))
    )
    return list(db.scalars(stmt).all())


# ---------- CRUD ----------

def create(db: Session, user_id: int, payload: TaskCreate) -> Task:
    _validate_depth(db, payload.parent_id)

    task = Task(
        user_id=user_id,
        title=payload.title,
        description=payload.description,
        project_id=payload.project_id,
        parent_id=payload.parent_id,
        priority=payload.priority,
        energy=payload.energy,
        due_date=payload.due_date,
        due_time=payload.due_time,
        estimated_min=payload.estimated_min,
        rrule=payload.rrule,
    )
    db.add(task)
    db.flush()

    _attach_tags(db, task, payload.tag_ids, user_id)
    db.commit()
    db.refresh(task)

    logger.info(
        "task created",
        extra={"user_id": user_id, "context": {"id": task.id, "parent_id": task.parent_id}},
    )
    return task


def get(db: Session, user_id: int, task_id: int) -> Task | None:
    return db.scalar(
        select(Task).where(
            Task.id == task_id,
            Task.user_id == user_id,
            Task.deleted_at.is_(None),
        )
    )


def update(db: Session, task: Task, payload: TaskUpdate) -> Task:
    data = payload.model_dump(exclude_unset=True)
    tag_ids = data.pop("tag_ids", None)

    for field, value in data.items():
        setattr(task, field, value)

    if tag_ids is not None:
        _attach_tags(db, task, tag_ids, task.user_id)

    db.commit()
    db.refresh(task)
    logger.info(
        "task updated",
        extra={"user_id": task.user_id, "context": {"id": task.id}},
    )
    return task


def set_status(db: Session, task: Task, status: str) -> Task:
    task.status = status
    if status == "done":
        task.completed_at = _now()
    elif status in ("todo", "doing"):
        task.completed_at = None
    db.commit()
    db.refresh(task)
    logger.info(
        "task status changed",
        extra={
            "user_id": task.user_id,
            "context": {"id": task.id, "status": status},
        },
    )
    return task


def defer(db: Session, task: Task, until: datetime | None) -> Task:
    task.deferred_until = until
    db.commit()
    db.refresh(task)
    return task


def soft_delete(db: Session, task: Task) -> None:
    """Move task (and its subtasks) to trash."""
    task.deleted_at = _now()
    # Cascade soft-delete subtasks
    db.query(Task).filter(
        Task.parent_id == task.id,
        Task.deleted_at.is_(None),
    ).update({"deleted_at": _now()})
    db.commit()
    logger.info(
        "task deleted",
        extra={"user_id": task.user_id, "context": {"id": task.id}},
    )


def restore(db: Session, task: Task) -> Task:
    task.deleted_at = None
    db.query(Task).filter(
        Task.parent_id == task.id,
        Task.deleted_at.is_not(None),
    ).update({"deleted_at": None})
    db.commit()
    db.refresh(task)
    return task


def hard_delete(db: Session, task: Task) -> None:
    db.delete(task)
    db.commit()


# ---------- Query / filters ----------

def list_for_user(
    db: Session,
    user_id: int,
    *,
    view: str = "all",  # all | today | week | month | agenda
    project_id: int | None = None,
    tag_id: int | None = None,
    status_filter: str | None = None,  # todo | doing | done | cancelled
    top_level_only: bool = True,
    include_deleted: bool = False,
    limit: int = 500,
    offset: int = 0,
) -> list[Task]:
    stmt = select(Task).where(Task.user_id == user_id)

    if not include_deleted:
        stmt = stmt.where(Task.deleted_at.is_(None))
    if top_level_only:
        stmt = stmt.where(Task.parent_id.is_(None))

    # Exclude deferred tasks
    stmt = stmt.where(
        (Task.deferred_until.is_(None)) | (Task.deferred_until <= _now())
    )

    if project_id is not None:
        stmt = stmt.where(Task.project_id == project_id)

    if status_filter:
        stmt = stmt.where(Task.status == status_filter)

    if tag_id is not None:
        stmt = stmt.join(task_tags, task_tags.c.task_id == Task.id).where(
            task_tags.c.tag_id == tag_id
        )

    today = date.today()

    if view == "today":
        stmt = stmt.where(Task.due_date == today)
    elif view == "week":
        end = today + timedelta(days=7)
        stmt = stmt.where(Task.due_date >= today, Task.due_date <= end)
    elif view == "month":
        end = today + timedelta(days=30)
        stmt = stmt.where(Task.due_date >= today, Task.due_date <= end)
    elif view == "agenda":
        stmt = stmt.where(Task.due_date.is_not(None))
        stmt = stmt.order_by(Task.due_date, Task.due_time, Task.priority)
    else:
        # default sort
        stmt = stmt.order_by(
            Task.due_date.is_(None),  # tasks with due_date first
            Task.due_date,
            Task.priority,
            Task.sort_order,
        )

    if view != "agenda":
        stmt = stmt.order_by(
            Task.due_date.is_(None),
            Task.due_date,
            Task.priority,
            Task.sort_order,
            Task.created_at.desc(),
        )

    stmt = stmt.limit(limit).offset(offset)
    return list(db.scalars(stmt).all())


def tags_for(db: Session, task_id: int) -> list[Tag]:
    return _tags_for(db, task_id)


def subtask_counts(db: Session, parent_ids: list[int]) -> dict[int, tuple[int, int]]:
    """Return {parent_id: (total, done)} for subtasks of given parents."""
    if not parent_ids:
        return {}
    from sqlalchemy import case

    done_expr = func.sum(case((Task.status == "done", 1), else_=0))
    rows = db.execute(
        select(
            Task.parent_id,
            func.count(Task.id),
            done_expr,
        )
        .where(Task.parent_id.in_(parent_ids), Task.deleted_at.is_(None))
        .group_by(Task.parent_id)
    ).all()
    return {r[0]: (r[1], int(r[2] or 0)) for r in rows}
