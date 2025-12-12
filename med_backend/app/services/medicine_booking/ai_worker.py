import google.generativeai as genai
import os
from dotenv import load_dotenv
import json
import re
import tempfile

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

def process_prescription_pdf(pdf_file) -> dict:
    """Send prescription file (PDF or JPG) directly to Gemini and extract recommended medicines"""
    temp_file_path = None
    try:
        model = genai.GenerativeModel("gemini-2.5-flash")
        
        # Read file
        file_data = pdf_file.read()
        
        # Determine MIME type based on file content
        mime_type = "application/pdf" if file_data[:4] == b'%PDF' else "image/jpeg"
        
        # Save to temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf' if mime_type == "application/pdf" else '.jpg') as tmp:
            tmp.write(file_data)
            temp_file_path = tmp.name
        
        # Upload file using the path
        file_response = genai.upload_file(temp_file_path, mime_type=mime_type)
        
        prompt = """
        Analyze this prescription document (PDF or image) and extract the following information:
        
        1. Doctor's information (name, specialization, registration number if available)
        2. Diagnosis or medical condition
        3. List of prescribed medicines with dosage and instructions (if any)
        
        Please provide ONLY a JSON response with the following format:
        {
            "doctor": {
                "name": "doctor's name or 'Not found'",
                "specialization": "doctor's specialization or 'Not specified'",
                "registration_number": "registration number or 'Not found'"
            },
            "diagnosis": "brief diagnosis from prescription or 'Not specified'",
            "recommended_medicines": ["medicine1 - dosage - instructions", "medicine2 - dosage - instructions"],
            "medicines_found": true/false
        }
        
        If no medicines are mentioned in the prescription, set "medicines_found" to false and "recommended_medicines" to an empty array.
        Return medicine names with their complete dosage and instructions if available.
        Format: "Medicine Name - Dosage - Instructions" (e.g., "Paracetamol 500mg - 1 tablet - Three times daily after meals")
        """
        
        response = model.generate_content([file_response, prompt])
        response_text = response.text
        
        # Extract JSON from response
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            json_str = json_match.group(0)
            result = json.loads(json_str)
            
            medicines_found = result.get("medicines_found", len(result.get("recommended_medicines", [])) > 0)
            
            return {
                "status": "success",
                "doctor": result.get("doctor", {
                    "name": "Not found",
                    "specialization": "Not specified",
                    "registration_number": "Not found"
                }),
                "diagnosis": result.get("diagnosis", "Not specified"),
                "recommended_medicines": result.get("recommended_medicines", []),
                "medicines_found": medicines_found,
                "message": "No medicines found in prescription" if not medicines_found else None
            }
        
        return {
            "status": "error",
            "message": "Could not parse response from Gemini",
            "doctor": None,
            "recommended_medicines": [],
            "medicines_found": False
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "doctor": None,
            "recommended_medicines": [],
            "medicines_found": False
        }
    finally:
        # Clean up temporary file
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
