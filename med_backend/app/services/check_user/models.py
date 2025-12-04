from pydantic import BaseModel

class CheckUserRequest(BaseModel):
    session_id: str

class CheckUserResponse(BaseModel):
    message: str
    status: str
    phone_number: str = None
    verified: bool = False
