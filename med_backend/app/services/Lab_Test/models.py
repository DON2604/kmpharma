from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class LabTestReqest(BaseModel):
    phone_number: str
    session_id: str
    time: datetime
    tests: List[str]

class LabTestResponse(BaseModel):
    id: str
    phn_no: str
    phone_number: str
    time: datetime
    tests: List[str]