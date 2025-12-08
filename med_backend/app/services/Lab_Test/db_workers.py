from sqlalchemy.orm import Session
from app.db.models import LabTset
from datetime import datetime
import uuid

async def create_lab_test(db: Session, phn_no: str, tests: list) -> LabTset:
    lab_test = LabTset(
        id=str(uuid.uuid4()),
        phn_no=phn_no,
        tests=tests
    )
    db.add(lab_test)
    db.commit()
    db.refresh(lab_test)
    return lab_test

async def get_lab_test(db: Session, test_id: str) -> LabTset:
    return db.query(LabTset).filter(LabTset.id == test_id).first()

async def get_lab_tests_by_phone(db: Session, phn_no: str) -> list:
    return db.query(LabTset).filter(LabTset.phn_no == phn_no).all()

async def delete_lab_test(db: Session, test_id: str) -> bool:
    lab_test = db.query(LabTset).filter(LabTset.id == test_id).first()
    if lab_test:
        db.delete(lab_test)
        db.commit()
        return True
    return False

