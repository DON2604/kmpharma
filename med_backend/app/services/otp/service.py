import os
import bcrypt
import uuid
from dotenv import load_dotenv
from datetime import datetime
from sqlalchemy.orm import Session
from app.services.otp.db_worker import (
    create_verification_record, verify_record, get_record_by_phone
)

load_dotenv()


def hash_pin(pin: str) -> str:
    """Hash a PIN using bcrypt"""
    return bcrypt.hashpw(pin.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')


def verify_pin(pin: str, pin_hash: str) -> bool:
    """Verify a PIN against its hash"""
    return bcrypt.checkpw(pin.encode('utf-8'), pin_hash.encode('utf-8'))


def signup_user(phone_number: str, pin: str, db: Session) -> str:
    """Sign up user with phone number and PIN"""
    # Check if phone number already exists
    existing_user = get_record_by_phone(db, phone_number)

    if existing_user:
        raise Exception("Phone number already registered. Please use sign in.")

    # Hash the PIN
    pin_hash = hash_pin(pin)
    
    # Generate session_id
    session_id = str(uuid.uuid4())
    
    # Create new verification record with auto-verify
    create_verification_record(db, phone_number, session_id, pin_hash)
    verify_record(db, session_id)
    
    return session_id


def signin_user(phone_number: str, pin: str, db: Session) -> str:
    """Sign in user with phone number and PIN"""
    # Check if user exists
    user = get_record_by_phone(db, phone_number)

    if not user:
        raise Exception("Phone number not registered. Please sign up first.")

    # Check if PIN hash exists
    if not user.pin_hash:
        raise Exception("Invalid account. Please contact support.")

    # Verify PIN
    if verify_pin(pin, user.pin_hash):
        # Generate new session_id for this login
        new_session_id = str(uuid.uuid4())
        user.session_id = new_session_id
        user.verified = True
        db.commit()
        db.refresh(user)
        return new_session_id
    else:
        raise Exception("Invalid PIN")
