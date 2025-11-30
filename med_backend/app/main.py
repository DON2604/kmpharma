import os
from fastapi import FastAPI
from sqlalchemy import create_engine, inspect
from app.services.otp import router as otp_router
from app.services.Ambulance_Booking import router as ambulance_router
from app.services.Lab_Test import router as labtest_router
from app.services.Reminders import router as reminder_router
from app.db import check_db_connection,create_tables

app = FastAPI(title="Med Backend Services")

# Include routers from different services
app.include_router(otp_router)
app.include_router(ambulance_router)
app.include_router(labtest_router)
app.include_router(reminder_router)

check_db_connection()
create_tables()

@app.get("/")
async def root():
    return {"message": "Welcome to Med Backend Services"}
