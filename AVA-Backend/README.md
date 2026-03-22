# AVA – AI Vehicle Assessment System

##  Project Overview
AVA is an AI-powered vehicle damage detection and insurance claim assistance system.

The system allows users to capture or upload vehicle images and automatically:
- Detect vehicle damages using AI (YOLOv8)
- Classify damage types (Dent / Scratch / Broken Part)
- Calculate estimated damage percentage
- Track insurance claim status through a customer portal

This project was developed as part of the Software Development Group Project (SDGP).

---

##  System Architecture

Mobile App (Flutter) → Backend Server (Node.js / Express) → ML API (Flask + YOLOv8)

---
##  Tech Stack

###  Frontend
- Flutter

###  Backend
- Node.js
- Express.js

###  Machine Learning
- Python
- Flask API
- YOLOv8 Object Detection
- Roboflow Dataset Management

---

##  Running the ML API

bash
cd AVA-App
python app.py

# The Flask API will run on:
http://127.0.0.1:5000

# Training the AI Model
cd ML_model.yolov8
yolo detect train data=data.yaml model=yolov8s.pt epochs=60 imgsz=640

# POST /analyze
file → vehicle_image.jpg

Example JSON Response:

{
  "damage_type": "dent",
  "damage_percentage": 12.8
}




<!-- # A new Flutter project.

# ## Getting Started

# This project is a starting point for a Flutter application.

# A few resources to get you started if this is your first Flutter project:

# - [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
# - [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

# For help getting started with Flutter development, view the
# [online documentation](https://docs.flutter.dev/), which offers tutorials,
# samples, guidance on mobile development, and a full API reference. -->
