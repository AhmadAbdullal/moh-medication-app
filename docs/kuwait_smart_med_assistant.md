# Kuwait Smart Medication Assistant Product Specification

## 1. Vision and Objectives
- **Vision:** Deliver a nationwide digital companion that enables Kuwaiti residents to manage medication schedules, understand prescriptions, and coordinate with Ministry of Health services from mobile and web devices.
- **Mission Objectives:**
  - Improve adherence to physician-prescribed regimens through intelligent reminders and contextual education.
  - Provide clinicians and pharmacists a unified view of patient medication histories to reduce adverse drug events.
  - Integrate seamlessly with existing Ministry of Health (MOH) systems while adhering to Kuwait's data residency, privacy, and security regulations.
  - Offer multilingual support (Arabic-first with English fallback) to ensure accessibility for diverse user groups.

## 2. Product Scope & Personas
- **Primary Personas:**
  - **Patients:** Adults managing chronic or acute medication regimens requiring reminders, education, and refill tracking.
  - **Caregivers:** Family members who assist patients with medication adherence and require delegated access.
  - **Clinicians & Pharmacists:** Healthcare professionals who review adherence data, adjust prescriptions, and send secure communications.
  - **MOH Administrators:** Officials responsible for monitoring population-level trends, ensuring compliance, and configuring system-wide rules.
- **Out-of-Scope (Phase 1):** Telemedicine video consultations, in-app payments, and non-medication health tracking (e.g., fitness, diet).

## 3. Functional Requirements Summary
- Intelligent medication scheduling with timezone awareness and flexible reminder cadence.
- Prescription digitization and barcode scanning to capture dosages, frequencies, and instructions.
- Medication interaction checker leveraging approved MOH datasets.
- Secure messaging between patients, caregivers, and clinicians.
- Adherence analytics dashboards for clinicians and MOH administrators.
- Localization support for Arabic (RTL) and English (LTR) with dynamic language switching.

## 4. Naming Conventions
- **Repository Naming:** `kuwait-smart-med-assistant` for primary monorepo; service repositories follow `ksa-<service>` (e.g., `ksa-medication-service`).
- **Branch Naming:** `feature/<summary>`, `bugfix/<summary>`, `hotfix/<summary>`, `release/<YYYYMMDD>`.
- **Environment Prefixes:** `dev-`, `staging-`, `prod-` for infrastructure, secrets, and build artifacts.
- **Database Tables:** snake_case (e.g., `patient_profiles`). Columns also snake_case.
- **API Routes:** Kebab-case paths (e.g., `/medication-plans`) with version prefix `/api/v1`.
- **UI Components:** PascalCase for React components (e.g., `MedicationTimeline`). CSS modules/Sass variables use kebab-case.
- **CI Jobs:** `<pipeline>-<stage>-<job>` (e.g., `app-build-unit-tests`).

## 5. Brand & UI Guidelines
- **Primary Typeface:** `Noto Sans Arabic` for Arabic text, `Inter` for English text.
- **Color Palette:**
  - Primary Blue: `#006FBA`
  - Secondary Teal: `#2CBFBF`
  - Accent Gold: `#FFC857`
  - Success Green: `#2E8B57`
  - Warning Amber: `#FF9F1C`
  - Error Red: `#D1495B`
  - Neutral Dark: `#2B2D42`
  - Neutral Light: `#F7F9FC`
- **Logo Placement:** Top-left on web header; center-aligned on splash screens.
- **Accessibility:** Minimum contrast ratio 4.5:1; font size 16px base; support text resizing up to 200% without breaking layout.

## 6. Screen Requirements & UX Flows
1. **Onboarding & Authentication**
   - Phone number + OTP verification (integrated with MOH identity provider).
   - Consent capture for data sharing (localized copies in Arabic and English).
2. **Dashboard**
   - Today's medication schedule, adherence summary, upcoming appointments.
   - Quick actions: log dose taken, request refill, contact clinician.
3. **Medication Plan Detail**
   - Timeline view with dosage instructions, interaction alerts, refill countdown.
   - Edit requests trigger clinician approval workflow.
4. **Prescription Capture**
   - Barcode/QR scanning, manual entry fallback, image upload (OCR pipeline).
5. **Reminder Management**
   - Configure reminder types (push, SMS, call), snooze options, escalation to caregivers.
6. **Caregiver Access**
   - Delegation invitation, role-based permissions, activity log.
7. **Secure Messaging**
   - Threaded conversations, file attachments (PDF, JPG), auto-translation hints.
8. **Clinician Portal**
   - Patient list, adherence heatmap, prescription adjustments, digital signatures.
9. **MOH Administration**
   - Population analytics dashboard, compliance reports, system configuration (e.g., formulary updates).
10. **Settings & Profile**
    - Language toggle, notification preferences, linked devices, privacy center.

Each screen must support responsive layouts for 320px width (mobile) through desktop widths.

## 7. Data Model & Database Schema
### Core Entities
- **patient_profiles**
  - `id` (UUID, PK)
  - `national_id` (string, unique, encrypted at rest)
  - `first_name`, `last_name`, `date_of_birth`, `gender`
  - `primary_language`, `contact_phone`, `email`
  - `created_at`, `updated_at`
- **caregiver_links**
  - `id` (UUID, PK)
  - `patient_id` (FK -> patient_profiles)
  - `caregiver_id` (FK -> patient_profiles)
  - `role` (enum: `viewer`, `manager`)
  - `status` (enum: `pending`, `active`, `revoked`)
  - `created_at`, `updated_at`
- **clinician_profiles**
  - `id` (UUID, PK)
  - `moh_license_number` (string, unique)
  - `facility_id` (FK -> healthcare_facilities)
  - `specialty`, `contact_email`, `contact_phone`
  - `created_at`, `updated_at`
- **medication_catalog**
  - `id` (UUID, PK)
  - `drug_code` (string, MOH formulary code)
  - `display_name_ar`, `display_name_en`
  - `dosage_form`, `strength`
  - `interaction_profile` (JSONB)
  - `created_at`, `updated_at`
- **medication_plans**
  - `id` (UUID, PK)
  - `patient_id` (FK -> patient_profiles)
  - `prescriber_id` (FK -> clinician_profiles)
  - `start_date`, `end_date`
  - `status` (enum: `active`, `paused`, `completed`, `cancelled`)
  - `notes`
  - `created_at`, `updated_at`
- **medication_doses**
  - `id` (UUID, PK)
  - `plan_id` (FK -> medication_plans)
  - `medication_id` (FK -> medication_catalog)
  - `dosage_instructions` (text)
  - `schedule_pattern` (JSONB: supports cron-like expressions, timezone)
  - `reminder_channels` (array enum: `push`, `sms`, `call`, `email`)
  - `requires_meal` (boolean)
  - `created_at`, `updated_at`
- **adherence_logs**
  - `id` (UUID, PK)
  - `dose_id` (FK -> medication_doses)
  - `taken_at` (timestamp with timezone)
  - `status` (enum: `taken`, `missed`, `snoozed`)
  - `recorded_by` (FK -> patient_profiles/caregiver)
  - `notes`
  - `created_at`
- **refill_requests**
  - `id` (UUID, PK)
  - `plan_id` (FK -> medication_plans)
  - `requested_by` (FK -> patient_profiles)
  - `status` (enum: `pending`, `approved`, `denied`, `fulfilled`)
  - `pharmacy_id` (FK -> healthcare_facilities)
  - `created_at`, `updated_at`
- **messages**
  - `id` (UUID, PK)
  - `thread_id` (UUID, logical thread grouping)
  - `sender_id`, `recipient_id` (FK -> user accounts)
  - `body`, `attachments` (JSONB)
  - `read_at`
  - `created_at`
- **system_audit_logs**
  - `id` (UUID, PK)
  - `actor_id`, `actor_role`
  - `action`, `resource_type`, `resource_id`
  - `metadata` (JSONB)
  - `created_at`

### Supporting Tables
- `healthcare_facilities`, `device_tokens`, `identity_providers`, `feature_flags`, `api_clients` (for external integrations).

### Data Governance
- Encrypt sensitive columns using KMS-backed keys.
- Store audit logs immutable for minimum 7 years.
- Implement data retention policies aligned with MOH regulation 2023-17.

## 8. API Specification (REST + GraphQL Hybrid)
- **Base URL:** `https://api.moh.gov.kw/ksa` with versioning via `/api/v1` prefix for REST and `/graphql` endpoint for complex queries.
- **Authentication:** OAuth 2.0 with MOH identity provider; short-lived access tokens, refresh tokens stored securely. Patient/caregiver apps use PKCE.

### REST Endpoints (v1)
- `POST /api/v1/auth/otp/request` – initiate OTP login.
- `POST /api/v1/auth/otp/verify` – validate OTP and issue tokens.
- `GET /api/v1/patients/{patientId}` – fetch patient profile (role-restricted).
- `PATCH /api/v1/patients/{patientId}` – update contact info or preferences.
- `GET /api/v1/patients/{patientId}/medication-plans` – list active and historical plans.
- `POST /api/v1/patients/{patientId}/medication-plans` – request new plan or upload prescription.
- `GET /api/v1/medication-plans/{planId}` – retrieve plan details.
- `PATCH /api/v1/medication-plans/{planId}` – update plan metadata (clinician only).
- `POST /api/v1/medication-plans/{planId}/doses` – add dose instructions.
- `POST /api/v1/medication-plans/{planId}/adherence` – submit adherence event.
- `GET /api/v1/medication-plans/{planId}/adherence` – fetch adherence history.
- `POST /api/v1/medication-plans/{planId}/refill-requests` – request refill.
- `GET /api/v1/refill-requests/{requestId}` – status check.
- `POST /api/v1/messages` – send secure message.
- `GET /api/v1/messages/threads` – list message threads for current user.
- `GET /api/v1/messages/threads/{threadId}` – fetch messages.
- `POST /api/v1/caregivers/invitations` – invite caregiver.
- `PATCH /api/v1/caregivers/{linkId}` – update status/permissions.
- `GET /api/v1/admin/analytics/adherence` – MOH analytics dataset.
- `POST /api/v1/admin/formulary` – upload formulary update file.

### GraphQL Schema Highlights
- `type Patient { id, profile, medicationPlans, caregivers, adherenceSummary }`
- `type MedicationPlan { id, doses, interactions, refillStatus }`
- `type Query { currentUser, patient(id: ID!), medicationPlan(id: ID!) }`
- `type Mutation { logAdherence(input: LogAdherenceInput!): AdherenceLog }`

### API Standards
- JSON:API formatted responses, consistent error envelopes with `code`, `message`, `details`.
- Pagination via cursor-based approach (`page[cursor]`, `page[size]`).
- Rate limiting (per user: 200 requests/minute, per client: 1000 requests/minute).
- Webhooks for refill approvals and formulary updates, signed with HMAC SHA-256.

## 9. Technology Stack
- **Frontend:** React Native (mobile), Next.js (web portal), Tailwind CSS + custom design tokens.
- **Backend:** Node.js (NestJS) for REST + GraphQL gateway, Python microservices (FastAPI) for OCR, interaction checker, and analytics pipelines.
- **Databases:** PostgreSQL 14 (primary transactional), Redis (caching, session store), Elasticsearch (searchable medication catalog and messages).
- **Infrastructure:** Kubernetes (EKS) across dev/staging/prod, Terraform for IaC, AWS S3 for secure file storage, AWS KMS for encryption keys, AWS SNS/SQS for notification orchestration.
- **Identity & Access:** Integration with MOH Single Sign-On (OpenID Connect), multi-factor authentication for clinicians and admins.

## 10. CI/CD Expectations
- **Source Control:** GitHub Enterprise with mandatory PR reviews and status checks.
- **Pipelines:** GitHub Actions orchestrating build, test, security, and deployment stages.
  - Stage 1: Lint & unit tests (frontend, backend, Python services).
  - Stage 2: Integration tests with service containers, contract tests.
  - Stage 3: Security scans (Snyk, Trivy) and dependency license checks.
  - Stage 4: Build artifacts (mobile bundles via EAS, Docker images via BuildKit).
  - Stage 5: Infrastructure deployment using Terraform with plan/apply approval gates.
- **Deployment Strategy:**
  - Dev: Continuous deployment on merge to `main`.
  - Staging: Scheduled promotion with smoke tests and QA sign-off.
  - Production: Blue/green releases with canary traffic (10%, 50%, 100%) monitored by health checks.
- **Observability:** Automated dashboards (Datadog), alerting thresholds, synthetic tests.
- **Release Notes:** Automated changelog generation and localization (Arabic, English).

## 11. Security & Compliance
- Adhere to Kuwait's Personal Data Protection Law (PDPL) and MOH-specific regulations.
- Data residency: store patient data in Kuwaiti data centers or approved sovereign cloud.
- End-to-end encryption for messaging, TLS 1.2+ enforced, HSTS on web endpoints.
- Role-based access control (RBAC) with attribute-based extensions for clinician scopes.
- Regular penetration testing and vulnerability management.
- Logging & auditing aligned with ISO 27001 controls.

## 12. Testing & Quality Assurance
- **Unit Tests:** 80% coverage for backend services, 70% for frontend components.
- **Integration Tests:** API contract tests using Pact; end-to-end flows via Cypress (web) and Detox (mobile).
- **Performance Testing:** Load tests to ensure adherence logging handles 5k concurrent users.
- **Localization Testing:** Ensure Arabic text renders RTL correctly, no truncation.
- **Accessibility Testing:** Automated (axe) + manual screen reader reviews.

## 13. Analytics & Reporting
- Event tracking via Segment > Snowflake pipeline.
- KPI dashboards: adherence rate, refill compliance, active users, response time to clinician messages.
- Privacy controls allowing users to opt-in/out of analytics events (non-essential).

## 14. Future Integrations & Roadmap Considerations
- **EHR Integration:** HL7 FHIR interfaces with MOH hospital systems for prescription ingestion and discharge summaries.
- **Pharmacy Networks:** Real-time stock checks and e-prescription fulfillment via APIs with major pharmacy chains.
- **Wearable Devices:** Import medication reminders into Apple HealthKit and Google Fit ecosystems.
- **AI Assistant:** NLP-based chatbot for medication Q&A leveraging MOH-approved knowledge base.
- **Telehealth Expansion:** Integration with video consultation platform (Phase 3).
- **Population Health:** Predictive analytics for adherence risk scoring using anonymized datasets.

## 15. Non-Functional Requirements
- Uptime SLA: 99.9% for production APIs.
- Mobile app latency target: <200ms for primary dashboard load on 4G networks.
- Offline support for logging doses with sync-on-connect.
- Data backup: point-in-time recovery with 15-minute RPO, 1-hour RTO.

## 16. Glossary
- **MOH:** Ministry of Health (Kuwait).
- **PDPL:** Personal Data Protection Law.
- **KMS:** Key Management Service.
- **RBAC:** Role-Based Access Control.
- **FHIR:** Fast Healthcare Interoperability Resources.
- **EAS:** Expo Application Services.
