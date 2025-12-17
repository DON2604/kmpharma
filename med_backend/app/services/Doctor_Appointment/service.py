from sqlalchemy.orm import Session
from app.services.Doctor_Appointment.db_workers import (
    create_doctor_appointment, 
    get_doctor_appointments_by_phone, 
    delete_doctor_appointment
)
from app.services.Doctor_Appointment.models import DoctorAppointmentRequest, DoctorAppointmentResponse
from app.db.models import Verification

async def book_doctor_appointment(db: Session, request: DoctorAppointmentRequest) -> DoctorAppointmentResponse:
    """Create a new doctor appointment for verified user"""
    # Verify user exists and is verified
    user = db.query(Verification).filter(
        Verification.phn_no == request.phone_number,
        Verification.session_id == request.session_id
    ).first()
    
    if not user:
        raise ValueError("User not found")
    
    if not user.verified:
        raise ValueError("User not verified")
    
    # Create appointment
    appointment = await create_doctor_appointment(
        db=db,
        phn_no=request.phone_number,
        symptoms=request.symptoms,
        preferred_specialization=request.preferred_specialization,
        preferred_date=request.preferred_date,
        preferred_time=request.preferred_time
    )
    
    return DoctorAppointmentResponse(
        id=appointment.id,
        phn_no=appointment.phn_no,
        phone_number=request.phone_number,
        symptoms=appointment.symptoms,
        preferred_specialization=appointment.preferred_specialization,
        preferred_date=appointment.preferred_date,
        preferred_time=appointment.preferred_time,
        status=appointment.status,
        created_at=appointment.created_at
    )

async def get_user_appointments(db: Session, phone_number: str, session_id: str) -> list:
    """Get all appointments for a verified user"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    appointments = await get_doctor_appointments_by_phone(db, phone_number)
    return [
        DoctorAppointmentResponse(
            id=apt.id,
            phn_no=apt.phn_no,
            phone_number=phone_number,
            symptoms=apt.symptoms,
            preferred_specialization=apt.preferred_specialization,
            preferred_date=apt.preferred_date,
            preferred_time=apt.preferred_time,
            status=apt.status,
            created_at=apt.created_at
        )
        for apt in appointments
    ]

async def cancel_appointment(db: Session, appointment_id: str, phone_number: str, session_id: str) -> bool:
    """Cancel an appointment for verified user"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    return await delete_doctor_appointment(db, appointment_id)
