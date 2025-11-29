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
    """Send prescription file (PDF or JPG) directly to Gemini and extract recommended tests"""
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
        Analyze this prescription document (PDF or image) and extract the list of recommended lab tests.
        
        Please provide ONLY a JSON response with the following format:
        {
            "diagnosis": "brief diagnosis from prescription",
            "recommended_tests": ["test1", "test2", "test3"]
        }
        
        Return only valid lab test names that are commonly available.
        """
        
        response = model.generate_content([file_response, prompt])
        response_text = response.text
        
        # Extract JSON from response
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            json_str = json_match.group(0)
            result = json.loads(json_str)
            return {
                "status": "success",
                "diagnosis": result.get("diagnosis", ""),
                "recommended_tests": result.get("recommended_tests", [])
            }
        
        return {
            "status": "error",
            "message": "Could not parse response from Gemini",
            "recommended_tests": []
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e),
            "recommended_tests": []
        }
    finally:
        # Clean up temporary file
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)