import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc, delete

from ...core.database import get_db
from ...api.dependencies import get_current_user
from ...models.user import User
from ...models.teacher import TeacherMaterial
from ...schemas.teacher import (
    LessonGenerateRequest,
    LessonPlanResponse,
    LessonPlanContent,
    QuizGenerateRequest,
    QuizResponse,
    QuizContent,
    ExplainConceptRequest,
    TeacherMaterialItem,
)
from ...services.ai_gateway import AIGateway

router = APIRouter(prefix="/teacher", tags=["Daryn Ustaz Teacher AI"])

@router.post("/lesson", response_model=LessonPlanResponse)
async def generate_lesson(
    req: LessonGenerateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content_dict = await AIGateway.generate_lesson_plan(
        subject=req.subject,
        grade=req.grade,
        topic=req.topic,
        duration=req.duration_minutes,
        difficulty=req.difficulty,
        language=req.language,
        objectives=req.learning_objectives,
    )

    material = TeacherMaterial(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        title=content_dict["title"],
        material_type="lesson_plan",
        subject=req.subject,
        grade=req.grade,
        topic=req.topic,
        language=req.language,
        content=content_dict,
        created_at=datetime.now(timezone.utc),
    )
    db.add(material)
    await db.flush()

    return LessonPlanResponse(
        id=material.id,
        subject=material.subject,
        grade=material.grade,
        topic=material.topic,
        language=material.language,
        content=LessonPlanContent(**content_dict),
        createdAt=material.created_at,
    )

@router.post("/quiz", response_model=QuizResponse)
async def generate_quiz(
    req: QuizGenerateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content_dict = await AIGateway.generate_quiz(
        subject=req.subject,
        topic=req.topic,
        grade=req.grade,
        count=req.questions_count,
        difficulty=req.difficulty,
        q_type=req.question_type,
        language=req.language,
    )

    material = TeacherMaterial(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        title=content_dict["title"],
        material_type="quiz",
        subject=req.subject,
        grade=req.grade,
        topic=req.topic,
        language=req.language,
        content=content_dict,
        created_at=datetime.now(timezone.utc),
    )
    db.add(material)
    await db.flush()

    return QuizResponse(
        id=material.id,
        subject=material.subject,
        grade=material.grade,
        topic=material.topic,
        language=material.language,
        content=QuizContent(**content_dict),
        createdAt=material.created_at,
    )

@router.post("/explain")
async def explain_concept(
    req: ExplainConceptRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await AIGateway.simplify_text(
        text=f"Тема: {req.topic}. Предмет: {req.subject}. Аудитория: {req.target_audience}",
        target_grade=req.grade,
        language=req.language,
    )
    return result

@router.get("/history", response_model=List[TeacherMaterialItem])
@router.get("/materials", response_model=List[TeacherMaterialItem])
async def get_materials_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(TeacherMaterial)
        .where(TeacherMaterial.user_id == current_user.id)
        .order_by(desc(TeacherMaterial.created_at))
    )
    result = await db.execute(query)
    items = result.scalars().all()
    return [
        TeacherMaterialItem(
            id=m.id,
            title=m.title,
            materialType=m.material_type,
            subject=m.subject,
            grade=m.grade,
            topic=m.topic,
            language=m.language,
            createdAt=m.created_at,
            content=m.content,
        )
        for m in items
    ]

@router.delete("/materials/{material_id}")
async def delete_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        delete(TeacherMaterial)
        .where(TeacherMaterial.id == material_id, TeacherMaterial.user_id == current_user.id)
    )
    res = await db.execute(query)
    if res.rowcount == 0:
        raise HTTPException(status_code=404, detail="Материал не найден или доступ запрещен")
    return {"message": "Материал успешно удален"}
