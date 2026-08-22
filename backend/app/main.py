from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api.auth import router as auth_router
from .api.health import router as health_router
from .api.sync import router as sync_router
from .core.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    description="Synchronization and Authentication API for Offline AI Tutor",
    version="1.0.0",
)

# CORS middleware to allow Flutter app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(health_router)
app.include_router(auth_router)
app.include_router(sync_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app.main:app", host=settings.HOST, port=settings.PORT, reload=settings.DEBUG)
