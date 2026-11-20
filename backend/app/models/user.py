import uuid
from datetime import datetime, timezone
from sqlalchemy import String, DateTime, Boolean, Float, JSON
from sqlalchemy.orm import Mapped, mapped_column
from ..core.database import Base

class User(Base):
    __tablename__ = "profiles"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(50), default="student", index=True, nullable=False)
    avatar_url: Mapped[str] = mapped_column(String(500), default="", nullable=False)
    language: Mapped[str] = mapped_column(String(10), default="ru", nullable=False)
    
    # Accessibility settings JSON
    accessibility_settings: Mapped[dict] = mapped_column(
        JSON,
        default=lambda: {
            "fontScale": 1.0,
            "highContrast": False,
            "reduceMotion": False,
            "voiceEnabled": False,
            "simplifiedUI": False,
            "largeButtons": False,
        },
    )
    
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_demo: Mapped[bool] = mapped_column(Boolean, default=False)
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
    last_login_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )
