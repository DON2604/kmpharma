from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .models import OTPResponse, OTPVerifyRequest, SigninRequest, SigninResponse, SignupRequest, SignupResponse
from .service import verify_otp_2factor, signin_user, signup_user
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/otp", tags=["OTP"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/verify", response_model=OTPResponse)
async def verify_otp_endpoint(request: OTPVerifyRequest, db: Session = Depends(get_db)):
    try:
        result = verify_otp_2factor(request.phone_number, request.otp_code, db)

        if result["success"]:
            return OTPResponse(
                message="OTP verified successfully",
                session_id=result["session_id"]
            )
        else:
            raise HTTPException(status_code=400, detail="Invalid OTP or OTP expired")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/signup", response_model=SignupResponse)
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    try:
        session_id = signup_user(request.phone_number, db)
        return SignupResponse(message="OTP sent successfully. Please verify to complete signup.", session_id=session_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/signin", response_model=SigninResponse)
async def signin(request: SigninRequest, db: Session = Depends(get_db)):
    try:
        session_id = signin_user(request.phone_number, db)
        return SigninResponse(message="OTP sent successfully", session_id=session_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
