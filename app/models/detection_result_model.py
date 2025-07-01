from sqlalchemy import Column, Integer, ForeignKey, DateTime, Float, String
from sqlalchemy.orm import relationship
from datetime import datetime
import pytz
from app.models.base import Base

# SQLAlchemy model representing a single object detection event
class DetectionResult(Base):
    __tablename__ = "detection_results"

    id = Column(Integer, primary_key=True, index=True)  # Unique identifier for the detection result

    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)  # Link to the related baby profile
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)  # Link to the detected object's class
    class_name = Column(String, nullable=False)  # Redundant name for easier access (copied from class definition)

    confidence = Column(Float, nullable=False)  # Confidence score of the detection (e.g., 0.87)
    camera_type = Column(String, nullable=False)  # Type of camera: 'head_camera' or 'static_camera'

    timestamp = Column(DateTime, default=datetime.now)  # When the detection occurred
    image_path = Column(String, nullable=True)  # Path to the image where the detection occurred

    # Relationships to other tables
    baby_profile = relationship("BabyProfile", back_populates="detection_results")  # Link back to baby profile
    class_ = relationship("ClassObject")  # Link to the class object (no back_populates here)
