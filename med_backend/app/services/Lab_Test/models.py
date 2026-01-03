from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class LabTestReqest(BaseModel):
    phone_number: str
    session_id: str
    tests: List[str]

class LabTestResponse(BaseModel):
    id: str
    phn_no: str
    phone_number: str
    tests: List[str]
    status: str

class DoctorInfo(BaseModel):
    name: str
    specialization: Optional[str] = None
    registration_number: Optional[str] = None

class PrescriptionAnalysisResponse(BaseModel):
    phone_number: str
    doctor: DoctorInfo
    diagnosis: Optional[str] = None
    recommended_tests: List[str]
    tests_found: bool
    file_url: str