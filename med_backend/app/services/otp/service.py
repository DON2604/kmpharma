import os
import requests
from dotenv import load_dotenv
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.services.otp.db_worker import (
    create_otp_record, verify_otp_record, delete_otp_record, get_otp_record, get_otp_record_by_phone, update_or_create_verification
)

load_dotenv()

API_KEY = os.getenv("TWOFACTOR_API_KEY")
BASE_URL = "https://2factor.in/API/V1"
OTP_EXPIRY_SECONDS = 60


def verify_otp_2factor(phone_number: str, otp_code: str, db: Session) -> dict:
    # Check if record exists by phone number
    record = get_otp_record_by_phone(db, phone_number)
    if not record:
        return {"success": False, "session_id": None}

    # Store original verified status
    was_verified = record.verified

    # Check if OTP expired only if not verified (> 60 seconds)
    if not record.verified:
        elapsed = (datetime.utcnow() - record.created_at).total_seconds()
        if elapsed > OTP_EXPIRY_SECONDS:
            delete_otp_record(db, record.session_id)
            return {"success": False, "session_id": None}

    # Verify with API using phone number directly
    url = f"{BASE_URL}/{API_KEY}/SMS/VERIFY3/{phone_number}/{otp_code}"
    response = requests.get(url).json()

    if response.get("Status") == "Success":
        verify_otp_record(db, record.session_id)
        return {"success": True, "session_id": record.session_id}
    else:
        # Only delete record if user was never verified (signup flow)
        if not was_verified:
            delete_otp_record(db, record.session_id)
        return {"success": False, "session_id": None}


def signup_user(phone_number: str, db: Session) -> str:
    """Sign up user: check if phone exists, if not create new verification record"""
    # Check if phone number already exists
    existing_user = get_otp_record_by_phone(db, phone_number)

    if existing_user:
        raise Exception("Phone number already registered. Please use sign in.")

    # Send OTP for new user
    url = f"{BASE_URL}/{API_KEY}/SMS/{phone_number}/AUTOGEN/OTP1"
    response = requests.get(url).json()

    if response.get("Status") == "Success":
        session_id = response["Details"]
        # Create new verification record
        create_otp_record(db, phone_number, session_id)
        return session_id

    raise Exception(response.get("Details", "Failed to send OTP"))


def signin_user(phone_number: str, db: Session) -> str:
    """Sign in user: check if user exists, then send OTP and update session_id"""
    # Check if user exists
    existing_user = get_otp_record_by_phone(db, phone_number)

    if not existing_user:
        raise Exception("Phone number not registered. Please sign up first.")

    # Send OTP
    url = f"{BASE_URL}/{API_KEY}/SMS/{phone_number}/AUTOGEN/OTP1"
    response = requests.get(url).json()

    if response.get("Status") == "Success":
        session_id = response["Details"]
        # Update session_id and reset verified status
        update_or_create_verification(db, phone_number, session_id)
        return session_id

    raise Exception(response.get("Details", "Failed to send OTP"))
