from pydantic import BaseModel

class OTPRequest(BaseModel):
    phone_number: str

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str

class OTPResponse(BaseModel):
    message: str
    status: str = "success"
