from sqlalchemy import Column, Integer, String, ForeignKey, JSON, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime

from app.models.base import Base


class BabyProfile(Base):
    """SQLAlchemy model for storing baby profile details."""

    __tablename__ = "baby_profiles"

    id = Column(Integer, primary_key=True, index=True)  # Unique identifier for the baby profile
    user_id = Column(Integer, ForeignKey("users.id"))  # ID of the user who owns this profile

    name = Column(String)  # Baby's name
    age = Column(Integer, nullable=True)  # Baby's age (in months or years)
    gender = Column(String, nullable=True)  # 'male', 'female', or 'other'
    weight = Column(Integer, nullable=True)  # Baby's weight in kg
    height = Column(Integer, nullable=True)  # Baby's height in cm
    medical_condition = Column(String, nullable=True)  # Any known medical condition
    profile_picture = Column(String, nullable=True)  # Path or URL to the baby's profile picture

    head_camera_model_classes = Column(JSON, nullable=True)  # JSON mapping of class names to risk levels for head camera
    static_camera_model_classes = Column(JSON, nullable=True)  # JSON mapping of class names to risk levels for static camera

    head_camera_ip = Column(String(100), nullable=True)  # IP address of the head-mounted camera
    static_camera_ip = Column(String(100), nullable=True)  # IP address of the static room camera

    head_camera_on = Column(Boolean, nullable=False, default=False)  # Connection state of head camera
    static_camera_on = Column(Boolean, nullable=False, default=False)  # Connection state of static camera

    head_camera_model_last_updated_time = Column(DateTime, nullable=True, default=None)
    static_camera_model_last_updated_time = Column(DateTime, nullable=True, default=None)

    head_camera_in_detection_system_on = Column(Boolean, nullable=False, default=False)
    static_camera_in_detection_system_on = Column(Boolean, nullable=False, default=False)

    # Relationships
    detection_results = relationship("DetectionResult", back_populates="baby_profile")  # List of detection results linked to this profile
    classes = relationship("ClassObject", back_populates="baby_profile")  # List of object classes defined for this profile
