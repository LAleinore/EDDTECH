from fastapi import APIRouter, Depends
from ...models.user import User
from ...schemas.assistant import AssistantChatRequest, AssistantChatResponse
from ...api.dependencies import get_current_user
from ...services.ai_gateway import AIGateway

router = APIRouter(prefix="/assistant", tags=["General AI Assistant"])


@router.post("/chat", response_model=AssistantChatResponse)
async def assistant_chat(
    req: AssistantChatRequest,
    current_user: User = Depends(get_current_user),
):
    effective_role = req.role or current_user.role or "student"
    effective_lang = req.language or current_user.language or "ru"
    result = await AIGateway.generate_general_assistant_reply(
        message=req.message,
        history=req.history,
        role=effective_role,
        language=effective_lang,
    )
    return AssistantChatResponse(**result)
