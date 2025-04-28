from sqlalchemy import Column, Integer, String, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base import Base

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)
    objects_detected = Column(JSON, nullable=True)
    description = Column(String, nullable=False)

    baby_profile = relationship("BabyProfile", back_populates="alerts")
