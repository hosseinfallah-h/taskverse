"""Initialize TaskVerse database: create DB if missing, run migrations.

Usage:
    python scripts/init_db.py
"""

import sys
from pathlib import Path

import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Allow running as a script from backend/
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.config import settings  # noqa: E402

MIGRATIONS_DIR = Path(__file__).resolve().parent.parent / "migrations"


def parse_db_url(url: str) -> dict:
    """Extract host/port/user/password/dbname from a postgres URL."""
    # postgresql://user:pass@host:port/dbname
    from urllib.parse import urlparse

    p = urlparse(url)
    return {
        "host": p.hostname or "localhost",
        "port": p.port or 5432,
        "user": p.username or "postgres",
        "password": p.password or "",
        "dbname": (p.path or "/taskverse").lstrip("/"),
    }


def ensure_database(cfg: dict) -> None:
    """Create the target database if it doesn't exist."""
    admin = {k: v for k, v in cfg.items() if k != "dbname"}
    admin["dbname"] = "postgres"

    conn = psycopg2.connect(**admin)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (cfg["dbname"],))
    exists = cur.fetchone()
    if exists:
        print(f"✅ Database '{cfg['dbname']}' already exists")
    else:
        cur.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(cfg["dbname"])))
        print(f"✅ Created database '{cfg['dbname']}'")
    cur.close()
    conn.close()


def run_migrations(cfg: dict) -> None:
    """Apply every *.sql file in migrations/ in sorted order."""
    conn = psycopg2.connect(**cfg)
    conn.autocommit = True
    cur = conn.cursor()

    files = sorted(MIGRATIONS_DIR.glob("*.sql"))
    if not files:
        print("⚠️  No migration files found")
        return

    for f in files:
        print(f"▶  Applying {f.name} ...", end=" ")
        sql_text = f.read_text(encoding="utf-8")
        cur.execute(sql_text)
        print("done")

    cur.close()
    conn.close()


def main() -> None:
    cfg = parse_db_url(settings.database_url)
    print(f"🎯 Target: {cfg['user']}@{cfg['host']}:{cfg['port']}/{cfg['dbname']}")
    ensure_database(cfg)
    run_migrations(cfg)
    print("🎉 Database ready")


if __name__ == "__main__":
    main()