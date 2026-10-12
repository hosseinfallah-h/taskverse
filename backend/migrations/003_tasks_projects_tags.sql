-- ============================================================
-- TaskVerse - Migration 003
-- Projects, tags, tasks, subtasks, task_templates.
-- ============================================================

BEGIN;

-- ============================================================
-- PROJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    color       VARCHAR(20),
    icon        VARCHAR(50),
    sort_order  INTEGER NOT NULL DEFAULT 0,
    archived    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_projects_user ON projects (user_id) WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS trg_projects_updated_at ON projects;
CREATE TRIGGER trg_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TAGS
-- ============================================================
CREATE TABLE IF NOT EXISTS tags (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(50) NOT NULL,
    color       VARCHAR(20),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,
    UNIQUE (user_id, name)
);

CREATE INDEX IF NOT EXISTS idx_tags_user ON tags (user_id) WHERE deleted_at IS NULL;

-- ============================================================
-- TASK TEMPLATES
-- ============================================================
CREATE TABLE IF NOT EXISTS task_templates (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    icon        VARCHAR(50),
    payload     JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_templates_user ON task_templates (user_id) WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS trg_templates_updated_at ON task_templates;
CREATE TRIGGER trg_templates_updated_at
    BEFORE UPDATE ON task_templates
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TASKS
-- ============================================================
CREATE TABLE IF NOT EXISTS tasks (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id      BIGINT REFERENCES projects(id) ON DELETE SET NULL,
    parent_id       BIGINT REFERENCES tasks(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'todo',
    priority        SMALLINT NOT NULL DEFAULT 2,
    energy          VARCHAR(10),
    due_date        DATE,
    due_time        TIME,
    estimated_min   INTEGER,
    actual_min      INTEGER NOT NULL DEFAULT 0,
    rrule           TEXT,
    recurrence_parent_id BIGINT REFERENCES tasks(id) ON DELETE SET NULL,
    deferred_until  TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    CONSTRAINT tasks_status_valid CHECK (status IN ('todo','doing','done','cancelled')),
    CONSTRAINT tasks_priority_valid CHECK (priority BETWEEN 0 AND 3),
    CONSTRAINT tasks_energy_valid CHECK (energy IS NULL OR energy IN ('high','low','neutral'))
);

CREATE INDEX IF NOT EXISTS idx_tasks_user_due
    ON tasks (user_id, due_date)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_parent
    ON tasks (parent_id)
    WHERE parent_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_status
    ON tasks (user_id, status)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_project
    ON tasks (project_id)
    WHERE project_id IS NOT NULL AND deleted_at IS NULL;

DROP TRIGGER IF EXISTS trg_tasks_updated_at ON tasks;
CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TASK <-> TAGS (many-to-many)
-- ============================================================
CREATE TABLE IF NOT EXISTS task_tags (
    task_id     BIGINT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    tag_id      BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);

CREATE INDEX IF NOT EXISTS idx_task_tags_tag ON task_tags (tag_id);

COMMIT;