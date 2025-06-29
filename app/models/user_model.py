from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    already_logged_in = Column(Boolean, default=False, nullable=False)
    
    fcm_tokens = relationship("UserFCMToken", back_populates="user", cascade="all, delete-orphan")

class UserFCMToken(Base):
    __tablename__ = "user_fcm_tokens"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    token = Column(String, nullable=False, unique=True)

    user = relationship("User", back_populates="fcm_tokens")

