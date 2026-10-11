"""Request middleware: request_id, timing, access log."""

import logging
import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

from app.core import request_context as ctx

access_logger = logging.getLogger("taskverse.access")


class RequestContextMiddleware(BaseHTTPMiddleware):
    """Assign request_id, capture ip + user_agent, log every request."""

    async def dispatch(self, request: Request, call_next):
        rid = request.headers.get("X-Request-ID") or ctx.new_request_id()
        ctx.set_request_id(rid)
        ctx.set_ip(request.client.host if request.client else None)
        ctx.set_user_agent(request.headers.get("user-agent"))

        start = time.perf_counter()
        try:
            response = await call_next(request)
        except Exception:
            duration_ms = (time.perf_counter() - start) * 1000
            access_logger.exception(
                "request failed",
                extra={
                    "request_id": rid,
                    "context": {
                        "method": request.method,
                        "path": request.url.path,
                        "duration_ms": round(duration_ms, 2),
                    },
                },
            )
            raise

        duration_ms = (time.perf_counter() - start) * 1000
        response.headers["X-Request-ID"] = rid

        access_logger.info(
            "%s %s -> %s (%.2fms)",
            request.method,
            request.url.path,
            response.status_code,
            duration_ms,
            extra={
                "request_id": rid,
                "context": {
                    "method": request.method,
                    "path": request.url.path,
                    "status": response.status_code,
                    "duration_ms": round(duration_ms, 2),
                },
            },
        )
        return response
