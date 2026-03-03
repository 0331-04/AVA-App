from ultralytics import YOLO
import cv2

# Load trained model
model = YOLO("My First Project.v1i.yolov8/runs/detect/train2/weights/best.pt")

# Use ORIGINAL image from valid/images (NOT predict folder)
image_path = "My First Project.v1i.yolov8/valid/images/20_jpeg.rf.9ff685a955cd70b4a99f43e78cf90dd6.jpg"

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
