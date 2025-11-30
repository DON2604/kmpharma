from sqlalchemy.orm import Session
from app.services.Reminders.db_worker import create_reminder, get_reminders_by_phone, delete_reminder
from app.services.Reminders.models import ReminderRequest, ReminderResponse
from app.db.models import Verification

async def post_reminder(db: Session, request: ReminderRequest) -> ReminderResponse:
    """Create a new reminder for verified user"""
    # Verify user exists and is verified
    user = db.query(Verification).filter(
        Verification.phn_no == request.phone_number,
        Verification.session_id == request.session_id
    ).first()
    
    if not user:
        raise ValueError("User not found")
    
    if not user.verified:
        raise ValueError("User not verified")
    
    # Create reminder
    reminder = create_reminder(
        db=db,
        phn_no=request.phone_number,
        reminder_text=request.reminder_text,
        reminder_time=request.reminder_time
    )
    
    return ReminderResponse(
        id=reminder.id,
        phn_no=reminder.phn_no,
        reminder_text=reminder.reminder_text,
        reminder_time=reminder.reminder_time,
        created_at=reminder.created_at
    )

async def get_user_reminders(db: Session, phone_number: str, session_id: str) -> list:
    """Get all reminders for a verified user"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    reminders = get_reminders_by_phone(db, phone_number)
    return [
        ReminderResponse(
            id=r.id,
            phn_no=r.phn_no,
            reminder_text=r.reminder_text,
            reminder_time=r.reminder_time,
            created_at=r.created_at
        )
        for r in reminders
    ]

async def cancel_reminder(db: Session, reminder_id: str, phone_number: str, session_id: str) -> bool:
    """Delete a reminder for verified user"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    return delete_reminder(db, reminder_id)
