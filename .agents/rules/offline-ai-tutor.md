# Offline AI Tutor — Antigravity Workspace Rule

This rule is always applicable to this project.

## Mission

Build a small, functional offline-first Android AI tutor for rural schools. Optimize for working functionality, simplicity, zero/near-zero cost, and easy demonstration—not production-scale infrastructure.

## Mandatory Behavior

- Read the project context before implementing.
- Work only on the requested build unit.
- Prefer the simplest solution that satisfies the requirement.
- Install dependencies only when they are actually needed.
- Never introduce infrastructure merely because it is common in production systems.
- Preserve offline operation as a first-class requirement.
- Keep local data authoritative while the device is offline.
- Treat synchronization as a separate concern from local learning functionality.
- Never put secrets, database passwords, service-role keys, or private credentials in the Android application.
- Never store plaintext passwords.
- Validate data at the API boundary.
- Use HTTPS for deployed API communication.
- Do not claim a feature is complete until it has been tested.

## Approved Stack

- Flutter/Dart for the Android application.
- SQLite for local persistence.
- ONNX Runtime for offline inference.
- FastAPI/Python for the synchronization backend.
- Supabase PostgreSQL for the optional free cloud database.
- Flutter/platform speech-to-text and text-to-speech for voice interaction.

## Forbidden Unless Explicitly Requested

Docker, Kubernetes, Firebase, AWS, Azure, MongoDB, Redis, Kafka, Node.js, React, Next.js, LangChain, vector databases, paid APIs, paid hosting, and duplicate AI runtimes.

## Development Style

Keep files small and responsibilities clear. Avoid premature abstractions. Prefer straightforward CRUD, REST, and local database code. Do not refactor unrelated code while implementing a feature.
