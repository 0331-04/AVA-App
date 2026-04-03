from ultralytics import YOLO
import cv2

# ============================================================
# VEHICLE DAMAGE ANALYSIS SCRIPT
# This script uses a trained YOLOv8 model to:
# 1. Detect vehicle damages from an image
# 2. Estimate total damaged area
# 3. Calculate damage percentage relative to car size
# ============================================================


# ----------------------------
# CONFIGURATION
# ----------------------------
FIXED_SIZE = 640            # Standard size to normalize all input images
CAR_RATIO = 0.85            # Assumption: car occupies 85% of total image
BOX_SHRINK_FACTOR = 0.35    # Correction factor to reduce YOLO box overestimation


# ----------------------------
# Load trained YOLOv8 model
# ----------------------------
# The model should be previously trained on vehicle damage dataset
model = YOLO("ML_model.yolov8/runs/detect/train2/weights/best.pt")


# ----------------------------
# Define input image path
# ----------------------------
# Replace with your test image path if needed
image_path = "ML_model.yolov8/valid/images/49_jpeg.rf.c3c53cb427a4a3bd3c3842af3eded488.jpg"


# ----------------------------
# Load image using OpenCV
# ----------------------------
image = cv2.imread(image_path)

# Validate image loading
if image is None:
    print("Image not found. Check path.")
    exit()


# ----------------------------
# Resize image for consistency
# ----------------------------
# Ensures all images are processed in the same dimension
image = cv2.resize(image, (FIXED_SIZE, FIXED_SIZE))

# Extract image dimensions
height, width, _ = image.shape
image_area = height * width  # Total image area in pixels

# Estimate car area based on predefined ratio
car_area = image_area * CAR_RATIO


# ----------------------------
# Run YOLO prediction
# ----------------------------
# Model returns detection results including bounding boxes
results = model(image)
result = results[0]  # Get first result (single image)

# Initialize total damage area accumulator
damage_area = 0


# ----------------------------
# Process detected bounding boxes
# ----------------------------
# Each box represents a detected damage region
if result.boxes is not None and len(result.boxes) > 0:

    for box in result.boxes.xyxy.cpu().numpy():
        # Extract coordinates
        x1, y1, x2, y2 = box

        # Calculate width and height of bounding box
        box_width = x2 - x1
        box_height = y2 - y1

        # Compute raw bounding box area
        raw_area = box_width * box_height

        # Apply correction factor to get more realistic damage area
        corrected_area = raw_area * BOX_SHRINK_FACTOR

        # Debug prints for analysis
        print("Raw Box Area:", raw_area)
        print("Corrected Damage Area:", corrected_area)
        print("-----------------------------")

        # Accumulate total damage area
        damage_area += corrected_area

else:
    # No damages detected
    print("No damage detected.")


# ----------------------------
# Calculate damage percentage
# ----------------------------
# Compare total damage area with estimated car area
if car_area > 0:
    damage_percent = (damage_area / car_area) * 100
else:
    damage_percent = 0


# ----------------------------
# Apply upper cap to avoid unrealistic outputs
# ----------------------------
# Helps stabilize results in case of detection errors
damage_percent = min(damage_percent, 60)


# ----------------------------
# Final Output Summary
# ----------------------------
print("\nImage Area:", image_area)
print("Assumed Car Area:", car_area)
print("Total Corrected Damage Area:", damage_area)
print("Damage Percentage: {:.2f}%".format(damage_percent))