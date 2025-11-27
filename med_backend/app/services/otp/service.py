import os
import requests
import random
import string
from typing import Dict
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("TWOFACTOR_API_KEY")
BASE_URL = "https://2factor.in/API/V1"

# In-memory OTP store (optional since 2Factor verifies too)
otp_storage: Dict[str, str] = {}


def generate_otp(length: int = 6) -> str:
    """Generate a numeric OTP."""
    return ''.join(random.choices(string.digits, k=length))


def send_otp(phone_number: str) -> str:
    """
    Sends OTP using 2Factor AUTOGEN API.
    2Factor automatically stores & verifies OTP for you.
    """
    url = f"{BASE_URL}/{API_KEY}/SMS/{phone_number}/AUTOGEN"

    response = requests.get(url)
    data = response.json()

    if data.get("Status") == "Success":
        session_id = data["Details"]
        print("OTP sent. Session ID:", session_id)
        return session_id

    raise Exception("Failed to send OTP: " + str(data))


def verify_otp(session_id: str, otp_code: str) -> bool:
    """
    Verifies OTP using 2Factor VERIFY API.
    """
    url = f"{BASE_URL}/{API_KEY}/SMS/VERIFY/{session_id}/{otp_code}"

    response = requests.get(url)
    data = response.json()

    if data.get("Status") == "Success":
        return True
    
    return False