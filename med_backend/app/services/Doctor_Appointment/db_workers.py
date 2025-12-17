from sqlalchemy.orm import Session
from app.db.models import DoctorAppointment
from datetime import datetime
import uuid

async def create_doctor_appointment(
    db: Session, 
    phn_no: str, 
    symptoms: str, 
    preferred_specialization: str,
    preferred_date: datetime,
    preferred_time: str
) -> DoctorAppointment:
    """Create a new doctor appointment"""
    appointment = DoctorAppointment(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        symptoms=symptoms,
        preferred_specialization=preferred_specialization,
        preferred_date=preferred_date,
        preferred_time=preferred_time,
        status="pending"
    )
    db.add(appointment)
    db.commit()
    db.refresh(appointment)
    return appointment

async def get_doctor_appointment(db: Session, appointment_id: str) -> DoctorAppointment:
    """Retrieve appointment by id"""
    return db.query(DoctorAppointment).filter(DoctorAppointment.id == appointment_id).first()

async def get_doctor_appointments_by_phone(db: Session, phn_no: str) -> list:
    """Retrieve all appointments by phone number"""
    return db.query(DoctorAppointment).filter(DoctorAppointment.phn_no == phn_no).all()

async def delete_doctor_appointment(db: Session, appointment_id: str) -> bool:
    """Delete an appointment"""
    appointment = db.query(DoctorAppointment).filter(DoctorAppointment.id == appointment_id).first()
    if appointment:
        db.delete(appointment)
        db.commit()
        return True
    return False
