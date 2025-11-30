from app.db.db_init import engine
from app.db.base import Base
from app.db.models import Verification, Ambulance
from sqlalchemy import inspect

def create_tables():
    """Create all tables if they don't exist"""
    inspector = inspect(engine)
    existing_tables = inspector.get_table_names()

    required_tables = ['verification', 'ambulance', 'lab_test','reminder']

    # Find which required tables are missing
    missing_tables = [t for t in required_tables if t not in existing_tables]

    if missing_tables:
        print("Creating missing tables:", missing_tables)
        Base.metadata.create_all(bind=engine)
        print("✓ Tables created successfully!")
    else:
        print("✓ All required tables already exist!")

if __name__ == "__main__":
    create_tables()
