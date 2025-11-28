import requests
import time

BASE_URL = "http://127.0.0.1:8000"

def test_otp_flow():
    print("Testing OTP Flow...")
    
    # 1. Send OTP
    phone = "+919836014691"
    print(f"Sending OTP to {phone}...")
    response = requests.post(f"{BASE_URL}/otp/send", json={"phone_number": phone})
    print(f"Send Response: {response.status_code} - {response.json()}")
    
    if response.status_code != 200:
        print("Failed to send OTP")
        return
    
    print(f"Got session_id: {response.json().get('session_id')}")
    
    # 2. Verify with Wrong OTP
    print("Verifying with WRONG OTP...")
    response = requests.post(f"{BASE_URL}/otp/verify", json={"phone_number": phone, "otp_code": "000000"})
    print(f"Verify Wrong Response: {response.status_code} - {response.json()}")
    assert response.status_code == 400
    
    print("Test Finished. Check server logs for the actual OTP to manually verify if needed.")

if __name__ == "__main__":
    # Wait for server to start
    time.sleep(2)
    try:
        test_otp_flow()
    except Exception as e:
        print(f"Test failed: {e}")
