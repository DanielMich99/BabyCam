from sqlalchemy import Column, Integer, String, ForeignKey
from app.models.base import Base

class DetectionResult(Base):
    """שומר תוצאות זיהוי של תמונות"""
    __tablename__ = "detection_results"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    detected_object = Column(String)
    confidence = Column(Integer)
