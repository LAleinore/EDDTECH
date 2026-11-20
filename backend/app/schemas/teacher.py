from datetime import datetime
from typing import List, Optional, Any
from pydantic import BaseModel, Field

# Lesson Plan Schemas
class LessonGenerateRequest(BaseModel):
    subject: str = Field(..., min_length=2)
    grade: str = Field(..., min_length=1)
    topic: str = Field(..., min_length=2)
    duration_minutes: int = Field(45, ge=15, le=180)
    difficulty: str = Field("medium", pattern="^(easy|medium|hard)$")
    language: str = Field("ru", pattern="^(ru|kk|en)$")
    learning_objectives: Optional[str] = None

class LessonPlanContent(BaseModel):
    title: str
    objectives: List[str]
    overview: str
    introduction: str
    main_body: List[str]
    practical_tasks: List[str]
    conclusion: str
    homework: str

class LessonPlanResponse(BaseModel):
    id: Optional[str] = None
    subject: str
    grade: str
    topic: str
    language: str
    content: LessonPlanContent
    createdAt: Optional[datetime] = None

# Quiz Schemas
class QuizQuestionOption(BaseModel):
    id: str
    text: str

class QuizQuestion(BaseModel):
    id: str
    text: str
    type: str # single_choice, multiple_choice, open_question
    options: List[QuizQuestionOption] = []
    correct_option_ids: List[str] = []
    sample_answer: Optional[str] = None
    explanation: str

class QuizGenerateRequest(BaseModel):
    subject: str
    topic: str
    grade: str
    questions_count: int = Field(5, ge=1, le=20)
    difficulty: str = "medium"
    question_type: str = "single_choice" # single_choice, multiple_choice, open_question, mixed
    language: str = "ru"

class QuizContent(BaseModel):
    title: str
    questions: List[QuizQuestion]

class QuizResponse(BaseModel):
    id: Optional[str] = None
    subject: str
    grade: str
    topic: str
    language: str
    content: QuizContent
    createdAt: Optional[datetime] = None

# Concept Explanation Schemas
class ExplainConceptRequest(BaseModel):
    subject: str
    topic: str
    grade: str
    target_audience: str = "school" # school, beginner, advanced
    language: str = "ru"

class ConceptExplanationContent(BaseModel):
    title: str
    simple_summary: str
    in_depth_breakdown: List[str]
    real_world_examples: List[str]
    interactive_questions: List[str]

class TeacherMaterialItem(BaseModel):
    id: str
    title: str
    materialType: str
    subject: str
    grade: str
    topic: str
    language: str
    createdAt: datetime
    content: dict

    model_config = {"from_attributes": True}
