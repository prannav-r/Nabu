# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

- Unit 07 completed; Unit 08 (Synchronization) next up.

## Current Goal

- Create the minimal functional Offline AI Tutor MVP.

## Completed

- [x] Product scope defined.
- [x] Minimal technology stack selected.
- [x] Offline-first architecture defined.
- [x] Context and agent rules created.
- [x] Build order defined.
- [x] Unit 01: Flutter application shell, theme, navigation, and placeholder screens.
- [x] Unit 02: Local SQLite Database schema, seed data, models, and repository layer.
- [x] Unit 03: Offline Lessons and Progress (Local lesson browsing, lesson detail view, offline completion toggling, and local progress calculation).
- [x] Unit 04: Offline ONNX Tutor (Local ONNX model loading, input handling, offline inference service, and tutor chat interface).
- [x] Unit 05: Offline Quizzes (Dynamic quiz interface, multiple-choice selection, scoring, local SQLite attempt recording, and score review).
- [x] Unit 06: Voice Interaction (Speech-to-text input, microphone interaction in Tutor, and text-to-speech audio playback for AI responses).
- [x] Unit 07: FastAPI Backend (FastAPI application with uv, Pydantic schemas, bcrypt password hashing, JWT auth, idempotent sync endpoints, and health check).

## In Progress

- None.

## Next Up

- Unit 08: Synchronization (Connectivity detection, local pending-sync queue management, upload orchestration, retry logic on failure, and server response handling).

## Open Questions

- Exact lightweight ONNX model to use.
- Exact local quiz-generation approach after testing the selected model.
- Exact free Supabase configuration when remote synchronization is implemented.

Do not block early implementation on these questions unless they affect the current unit.

## Architecture Decisions

- Flutter is the Android application framework.
- SQLite is the local source of truth for offline learning activity.
- ONNX Runtime is the only offline AI runtime.
- FastAPI is used instead of Flask because this project is primarily a REST API.
- Supabase PostgreSQL is the remote database option.
- Cloud deployment is deferred until local offline and synchronization behavior works.
- No Docker or Kubernetes.
- No paid AI API.
- No cloud AI inference.
- Core learning features must work in airplane mode.

## Session Notes

- Follow the build plan in `context/specs/00-build-plan.md`.
- Install dependencies just in time.
- Verify each unit before continuing.
