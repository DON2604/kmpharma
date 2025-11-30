from pydantic import BaseModel
from datetime import datetime

class ReminderRequest(BaseModel):
    phone_number: str
    session_id: str
    reminder_text: str
    reminder_time: datetime

class ReminderResponse(BaseModel):
    id: str
    phn_no: str
    reminder_text: str
    reminder_time: datetime
    created_at: datetime
    
    class Config:
        from_attributes = True
