from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AmbBookingRequest(BaseModel):
    phone_number: str
    session_id: str
    curr_loc: str
    destination: str

class AmbBookingResponse(BaseModel):
    id: str
    phn_no: str
    current_location: str
    destination: str
    created_at: datetime
    
    class Config:
        from_attributes = True