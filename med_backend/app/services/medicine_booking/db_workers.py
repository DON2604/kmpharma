from sqlalchemy.orm import Session
from app.db.models import Medicine
from datetime import datetime
import uuid

async def create_medicine_booking(db: Session, phn_no: str, medicines: list) -> Medicine:
    medicine_booking = Medicine(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        medicines=medicines
    )
    db.add(medicine_booking)
    db.commit()
    db.refresh(medicine_booking)
    return medicine_booking

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
