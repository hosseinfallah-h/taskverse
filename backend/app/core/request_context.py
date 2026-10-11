"""Per-request context: request_id, ip, user_agent.

Populated by middleware, read by logger + audit service.
"""

import uuid
from contextvars import ContextVar
from typing import Optional

_request_id: ContextVar[Optional[str]] = ContextVar("request_id", default=None)
_user_id: ContextVar[Optional[int]] = ContextVar("user_id", default=None)
_ip: ContextVar[Optional[str]] = ContextVar("ip", default=None)
_user_agent: ContextVar[Optional[str]] = ContextVar("user_agent", default=None)


def new_request_id() -> str:
    return uuid.uuid4().hex


def set_request_id(value: str) -> None:
    _request_id.set(value)


def get_request_id() -> Optional[str]:
    return _request_id.get()


def set_user_id(value: Optional[int]) -> None:
    _user_id.set(value)


def get_user_id() -> Optional[int]:
    return _user_id.get()


def set_ip(value: Optional[str]) -> None:
    _ip.set(value)


def get_ip() -> Optional[str]:
    return _ip.get()


def set_user_agent(value: Optional[str]) -> None:
    _user_agent.set(value)


def get_user_agent() -> Optional[str]:
    return _user_agent.get()