from sqlalchemy.orm import Session
from app.db.models import Ambulance
from datetime import datetime
import uuid

def create_ambulance_booking(db: Session, phn_no: str, current_location: str, destination: str) -> Ambulance:
    """Create a new ambulance booking record"""
    booking = Ambulance(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        current_location=current_location,
        destination=destination
    )
    db.add(booking)
    db.commit()
    db.refresh(booking)
    return booking

def get_ambulance_booking(db: Session, booking_id: str) -> Ambulance:
    """Retrieve ambulance booking by id"""
    return db.query(Ambulance).filter(Ambulance.id == booking_id).first()

def get_ambulance_bookings_by_phone(db: Session, phn_no: str):
    """Retrieve all ambulance bookings by phone number"""
    return db.query(Ambulance).filter(Ambulance.phn_no == phn_no).all()
