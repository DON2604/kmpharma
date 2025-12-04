from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from .models import CheckUserRequest, CheckUserResponse
from .service import check_user_session
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/check-user", tags=["Check User"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("", response_model=CheckUserResponse)
async def check_user(request: CheckUserRequest, db: Session = Depends(get_db)):
    try:
        result = check_user_session(request.session_id, db)
        
        if result["status"] == "error":
            raise HTTPException(status_code=404, detail=result["message"])
        
        return CheckUserResponse(
            message=result["message"],
            status=result["status"],
            phone_number=result["phone_number"],
            verified=result["verified"]
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
