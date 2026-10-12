"""Project endpoints - authenticated."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import get_current_user
from app.modules.projects import service
from app.modules.projects.schemas import ProjectCreate, ProjectPublic, ProjectUpdate
from app.modules.users.models import User

router = APIRouter(prefix="/projects", tags=["projects"])


@router.get("", response_model=list[ProjectPublic])
def list_projects(
    include_archived: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[ProjectPublic]:
    projects = service.list_for_user(db, current_user.id, include_archived=include_archived)
    return [ProjectPublic.model_validate(p) for p in projects]


@router.post("", response_model=ProjectPublic, status_code=status.HTTP_201_CREATED)
def create_project(
    payload: ProjectCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ProjectPublic:
    project = service.create(db, current_user.id, payload)
    return ProjectPublic.model_validate(project)


@router.get("/{project_id}", response_model=ProjectPublic)
def get_project(
    project_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ProjectPublic:
    project = service.get(db, current_user.id, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="project not found")
    return ProjectPublic.model_validate(project)


@router.patch("/{project_id}", response_model=ProjectPublic)
def update_project(
    project_id: int,
    payload: ProjectUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ProjectPublic:
    project = service.get(db, current_user.id, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="project not found")
    project = service.update(db, project, payload)
    return ProjectPublic.model_validate(project)


@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(
    project_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> None:
    project = service.get(db, current_user.id, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="project not found")
    service.soft_delete(db, project)
