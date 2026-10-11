"""Query recent logs from the database — for ops sanity checks.

Usage:
    python scripts/check_logs.py                 # last 20 app_logs
    python scripts/check_logs.py --level ERROR   # last 20 ERROR app_logs
    python scripts/check_logs.py --user 1        # last 20 logs for user 1
    python scripts/check_logs.py --audit         # last 20 audit_log entries
"""

import argparse
import json
import sys
from pathlib import Path

import psycopg2
import psycopg2.extras

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from app.core.config import settings  # noqa: E402


def fmt_app_log(row: dict) -> str:
    ts = row["ts"].strftime("%Y-%m-%d %H:%M:%S")
    ctx = row.get("context") or {}
    if isinstance(ctx, str):
        try:
            ctx = json.loads(ctx)
        except Exception:
            ctx = {"raw": ctx}
    ctx_str = json.dumps(ctx, ensure_ascii=False) if ctx else ""
    return (
        f"{ts} | {row['level']:<8} | "
        f"{row['logger']:<30} | "
        f"{row['message'][:80]:<80} | "
        f"{ctx_str[:120]}"
    )


def fmt_audit_log(row: dict) -> str:
    ts = row["ts"].strftime("%Y-%m-%d %H:%M:%S")
    actor = row.get("actor_id") or "-"
    return (
        f"{ts} | {row['action']:<8} | "
        f"{row['entity']}:{row.get('entity_id') or '-'} | "
        f"actor={actor}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--level", default=None, help="filter by level (INFO/ERROR/...)")
    parser.add_argument("--user", type=int, default=None, help="filter by user_id")
    parser.add_argument("--audit", action="store_true", help="query audit_log instead")
    parser.add_argument("--limit", type=int, default=20)
    args = parser.parse_args()

    conn = psycopg2.connect(settings.database_url)

    if args.audit:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        if args.user:
            cur.execute(
                "SELECT * FROM audit_log WHERE actor_id = %s ORDER BY ts DESC LIMIT %s",
                (args.user, args.limit),
            )
        else:
            cur.execute(
                "SELECT * FROM audit_log ORDER BY ts DESC LIMIT %s",
                (args.limit,),
            )
        rows = cur.fetchall()
        for r in rows:
            print(fmt_audit_log(dict(r)))
    else:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        clauses, params = [], []
        if args.level:
            clauses.append("level = %s")
            params.append(args.level.upper())
        if args.user:
            clauses.append("user_id = %s")
            params.append(args.user)
        where = ("WHERE " + " AND ".join(clauses)) if clauses else ""
        params.append(args.limit)
        cur.execute(
            f"SELECT * FROM app_logs {where} ORDER BY ts DESC LIMIT %s",
            params,
        )
        rows = cur.fetchall()
        for r in rows:
            print(fmt_app_log(dict(r)))

    print(f"\n({len(rows)} rows)")
    cur.close()
    conn.close()


if __name__ == "__main__":
    main()