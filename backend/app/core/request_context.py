"""Per-request context: request_id, ip, user_agent.

Populated by middleware, read by logger + audit service.
"""

import uuid
from contextvars import ContextVar

_request_id: ContextVar[str | None] = ContextVar("request_id", default=None)
_user_id: ContextVar[int | None] = ContextVar("user_id", default=None)
_ip: ContextVar[str | None] = ContextVar("ip", default=None)
_user_agent: ContextVar[str | None] = ContextVar("user_agent", default=None)


def new_request_id() -> str:
    return uuid.uuid4().hex


def set_request_id(value: str) -> None:
    _request_id.set(value)


def get_request_id() -> str | None:
    return _request_id.get()


def set_user_id(value: int | None) -> None:
    _user_id.set(value)


def get_user_id() -> int | None:
    return _user_id.get()


def set_ip(value: str | None) -> None:
    _ip.set(value)


def get_ip() -> str | None:
    return _ip.get()


def set_user_agent(value: str | None) -> None:
    _user_agent.set(value)


def get_user_agent() -> str | None:
    return _user_agent.get()
