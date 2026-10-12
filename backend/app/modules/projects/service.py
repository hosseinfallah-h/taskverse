"""Business logic for projects."""

import logging
from datetime import UTC

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.modules.projects.models import Project
from app.modules.projects.schemas import ProjectCreate, ProjectUpdate

logger = logging.getLogger("taskverse.projects")


def list_for_user(db: Session, user_id: int, include_archived: bool = False) -> list[Project]:
    stmt = select(Project).where(
        Project.user_id == user_id,
        Project.deleted_at.is_(None),
    )
    if not include_archived:
        stmt = stmt.where(Project.archived.is_(False))
    stmt = stmt.order_by(Project.sort_order, Project.created_at.desc())
    return list(db.scalars(stmt).all())


def get(db: Session, user_id: int, project_id: int) -> Project | None:
    return db.scalar(
        select(Project).where(
            Project.id == project_id,
            Project.user_id == user_id,
            Project.deleted_at.is_(None),
        )
    )


def create(db: Session, user_id: int, payload: ProjectCreate) -> Project:
    project = Project(
        user_id=user_id,
        name=payload.name,
        description=payload.description,
        color=payload.color,
        icon=payload.icon,
    )
    db.add(project)
    db.commit()
    db.refresh(project)
    logger.info("project created", extra={"user_id": user_id, "context": {"id": project.id}})
    return project


def update(db: Session, project: Project, payload: ProjectUpdate) -> Project:
    data = payload.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(project, field, value)
    db.commit()
    db.refresh(project)
    logger.info("project updated", extra={"user_id": project.user_id, "context": {"id": project.id}})
    return project


def soft_delete(db: Session, project: Project) -> None:
    from datetime import datetime

    project.deleted_at = datetime.now(UTC)
    db.commit()
    logger.info("project deleted", extra={"user_id": project.user_id, "context": {"id": project.id}})
