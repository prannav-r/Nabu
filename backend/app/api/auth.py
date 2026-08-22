from fastapi import APIRouter
from ..schemas.auth import UserRegisterRequest, UserLoginRequest, TokenResponse
from ..services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=TokenResponse)
def register(req: UserRegisterRequest):
    return AuthService.register_user(req)

@router.post("/login", response_model=TokenResponse)
def login(req: UserLoginRequest):
    return AuthService.login_user(req)
