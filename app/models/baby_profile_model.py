from sqlalchemy import Column, Integer, String, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base import Base

class BabyProfile(Base):
    __tablename__ = "baby_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)
    weight = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    medical_condition = Column(String, nullable=True)
    profile_picture = Column(String, nullable=True)
    head_camera_model_classes = Column(JSON, nullable=True)
    static_camera_model_classes = Column(JSON, nullable=True)
    head_camera_ip = Column(String(100), nullable=True)
    static_camera_ip = Column(String(100), nullable=True)


    detection_results = relationship("DetectionResult", back_populates="baby_profile")
    classes = relationship("ClassObject", back_populates="baby_profile")