# MOH Medication App

This repository hosts the Kuwait Ministry of Health smart medication assistant. It will contain:
- backend (FastAPI)
- Flutter mobile app
- admin workspace
- project documentation

> **Important:** the repo currently has the Flutter app (`mobile/`) and the docs (`docs/`). Backend and admin will be filled in the next tasks.

---

## Requirements

- Python **3.11+**
- Flutter **3.x**
- Git + GitHub

---

## Documentation

Before making changes or running any component, read:

- [`docs/kuwait_smart_med_assistant.md`](docs/kuwait_smart_med_assistant.md) – architecture, flows, roles, and naming.
- If present: [`docs/rxnorm_sources_for_codex.md`](docs/rxnorm_sources_for_codex.md) – external drug-data sources (RxNorm, DailyMed, openFDA) to be ingested later.

---

## Repository Layout

- `backend/` – **FastAPI backend service** (auth, drugs DB, schedules, devices/FCM)  
  *(to be implemented – keep the folder name exactly `backend/`)*

- `mobile/` – **Flutter mobile client** for patients and caregivers (AR first, EN fallback)  
  *(this is the one that exists now – use this, do **not** create `mobile_app/`)*

- `admin/` – **React/Vite admin console** for MoH/pharmacists to review imported drugs and unmatched Kuwait items  
  *(to be implemented later)*

- `docs/` – **Project documentation** (product spec, Kuwait flows, later: data-ingestion notes)

---

## Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
Notes:

Default language: Arabic (RTL)

Theme: white + green (#0F9D58)

API base URL should be defined in a single place (lib/core/config.dart) as:

dart
Copy code
class AppConfig {
  static const String apiBaseUrl = "http://localhost:8000/api/v1";
}
Any HTTP service in the app should read from this constant, not from hardcoded URLs.

Backend (FastAPI) – placeholder
When the backend folder is added, expected flow:

bash
Copy code
cd backend
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
Expose /api/v1/...

Enable CORS for local Flutter / local admin

Add a daily job to sync external drug sources:

now: RxNorm

later: DailyMed + openFDA

Background Jobs (optional)
If Celery/worker files exist in backend/jobs/, run:

bash
Copy code
celery -A backend.jobs.daily_sync.celery_app worker --loglevel=info
Then schedule:

text
Copy code
drugs.sync_external_sources → daily
This will refresh RxNorm now, and later DailyMed/openFDA when connectors are ready.

Conventions (important for Codex/agents)
Use only these top-level folders: backend/, mobile/, admin/, docs/.

Do not create: mobile_app/, admin_panel/, infrastructure/.

Always link to docs/kuwait_smart_med_assistant.md from new README/PRs.

PR title format: chore: repo normalization or feat: mobile screen ...
