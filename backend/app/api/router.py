from fastapi import APIRouter
from ..modules.auth.router import router as auth_router
from ..modules.teacher.router import router as teacher_router
from ..modules.mindcare.router import router as mindcare_router
from ..modules.inclusive.router import router as inclusive_router

api_router = APIRouter(prefix="/api")
api_router.include_router(auth_router)
api_router.include_router(teacher_router)
api_router.include_router(mindcare_router)
api_router.include_router(inclusive_router)
