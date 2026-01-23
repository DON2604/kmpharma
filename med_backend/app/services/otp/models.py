from pydantic import BaseModel, field_validator

class SignupRequest(BaseModel):
    phone_number: str
    pin: str
    
    @field_validator('pin')
    @classmethod
    def validate_pin(cls, v):
        if not v.isdigit() or len(v) != 4:
            raise ValueError('PIN must be exactly 4 digits')
        return v

class SignupResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: str

class SigninRequest(BaseModel):
    phone_number: str
    pin: str
    
    @field_validator('pin')
    @classmethod
    def validate_pin(cls, v):
        if not v.isdigit() or len(v) != 4:
            raise ValueError('PIN must be exactly 4 digits')
        return v

class SigninResponse(BaseModel):
    message: str
    status: str = "success"
    session_id: str
