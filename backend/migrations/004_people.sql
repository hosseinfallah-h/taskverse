-- ============================================================
-- TaskVerse - Migration 004
-- People (friends, family, contacts) with birthdays.
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS people (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    nickname        VARCHAR(100),
    phone           VARCHAR(20),
    email           VARCHAR(255),
    birthday        DATE,                      -- stored as-is; Jalali view computed in app
    avatar_path     TEXT,
    notes           TEXT,
    relationship    VARCHAR(30) DEFAULT 'friend',
                    -- friend | family | colleague | client | other
    sort_order      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    CONSTRAINT people_relationship_valid CHECK (
        relationship IN ('friend','family','colleague','client','other')
    )
);

CREATE INDEX IF NOT EXISTS idx_people_user
    ON people (user_id)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_people_birthday
    ON people (user_id, birthday)
    WHERE deleted_at IS NULL AND birthday IS NOT NULL;

DROP TRIGGER IF EXISTS trg_people_updated_at ON people;
CREATE TRIGGER trg_people_updated_at
    BEFORE UPDATE ON people
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- PERSON <-> TAGS
-- ============================================================
CREATE TABLE IF NOT EXISTS person_tags (
    person_id   BIGINT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    tag_id      BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (person_id, tag_id)
);

CREATE INDEX IF NOT EXISTS idx_person_tags_tag ON person_tags (tag_id);

-- ============================================================
-- PERSON <-> PERSON relationships (optional; "knows", "spouse", ...)
-- ============================================================
CREATE TABLE IF NOT EXISTS person_relationships (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    person_a_id     BIGINT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    person_b_id     BIGINT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    kind            VARCHAR(30) NOT NULL DEFAULT 'knows',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (person_a_id, person_b_id, kind),
    CONSTRAINT person_rel_not_self CHECK (person_a_id <> person_b_id)
);

COMMIT;