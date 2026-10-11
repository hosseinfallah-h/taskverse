# 📜 TASKVERSE CONSTITUTION v1.1

> The rules that never change. Ever.

---

## ARTICLE 1 — IDENTITY

- **Name:** TaskVerse
- **Codename:** باغِ کار (The Garden of Work)
- **Mission:** The most beautiful task manager ever built for Iran.
- **Owner:** Hossein Fallah
- **Audience:** Owner first. Friends second. Paying users third.
- **Platform:** Android (Flutter) + Bale Bot + Self-hosted API

---

## ARTICLE 2 — NON-NEGOTIABLE PRINCIPLES

1. Persian-first. Every string, date, and design choice.
2. Offline-first. Works with zero internet. Sync is a bonus.
3. Self-hosted. No Google, no AWS, no foreign telemetry.
4. Bale is a first-class citizen.
5. Premium UI is a REQUIREMENT.
6. Zero data loss. Backups before every migration.
7. No feature ships without: tests + docs + backup + rollback.
8. Owner approves every change before deploy.
9. **Fully modular. Every feature is a self-contained module.**

---

## ARTICLE 3 — STACK (LOCKED)

| Layer | Tech |
|-------|------|
| Mobile | Flutter 3.44.4 / Dart 3.12.2 |
| State | Riverpod 2 + freezed |
| Local DB | Drift (SQLite) |
| Backend | FastAPI 0.139.0 / Python 3.11 |
| API | REST + GraphQL (Strawberry) |
| DB | PostgreSQL 18 (dev) / 14 (prod) |
| Cache | Redis 7 |
| Queue | ARQ |
| Bot | Bale Bot API |
| Auth | JWT + FarazSMS OTP |
| Host | ParsPack irVPS2 |
| OS | Ubuntu 22.04 LTS |
| Charts | fl_chart |
| Font | IranSans (primary) / Vazirmatn (fallback) |
| Calendar | Jalali native |

---

## ARTICLE 4 — VERSION PINNING

```
✅ bcrypt==4.0.1              (5.x breaks passlib — PIN FOREVER)
✅ fastapi==0.139.0
✅ uvicorn==0.49.0
✅ psycopg2-binary==2.9.12
✅ python-jose==3.5.0
✅ passlib==1.7.4
✅ Pillow==12.3.0
✅ gunicorn==26.0.0
✅ sqlalchemy==2.0.36
✅ pydantic==2.10.4
✅ pydantic-settings==2.7.0

❌ NO: isar (Dart 3.9+ incompatible)
❌ NO: liquid_glass original
❌ NO: phosphor_flutter
❌ NO: lucide_icons Flutter pkg
❌ NO: image_gallery_saver
❌ NO: gal
✅ USE: liquid_glass_easy, liquid_glass_bar (proven in ReyhanTex)
```

---

## ARTICLE 5 — SECRETS

- ALL secrets in `.env`. NEVER in code. NEVER in git.
- `.env` is in `.gitignore`. ALWAYS.
- `.env.example` is committed with placeholders.
- Rotate on leak.

---

## ARTICLE 6 — DEPLOY

Every deploy = **Backup → Build → Verify → Upload → Extract → Restart → Test → Rollback ready.**

No exceptions.

---

## ARTICLE 7 — UI LAW

- No raw colors in widgets. All from theme tokens.
- No magic numbers. All from spacing scale.
- Every state change animated.
- Every tap has haptic feedback.
- Every list has skeleton loaders.
- Every action has optimistic update + rollback.
- **60fps or it doesn't merge.**

---

## ARTICLE 8 — NAMING

| Context | Convention |
|---------|-----------|
| Flutter files | `snake_case.dart` |
| Flutter classes | `PascalCase` |
| Flutter vars | `camelCase` |
| Python files | `snake_case.py` |
| Python classes | `PascalCase` |
| Python funcs | `snake_case` |
| DB tables | `snake_case`, plural |
| DB columns | `snake_case` |
| REST endpoints | `kebab-case` |
| GraphQL fields | `camelCase` |
| Git branches | `feature/xxx`, `fix/xxx` |
| Git commits | Conventional Commits |

---

## ARTICLE 9 — DATA OWNERSHIP

- User data belongs to the user.
- Export to JSON + Markdown + ICS in ONE tap.
- Delete account = hard delete within 24h.
- No shadow profiles. No tracking. No ad SDKs. Ever.

---

## ARTICLE 10 — GOLDEN RULE

> If it's not documented, it doesn't exist.
> If it's not tested, it's broken.
> If it's not backed up, it's already lost.

---

## ARTICLE 11 — MODULARITY

**Every feature is a self-contained module.**

- Backend: `backend/app/modules/<feature>/`
  - `__init__.py`, `router.py`, `service.py`, `models.py`, `schemas.py`, `tests.py`
- Mobile: `mobile/lib/features/<feature>/`
  - `screens/`, `providers/`, `models/`, `widgets/`
- Docs: `docs/modules/<feature>.md`

Rules:
- A module may import from `app/core/` and `app/shared/`.
- A module **may not** import from another module's internals (only its public API).
- Removing a module = deleting one folder. Adding = creating one folder.
- Cross-module communication goes through services or events, never direct DB access across modules.

---

## ARTICLE 12 — GIT DISCIPLINE

- Push after **every working piece**. Small, atomic commits.
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `style:`, `perf:`.
- Never commit secrets.
- Never force-push `main`.
- Every commit leaves the tree in a working state.

---

**Signed:** Hossein Fallah — 2026-10-11