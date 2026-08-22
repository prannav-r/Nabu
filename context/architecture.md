# Architecture

## Stack

| Layer | Technology | Role |
|---|---|---|
| Android app | Flutter + Dart | UI and application logic |
| Local database | SQLite | Offline lessons, users, attempts, progress, sync queue |
| Offline AI | ONNX Runtime | Local model inference |
| Voice | Flutter/platform speech APIs | Speech-to-text and text-to-speech |
| Backend | FastAPI + Python | Authentication and synchronization API |
| Cloud database | Supabase PostgreSQL | Remote synchronized data |
| Version control | Git | Source control |

## System Architecture

```text
Flutter Android App
│
├── Presentation
│   ├── Home
│   ├── Lessons
│   ├── Tutor
│   ├── Quiz
│   ├── Progress
│   └── Settings
│
├── Application Logic
│   ├── Tutor service
│   ├── Quiz service
│   ├── Progress service
│   ├── Sync service
│   └── Connectivity service
│
├── Local Data
│   └── SQLite
│
├── Offline AI
│   └── ONNX Runtime
│
└── Remote API
    └── FastAPI
         └── Supabase PostgreSQL
```

## System Boundaries

### Flutter

Owns:

- Screens and UI.
- Local application state.
- Local database access.
- AI model invocation.
- Voice interaction.
- Connectivity detection.
- Sync orchestration.

Flutter must not contain cloud database credentials or privileged backend secrets.

### SQLite

Owns:

- Student/local profile data.
- Lessons available offline.
- Quiz questions.
- Quiz attempts.
- Progress.
- Sync queue/status.

SQLite is the source of truth for learning activity while offline.

### ONNX Runtime

Owns:

- Loading the bundled model.
- Preparing model input.
- Running local inference.
- Returning model output.

The model must not require an internet connection.

### FastAPI

Owns:

- Authentication endpoints.
- Sync endpoints.
- Request validation.
- Server-side authorization.
- Writing synchronized data to PostgreSQL.

FastAPI does not perform the primary tutor inference.

### PostgreSQL

Owns:

- Remote student/account records required for synchronization.
- Synchronized progress.
- Synchronized quiz attempts.
- Server-side timestamps/IDs.

## Storage Model

### SQLite

Store:

- local student ID
- lesson metadata/content
- quiz questions
- quiz attempts
- scores
- progress
- sync status
- local timestamps
- server IDs where applicable

### PostgreSQL

Store only data required for synchronization and remote persistence.

### Model Files

The ONNX model is packaged with the Android application or downloaded through a controlled update mechanism later. For the MVP, package the model with the app.

## Synchronization Model

Use an explicit sync queue.

Each locally generated syncable record should have:

- stable local ID
- optional server ID
- created timestamp
- updated timestamp
- sync status

Basic states:

```text
pending → syncing → synced
             │
             └────→ pending
```

If a request fails, preserve the local record and return it to `pending`.

Use idempotent server operations so retrying the same local record does not create duplicates.

## Authentication

For the MVP:

- Authenticate through FastAPI.
- Passwords are hashed with a strong password hashing algorithm.
- Authentication tokens are short-lived where practical.
- Never store plaintext passwords.
- Never embed database credentials in the app.
- The client may store a user token securely using platform secure storage.
- Deployed API traffic must use HTTPS.

## Invariants

1. The app must remain usable for core learning features without internet.
2. No tutor request may require a cloud AI API.
3. Local progress must be saved before attempting synchronization.
4. Failed synchronization must never delete local progress.
5. Synchronization must be retryable without creating duplicate records.
6. Android code must never contain PostgreSQL credentials or privileged Supabase keys.
7. The backend must validate authenticated requests before mutating remote data.
8. Dependencies must be added only when required by an implemented feature.
9. Do not add a second AI inference runtime.
10. Do not replace SQLite with a cloud database for offline functionality.
