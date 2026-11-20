from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field

class SimplifyTextRequest(BaseModel):
    text: str = Field(..., min_length=5)
    target_grade: str = "elementary" # elementary, middle, plain_language
    language: str = "ru"

class KeyConcept(BaseModel):
    term: str
    definition: str

class SimplifiedContent(BaseModel):
    title: str
    simpleExplanation: str
    summary: str
    stepByStepGuide: List[str]
    keyConcepts: List[KeyConcept]
    practicalExamples: List[str]

class SimplifyTextResponse(BaseModel):
    id: Optional[str] = None
    originalText: str
    simplified: SimplifiedContent
    language: str
    createdAt: Optional[datetime] = None

class InclusiveMaterialItem(BaseModel):
    id: str
    title: str
    originalText: str
    simplifiedContent: dict
    language: str
    createdAt: datetime

    model_config = {"from_attributes": True}
