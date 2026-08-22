# Code Standards

## General

- Use simple, readable code.
- Prefer explicit code over clever abstractions.
- Keep each file focused on one responsibility.
- Do not refactor unrelated code during feature work.
- Do not add a dependency when the standard library or an existing dependency is sufficient.
- Use meaningful names.
- Keep functions reasonably small.
- Add comments only where they explain non-obvious behavior.

## Flutter/Dart

- Follow standard Dart formatting.
- Use `dart format`.
- Use null safety.
- Prefer immutable data where practical.
- Separate UI widgets from data/services.
- Keep database, AI, sync, and network code out of presentation widgets.
- Do not place API URLs, secrets, or database credentials directly in widgets.
- Use a clear feature-oriented structure.

Recommended structure:

```text
app/
  lib/
    core/
    data/
      local/
      remote/
    features/
      auth/
      lessons/
      tutor/
      quiz/
      progress/
      sync/
      voice/
    main.dart
```

## SQLite

- Use parameterized queries.
- Give tables stable primary keys.
- Keep sync status explicit.
- Store timestamps consistently.
- Do not delete unsynchronized records as part of normal cleanup.
- Database migrations must preserve existing user data.

## ONNX

- Keep model loading and inference inside a dedicated service.
- Load the model once when practical rather than for every question.
- Validate input shape/type before inference.
- Handle model errors without crashing the application.
- Keep the model file outside UI code.

## FastAPI

Recommended structure:

```text
backend/
  app/
    main.py
    api/
    services/
    models/
    schemas/
    db/
    core/
```

- Use Pydantic request/response schemas.
- Validate all client input.
- Keep route handlers thin.
- Put business logic in services.
- Use parameterized database operations/ORM facilities.
- Never expose privileged database credentials to clients.
- Return clear HTTP status codes.
- Do not log passwords or authentication tokens.

## API

Use simple REST endpoints.

Example:

```text
POST /auth/login
POST /auth/register
POST /sync
GET  /sync/status
GET  /lessons
```

Keep the API small. Do not create endpoints without a feature requiring them.

## Testing

Prioritize functional tests for:

- local database writes
- offline tutor invocation
- quiz scoring
- sync queue behavior
- retry after failed sync
- duplicate sync prevention
- authentication

For the MVP, tests should target important behavior rather than achieving arbitrary coverage percentages.
