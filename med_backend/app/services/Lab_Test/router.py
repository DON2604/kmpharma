from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.services.Lab_Test.service import book_lab_test, get_user_lab_tests, cancel_lab_test, process_prescription
from app.services.Lab_Test.models import LabTestReqest, LabTestResponse
from app.db.db_init import SessionLocal

router = APIRouter(prefix="/lab-test", tags=["Lab Test"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/book", response_model=LabTestResponse)
async def book_test(request: LabTestReqest, db: Session = Depends(get_db)):
    try:
        return await book_lab_test(db, request)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/user/{phone_number}/{session_id}", response_model=list[LabTestResponse])
async def get_user_tests(phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        return await get_user_lab_tests(phone_number, session_id, db)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/cancel/{test_id}/{phone_number}/{session_id}")
async def cancel_test(test_id: str, phone_number: str, session_id: str, db: Session = Depends(get_db)):
    try:
        success = await cancel_lab_test(db, test_id, phone_number, session_id)
        if not success:
            raise HTTPException(status_code=404, detail="Lab test not found")
        return {"message": "Lab test cancelled successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/analyze-prescription")
async def analyze_prescription(
    file: UploadFile = File(..., description="Prescription file (PDF or JPG)"),
    phone_number: str = Form(...),
    session_id: str = Form(...),
    db: Session = Depends(get_db)
):
    try:
        # Check file size (10MB max)
        MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
        file_content = await file.read()
        if len(file_content) > MAX_FILE_SIZE:
            raise HTTPException(status_code=413, detail="File size exceeds 10MB limit")
        
        # Reset file pointer
        await file.seek(0)
        
        result = await process_prescription(file.file, phone_number, session_id, db)
        return result
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
