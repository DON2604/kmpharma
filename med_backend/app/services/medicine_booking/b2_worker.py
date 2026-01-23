import os
import boto3
import uuid
from dotenv import load_dotenv
from botocore.client import Config
from botocore.exceptions import NoCredentialsError

load_dotenv()

# ENV VARIABLES
BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")
BACKBLAZE_KEYID = os.getenv("BACKBLAZE_KEYTD")
ENDPOINT_URL = os.getenv("ENDPOINT_URL")
BUCKET = os.getenv("BUCKET")


def get_s3_client():
    return boto3.client(
        "s3",
        endpoint_url=ENDPOINT_URL,
        aws_access_key_id=BACKBLAZE_KEYID,
        aws_secret_access_key=BACKBLAZE_KEY,
        config=Config(signature_version="s3v4")
    )


def upload_prescription_to_b2(file, phone_number: str, expiry=86400*6) -> str:
    """
    Upload prescription and instantly return presigned URL
    """
    try:
        file_bytes = file.read()

        # Detect file type
        if file_bytes[:4] == b"%PDF":
            ext = ".pdf"
            content_type = "application/pdf"
        else:
            ext = ".jpg"
            content_type = "image/jpeg"

        object_key = (
            f"medicine_prescriptions/"
            f"{phone_number}_{uuid.uuid4()}{ext}"
        )

        s3 = get_s3_client()

        # 1️⃣ Upload
        s3.put_object(
            Bucket=BUCKET,
            Key=object_key,
            Body=file_bytes,
            ContentType=content_type
        )

        # 2️⃣ Fetch URL (same logic as try3.py)
        presigned_url = s3.generate_presigned_url(
            ClientMethod="get_object",
            Params={
                "Bucket": BUCKET,
                "Key": object_key
            },
            ExpiresIn=expiry
        )

        return presigned_url

    except NoCredentialsError:
        raise RuntimeError("Backblaze B2 credentials not available")
    except Exception as e:
        raise RuntimeError(f"Upload or URL fetch failed: {e}")