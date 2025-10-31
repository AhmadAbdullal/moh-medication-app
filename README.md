# MOH Medication App Backend

This repository contains a FastAPI-based backend for the Kuwait Ministry of Health smart medication assistant. It exposes authentication, patient schedule, and drug catalog APIs backed by PostgreSQL and SQLAlchemy ORM models. The service also integrates with public RxNorm, DailyMed, and openFDA APIs to enrich the medication catalog and capture provenance for imported data.

## Features

- Token-based authentication flows with email/password and phone OTP login endpoints.
- CRUD-style access to patient medication schedules and dose logging.
- Admin surfaces for reconciling local Kuwait drug records against RxNorm master data.
- Celery-powered background jobs that periodically synchronize data from external drug information sources.
- Alembic migrations and seed scripts to bootstrap the development database.

## Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL 13+
- Redis (for Celery background jobs)

### Installation

1. Create and activate a virtual environment.
2. Install dependencies:

   ```bash
   pip install -r backend/requirements.txt
   ```

3. Configure environment variables in a `.env` file (see `backend/app/core/config.py` for defaults). At minimum, set `DATABASE_URL` and `SECRET_KEY`.

4. Apply database migrations:

   ```bash
   alembic -c backend/alembic.ini upgrade head
   ```

5. (Optional) Seed sample Kuwait drug records:

   ```bash
   python -m backend.scripts.seed_kuwait_drugs
   ```

### Running the API

Start the FastAPI server with Uvicorn:

```bash
uvicorn app.main:app --app-dir backend --reload
```

The interactive docs are available at <http://localhost:8000/docs>.

### Background Jobs

Celery workers are configured in `backend/jobs/daily_sync.py`. Launch a worker with:

```bash
celery -A backend.jobs.daily_sync.celery_app worker --loglevel=info
```

A beat scheduler (or external cron) should enqueue the `drugs.sync_external_sources` task daily to refresh RxNorm, DailyMed, and openFDA data. The ingestion clients live in `backend/app/services/` and encapsulate the public endpoints for these data sources.

## Project Structure

- `backend/app` – FastAPI application code (routers, schemas, models, services).
- `backend/alembic` – Database migration environment.
- `backend/jobs` – Celery application and scheduled task definitions.
- `backend/scripts` – Utility scripts (e.g., seeding local Kuwait drug data).

## Development Tips

- Run `python -m compileall backend` to ensure Python modules compile cleanly.
- Configure logging and dependency overrides in `backend/app/core/` for local testing.
- Use the ingestion clients to backfill the master drug catalog before exposing new medications to mobile clients; unverified drugs remain tagged via the `verified_status` field.
