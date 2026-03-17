#!/usr/bin/env python3
"""
Example usage script for AVA Image Quality Checker
Demonstrates how to use the service with sample images
"""

import requests
import os
from pathlib import Path

# Configuration
QUALITY_SERVICE_URL = "http://localhost:5001"

def check_single_image(image_path, photo_type="general"):
    """
    Example: Check quality of a single image
    """
    print(f"\n{'='*60}")
    print(f"Checking: {os.path.basename(image_path)}")
    print(f"Photo Type: {photo_type}")
    print('='*60)
    
    url = f"{QUALITY_SERVICE_URL}/api/v1/check-quality"
    
    with open(image_path, 'rb') as f:
        files = {'file': f}
        data = {'photo_type': photo_type}
        
        response = requests.post(url, files=files, data=data)
    
    if response.status_code == 200:
        result = response.json()
        
        print(f"\n✓ Status: {result['overall_status'].upper()}")
        print(f"✓ Passed: {'YES' if result['passed'] else 'NO'}")
        print(f"✓ Confidence: {result['confidence']*100:.1f}%")
        
        print("\nScores:")
        for score_name, score_value in result['scores'].items():
            bar = '█' * int(score_value * 20)
            print(f"  {score_name:12}: [{bar:20}] {score_value*100:.1f}%")
        
        if result['issues']:
            print("\n⚠ Issues Found:")
            for issue in result['issues']:
                print(f"  • {issue}")
        
        if result['recommendations']:
            print("\n💡 Recommendations:")
            for rec in result['recommendations']:
                print(f"  • {rec}")
        
        return result
    else:
        print(f"\n✗ Error: {response.status_code}")
        print(response.json())
        return None

def check_batch_images(image_paths):
    """
    Example: Check multiple images at once
    """
    print(f"\n{'='*60}")
    print(f"Batch Check: {len(image_paths)} images")
    print('='*60)
    
    url = f"{QUALITY_SERVICE_URL}/api/v1/batch-check"
    
    files = []
    for image_path in image_paths:
        with open(image_path, 'rb') as f:
            files.append(('files[]', (os.path.basename(image_path), f.read(), 'image/jpeg')))
    
    response = requests.post(url, files=files)
    
    if response.status_code == 200:
        result = response.json()
        
        print(f"\nSummary:")
        print(f"  Total: {result['summary']['total_images']}")
        print(f"  Passed: {result['summary']['passed']}")
        print(f"  Failed: {result['summary']['failed']}")
        print(f"  Pass Rate: {result['summary']['pass_rate']}%")
        
        print("\nIndividual Results:")
        for i, res in enumerate(result['results'], 1):
            status_icon = '✓' if res.get('passed') else '✗'
            print(f"  {status_icon} Image {i}: {res.get('overall_status', 'error')} "
                  f"(confidence: {res.get('confidence', 0)*100:.1f}%)")
        
        return result
    else:
        print(f"\n✗ Error: {response.status_code}")
        print(response.json())
        return None

def get_quality_standards():
    """
    Example: Get quality standards
    """
    print(f"\n{'='*60}")
    print("Quality Standards")
    print('='*60)
    
    url = f"{QUALITY_SERVICE_URL}/api/v1/quality-standards"
    response = requests.get(url)
    
    if response.status_code == 200:
        standards = response.json()['standards']
        
        print("\nResolution:")
        print(f"  Minimum: {standards['resolution']['minimum']}")
        print(f"  Recommended: {standards['resolution']['recommended']}")
        
        print("\nBlur Thresholds:")
        print(f"  Minimum: {standards['blur']['minimum_threshold']}")
        print(f"  Ideal: {standards['blur']['ideal_threshold']}")
        
        print("\nBrightness:")
        print(f"  Range: {standards['brightness']['minimum']}-{standards['brightness']['maximum']}")
        print(f"  Ideal: {standards['brightness']['ideal_range']['min']}-"
              f"{standards['brightness']['ideal_range']['max']}")
        
        print("\nFile Size:")
        print(f"  Minimum: {standards['file_size']['minimum_kb']} KB")
        print(f"  Maximum: {standards['file_size']['maximum_mb']} MB")
        
        return standards
    else:
        print(f"\n✗ Error: {response.status_code}")
        return None

def health_check():
    """
    Example: Check service health
    """
    print(f"\n{'='*60}")
    print("Health Check")
    print('='*60)
    
    url = f"{QUALITY_SERVICE_URL}/health"
    
    try:
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            health = response.json()
            print(f"\n✓ Service: {health['service']}")
            print(f"✓ Status: {health['status']}")
            print(f"✓ Version: {health['version']}")
            return True
        else:
            print(f"\n✗ Service unhealthy: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"\n✗ Service unavailable: {e}")
        return False

def simulate_claim_submission():
    """
    Example: Simulate a complete claim submission with required photos
    """
    print(f"\n{'='*60}")
    print("Simulating Claim Submission")
    print('='*60)
    
    # In a real scenario, these would be actual photos taken by the user
    required_photos = {
        'front': 'sample_vehicle_front.jpg',
        'rear': 'sample_vehicle_rear.jpg',
        'left': 'sample_vehicle_left.jpg',
        'right': 'sample_vehicle_right.jpg',
        'damage': 'sample_vehicle_damage.jpg'
    }
    
    print("\nRequired photos:")
    for photo_type, filename in required_photos.items():
        print(f"  • {photo_type}: {filename}")
    
    # Check if sample files exist
    missing_files = [f for f in required_photos.values() if not os.path.exists(f)]
    
    if missing_files:
        print(f"\n⚠ Warning: The following sample files don't exist:")
        for f in missing_files:
            print(f"  • {f}")
        print("\nUsing generic test image for demonstration...")
        return
    
    # Validate each photo
    print("\nValidating photos...")
    all_passed = True
    
    for photo_type, filename in required_photos.items():
        result = check_single_image(filename, photo_type)
        if result and not result['passed']:
            all_passed = False
            print(f"\n✗ {photo_type} photo failed quality check")
    
    if all_passed:
        print(f"\n{'='*60}")
        print("✓ All photos passed! Claim can be submitted.")
        print('='*60)
    else:
        print(f"\n{'='*60}")
        print("✗ Some photos failed. Please retake and resubmit.")
        print('='*60)

def main():
    """
    Main function demonstrating various usage patterns
    """
    print("\n" + "="*60)
    print("AVA Image Quality Checker - Example Usage")
    print("="*60)
    
    # 1. Health Check
    if not health_check():
        print("\n⚠ Please start the quality service first:")
        print("  python quality_api.py")
        return
    
    # 2. Get Quality Standards
    get_quality_standards()
    
    # 3. Check single image (if exists)
    sample_image = "sample_vehicle.jpg"
    if os.path.exists(sample_image):
        check_single_image(sample_image, "front")
    else:
        print(f"\n⚠ Sample image '{sample_image}' not found")
        print("  Please provide a sample image to test")
    
    # 4. Batch check (if multiple samples exist)
    sample_images = [f for f in os.listdir('.') if f.startswith('sample_') and f.endswith('.jpg')]
    if len(sample_images) > 1:
        check_batch_images(sample_images)
    
    # 5. Simulate claim submission
    # simulate_claim_submission()
    
    print(f"\n{'='*60}")
    print("Example usage complete!")
    print('='*60)

if __name__ == "__main__":
    main()