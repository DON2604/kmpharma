from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class DoctorAppointmentRequest(BaseModel):
    phone_number: str
    session_id: str
    symptoms: str
    preferred_specialization: str
    preferred_date: datetime
    preferred_time: str

class DoctorAppointmentResponse(BaseModel):
    id: str
    phn_no: str
    phone_number: str
    symptoms: str
    preferred_specialization: str
    preferred_date: datetime
    preferred_time: str
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True
