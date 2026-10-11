-- ============================================================
-- TaskVerse — Migration 001
-- Initial schema: extensions, log tables, core scaffolding.
-- Domain tables (users, tasks, ...) come in later migrations.
-- ============================================================

BEGIN;

-- ---------- Extensions ----------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";     -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "citext";       -- case-insensitive text

-- ---------- Helper: updated_at trigger ----------
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- APP LOGS — runtime, queryable event log
-- ============================================================
CREATE TABLE IF NOT EXISTS app_logs (
    id           BIGSERIAL PRIMARY KEY,
    ts           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    level        VARCHAR(10) NOT NULL,           -- DEBUG|INFO|WARNING|ERROR|CRITICAL
    logger       VARCHAR(100) NOT NULL,          -- e.g. "taskverse.auth"
    module       VARCHAR(50),                    -- e.g. "auth", "tasks"
    message      TEXT NOT NULL,
    request_id   VARCHAR(32),
    user_id      BIGINT,
    ip           INET,
    user_agent   TEXT,
    context      JSONB,                          -- arbitrary structured data
    exc          TEXT                            -- exception traceback if any
);

CREATE INDEX IF NOT EXISTS idx_app_logs_ts        ON app_logs (ts DESC);
CREATE INDEX IF NOT EXISTS idx_app_logs_level     ON app_logs (level, ts DESC);
CREATE INDEX IF NOT EXISTS idx_app_logs_user      ON app_logs (user_id, ts DESC) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_app_logs_module    ON app_logs (module, ts DESC) WHERE module IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_app_logs_request   ON app_logs (request_id) WHERE request_id IS NOT NULL;

-- ============================================================
-- AUDIT LOG — immutable record of every state change
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_log (
    id           BIGSERIAL PRIMARY KEY,
    ts           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actor_id     BIGINT,                         -- user who performed action
    entity       VARCHAR(50) NOT NULL,           -- "task", "user", "project", ...
    entity_id    BIGINT,
    action       VARCHAR(20) NOT NULL,           -- create|update|delete|restore|login|logout
    diff         JSONB,                          -- {before: {...}, after: {...}}
    ip           INET,
    user_agent   TEXT,
    request_id   VARCHAR(32)
);

CREATE INDEX IF NOT EXISTS idx_audit_actor     ON audit_log (actor_id, ts DESC);
CREATE INDEX IF NOT EXISTS idx_audit_entity    ON audit_log (entity, entity_id, ts DESC);
CREATE INDEX IF NOT EXISTS idx_audit_ts        ON audit_log (ts DESC);
CREATE INDEX IF NOT EXISTS idx_audit_action    ON audit_log (action, ts DESC);

-- ============================================================
-- APP LOGS — retention: we keep 90 days by default.
-- Cleanup is done by scripts/prune_logs.py (Sprint 8 cron).
-- ============================================================

COMMIT;