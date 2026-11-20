import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "EduMind AI"
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = True
    SECRET_KEY: str = os.getenv("SECRET_KEY", "edumind-super-secure-production-secret-key-32-chars!")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 # 24 hours
    
    # DB URL: uses SQLite local fallback if PostgreSQL is not active
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite+aiosqlite:///./edumind.db"
    )
    
    # AI Gateway
    AI_PROVIDER: str = os.getenv("AI_PROVIDER", "gemini")
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    AI_REQUEST_TIMEOUT_SECONDS: int = 30
    
    # CORS
    ALLOWED_ORIGINS: list[str] = ["*"]

    model_config = SettingsConfigDict(case_sensitive=True)

settings = Settings()
