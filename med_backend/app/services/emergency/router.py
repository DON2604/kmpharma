from fastapi import APIRouter, HTTPException
from .models import EmergencyCallRequest, EmergencyCallResponse
from .service import make_emergency_calls

router = APIRouter(prefix="/emergency", tags=["Emergency"])

@router.post("/call", response_model=EmergencyCallResponse)
async def trigger_emergency_call(request: EmergencyCallRequest):
    if not request.message or not request.contacts:
        raise HTTPException(status_code=400, detail="Missing message or contacts")

    try:
        call_sids = make_emergency_calls(request.message, request.contacts)
        return EmergencyCallResponse(status="calling", calls=call_sids)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
