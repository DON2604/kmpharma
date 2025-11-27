from pydantic import BaseModel
from typing import List

class EmergencyCallRequest(BaseModel):
    message: str
    contacts: List[str]

class EmergencyCallResponse(BaseModel):
    status: str
    calls: List[str]
