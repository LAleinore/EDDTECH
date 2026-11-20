from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, EmailStr, Field

class AccessibilitySettingsSchema(BaseModel):
    fontScale: float = 1.0
    highContrast: bool = False
    reduceMotion: bool = False
    voiceEnabled: bool = False
    simplifiedUI: bool = False
    largeButtons: bool = False

class UserRegisterRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6)
    role: str = Field("student", pattern="^(teacher|student|learner|admin)$")
    language: str = Field("ru", pattern="^(ru|kk|en)$")

class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class UserProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    language: Optional[str] = None
    accessibility: Optional[AccessibilitySettingsSchema] = None

class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    role: str
    avatarUrl: str = ""
    language: str = "ru"
    createdAt: datetime
    lastLoginAt: Optional[datetime] = None
    accessibility: AccessibilitySettingsSchema
    isDemo: bool = False

    model_config = {"from_attributes": True}

class AuthTokenResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    user: UserResponse
