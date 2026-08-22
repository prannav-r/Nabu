import pytest
from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "timestamp" in data

def test_auth_register_and_login():
    reg_payload = {
        "username": "teststudent",
        "email": "student@example.com",
        "password": "SecurePassword123!",
    }
    reg_res = client.post("/auth/register", json=reg_payload)
    assert reg_res.status_code == 200
    reg_data = reg_res.json()
    assert "access_token" in reg_data
    assert reg_data["user"]["username"] == "teststudent"

    # Login
    login_payload = {
        "username_or_email": "teststudent",
        "password": "SecurePassword123!",
    }
    login_res = client.post("/auth/login", json=login_payload)
    assert login_res.status_code == 200
    login_data = login_res.json()
    assert "access_token" in login_data

def test_sync_push_idempotent():
    sync_payload = {
        "student_id": "student_1",
        "attempts": [
            {
                "client_id": "att_test_1",
                "lesson_id": "lesson_1",
                "score": 5,
                "total_questions": 5,
                "completed_at": "2026-08-22T00:00:00Z",
            }
        ],
        "lesson_progress": [
            {
                "lesson_id": "lesson_1",
                "is_completed": True,
                "updated_at": "2026-08-22T00:00:00Z",
            }
        ],
        "summary": {
            "lessons_completed": 1,
            "total_lessons": 4,
            "quizzes_completed": 1,
            "average_score": 100.0,
            "updated_at": "2026-08-22T00:00:00Z",
        }
    }

    # First sync
    res1 = client.post("/sync", json=sync_payload)
    assert res1.status_code == 200
    assert res1.json()["success"] is True

    # Retry sync with same records (must be idempotent without duplicate errors)
    res2 = client.post("/sync", json=sync_payload)
    assert res2.status_code == 200
    assert res2.json()["success"] is True

    # Check status
    status_res = client.get("/sync/status/student_1")
    assert status_res.status_code == 200
    status_data = status_res.json()
    assert status_data["total_synced_attempts"] == 1
    assert status_data["total_synced_lessons"] == 1
