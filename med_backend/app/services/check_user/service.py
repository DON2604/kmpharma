from sqlalchemy.orm import Session
from app.db.models import Verification

def check_user_session(session_id: str, db: Session) -> dict:
    """Check if session_id exists and return user info"""
    user = db.query(Verification).filter(
        Verification.session_id == session_id
    ).first()
    
    if not user:
        return {
            "status": "error",
            "message": "Session not found",
            "phone_number": None,
            "verified": False
        }
    
    return {
        "status": "success",
        "message": "User session found",
        "phone_number": user.phn_no,
        "verified": user.verified
    }
