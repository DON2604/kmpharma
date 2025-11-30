from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
from app.services.Reminders.models import ReminderRequest, ReminderResponse
from app.services.Reminders.service import post_reminder, get_user_reminders, cancel_reminder
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/reminder", tags=["Reminder"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/create", response_model=ReminderResponse)
async def create_reminder_endpoint(request: ReminderRequest, db: Session = Depends(get_db)):
    try:
        return await post_reminder(db, request)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{phone_number}/{session_id}", response_model=List[ReminderResponse])
async def get_reminders(phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        return await get_user_reminders(db, phone_number, session_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/cancel/{reminder_id}/{phone_number}/{session_id}")
async def delete_reminder_endpoint(reminder_id: str, phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        success = await cancel_reminder(db, reminder_id, phone_number, session_id)
        if not success:
            raise HTTPException(status_code=404, detail="Reminder not found")
        return {"message": "Reminder cancelled successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


