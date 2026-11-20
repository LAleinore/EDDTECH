from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from ..core.config import settings
from ..core.database import get_db
from ..models.user import User

security_bearer = HTTPBearer(auto_error=False)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Отсутствует токен авторизации",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = credentials.credentials
    # Demo token handling for jury presentation
    if token.startswith("demo-token-"):
        user_id = token.replace("demo-token-", "")
        # Check if demo user exists in db, otherwise return a synthetic demo user
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if user:
            return user
        
        # Return fallback demo user
        role = "teacher" if "teacher" in user_id else ("learner" if "learner" in user_id else "student")
        return User(
            id=user_id,
            email=f"{role}@edumind.ai",
            name=f"Demo {role.capitalize()}",
            hashed_password="",
            role=role,
            is_demo=True,
        )

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Неверный токен авторизации")
    except JWTError:
        raise HTTPException(status_code=401, detail="Срок действия токена истек или он поврежден")

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return user
