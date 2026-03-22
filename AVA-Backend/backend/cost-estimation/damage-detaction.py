# Complete damage detection with cost estimation
DAMAGE_COSTS = {
    # Format: "damage_type": {"repair_cost": amount, "part_cost": amount}
    "scratch": {
        "minor": {"repair": 15000, "part": 0},       # Just buffing/painting
        "moderate": {"repair": 35000, "part": 0},     # Deeper scratch, repainting
        "severe": {"repair": 75000, "part": 25000}    # Panel replacement needed
    },
    "dent": {
        "minor": {"repair": 25000, "part": 0},        # Paintless dent repair
        "moderate": {"repair": 50000, "part": 0},     # Traditional dent repair
        "severe": {"repair": 100000, "part": 50000}   # Panel replacement
    },
    "broken": {
        "minor": {"repair": 50000, "part": 75000},    # Small broken part
        "moderate": {"repair": 75000, "part": 150000}, # Major component
        "severe": {"repair": 150000, "part": 300000}  # Multiple parts
    },
    "cracked": {
        "minor": {"repair": 30000, "part": 50000},    # Small crack
        "moderate": {"repair": 60000, "part": 100000}, # Large crack
        "severe": {"repair": 120000, "part": 200000}  # Replacement needed
    }
}

# Vehicle part base costs (LKR)
PART_COSTS = {
    "front_bumper": 85000,
    "rear_bumper": 75000,
    "hood": 120000,
    "door": 150000,
    "fender": 95000,
    "headlight": 125000,
    "taillight": 85000,
    "windshield": 180000,
    "mirror": 45000,
    "roof": 200000
}

# Labor rates (LKR per hour)
LABOR_RATE = 2500
PAINT_COST_PER_PANEL = 25000

def calculate_severity(damage_percentage):
    """
    Determine damage severity based on percentage
    """
    if damage_percentage < 5:
        return "minor"
    elif damage_percentage < 15:
        return "moderate"
    else:
        return "severe"

def estimate_repair_cost(damage_counts, damage_percentage, total_damaged_area):
    """
    Calculate total repair cost based on detected damage
    """
    severity = calculate_severity(damage_percentage)
    
    total_parts_cost = 0
    total_labor_cost = 0
    total_paint_cost = 0
    
    damage_details = []
    
    for damage_type, count in damage_counts.items():
        # Normalize damage type name (lowercase, remove spaces)
        damage_key = damage_type.lower().replace(" ", "_")
        
        # Get base costs for this damage type
        if damage_key in DAMAGE_COSTS:
            costs = DAMAGE_COSTS[damage_key][severity]
        else:
            # Default costs if damage type not in database
            costs = {"repair": 50000, "part": 75000}
        
        # Calculate costs (multiply by count)
        parts_cost = costs["part"] * count
        labor_cost = costs["repair"] * count
        
        # Estimate labor hours based on severity
        labor_hours = 2 if severity == "minor" else 4 if severity == "moderate" else 8
        labor_cost = labor_hours * LABOR_RATE * count
        
        # Paint cost (if damage affects paint)
        paint_needed = damage_type.lower() in ["scratch", "dent", "broken"]
        paint_cost = PAINT_COST_PER_PANEL * count if paint_needed else 0
        
        total_parts_cost += parts_cost
        total_labor_cost += labor_cost
        total_paint_cost += paint_cost
        
        damage_details.append({
            "damage_type": damage_type,
            "count": count,
            "severity": severity,
            "parts_cost": parts_cost,
            "labor_cost": labor_cost,
            "paint_cost": paint_cost,
            "subtotal": parts_cost + labor_cost + paint_cost
        })
    
    # Calculate total estimate
    subtotal = total_parts_cost + total_labor_cost + total_paint_cost
    
    # Add contingency (10% for unexpected issues)
    contingency = subtotal * 0.10
    
    # Tax (if applicable - adjust based on your region)
    tax_rate = 0.00  # 0% for now, adjust if needed
    tax = subtotal * tax_rate
    
    total_estimate = subtotal + contingency + tax
    
    return {
        "breakdown": {
            "parts_cost": round(total_parts_cost, 2),
            "labor_cost": round(total_labor_cost, 2),
            "paint_cost": round(total_paint_cost, 2),
            "subtotal": round(subtotal, 2),
            "contingency": round(contingency, 2),
            "tax": round(tax, 2),
            "total": round(total_estimate, 2)
        },
        "damage_details": damage_details,
        "severity": severity
    }

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "service": "AVA Damage Detection & Cost Estimation",
        "version": "1.0.0",
        "endpoints": {
            "analyze": "/analyze - POST image for damage detection and cost",
            "estimate": "/estimate - POST with damage data for cost only"
        }
    })

@app.route("/analyze", methods=["POST"])
def analyze():
    """
    Complete damage analysis with cost estimation
    """
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image uploaded"}), 400
        
        file = request.files["image"]
        filepath = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(filepath)
        
        # Load image
        image = cv2.imread(filepath)
        height, width, _ = image.shape
        total_image_area = height * width
        
        # Run YOLO detection
        results = model(filepath)
        result = results[0]
        
        damage_area = 0
        damage_counts = {}
        detected_damages = []
        
        for box in result.boxes:
            cls_id = int(box.cls[0])
            class_name = model.names[cls_id]
            confidence = float(box.conf[0])
            
            x1, y1, x2, y2 = box.xyxy[0]
            area = float((x2 - x1) * (y2 - y1))
            damage_area += area
            
            # Count damage types
            if class_name in damage_counts:
                damage_counts[class_name] += 1
            else:
                damage_counts[class_name] = 1
            
            detected_damages.append({
                "type": class_name,
                "confidence": round(confidence * 100, 2),
                "bbox": [float(x1), float(y1), float(x2), float(y2)],
                "area": round(area, 2)
            })
        
        damage_percentage = (damage_area / total_image_area) * 100
        
        # Calculate cost estimate
        cost_estimate = estimate_repair_cost(
            damage_counts, 
            damage_percentage,
            damage_area
        )
        
        # Clean up uploaded file
        os.remove(filepath)
        
        return jsonify({
            "success": True,
            "analysis": {
                "damage_percentage": round(damage_percentage, 2),
                "total_damage_area": round(damage_area, 2),
                "total_image_area": total_image_area,
                "damage_counts": damage_counts,
                "detected_damages": detected_damages
            },
            "cost_estimate": cost_estimate,
            "currency": "LKR"
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route("/estimate", methods=["POST"])
def estimate_cost_only():
    """
    Calculate cost based on provided damage data
    (Without running image analysis)
    """
    try:
        data = request.get_json()
        
        damage_counts = data.get("damage_counts", {})
        damage_percentage = data.get("damage_percentage", 10)
        damage_area = data.get("damage_area", 0)
        
        cost_estimate = estimate_repair_cost(
            damage_counts,
            damage_percentage,
            damage_area
        )
        
        return jsonify({
            "success": True,
            "cost_estimate": cost_estimate,
            "currency": "LKR"
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == "__main__":
    print("🚀 Starting Damage Detection & Cost Estimation Service")
    print("📡 Service running on http://localhost:5002")
    print("💰 Currency: Sri Lankan Rupees (LKR)")
    app.run(debug=True, host='0.0.0.0', port=5002)