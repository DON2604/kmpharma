from pydantic import BaseModel
from typing import Optional

class OTPRequest(BaseModel):
    phone_number: str

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str

class OTPResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: Optional[str] = None

class SigninRequest(BaseModel):
    phone_number: str

class SigninResponse(BaseModel):
    message: str
    status: str = "success"
