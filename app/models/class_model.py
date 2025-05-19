from sqlalchemy import Column, Integer, String, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.models.base import Base
import enum

class RiskLevelEnum(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"

class ClassObject(Base):
    __tablename__ = "classes"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    risk_level = Column(Enum(RiskLevelEnum), nullable=False)
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)

    baby_profile = relationship("BabyProfile", back_populates="classes")
