from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
from .models import AmbBookingRequest, AmbBookingResponse
from .service import book_ambulance
from .db_worker import get_ambulance_bookings_by_phone
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/ambulance", tags=["Ambulance"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/book", response_model=AmbBookingResponse)
async def book_ambulance_endpoint(request: AmbBookingRequest, db: Session = Depends(get_db)):
    try:
        booking = book_ambulance(request.phone_number, request.session_id, request.curr_loc, request.destination, db)
        return booking
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/bookings/{phone_number}/{session_id}", response_model=List[AmbBookingResponse])
async def get_bookings(phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        # Validate session_id matches phone number
        from app.services.otp.db_worker import get_record_by_session
        verification_record = get_record_by_session(db, session_id)
        
        if not verification_record or verification_record.phn_no != phone_number:
            raise HTTPException(status_code=401, detail="Invalid session or phone number")
        
        bookings = get_ambulance_bookings_by_phone(db, phone_number)
        if not bookings:
            raise HTTPException(status_code=404, detail="No bookings found for this phone number")
        return bookings
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
