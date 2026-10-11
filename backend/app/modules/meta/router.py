"""Meta endpoints: version, build info."""

from fastapi import APIRouter

from app.core.config import settings

router = APIRouter(prefix="/meta", tags=["meta"])


@router.get("/info")
async def info():
    """App info."""
    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "env": settings.env,
        "timezone": settings.timezone,
    }