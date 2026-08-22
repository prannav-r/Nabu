import os
import sqlite3
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from ..core.config import settings

class Database:
    def __init__(self, db_path: str = "backend_sync.db"):
        self.db_path = db_path
        self._init_db()

    def _get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _init_db(self):
        with self._get_connection() as conn:
            cursor = conn.cursor()
            # Users table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS users (
                    id TEXT PRIMARY KEY,
                    username TEXT UNIQUE NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    hashed_password TEXT NOT NULL,
                    created_at TEXT NOT NULL
                )
            ''')
            # Synced quiz attempts table (idempotent unique constraint on client_id + student_id)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS remote_quiz_attempts (
                    id TEXT PRIMARY KEY,
                    student_id TEXT NOT NULL,
                    client_id TEXT NOT NULL,
                    lesson_id TEXT NOT NULL,
                    score INTEGER NOT NULL,
                    total_questions INTEGER NOT NULL,
                    completed_at TEXT NOT NULL,
                    synced_at TEXT NOT NULL,
                    UNIQUE(student_id, client_id)
                )
            ''')
            # Synced lesson progress table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS remote_lesson_progress (
                    student_id TEXT NOT NULL,
                    lesson_id TEXT NOT NULL,
                    is_completed INTEGER NOT NULL,
                    updated_at TEXT NOT NULL,
                    synced_at TEXT NOT NULL,
                    PRIMARY KEY (student_id, lesson_id)
                )
            ''')
            # Synced summary progress table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS remote_student_summaries (
                    student_id TEXT PRIMARY KEY,
                    lessons_completed INTEGER NOT NULL,
                    total_lessons INTEGER NOT NULL,
                    quizzes_completed INTEGER NOT NULL,
                    average_score REAL NOT NULL,
                    updated_at TEXT NOT NULL,
                    synced_at TEXT NOT NULL
                )
            ''')
            conn.commit()

    # User operations
    def create_user(self, user_id: str, username: str, email: str, hashed_pw: str) -> Dict[str, Any]:
        now = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO users (id, username, email, hashed_password, created_at) VALUES (?, ?, ?, ?, ?)",
                (user_id, username, email, hashed_pw, now),
            )
            conn.commit()
            return {"id": user_id, "username": username, "email": email, "created_at": now}

    def get_user_by_username_or_email(self, identifier: str) -> Optional[Dict[str, Any]]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "SELECT * FROM users WHERE username = ? OR email = ?",
                (identifier, identifier),
            )
            row = cursor.fetchone()
            if row:
                return dict(row)
            return None

    def get_user_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
            row = cursor.fetchone()
            if row:
                return dict(row)
            return None

    # Sync operations (idempotent upsert / insert ignore)
    def save_quiz_attempt(self, student_id: str, client_id: str, lesson_id: str, score: int, total_questions: int, completed_at: str) -> bool:
        now = datetime.now(timezone.utc).isoformat()
        server_id = f"srv_{student_id}_{client_id}"
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                '''
                INSERT INTO remote_quiz_attempts (id, student_id, client_id, lesson_id, score, total_questions, completed_at, synced_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(student_id, client_id) DO UPDATE SET
                    score=excluded.score,
                    total_questions=excluded.total_questions,
                    synced_at=excluded.synced_at
                ''',
                (server_id, student_id, client_id, lesson_id, score, total_questions, completed_at, now),
            )
            conn.commit()
            return True

    def save_lesson_progress(self, student_id: str, lesson_id: str, is_completed: bool, updated_at: str) -> bool:
        now = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                '''
                INSERT INTO remote_lesson_progress (student_id, lesson_id, is_completed, updated_at, synced_at)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(student_id, lesson_id) DO UPDATE SET
                    is_completed=excluded.is_completed,
                    updated_at=excluded.updated_at,
                    synced_at=excluded.synced_at
                ''',
                (student_id, lesson_id, 1 if is_completed else 0, updated_at, now),
            )
            conn.commit()
            return True

    def save_student_summary(self, student_id: str, lessons_completed: int, total_lessons: int, quizzes_completed: int, average_score: float, updated_at: str) -> bool:
        now = datetime.now(timezone.utc).isoformat()
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                '''
                INSERT INTO remote_student_summaries (student_id, lessons_completed, total_lessons, quizzes_completed, average_score, updated_at, synced_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(student_id) DO UPDATE SET
                    lessons_completed=excluded.lessons_completed,
                    total_lessons=excluded.total_lessons,
                    quizzes_completed=excluded.quizzes_completed,
                    average_score=excluded.average_score,
                    updated_at=excluded.updated_at,
                    synced_at=excluded.synced_at
                ''',
                (student_id, lessons_completed, total_lessons, quizzes_completed, average_score, updated_at, now),
            )
            conn.commit()
            return True

    def get_sync_status(self, student_id: str) -> Dict[str, Any]:
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT COUNT(*) as c, MAX(synced_at) as max_sync FROM remote_quiz_attempts WHERE student_id = ?", (student_id,))
            row1 = cursor.fetchone()
            total_attempts = row1["c"] if row1 else 0
            last_sync_1 = row1["max_sync"] if row1 else None

            cursor.execute("SELECT COUNT(*) as c, MAX(synced_at) as max_sync FROM remote_lesson_progress WHERE student_id = ?", (student_id,))
            row2 = cursor.fetchone()
            total_lessons = row2["c"] if row2 else 0
            last_sync_2 = row2["max_sync"] if row2 else None

            last_synced = max(filter(None, [last_sync_1, last_sync_2]), default=None)

            return {
                "student_id": student_id,
                "server_time": datetime.now(timezone.utc).isoformat(),
                "total_synced_attempts": total_attempts,
                "total_synced_lessons": total_lessons,
                "last_synced_at": last_synced,
            }

db = Database()
