import os
import boto3
from botocore.client import Config # Import Config
from botocore.exceptions import NoCredentialsError
from dotenv import load_dotenv

load_dotenv()

BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")     
BACKBLAZE_KEYTD = os.getenv("BACKBLAZE_KEYTD") 
ENDPOINT_URL = os.getenv("ENDPOINT_URL")        

def get_s3_client():
    """
    Initialize the client with specific B2 configuration.
    B2 requires 's3v4' signature version to sign URLs correctly.
    """
    return boto3.client(
        's3',
        endpoint_url=ENDPOINT_URL,
        aws_access_key_id=BACKBLAZE_KEYTD,
        aws_secret_access_key=BACKBLAZE_KEY,
        config=Config(signature_version='s3v4') # <--- CRITICAL FIX FOR B2
    )

def generate_presigned_url(bucket_name, object_name, expiration=3600):
    s3 = get_s3_client()
    try:
        # Generate the URL
        url = s3.generate_presigned_url(
            ClientMethod='get_object',
            Params={
                'Bucket': bucket_name,
                'Key': object_name
            },
            ExpiresIn=expiration
        )
        return url
    except Exception as e:
        print(f"Error generating URL: {e}")
        return None

if __name__ == "__main__":
    bucket = os.getenv("BUCKET")   
    file_key = "medicine_prescriptions/+916292009950_d96444c3-80e1-49c6-8fa4-408784004fc2.jpg"
    
    print(f"Generating Link for: {file_key} in {bucket}...")
    url = generate_presigned_url(bucket, file_key)
    
    if url:
        print("\n--- NEW WORKING LINK (Valid for 1 hour) ---")
        print(url)
        print("-------------------------------------------\n")