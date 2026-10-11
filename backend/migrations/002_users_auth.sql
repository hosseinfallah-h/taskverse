-- ============================================================
-- TaskVerse — Migration 002
-- Users, auth, OTP, invites.
-- ============================================================

BEGIN;

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,
    phone           VARCHAR(20) UNIQUE NOT NULL,
    password_hash   VARCHAR(255),
    name            VARCHAR(100) NOT NULL,
    email           CITEXT,
    avatar_path     TEXT,
    timezone        VARCHAR(50) NOT NULL DEFAULT 'Asia/Tehran',
    tier            VARCHAR(20) NOT NULL DEFAULT 'pending',
                    -- pending | approved | admin | banned
    brief_hour      SMALLINT NOT NULL DEFAULT 7,
    recap_hour      SMALLINT NOT NULL DEFAULT 21,
    xp              INTEGER NOT NULL DEFAULT 0,
    level           SMALLINT NOT NULL DEFAULT 1,
    bale_chat_id    BIGINT UNIQUE,
    bale_link_code  VARCHAR(16),
    last_seen_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    CONSTRAINT users_tier_valid CHECK (tier IN ('pending','approved','admin','banned')),
    CONSTRAINT users_brief_hour_valid CHECK (brief_hour BETWEEN 0 AND 23),
    CONSTRAINT users_recap_hour_valid CHECK (recap_hour BETWEEN 0 AND 23)
);

CREATE INDEX IF NOT EXISTS idx_users_phone      ON users (phone) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_tier       ON users (tier) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_users_bale_chat  ON users (bale_chat_id) WHERE bale_chat_id IS NOT NULL;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- REFRESH TOKENS (rotate on use)
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(255) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_agent  TEXT,
    ip          INET
);

CREATE INDEX IF NOT EXISTS idx_refresh_user    ON refresh_tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_expires ON refresh_tokens (expires_at);

-- ============================================================
-- OTP CODES (short-lived, hashed)
-- ============================================================
CREATE TABLE IF NOT EXISTS otp_codes (
    id           BIGSERIAL PRIMARY KEY,
    phone        VARCHAR(20) NOT NULL,
    code_hash    VARCHAR(255) NOT NULL,
    purpose      VARCHAR(20) NOT NULL DEFAULT 'register',
                 -- register | login | reset_password
    attempts     SMALLINT NOT NULL DEFAULT 0,
    max_attempts SMALLINT NOT NULL DEFAULT 5,
    expires_at   TIMESTAMPTZ NOT NULL,
    used_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip           INET
);

CREATE INDEX IF NOT EXISTS idx_otp_phone   ON otp_codes (phone, purpose);
CREATE INDEX IF NOT EXISTS idx_otp_expires ON otp_codes (expires_at);

-- ============================================================
-- INVITES
-- ============================================================
CREATE TABLE IF NOT EXISTS invites (
    id          BIGSERIAL PRIMARY KEY,
    code        VARCHAR(32) UNIQUE NOT NULL,
    created_by  BIGINT REFERENCES users(id) ON DELETE SET NULL,
    used_by     BIGINT REFERENCES users(id) ON DELETE SET NULL,
    max_uses    SMALLINT NOT NULL DEFAULT 1,
    uses        SMALLINT NOT NULL DEFAULT 0,
    note        TEXT,
    expires_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_invites_code ON invites (code);

COMMIT;