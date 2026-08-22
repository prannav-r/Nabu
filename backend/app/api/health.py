from datetime import datetime, timezone
from fastapi import APIRouter
from ..core.config import settings

router = APIRouter(prefix="", tags=["Health"])

@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "environment": settings.ENVIRONMENT,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
