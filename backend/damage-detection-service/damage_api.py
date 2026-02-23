"""
Flask API for AVA Damage Detection Service
REST endpoints for vehicle damage analysis
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from damage_detection_service import analyze_vehicle_damage, VehicleDamageDetector
import os
from werkzeug.utils import secure_filename
import traceback

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = '/tmp/ava_damage_uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'heic'}
MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10MB

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create upload folder if it doesn't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "AVA Damage Detection Service",
        "version": "1.0.0"
    }), 200

@app.route('/api/v1/detect-damage', methods=['POST'])
def detect_damage():
    """
    Detect and analyze vehicle damage
    
    Request:
        - file: Image file (multipart/form-data)
        - annotate: boolean (optional, default: true) - Return annotated image
        - vehicle_part: string (optional) - Specific part to analyze
    
    Response:
        - total_damages: int
        - overall_severity: string
        - damages: array of detected damages
        - total_estimated_cost: object with min/max
        - requires_inspection: boolean
        - drivable: boolean
        - annotated_image: base64 string (if requested)
        - summary: string
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({
                "error": "No file provided",
                "message": "Please upload an image file"
            }), 400
        
        file = request.files['file']
        
        # Check if file is selected
        if file.filename == '':
            return jsonify({
                "error": "No file selected",
                "message": "Please select an image file"
            }), 400
        
        # Check file extension
        if not allowed_file(file.filename):
            return jsonify({
                "error": "Invalid file type",
                "message": f"Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
            }), 400
        
        # Read file data
        image_data = file.read()
        
        # Get options
        annotate = request.form.get('annotate', 'true').lower() == 'true'
        vehicle_part = request.form.get('vehicle_part', None)
        
        # Analyze damage
        logger.info(f"Analyzing damage for {file.filename}")
        result = analyze_vehicle_damage(image_data, annotate=annotate)
        
        # Add metadata
        result['metadata'] = {
            "filename": secure_filename(file.filename),
            "file_size": len(image_data),
            "vehicle_part": vehicle_part
        }
        
        logger.info(f"Damage analysis complete: {result['total_damages']} damages found")
        
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Error processing image: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({
            "error": "Processing error",
            "message": str(e)
        }), 500

@app.route('/api/v1/batch-detect', methods=['POST'])
def batch_detect_damage():
    """
    Detect damage in multiple images
    
    Request:
        - files[]: Multiple image files (multipart/form-data)
        - annotate: boolean (optional, default: false for performance)
    
    Response:
        - results: array of damage analysis results
        - summary: overall statistics
    """
    try:
        files = request.files.getlist('files[]')
        
        if not files or len(files) == 0:
            return jsonify({
                "error": "No files provided",
                "message": "Please upload at least one image file"
            }), 400
        
        annotate = request.form.get('annotate', 'false').lower() == 'true'
        
        results = []
        total_damages = 0
        total_cost_min = 0
        total_cost_max = 0
        requires_inspection = False
        not_drivable_count = 0
        
        for file in files:
            if file.filename == '':
                continue
            
            if not allowed_file(file.filename):
                results.append({
                    "filename": file.filename,
                    "error": "Invalid file type"
                })
                continue
            
            try:
                image_data = file.read()
                result = analyze_vehicle_damage(image_data, annotate=annotate)
                result['filename'] = secure_filename(file.filename)
                
                # Aggregate statistics
                total_damages += result['total_damages']
                total_cost_min += result['total_estimated_cost']['min']
                total_cost_max += result['total_estimated_cost']['max']
                
                if result['requires_inspection']:
                    requires_inspection = True
                
                if not result['drivable']:
                    not_drivable_count += 1
                
                results.append(result)
            
            except Exception as e:
                results.append({
                    "filename": file.filename,
                    "error": str(e)
                })
        
        summary = {
            "total_images": len(results),
            "total_damages_detected": total_damages,
            "total_estimated_cost": {
                "min": total_cost_min,
                "max": total_cost_max,
                "currency": "USD"
            },
            "requires_inspection": requires_inspection,
            "not_drivable_count": not_drivable_count
        }
        
        return jsonify({
            "results": results,
            "summary": summary
        }), 200
    
    except Exception as e:
        logger.error(f"Error in batch processing: {str(e)}")
        return jsonify({
            "error": "Batch processing error",
            "message": str(e)
        }), 500

@app.route('/api/v1/damage-types', methods=['GET'])
def get_damage_types():
    """
    Get list of detectable damage types and their descriptions
    """
    damage_types = {
        "scratch": "Linear surface damage from contact or abrasion",
        "dent": "Inward deformation of body panel without paint damage",
        "crack": "Linear fracture in surface material",
        "shattered_glass": "Broken or spider-web pattern in glass surfaces",
        "broken_light": "Damaged headlight, taillight, or signal light",
        "bumper_damage": "Damage to front or rear bumper",
        "paint_damage": "Chipped, peeled, or discolored paint",
        "rust": "Corrosion or oxidation damage",
        "missing_part": "Component completely missing or detached",
        "tire_damage": "Tire puncture, wear, or structural damage"
    }
    
    severity_levels = {
        "minor": "Small, superficial damage requiring minimal repair",
        "moderate": "Noticeable damage requiring professional attention",
        "severe": "Significant damage affecting functionality or safety",
        "critical": "Extensive damage requiring immediate repair"
    }
    
    vehicle_parts = [
        "front_bumper", "rear_bumper", "hood", "trunk", "windshield",
        "front_left_door", "front_right_door", "rear_left_door", "rear_right_door",
        "left_fender", "right_fender", "headlight", "taillight",
        "side_mirror", "wheel", "tire", "roof"
    ]
    
    return jsonify({
        "damage_types": damage_types,
        "severity_levels": severity_levels,
        "vehicle_parts": vehicle_parts
    }), 200

@app.route('/api/v1/estimate-cost', methods=['POST'])
def estimate_repair_cost():
    """
    Get repair cost estimate for specific damage types
    
    Request:
        - damages: array of {type, severity} objects
    
    Response:
        - total_cost: {min, max, currency}
        - breakdown: array of individual costs
    """
    try:
        data = request.get_json()
        
        if not data or 'damages' not in data:
            return jsonify({
                "error": "Invalid request",
                "message": "Please provide damages array"
            }), 400
        
        detector = VehicleDamageDetector()
        breakdown = []
        total_min = 0
        total_max = 0
        
        for damage in data['damages']:
            damage_type = damage.get('type')
            severity = damage.get('severity')
            
            if damage_type and severity:
                # Get cost from lookup table
                from damage_detection_service import DamageType, DamageSeverity
                
                try:
                    dt = DamageType(damage_type)
                    sev = DamageSeverity(severity)
                    
                    cost_range = detector.DAMAGE_COSTS[dt][sev]
                    
                    breakdown.append({
                        "type": damage_type,
                        "severity": severity,
                        "cost": {
                            "min": cost_range[0],
                            "max": cost_range[1],
                            "currency": "USD"
                        }
                    })
                    
                    total_min += cost_range[0]
                    total_max += cost_range[1]
                
                except ValueError:
                    pass
        
        return jsonify({
            "total_cost": {
                "min": total_min,
                "max": total_max,
                "currency": "USD"
            },
            "breakdown": breakdown
        }), 200
    
    except Exception as e:
        return jsonify({
            "error": "Cost estimation error",
            "message": str(e)
        }), 500

@app.route('/api/v1/analyze-severity', methods=['POST'])
def analyze_severity():
    """
    Analyze overall severity of multiple damages
    
    Request:
        - damages: array of severity levels
    
    Response:
        - overall_severity: string
        - requires_inspection: boolean
        - recommendation: string
    """
    try:
        data = request.get_json()
        
        if not data or 'damages' not in data:
            return jsonify({
                "error": "Invalid request",
                "message": "Please provide damages array"
            }), 400
        
        from damage_detection_service import DamageSeverity
        
        severity_counts = {
            "minor": 0,
            "moderate": 0,
            "severe": 0,
            "critical": 0
        }
        
        for damage in data['damages']:
            severity = damage.get('severity', 'minor')
            if severity in severity_counts:
                severity_counts[severity] += 1
        
        # Determine overall severity
        if severity_counts['critical'] > 0:
            overall = "critical"
        elif severity_counts['severe'] >= 2:
            overall = "critical"
        elif severity_counts['severe'] > 0:
            overall = "severe"
        elif severity_counts['moderate'] >= 3:
            overall = "severe"
        elif severity_counts['moderate'] > 0:
            overall = "moderate"
        else:
            overall = "minor"
        
        requires_inspection = (
            severity_counts['critical'] > 0 or
            severity_counts['severe'] > 0 or
            severity_counts['moderate'] >= 3
        )
        
        recommendations = {
            "minor": "Minor damage detected. Standard claim processing can proceed.",
            "moderate": "Moderate damage detected. Professional assessment recommended.",
            "severe": "Severe damage detected. Professional inspection REQUIRED before repairs.",
            "critical": "Critical damage detected. Immediate professional inspection REQUIRED. Vehicle may be unsafe."
        }
        
        return jsonify({
            "overall_severity": overall,
            "requires_inspection": requires_inspection,
            "recommendation": recommendations[overall],
            "severity_breakdown": severity_counts
        }), 200
    
    except Exception as e:
        return jsonify({
            "error": "Severity analysis error",
            "message": str(e)
        }), 500

@app.errorhandler(413)
def too_large(e):
    """Handle file too large error"""
    return jsonify({
        "error": "File too large",
        "message": f"Maximum file size is {MAX_CONTENT_LENGTH / (1024*1024)} MB"
    }), 413

@app.errorhandler(500)
def internal_error(e):
    """Handle internal server error"""
    logger.error(f"Internal server error: {str(e)}")
    return jsonify({
        "error": "Internal server error",
        "message": "An unexpected error occurred"
    }), 500

if __name__ == '__main__':
    print("=" * 70)
    print("AVA Damage Detection Service Starting...")
    print("=" * 70)
    print(f"Upload folder: {UPLOAD_FOLDER}")
    print(f"Max file size: {MAX_CONTENT_LENGTH / (1024*1024)} MB")
    print(f"Allowed formats: {', '.join(ALLOWED_EXTENSIONS)}")
    print("=" * 70)
    print("\nDetectable Damage Types:")
    print("  • Scratches          • Dents             • Cracks")
    print("  • Shattered Glass    • Broken Lights     • Bumper Damage")
    print("  • Paint Damage       • Rust/Corrosion    • Missing Parts")
    print("=" * 70)
    
    # Run the Flask app
    app.run(
        host='0.0.0.0',
        port=5002,  # Different port from quality service
        debug=True
    )