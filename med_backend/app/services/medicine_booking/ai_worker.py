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

def get_medicine_info(medicine_name: str) -> dict:
    """Get detailed information about a medicine using Gemini AI, handles spelling mistakes"""
    try:
        model = genai.GenerativeModel("gemini-2.5-flash")
        
        prompt = f"""
        Provide detailed information about the medicine: "{medicine_name}"
        
        Note: The medicine name might have spelling errors. Please identify the correct medicine name and provide information.
        
        IMPORTANT: Explain everything in simple, easy-to-understand language that anyone can comprehend. Avoid medical jargon.
        
        Provide ONLY a JSON response with the following format:
        {{
            "corrected_name": "correct medicine name",
            "generic_name": "generic/scientific name",
            "category": "medicine category in simple terms (e.g., Pain reliever, Fever reducer, Antibiotic for infections, etc.)",
            "uses": ["what it treats in simple language", "another use in simple language"],
            "dosage": "typical dosage in simple language (e.g., 'Usually 1 tablet twice a day' or 'As directed by doctor')",
            "side_effects": ["common side effect in simple terms", "another side effect in simple terms"],
            "precautions": ["simple precaution like 'Take with food', 'Avoid alcohol', etc.", "another simple precaution"],
            "alternative_medicines": ["similar medicine that can be used instead", "another alternative option"],
            "prescription_required": true/false,
            "found": true/false
        }}
        
        Use simple, everyday language. Explain like you're talking to someone without medical knowledge.
        For alternative_medicines, suggest 2-3 commonly available alternatives with similar effects.
        If the medicine is not found or cannot be identified even with spelling correction, set "found" to false and return minimal information.
        """
        
        response = model.generate_content(prompt)
        response_text = response.text
        
        # Extract JSON from response
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            json_str = json_match.group(0)
            result = json.loads(json_str)
            
            if result.get("found", True):
                return {
                    "status": "success",
                    "medicine_info": result
                }
            else:
                return {
                    "status": "not_found",
                    "message": f"Medicine '{medicine_name}' not found",
                    "medicine_info": None
                }
        
        return {
            "status": "error",
            "message": "Could not parse response from Gemini",
            "medicine_info": None
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "medicine_info": None
        }
