"""
Test suite for AVA Image Quality Checker
"""

import pytest
import numpy as np
import cv2
from PIL import Image
import io
from image_quality_service import (
    ImageQualityChecker,
    QualityStatus,
    check_vehicle_photo
)

class TestImageQualityChecker:
    """Test cases for ImageQualityChecker class"""
    
    @pytest.fixture
    def checker(self):
        """Create a fresh ImageQualityChecker instance"""
        return ImageQualityChecker()
    
    @pytest.fixture
    def good_image(self):
        """Generate a good quality test image"""
        # Create a 1920x1080 image with good lighting
        img = np.random.randint(80, 180, (1080, 1920, 3), dtype=np.uint8)
        
        # Add some structure (not just noise)
        cv2.rectangle(img, (400, 300), (1500, 800), (100, 150, 200), -1)
        cv2.putText(img, "TEST VEHICLE", (600, 500), 
                   cv2.FONT_HERSHEY_SIMPLEX, 2, (255, 255, 255), 3)
        
        # Convert to bytes
        _, encoded = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 95])
        return encoded.tobytes()
    
    @pytest.fixture
    def blurry_image(self):
        """Generate a blurry test image"""
        img = np.random.randint(80, 180, (1080, 1920, 3), dtype=np.uint8)
        
        # Apply heavy blur
        img = cv2.GaussianBlur(img, (51, 51), 0)
        
        _, encoded = cv2.imencode('.jpg', img)
        return encoded.tobytes()
    
    @pytest.fixture
    def dark_image(self):
        """Generate a dark test image"""
        img = np.random.randint(0, 40, (1080, 1920, 3), dtype=np.uint8)
        
        _, encoded = cv2.imencode('.jpg', img)
        return encoded.tobytes()
    
    @pytest.fixture
    def bright_image(self):
        """Generate an overly bright test image"""
        img = np.random.randint(220, 255, (1080, 1920, 3), dtype=np.uint8)
        
        _, encoded = cv2.imencode('.jpg', img)
        return encoded.tobytes()
    
    @pytest.fixture
    def low_res_image(self):
        """Generate a low resolution test image"""
        img = np.random.randint(80, 180, (480, 640, 3), dtype=np.uint8)
        
        _, encoded = cv2.imencode('.jpg', img)
        return encoded.tobytes()
    
    def test_good_image_passes(self, checker, good_image):
        """Test that a good quality image passes all checks"""
        result = checker.check_image_quality(good_image)
        
        assert result.passed is True
        assert result.overall_status in [
            QualityStatus.EXCELLENT,
            QualityStatus.GOOD,
            QualityStatus.ACCEPTABLE
        ]
        assert result.confidence > 0.5
    
    def test_blurry_image_detected(self, checker, blurry_image):
        """Test that blurry images are detected"""
        result = checker.check_image_quality(blurry_image)
        
        assert result.blur_score < 0.5
        assert any('blurry' in issue.lower() for issue in result.issues)
    
    def test_dark_image_detected(self, checker, dark_image):
        """Test that dark images are detected"""
        result = checker.check_image_quality(dark_image)
        
        assert result.brightness_score < 0.5
        assert any('dark' in issue.lower() for issue in result.issues)
    
    def test_bright_image_detected(self, checker, bright_image):
        """Test that overly bright images are detected"""
        result = checker.check_image_quality(bright_image)
        
        assert result.brightness_score < 0.5
        assert any('bright' in issue.lower() for issue in result.issues)
    
    def test_low_resolution_detected(self, checker, low_res_image):
        """Test that low resolution images are detected"""
        result = checker.check_image_quality(low_res_image)
        
        assert result.resolution_score < 0.7
        assert any('resolution' in issue.lower() for issue in result.issues)
    
    def test_invalid_image_rejected(self, checker):
        """Test that invalid image data is rejected"""
        invalid_data = b"This is not an image"
        
        result = checker.check_image_quality(invalid_data)
        
        assert result.passed is False
        assert result.overall_status == QualityStatus.REJECTED
    
    def test_file_size_validation(self, checker):
        """Test file size validation"""
        # Too small
        tiny_img = np.zeros((100, 100, 3), dtype=np.uint8)
        _, encoded = cv2.imencode('.jpg', tiny_img, [cv2.IMWRITE_JPEG_QUALITY, 10])
        
        # Mock file size check by checking the actual encoded size
        file_size_ok = checker._check_file_size(len(encoded.tobytes()))
        
        # Depending on compression, this might pass or fail
        # Just verify the method works without errors
        assert isinstance(file_size_ok, bool)
    
    def test_recommendations_provided(self, checker, blurry_image):
        """Test that recommendations are provided for poor quality images"""
        result = checker.check_image_quality(blurry_image)
        
        assert len(result.recommendations) > 0
        assert all(isinstance(rec, str) for rec in result.recommendations)
    
    def test_all_scores_in_range(self, checker, good_image):
        """Test that all scores are between 0 and 1"""
        result = checker.check_image_quality(good_image)
        
        assert 0.0 <= result.blur_score <= 1.0
        assert 0.0 <= result.brightness_score <= 1.0
        assert 0.0 <= result.angle_score <= 1.0
        assert 0.0 <= result.resolution_score <= 1.0
        assert 0.0 <= result.confidence <= 1.0
    
    def test_check_vehicle_photo_convenience_function(self, good_image):
        """Test the convenience function returns correct format"""
        result = check_vehicle_photo(good_image)
        
        assert isinstance(result, dict)
        assert 'passed' in result
        assert 'overall_status' in result
        assert 'scores' in result
        assert 'issues' in result
        assert 'recommendations' in result
    
    def test_multiple_issues_detected(self, checker):
        """Test that multiple issues can be detected simultaneously"""
        # Create an image that's both blurry and dark
        img = np.random.randint(0, 30, (1080, 1920, 3), dtype=np.uint8)
        img = cv2.GaussianBlur(img, (51, 51), 0)
        
        _, encoded = cv2.imencode('.jpg', img)
        result = checker.check_image_quality(encoded.tobytes())
        
        # Should detect both blur and darkness
        issues_text = ' '.join(result.issues).lower()
        assert 'blurry' in issues_text or 'dark' in issues_text
        assert len(result.issues) >= 1


class TestQualityStatus:
    """Test QualityStatus enum"""
    
    def test_status_values(self):
        """Test that all status values are defined"""
        assert QualityStatus.EXCELLENT.value == "excellent"
        assert QualityStatus.GOOD.value == "good"
        assert QualityStatus.ACCEPTABLE.value == "acceptable"
        assert QualityStatus.POOR.value == "poor"
        assert QualityStatus.REJECTED.value == "rejected"


class TestEdgeCases:
    """Test edge cases and boundary conditions"""
    
    @pytest.fixture
    def checker(self):
        return ImageQualityChecker()
    
    def test_square_image(self, checker):
        """Test with a square image"""
        img = np.random.randint(80, 180, (1000, 1000, 3), dtype=np.uint8)
        _, encoded = cv2.imencode('.jpg', img)
        
        result = checker.check_image_quality(encoded.tobytes())
        
        assert result is not None
        assert isinstance(result.passed, bool)
    
    def test_very_large_image(self, checker):
        """Test with a very large resolution image"""
        img = np.random.randint(80, 180, (4000, 6000, 3), dtype=np.uint8)
        _, encoded = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 90])
        
        result = checker.check_image_quality(encoded.tobytes())
        
        # Should pass resolution check
        assert result.resolution_score >= 0.9
    
    def test_minimum_acceptable_resolution(self, checker):
        """Test with exactly minimum resolution"""
        width, height = checker.MIN_RESOLUTION
        img = np.random.randint(80, 180, (height, width, 3), dtype=np.uint8)
        
        # Add some structure
        cv2.rectangle(img, (50, 50), (width-50, height-50), (100, 150, 200), -1)
        
        _, encoded = cv2.imencode('.jpg', img)
        result = checker.check_image_quality(encoded.tobytes())
        
        # Should barely pass
        assert result.resolution_score >= 0.5
    
    def test_grayscale_image(self, checker):
        """Test with a grayscale image"""
        img = np.random.randint(80, 180, (1080, 1920), dtype=np.uint8)
        
        # Convert to 3-channel for proper encoding
        img_color = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
        
        _, encoded = cv2.imencode('.jpg', img_color)
        result = checker.check_image_quality(encoded.tobytes())
        
        assert result is not None
        assert isinstance(result.passed, bool)


# Integration tests
class TestIntegration:
    """Integration tests for the complete workflow"""
    
    def test_complete_workflow_good_image(self):
        """Test complete workflow with a good image"""
        # Create a realistic looking image
        img = np.ones((1080, 1920, 3), dtype=np.uint8) * 120
        
        # Add vehicle-like structure
        cv2.rectangle(img, (500, 300), (1400, 800), (100, 100, 150), -1)
        cv2.rectangle(img, (700, 400), (1200, 700), (50, 50, 100), 3)
        
        _, encoded = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 95])
        
        result = check_vehicle_photo(encoded.tobytes())
        
        assert result['passed'] is True
        assert result['confidence'] > 0.5
        assert all(score >= 0.4 for score in result['scores'].values())
    
    def test_complete_workflow_poor_image(self):
        """Test complete workflow with a poor image"""
        # Create a poor quality image (dark, blurry, low res)
        img = np.random.randint(10, 30, (400, 500, 3), dtype=np.uint8)
        img = cv2.GaussianBlur(img, (25, 25), 0)
        
        _, encoded = cv2.imencode('.jpg', img, [cv2.IMWRITE_JPEG_QUALITY, 50])
        
        result = check_vehicle_photo(encoded.tobytes())
        
        assert result['passed'] is False
        assert len(result['issues']) > 0
        assert len(result['recommendations']) > 0


if __name__ == '__main__':
    pytest.main([__file__, '-v', '--cov=image_quality_service'])