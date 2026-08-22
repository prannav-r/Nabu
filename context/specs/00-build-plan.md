# Build Plan

## Build Strategy

Build the smallest working system first. Dependencies are introduced only when needed.

## Units

### Unit 01 — Flutter Application Shell

Build:

- Flutter Android project.
- Basic Material theme.
- Main navigation.
- Placeholder Home, Lessons, Tutor, Quiz, Progress, Settings screens.
- Offline status placeholder.

Dependencies:

- Flutter SDK.
- Android SDK.

Verify:

- [ ] App launches on Android.
- [ ] Navigation works.
- [ ] No unnecessary packages installed.
- [ ] Basic UI renders on a phone.

### Unit 02 — Local SQLite Database

Build:

- Local database.
- Student/profile table.
- Lessons table.
- Quiz questions table.
- Quiz attempts table.
- Progress table.
- Sync queue/status fields.
- Repository layer.

Verify:

- [ ] Data can be inserted.
- [ ] Data can be read after app restart.
- [ ] Progress persists without internet.
- [ ] No network is required for database operations.

### Unit 03 — Offline Lessons and Progress

Build:

- Local lesson list.
- Lesson detail screen.
- Mark lesson complete.
- Store completion locally.
- Display progress.

Verify:

- [ ] Lessons work in airplane mode.
- [ ] Completion survives app restart.
- [ ] Progress is calculated locally.

### Unit 04 — Offline ONNX Tutor

Build:

- Add the selected lightweight ONNX model.
- Create model service.
- Load model locally.
- Build tutor screen.
- Send text question to local model.
- Display response.

Verify:

- [ ] Tutor works with internet disabled.
- [ ] No cloud API is called.
- [ ] Model errors do not crash the app.

### Unit 05 — Offline Quizzes

Build:

- Local question storage.
- Quiz screen.
- Answer selection/input.
- Scoring.
- Store attempts locally.
- Show score.

Verify:

- [ ] Quiz works offline.
- [ ] Score is saved locally.
- [ ] Previous attempts remain after restart.

### Unit 06 — Voice Interaction

Build:

- Speech-to-text input.
- Microphone button in Tutor.
- Text-to-speech for AI responses.

Verify:

- [ ] Voice input works on a supported Android device.
- [ ] AI response can be read aloud.
- [ ] Core text-based tutor still works if voice is unavailable.

### Unit 07 — FastAPI Backend

Build:

- FastAPI project.
- Environment configuration.
- Basic authentication.
- Health endpoint.
- Sync endpoint skeleton.
- PostgreSQL connection.

Verify:

- [ ] Backend starts locally.
- [ ] Health endpoint responds.
- [ ] Secrets come from environment variables.
- [ ] Authentication does not store plaintext passwords.

### Unit 08 — Synchronization

Build:

- Connectivity detection.
- Local pending-sync queue.
- Upload local progress/attempts.
- Server-side persistence.
- Retry on failure.
- Idempotent synchronization.
- Mark records synced only after success.

Verify:

- [ ] Complete quiz offline.
- [ ] Data appears in local sync queue.
- [ ] Start backend/connectivity.
- [ ] Synchronize successfully.
- [ ] Same record can be retried without duplication.
- [ ] Failed sync leaves local data intact.

### Unit 09 — Final Integration and Security Pass

Build:

- Authentication flow integration.
- Sync status UI.
- Error states.
- Secure local token storage.
- Input validation.
- Remove debug secrets/logging.
- Basic end-to-end testing.

Verify:

- [ ] Full core flow works.
- [ ] Offline learning works.
- [ ] Tutor works offline.
- [ ] Quiz works offline.
- [ ] Voice works.
- [ ] Sync works.
- [ ] Authentication works.
- [ ] No secrets are committed.
- [ ] App remains usable when backend is unavailable.

## Final MVP Definition

The project is done when a student can:

1. Open the Android app.
2. Study a lesson without internet.
3. Ask the local AI tutor a question.
4. Use voice interaction.
5. Complete a quiz.
6. See progress.
7. Close/reopen the app and retain progress.
8. Reconnect to the internet.
9. Synchronize progress to the backend.
10. Retry synchronization safely if it initially fails.
