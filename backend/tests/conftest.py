"""Pytest fixtures for TaskVerse.

Uses a real PostgreSQL test database (`taskverse_test`). Creates schema once
per session, truncates between tests, and yields a TestClient.
"""

import glob
import os
from pathlib import Path
from urllib.parse import urlparse

import psycopg2
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

BACKEND_ROOT = Path(__file__).resolve().parent.parent

TEST_DB_URL = os.getenv(
    "TEST_DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/taskverse_test",
)
os.environ["DATABASE_URL"] = TEST_DB_URL
os.environ.setdefault("SECRET_KEY", "test-secret-key-please-rotate-in-production")
os.environ.setdefault("ENV", "test")
os.environ.setdefault("DEBUG", "true")
os.environ.setdefault("SMS_PROVIDER", "")


@pytest.fixture(scope="session", autouse=True)
def _create_test_db() -> None:
    """Create the test database + apply all migrations once."""
    p = urlparse(TEST_DB_URL)
    db_name = p.path.lstrip("/")
    admin_url = TEST_DB_URL.replace(f"/{db_name}", "/postgres")

    conn = psycopg2.connect(admin_url)
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
    if not cur.fetchone():
        cur.execute(f'CREATE DATABASE "{db_name}"')
    cur.close()
    conn.close()

    conn = psycopg2.connect(TEST_DB_URL)
    conn.autocommit = True
    cur = conn.cursor()
    for f in sorted(glob.glob(str(BACKEND_ROOT / "migrations" / "*.sql"))):
        cur.execute(Path(f).read_text(encoding="utf-8"))
    cur.close()
    conn.close()


@pytest.fixture(scope="session")
def _engine():
    return create_engine(TEST_DB_URL, pool_pre_ping=True)


@pytest.fixture(scope="session")
def _session_factory(_engine):
    return sessionmaker(
        bind=_engine, autoflush=False, autocommit=False, expire_on_commit=False
    )


@pytest.fixture(autouse=True)
def _clean_tables(_engine):
    with _engine.begin() as conn:
        conn.execute(
            text(
                """
                TRUNCATE TABLE refresh_tokens, otp_codes, invites,
                               audit_log, app_logs, users
                RESTART IDENTITY CASCADE
                """
            )
        )
    yield


@pytest.fixture
def db(_session_factory):
    s = _session_factory()
    try:
        yield s
    finally:
        s.close()


@pytest.fixture(scope="session")
def client():
    from app.main import app

    with TestClient(app) as c:
        yield c