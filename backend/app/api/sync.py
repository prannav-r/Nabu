from fastapi import APIRouter
from ..schemas.sync import SyncPushRequest, SyncPushResponse, SyncStatusResponse
from ..services.sync_service import SyncService

router = APIRouter(prefix="/sync", tags=["Synchronization"])

@router.post("", response_model=SyncPushResponse)
def sync_push(req: SyncPushRequest):
    return SyncService.process_sync_push(req)

@router.get("/status/{student_id}", response_model=SyncStatusResponse)
def get_sync_status(student_id: str):
    return SyncService.get_sync_status(student_id)
