from typing import List, Optional
from pydantic import BaseModel, Field


class AssistantHistoryItem(BaseModel):
    role: str = Field(..., description="user or assistant")
    content: str


class AssistantChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=4000)
    history: List[AssistantHistoryItem] = Field(default_factory=list)
    role: str = Field(default="student", description="teacher, student, learner, admin")
    language: str = Field(default="ru", description="ru, kk, en")


class AssistantChatResponse(BaseModel):
    reply: str
    isCrisis: bool = False
    emergencyHelpline: Optional[str] = None
    suggestedRoute: Optional[str] = None
