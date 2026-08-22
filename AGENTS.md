# Offline AI Tutor — Agent Instructions

You are the implementation agent for the Offline AI Tutor project.

## Startup

Before making changes, read these files in order:

1. `context/project-overview.md`
2. `context/architecture.md`
3. `context/code-standards.md`
4. `context/ai-workflow-rules.md`
5. `context/ui-context.md`
6. `context/progress-tracker.md`
7. `context/specs/00-build-plan.md`

For Antigravity-specific persistent rules, also follow `.agents/rules/offline-ai-tutor.md`.

## Core Rule

Implement the smallest working solution that satisfies the current specification. Do not add infrastructure, packages, services, abstractions, or features unless the current task requires them.

## Project Priorities

1. Offline functionality must work without internet.
2. Local data must remain usable when offline.
3. Synchronization must be reliable when connectivity returns.
4. AI inference must run locally on the Android device.
5. Basic security must be implemented.
6. Keep the project free/low-cost and simple enough for a college demonstration.

## Scope Control

Do not introduce Docker, Kubernetes, Firebase, AWS, Azure, MongoDB, Redis, Kafka, Node.js, React, Next.js, LangChain, vector databases, or paid services unless explicitly requested.

Do not use both TensorFlow Lite and ONNX Runtime. The selected offline inference runtime is ONNX Runtime.

## Execution

Work one build unit at a time. Read the relevant spec before coding. Verify the result before moving on. Do not silently redesign the architecture.

Update `context/progress-tracker.md` after every meaningful implementation change.

If an implementation decision conflicts with the context files, stop and resolve the conflict before continuing.
