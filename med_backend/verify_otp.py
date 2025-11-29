import os
import boto3
from botocore.exceptions import NoCredentialsError
from dotenv import load_dotenv


load_dotenv()

BACKBLAZE_KEY = os.getenv("BACKBLAZE_KEY")
BACKBLAZE_KEYTD = os.getenv("BACKBLAZE_KEYTD")
ENDPOINT_URL = os.getenv("ENDPOINT_URL")

def upload_to_backblaze(file_path, bucket_name, object_name=None):
    """
    Upload a file to Backblaze B2 using S3 compatibility.
    """
    # ---------------------------------------------------------
    # CONFIGURATION
    # ---------------------------------------------------------
    endpoint_url = ENDPOINT_URL # Found in B2 Bucket Settings
    # ---------------------------------------------------------

    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = file_path.split('/')[-1]

    # Initialize the S3 client
    s3 = boto3.client(
        's3',
        endpoint_url=endpoint_url,
        aws_access_key_id=BACKBLAZE_KEYTD,
        aws_secret_access_key=BACKBLAZE_KEY
    )

    try:
        # Upload the file
        print(f"Uploading {file_path} to {bucket_name}...")
        s3.upload_file(file_path, bucket_name, object_name)
        print("Upload Successful")
        return True
    except FileNotFoundError:
        print("The file was not found")
        return False
    except NoCredentialsError:
        print("Credentials not available")
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

# --- Usage Example ---
if __name__ == "__main__":
    # Replace these with your actual details
    my_bucket = os.getenv("BUCKET")    
    my_image = "wave.gif"
    
    upload_to_backblaze(my_image, my_bucket)