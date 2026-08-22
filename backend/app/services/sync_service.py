from datetime import datetime, timezone
from ..db.database import db
from ..schemas.sync import SyncPushRequest, SyncPushResponse, SyncStatusResponse

class SyncService:
    @staticmethod
    def process_sync_push(req: SyncPushRequest) -> SyncPushResponse:
        attempts_synced = 0
        lessons_synced = 0

        # Idempotently persist quiz attempts
        for attempt in req.attempts:
            db.save_quiz_attempt(
                student_id=req.student_id,
                client_id=attempt.client_id,
                lesson_id=attempt.lesson_id,
                score=attempt.score,
                total_questions=attempt.total_questions,
                completed_at=attempt.completed_at,
            )
            attempts_synced += 1

        # Idempotently persist lesson completions
        for lp in req.lesson_progress:
            db.save_lesson_progress(
                student_id=req.student_id,
                lesson_id=lp.lesson_id,
                is_completed=lp.is_completed,
                updated_at=lp.updated_at,
            )
            lessons_synced += 1

        # Idempotently update overall student summary
        if req.summary:
            db.save_student_summary(
                student_id=req.student_id,
                lessons_completed=req.summary.lessons_completed,
                total_lessons=req.summary.total_lessons,
                quizzes_completed=req.summary.quizzes_completed,
                average_score=req.summary.average_score,
                updated_at=req.summary.updated_at,
            )

        now = datetime.now(timezone.utc).isoformat()
        return SyncPushResponse(
            success=True,
            synchronized_attempts_count=attempts_synced,
            synchronized_lessons_count=lessons_synced,
            synced_at=now,
            message="Data synchronized successfully.",
        )

    @staticmethod
    def get_sync_status(student_id: str) -> SyncStatusResponse:
        status_info = db.get_sync_status(student_id)
        return SyncStatusResponse(**status_info)
