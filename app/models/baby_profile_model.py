from sqlalchemy import Column, Integer, String, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.models.base import Base

class BabyProfile(Base):
    __tablename__ = "baby_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String)
    age = Column(Integer)
    height = Column(Integer)
    sensitivity = Column(String)
    medical_condition = Column(String)
    profile_picture = Column(String, nullable=True)
    dangerous_objects = Column(JSON, nullable=True)

    camera = relationship("Camera", back_populates="profile", uselist=False)
