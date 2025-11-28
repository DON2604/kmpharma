import os
import requests
from dotenv import load_dotenv
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.services.otp.db_worker import (
    create_otp_record, verify_otp_record, delete_otp_record, get_otp_record, get_otp_record_by_phone
)

load_dotenv()

API_KEY = os.getenv("TWOFACTOR_API_KEY")
BASE_URL = "https://2factor.in/API/V1"
OTP_EXPIRY_SECONDS = 60


def send_otp_2factor(phone_number: str, db: Session) -> str:
    url = f"{BASE_URL}/{API_KEY}/SMS/{phone_number}/AUTOGEN/OTP1"

    response = requests.get(url).json()

    if response.get("Status") == "Success":
        session_id = response["Details"]
        # Store in database
        create_otp_record(db, phone_number, session_id)
        return session_id

    raise Exception(response.get("Details", "Failed to send OTP"))


def verify_otp_2factor(phone_number: str, otp_code: str, db: Session) -> bool:
    # Check if record exists by phone number
    record = get_otp_record_by_phone(db, phone_number)
    if not record:
        return False

    # Check if OTP expired only if not verified (> 60 seconds)
    if not record.verified:
        elapsed = (datetime.utcnow() - record.created_at).total_seconds()
        if elapsed > OTP_EXPIRY_SECONDS:
            delete_otp_record(db, record.session_id)
            return False

    # Verify with API using phone number directly
    url = f"{BASE_URL}/{API_KEY}/SMS/VERIFY3/{phone_number}/{otp_code}"
    response = requests.get(url).json()

    if response.get("Status") == "Success":
        verify_otp_record(db, record.session_id)
        return True
    else:
        # Delete record on failed verification
        delete_otp_record(db, record.session_id)
        return False
