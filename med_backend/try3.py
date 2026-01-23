import os
import boto3
from botocore.client import Config
from botocore.exceptions import NoCredentialsError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Environment variables
BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")          # Application Key
BACKBLAZE_KEYTD = os.getenv("BACKBLAZE_KEYTD")      # Application Key ID
ENDPOINT_URL = os.getenv("ENDPOINT_URL")            # e.g. https://s3.us-west-004.backblazeb2.com
BUCKET = os.getenv("BUCKET")

# -----------------------------
# S3 Client for Backblaze B2
# -----------------------------
def get_s3_client():
    """
    Initialize an S3-compatible client for Backblaze B2.
    """
    return boto3.client(
        "s3",
        endpoint_url=ENDPOINT_URL,
        aws_access_key_id=BACKBLAZE_KEYTD,
        aws_secret_access_key=BACKBLAZE_KEY,
        config=Config(signature_version="s3v4")
    )

# -----------------------------
# Generate Presigned URL
# -----------------------------
def generate_presigned_url(bucket_name, object_key, expiration=3600):
    """
    Generate a presigned GET URL for an object.
    """
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

# -----------------------------
# Check if any file exists with phone prefix
# -----------------------------
def files_exist_with_phone_prefix(bucket_name, folder, phone_number):
    """
    Efficiently checks if at least one file exists in a folder
    that starts with the given phone number.
    """
    s3 = get_s3_client()

    prefix = f"{folder.rstrip('/')}/{phone_number}"

    response = s3.list_objects_v2(
        Bucket=bucket_name,
        Prefix=prefix,
        MaxKeys=1
    )

    return "Contents" in response

# -----------------------------
# List all files with phone prefix
# -----------------------------
def list_files_with_phone_prefix(bucket_name, folder, phone_number):
    """
    Lists all object keys that start with the given phone number
    inside the specified folder.
    """
    s3 = get_s3_client()

    prefix = f"{folder.rstrip('/')}/{phone_number}"
    paginator = s3.get_paginator("list_objects_v2")

    files = []

    for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
        for obj in page.get("Contents", []):
            files.append(obj["Key"])

    return files

# -----------------------------
# Main Execution
# -----------------------------
if __name__ == "__main__":
    if not all([BACKBLAZE_KEY, BACKBLAZE_KEYTD, ENDPOINT_URL, BUCKET]):
        raise RuntimeError("Missing required environment variables")

    folder = "medicine_prescriptions"
    phone_number = "+919836014691"

    print(f"Checking files for phone number: {phone_number}")

    if files_exist_with_phone_prefix(BUCKET, folder, phone_number):
        print("Files found.")

        files = list_files_with_phone_prefix(BUCKET, folder, phone_number)
        print(f"Total files: {len(files)}")

        for key in files:
            print(f"\nObject Key: {key}")
            url = generate_presigned_url(BUCKET, key)
            if url:
                print("Presigned URL:")
                print(url)
    else:
        print("No files found for this phone number.")
