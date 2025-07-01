from sqlalchemy import Column, Integer, String, ForeignKey, Enum, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import Base
import enum

# Enum class to define risk levels for object classes
class RiskLevelEnum(str, enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"

# SQLAlchemy model representing a single object class (e.g., 'knife', 'bottle') for a baby profile
class ClassObject(Base):
    __tablename__ = "classes"

    # Ensure uniqueness of class name and model index per camera type within each baby profile
    __table_args__ = (
        UniqueConstraint("baby_profile_id", "camera_type", "name", name="uq_class_name_per_camera"),
        UniqueConstraint("baby_profile_id", "camera_type", "model_index", name="uq_model_index_per_camera"),
    )

    id = Column(Integer, primary_key=True, index=True)  # Unique identifier
    name = Column(String, nullable=False)  # Class name (e.g., "knife")
    risk_level = Column(Enum(RiskLevelEnum), nullable=False)  # Risk level: low, medium, or high
    model_index = Column(Integer, nullable=True)  # Index used in the model's output layer
    camera_type = Column(String, nullable=False)  # 'head_camera' or 'static_camera'
    baby_profile_id = Column(Integer, ForeignKey("baby_profiles.id"), nullable=False)  # Link to associated baby profile

    # Relationship back to BabyProfile (many-to-one)
    baby_profile = relationship("BabyProfile", back_populates="classes")
