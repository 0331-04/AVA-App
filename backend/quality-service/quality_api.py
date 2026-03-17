"""
AVA Image Quality Checker
Validates uploaded vehicle damage photos for quality standards
"""

import cv2
import numpy as np
from PIL import Image, ExifTags
import io
from typing import Dict, Tuple, Optional
from dataclasses import dataclass
from enum import Enum

class QualityStatus(Enum):
    EXCELLENT = "excellent"
    GOOD = "good"
    ACCEPTABLE = "acceptable"
    POOR = "poor"
    REJECTED = "rejected"

@dataclass
class QualityCheckResult:
    """Result of image quality validation"""
    overall_status: QualityStatus
    blur_score: float
    brightness_score: float
    angle_score: float
    resolution_score: float
    issues: list
    recommendations: list
    passed: bool
    confidence: float

class ImageQualityChecker:
    """Main class for validating vehicle damage photos"""
    
    # Quality thresholds
    MIN_RESOLUTION = (800, 600)  # Minimum width x height
    RECOMMENDED_RESOLUTION = (1920, 1080)
    MIN_BLUR_THRESHOLD = 100  # Laplacian variance threshold
    IDEAL_BLUR_THRESHOLD = 500
    MIN_BRIGHTNESS = 50
    MAX_BRIGHTNESS = 200
    IDEAL_BRIGHTNESS_RANGE = (80, 180)
    MAX_TILT_ANGLE = 15  # degrees
    MIN_FILE_SIZE = 50 * 1024  # 50 KB
    MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
    
    def __init__(self):
        self.issues = []
        self.recommendations = []
    
    def check_image_quality(self, image_data: bytes) -> QualityCheckResult:
        """
        Main method to check all quality aspects of an image
        
        Args:
            image_data: Raw bytes of the image
            
        Returns:
            QualityCheckResult with detailed analysis
        """
        self.issues = []
        self.recommendations = []
        
        try:
            # Convert bytes to numpy array
            nparr = np.frombuffer(image_data, np.uint8)
            img_cv = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if img_cv is None:
                raise ValueError("Invalid image format")
            
            # Convert to PIL Image for EXIF data
            img_pil = Image.open(io.BytesIO(image_data))
            
            # Run all quality checks
            blur_score = self._check_blur(img_cv)
            brightness_score = self._check_brightness(img_cv)
            angle_score = self._check_angle(img_pil)
            resolution_score = self._check_resolution(img_cv)
            file_size_ok = self._check_file_size(len(image_data))
            
            # Calculate overall quality
            scores = [blur_score, brightness_score, angle_score, resolution_score]
            avg_score = np.mean(scores)
            
            # Determine overall status
            overall_status = self._determine_status(avg_score, scores)
            
            # Determine if passed
            passed = (
                overall_status not in [QualityStatus.REJECTED] and
                blur_score >= 0.4 and
                brightness_score >= 0.5 and
                file_size_ok
            )
            
            return QualityCheckResult(
                overall_status=overall_status,
                blur_score=blur_score,
                brightness_score=brightness_score,
                angle_score=angle_score,
                resolution_score=resolution_score,
                issues=self.issues.copy(),
                recommendations=self.recommendations.copy(),
                passed=passed,
                confidence=avg_score
            )
            
        except Exception as e:
            self.issues.append(f"Error processing image: {str(e)}")
            return QualityCheckResult(
                overall_status=QualityStatus.REJECTED,
                blur_score=0.0,
                brightness_score=0.0,
                angle_score=0.0,
                resolution_score=0.0,
                issues=self.issues.copy(),
                recommendations=["Please upload a valid image file"],
                passed=False,
                confidence=0.0
            )
    
    def _check_blur(self, img: np.ndarray) -> float:
        """
        Check image sharpness using Laplacian variance
        
        Returns:
            Score from 0.0 (very blurry) to 1.0 (very sharp)
        """
        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Calculate Laplacian variance
        laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
        
        # Normalize score
        if laplacian_var < self.MIN_BLUR_THRESHOLD:
            score = 0.0
            self.issues.append(f"Image is too blurry (sharpness: {laplacian_var:.1f})")
            self.recommendations.append("Hold the camera steady and ensure good focus")
        elif laplacian_var < self.IDEAL_BLUR_THRESHOLD:
            score = (laplacian_var - self.MIN_BLUR_THRESHOLD) / (self.IDEAL_BLUR_THRESHOLD - self.MIN_BLUR_THRESHOLD)
            score = min(score, 1.0) * 0.8  # Cap at 0.8 for acceptable range
            self.recommendations.append("Image sharpness is acceptable but could be improved")
        else:
            score = 1.0
        
        return score
    
    def _check_brightness(self, img: np.ndarray) -> float:
        """
        Check if image has adequate lighting
        
        Returns:
            Score from 0.0 (too dark/bright) to 1.0 (ideal lighting)
        """
        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Calculate average brightness
        avg_brightness = np.mean(gray)
        
        # Check if too dark
        if avg_brightness < self.MIN_BRIGHTNESS:
            score = avg_brightness / self.MIN_BRIGHTNESS * 0.3
            self.issues.append(f"Image is too dark (brightness: {avg_brightness:.1f})")
            self.recommendations.append("Use more lighting or increase camera exposure")
        
        # Check if too bright
        elif avg_brightness > self.MAX_BRIGHTNESS:
            score = (255 - avg_brightness) / (255 - self.MAX_BRIGHTNESS) * 0.3
            self.issues.append(f"Image is too bright (brightness: {avg_brightness:.1f})")
            self.recommendations.append("Reduce lighting or decrease camera exposure")
        
        # Check if in ideal range
        elif self.IDEAL_BRIGHTNESS_RANGE[0] <= avg_brightness <= self.IDEAL_BRIGHTNESS_RANGE[1]:
            score = 1.0
        
        # In acceptable range
        else:
            if avg_brightness < self.IDEAL_BRIGHTNESS_RANGE[0]:
                score = 0.5 + (avg_brightness - self.MIN_BRIGHTNESS) / (self.IDEAL_BRIGHTNESS_RANGE[0] - self.MIN_BRIGHTNESS) * 0.5
            else:
                score = 0.5 + (self.MAX_BRIGHTNESS - avg_brightness) / (self.MAX_BRIGHTNESS - self.IDEAL_BRIGHTNESS_RANGE[1]) * 0.5
            
            self.recommendations.append("Lighting is acceptable but could be improved")
        
        # Check for overexposed/underexposed regions
        overexposed = np.sum(gray > 240) / gray.size
        underexposed = np.sum(gray < 20) / gray.size
        
        if overexposed > 0.1:
            score *= 0.8
            self.issues.append(f"{overexposed*100:.1f}% of image is overexposed")
        
        if underexposed > 0.1:
            score *= 0.8
            self.issues.append(f"{underexposed*100:.1f}% of image is underexposed")
        
        return max(score, 0.0)
    
    def _check_angle(self, img: Image.Image) -> float:
        """
        Check if image is properly oriented (not tilted)
        
        Returns:
            Score from 0.0 (severely tilted) to 1.0 (properly aligned)
        """
        try:
            # Get EXIF orientation
            exif = img._getexif()
            if exif is not None:
                for tag, value in exif.items():
                    if ExifTags.TAGS.get(tag) == 'Orientation':
                        if value not in [1, 0]:  # 1 is normal orientation
                            self.issues.append("Image orientation needs correction")
                            return 0.7
            
            # Convert to OpenCV format for edge detection
            img_cv = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
            gray = cv2.cvtColor(img_cv, cv2.COLOR_BGR2GRAY)
            
            # Detect edges
            edges = cv2.Canny(gray, 50, 150, apertureSize=3)
            
            # Detect lines using Hough transform
            lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)
            
            if lines is not None:
                angles = []
                for rho, theta in lines[:10]:  # Check first 10 lines
                    angle = np.degrees(theta)
                    # Normalize to -90 to 90
                    if angle > 90:
                        angle = angle - 180
                    angles.append(abs(angle))
                
                # Calculate average tilt
                avg_tilt = np.mean(angles)
                
                if avg_tilt > self.MAX_TILT_ANGLE:
                    score = max(0.3, 1.0 - (avg_tilt - self.MAX_TILT_ANGLE) / 45)
                    self.issues.append(f"Image is tilted by approximately {avg_tilt:.1f}°")
                    self.recommendations.append("Hold the camera level with the vehicle")
                    return score
            
            return 1.0
            
        except Exception as e:
            # If we can't determine angle, assume it's acceptable
            return 0.8
    
    def _check_resolution(self, img: np.ndarray) -> float:
        """
        Check if image has adequate resolution
        
        Returns:
            Score from 0.0 (too low resolution) to 1.0 (excellent resolution)
        """
        height, width = img.shape[:2]
        
        # Check minimum resolution
        if width < self.MIN_RESOLUTION[0] or height < self.MIN_RESOLUTION[1]:
            score = min(width / self.MIN_RESOLUTION[0], height / self.MIN_RESOLUTION[1])
            self.issues.append(f"Resolution too low: {width}x{height}")
            self.recommendations.append(f"Use a camera with at least {self.MIN_RESOLUTION[0]}x{self.MIN_RESOLUTION[1]} resolution")
            return score * 0.5
        
        # Check if meets recommended resolution
        elif width >= self.RECOMMENDED_RESOLUTION[0] and height >= self.RECOMMENDED_RESOLUTION[1]:
            return 1.0
        
        # In acceptable range
        else:
            score = 0.7 + min(
                (width - self.MIN_RESOLUTION[0]) / (self.RECOMMENDED_RESOLUTION[0] - self.MIN_RESOLUTION[0]),
                (height - self.MIN_RESOLUTION[1]) / (self.RECOMMENDED_RESOLUTION[1] - self.MIN_RESOLUTION[1])
            ) * 0.3
            return score
    
    def _check_file_size(self, file_size: int) -> bool:
        """
        Check if file size is within acceptable range
        
        Returns:
            True if file size is acceptable
        """
        if file_size < self.MIN_FILE_SIZE:
            self.issues.append(f"File size too small: {file_size / 1024:.1f} KB")
            self.recommendations.append("Image may be too compressed. Use higher quality settings")
            return False
        
        if file_size > self.MAX_FILE_SIZE:
            self.issues.append(f"File size too large: {file_size / (1024*1024):.1f} MB")
            self.recommendations.append("Reduce image size before uploading")
            return False
        
        return True
    
    def _determine_status(self, avg_score: float, scores: list) -> QualityStatus:
        """Determine overall quality status based on scores"""
        min_score = min(scores)
        
        if min_score < 0.3 or avg_score < 0.4:
            return QualityStatus.REJECTED
        elif avg_score >= 0.9 and min_score >= 0.8:
            return QualityStatus.EXCELLENT
        elif avg_score >= 0.75 and min_score >= 0.6:
            return QualityStatus.GOOD
        elif avg_score >= 0.5 and min_score >= 0.4:
            return QualityStatus.ACCEPTABLE
        else:
            return QualityStatus.POOR


def check_vehicle_photo(image_data: bytes) -> Dict:
    """
    Convenience function to check vehicle photo quality
    
    Args:
        image_data: Raw bytes of the image
        
    Returns:
        Dictionary with quality check results
    """
    checker = ImageQualityChecker()
    result = checker.check_image_quality(image_data)
    
    return {
        "passed": result.passed,
        "overall_status": result.overall_status.value,
        "confidence": round(result.confidence, 2),
        "scores": {
            "blur": round(result.blur_score, 2),
            "brightness": round(result.brightness_score, 2),
            "angle": round(result.angle_score, 2),
            "resolution": round(result.resolution_score, 2)
        },
        "issues": result.issues,
        "recommendations": result.recommendations
    }


# Example usage
if __name__ == "__main__":
    # Test with a sample image
    try:
        with open("sample_vehicle.jpg", "rb") as f:
            image_data = f.read()
        
        result = check_vehicle_photo(image_data)
        
        print("=" * 60)
        print("AVA IMAGE QUALITY CHECK RESULTS")
        print("=" * 60)
        print(f"Status: {result['overall_status'].upper()}")
        print(f"Passed: {'✓ YES' if result['passed'] else '✗ NO'}")
        print(f"Confidence: {result['confidence']*100:.1f}%")
        print("\nScores:")
        print(f"  Blur/Sharpness: {result['scores']['blur']*100:.1f}%")
        print(f"  Brightness:     {result['scores']['brightness']*100:.1f}%")
        print(f"  Angle:          {result['scores']['angle']*100:.1f}%")
        print(f"  Resolution:     {result['scores']['resolution']*100:.1f}%")
        
        if result['issues']:
            print("\nIssues Found:")
            for issue in result['issues']:
                print(f"  • {issue}")
        
        if result['recommendations']:
            print("\nRecommendations:")
            for rec in result['recommendations']:
                print(f"  • {rec}")
        
        print("=" * 60)
        
    except FileNotFoundError:
        print("Please provide a sample_vehicle.jpg file to test")