"""Logging handler that forwards records into the async log sink."""

import logging

from app.core import log_sink
from app.core.request_context import get_ip, get_request_id, get_user_agent, get_user_id


class DbLogHandler(logging.Handler):
    """Forward log records to the async DB sink.

    Only WARNING and above by default, so we don't flood the DB.
    """

    def __init__(self, level: int = logging.INFO) -> None:
        super().__init__(level=level)

    def emit(self, record: logging.LogRecord) -> None:
        try:
            log_sink.emit(
                {
                    "level": record.levelname,
                    "logger": record.name,
                    "module": getattr(record, "module", None),
                    "message": record.getMessage(),
                    "request_id": getattr(record, "request_id", None) or get_request_id(),
                    "user_id": getattr(record, "user_id", None) or get_user_id(),
                    "ip": getattr(record, "ip", None) or get_ip(),
                    "user_agent": getattr(record, "user_agent", None) or get_user_agent(),
                    "context": getattr(record, "context", None),
                    "exc": self.format(record) if record.exc_info else None,
                }
            )
        except Exception:
            # Never raise from a log handler
            self.handleError(record)
