# 📖 TASKVERSE BIBLE

> The single source of truth.

**Version:** 0.2
**Last updated:** 2026-10-11
**Status:** 🟡 In Progress

---

## PART A — FOUNDATION

### A.1 Vision

TaskVerse is a Persian-first, offline-first, self-hosted task manager that
lives in your pocket AND in your Bale chats — built for people whose lives
run on routine, content, and consistency.

**Anti-goals:**
- Not a Notion clone
- Not a team PM tool (yet)
- Not a calendar replacement
- Not a habit tracker first
- Not a social network

### A.2 Personas

**#1 — The Creator (Primary):** Owner. Daily user. Self-hosts.
**#2 — The Friend (Secondary):** Invited. Free tier.
**#3 — The Paying User (Future):** Approved by admin. Paid tier.

### A.3 Modular Architecture

Every feature is a self-contained module.

**Backend module shape:**
```
app/modules/<name>/
├── __init__.py
├── router.py       FastAPI endpoints
├── service.py      Business logic
├── models.py       SQLAlchemy models
├── schemas.py      Pydantic request/response
└── tests.py        Module tests
```

**Mobile module shape:**
```
lib/features/<name>/
├── screens/
├── providers/
├── models/
└── widgets/
```

**Registered modules (v1.0 plan):**
health, meta, auth, users, tasks, projects, tags, subtasks, templates,
habits, rituals, goals, people, birthdays, attachments, voice, bale_bot,
content, insights, prompts, reports, audit, admin.

### A.4 Stack

| Layer | Tech |
|-------|------|
| Mobile | Flutter 3.44.4 |
| State | Riverpod 2 + freezed |
| Local DB | Drift (SQLite) |
| Backend | FastAPI 0.139.0 / Python 3.11 |
| API | REST + GraphQL |
| DB | PostgreSQL 18 (dev) / 14 (prod) |
| Cache | Redis 7 |
| Queue | ARQ |
| Bot | Bale Bot API |
| Auth | JWT + FarazSMS OTP |
| Host | ParsPack irVPS2 |
| Charts | fl_chart |

### A.5 Data Model

Locked in Sprint 1. Full PostgreSQL schema will be versioned in
`backend/migrations/`.

Core tables planned:
- users, refresh_tokens, invites
- projects, tags, tasks, task_tags
- attachments, reminders
- task_templates
- habits, habit_logs
- content_items, insights
- prompts
- goals
- **people** (friends: name, avatar, phone, birthday, notes)
- audit_log, bale_messages

### A.6 Feature Matrix

Legend: **M**=Must v1.0 · **S**=Should v1.x · **C**=Could v2+

**Auth:** phone+OTP (M), password (M), JWT (M), admin approval (M), tiers (M), profile+avatar (M), invites (S), forgot-pw (S), 2FA (S), delete account (S).

**Tasks:** CRUD (M), markdown notes (M), priority (M), tags (M), projects (M), subtasks 2-level (M), RRULE recurrence (M), templates (M), attachments (M), reminders (M), defer (M), snooze (M), bulk actions (M), undo (M), trash 30d (M), time tracking (S), pomodoro (S), NLS (C).

**Views:** Today/Week/Month/Agenda (M), weekly planner grid (M), time-blocking (M), kanban (S), Eisenhower (C), focus mode (S), command palette (M).

**Rituals:** daily review (M), weekly review (M), monthly goals (M), quarterly OKRs (S), habits (M), streaks (M), XP+levels (M), badges (S), energy tagging (M).

**People (NEW):** CRUD friends (M), avatar upload+optimize (M), phone (M), birthday (M), notes (M), tags/groups (S), birthday reminders 3d+0d (M).

**Content:** board Idea→Posted (M), multi-platform scheduler (S), templates (S), captions+hashtags (S), heatmap (M), idea inbox (M), analytics reminder (M), insights saver+analyzer (M).

**Bale:** /start link (M), 7AM brief (M), inline done buttons (M), nightly recap (M), /today /week /add /done /stats (M), voice→task (M), plain msg add (S), snooze reply (S), weekly report PNG (S), birthday reminders (M), Sunday prompt (S), shared list (C).

**UI:** custom icons (M), haptics (M), skeletons (M), optimistic (M), Android widget (M), dark+AMOLED (M), Material You (S), RTL+Persian (M), Jalali (M), motion system (M), a11y (S), Wear OS (C).

**Reports (NEW):** daily/weekly/monthly/yearly dashboards (M), fl_chart visuals (M), XP chart (M), completion trends (M), habit heatmap (M), content performance (M), export report PNG (S).

**Prompts Vault:** CRUD (M), copy 1-tap (M), variables (S), folders (S), history (C).

**Power:** offline sync (M), export JSON/MD/ICS (M), import JSON/Excel w/ preview (M), audit log (M), daily DB backup (M), weekly encrypted backup (M), admin panel (M), Umami analytics (S), rate limiting (M), API tokens (C), webhooks (C).

---

## PART B — API CONTRACT

> _Pending — Sprint 1_

## PART C — BALE BOT FLOWS

> _Pending — Sprint 3_

## PART D — DESIGN SYSTEM

> _Pending — Sprint 0.5_

## PART E — SYNC STRATEGY

> _Pending — Sprint 2_

## PART F — SECURITY HARDENING

### Backend
- HTTPS only (Let's Encrypt via Nginx reverse proxy)
- JWT access 30d, refresh 90d, hashed at rest
- Rate limiting: slowapi — 60/min default, 5/min auth
- CORS strict allowlist
- Passwords: bcrypt 4.0.1, min 8 chars
- OTP: 6-digit, 2-min expiry, 5 attempts max
- Pydantic validation on every endpoint
- SQLAlchemy parameterized queries only
- File uploads: MIME sniff, size caps, stored outside web root
- Audit log for every mutation

### Server
- UFW: 22 (SSH), 80 (redirect), 443 (HTTPS); 8000 internal only
- fail2ban: SSH + app 401/429 patterns
- SSH key-only, password disabled, non-standard port
- unattended-upgrades enabled
- logrotate for app/nginx/postgres

### Mobile
- JWT in flutter_secure_storage
- Certificate pinning (production)
- No secrets in logs
- Rooted device warning (optional)

## PART G — MODULE INDEX

| Module | Sprint | Status |
|--------|--------|--------|
| health | 0 | 🔄 building |
| meta | 0 | 🔄 building |
| auth | 1 | ⏳ |
| users | 1 | ⏳ |
| tasks | 2 | ⏳ |
| people | 2 | ⏳ |
| reports | 6 | ⏳ |
| bale_bot | 3 | ⏳ |
| ... | ... | ... |

---

**Next:** Sprint 0.5 — API contract + design system