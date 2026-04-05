# Version: 1.0.1
# Last Updated: 2026-03-30


from flask import Flask, request, jsonify
from ultralytics import YOLO
import cv2
import os

# ============================================================
# FLASK API FOR VEHICLE DAMAGE ANALYSIS
# This API:
# 1. Accepts an uploaded vehicle image
# 2. Runs YOLOv8 damage detection
# 3. Calculates damage percentage
# 4. Returns damage summary as JSON
# ============================================================

# Initialize Flask app
app = Flask(__name__)

# ----------------------------
# Load trained YOLO model
# ----------------------------
# Ensure the model path is correct before running
model = YOLO("ML_model.yolov8/runs/detect/train6/weights/best.pt")

# ----------------------------
# Configure upload folder
# ----------------------------
# Temporary storage for uploaded images
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


# ----------------------------
# API Endpoint: /analyze
# ----------------------------
@app.route("/analyze", methods=["POST"])
def analyze():

    # Check if image is included in request
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    # Get uploaded file
    file = request.files["image"]

    # Save file temporarily
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # ----------------------------
    # Load image using OpenCV
    # ----------------------------
    image = cv2.imread(filepath)

    # Extract image dimensions
    height, width, _ = image.shape
    total_image_area = height * width  # Total pixel area of image

    # ----------------------------
    # Run YOLO detection
    # ----------------------------
    # Pass file path directly to model
    results = model(filepath)
    result = results[0]

    # Initialize variables
    damage_area = 0            # Total detected damage area
    damage_counts = {}        # Dictionary to store count of each damage type

    # ----------------------------
    # Process detection results
    # ----------------------------
    for box in result.boxes:

        # Get class ID and class name
        cls_id = int(box.cls[0])
        class_name = model.names[cls_id]

        # Extract bounding box coordinates
        x1, y1, x2, y2 = box.xyxy[0]

        # Calculate bounding box area
        area = float((x2 - x1) * (y2 - y1))

        # Accumulate total damage area
        damage_area += area

        # Count occurrences of each damage type
        if class_name in damage_counts:
            damage_counts[class_name] += 1
        else:
            damage_counts[class_name] = 1

    # ----------------------------
    # Calculate damage percentage
    # ----------------------------
    damage_percent = (damage_area / total_image_area) * 100

    # ----------------------------
    # Clean up (delete uploaded file)
    # ----------------------------
    os.remove(filepath)

    # ----------------------------
    # Return JSON response
    # ----------------------------
    return jsonify({
        "damage_percentage": round(damage_percent, 2),
        "damage_counts": damage_counts
    })


# ----------------------------
# Run Flask server
# ----------------------------
if __name__ == "__main__":
    app.run(debug=True, port=5000)