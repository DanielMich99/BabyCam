from sqlalchemy import Column, Integer, String, ForeignKey, Enum, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import Base
import enum

class RiskLevelEnum(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"

class ClassObject(Base):
    __tablename__ = "classes"
    __table_args__ = (
        UniqueConstraint("baby_profile_id", "camera_type", "name", name="uq_class_name_per_camera"),
        UniqueConstraint("baby_profile_id", "camera_type", "model_index", name="uq_model_index_per_camera"),
    )

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    risk_level = Column(Enum(RiskLevelEnum), nullable=False)
    model_index = Column(Integer, nullable=True)
    camera_type = Column(String, nullable=False)
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)

    baby_profile = relationship("BabyProfile", back_populates="classes")
