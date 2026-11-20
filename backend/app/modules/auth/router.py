from datetime import datetime, timezone
import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from ...core.database import get_db
from ...core.security import hash_password, verify_password, create_access_token
from ...models.user import User
from ...schemas.user import (
    UserRegisterRequest,
    UserLoginRequest,
    ForgotPasswordRequest,
    UserProfileUpdateRequest,
    UserResponse,
    AuthTokenResponse,
    AccessibilitySettingsSchema,
)
from ...api.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

def _to_user_response(user: User) -> UserResponse:
    acc = user.accessibility_settings or {}
    return UserResponse(
        id=user.id,
        name=user.name,
        email=user.email,
        role=user.role,
        avatarUrl=user.avatar_url or "",
        language=user.language or "ru",
        createdAt=user.created_at,
        lastLoginAt=user.last_login_at,
        accessibility=AccessibilitySettingsSchema(
            fontScale=acc.get("fontScale", 1.0),
            highContrast=acc.get("highContrast", False),
            reduceMotion=acc.get("reduceMotion", False),
            voiceEnabled=acc.get("voiceEnabled", False),
            simplifiedUI=acc.get("simplifiedUI", False),
            largeButtons=acc.get("largeButtons", False),
        ),
        isDemo=user.is_demo,
    )

@router.post("/register", response_model=AuthTokenResponse, status_code=status.HTTP_201_CREATED)
async def register(req: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email.lower()))
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Пользователь с таким email уже зарегистрирован",
        )

    user = User(
        id=str(uuid.uuid4()),
        name=req.name,
        email=req.email.lower(),
        hashed_password=hash_password(req.password),
        role=req.role,
        language=req.language,
        created_at=datetime.now(timezone.utc),
        last_login_at=datetime.now(timezone.utc),
        is_demo=False,
    )
    db.add(user)
    await db.flush()

    token = create_access_token(user.id)
    return AuthTokenResponse(token=token, user=_to_user_response(user))

@router.post("/login", response_model=AuthTokenResponse)
async def login(req: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == req.email.lower()))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Неверный email или пароль",
        )

    user.last_login_at = datetime.now(timezone.utc)
    await db.flush()

    token = create_access_token(user.id)
    return AuthTokenResponse(token=token, user=_to_user_response(user))

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return _to_user_response(current_user)

@router.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    return {"message": "Успешный выход из системы"}

@router.post("/forgot-password")
async def forgot_password(req: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    # Simulates sending password recovery link
    return {"message": f"Ссылка для сброса пароля отправлена на {req.email}"}

@router.put("/profile", response_model=UserResponse)
async def update_profile(
    req: UserProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if req.name is not None:
        current_user.name = req.name
    if req.language is not None:
        current_user.language = req.language
    if req.accessibility is not None:
        current_user.accessibility_settings = req.accessibility.model_dump()
    
    await db.flush()
    return _to_user_response(current_user)
