from ultralytics import YOLO

# Load your trained model (IMPORTANT PATH)
model = YOLO("runs/detect/train/weights/best.pt")

# Put your test image path here
image_path = "valid/images/0263_JPEG.rf.8e2274f81f9b29118a34a7fae33773c6.jpg"

results = model(image_path)

vehicle_area = 0
damage_area = 0

result = results[0]

for box in result.boxes:
    cls_id = int(box.cls[0])
    x1, y1, x2, y2 = box.xyxy[0]

    width = x2 - x1
    height = y2 - y1
    area = width * height

    print("Detected class ID:", cls_id)

    # CHANGE THIS if vehicle is not class 0
    if cls_id == 0:
        vehicle_area = area
    else:
        damage_area += area

if vehicle_area > 0:
    damage_percent = (damage_area / vehicle_area) * 100
else:
    damage_percent = 0

print("\nVehicle Area:", vehicle_area)
print("Damage Area:", damage_area)
print("Damage Percentage: {:.2f}%".format(damage_percent))
