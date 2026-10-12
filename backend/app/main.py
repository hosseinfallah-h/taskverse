"""TaskVerse FastAPI application factory."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from starlette.responses import JSONResponse

from app.core import log_sink
from app.core.config import settings
from app.core.errors import register_error_handlers
from app.core.logging import setup_logging
from app.core.middleware import RequestContextMiddleware
from app.core.rate_limit import limiter
from app.modules.auth.router import router as auth_router
from app.modules.health.router import router as health_router
from app.modules.meta.router import router as meta_router
from app.modules.users.router import router as users_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    print(f"🚀 {settings.app_name} v{settings.app_version} starting...")
    print(f"   ENV: {settings.env}")
    print(f"   TZ:  {settings.timezone}")
    async with log_sink.lifespan_hook():
        yield
    print(f"🛑 {settings.app_name} shutting down...")


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        description="Persian-first, self-hosted task manager API.",
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
        openapi_url="/openapi.json" if settings.debug else None,
        lifespan=lifespan,
    )

    # --- Rate limiter ---
    app.state.limiter = limiter

    @app.exception_handler(RateLimitExceeded)
    async def rate_limit_handler(_, exc):  # noqa: ANN001
        return JSONResponse(
            status_code=429,
            content={"detail": "rate limit exceeded", "retry_after": str(exc.detail)},
        )

    app.add_middleware(SlowAPIMiddleware)
    app.add_middleware(RequestContextMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["X-Request-ID", "Retry-After"],
    )

    register_error_handlers(app)

    # --- Modules ---
    app.include_router(health_router)
    app.include_router(meta_router)
    app.include_router(auth_router)
    app.include_router(users_router)

    return app


app = create_app()
