import os
import boto3
from botocore.exceptions import NoCredentialsError
from dotenv import load_dotenv
import uuid

load_dotenv()

BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")
BACKBLAZE_KEYID = os.getenv("BACKBLAZE_KEYTD")
ENDPOINT_URL = os.getenv("ENDPOINT_URL")
BUCKET_NAME = os.getenv("BUCKET")

async def upload_prescription_to_b2(file, phone_number: str) -> str:
    """Upload prescription file to Backblaze B2 storage"""
    try:
        # Read file content
        file_content = file.read()
        
        # Determine file extension
        file_extension = ".pdf" if file_content[:4] == b'%PDF' else ".jpg"
        
        # Generate unique object name
        object_name = f"medicine_prescriptions/{phone_number}_{uuid.uuid4()}{file_extension}"
        
        # Initialize S3 client
        s3 = boto3.client(
            's3',
            endpoint_url=ENDPOINT_URL,
            aws_access_key_id=BACKBLAZE_KEYID,
            aws_secret_access_key=BACKBLAZE_KEY
        )
        
        # Upload to B2
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=object_name,
            Body=file_content
        )
        
        # Construct file URL
        file_url = f"{ENDPOINT_URL}/file/{BUCKET_NAME}/{object_name}"
        
        return file_url
    except NoCredentialsError:
        raise Exception("B2 credentials not available")
    except Exception as e:
        raise Exception(f"Failed to upload to B2: {str(e)}")
