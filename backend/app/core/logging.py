"""Structured logging: stdout + optional DB sink."""

import json
import logging
import sys
from datetime import UTC, datetime
from typing import Any

from app.core.config import settings


class JsonFormatter(logging.Formatter):
    """Emit log records as JSON — parseable by Loki/ELK and by our own reader."""

    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "ts": datetime.now(UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "msg": record.getMessage(),
        }
        # Attach extra structured fields if present
        for key in ("request_id", "user_id", "module", "ip", "user_agent", "context"):
            value = getattr(record, key, None)
            if value is not None:
                payload[key] = value
        if record.exc_info:
            payload["exc"] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False, default=str)


class HumanFormatter(logging.Formatter):
    """Readable console output for local dev."""

    def format(self, record: logging.LogRecord) -> str:
        base = (
            f"{self.formatTime(record, '%H:%M:%S')} | "
            f"{record.levelname:<8} | "
            f"{record.name:<30} | "
            f"{record.getMessage()}"
        )
        rid = getattr(record, "request_id", None)
        uid = getattr(record, "user_id", None)
        extras = []
        if rid:
            extras.append(f"rid={rid}")
        if uid:
            extras.append(f"uid={uid}")
        if extras:
            base += " | " + " ".join(extras)
        if record.exc_info:
            base += "\n" + self.formatException(record.exc_info)
        return base


def setup_logging() -> None:
    """Configure root logger once at startup."""
    level = logging.DEBUG if settings.debug else logging.INFO
    formatter: logging.Formatter = (
        JsonFormatter() if settings.env == "production" else HumanFormatter()
    )

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setFormatter(formatter)

    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(stdout_handler)
    root.setLevel(level)

    # DB sink (async) — INFO+
    try:
        from app.core.log_sink_handler import DbLogHandler

        db_handler = DbLogHandler(level=logging.INFO)
        db_handler.setFormatter(formatter)
        root.addHandler(db_handler)
    except Exception as e:  # pragma: no cover
        logging.getLogger(__name__).warning("DB log handler not attached: %s", e)

    # Quiet noisy libraries
    for noisy in (
        "uvicorn.access",
        "httpcore",
        "httpx",
        "hpack",
        "sqlalchemy.engine",
    ):
        logging.getLogger(noisy).setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.INFO)


def get_logger(name: str, **context: Any) -> logging.LoggerAdapter:
    """Get a logger pre-bound with context (user_id, request_id, ...)."""
    logger = logging.getLogger(name)
    return logging.LoggerAdapter(logger, context)


def log_extra(
    request_id: str | None = None,
    user_id: int | None = None,
    module: str | None = None,
    ip: str | None = None,
    user_agent: str | None = None,
    **context: Any,
) -> dict[str, Any]:
    """Build the `extra` dict for `logger.info(..., extra=...)`."""
    extra: dict[str, Any] = {}
    if request_id:
        extra["request_id"] = request_id
    if user_id is not None:
        extra["user_id"] = user_id
    if module:
        extra["module"] = module
    if ip:
        extra["ip"] = ip
    if user_agent:
        extra["user_agent"] = user_agent
    if context:
        extra["context"] = context
    return extra
