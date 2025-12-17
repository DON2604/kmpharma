from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class MedicineBookingRequest(BaseModel):
    phone_number: str
    session_id: str
    medicines: List[str]

class MedicineBookingResponse(BaseModel):
    id: str
    phn_no: str
    phone_number: str
    medicines: List[str]

class DoctorInfo(BaseModel):
    name: str
    specialization: Optional[str] = None
    registration_number: Optional[str] = None

class PrescriptionAnalysisResponse(BaseModel):
    phone_number: str
    doctor: DoctorInfo
    diagnosis: Optional[str] = None
    recommended_medicines: List[str]
    medicines_found: bool
    file_url: str

class MedicineInfoRequest(BaseModel):
    medicine_name: str

class MedicineInfo(BaseModel):
    corrected_name: str
    generic_name: str
    category: str
    uses: list[str]
    dosage: str
    side_effects: list[str]
    precautions: list[str]
    alternative_medicines: list[str]
    prescription_required: bool
    found: bool

class MedicineInfoResponse(BaseModel):
    status: str
    message: str = None
    medicine_info: MedicineInfo = None
