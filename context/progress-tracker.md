# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

- Unit 02 completed; Unit 03 (Offline Lessons and Progress) next up.

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

## In Progress

- None.

## Next Up

- Unit 03: Offline Lessons and Progress (Local lesson list, lesson detail screen, mark lesson complete, store completion locally, display progress).

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
