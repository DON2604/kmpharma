from sqlalchemy.orm import Session
from app.services.otp.db_worker import get_otp_record
from app.services.Ambulance_Booking.db_worker import create_ambulance_booking

def book_ambulance(phone_number: str, session_id: str, current_location: str, destination: str, db: Session):
    """Book ambulance if session_id and phone number are verified"""
    # Check if session_id exists and phone number is verified
    verification_record = get_otp_record(db, session_id)
    
    if not verification_record or not verification_record.verified:
        raise Exception("Invalid session or phone number not verified. Please verify OTP first.")
    
    if verification_record.phn_no != phone_number:
        raise Exception("Phone number does not match with session.")
    
    # Create ambulance booking
    booking = create_ambulance_booking(db, phone_number, current_location, destination)
    return booking
