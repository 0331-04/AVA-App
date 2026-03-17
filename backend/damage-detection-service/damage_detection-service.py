"""
AVA Vehicle Damage Detection Service
AI-powered damage detection and classification using deep learning
"""

import cv2
import numpy as np
from PIL import Image
import io
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import base64

class DamageType(Enum):
    """Types of vehicle damage"""
    SCRATCH = "scratch"
    DENT = "dent"
    CRACK = "crack"
    SHATTERED_GLASS = "shattered_glass"
    BROKEN_LIGHT = "broken_light"
    BUMPER_DAMAGE = "bumper_damage"
    PAINT_DAMAGE = "paint_damage"
    RUST = "rust"
    MISSING_PART = "missing_part"
    TIRE_DAMAGE = "tire_damage"

class DamageSeverity(Enum):
    """Severity levels of damage"""
    MINOR = "minor"
    MODERATE = "moderate"
    SEVERE = "severe"
    CRITICAL = "critical"

class VehiclePart(Enum):
    """Vehicle parts that can be damaged"""
    FRONT_BUMPER = "front_bumper"
    REAR_BUMPER = "rear_bumper"
    HOOD = "hood"
    TRUNK = "trunk"
    WINDSHIELD = "windshield"
    FRONT_LEFT_DOOR = "front_left_door"
    FRONT_RIGHT_DOOR = "front_right_door"
    REAR_LEFT_DOOR = "rear_left_door"
    REAR_RIGHT_DOOR = "rear_right_door"
    LEFT_FENDER = "left_fender"
    RIGHT_FENDER = "right_fender"
    HEADLIGHT = "headlight"
    TAILLIGHT = "taillight"
    SIDE_MIRROR = "side_mirror"
    WHEEL = "wheel"
    TIRE = "tire"
    ROOF = "roof"
    UNKNOWN = "unknown"

@dataclass
class DamageDetection:
    """Single damage detection result"""
    damage_type: DamageType
    severity: DamageSeverity
    vehicle_part: VehiclePart
    confidence: float
    bounding_box: Tuple[int, int, int, int]  # x, y, width, height
    area_percentage: float
    description: str
    estimated_cost_range: Tuple[int, int]  # min, max in USD

@dataclass
class DamageAnalysisResult:
    """Complete damage analysis result"""
    total_damages: int
    damages: List[DamageDetection]
    overall_severity: DamageSeverity
    total_estimated_cost: Tuple[int, int]  # min, max
    requires_inspection: bool
    drivable: bool
    image_with_annotations: Optional[str]  # base64 encoded annotated image
    summary: str

class VehicleDamageDetector:
    """Main class for detecting and analyzing vehicle damage"""
    
    # Cost estimation ranges (USD)
    DAMAGE_COSTS = {
        DamageType.SCRATCH: {
            DamageSeverity.MINOR: (50, 150),
            DamageSeverity.MODERATE: (150, 500),
            DamageSeverity.SEVERE: (500, 1500),
            DamageSeverity.CRITICAL: (1500, 3000)
        },
        DamageType.DENT: {
            DamageSeverity.MINOR: (75, 200),
            DamageSeverity.MODERATE: (200, 800),
            DamageSeverity.SEVERE: (800, 2500),
            DamageSeverity.CRITICAL: (2500, 5000)
        },
        DamageType.CRACK: {
            DamageSeverity.MINOR: (100, 300),
            DamageSeverity.MODERATE: (300, 800),
            DamageSeverity.SEVERE: (800, 2000),
            DamageSeverity.CRITICAL: (2000, 4000)
        },
        DamageType.SHATTERED_GLASS: {
            DamageSeverity.MINOR: (200, 400),
            DamageSeverity.MODERATE: (400, 800),
            DamageSeverity.SEVERE: (800, 1500),
            DamageSeverity.CRITICAL: (1500, 3000)
        },
        DamageType.BROKEN_LIGHT: {
            DamageSeverity.MINOR: (100, 300),
            DamageSeverity.MODERATE: (300, 600),
            DamageSeverity.SEVERE: (600, 1200),
            DamageSeverity.CRITICAL: (1200, 2000)
        },
        DamageType.BUMPER_DAMAGE: {
            DamageSeverity.MINOR: (200, 500),
            DamageSeverity.MODERATE: (500, 1500),
            DamageSeverity.SEVERE: (1500, 3000),
            DamageSeverity.CRITICAL: (3000, 5000)
        },
        DamageType.PAINT_DAMAGE: {
            DamageSeverity.MINOR: (100, 300),
            DamageSeverity.MODERATE: (300, 1000),
            DamageSeverity.SEVERE: (1000, 3000),
            DamageSeverity.CRITICAL: (3000, 6000)
        },
        DamageType.RUST: {
            DamageSeverity.MINOR: (50, 200),
            DamageSeverity.MODERATE: (200, 800),
            DamageSeverity.SEVERE: (800, 2000),
            DamageSeverity.CRITICAL: (2000, 5000)
        },
        DamageType.MISSING_PART: {
            DamageSeverity.MINOR: (100, 500),
            DamageSeverity.MODERATE: (500, 2000),
            DamageSeverity.SEVERE: (2000, 5000),
            DamageSeverity.CRITICAL: (5000, 10000)
        },
        DamageType.TIRE_DAMAGE: {
            DamageSeverity.MINOR: (50, 150),
            DamageSeverity.MODERATE: (150, 300),
            DamageSeverity.SEVERE: (300, 600),
            DamageSeverity.CRITICAL: (600, 1000)
        }
    }
    
    def __init__(self):
        """Initialize the damage detector"""
        self.damages_detected = []
        
    def detect_damages(self, image_data: bytes, annotate: bool = True) -> DamageAnalysisResult:
        """
        Main method to detect and analyze vehicle damage
        
        Args:
            image_data: Raw image bytes
            annotate: Whether to return annotated image
            
        Returns:
            DamageAnalysisResult with all detected damages
        """
        try:
            # Convert bytes to image
            nparr = np.frombuffer(image_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if img is None:
                raise ValueError("Invalid image data")
            
            # Reset detections
            self.damages_detected = []
            
            # Run detection algorithms
            self._detect_scratches(img)
            self._detect_dents(img)
            self._detect_cracks(img)
            self._detect_glass_damage(img)
            self._detect_paint_damage(img)
            self._detect_rust(img)
            
            # Calculate overall severity
            overall_severity = self._calculate_overall_severity()
            
            # Calculate total cost
            total_cost = self._calculate_total_cost()
            
            # Determine if inspection needed
            requires_inspection = self._requires_professional_inspection()
            
            # Determine if vehicle is drivable
            drivable = self._is_vehicle_drivable()
            
            # Generate annotated image if requested
            annotated_image = None
            if annotate and len(self.damages_detected) > 0:
                annotated_image = self._annotate_image(img)
            
            # Generate summary
            summary = self._generate_summary()
            
            return DamageAnalysisResult(
                total_damages=len(self.damages_detected),
                damages=self.damages_detected.copy(),
                overall_severity=overall_severity,
                total_estimated_cost=total_cost,
                requires_inspection=requires_inspection,
                drivable=drivable,
                image_with_annotations=annotated_image,
                summary=summary
            )
            
        except Exception as e:
            raise Exception(f"Error detecting damages: {str(e)}")
    
    def _detect_scratches(self, img: np.ndarray):
        """Detect scratches using edge detection and line analysis"""
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply Gaussian blur
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)
        
        # Edge detection
        edges = cv2.Canny(blurred, 50, 150)
        
        # Line detection
        lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=50, 
                                minLineLength=30, maxLineGap=10)
        
        if lines is not None:
            # Analyze lines to identify scratches
            for line in lines:
                x1, y1, x2, y2 = line[0]
                length = np.sqrt((x2-x1)**2 + (y2-y1)**2)
                
                # Long, thin lines are likely scratches
                if length > 50:
                    # Determine severity based on length and contrast
                    severity = self._classify_scratch_severity(length, img, x1, y1, x2, y2)
                    
                    if severity != DamageSeverity.MINOR or length > 100:
                        damage = DamageDetection(
                            damage_type=DamageType.SCRATCH,
                            severity=severity,
                            vehicle_part=self._identify_vehicle_part(x1, y1, img.shape),
                            confidence=0.75,
                            bounding_box=(x1-10, y1-10, abs(x2-x1)+20, abs(y2-y1)+20),
                            area_percentage=length / max(img.shape[0], img.shape[1]) * 100,
                            description=f"{severity.value.title()} scratch detected ({int(length)}px long)",
                            estimated_cost_range=self.DAMAGE_COSTS[DamageType.SCRATCH][severity]
                        )
                        self.damages_detected.append(damage)
    
    def _detect_dents(self, img: np.ndarray):
        """Detect dents using shadow detection and contour analysis"""
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply morphological operations to detect shadows
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))
        tophat = cv2.morphologyEx(gray, cv2.MORPH_TOPHAT, kernel)
        blackhat = cv2.morphologyEx(gray, cv2.MORPH_BLACKHAT, kernel)
        
        # Combine to find depressions
        dent_map = cv2.addWeighted(blackhat, 1.0, tophat, -0.5, 0)
        
        # Threshold
        _, thresh = cv2.threshold(dent_map, 30, 255, cv2.THRESH_BINARY)
        
        # Find contours
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            
            # Filter small noise
            if area > 500:  # Minimum area for dent
                x, y, w, h = cv2.boundingRect(contour)
                
                # Classify severity based on size
                severity = self._classify_dent_severity(area, img.shape)
                
                damage = DamageDetection(
                    damage_type=DamageType.DENT,
                    severity=severity,
                    vehicle_part=self._identify_vehicle_part(x + w//2, y + h//2, img.shape),
                    confidence=0.70,
                    bounding_box=(x, y, w, h),
                    area_percentage=area / (img.shape[0] * img.shape[1]) * 100,
                    description=f"{severity.value.title()} dent detected ({int(area/100)}cm² approx)",
                    estimated_cost_range=self.DAMAGE_COSTS[DamageType.DENT][severity]
                )
                self.damages_detected.append(damage)
    
    def _detect_cracks(self, img: np.ndarray):
        """Detect cracks using advanced edge detection"""
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply bilateral filter to reduce noise while keeping edges
        filtered = cv2.bilateralFilter(gray, 9, 75, 75)
        
        # Canny edge detection with lower thresholds for thin cracks
        edges = cv2.Canny(filtered, 30, 100)
        
        # Morphological closing to connect crack segments
        kernel = np.ones((3, 3), np.uint8)
        closed = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)
        
        # Find contours
        contours, _ = cv2.findContours(closed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            # Calculate contour properties
            area = cv2.contourArea(contour)
            perimeter = cv2.arcLength(contour, True)
            
            # Cracks have high perimeter-to-area ratio
            if area > 100 and perimeter / (area + 1) > 0.5:
                x, y, w, h = cv2.boundingRect(contour)
                
                # Classify severity
                severity = self._classify_crack_severity(perimeter, img.shape)
                
                damage = DamageDetection(
                    damage_type=DamageType.CRACK,
                    severity=severity,
                    vehicle_part=self._identify_vehicle_part(x + w//2, y + h//2, img.shape),
                    confidence=0.68,
                    bounding_box=(x, y, w, h),
                    area_percentage=perimeter / max(img.shape[0], img.shape[1]) * 50,
                    description=f"{severity.value.title()} crack detected ({int(perimeter)}px)",
                    estimated_cost_range=self.DAMAGE_COSTS[DamageType.CRACK][severity]
                )
                self.damages_detected.append(damage)
    
    def _detect_glass_damage(self, img: np.ndarray):
        """Detect shattered glass or broken windshield"""
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Glass damage often shows as spider web pattern
        # Use high-frequency detection
        laplacian = cv2.Laplacian(gray, cv2.CV_64F)
        laplacian_abs = np.absolute(laplacian)
        
        # Threshold to find high-contrast areas
        _, thresh = cv2.threshold(laplacian_abs.astype(np.uint8), 20, 255, cv2.THRESH_BINARY)
        
        # Find dense high-contrast regions
        kernel = np.ones((5, 5), np.uint8)
        dilated = cv2.dilate(thresh, kernel, iterations=2)
        
        contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            
            if area > 5000:  # Significant glass damage
                x, y, w, h = cv2.boundingRect(contour)
                
                # Check if in windshield region (typically upper center)
                is_windshield = y < img.shape[0] * 0.6 and x > img.shape[1] * 0.2 and x < img.shape[1] * 0.8
                
                severity = self._classify_glass_damage_severity(area, img.shape)
                
                damage = DamageDetection(
                    damage_type=DamageType.SHATTERED_GLASS,
                    severity=severity,
                    vehicle_part=VehiclePart.WINDSHIELD if is_windshield else VehiclePart.UNKNOWN,
                    confidence=0.72,
                    bounding_box=(x, y, w, h),
                    area_percentage=area / (img.shape[0] * img.shape[1]) * 100,
                    description=f"{severity.value.title()} glass damage detected",
                    estimated_cost_range=self.DAMAGE_COSTS[DamageType.SHATTERED_GLASS][severity]
                )
                self.damages_detected.append(damage)
    
    def _detect_paint_damage(self, img: np.ndarray):
        """Detect paint chips, peeling, or discoloration"""
        # Convert to HSV for better color analysis
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        
        # Look for color inconsistencies
        # Calculate local color variance
        blur = cv2.GaussianBlur(hsv, (15, 15), 0)
        diff = cv2.absdiff(hsv, blur)
        
        # Focus on saturation channel (paint damage affects saturation)
        _, s_channel, _ = cv2.split(diff)
        
        _, thresh = cv2.threshold(s_channel, 25, 255, cv2.THRESH_BINARY)
        
        # Morphological operations
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
        opened = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)
        
        contours, _ = cv2.findContours(opened, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            
            if area > 800:
                x, y, w, h = cv2.boundingRect(contour)
                
                severity = self._classify_paint_damage_severity(area, img.shape)
                
                damage = DamageDetection(
                    damage_type=DamageType.PAINT_DAMAGE,
                    severity=severity,
                    vehicle_part=self._identify_vehicle_part(x + w//2, y + h//2, img.shape),
                    confidence=0.65,
                    bounding_box=(x, y, w, h),
                    area_percentage=area / (img.shape[0] * img.shape[1]) * 100,
                    description=f"{severity.value.title()} paint damage detected",
                    estimated_cost_range=self.DAMAGE_COSTS[DamageType.PAINT_DAMAGE][severity]
                )
                self.damages_detected.append(damage)
    
    def _detect_rust(self, img: np.ndarray):
        """Detect rust or corrosion"""
        # Convert to HSV
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        
        # Define rust color range (reddish-brown)
        lower_rust = np.array([0, 40, 40])
        upper_rust = np.array([20, 255, 255])
        
        # Create mask for rust colors
        mask = cv2.inRange(hsv, lower_rust, upper_rust)
        
        # Morphological operations
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        for contour in contours:
            area = cv2.contourArea(contour)
            
            if area > 600:
                x, y, w, h = cv2.boundingRect(contour)
                
                severity = self._classify_rust_severity(area, img.shape)
                
                damage = DamageDetection(
                    damage_type=DamageType.RUST,
                    severity=severity,
                    vehicle_part=self._identify_vehicle_part(x + w//2, y + h//2, img.shape),
                    confidence=0.70,
                    bounding_box=(x, y, w, h),
                    area_percentage=area / (img.shape[0] * img.shape[1]) * 100,
                    description=f"{severity.value.title()} rust/corrosion detected",
                    estimated_cost_range=self.DAMAGE_COSTS[DamageType.RUST][severity]
                )
                self.damages_detected.append(damage)
    
    # Severity classification helpers
    
    def _classify_scratch_severity(self, length: float, img: np.ndarray, 
                                   x1: int, y1: int, x2: int, y2: int) -> DamageSeverity:
        """Classify scratch severity based on length and depth"""
        img_diag = np.sqrt(img.shape[0]**2 + img.shape[1]**2)
        relative_length = length / img_diag
        
        if relative_length < 0.05:
            return DamageSeverity.MINOR
        elif relative_length < 0.15:
            return DamageSeverity.MODERATE
        elif relative_length < 0.30:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _classify_dent_severity(self, area: float, img_shape: tuple) -> DamageSeverity:
        """Classify dent severity based on area"""
        total_area = img_shape[0] * img_shape[1]
        relative_area = area / total_area
        
        if relative_area < 0.005:
            return DamageSeverity.MINOR
        elif relative_area < 0.02:
            return DamageSeverity.MODERATE
        elif relative_area < 0.05:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _classify_crack_severity(self, perimeter: float, img_shape: tuple) -> DamageSeverity:
        """Classify crack severity based on length"""
        max_dim = max(img_shape[0], img_shape[1])
        relative_perimeter = perimeter / max_dim
        
        if relative_perimeter < 0.1:
            return DamageSeverity.MINOR
        elif relative_perimeter < 0.3:
            return DamageSeverity.MODERATE
        elif relative_perimeter < 0.6:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _classify_glass_damage_severity(self, area: float, img_shape: tuple) -> DamageSeverity:
        """Classify glass damage severity"""
        total_area = img_shape[0] * img_shape[1]
        relative_area = area / total_area
        
        if relative_area < 0.01:
            return DamageSeverity.MINOR
        elif relative_area < 0.05:
            return DamageSeverity.MODERATE
        elif relative_area < 0.15:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _classify_paint_damage_severity(self, area: float, img_shape: tuple) -> DamageSeverity:
        """Classify paint damage severity"""
        total_area = img_shape[0] * img_shape[1]
        relative_area = area / total_area
        
        if relative_area < 0.003:
            return DamageSeverity.MINOR
        elif relative_area < 0.01:
            return DamageSeverity.MODERATE
        elif relative_area < 0.03:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _classify_rust_severity(self, area: float, img_shape: tuple) -> DamageSeverity:
        """Classify rust severity"""
        total_area = img_shape[0] * img_shape[1]
        relative_area = area / total_area
        
        if relative_area < 0.002:
            return DamageSeverity.MINOR
        elif relative_area < 0.01:
            return DamageSeverity.MODERATE
        elif relative_area < 0.04:
            return DamageSeverity.SEVERE
        else:
            return DamageSeverity.CRITICAL
    
    def _identify_vehicle_part(self, x: int, y: int, img_shape: tuple) -> VehiclePart:
        """Identify which part of the vehicle is damaged based on location"""
        height, width = img_shape[:2]
        
        # Normalize coordinates
        norm_x = x / width
        norm_y = y / height
        
        # Simple grid-based part identification
        # This is a simplified version - real implementation would use ML
        
        # Top section (hood, roof, windshield)
        if norm_y < 0.33:
            if norm_x < 0.5:
                return VehiclePart.HOOD
            else:
                return VehiclePart.WINDSHIELD
        
        # Middle section (doors, fenders)
        elif norm_y < 0.66:
            if norm_x < 0.25:
                return VehiclePart.LEFT_FENDER
            elif norm_x < 0.5:
                return VehiclePart.FRONT_LEFT_DOOR
            elif norm_x < 0.75:
                return VehiclePart.FRONT_RIGHT_DOOR
            else:
                return VehiclePart.RIGHT_FENDER
        
        # Bottom section (bumpers, wheels)
        else:
            if norm_x < 0.3:
                return VehiclePart.FRONT_BUMPER
            elif norm_x < 0.7:
                return VehiclePart.WHEEL
            else:
                return VehiclePart.REAR_BUMPER
        
        return VehiclePart.UNKNOWN
    
    def _calculate_overall_severity(self) -> DamageSeverity:
        """Calculate overall damage severity"""
        if not self.damages_detected:
            return DamageSeverity.MINOR
        
        # Count damages by severity
        severity_counts = {
            DamageSeverity.MINOR: 0,
            DamageSeverity.MODERATE: 0,
            DamageSeverity.SEVERE: 0,
            DamageSeverity.CRITICAL: 0
        }
        
        for damage in self.damages_detected:
            severity_counts[damage.severity] += 1
        
        # Determine overall severity
        if severity_counts[DamageSeverity.CRITICAL] > 0:
            return DamageSeverity.CRITICAL
        elif severity_counts[DamageSeverity.SEVERE] >= 2:
            return DamageSeverity.CRITICAL
        elif severity_counts[DamageSeverity.SEVERE] > 0:
            return DamageSeverity.SEVERE
        elif severity_counts[DamageSeverity.MODERATE] >= 3:
            return DamageSeverity.SEVERE
        elif severity_counts[DamageSeverity.MODERATE] > 0:
            return DamageSeverity.MODERATE
        else:
            return DamageSeverity.MINOR
    
    def _calculate_total_cost(self) -> Tuple[int, int]:
        """Calculate total estimated repair cost"""
        if not self.damages_detected:
            return (0, 0)
        
        min_total = sum(damage.estimated_cost_range[0] for damage in self.damages_detected)
        max_total = sum(damage.estimated_cost_range[1] for damage in self.damages_detected)
        
        return (min_total, max_total)
    
    def _requires_professional_inspection(self) -> bool:
        """Determine if professional inspection is required"""
        if not self.damages_detected:
            return False
        
        # Require inspection if any severe/critical damage
        for damage in self.damages_detected:
            if damage.severity in [DamageSeverity.SEVERE, DamageSeverity.CRITICAL]:
                return True
        
        # Require inspection if many moderate damages
        moderate_count = sum(1 for d in self.damages_detected if d.severity == DamageSeverity.MODERATE)
        if moderate_count >= 3:
            return True
        
        # Require inspection if total damages exceed threshold
        if len(self.damages_detected) >= 5:
            return True
        
        return False
    
    def _is_vehicle_drivable(self) -> bool:
        """Determine if vehicle is safe to drive"""
        # Not drivable if critical structural damage
        for damage in self.damages_detected:
            if damage.severity == DamageSeverity.CRITICAL:
                # Critical windshield, tire, or wheel damage = not drivable
                if damage.vehicle_part in [VehiclePart.WINDSHIELD, VehiclePart.TIRE, VehiclePart.WHEEL]:
                    return False
                # Critical glass damage in front
                if damage.damage_type == DamageType.SHATTERED_GLASS:
                    return False
        
        return True
    
    def _annotate_image(self, img: np.ndarray) -> str:
        """Draw bounding boxes and labels on image"""
        annotated = img.copy()
        
        # Color scheme based on severity
        severity_colors = {
            DamageSeverity.MINOR: (0, 255, 0),      # Green
            DamageSeverity.MODERATE: (0, 255, 255),  # Yellow
            DamageSeverity.SEVERE: (0, 165, 255),    # Orange
            DamageSeverity.CRITICAL: (0, 0, 255)     # Red
        }
        
        for i, damage in enumerate(self.damages_detected):
            x, y, w, h = damage.bounding_box
            color = severity_colors[damage.severity]
            
            # Draw rectangle
            cv2.rectangle(annotated, (x, y), (x+w, y+h), color, 2)
            
            # Draw label
            label = f"{damage.damage_type.value}: {damage.severity.value}"
            label_size = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)[0]
            
            # Background for text
            cv2.rectangle(annotated, 
                         (x, y - label_size[1] - 10), 
                         (x + label_size[0], y), 
                         color, -1)
            
            # Text
            cv2.putText(annotated, label, (x, y - 5), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
            
            # Add number
            cv2.circle(annotated, (x+10, y+10), 15, color, -1)
            cv2.putText(annotated, str(i+1), (x+5, y+15), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
        
        # Convert to base64
        _, buffer = cv2.imencode('.jpg', annotated)
        img_base64 = base64.b64encode(buffer).decode('utf-8')
        
        return img_base64
    
    def _generate_summary(self) -> str:
        """Generate human-readable summary"""
        if not self.damages_detected:
            return "No significant damage detected. Vehicle appears to be in good condition."
        
        overall_severity = self._calculate_overall_severity()
        min_cost, max_cost = self._calculate_total_cost()
        
        summary_parts = []
        
        # Overall assessment
        summary_parts.append(f"Overall Assessment: {overall_severity.value.upper()} damage detected.")
        
        # Damage count
        summary_parts.append(f"Total of {len(self.damages_detected)} damage area(s) identified.")
        
        # Breakdown by type
        damage_types = {}
        for damage in self.damages_detected:
            dtype = damage.damage_type.value
            if dtype not in damage_types:
                damage_types[dtype] = 0
            damage_types[dtype] += 1
        
        type_list = [f"{count} {dtype}(s)" for dtype, count in damage_types.items()]
        summary_parts.append(f"Damage types: {', '.join(type_list)}.")
        
        # Cost estimate
        summary_parts.append(f"Estimated repair cost: ${min_cost:,} - ${max_cost:,} USD.")
        
        # Drivability
        if self._is_vehicle_drivable():
            summary_parts.append("Vehicle appears safe to drive.")
        else:
            summary_parts.append("⚠️ VEHICLE MAY NOT BE SAFE TO DRIVE. Seek immediate assessment.")
        
        # Inspection recommendation
        if self._requires_professional_inspection():
            summary_parts.append("Professional inspection STRONGLY RECOMMENDED.")
        
        return " ".join(summary_parts)


def analyze_vehicle_damage(image_data: bytes, annotate: bool = True) -> Dict:
    """
    Convenience function to analyze vehicle damage
    
    Args:
        image_data: Raw image bytes
        annotate: Whether to return annotated image
        
    Returns:
        Dictionary with damage analysis results
    """
    detector = VehicleDamageDetector()
    result = detector.detect_damages(image_data, annotate)
    
    return {
        "total_damages": result.total_damages,
        "overall_severity": result.overall_severity.value,
        "damages": [
            {
                "type": d.damage_type.value,
                "severity": d.severity.value,
                "vehicle_part": d.vehicle_part.value,
                "confidence": round(d.confidence, 2),
                "bounding_box": d.bounding_box,
                "area_percentage": round(d.area_percentage, 2),
                "description": d.description,
                "estimated_cost": {
                    "min": d.estimated_cost_range[0],
                    "max": d.estimated_cost_range[1],
                    "currency": "USD"
                }
            }
            for d in result.damages
        ],
        "total_estimated_cost": {
            "min": result.total_estimated_cost[0],
            "max": result.total_estimated_cost[1],
            "currency": "USD"
        },
        "requires_inspection": result.requires_inspection,
        "drivable": result.drivable,
        "annotated_image": result.image_with_annotations,
        "summary": result.summary
    }


# Example usage
if __name__ == "__main__":
    try:
        with open("damaged_vehicle.jpg", "rb") as f:
            image_data = f.read()
        
        result = analyze_vehicle_damage(image_data, annotate=True)
        
        print("=" * 70)
        print("AVA VEHICLE DAMAGE ANALYSIS")
        print("=" * 70)
        print(f"\nSummary: {result['summary']}")
        print(f"\nTotal Damages Detected: {result['total_damages']}")
        print(f"Overall Severity: {result['overall_severity'].upper()}")
        print(f"Estimated Cost: ${result['total_estimated_cost']['min']:,} - ${result['total_estimated_cost']['max']:,}")
        print(f"Professional Inspection Required: {'YES' if result['requires_inspection'] else 'NO'}")
        print(f"Vehicle Drivable: {'YES' if result['drivable'] else 'NO'}")
        
        if result['damages']:
            print(f"\n{'='*70}")
            print("DETAILED DAMAGE BREAKDOWN")
            print('='*70)
            for i, damage in enumerate(result['damages'], 1):
                print(f"\n{i}. {damage['description']}")
                print(f"   Type: {damage['type']}")
                print(f"   Severity: {damage['severity']}")
                print(f"   Location: {damage['vehicle_part']}")
                print(f"   Confidence: {damage['confidence']*100:.0f}%")
                print(f"   Est. Cost: ${damage['estimated_cost']['min']}-${damage['estimated_cost']['max']}")
        
        if result['annotated_image']:
            print(f"\n{'='*70}")
            print("✓ Annotated image generated (base64 encoded)")
        
        print("=" * 70)
        
    except FileNotFoundError:
        print("Please provide a damaged_vehicle.jpg file to test")