from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.models.base import Base

class DetectionResult(Base):
    """שומר תוצאות זיהוי של תמונות"""
    __tablename__ = "detection_results"

    id = Column(Integer, primary_key=True, index=True)
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"))
    detected_object = Column(String)
    confidence = Column(Integer)
    timestamp = Column(DateTime, default=datetime.utcnow)  # זמן יצירת הרשומה
    baby_profile = relationship("BabyProfile", back_populates="detection_results")