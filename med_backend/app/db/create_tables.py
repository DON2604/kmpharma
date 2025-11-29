from app.db.db_init import engine
from app.db.base import Base
from app.db.models import Verification,Ambulance
from sqlalchemy import inspect

def create_tables():
    """Create all tables if they don't exist"""
    inspector = inspect(engine)
    existing_tables = inspector.get_table_names()
    
    
    if ["verification","ambulance","lab_test"] not in existing_tables:
        Base.metadata.create_all(bind=engine)
        print("✓ Tables created successfully!")
    else:
        print("✓ Tables already exist!")

if __name__ == "__main__":
    create_tables()
