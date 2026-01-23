from sqlalchemy.orm import Session
from app.db.models import Medicine
from datetime import datetime
import uuid

async def create_medicine_booking(db: Session, phn_no: str, medicines: list, location: str, prescription: str = None) -> Medicine:
    medicine_booking = Medicine(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        medicines=medicines,
        location=location,
        prescription=prescription
    )
    db.add(medicine_booking)
    db.commit()
    db.refresh(medicine_booking)
    return medicine_booking

async def create_prescription_record(db: Session, phn_no: str, prescription_url: str, location: str) -> Medicine:
    """Create a medicine record with just prescription URL"""
    medicine_record = Medicine(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        medicines=[],
        prescription=prescription_url,
        location=location,
        status="prescription_uploaded"
    )
    db.add(medicine_record)
    db.commit()
    db.refresh(medicine_record)
    return medicine_record

async def get_medicine_booking(db: Session, booking_id: str) -> Medicine:
    return db.query(Medicine).filter(Medicine.id == booking_id).first()

async def get_medicine_bookings_by_phone(db: Session, phn_no: str) -> list:
    return db.query(Medicine).filter(Medicine.phn_no == phn_no).all()

async def delete_medicine_booking(db: Session, booking_id: str) -> bool:
    medicine_booking = db.query(Medicine).filter(Medicine.id == booking_id).first()
    if medicine_booking:
        db.delete(medicine_booking)
        db.commit()
        return True
    return False
