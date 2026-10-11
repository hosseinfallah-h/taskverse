"""Rate limiting via slowapi.

Rules:
- Default: settings.rate_limit_default (60/min)
- Auth endpoints: settings.rate_limit_auth (5/min)

Identity for limiting: X-Forwarded-For (if behind proxy) else client IP.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address
from starlette.requests import Request

from app.core.config import settings


def client_key(request: Request) -> str:
    """Best-effort client identifier for rate limiting."""
    fwd = request.headers.get("x-forwarded-for")
    if fwd:
        return fwd.split(",")[0].strip()
    return get_remote_address(request) or "unknown"


limiter = Limiter(
    key_func=client_key,
    default_limits=[settings.rate_limit_default],
    headers_enabled=True,
)