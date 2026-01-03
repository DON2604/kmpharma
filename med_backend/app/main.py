import os
from fastapi import FastAPI
from sqlalchemy import create_engine, inspect
from app.services.otp import router as otp_router
from app.services.Ambulance_Booking import router as ambulance_router
from app.services.Lab_Test import router as labtest_router
from app.services.Reminders import router as reminder_router
from app.services.check_user import router as check_user_router
from app.services.medicine_booking import router as medicine_booking_router
from app.services.Doctor_Appointment import router as doctor_appointment_router
from app.services.fetch_presc import router as fetch_presc_router
from app.db import check_db_connection,create_tables

app = FastAPI(title="Med Backend Services")

# Include routers from different services
app.include_router(otp_router)
app.include_router(ambulance_router)
app.include_router(labtest_router)
app.include_router(reminder_router)
app.include_router(check_user_router)
app.include_router(medicine_booking_router)
app.include_router(doctor_appointment_router)
app.include_router(fetch_presc_router)  

check_db_connection()
create_tables()

@app.get("/")
async def root():
    return {"message": "Welcome to Med Backend Services"}
