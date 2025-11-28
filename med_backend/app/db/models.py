from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from datetime import datetime
from app.db.base import Base

class Verification(Base):
    __tablename__ = "verification"
    phn_no = Column(String(20), primary_key=True)
    session_id = Column(String(255), nullable=False, unique=True)
    verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class Ambulance(Base):
    __tablename__ = "ambulance"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    current_location = Column(String(255), nullable=False)
    destination = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
