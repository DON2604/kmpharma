from fastapi import FastAPI
from app.services.otp import router as otp_router
from app.services.Ambulance_Booking import router as ambulance_router
from app.db import check_db_connection,create_tables

app = FastAPI(title="Med Backend Services")

# Include routers from different services
app.include_router(otp_router)
app.include_router(ambulance_router)


check_db_connection()
create_tables()

@app.get("/")
async def root():
    return {"message": "Welcome to Med Backend Services"}
