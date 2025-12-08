from pydantic import BaseModel
from typing import Optional

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str

class OTPResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: Optional[str] = None

class SignupRequest(BaseModel):
    phone_number: str

class SignupResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: str

class SigninRequest(BaseModel):
    phone_number: str

class SigninResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: str
