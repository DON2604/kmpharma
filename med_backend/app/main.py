from fastapi import FastAPI
from app.services.otp import router as otp_router
from app.services.emergency import router as emergency_router

app = FastAPI(title="Med Backend Services")

# Include routers from different services
app.include_router(otp_router)
app.include_router(emergency_router)

@app.get("/")
async def root():
    return {"message": "Welcome to Med Backend Services"}
