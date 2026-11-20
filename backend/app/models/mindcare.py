import uuid
from datetime import datetime, timezone
from sqlalchemy import String, DateTime, Text, JSON, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column
from ..core.database import Base

class MoodEntry(Base):
    __tablename__ = "mood_entries"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    score: Mapped[int] = mapped_column(Integer, nullable=False) # 1 (terrible) to 5 (excellent)
    mood_state: Mapped[str] = mapped_column(String(50), nullable=False) # excellent, good, neutral, bad, terrible
    emotions: Mapped[list] = mapped_column(JSON, default=list, nullable=False)
    note: Mapped[str] = mapped_column(Text, default="", nullable=False)
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )

class MindcareChatMessage(Base):
    __tablename__ = "mindcare_chat_messages"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("profiles.id", ondelete="CASCADE"), index=True, nullable=False)
    role: Mapped[str] = mapped_column(String(20), nullable=False) # user, assistant, system
    content: Mapped[str] = mapped_column(Text, nullable=False)
    is_crisis: Mapped[bool] = mapped_column(default=False, nullable=False)
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc),
        nullable=False
    )
