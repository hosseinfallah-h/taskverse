"""Async log sink: pushes structured log records into app_logs table.

Design: a bounded queue + background task. Non-blocking. If the queue fills,
we drop + count drops (and warn). This protects the request path.

Sprint 1 ships the writer; wiring to logging handlers happens on startup.
"""

import asyncio
import contextlib
import json
import logging
from contextlib import asynccontextmanager
from typing import Any

from sqlalchemy import text

from app.core.database import SessionLocal

_queue: asyncio.Queue[dict[str, Any]] | None = None
_worker_task: asyncio.Task | None = None
_dropped = 0

logger = logging.getLogger("taskverse.log_sink")

QUEUE_MAX = 1000
BATCH_SIZE = 50
FLUSH_INTERVAL = 2.0


async def start() -> None:
    """Start the background worker."""
    global _queue, _worker_task
    if _worker_task is not None:
        return
    _queue = asyncio.Queue(maxsize=QUEUE_MAX)
    _worker_task = asyncio.create_task(_worker(), name="log-sink-worker")
    logger.info("log sink started")


async def stop() -> None:
    """Stop the worker, flushing remaining records."""
    global _worker_task
    if _worker_task is None:
        return
    _worker_task.cancel()
    with contextlib.suppress(asyncio.CancelledError):
        await _worker_task
    _worker_task = None
    logger.info("log sink stopped", extra={"context": {"dropped": _dropped}})


def emit(record: dict[str, Any]) -> None:
    """Enqueue a log record. Never blocks. Drops on overflow."""
    global _dropped
    if _queue is None:
        return
    try:
        _queue.put_nowait(record)
    except asyncio.QueueFull:
        _dropped += 1


async def _worker() -> None:
    """Batch-insert records into app_logs every FLUSH_INTERVAL or BATCH_SIZE."""
    assert _queue is not None
    while True:
        batch: list[dict[str, Any]] = []
        try:
            first = await _queue.get()
            batch.append(first)
            deadline = asyncio.get_event_loop().time() + FLUSH_INTERVAL
            while len(batch) < BATCH_SIZE:
                timeout = deadline - asyncio.get_event_loop().time()
                if timeout <= 0:
                    break
                try:
                    batch.append(await asyncio.wait_for(_queue.get(), timeout))
                except TimeoutError:
                    break
        except asyncio.CancelledError:
            if batch:
                _write_batch(batch)
            raise
        except Exception as e:
            logger.warning("log sink error: %s", e)
            continue

        if batch:
            _write_batch(batch)


def _write_batch(batch: list[dict[str, Any]]) -> None:
    """Insert a batch in one transaction."""
    try:
        with SessionLocal() as db:
            db.execute(
                text(
                    """
                    INSERT INTO app_logs
                        (level, logger, module, message, request_id,
                         user_id, ip, user_agent, context, exc)
                    VALUES
                        (:level, :logger, :module, :message, :request_id,
                         :user_id, :ip, :user_agent, :context, :exc)
                    """
                ),
                [
                    {
                        "level": r.get("level", "INFO"),
                        "logger": r.get("logger", "unknown"),
                        "module": r.get("module"),
                        "message": r.get("message", ""),
                        "request_id": r.get("request_id"),
                        "user_id": r.get("user_id"),
                        "ip": r.get("ip"),
                        "user_agent": r.get("user_agent"),
                        "context": json.dumps(r.get("context") or {}),
                        "exc": r.get("exc"),
                    }
                    for r in batch
                ],
            )
            db.commit()
    except Exception as e:
        logger.warning("log sink write failed: %s", e)


@asynccontextmanager
async def lifespan_hook():
    """Use inside FastAPI lifespan to start/stop cleanly."""
    await start()
    try:
        yield
    finally:
        await stop()
