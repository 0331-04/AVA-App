# AVA Photo Quality Checker

## 📋 Overview

The AVA Photo Quality Checker is a comprehensive AI-powered image validation system designed for the AVA Insurance Claims platform. It automatically validates vehicle damage photos submitted by customers to ensure they meet quality standards required for accurate damage assessment and fraud detection.

## 🎯 Features

### Core Quality Checks

1. **Blur Detection**
   - Uses Laplacian variance to measure image sharpness
   - Detects out-of-focus or motion-blurred images
   - Minimum threshold: 100 (Laplacian variance)
   - Ideal threshold: 500+ (Laplacian variance)

2. **Brightness/Lighting Analysis**
   - Validates adequate lighting conditions
   - Detects underexposed (too dark) images
   - Detects overexposed (too bright) images
   - Ideal brightness range: 80-180 (on 0-255 scale)

3. **Resolution Validation**
   - Ensures sufficient image detail for damage analysis
   - Minimum resolution: 800x600 pixels
   - Recommended resolution: 1920x1080 pixels

4. **Angle/Orientation Check**
   - Detects severely tilted images
   - Uses edge detection and Hough transform
   - Maximum acceptable tilt: 15 degrees

5. **File Size Validation**
   - Minimum: 50 KB (prevents over-compressed images)
   - Maximum: 10 MB (reasonable file size limit)

### Quality Scoring System

Each image receives individual scores (0.0 to 1.0) for:
- Blur/Sharpness
- Brightness
- Angle/Orientation
- Resolution

**Overall Status Categories:**
- `EXCELLENT` (90%+ confidence, all scores ≥ 0.8)
- `GOOD` (75%+ confidence, all scores ≥ 0.6)
- `ACCEPTABLE` (50%+ confidence, all scores ≥ 0.4)
- `POOR` (below acceptable thresholds)
- `REJECTED` (critical failures)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     AVA Backend (Node.js)                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Express API Routes                       │  │
│  │  /api/quality/check-single                           │  │
│  │  /api/quality/check-batch                            │  │
│  │  /api/quality/validate-claim-photos                  │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │         Quality Integration Service                   │  │
│  │  - ImageQualityService class                         │  │
│  │  - Middleware for automatic validation               │  │
│  │  - Helper functions                                  │  │
│  └──────────────────┬───────────────────────────────────┘  │
└────────────────────│────────────────────────────────────────┘
                     │ HTTP Requests
                     │
┌────────────────────▼────────────────────────────────────────┐
│              Python Quality Service (Flask)                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Flask API Endpoints                      │  │
│  │  POST /api/v1/check-quality                          │  │
│  │  POST /api/v1/batch-check                            │  │
│  │  GET  /api/v1/quality-standards                      │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │                                        │
│  ┌──────────────────▼───────────────────────────────────┐  │
│  │        ImageQualityChecker (Core Logic)              │  │
│  │  - OpenCV for image processing                       │  │
│  │  - PIL for EXIF data                                 │  │
│  │  - NumPy for numerical operations                    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Installation

### Python Service

```bash
# Install Python dependencies
pip install -r requirements.txt

# Or install individually
pip install opencv-python opencv-contrib-python Pillow numpy Flask Flask-CORS
```

### Node.js Integration

```bash
# Install Node.js dependencies
npm install axios form-data multer express
```

## 📖 Usage

### 1. Start the Python Quality Service

```bash
python quality_api.py
```

The service will start on `http://localhost:5001`

### 2. Integrate with Node.js Backend

```javascript
const { ImageQualityService, imageQualityMiddleware } = require('./quality_integration');

// Create service instance
const qualityService = new ImageQualityService();

// Check single image
const result = await qualityService.checkImageQuality(imageBuffer, 'front');

console.log('Passed:', result.data.passed);
console.log('Status:', result.data.overall_status);
console.log('Confidence:', result.data.confidence);
```

### 3. Use Express Middleware

```javascript
const qualityRoutes = require('./quality_routes');

// Add routes to your Express app
app.use('/api/quality', qualityRoutes);

// Or use as middleware for automatic validation
app.post('/api/claims/submit', 
  upload.array('photos'),
  imageQualityMiddleware({ rejectOnFail: true }),
  claimController.submitClaim
);
```

## 🔌 API Endpoints

### Python Service

#### POST `/api/v1/check-quality`
Check quality of a single image.

**Request:**
```
Content-Type: multipart/form-data
file: <image file>
photo_type: <string> (optional)
```

**Response:**
```json
{
  "passed": true,
  "overall_status": "good",
  "confidence": 0.85,
  "scores": {
    "blur": 0.92,
    "brightness": 0.88,
    "angle": 0.95,
    "resolution": 1.0
  },
  "issues": [],
  "recommendations": []
}
```

#### POST `/api/v1/batch-check`
Check quality of multiple images.

**Request:**
```
Content-Type: multipart/form-data
files[]: <image file 1>
files[]: <image file 2>
...
```

**Response:**
```json
{
  "results": [
    { "passed": true, "overall_status": "good", ... },
    { "passed": false, "overall_status": "poor", ... }
  ],
  "summary": {
    "total_images": 5,
    "passed": 4,
    "failed": 1,
    "pass_rate": 80.0
  }
}
```

#### GET `/api/v1/quality-standards`
Get quality standards and thresholds.

### Node.js Backend

#### POST `/api/quality/check-single`
Check a single image through Node.js backend.

#### POST `/api/quality/check-batch`
Check multiple images.

#### POST `/api/quality/validate-claim-photos`
Validate all required photos for a claim submission.

**Request:**
```
Content-Type: multipart/form-data
photos[]: <image files>
photoTypes: ["front", "rear", "left", "right", "damage"]
```

**Response:**
```json
{
  "success": true,
  "message": "All photos passed quality validation",
  "validationResult": {
    "totalPhotos": 5,
    "passedPhotos": 5,
    "failedPhotos": 0,
    "allPassed": true,
    "results": [...]
  }
}
```

#### GET `/api/quality/standards`
Get quality standards and required photo types.

## 🧪 Testing

### Run Python Tests

```bash
# Run all tests
pytest test_quality_checker.py -v

# Run with coverage
pytest test_quality_checker.py -v --cov=image_quality_service

# Run specific test class
pytest test_quality_checker.py::TestImageQualityChecker -v
```

### Test with Sample Images

```python
from image_quality_service import check_vehicle_photo

# Read image
with open('vehicle_photo.jpg', 'rb') as f:
    image_data = f.read()

# Check quality
result = check_vehicle_photo(image_data)

print('Passed:', result['passed'])
print('Issues:', result['issues'])
print('Recommendations:', result['recommendations'])
```

## 📊 Quality Standards Summary

| Aspect | Minimum | Ideal | Scoring |
|--------|---------|-------|---------|
| **Resolution** | 800x600 | 1920x1080+ | Based on pixel dimensions |
| **Blur (Laplacian)** | 100 | 500+ | Higher = sharper |
| **Brightness** | 50-200 | 80-180 | Average pixel intensity |
| **Angle** | ±15° | 0° | Tilt detection |
| **File Size** | 50 KB | 100KB-5MB | Ensures quality |

## 🔧 Configuration

### Adjust Quality Thresholds

Edit `image_quality_service.py`:

```python
class ImageQualityChecker:
    MIN_RESOLUTION = (800, 600)  # Change minimum resolution
    MIN_BLUR_THRESHOLD = 100      # Change blur threshold
    MIN_BRIGHTNESS = 50           # Change brightness range
    MAX_BRIGHTNESS = 200
    # ... etc
```

### Change Service Port

Edit `quality_api.py`:

```python
app.run(
    host='0.0.0.0',
    port=5001,  # Change port here
    debug=True
)
```

## 🐛 Common Issues & Solutions

### Issue: "Service unavailable"
**Solution:** Ensure Python service is running on port 5001
```bash
python quality_api.py
```

### Issue: "Out of memory"
**Solution:** Large images consume memory. Consider:
- Limiting upload file size
- Processing images in batches
- Using image resizing before analysis

### Issue: False positives for good images
**Solution:** Adjust thresholds in `ImageQualityChecker` class based on your specific requirements

### Issue: HEIC images not supported
**Solution:** Convert HEIC to JPEG before processing:
```bash
pip install pillow-heif
```

## 📈 Performance

- **Single image check:** ~200-500ms (depending on resolution)
- **Batch processing:** ~300-800ms per image
- **Memory usage:** ~50-200MB per image (varies with resolution)
- **Concurrent requests:** Up to 10 simultaneous checks recommended

## 🔐 Security Considerations

1. **File Size Limits:** Enforced at 10MB to prevent DoS
2. **File Type Validation:** Only image MIME types accepted
3. **Input Sanitization:** All inputs validated and sanitized
4. **Temporary Storage:** Uploaded files stored in memory, not disk
5. **No Data Retention:** Images not persisted after analysis

## 🚦 Integration Checklist

- [ ] Python service running on port 5001
- [ ] Node.js dependencies installed
- [ ] Quality routes added to Express app
- [ ] Environment variables configured
- [ ] Error handling implemented
- [ ] Logging configured
- [ ] Tests passing
- [ ] API endpoints tested with Postman/curl

## 📞 Support & Contribution

For issues, feature requests, or contributions:
- Create an issue in the project repository
- Follow the contribution guidelines
- Ensure tests pass before submitting PRs

## 📄 License

Part of the AVA Insurance Claims System
© 2025 AVA-SE-28 Team

---

**Version:** 1.0.0  
**Last Updated:** February 2025  
**Maintained by:** AVA Development Team