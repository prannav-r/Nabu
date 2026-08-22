# UI Context

## Product Feel

The app is an educational tool for students. The interface should feel:

- simple
- friendly
- readable
- calm
- lightweight
- usable on small Android screens

Avoid a flashy AI-dashboard aesthetic.

## Design Principles

1. Prioritize readability over decoration.
2. Keep navigation obvious.
3. Use large touch targets.
4. Minimize the number of actions needed to study.
5. Make offline status visible but not distracting.
6. Clearly distinguish local/synced state when useful.
7. Use accessible contrast.
8. Avoid excessive animation.
9. Do not require internet-dependent UI elements for core learning.

## Layout

Primary navigation:

- Home
- Lessons
- Tutor
- Quiz
- Progress

Settings can be accessed from the home screen.

## Core Screens

### Home

Show:

- greeting/student name
- current progress
- continue lesson
- start quiz
- ask tutor
- offline/sync status

### Lessons

Show:

- lesson list
- completion state
- lesson title
- short description

### Tutor

Show:

- conversation area
- text input
- microphone button
- send button
- AI response
- speaker/read-aloud action
- clear offline indication

### Quiz

Show:

- question
- answer choices/input
- progress through quiz
- submit
- final score

### Progress

Show:

- lessons completed
- quiz scores
- simple progress indicators
- last synchronization state

## Colors

Use a simple semantic palette. Do not hard-code colors throughout widgets.

Suggested starting tokens:

| Token | Value |
|---|---|
| primary | `#2563EB` |
| primaryDark | `#1D4ED8` |
| background | `#F8FAFC` |
| surface | `#FFFFFF` |
| textPrimary | `#0F172A` |
| textSecondary | `#475569` |
| success | `#16A34A` |
| warning | `#D97706` |
| error | `#DC2626` |
| border | `#E2E8F0` |

These are starting values, not reasons to introduce a design system package.

## Typography

Use the platform/default readable sans-serif font. Prefer clear hierarchy:

- Screen title
- Section title
- Body
- Supporting text
- Button labels

Avoid tiny text.

## Components

Prefer Flutter's standard Material components unless a custom component is genuinely required.

Do not add a UI component library solely for styling convenience.

## Icons

Use standard Material icons where possible.

## Responsive Behavior

The initial target is Android phones. Support common phone sizes without building a separate tablet design system.

## Offline Indicator

Use a small, clear status indicator such as:

- Offline — Working locally
- Online — Synced
- Syncing...
- Sync failed — Will retry

The indicator must never prevent the student from studying.
