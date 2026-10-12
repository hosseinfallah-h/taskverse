"""Task endpoints - authenticated."""

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.modules.tasks import service
from app.modules.tasks.schemas import (
    TagBrief,
    TaskCreate,
    TaskDefer,
    TaskPublic,
    TaskStatusUpdate,
    TaskUpdate,
    TaskWithTags,
)
from app.modules.users.models import User

router = APIRouter(prefix="/tasks", tags=["tasks"])


def _to_public(db: Session, task, with_meta: bool = True) -> dict:
    base = TaskPublic.model_validate(task).model_dump()
    if with_meta:
        tags = service.tags_for(db, task.id)
        base["tags"] = [TagBrief.model_validate(t).model_dump() for t in tags]
        counts = service.subtask_counts(db, [task.id])
        total, done = counts.get(task.id, (0, 0))
        base["subtasks_count"] = total
        base["subtasks_done"] = done
    return base


@router.get("", response_model=list[TaskWithTags])
def list_tasks(
    view: str = Query("all", pattern="^(all|today|week|month|agenda)$"),
    project_id: int | None = None,
    tag_id: int | None = None,
    status_filter: str | None = Query(None, pattern="^(todo|doing|done|cancelled)$"),
    top_level_only: bool = True,
    limit: int = Query(500, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TaskWithTags]:
    tasks = service.list_for_user(
        db,
        current_user.id,
        view=view,
        project_id=project_id,
        tag_id=tag_id,
        status_filter=status_filter,
        top_level_only=top_level_only,
        limit=limit,
        offset=offset,
    )
    return [TaskWithTags(**(_to_public(db, t, with_meta=True))) for t in tasks]


@router.post("", response_model=TaskWithTags, status_code=status.HTTP_201_CREATED)
def create_task(
    payload: TaskCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = service.create(db, current_user.id, payload)
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.get("/{task_id}", response_model=TaskWithTags)
def get_task(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = service.get(db, current_user.id, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.patch("/{task_id}", response_model=TaskWithTags)
def update_task(
    task_id: int,
    payload: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = service.get(db, current_user.id, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    task = service.update(db, task, payload)
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.post("/{task_id}/status", response_model=TaskWithTags)
def set_status(
    task_id: int,
    payload: TaskStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = service.get(db, current_user.id, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    task = service.set_status(db, task, payload.status)
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.post("/{task_id}/defer", response_model=TaskWithTags)
def defer_task(
    task_id: int,
    payload: TaskDefer,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = service.get(db, current_user.id, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    task = service.defer(db, task, payload.deferred_until)
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    task = service.get(db, current_user.id, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="task not found")
    service.soft_delete(db, task)


@router.post("/{task_id}/restore", response_model=TaskWithTags)
def restore_task(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TaskWithTags:
    task = db.query(service.Task).filter(
        service.Task.id == task_id,
        service.Task.user_id == current_user.id,
        service.Task.deleted_at.is_not(None),
    ).first()
    if not task:
        raise HTTPException(status_code=404, detail="trashed task not found")
    task = service.restore(db, task)
    return TaskWithTags(**(_to_public(db, task, with_meta=True)))


@router.get("/{task_id}/subtasks", response_model=list[TaskWithTags])
def list_subtasks(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TaskWithTags]:
    parent = service.get(db, current_user.id, task_id)
    if not parent:
        raise HTTPException(status_code=404, detail="task not found")
    subtasks = list(
        db.query(service.Task).filter(
            service.Task.parent_id == task_id,
            service.Task.user_id == current_user.id,
            service.Task.deleted_at.is_(None),
        ).order_by(service.Task.sort_order, service.Task.created_at).all()
    )
    return [TaskWithTags(**(_to_public(db, t, with_meta=True))) for t in subtasks]
