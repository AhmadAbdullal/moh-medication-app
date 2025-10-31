from fastapi import APIRouter

from app.api.routes import admin, auth, drugs, schedules, users

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(drugs.router)
api_router.include_router(schedules.router)
api_router.include_router(admin.router)
