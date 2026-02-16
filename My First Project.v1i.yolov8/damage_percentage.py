from ultralytics import YOLO
import cv2

# Load trained model
model = YOLO("runs/detect/train/weights/best.pt")

# Use ORIGINAL image from valid/images (NOT predict folder)
image_path = "valid/images/0157_jpeg.rf.630aac1d763628af05f11241b15cd8ef.jpg"

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

print("Number of boxes detected:", len(result.boxes))

damage_area = 0

for box in result.boxes:
    x1, y1, x2, y2 = box.xyxy[0]

    box_width = float(x2 - x1)
    box_height = float(y2 - y1)

    area = box_width * box_height
    print("Box Area:", area)

    damage_area += area

# Convert to float
damage_area = float(damage_area)

# Calculate percentage
damage_percent = (damage_area / total_image_area) * 100

print("\nTotal Image Area:", total_image_area)
print("Damage Area:", damage_area)
print("Damage Percentage: {:.2f}%".format(damage_percent))
