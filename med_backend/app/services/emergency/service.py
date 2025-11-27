from twilio.rest import Client
from typing import List

# Twilio credentials
ACCOUNT_SID = "ACxxxxxxxxxxxxxxxxxxxxxx"
AUTH_TOKEN = "xxxxxxxxxxxxxxxxxxxxxx"
TWILIO_NUMBER = "+1XXXXXXXXXX"

# Initialize Twilio client
# Note: Ensure valid credentials are provided above or via environment variables
try:
    client = Client(ACCOUNT_SID, AUTH_TOKEN)
except Exception as e:
    print(f"Warning: Failed to initialize Twilio client: {e}")
    client = None

def make_emergency_calls(message: str, numbers: List[str]) -> List[str]:
    if not client:
        raise Exception("Twilio client is not initialized. Check credentials.")

    call_sids = []
    for number in numbers:
        try:
            call = client.calls.create(
                to=number,
                from_=TWILIO_NUMBER,
                twiml=f"""
                <Response>
                    <Say voice="woman">
                        Emergency Alert. The user said: {message}.
                        Please contact them immediately.
                    </Say>
                </Response>
                """
            )
            call_sids.append(call.sid)
        except Exception as e:
            print(f"Error calling {number}: {e}")
            # We continue to try other numbers even if one fails
            continue
            
    return call_sids
