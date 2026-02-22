from flask import Flask, request, jsonify
from ultralytics import YOLO
import cv2
import os

app = Flask(__name__)

# Load model using correct relative path
model = YOLO("My First Project.v1i.yolov8/runs/detect/train/weights/best.pt")

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/analyze", methods=["POST"])
def analyze():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # Load image to calculate total area
    image = cv2.imread(filepath)
    height, width, _ = image.shape
    total_image_area = height * width

    # Run YOLO
    results = model(filepath)
    result = results[0]

    damage_area = 0

    for box in result.boxes:
        x1, y1, x2, y2 = box.xyxy[0]
        damage_area += float((x2 - x1) * (y2 - y1))

    damage_percent = (damage_area / total_image_area) * 100

    # Remove temp file
    os.remove(filepath)

    return jsonify({
        "damage_percentage": round(damage_percent, 2)
    })

if __name__ == "__main__":
    app.run(debug=True, port=5000)