# MOH Medication App

The MOH Medication App is a multi-platform solution that streamlines medication management for healthcare professionals and patients. It comprises three main components:

- **Backend FastAPI service** that powers the core medication APIs and authentication services.
- **Flutter mobile application** for clinicians and patients to view prescriptions, record medication adherence, and receive reminders.
- **React-based admin panel** used by administrators to configure formularies, monitor usage analytics, and manage user permissions.

This document explains the prerequisites, configuration, and step-by-step instructions to set up, run, and contribute to each part of the project.

## Prerequisites

Before you begin, ensure the following tools are installed on your machine:

- [Python 3.11+](https://www.python.org/downloads/) and [pip](https://pip.pypa.io/en/stable/)
- [Poetry](https://python-poetry.org/docs/) for managing backend dependencies
- [Node.js 18+ and npm](https://nodejs.org/en/download/) for the React admin panel
- [Flutter 3.19+](https://docs.flutter.dev/get-started/install) with the appropriate SDKs for your target platform (Android/iOS)
- [Git](https://git-scm.com/) for version control
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (optional, for containerized deployments)

You will also need access credentials for any third-party services (e.g., email, SMS, analytics) configured in your deployment.

## Repository Layout

```
backend/             # FastAPI service code
mobile_app/          # Flutter mobile application
admin_panel/         # React admin interface
infrastructure/      # Deployment scripts and IaC templates
README.md            # You are here
```

> **Note:** If any of these directories are missing in your local clone, check out the relevant Git submodules or branches that contain the component you wish to work on.

## Environment Variables

Create a `.env` file in the root of each component (or populate your preferred secret manager) with the following keys. Replace the placeholder values with the credentials for your environment.

### Backend (`backend/.env`)

```
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/moh_medications
REDIS_URL=redis://localhost:6379/0
SECRET_KEY=change-me
ACCESS_TOKEN_EXPIRE_MINUTES=60
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your-smtp-user
SMTP_PASSWORD=your-smtp-password
SENTRY_DSN=
```

### Flutter Mobile App (`mobile_app/.env` or `lib/constants/config.dart`)

```
API_BASE_URL=http://localhost:8000
SENTRY_DSN=
FIREBASE_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_APP_ID=
```

> Flutter does not natively load `.env` files. Use packages such as [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) or set the values in compile-time configuration files as required.

### React Admin Panel (`admin_panel/.env.local`)

```
VITE_API_BASE_URL=http://localhost:8000
VITE_SENTRY_DSN=
VITE_ANALYTICS_KEY=
```

Remember to keep secret values out of version control. Use tools like [direnv](https://direnv.net/), [Doppler](https://www.doppler.com/), or your CI/CD provider's secret manager to manage credentials in different environments.

## Backend FastAPI Service

Follow these steps to set up and run the backend API locally.

1. **Install dependencies:**
   ```bash
   cd backend
   poetry install
   ```
2. **Activate the virtual environment:**
   ```bash
   poetry shell
   ```
3. **Apply database migrations:**
   ```bash
   alembic upgrade head
   ```
4. **Seed initial data (optional):**
   ```bash
   python scripts/seed_data.py
   ```
5. **Start the development server:**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

The API will be available at `http://localhost:8000`. Auto-generated API documentation is accessible at `http://localhost:8000/docs` (Swagger UI) and `http://localhost:8000/redoc` (ReDoc).

### Running Tests

```bash
pytest
```

For more information about FastAPI, see the [official documentation](https://fastapi.tiangolo.com/).

## Flutter Mobile Application

The Flutter app consumes the backend APIs to deliver a patient- and clinician-facing experience.

1. **Install Flutter dependencies:**
   ```bash
   cd mobile_app
   flutter pub get
   ```
2. **Configure Firebase (if applicable):** Follow the instructions in the [`firebase_options.dart`](mobile_app/lib/firebase_options.dart) file or use the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) to generate configuration files.
3. **Run code generation (if using freezed/json_serializable, etc.):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Launch the app:**
   ```bash
   flutter run
   ```

Use `flutter run -d chrome` for web, `flutter run -d android` for Android emulators, or `flutter run -d ios` for iOS simulators.

### Testing & Quality Checks

```bash
flutter test
flutter analyze
```

Refer to the [Flutter documentation](https://docs.flutter.dev/) for detailed guidance on tooling, debugging, and platform-specific setup.

## React Admin Panel

The admin panel is built with Vite and React to provide administrative tooling.

1. **Install dependencies:**
   ```bash
   cd admin_panel
   npm install
   ```
2. **Start the development server:**
   ```bash
   npm run dev -- --host 0.0.0.0 --port 5173
   ```
3. **Access the application:** Open `http://localhost:5173` in your browser. Ensure the backend service is running so API calls succeed.

### Testing & Linting

```bash
npm test
npm run lint
```

See the [React documentation](https://react.dev/learn), [Vite guide](https://vitejs.dev/guide/), and [Testing Library docs](https://testing-library.com/docs/react-testing-library/intro/) for additional resources.

## Contributing

1. Fork the repository and create a feature branch.
2. Ensure all linting and tests pass for each component you modify.
3. Commit your changes with clear messages and open a pull request.
4. Follow the project's coding standards and include updates to documentation or tests when applicable.

Refer to [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow) for a refresher on the contribution process.

## Support & Further Reading

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [React Documentation](https://react.dev/learn)
- [Vite Documentation](https://vitejs.dev/guide/)
- [Alembic Migration Tool](https://alembic.sqlalchemy.org/en/latest/)
- [Poetry Dependency Management](https://python-poetry.org/docs/)

If you encounter issues or have questions, open an issue in the repository with detailed reproduction steps.
