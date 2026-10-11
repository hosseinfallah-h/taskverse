"""Health check endpoints."""

from datetime import UTC, datetime

from fastapi import APIRouter

from app.core.config import settings

router = APIRouter(tags=["health"])


@router.get("/")
async def root():
    """Root — quick liveness check."""
    return {
        "app": settings.app_name,
        "version": settings.app_version,
        "status": "ok",
        "time": datetime.now(UTC).isoformat(),
    }


@router.get("/health")
async def health():
    """Detailed health check."""
    return {
        "status": "healthy",
        "app": settings.app_name,
        "version": settings.app_version,
        "env": settings.env,
        "timestamp": datetime.now(UTC).isoformat(),
    }
