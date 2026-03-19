from ultralytics import YOLO
import cv2

# ----------------------------
# CONFIGURATION
# ----------------------------
FIXED_SIZE = 640            # Normalize all images
CAR_RATIO = 0.85            # Assume car occupies 85% of frame
BOX_SHRINK_FACTOR = 0.35    # Compensate for YOLO rectangle overestimation

# ----------------------------
# Load trained model
# ----------------------------
model = YOLO("My First Project.v1i.yolov8/runs/detect/train2/weights/best.pt")

# ----------------------------
# Image path
# ----------------------------
image_path = "My First Project.v1i.yolov8/valid/images/20_jpeg.rf.9ff685a955cd70b4a99f43e78cf90dd6.jpg"

# ----------------------------
# Load image
# ----------------------------
image = cv2.imread(image_path)

if image is None:
    print("Image not found. Check path.")
    exit()

# ----------------------------
# Resize for normalization
# ----------------------------
image = cv2.resize(image, (FIXED_SIZE, FIXED_SIZE))

height, width, _ = image.shape
image_area = height * width

# Approximate car area
car_area = image_area * CAR_RATIO

# ----------------------------
# Run prediction
# ----------------------------
results = model(image)
result = results[0]

damage_area = 0

if result.boxes is not None and len(result.boxes) > 0:

    for box in result.boxes.xyxy.cpu().numpy():
        x1, y1, x2, y2 = box

        box_width = x2 - x1
        box_height = y2 - y1

        raw_area = box_width * box_height
        corrected_area = raw_area * BOX_SHRINK_FACTOR

        print("Raw Box Area:", raw_area)
        print("Corrected Damage Area:", corrected_area)
        print("-----------------------------")

        damage_area += corrected_area

else:
    print("No damage detected.")

# ----------------------------
# Calculate percentage
# ----------------------------
if car_area > 0:
    damage_percent = (damage_area / car_area) * 100
else:
    damage_percent = 0

# Optional cap to avoid unrealistic values
damage_percent = min(damage_percent, 60)

print("\nImage Area:", image_area)
print("Assumed Car Area:", car_area)
print("Total Corrected Damage Area:", damage_area)
print("Damage Percentage: {:.2f}%".format(damage_percent))