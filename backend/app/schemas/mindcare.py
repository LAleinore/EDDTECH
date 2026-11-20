from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

# MindCare Chat
class ChatMessageItem(BaseModel):
    role: str # user, assistant, system
    content: str
    timestamp: Optional[datetime] = None

class MindcareChatRequest(BaseModel):
    message: str = Field(..., min_length=1)
    history: List[ChatMessageItem] = []
    language: str = "ru"

class MindcareChatResponse(BaseModel):
    reply: str
    isCrisis: bool = False
    emergencyHelpline: Optional[str] = None
    suggestedTechnique: Optional[str] = None

# Mood Tracker
class MoodEntryCreate(BaseModel):
    score: int = Field(..., ge=1, le=5) # 1: terrible, 2: bad, 3: neutral, 4: good, 5: excellent
    moodState: str = Field(..., pattern="^(terrible|bad|neutral|good|excellent)$")
    emotions: List[str] = []
    note: Optional[str] = ""

class MoodEntryResponse(BaseModel):
    id: str
    score: int
    moodState: str
    emotions: List[str]
    note: str
    createdAt: datetime

    model_config = {"from_attributes": True}

class MoodStatisticsResponse(BaseModel):
    averageScore: float
    totalEntries: int
    dominantMood: str
    topEmotions: List[str]
    recentScores: List[int]
    weeklySummary: str

# Exercises
class ExerciseItem(BaseModel):
    id: str
    title: str
    description: str
    durationMinutes: int
    type: str # breathing, relaxation, mindfulness
    steps: List[str]
