from typing import Any, List, Optional
from pydantic import BaseModel, Field

class SyncQuizAttemptItem(BaseModel):
    client_id: str
    lesson_id: str
    score: int
    total_questions: int
    completed_at: str

class SyncLessonProgressItem(BaseModel):
    lesson_id: str
    is_completed: bool
    updated_at: str

class SyncProgressSummaryItem(BaseModel):
    lessons_completed: int
    total_lessons: int
    quizzes_completed: int
    average_score: float
    updated_at: str

class SyncPushRequest(BaseModel):
    student_id: str
    attempts: List[SyncQuizAttemptItem] = Field(default_factory=list)
    lesson_progress: List[SyncLessonProgressItem] = Field(default_factory=list)
    summary: Optional[SyncProgressSummaryItem] = None

class SyncPushResponse(BaseModel):
    success: bool
    synchronized_attempts_count: int
    synchronized_lessons_count: int
    synced_at: str
    message: str

class SyncStatusResponse(BaseModel):
    student_id: str
    server_time: str
    total_synced_attempts: int
    total_synced_lessons: int
    last_synced_at: Optional[str] = None
