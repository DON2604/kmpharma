from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.services.medicine_booking.service import book_medicine, get_user_medicine_bookings, cancel_medicine_booking, upload_prescription
from app.services.medicine_booking.models import MedicineBookingRequest, MedicineBookingResponse, PrescriptionUploadResponse, MedicineInfoRequest, MedicineInfoResponse
from app.services.medicine_booking.ai_worker import get_medicine_info
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/medicine-booking", tags=["Medicine Booking"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/book", response_model=MedicineBookingResponse)
async def book_medicines(request: MedicineBookingRequest, db: Session = Depends(get_db)):
    try:
        return await book_medicine(db, request)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{phone_number}/{session_id}", response_model=list[MedicineBookingResponse])
async def get_user_bookings(phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        return await get_user_medicine_bookings(db, phone_number, session_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/cancel/{booking_id}/{phone_number}/{session_id}")
async def cancel_booking(booking_id: str, phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        success = await cancel_medicine_booking(db, booking_id, phone_number, session_id)
        if not success:
            raise HTTPException(status_code=404, detail="Medicine booking not found")
        return {"message": "Medicine booking cancelled successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/upload-prescription", response_model=PrescriptionUploadResponse)
async def upload_prescription_file(
    file: UploadFile = File(..., description="Prescription file (PDF or JPG)"),
    phone_number: str = Form(...),
    session_id: str = Form(...),
    db: Session = Depends(get_db)
):
    try:
        # Check file size (10MB max)
        MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
        file_content = await file.read()
        if len(file_content) > MAX_FILE_SIZE:
            raise HTTPException(status_code=413, detail="File size exceeds 10MB limit")
        
        # Reset file pointer
        await file.seek(0)
        
        result = await upload_prescription(file.file, phone_number, session_id, db)
        return result
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/medicine-info", response_model=MedicineInfoResponse)
async def get_medicine_information(request: MedicineInfoRequest):
    """Get detailed information about a medicine (handles spelling mistakes)"""
    try:
        if not request.medicine_name or not request.medicine_name.strip():
            raise HTTPException(status_code=400, detail="Medicine name is required")
        
        result = get_medicine_info(request.medicine_name.strip())
        
        if result["status"] == "not_found":
            raise HTTPException(status_code=404, detail=result["message"])
        elif result["status"] == "error":
            raise HTTPException(status_code=500, detail=result["message"])
        
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
