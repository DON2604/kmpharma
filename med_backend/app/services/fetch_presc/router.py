from fastapi import APIRouter, HTTPException, Query, Path
from typing import Optional
from .models import (
    FolderType,
    PrescriptionListResponse
)
from .service import prescription_service

router = APIRouter(
    prefix="/prescriptions",
    tags=["prescriptions"]
)

@router.get(
    "/{folder_type}/{phone_number}",
    response_model=PrescriptionListResponse,
    summary="Get all prescriptions with URLs"
)
async def get_prescriptions(
    folder_type: FolderType = Path(..., description="Folder type: 'medicine_prescriptions' or 'prescriptions'"),
    phone_number: str = Path(..., description="Phone number to search for (e.g., +919836014691)"),
    expiration: int = Query(604800, description="Presigned URL expiration in seconds (default: 7 days)", ge=60)
):
    """
    Get all prescription files with presigned URLs for the given phone number.
    Returns exists=false with empty files list if no prescriptions found.
    
    - **folder_type**: Either 'medicine_prescriptions' or 'prescriptions'
    - **phone_number**: Phone number with country code (e.g., +919836014691)
    - **expiration**: URL expiration time in seconds (default: 604800 = 7 days, min: 60)
    
    Example: GET /prescriptions/medicine_prescriptions/+919836014691
    """
    try:
        result = prescription_service.get_prescriptions(folder_type.value, phone_number, expiration)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
