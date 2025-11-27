from fastapi import APIRouter, HTTPException
from .models import OTPRequest, OTPResponse, OTPVerifyRequest
from .service import create_otp, send_sms, verify_otp

router = APIRouter(prefix="/otp", tags=["OTP"])

@router.post("/send", response_model=OTPResponse)
async def send_otp(request: OTPRequest):
    otp = create_otp(request.phone_number)
    message = f"Your OTP is: {otp}"
    
    if send_sms(request.phone_number, message):
        return OTPResponse(message="OTP sent successfully")
    else:
        raise HTTPException(status_code=500, detail="Failed to send OTP")

@router.post("/verify", response_model=OTPResponse)
async def verify_otp_endpoint(request: OTPVerifyRequest):
    is_valid = verify_otp(request.phone_number, request.otp_code)
    if is_valid:
        return OTPResponse(message="OTP verified successfully")
    else:
        raise HTTPException(status_code=400, detail="Invalid OTP or OTP expired")
