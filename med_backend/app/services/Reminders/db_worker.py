from sqlalchemy.orm import Session
from app.db.models import Reminder
from datetime import datetime
import uuid

def create_reminder(db: Session, phn_no: str, reminder_text: str, reminder_time: datetime) -> Reminder:
    """Create a new reminder record"""
    reminder = Reminder(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        reminder_text=reminder_text,
        reminder_time=reminder_time
    )
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
    return reminder

def get_reminder(db: Session, reminder_id: str) -> Reminder:
    """Retrieve reminder by id"""
    return db.query(Reminder).filter(Reminder.id == reminder_id).first()

def get_reminders_by_phone(db: Session, phn_no: str) -> list:
    """Retrieve all reminders by phone number"""
    return db.query(Reminder).filter(Reminder.phn_no == phn_no).all()

def delete_reminder(db: Session, reminder_id: str) -> bool:
    """Delete a reminder record"""
    reminder = db.query(Reminder).filter(Reminder.id == reminder_id).first()
    if reminder:
        db.delete(reminder)
        db.commit()
        return True
    return False
