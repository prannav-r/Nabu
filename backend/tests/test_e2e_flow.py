import uuid
import pytest
from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

def test_full_student_e2e_flow():
    # 1. Health check
    health_res = client.get("/health")
    assert health_res.status_code == 200
    assert health_res.json()["status"] == "healthy"

    # 2. Student registers an account for cloud backup
    student_uid = uuid.uuid4().hex[:6]
    username = f"rural_student_{student_uid}"
    email = f"student_{student_uid}@school.edu"
    password = "SecurePassword2026!"

    reg_res = client.post("/auth/register", json={
        "username": username,
        "email": email,
        "password": password,
    })
    assert reg_res.status_code == 200
    reg_data = reg_res.json()
    auth_token = reg_data["access_token"]
    student_id = reg_data["user"]["id"]
    assert auth_token is not None

    # 3. Student goes offline (airplane mode), studies lessons, and completes quiz locally
    # Local attempt generated on SQLite:
    client_attempt_id = f"local_attempt_{uuid.uuid4().hex[:8]}"
    attempt_payload = {
        "client_id": client_attempt_id,
        "lesson_id": "lesson_3_photosynthesis",
        "score": 5,
        "total_questions": 5,
        "completed_at": "2026-08-22T04:15:00Z",
    }
    lesson_progress_payload = {
        "lesson_id": "lesson_3_photosynthesis",
        "is_completed": True,
        "updated_at": "2026-08-22T04:15:00Z",
    }
    summary_payload = {
        "lessons_completed": 3,
        "total_lessons": 4,
        "quizzes_completed": 3,
        "average_score": 93.3,
        "updated_at": "2026-08-22T04:15:00Z",
    }

    # 4. Device regains connectivity -> Trigger Synchronization
    sync_push_req = {
        "student_id": student_id,
        "attempts": [attempt_payload],
        "lesson_progress": [lesson_progress_payload],
        "summary": summary_payload,
    }

    sync_res = client.post("/sync", json=sync_push_req)
    assert sync_res.status_code == 200
    sync_data = sync_res.json()
    assert sync_data["success"] is True
    assert sync_data["synchronized_attempts_count"] == 1
    assert sync_data["synchronized_lessons_count"] == 1

    # 5. Verify server status reflects synced records
    status_res = client.get(f"/sync/status/{student_id}")
    assert status_res.status_code == 200
    status_data = status_res.json()
    assert status_data["total_synced_attempts"] == 1
    assert status_data["total_synced_lessons"] == 1

    # 6. Test idempotent retry (re-sending same batch must succeed without duplicate insertion)
    retry_res = client.post("/sync", json=sync_push_req)
    assert retry_res.status_code == 200
    assert retry_res.json()["success"] is True

    # Total counts on server should still remain 1 (no duplicates)
    status_res_after = client.get(f"/sync/status/{student_id}")
    assert status_res_after.json()["total_synced_attempts"] == 1
    assert status_res_after.json()["total_synced_lessons"] == 1
