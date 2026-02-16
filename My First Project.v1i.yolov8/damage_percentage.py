from ultralytics import YOLO
import cv2

# Load trained model
model = YOLO("runs/detect/train/weights/best.pt")

# Use ORIGINAL image from valid/images (NOT predict folder)
image_path = "valid/images/0263_JPEG.rf.8e2274f81f9b29118a34a7fae33773c6.jpg"

# Load image
image = cv2.imread(image_path)

if image is None:
    print("Image not found. Check path.")
    exit()

height, width, _ = image.shape
total_image_area = height * width

# Run prediction
results = model(image_path)
result = results[0]

damage_area = 0

for box in result.boxes:
    x1, y1, x2, y2 = box.xyxy[0]

    box_width = float(x2 - x1)
    box_height = float(y2 - y1)

    area = box_width * box_height
    damage_area += area

# Convert to float
damage_area = float(damage_area)

# Calculate percentage
damage_percent = (damage_area / total_image_area) * 100

print("\nTotal Image Area:", total_image_area)
print("Damage Area:", damage_area)
print("Damage Percentage: {:.2f}%".format(damage_percent))
