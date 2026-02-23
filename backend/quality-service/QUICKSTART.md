# AVA Photo Quality Checker - Quick Start Guide

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Python 3.8+ installed
- Node.js 14+ installed (for backend integration)
- pip and npm package managers

### Step 1: Install Python Dependencies

```bash
# Install required packages
pip install opencv-python Pillow numpy Flask Flask-CORS

# Or use requirements.txt
pip install -r requirements.txt
```

### Step 2: Start the Quality Service

```bash
# Start the Flask service
python quality_api.py
```

You should see:
```
 * Running on http://0.0.0.0:5001
AVA Image Quality Service Starting...
```

### Step 3: Test with curl

```bash
# Test health endpoint
curl http://localhost:5001/health

# Test with an image
curl -X POST \
  http://localhost:5001/api/v1/check-quality \
  -F "file=@path/to/your/image.jpg" \
  -F "photo_type=front"
```

### Step 4: Integrate with Node.js (Optional)

```javascript
// In your Express app
const qualityRoutes = require('./quality_routes');
app.use('/api/quality', qualityRoutes);

// Start your backend
npm start
```

---

## 📱 Usage Examples

### Python Direct Usage

```python
from image_quality_service import check_vehicle_photo

# Read image
with open('vehicle.jpg', 'rb') as f:
    image_data = f.read()

# Check quality
result = check_vehicle_photo(image_data)

if result['passed']:
    print("✓ Photo quality is acceptable")
else:
    print("✗ Photo quality check failed:")
    for issue in result['issues']:
        print(f"  - {issue}")
```

### Node.js Integration

```javascript
const { ImageQualityService } = require('./quality_integration');

const qualityService = new ImageQualityService();

// Check image quality
const result = await qualityService.checkImageQuality(
    req.file.buffer,
    'front'
);

if (result.data.passed) {
    // Proceed with claim submission
    await submitClaim(claimData);
} else {
    // Return error to user
    res.status(400).json({
        error: 'Photo quality insufficient',
        issues: result.data.issues
    });
}
```

### Express Middleware

```javascript
const { imageQualityMiddleware } = require('./quality_integration');

router.post('/submit-claim',
    upload.array('photos'),
    imageQualityMiddleware({ rejectOnFail: true }),
    async (req, res) => {
        // All photos have passed quality check
        // req.qualityChecks contains the results
        
        const claim = await createClaim({
            photos: req.files,
            qualityScores: req.qualityChecks
        });
        
        res.json({ success: true, claimId: claim.id });
    }
);
```

---

## 🔧 Configuration

### Adjust Quality Thresholds

Edit `image_quality_service.py`:

```python
class ImageQualityChecker:
    # Customize these values
    MIN_RESOLUTION = (1024, 768)  # Require higher resolution
    MIN_BLUR_THRESHOLD = 150       # Be more strict about blur
    MIN_BRIGHTNESS = 60            # Adjust brightness range
    MAX_BRIGHTNESS = 190
```

### Environment Variables

Create `.env` file:

```bash
FLASK_PORT=5001
QUALITY_SERVICE_URL=http://localhost:5001
MAX_UPLOAD_SIZE_MB=10
LOG_LEVEL=INFO
```

---

## 🐳 Docker Deployment

### Build and Run

```bash
# Build image
docker build -t ava-quality-service .

# Run container
docker run -p 5001:5001 ava-quality-service
```

### Using Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f quality-service

# Stop services
docker-compose down
```

---

## 📊 API Response Format

### Success Response

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
  "recommendations": [],
  "metadata": {
    "filename": "vehicle_front.jpg",
    "file_size": 2458320,
    "photo_type": "front"
  }
}
```

### Failure Response

```json
{
  "passed": false,
  "overall_status": "poor",
  "confidence": 0.35,
  "scores": {
    "blur": 0.25,
    "brightness": 0.45,
    "angle": 0.80,
    "resolution": 0.90
  },
  "issues": [
    "Image is too blurry (sharpness: 85.3)",
    "Image is too dark (brightness: 42.1)"
  ],
  "recommendations": [
    "Hold the camera steady and ensure good focus",
    "Use more lighting or increase camera exposure"
  ]
}
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
pytest test_quality_checker.py -v

# Run with coverage
pytest test_quality_checker.py --cov=image_quality_service --cov-report=html

# Run specific test
pytest test_quality_checker.py::TestImageQualityChecker::test_good_image_passes -v
```

### Test with Sample Images

```bash
# Run example script
python example_usage.py

# Test with curl
curl -X POST \
  http://localhost:5001/api/v1/check-quality \
  -F "file=@sample_vehicle.jpg" \
  -F "photo_type=front"
```

### Import Postman Collection

1. Open Postman
2. Click "Import"
3. Select `AVA_Quality_API.postman_collection.json`
4. Update `base_url` variable to your service URL
5. Run requests

---

## 🐛 Troubleshooting

### Service Won't Start

**Error:** `Address already in use`

**Solution:**
```bash
# Find process using port 5001
lsof -i :5001

# Kill the process
kill -9 <PID>

# Or change port in quality_api.py
app.run(port=5002)
```

### OpenCV Import Error

**Error:** `ImportError: libGL.so.1: cannot open shared object file`

**Solution (Linux):**
```bash
apt-get install libgl1-mesa-glx
```

**Solution (Mac):**
```bash
brew install opencv
```

### Memory Issues with Large Images

**Solution:** Add image resizing before processing:

```python
# In image_quality_service.py
def _preprocess_image(self, img):
    max_dimension = 2000
    height, width = img.shape[:2]
    
    if max(height, width) > max_dimension:
        scale = max_dimension / max(height, width)
        new_width = int(width * scale)
        new_height = int(height * scale)
        img = cv2.resize(img, (new_width, new_height))
    
    return img
```

### Integration Test Failures

**Issue:** Node.js can't connect to Python service

**Solution:**
1. Check Python service is running: `curl http://localhost:5001/health`
2. Check firewall settings
3. Verify QUALITY_SERVICE_URL environment variable
4. Check Docker network if using containers

---

## 📈 Performance Optimization

### Enable Response Caching

```python
# Add Redis caching for repeated checks
from flask_caching import Cache

cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/0'
})

@app.route('/api/v1/check-quality', methods=['POST'])
@cache.cached(timeout=3600, key_prefix='quality_check')
def check_quality():
    # ... existing code ...
```

### Process Images in Parallel

```python
from concurrent.futures import ThreadPoolExecutor

def process_batch(images):
    with ThreadPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(check_image_quality, images))
    return results
```

### Use Image Resizing

Large images can be resized before processing without losing quality assessment accuracy:

```python
MAX_DIMENSION = 1920  # Resize images larger than this
```

---

## 🔐 Security Best Practices

1. **Rate Limiting:** Implement rate limiting to prevent abuse
2. **Authentication:** Add API key authentication for production
3. **Input Validation:** Validate all file uploads
4. **CORS:** Configure appropriate CORS origins
5. **HTTPS:** Use HTTPS in production
6. **File Size Limits:** Enforce maximum upload sizes
7. **Temp File Cleanup:** Ensure temporary files are deleted

---

## 📞 Next Steps

- [ ] Integrate with your Claims API
- [ ] Add to mobile app photo capture flow
- [ ] Setup monitoring and alerting
- [ ] Configure production environment
- [ ] Train team on quality standards
- [ ] Create user documentation
- [ ] Setup CI/CD pipeline

---

## 💡 Tips for Best Results

1. **Educate Users:** Show examples of good vs bad photos
2. **Real-time Feedback:** Integrate with camera preview
3. **Progressive Enhancement:** Start with basic checks, add more
4. **Monitor Quality:** Track pass rates and adjust thresholds
5. **User Feedback Loop:** Learn from user-reported issues
6. **A/B Testing:** Test different threshold values

---

## 📚 Additional Resources

- [OpenCV Documentation](https://docs.opencv.org/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Image Processing Best Practices](https://docs.opencv.org/master/)
- [AVA Full Documentation](./README_QUALITY_CHECKER.md)



