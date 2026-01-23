from sqlalchemy.orm import Session
from app.services.medicine_booking.db_workers import create_medicine_booking, get_medicine_booking, get_medicine_bookings_by_phone, delete_medicine_booking, create_prescription_record
from app.services.medicine_booking.models import MedicineBookingRequest, MedicineBookingResponse
from app.services.medicine_booking.b2_worker import upload_prescription_to_b2
from app.db.models import Verification
from datetime import datetime
import os
import uuid

async def book_medicine(db: Session, request: MedicineBookingRequest) -> MedicineBookingResponse:
    # Verify user exists and is verified
    user = db.query(Verification).filter(
        Verification.phn_no == request.phone_number,
        Verification.session_id == request.session_id
    ).first()
    
    if not user:
        raise ValueError("User not found")
    
    if not user.verified:
        raise ValueError("User not verified")
    
    # Create medicine booking
    medicine_booking = await create_medicine_booking(
        db=db,
        phn_no=request.phone_number,
        medicines=request.medicines
    )
    
    return MedicineBookingResponse(
        id=medicine_booking.id,
        phn_no=medicine_booking.phn_no,
        phone_number=request.phone_number,
        medicines=medicine_booking.medicines,
        status=medicine_booking.status
    )

async def get_user_medicine_bookings(db: Session, phone_number: str, session_id: str) -> list:
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    medicine_bookings = await get_medicine_bookings_by_phone(db, phone_number)
    return [
        MedicineBookingResponse(
            id=booking.id,
            phn_no=booking.phn_no,
            phone_number=phone_number,
            medicines=booking.medicines,
            status=booking.status
        )
        for booking in medicine_bookings
    ]

async def cancel_medicine_booking(db: Session, booking_id: str, phone_number: str, session_id: str) -> bool:
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    return await delete_medicine_booking(db, booking_id)

async def upload_prescription(file, phone_number: str, session_id: str, db: Session) -> dict:
    """Upload prescription to B2 storage and save URL to database"""
    # Verify user
    user = db.query(Verification).filter(
        Verification.phn_no == phone_number,
        Verification.session_id == session_id
    ).first()
    
    if not user or not user.verified:
        raise ValueError("User not verified")
    
    # Upload file to B2 storage
    file_url = upload_prescription_to_b2(file, phone_number)
    
    # Create medicine record with prescription URL
    medicine_record = await create_prescription_record(db, phone_number, file_url)
    
    return {
        "phone_number": phone_number,
        "file_url": file_url,
        "message": "Prescription uploaded successfully"
    }
