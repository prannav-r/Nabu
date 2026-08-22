import uuid
from typing import Optional
from fastapi import HTTPException, status
from ..core.security import hash_password, verify_password, create_access_token
from ..db.database import db
from ..schemas.auth import UserRegisterRequest, UserLoginRequest, TokenResponse, UserResponse

class AuthService:
    @staticmethod
    def register_user(req: UserRegisterRequest) -> TokenResponse:
        existing = db.get_user_by_username_or_email(req.username)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already registered.",
            )
        existing_email = db.get_user_by_username_or_email(req.email)
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered.",
            )

        user_id = f"usr_{uuid.uuid4().hex[:12]}"
        hashed_pw = hash_password(req.password)
        created_user = db.create_user(user_id, req.username, req.email, hashed_pw)

        token = create_access_token(user_id)
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(
                id=created_user["id"],
                username=created_user["username"],
                email=created_user["email"],
                created_at=created_user["created_at"],
            ),
        )

    @staticmethod
    def login_user(req: UserLoginRequest) -> TokenResponse:
        user = db.get_user_by_username_or_email(req.username_or_email)
        if not user or not verify_password(req.password, user["hashed_password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid username or password.",
            )

        token = create_access_token(user["id"])
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user=UserResponse(
                id=user["id"],
                username=user["username"],
                email=user["email"],
                created_at=user["created_at"],
            ),
        )
