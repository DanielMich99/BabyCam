from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import Base

class Camera(Base):
    __tablename__ = "cameras"

    id = Column(Integer, primary_key=True, index=True)
    profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)
    url = Column(String, nullable=False)
    active = Column(Boolean, default=True)

    # קשר לפרופיל התינוק
    #profile = relationship("BabyProfile", back_populates="camera")
