import os
import boto3
from botocore.client import Config
from botocore.exceptions import NoCredentialsError, ClientError
from dotenv import load_dotenv
from typing import List, Optional, Dict

load_dotenv()

# Environment variables
BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")
BACKBLAZE_KEYTD = os.getenv("BACKBLAZE_KEYTD")
ENDPOINT_URL = os.getenv("ENDPOINT_URL")
BUCKET = os.getenv("BUCKET")

def get_s3_client():
    """Initialize an S3-compatible client for Backblaze B2."""
    return boto3.client(
        "s3",
        endpoint_url=ENDPOINT_URL,
        aws_access_key_id=BACKBLAZE_KEYTD,
        aws_secret_access_key=BACKBLAZE_KEY,
        config=Config(signature_version="s3v4")
    )

def generate_presigned_url(bucket_name: str, object_key: str, expiration: int = 604800) -> Optional[str]:
    """Generate a presigned GET URL for an object. Default: 7 days (604800 seconds)."""
    s3 = get_s3_client()
    try:
        return s3.generate_presigned_url(
            ClientMethod="get_object",
            Params={
                "Bucket": bucket_name,
                "Key": object_key
            },
            ExpiresIn=expiration
        )
    except Exception as e:
        print(f"[ERROR] Failed to generate presigned URL: {e}")
        return None

def files_exist_with_phone_prefix(bucket_name: str, folder: str, phone_number: str) -> bool:
    """Check if at least one file exists with the given phone number prefix."""
    s3 = get_s3_client()
    prefix = f"{folder.rstrip('/')}/{phone_number}"
    
    try:
        response = s3.list_objects_v2(
            Bucket=bucket_name,
            Prefix=prefix,
            MaxKeys=1
        )
        return "Contents" in response
    except ClientError as e:
        print(f"[ERROR] Failed to check files: {e}")
        return False

def list_files_with_phone_prefix(bucket_name: str, folder: str, phone_number: str, expiration: int = 604800) -> List[Dict[str, any]]:
    """List all files with phone prefix and generate presigned URLs. Default: 7 days."""
    s3 = get_s3_client()
    prefix = f"{folder.rstrip('/')}/{phone_number}"
    paginator = s3.get_paginator("list_objects_v2")
    
    files = []
    
    try:
        for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
            for obj in page.get("Contents", []):
                key = obj["Key"]
                url = generate_presigned_url(bucket_name, key, expiration)
                files.append({
                    "key": key,
                    "url": url,
                    "last_modified": obj.get("LastModified").isoformat() if obj.get("LastModified") else None,
                    "size": obj.get("Size", 0)
                })
    except ClientError as e:
        print(f"[ERROR] Failed to list files: {e}")
    
    return files

class PrescriptionService:
    """Service class for managing prescription queries."""
    
    def __init__(self):
        if not all([BACKBLAZE_KEY, BACKBLAZE_KEYTD, ENDPOINT_URL, BUCKET]):
            raise RuntimeError("Missing required environment variables for S3 connection")
        self.bucket = BUCKET
    
    def check_prescriptions_exist(self, folder_type: str, phone_number: str) -> Dict:
        """Check if prescriptions exist for a phone number in specified folder."""
        exists = files_exist_with_phone_prefix(self.bucket, folder_type, phone_number)
        return {
            "exists": exists,
            "folder_type": folder_type,
            "phone_number": phone_number
        }
    
    def get_prescriptions(self, folder_type: str, phone_number: str, expiration: int = 604800) -> Dict:
        """Get all prescriptions with presigned URLs for a phone number. Default: 7 days."""
        exists = files_exist_with_phone_prefix(self.bucket, folder_type, phone_number)
        
        files = []
        if exists:
            files = list_files_with_phone_prefix(self.bucket, folder_type, phone_number, expiration)
        
        return {
            "exists": exists,
            "count": len(files),
            "files": files,
            "folder_type": folder_type,
            "phone_number": phone_number
        }

# Singleton instance
prescription_service = PrescriptionService()
