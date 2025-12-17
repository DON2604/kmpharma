from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
from app.services.Doctor_Appointment.models import DoctorAppointmentRequest, DoctorAppointmentResponse
from app.services.Doctor_Appointment.service import book_doctor_appointment, get_user_appointments, cancel_appointment
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/doctor-appointment", tags=["Doctor Appointment"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/book", response_model=DoctorAppointmentResponse)
async def create_appointment(request: DoctorAppointmentRequest, db: Session = Depends(get_db)):
    """Book a new doctor appointment"""
    try:
        return await book_doctor_appointment(db, request)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{phone_number}/{session_id}", response_model=List[DoctorAppointmentResponse])
async def get_appointments(phone_number: str, session_id: str, db: Session = Depends(get_db)):
    """Get all appointments for a user"""
    try:
        return await get_user_appointments(db, phone_number, session_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/cancel/{appointment_id}/{phone_number}/{session_id}")
async def delete_appointment(appointment_id: str, phone_number: str, session_id: str, db: Session = Depends(get_db)):
    """Cancel a doctor appointment"""
    try:
        success = await cancel_appointment(db, appointment_id, phone_number, session_id)
        if not success:
            raise HTTPException(status_code=404, detail="Appointment not found")
        return {"message": "Appointment cancelled successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
