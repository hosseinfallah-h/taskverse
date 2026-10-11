"""Application configuration loaded from environment variables."""

import json
from functools import lru_cache

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Central settings object. Reads from .env file."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # App
    app_name: str = "TaskVerse"
    app_version: str = "0.0.1"
    env: str = "development"
    debug: bool = True
    host: str = "0.0.0.0"
    port: int = 8000
    timezone: str = "Asia/Tehran"

    # Database
    database_url: str = "postgresql://postgres:postgres@localhost:5432/taskverse"
    database_pool_size: int = 10
    database_max_overflow: int = 20

    # Redis
    redis_url: str = "redis://localhost:6379/0"

    # Security
    secret_key: str = Field(default="CHANGE_ME_TO_A_RANDOM_64_CHAR_STRING", min_length=16)
    algorithm: str = "HS256"
    access_token_expire_days: int = 30
    refresh_token_expire_days: int = 90
    cors_origins: list[str] = ["http://localhost:3000"]

    # SMS (disabled until we own a provider)
    sms_provider: str = ""
    sms_api_base: str = ""
    sms_api_key: str = ""
    sms_pattern_code: str = ""
    sms_line_number: str = ""
    sms_otp_ttl_seconds: int = 120
    sms_otp_max_attempts: int = 5

    # Bale
    bale_bot_token: str = ""
    bale_api_base: str = "https://tapi.bale.ai/bot"
    bale_webhook_secret: str = ""

    # Storage
    storage_root: str = "storage"
    attachments_dir: str = "storage/attachments"
    max_upload_mb: int = 25
    allowed_mime_types: list[str] = [
        "image/jpeg",
        "image/png",
        "image/webp",
        "audio/ogg",
        "audio/mpeg",
        "application/pdf",
        "text/plain",
    ]

    # Rate limiting
    rate_limit_default: str = "60/minute"
    rate_limit_auth: str = "5/minute"

    # Admin
    admin_phone: str = ""

    @field_validator("cors_origins", "allowed_mime_types", mode="before")
    @classmethod
    def parse_list(cls, v):
        """Allow JSON array or comma-separated string."""
        if isinstance(v, str):
            v = v.strip()
            if v.startswith("["):
                return json.loads(v)
            return [s.strip() for s in v.split(",") if s.strip()]
        return v


@lru_cache
def get_settings() -> Settings:
    """Cached settings instance."""
    return Settings()


settings = get_settings()
