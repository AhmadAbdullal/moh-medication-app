from fastapi import APIRouter, Depends

from app.api import deps
from app.models.user import User
from app.schemas.user import User as UserSchema

router = APIRouter(tags=["users"])


@router.get("/me", response_model=UserSchema)
def read_current_user(current_user: User = Depends(deps.get_current_active_user)) -> User:
    return current_user
