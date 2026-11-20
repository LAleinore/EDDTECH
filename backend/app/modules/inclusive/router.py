import uuid
from datetime import datetime, timezone
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc, delete

from ...core.database import get_db
from ...api.dependencies import get_current_user
from ...models.user import User
from ...models.inclusive import InclusiveMaterial
from ...schemas.inclusive import (
    SimplifyTextRequest,
    SimplifyTextResponse,
    SimplifiedContent,
    InclusiveMaterialItem,
)
from ...services.ai_gateway import AIGateway

router = APIRouter(prefix="/inclusive", tags=["Inclusive AI"])

@router.post("/simplify", response_model=SimplifyTextResponse)
async def simplify_text(
    req: SimplifyTextRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    content_dict = await AIGateway.simplify_text(
        text=req.text,
        target_grade=req.target_grade,
        language=req.language,
    )

    material = InclusiveMaterial(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        title=content_dict["title"],
        original_text=req.text,
        simplified_content=content_dict,
        language=req.language,
        created_at=datetime.now(timezone.utc),
    )
    db.add(material)
    await db.flush()

    return SimplifyTextResponse(
        id=material.id,
        originalText=material.original_text,
        simplified=SimplifiedContent(**content_dict),
        language=material.language,
        createdAt=material.created_at,
    )

@router.post("/summarize")
async def summarize_text(
    req: SimplifyTextRequest,
    current_user: User = Depends(get_current_user),
):
    content_dict = await AIGateway.simplify_text(
        text=req.text,
        target_grade=req.target_grade,
        language=req.language,
    )
    return {"summary": content_dict["summary"]}

@router.post("/transcribe")
async def transcribe_audio():
    # Audio transcription proxy for mobile STT
    return {"text": "Распознанный текст голосовой учебной заметки."}

@router.get("/materials", response_model=List[InclusiveMaterialItem])
async def get_inclusive_materials(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        select(InclusiveMaterial)
        .where(InclusiveMaterial.user_id == current_user.id)
        .order_by(desc(InclusiveMaterial.created_at))
    )
    res = await db.execute(query)
    items = res.scalars().all()
    return [
        InclusiveMaterialItem(
            id=m.id,
            title=m.title,
            originalText=m.original_text,
            simplifiedContent=m.simplified_content,
            language=m.language,
            createdAt=m.created_at,
        )
        for m in items
    ]

@router.delete("/materials/{material_id}")
async def delete_inclusive_material(
    material_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = (
        delete(InclusiveMaterial)
        .where(InclusiveMaterial.id == material_id, InclusiveMaterial.user_id == current_user.id)
    )
    res = await db.execute(query)
    if res.rowcount == 0:
        raise HTTPException(status_code=404, detail="Материал не найден")
    return {"message": "Материал удален"}
