from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .models import SigninRequest, SigninResponse, SignupRequest, SignupResponse
from .service import signin_user, signup_user
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/auth", tags=["Authentication"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/signup", response_model=SignupResponse)
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    """Sign up with phone number and 4-digit PIN"""
    try:
        session_id = signup_user(request.phone_number, request.pin, db)
        return SignupResponse(
            message="Signup successful. You are now logged in.", 
            session_id=session_id
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/signin", response_model=SigninResponse)
async def signin(request: SigninRequest, db: Session = Depends(get_db)):
    """Sign in with phone number and 4-digit PIN"""
    try:
        session_id = signin_user(request.phone_number, request.pin, db)
        return SigninResponse(
            message="Sign in successful", 
            session_id=session_id
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
