from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .models import OTPRequest, OTPResponse, OTPVerifyRequest
from .service import send_otp_2factor, verify_otp_2factor
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/otp", tags=["OTP"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/send", response_model=OTPResponse)
async def send_otp(request: OTPRequest, db: Session = Depends(get_db)):
    try:
        # Call 2Factor SMS AUTOGEN API
        session_id = send_otp_2factor(request.phone_number, db)

        return OTPResponse(message="OTP sent successfully", session_id=session_id)

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/verify", response_model=OTPResponse)
async def verify_otp_endpoint(request: OTPVerifyRequest, db: Session = Depends(get_db)):
    try:
        is_valid = verify_otp_2factor(request.phone_number, request.otp_code, db)

        if is_valid:
            return OTPResponse(message="OTP verified successfully")
        else:
            raise HTTPException(status_code=400, detail="Invalid OTP or OTP expired")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
