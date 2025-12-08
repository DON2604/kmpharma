from sqlalchemy.orm import Session
from app.services.Lab_Test.db_workers import create_lab_test, get_lab_test, get_lab_tests_by_phone, delete_lab_test
from app.services.Lab_Test.models import LabTestReqest, LabTestResponse
from app.services.Lab_Test.ai_worker import process_prescription_pdf
from app.services.Lab_Test.b2_worker import upload_prescription_to_b2
from app.db.models import Verification
from datetime import datetime
import os
import uuid

async def book_lab_test(db: Session, request: LabTestReqest) -> LabTestResponse:
    # Verify user exists and is verified
    user = db.query(Verification).filter(
        Verification.phn_no == request.phone_number,
        Verification.session_id == request.session_id
    ).first()
    
    if not user:
        raise ValueError("User not found")
    
    if not user.verified:
        raise ValueError("User not verified")
    
    # Create lab test booking
    lab_test = await create_lab_test(
        db=db,
        phn_no=request.phone_number,
        time=request.time,
        tests=request.tests
    )
    
    return LabTestResponse(
        id=lab_test.id,
        phn_no=lab_test.phn_no,
        phone_number=request.phone_number,
        time=lab_test.time,
        tests=lab_test.tests
    )

async def get_user_lab_tests(db: Session, phone_number: str, session_id: str) -> list:
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    lab_tests = await get_lab_tests_by_phone(db, phone_number)
    return [
        LabTestResponse(
            id=test.id,
            phn_no=test.phn_no,
            phone_number=phone_number,
            time=test.time,
            tests=test.tests
        )
        for test in lab_tests
    ]

async def cancel_lab_test(db: Session, test_id: str, phone_number: str, session_id: str) -> bool:
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    return await delete_lab_test(db, test_id)

async def process_prescription(pdf_file, phone_number: str, session_id: str, db: Session) -> dict:
    """Process prescription PDF and extract recommended tests"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    # Upload file to B2 storage
    file_url = await upload_prescription_to_b2(pdf_file, phone_number)
    
    # Reset file pointer for AI processing
    pdf_file.seek(0)
    
    # Process PDF with AI
    result = process_prescription_pdf(pdf_file)
    
    if result["status"] == "error":
        raise ValueError(result["message"])
    
    return {
        "phone_number": phone_number,
        "doctor": result.get("doctor"),
        "diagnosis": result.get("diagnosis", "Not specified"),
        "recommended_tests": result.get("recommended_tests", []),
        "tests_found": result.get("tests_found", False),
        "message": result.get("message"),
        "file_url": file_url
    }
