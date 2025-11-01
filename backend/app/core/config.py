from functools import lru_cache

from pydantic import Field

try:  # pragma: no cover - fallback for environments without pydantic-settings
    from pydantic_settings import BaseSettings
except ModuleNotFoundError:  # pragma: no cover
    from pydantic import BaseModel

    class BaseSettings(BaseModel):
        model_config = {"extra": "allow"}


class Settings(BaseSettings):
    app_name: str = Field("MOH Medication API", env="APP_NAME")
    debug: bool = Field(False, env="DEBUG")
    database_url: str = Field(
        "postgresql+psycopg2://postgres:postgres@localhost:5432/moh_medication",
        env="DATABASE_URL",
    )
    secret_key: str = Field("super-secret-key", env="SECRET_KEY")
    access_token_expire_minutes: int = Field(60, env="ACCESS_TOKEN_EXPIRE_MINUTES")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()
