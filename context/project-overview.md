# Project Overview

## Overview

Offline AI Tutor is a simple Android application designed for students in schools with unreliable internet connectivity. Students can study lessons, ask an AI tutor questions, take quizzes, use voice interaction, and track their progress without an internet connection. When connectivity becomes available, locally stored progress is synchronized with a remote backend.

The project is intentionally an MVP. It prioritizes functional offline learning and synchronization over production-scale infrastructure.

## Goals

1. Provide a usable Android learning application that works without internet.
2. Run a lightweight AI model locally on the device.
3. Store lessons, quiz activity, and student progress locally.
4. Generate or provide quizzes while offline.
5. Support basic voice input and voice output.
6. Synchronize local progress with a remote database when connectivity returns.
7. Implement basic security without introducing unnecessary complexity.
8. Keep development and operation free or close to free.

## Core User Flow

1. Student opens the application.
2. Student signs in or selects their local student profile.
3. Student sees available lessons and current progress.
4. Student opens a lesson stored locally.
5. Student asks the AI tutor a question using text or voice.
6. The local AI model generates an answer without requiring internet.
7. Student starts a quiz based on available lesson content.
8. Student submits answers.
9. Score and progress are saved immediately in SQLite.
10. The app marks unsynchronized records as pending.
11. Internet connectivity becomes available.
12. The synchronization process sends pending records to the backend.
13. The backend stores synchronized progress in PostgreSQL.
14. The app marks successfully synchronized records as synced.

## Features

### Offline Learning

- Browse locally stored lessons.
- Read lesson content without internet.
- View previously downloaded learning material.

### Offline AI Tutor

- Ask questions using text.
- Run a lightweight ONNX model locally.
- Return an answer without calling a cloud AI API.

### Quizzes

- Take quizzes offline.
- Generate simple quizzes locally where supported by the selected model/content approach.
- Store attempts and scores locally.

### Progress

- Track completed lessons.
- Track quiz scores.
- Track learning progress locally.
- Synchronize progress later.

### Voice

- Speech-to-text for asking questions.
- Text-to-speech for reading AI responses.

### Synchronization

- Detect connectivity.
- Upload pending local changes.
- Download relevant remote updates.
- Mark successful records as synchronized.
- Avoid duplicating already synchronized records.

## In Scope

- Android application.
- Flutter UI.
- SQLite local database.
- Offline ONNX inference.
- Local lessons.
- Offline quizzes.
- Local progress tracking.
- Voice input/output.
- FastAPI synchronization API.
- PostgreSQL cloud synchronization.
- Basic authentication/security.
- Manual or automatic synchronization when connectivity is available.

## Out of Scope

- Production-scale deployment.
- Multi-region infrastructure.
- Kubernetes or containers.
- Complex teacher/admin dashboards.
- Real-time multiplayer learning.
- Advanced analytics.
- Paid AI APIs.
- Large cloud-hosted LLM inference.
- Recommendation engines.
- Vector databases/RAG infrastructure.
- Enterprise identity management.
- Payment systems.
- Push notification infrastructure.
- Complex conflict-resolution systems.
- Perfect natural-language tutoring.
- Training a language model from scratch.

## Success Criteria

The MVP is complete when:

- [ ] The Android app launches successfully.
- [ ] Lessons can be viewed with internet disabled.
- [ ] Student progress is saved locally.
- [ ] A local ONNX model can process a supported tutor interaction.
- [ ] A student can complete a quiz offline.
- [ ] Quiz scores are stored locally.
- [ ] Voice input works on a supported Android device.
- [ ] Voice output works on a supported Android device.
- [ ] Pending local progress can be synchronized to the backend.
- [ ] Synchronized records appear in the remote PostgreSQL database.
- [ ] Re-running synchronization does not create duplicate records.
- [ ] Basic authentication and credential handling are secure.
