# AI Workflow Rules

## Overall Approach

Use spec-driven, incremental development.

The agent is the implementation engine. The project context defines the architecture and constraints.

## Rules

1. Read the relevant context files before implementing.
2. Work on one build unit at a time.
3. Do not implement future units during the current unit.
4. Do not install dependencies before the unit that needs them.
5. Prefer existing platform capabilities over new libraries.
6. Never invent requirements that are not documented.
7. If a requirement is ambiguous and the decision affects architecture, stop and ask.
8. If ambiguity does not affect architecture, choose the simplest reasonable implementation and document the decision.
9. Do not silently replace approved technologies.
10. Do not introduce production infrastructure into this MVP.
11. Do not rewrite working code merely to make it more sophisticated.
12. Preserve working offline behavior whenever modifying sync, networking, or database code.
13. Never remove local data merely because cloud synchronization failed.
14. Verify each unit before moving to the next one.
15. Update `context/progress-tracker.md` after meaningful implementation changes.
16. If architecture changes, update `context/architecture.md`.
17. If scope changes, update `context/project-overview.md`.
18. Keep documentation truthful to the actual implementation.

## Dependency Discipline

Install a package only when:

- The current feature requires it.
- The package solves a real requirement.
- The package is compatible with the chosen stack.

Do not add:

- Docker
- Kubernetes
- Firebase
- MongoDB
- Redis
- Kafka
- Node.js
- React
- Next.js
- LangChain
- vector databases
- paid APIs
- duplicate AI runtimes

unless the user explicitly changes the project requirements.

## Before Coding

For every unit:

1. Read its spec.
2. Inspect the existing code.
3. Identify files that must change.
4. Check whether required dependencies already exist.
5. Implement only the requested behavior.

## Verification

Before marking a unit complete:

- Run the relevant formatter/analyzer/tests.
- Run the application if applicable.
- Verify the user-visible behavior.
- Verify offline behavior for features that claim to work offline.
- Verify no secrets were introduced.
- Check that unrelated features still work.
- Update the progress tracker.

## When Something Fails

Do not respond to an error by installing unrelated packages or changing architecture.

First:

1. Read the error.
2. Identify the exact failing component.
3. Check the current implementation.
4. Apply the smallest fix.
5. Re-run the relevant verification.

## Completion

A unit is complete only when its verification checklist passes.

Do not mark work complete because the code was generated. Mark it complete because the behavior was verified.
