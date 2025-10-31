# MOH Medication App

This repository hosts the Kuwait Ministry of Health smart medication assistant. It contains the production backend service, the Flutter mobile application, an admin workspace, and project documentation for deploying and maintaining the platform.

## Documentation

Before making changes or running any component, read [`docs/kuwait_smart_med_assistant.md`](docs/kuwait_smart_med_assistant.md) for architecture guidance, environment prerequisites, and integration notes.

## Project Structure

- `backend/` – FastAPI backend service, including database models, API routers, and background jobs.
- `mobile/` – Flutter mobile client used by patients and caregivers.
- `admin/` – Admin dashboard workspace and related tooling.
- `docs/` – Reference documentation for architecture, operations, and data ingestion plans.

## Backend Quickstart

1. Create and activate a Python 3.11+ virtual environment.
2. Install dependencies:

   ```bash
   pip install -r backend/requirements.txt
   ```

3. Configure environment variables in a `.env` file (see `backend/app/core/config.py` for defaults).
4. Apply database migrations:

   ```bash
   alembic -c backend/alembic.ini upgrade head
   ```

5. (Optional) Seed sample Kuwait drug records:

   ```bash
   python -m backend.scripts.seed_kuwait_drugs
   ```

## Running the Backend API

Start the FastAPI server with Uvicorn:

```bash
uvicorn app.main:app --app-dir backend --reload
```

The interactive documentation is available at <http://localhost:8000/docs>.

## Background Jobs

Celery workers are configured in `backend/jobs/daily_sync.py`. Launch a worker with:

```bash
celery -A backend.jobs.daily_sync.celery_app worker --loglevel=info
```

Schedule the `drugs.sync_external_sources` task daily to refresh RxNorm, DailyMed, and openFDA data sources.
