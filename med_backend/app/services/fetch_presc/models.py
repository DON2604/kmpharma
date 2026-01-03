from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum

class FolderType(str, Enum):
    MEDICINE_PRESCRIPTIONS = "medicine_prescriptions"
    PRESCRIPTIONS = "prescriptions"

class FileInfo(BaseModel):
    key: str
    url: Optional[str]
    last_modified: Optional[str] = None
    size: int = 0

class PrescriptionListResponse(BaseModel):
    exists: bool
    count: int
    files: List[FileInfo]
    folder_type: str
    phone_number: str

class PrescriptionQuery(BaseModel):
    phone_number: str = Field(..., description="Phone number to search for")
    folder_type: FolderType = Field(FolderType.MEDICINE_PRESCRIPTIONS, description="Folder type to search in")
