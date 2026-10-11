"""TaskVerse FastAPI application factory."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.errors import register_error_handlers
from app.core.logging import setup_logging
from app.modules.health.router import router as health_router
from app.modules.meta.router import router as meta_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup / shutdown hooks."""
    setup_logging()
    print(f"🚀 {settings.app_name} v{settings.app_version} starting...")
    print(f"   ENV: {settings.env}")
    print(f"   TZ:  {settings.timezone}")
    yield
    print(f"🛑 {settings.app_name} shutting down...")


def create_app() -> FastAPI:
    """Application factory."""
    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        description="Persian-first, self-hosted task manager API.",
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
        openapi_url="/openapi.json" if settings.debug else None,
        lifespan=lifespan,
    )

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Errors
    register_error_handlers(app)

    # --- Modules ---
    app.include_router(health_router)
    app.include_router(meta_router)

    return app


app = create_app()