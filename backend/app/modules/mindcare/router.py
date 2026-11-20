import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc, delete

from ...core.database import get_db
from ...api.dependencies import get_current_user
from ...models.user import User
from ...models.mindcare import MoodEntry, MindcareChatMessage
from ...schemas.mindcare import (
    MindcareChatRequest,
    MindcareChatResponse,
    MoodEntryCreate,
    MoodEntryResponse,
    MoodStatisticsResponse,
    ExerciseItem,
)
from ...services.ai_gateway import AIGateway

router = APIRouter(prefix="/mindcare", tags=["MindCare Support"])

@router.post("/chat", response_model=MindcareChatResponse)
async def chat(
    req: MindcareChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await AIGateway.generate_supportive_chat_reply(
        message=req.message,
        history=req.history,
        language=req.language,
    )

    # Save user message
    user_msg = MindcareChatMessage(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        role="user",
        content=req.message,
        is_crisis=result.get("isCrisis", False),
        created_at=datetime.now(timezone.utc),
    )
    db.add(user_msg)

    # Save assistant message
    bot_msg = MindcareChatMessage(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        role="assistant",
        content=result["reply"],
        is_crisis=result.get("isCrisis", False),
        created_at=datetime.now(timezone.utc),
    )
    db.add(bot_msg)
    await db.flush()

    return MindcareChatResponse(
        reply=result["reply"],
        isCrisis=result.get("isCrisis", False),
        emergencyHelpline=result.get("emergencyHelpline"),
        suggestedTechnique=result.get("suggestedTechnique"),
    )

@router.post("/mood", response_model=MoodEntryResponse)
async def create_mood_entry(
    req: MoodEntryCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    entry = MoodEntry(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        score=req.score,
        mood_state=req.moodState,
        emotions=req.emotions,
        note=req.note or "",
        created_at=datetime.now(timezone.utc),
    )
    db.add(entry)
    await db.flush()

    return MoodEntryResponse(
        id=entry.id,
        score=entry.score,
        moodState=entry.mood_state,
        emotions=entry.emotions,
        note=entry.note,
        createdAt=entry.created_at,
    )

@router.get("/mood", response_model=List[MoodEntryResponse])
async def get_mood_entries(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(MoodEntry)
        .where(MoodEntry.user_id == current_user.id)
        .order_by(desc(MoodEntry.created_at))
    )
    res = await db.execute(query)
    entries = res.scalars().all()
    return [
        MoodEntryResponse(
            id=e.id,
            score=e.score,
            moodState=e.mood_state,
            emotions=e.emotions,
            note=e.note,
            createdAt=e.created_at,
        )
        for e in entries
    ]

@router.get("/mood/statistics", response_model=MoodStatisticsResponse)
async def get_mood_statistics(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(MoodEntry)
        .where(MoodEntry.user_id == current_user.id)
        .order_by(desc(MoodEntry.created_at))
        .limit(30)
    )
    res = await db.execute(query)
    entries = res.scalars().all()

    if not entries:
        return MoodStatisticsResponse(
            averageScore=4.0,
            totalEntries=0,
            dominantMood="good",
            topEmotions=["Спокойствие", "Вдохновение"],
            recentScores=[4, 4, 5, 4, 4],
            weeklySummary="Данные пока не накоплены. Начните отмечать настроение каждый день!",
        )

    scores = [e.score for e in entries]
    avg_score = round(sum(scores) / len(scores), 2)
    dominant_mood = entries[0].mood_state
    
    all_emotions = []
    for e in entries:
        all_emotions.extend(e.emotions)

    return MoodStatisticsResponse(
        averageScore=avg_score,
        totalEntries=len(entries),
        dominantMood=dominant_mood,
        topEmotions=list(set(all_emotions))[:4] or ["Радость", "Уверенность"],
        recentScores=scores[:7],
        weeklySummary=f"Ваше среднее эмоциональное состояние: {avg_score} из 5. Состояние стабильное.",
    )

@router.get("/exercises", response_model=List[ExerciseItem])
async def get_exercises():
    return [
        ExerciseItem(
            id="breathing-478",
            title="Дыхательная техника 4-7-8",
            description="Классическая методика снижения уровня тревожности и стабилизации сердечного ритма.",
            durationMinutes=3,
            type="breathing",
            steps=[
                "Примите удобное положение сидя с прямой спиной",
                "Сделайте полный спокойный выдох через рот",
                "Вдохните носом, считая про себя до 4",
                "Задержите дыхание на 7 секунд",
                "Плавно выдохните через рот на 8 счетов",
                "Повторите цикл 4 раза"
            ]
        ),
        ExerciseItem(
            id="grounding-54321",
            title="Техника заземления '5-4-3-2-1'",
            description="Быстрое возвращение концентрации и снятие эмоционального перенапряжения.",
            durationMinutes=5,
            type="relaxation",
            steps=[
                "Найдите глазами 5 предметов разного цвета вокруг вас",
                "Почувствуйте 4 тактильных ощущения (одежда, пол под ногами)",
                "Услышьте 3 разных фоновых звука",
                "Уловите 2 аромата или запаха",
                "Ощутите 1 вкус во рту (например, глоток прохладной воды)"
            ]
        )
    ]

@router.delete("/data")
async def delete_all_mindcare_data(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(delete(MoodEntry).where(MoodEntry.user_id == current_user.id))
    await db.execute(delete(MindcareChatMessage).where(MindcareChatMessage.user_id == current_user.id))
    return {"message": "Все психологические записи и история настроения успешно удалены"}
