from sqlalchemy import ARRAY, Column, String, Boolean, DateTime, ForeignKey
from datetime import datetime
from app.db.base import Base

class Verification(Base):
    __tablename__ = "verification"
    phn_no = Column(String(20), primary_key=True)
    session_id = Column(String(255), nullable=False, unique=True)
    verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    pin_hash = Column(String(255), nullable=True)

class Ambulance(Base):
    __tablename__ = "ambulance"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    current_location = Column(String(255), nullable=False)
    destination = Column(String(255), nullable=False)
    status = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class LabTset(Base):
    __tablename__ = "lab_test"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    tests = Column(ARRAY(String(100)), nullable=False, default=list)
    status = Column(String(50), default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)

class Reminder(Base):
    __tablename__ = "reminder"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    reminder_text = Column(String(500), nullable=False)
    reminder_time = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class Medicine(Base):
    __tablename__ = "medicine"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    medicines = Column(ARRAY(String(200)), default=list)
    status = Column(String(50), default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)
    prescription = Column(String(1000))
    location = Column(String(255), nullable=False)

class DoctorAppointment(Base):
    __tablename__ = "doctor_appointment"
    id = Column(String(50), primary_key=True)
    phn_no = Column(String(20), ForeignKey("verification.phn_no"), nullable=False)
    symptoms = Column(String(1000), nullable=False)
    preferred_specialization = Column(String(200), nullable=False)
    preferred_date = Column(DateTime, nullable=False)
    preferred_time = Column(String(50), nullable=False)
    status = Column(String(50), default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)

