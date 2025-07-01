from sqlalchemy import Column, Integer, String, ForeignKey, JSON, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime

from app.models.base import Base

class BabyProfile(Base):
    """SQLAlchemy model for storing baby profile details."""

    __tablename__ = "baby_profiles"

    id = Column(Integer, primary_key=True, index=True)  # Unique identifier for the baby profile
    user_id = Column(Integer, ForeignKey("users.id"))  # Foreign key to the user who owns this profile

    name = Column(String)  # Baby's name
    age = Column(Integer, nullable=True)  # Baby's age (in months)
    gender = Column(String, nullable=True)  # Baby's gender: 'male', 'female', or 'other'
    weight = Column(Integer, nullable=True)  # Baby's weight in kilograms
    height = Column(Integer, nullable=True)  # Baby's height in centimeters
    medical_condition = Column(String, nullable=True)  # Any known medical condition
    profile_picture = Column(String, nullable=True)  # URL or path to the baby's profile picture

    # JSON dictionaries mapping class names to risk levels
    head_camera_model_classes = Column(JSON, nullable=True)  # For head-mounted camera
    static_camera_model_classes = Column(JSON, nullable=True)  # For static room camera

    # IP addresses of the connected cameras
    head_camera_ip = Column(String(100), nullable=True)  # Head camera IP address
    static_camera_ip = Column(String(100), nullable=True)  # Static camera IP address

    # Booleans indicating whether each camera is currently connected
    head_camera_on = Column(Boolean, nullable=False, default=False)
    static_camera_on = Column(Boolean, nullable=False, default=False)

    # Last time the model was updated for each camera
    head_camera_model_last_updated_time = Column(DateTime, nullable=True, default=None)
    static_camera_model_last_updated_time = Column(DateTime, nullable=True, default=None)

    # Whether each camera is currently active in the detection system
    head_camera_in_detection_system_on = Column(Boolean, nullable=False, default=False)
    static_camera_in_detection_system_on = Column(Boolean, nullable=False, default=False)

    # Relationships to other tables
    detection_results = relationship("DetectionResult", back_populates="baby_profile")  # Linked detection results
    classes = relationship("ClassObject", back_populates="baby_profile")  # Object classes defined for this baby
