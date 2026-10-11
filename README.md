# 🎯 TaskVerse

> **باغِ کار** — The most beautiful Persian-first task manager ever built.

TaskVerse is a self-hosted, offline-first, modular task manager with:
- 📱 A premium Flutter Android app
- 🤖 A native Bale bot for daily briefs (7AM), recaps, and voice task creation
- 🌐 A FastAPI backend (REST + GraphQL), fully modular
- 🗄️ PostgreSQL + Redis, running on an Iranian VPS
- 🔒 Zero foreign telemetry, full data ownership

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| [`TASKVERSE_CONSTITUTION.md`](./TASKVERSE_CONSTITUTION.md) | Non-negotiable rules |
| [`TASKVERSE_BIBLE.md`](./TASKVERSE_BIBLE.md) | Full spec: vision, features, API, bot flows |
| [`TRACKER.md`](./TRACKER.md) | Live sprint progress |

---

## 🏗️ Stack

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
| Host | ParsPack irVPS2 (Tehran) |
| Charts | fl_chart |

---

## 🧩 Modular Architecture

Every feature is a **self-contained module**:

- **Backend:** `backend/app/modules/<feature>/` — router, service, models, schemas, tests
- **Mobile:** `mobile/lib/features/<feature>/` — screens, providers, models, widgets

Adding a feature = creating one folder. Removing = deleting one folder.

---

## 🗂️ Project Structure

```
taskVerse/
├── backend/
│   ├── app/
│   │   ├── core/          Config, database, security, logging
│   │   ├── modules/       Feature modules (health, tasks, people, ...)
│   │   ├── shared/        Reusable utilities
│   │   └── main.py        App factory
│   ├── migrations/        SQL migrations
│   ├── scripts/           DB init, seed
│   ├── storage/           Attachments
│   └── tests/             Pytest suite
├── mobile/                Flutter app
├── docs/                  API + design + module docs
└── scripts/               Deploy + backup
```

---

## 🚦 Development

### Backend
```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt -r requirements-dev.txt
uvicorn app.main:app --reload --port 8000
```
Visit `http://localhost:8000/health`

### Mobile
```powershell
cd mobile
flutter pub get
flutter run
```

---

## 📜 License

Proprietary. See [LICENSE](./LICENSE).

---

**Built with 🖤 in Tehran.**