from sqlalchemy.orm import Session
from app.db.models import Verification
from datetime import datetime, timedelta

def create_otp_record(db: Session, phn_no: str, session_id: str) -> Verification:
    """Create a new OTP verification record"""
    verification = Verification(
        phn_no=phn_no,
        session_id=session_id,
        verified=False
    )
    db.add(verification)
    db.commit()
    db.refresh(verification)
    return verification

def verify_otp_record(db: Session, session_id: str) -> Verification:
    """Mark OTP as verified"""
    verification = db.query(Verification).filter(
        Verification.session_id == session_id
    ).first()
    
    if verification:
        verification.verified = True
        db.commit()
        db.refresh(verification)
    return verification

def get_otp_record(db: Session, session_id: str) -> Verification:
    """Retrieve OTP record by session_id"""
    return db.query(Verification).filter(
        Verification.session_id == session_id
    ).first()

def get_otp_record_by_phone(db: Session, phn_no: str) -> Verification:
    """Retrieve OTP record by phone number"""
    return db.query(Verification).filter(
        Verification.phn_no == phn_no
    ).first()

def delete_otp_record(db: Session, session_id: str) -> bool:
    """Delete OTP record"""
    verification = db.query(Verification).filter(
        Verification.session_id == session_id
    ).first()
    
    if verification:
        db.delete(verification)
        db.commit()
        return True
    return False
