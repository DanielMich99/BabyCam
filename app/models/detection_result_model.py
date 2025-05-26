from sqlalchemy import Column, Integer, ForeignKey, DateTime, Float, String
from sqlalchemy.orm import relationship
from datetime import datetime
from app.models.base import Base

class DetectionResult(Base):
    __tablename__ = "detection_results"

    id = Column(Integer, primary_key=True, index=True)
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)
    class_id = Column(Integer, ForeignKey("classes.id"), nullable=False)
    class_name = Column(String, nullable=False)
    confidence = Column(Float, nullable=False)
    camera_type = Column(String, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

    baby_profile = relationship("BabyProfile", back_populates="detection_results")
    class_ = relationship("ClassObject")  # assuming class_model.py defines ClassObject